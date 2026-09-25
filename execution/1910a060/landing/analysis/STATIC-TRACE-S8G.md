# Static trace: land-s8g-1910.sh (sha256 4992e3bdf64cea5b4b82bff640503725a5b3bf425ea9cb86e7b657f0b850fe92)

The trace ran at 2026-09-25 22:46Z against a scratch clone, `/tmp/s8g-trace-*/w`.

**Setup.** I sourced the script's own constants and helpers, which are everything above `MODE=`. Only two paths were overridden: `W` became the scratch clone and `LANDING` became the scratch landing directory. I then ran every compose step in order using the script's own commands.

**What was not executed:**
- **Lock:** not taken.
- **Runtime:** node_modules were not copied and lefthook was not installed.
- **Jest:** the must-run suites were not run.
- **Push and PR:** nothing was pushed and no PR was created.

**Commit.** The scratch clone has no hooks, so the commit step was simulated there with `git commit -F <script message>`. That simulated commit object, `663ce133`, exists only in /tmp. It is not a product commit and it is not M3.

The trace artifacts are in `analysis/s8g-static-trace/`: `run.log`, `merge.log`, `commit-message.txt`, `pr-body.md` and the name-status exports.

## Compose (the order the script uses)
| Step | Result |
|---|---|
| `remote_state M2` | integration/importer = 9497ca52 and main = 1c10e2a1. There are 18 land refs. |
| Land refs | `land/s8-g-accepted` and `land/s8-g` are both absent. |
| `git init -b land1910/s8g`, then fetch origin | The tip is 9497ca52 with tree 737c34a3. |
| `fetch_cand $W` | Four checks pass: bundle sha `3013bae3…`, receipt sha `6beeee55…`, `bundle verify` (prerequisite M is present in W via M2's history), and the fetch to `refs/heads/cand-accepted`. The candidate matches on head, tree and parent, the raw-diff sha is `d904d40c`, there are 14 paths, and 14/14 blobs equal the gate receipt. |
| `check_commit_hygiene MB H` | ok, 1 commit. |
| Fresh hooks, checkout of the tip, schema and lockfile pins | All ok. S8-G touches no pinned files. |
| Donor checks | Donor HEAD e1ec2fec. The donor-vs-tip diff over prisma, package.json and package-lock.json was computed **in W**, where object e1ec2fec is present (CORRECTION-S9A-1 lesson). It is empty. The donor also equals the candidate on those inputs. |
| Reference hooks | Both hooks are present under `1910a060-s8f/.git/hooks`. |
| Prettier prefix manifest | ok, 56 entries. |
| Tracked files before the merge | clean |
| `merge --no-ff --no-commit refs/heads/cand-accepted` | rc 0, `MERGE_HEAD` = 820ce85b, no unmerged paths. |
| `write-tree` | 60214a64, equal to PRED_TREE. |
| Staged set | `diff --cached --raw M2` == `diff --raw M 820ce85b` (the 14 paths, including 2 `M `). This replaces the S9-A path-list check. |
| Contract blob | 8ebf936a |
| Worktree vs index | equal |
| The 11 suites | All present. |
| Untracked check (CORRECTION-S9A-2) | Status counts are `12 A` and `2 M`, with 0 `??` entries, so UNTRACKED_NONE. A check that treated any status line as untracked would have misfired here, as it did in S9A-2. |
| Commit message | Not banned. The subject is "Merge S8-G run orchestration (820ce85b) into integration/importer". |
| Post-commit checks (scratch) | Parents = (M2, 820ce85b), the committed tree equals PRED_TREE, HYGIENE ok with 2 commits over M2..HEAD, and the tree is clean. |
| Bundle export `M2..refs/heads/land1910/s8g` | Verifies okay. Its prerequisites are M2 and M; both are present on the remote tip. |
| Name-status | 14 lines vs the tip and 4 lines vs S8-G (the S9-A adds). |
| Receipt and state | The variables all resolve. No `BLOB_*` or `S9A_*` names remain, and `M3` is used consistently. |

## Stage and ff (static; nothing was pushed)
- **Stage pre-checks:** the state `MERGE` sha is read back, and the branch and tree in W match the state. PR body: all names are S8-G, no banned tokens.
- **Stage refs:** `push_land_ref` writes only `land/s8-g-accepted = 820ce85b` and `land/s8-g = M3`. It uses ordinary pushes, absent-or-equal.
- **Acceptance records:** tested `check_acceptance` on scratch records. A record naming 820ce85b + ACCEPTED passes, and a record naming M3 + ACCEPTED passes. A record containing NO-GO is refused with rc 75.
- **ff ordering:** `ff` needs `ACCEPT_RECORD` naming 820ce85b and `LAND_RECORD` naming M3. It then checks `remote_state M2` and `land/s8-g == M3`, observes PR CI once, and only then runs `ff_push` (tip == M2, ancestry, ordinary push, `ls-remote` verify).
- **Forbidden operations:** there is no `--force`, `--no-verify`, `--amend`, `+` refspec, delete or main refspec. The only match for these is the comment on line 16.
- **Syntax:** `bash -n` is ok, and a grep found no leftover `s9a` / `S9A_` / `be88909f` / `BLOB_` / `PRE_FF` / `land/s8-f` identifiers.

## Defects found
None in the derived script. The two lessons from the earlier corrections are carried over:
1. **CORRECTION-S9A-1:** the donor inputs are compared inside W.
2. **CORRECTION-S9A-2:** the leftover check looks for untracked `??` entries only.

The S8-G staged set includes `M ` entries, and the trace confirmed that they do not trigger the untracked check.
