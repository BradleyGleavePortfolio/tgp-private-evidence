# S5-SOURCE-RESTORE — clean 143d451e + frozen two-file patch (revision 1, frozen) — STOPPED AT ONE CONTRADICTION

Writer: `restore_upstream_proof_inputs_muddwjad`, T4 source-only restoration builder (requested Claude Fable 5; runtime identity not observable, not asserted). Executed 2026-09-23T01:24:11Z–01:25:10Z. Mechanical restore only; no install, hook, test, prisma, generator, process, version, network, or commit action; no authored product change; no `execution/s5-r4/**` created.

Inputs read (only): `execution/e8d546f9/s5-v101/controls-v101-t0/run-s5-setup-npm-ci.v101.sh` (`5f94783b…8087`; pins L44–52, `dirty_fingerprint()` L172, gates L220–225) and `ctl-t0-only.v101.sh` (`51fb43b7…d62c`; pins L68–71, gates L184–191); `execution/op88/OWNED_LAUNCH_SCOPE.md` L8 (reference to "candidate 143d451e + patch c36258b3"); S5 bundle `2026-09-21/remediation/s5-r3/b3-pinned-resume/checkpoint-5-B3/s5-r3-candidate.bundle` (`e42aa021…5b48` ✔); patch packet `2026-09-22/remediation/s5-r4/checkpoint-1/` (`SHA256SUMS` 17/17 OK; `s5-r4-dirty-from-143d451e.patch` `c36258b3…5491`). Baseline `source/backend` read-only (HEAD c23b9d9f, porcelain 0 before/after).

## 1. Restored — `logs/S1-S2-restore-and-patch.txt`

| Fact | Value |
|---|---|
| Target | `/home/user/workspace/worktrees/s5-r4` (ABSENT before; standalone repo = byte copy of `source/backend/.git`, origin removed, 0 remotes, no promisor; bundle verified `okay`, requires c23b9d9f = local base; fetched offline to `refs/restored/execute/20260921-s5-r3`; `checkout --force --detach 143d451e`) |
| HEAD | **`143d451ead6ccdbebd92ca3031ba7a89867d6cfc`** = `PIN_HEAD` |
| Exact base tree (clean) | **`d0e122d35022377196908b7d132fc34c1af2fc6b`**; parent `b94c2488…`; c23b ancestor, 32 commits; 2114 tracked = 2114 files, 0 missing blobs, fsck ok; clean porcelain 0 before patch |
| Lock blob | **`354de3dae19449970497da6e4d87f0a1225a8f43`** = `PIN_LOCK_BLOB` (before and after patch); `package-lock.json` sha256 `b7fed5ed…9c55` |
| Raw patch | **`c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491`**, 103 lines, touches exactly `test/rls-g2-pg17-etq0.spec.ts` (`77bb94b6→ff5a38b8`, 100644) and `test/utils/g2-pg17-bootstrap.sh` (`c85eaca0→85a636ba`, 100755); pre-image blobs at HEAD match; `git apply --check` ok; applied to working tree only (index untouched, 0 untracked) |
| Status | `git status --porcelain` = `' M test/rls-g2-pg17-etq0.spec.ts\n M test/utils/g2-pg17-bootstrap.sh'` = **`PIN_DIRTY_STATUS` ✔** |
| Post-image content | `git hash-object` of the two working files = `ff5a38b8…` / `85a636ba…` = the patch's post-image ids → **tree content byte-exact** |
| Hygiene | `node_modules` absent, `dist` absent, hooks 0 (`pre-commit` absent, lefthook not installed), `core.hooksPath` unset, shallow (as baseline) |

## 2. CONTRADICTION (stop point) — `logs/S3-fingerprint-analysis.txt`

Live `dirty_fingerprint()` (runner formula: `sha256(git diff HEAD; status --porcelain --untracked-files=all; "\n")`) = **`16cc5e727a5490ccb8c37a192a517338546e85598b7ae32d6357e1081a9cfa88` ≠ `PIN_DIRTY_FINGERPRINT 6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0`.**

Exact cause, proven not inferred: `diff(live git diff HEAD, frozen patch)` differs **only** in the two `index` lines — live `77bb94b..ff5a38b` / `c85eaca..85a636b` (7 hex) vs patch `77bb94b6..ff5a38b8` / `c85eaca0..85a636ba` (8 hex). Everything else (all 103 lines) is identical. `sha256(frozen patch bytes + status + "\n")` = **`6850b32e…`** exactly, so the pin was minted from this patch's bytes over this status; the tree content is exact. The abbreviation length comes from `core.abbrev=auto`, which git scales with object count: this standalone repo has 3,349 packed objects (shallow baseline) → 7 hex; the environment that minted the pin had more objects → 8 hex. Non-persisted test `git -c core.abbrev=8 diff HEAD` is byte-identical to the patch and yields fingerprint **`6850b32e…`** = pin. **No config was persisted** (`core.abbrev` unset; local config = 4 default keys).

Consequence: as-is, `run-s5-setup-npm-ci.v101.sh` L223 would `die provenance-dirty-fingerprint 2` and `ctl-t0-only.v101.sh` L185 would refuse — for an abbreviation-length artefact, not a content difference. Options are the parent's, not taken here: (a) authorize `git config core.abbrev 8` in `worktrees/s5-r4` (repo-local, non-product, deterministic; verified above to reproduce the pin) and record it in the setup packet's provenance; (b) supply a fuller object store so auto-abbrev reaches 8 (not derivable locally); (c) have the setup-v2 builder pin a content-based fingerprint (e.g. `git diff --full-index HEAD`) — a runner change outside this slice. Nothing further was attempted (no archaeology).

## 3. File-only T0 / setup readiness — `logs/S4-file-existence.txt`

PRESENT: WT, `package.json`, `package-lock.json`, both patched test files, V101 setup runner and T0 control, `/usr/local/bin/{node,npm}` (paths only), platform `/home/user/node_modules` (210 entries incl. dotfiles; read-only inventory input for the ancestor gate), canonical lock file (exists, empty, from the granted S2 probe). Correctly ABSENT: `worktrees/s5-r4/node_modules` (setup gate: one install only), `node_modules/.bin/jest` (T0 needs it after setup), `dist`, `.git/hooks/pre-commit`, `/home/user/package.json` (setup refuses if present), `execution/s5-r4` (not created; setup-v2 builder owns).

Readiness statement: head, lock blob, status pin and tree content are exact and ready for the setup grant; the **dirty-fingerprint gate will fail until the parent resolves §2**. No runtime grant requested or implied.

## 4. Not done / not claimed

No `execution/s5-r4/**` paths; no config persisted; no worktree edit beyond the mechanical `git apply` of the frozen patch; no versions, census, install, network, hooks, tests, prisma, commit. Baseline and private evidence porcelain 0. Success here proves exact source bytes only.

## 5. Owned outputs

`worktrees/s5-r4/**`; `execution/e8d546f9/s5-source-restore/{REPORT.md, MANIFEST.sha256, logs/S1-S2, S3, S4}`. `MANIFEST.sha256` covers this directory except itself.
