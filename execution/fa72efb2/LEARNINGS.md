
## 2026-09-26 — linked worktree broke the parent clone's push URL (S11-D builder)
The S11-D builder created worktrees/fa72-s11d with `git worktree add` from repos/backend (not a standalone clone) and then set
`remote.origin.url no_push://…`, which rewrote the SHARED config of repos/backend and broke parent pushes. Repaired 18:4xZ:
extensions.worktreeConfig=true, fa72-s11d gets a worktree-scoped no_push url/pushurl, repos/backend origin restored. Rule for
grants: "standalone" means `git clone --no-hardlinks` (or clone from a local worktree), never `git worktree add` from repos/*.

## 2026-09-26 — S11-A2 proof v1: insert-only triggers invisible to no-DB gates
A harness reset that deletes S10-B tables directly passed every static gate and T4 review and failed on first live reset once rows
existed (row-level trigger; empty-table deletes pass). Reviewers of harness resets: check each DELETE target against migration
triggers (insert-only / no-truncate) and rely on parent cascades like the owning lane's harness.
