# S9-0 commit record (docs-only; not pushed)

Status: **COMMITTED** locally. The landing agent pushes, opens the PR and fast-forwards it.

## Commit

| Field          | Value                                                                                  |
| -------------- | -------------------------------------------------------------------------------------- |
| head           | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`                                             |
| tree           | `82b56ad373c9cb4888b7c9b79544fbbb6f55c0d6`                                             |
| parent         | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` (landed `integration/importer`, S8-C)       |
| branch         | `exec-dace/s9-0b` (`exec-dace/s9-0` already existed locally from the s7l worktree)     |
| worktree       | `/home/user/workspace/worktrees/daceddc8-land-s8-c`                                    |
| file           | `docs/decisions/2026-09-25-s9-reconciliation.md` (100644, 533 lines, the only change)  |
| git blob       | `c3423725ed51b68967074a97a0975a7245543c22`                                             |
| sha256         | `cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1` (re-review GO bytes) |
| author         | Bradley Gleave <bradley@bradleytgpcoaching.com> 2026-09-25T18:22:37Z                  |
| committer      | Bradley Gleave <bradley@bradleytgpcoaching.com> 2026-09-25T18:22:37Z                  |
| identity from  | repo-local `growth-project-backend/.git/config` (no `GIT_*` env overrides)             |
| trailers       | none                                                                                   |
| `--no-verify`  | not used                                                                               |
| pushed         | no                                                                                     |

Message:

```
docs(scout): S9-0 reconciliation decision (verdict predicate, report v1, reason codes)

Records the S9 native reconciliation contract: the family-complete verdict
predicate with required families and a recorded completeness basis, report
and coverage manifest v1 recomputed on read with no table, the verified
union only for native counts, the ceiling case as partial with blocked
reserved for revoked, additive low-cardinality reason codes, the S9-A/B/C
seam and paths, and acceptance cases R01-R19.
```

## Byte checks (all equal to the GO sha256)

- pre-stage worktree: `cda68d82…7bab1`
- staged (`git show :<path>`): `cda68d82…7bab1`
- post-commit worktree: `cda68d82…7bab1`
- committed blob (`git show HEAD:<path>`): `cda68d82…7bab1`
- The source copy in `worktrees/64e33dc7-s7l` compares byte-identical (`cmp`). It is left untracked there.

The prettier hook ran as `--check`, passed and did not reformat. `git status` after the commit is
clean, and `git diff --name-only 1c10e2a1 HEAD` lists only the doc.

## Slot

- Canonical lock `/home/user/workspace/execution/test-validation.lock`, inode 674373, taken with
  `flock -n`. The script polled every 60 s and never took the lock from a holder.
- **Attempt 1.** The S8-F gate (`s8f-gate.sh`, pid 27728) held the lock, so the script waited
  through 5 busy polls. It acquired the lock at 18:20:58Z and released it at 18:21:58Z.
- **Attempt 2.** Acquired at 18:22:37Z with 0 busy polls, released at 18:23:25Z. No holders remain.

## Hook log

**Attempt 1 failed with no commit.** Prettier, R75 and prod-readiness-quick passed, but `tsc`
aborted when Node ran out of heap at the default ~2 GB (exit 134). This was not a type error. The
doc bytes were unchanged (sha256 re-checked after the failure).

- Log: `s9/s9_0_commit/hook.log`
- Script: `s9/s9_0_commit.sh`

**Attempt 2 passed.** It set `NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true`,
the same heap convention as `landing/PLAN.md` L142/L183 and the CI build-and-test job. The hooks
still ran in full. Results:

- pre-commit:
  - eslint skipped (no files for inspection);
  - prod-readiness-quick passed;
  - banned-cast-tokens (R75 `--cached`: "no positive token change") passed;
  - prettier passed ("All matched files use Prettier code style!");
  - tsc passed (47.45 s).
- commit-msg: no-ai-tokens passed.

- Logs: `s9/s9_0_commit_attempt2/{hook.log,poll.log,shas.txt,commit.txt,message.txt,status_after.txt}`
- Script: `s9/s9_0_commit_attempt2.sh`
