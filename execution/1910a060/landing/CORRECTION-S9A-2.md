# CORRECTION-S9A-2 (granted by parent at 2026-09-25 ~22:11Z)

## Trigger
The second S9-A compose run, `run/s9a-compose-20260925T220813Z`, stopped with rc 79 at line 287, after Jest had passed (7/7 suites). The untracked-file check read every `git status --porcelain --untracked-files=all` line except `?? node_modules/`. It therefore counted the 4 expected staged merge adds (`A `) as leftovers. The parent classified this as a script defect in status parsing, not a problem with the candidate. The details are in `COMPOSE_RESULT-S9A-2.md`.

## Change
The diff is in `analysis/CORRECTION-S9A-2.proposed.diff`.
1. **Line 287.** The check becomes:
   ```
   UT=$(git status --porcelain --untracked-files=all | grep '^??' | grep -v '^?? node_modules/' || true)
   [ -z "$UT" ] || refuse 79 …
   ```
   Only genuinely untracked entries are counted now.
2. **`W`.** It is now `/home/user/workspace/worktrees/1910a060-land-s9a-3`. Clones `-1` and `-2` are preserved untouched.

No other byte changed. The full static trace below found no further defect.

## Static trace of every compose step after Jest (read-only, against the preserved `-2` clone)
The `-2` clone state used for the trace: HEAD is M `62471b11`, MERGE_HEAD is `be88909f`, the index tree is `737c34a3`, and the worktree equals the index.

| Step | What was checked (read-only) | Result |
|---|---|---|
| Untracked check (corrected) | Ran the new pipeline in `-2`. | Empty, so it passes. |
| Commit message and BANNED_RE | Rendered the exact printf with the pinned values and grepped it. The lefthook `commit-msg` hook, `no-ai-tokens` (R3), uses the same regex after scrubbing `ai.txt`, `.well-known/ai*` and `User-Agent`. | Clean. |
| `git commit -F` context | cwd is `$W`. `user.name` and `user.email` are Bradley's in `$W`, and `GIT_AUTHOR_*`/`GIT_COMMITTER_*` are exported. `core.hooksPath` is unset, and `.git/hooks/{pre-commit,commit-msg}` are present (lefthook).<br>The pre-commit hooks are `check-r75.js --mode=staged`, `tsc --noEmit`, `eslint {staged}`, `prettier --check {staged}`, and `prod-readiness-precheck.sh --quick` (which runs only if the script is executable). They run over the same 4 staged S9-A files and the same checker set that the S8-F merge commit passed on M's parent lineage. | No object or path lookups outside `$W`. |
| Parents check | `git rev-list --parents -n1 HEAD` on a merge gives `M2 <HEAD before commit> <MERGE_HEAD>`. That is `M2 62471b11 be88909f`, which matches the expected string. | OK |
| Tree check | `HEAD^{tree}` vs `PRED_TREE`. The `-2` index is `737c34a3`. | OK, unless a hook rewrites bytes; prettier only runs `--check`. |
| Hygiene over `M..M2` | `rev-list --count M..be88909f` = 1, so `M..M2` = 2 commits (M2 and be88909f). be88909f: 0 identity mismatches against `Bradley Gleave <bradley@bradleytgpcoaching.com>`, empty trailers, message clean against BANNED_RE. M2 inherits the exported identity and the pre-scanned message. | OK |
| Post-commit clean check | Uses `git status --porcelain --untracked-files=no`. In `-2`, the only non-`A ` tracked entries number 0. After the commit, the `A ` entries become committed. | OK |
| Bundle export | Simulated `git bundle create /tmp/s9a-sim.bundle M..refs/heads/s9a-accepted` in `-2`: "is okay", head be88909f. This is the same form as `M..refs/heads/$BR`, run in `$W`, which holds both prerequisites. | OK |
| name-status and receipt | `git diff`/`git log` run in `$W`. The variables `HP HC NP NC LHV V HOOK_REF_ROOT` are set earlier in the same shell. | OK |
| Export SHA256SUMS | `( cd X && sha256sum ./* >SHA256SUMS )`: the glob expands before the redirection runs. Simulated: 2 files gave 2 lines, with no self-entry. | OK |
| State env | This is a `printf` to `$LANDING/state/compose-s9a.env`. That file is absent, and the directory exists after `mkdir -p`. | OK |
| Lock | fd 9 is held for the life of the script. Jest ran `--runInBand`, so no workers outlive it. The `-2` run released the lock at exit. | OK |

## Script identities
| Version | sha256 | Location |
|---|---|---|
| Pre-correction | `21f1ed8cc04b23bd0fa18e0a1f849676aaf1476548a88a2ccccd86187384eb2b` | Preserved as `analysis/land-s9a-1910.pre-CORRECTION-S9A-2.sh` |
| **Final, installed** | **`15a7799f4fedd70cd356693c6d55d4fbc00b041ac7abd1d1a7d04ad2f968a252`** | `land-s9a-1910.sh`; identical to `analysis/land-s9a-1910.CORRECTION-S9A-2.proposed.sh` |

The installed script passes `bash -n`.
