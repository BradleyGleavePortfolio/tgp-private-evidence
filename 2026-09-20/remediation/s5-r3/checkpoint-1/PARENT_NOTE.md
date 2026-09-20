# S5 R3 source checkpoint, not execution approval

Preserved 2026-09-20 23:00 UTC. Head `9f38ab033b08ae30ce2fc62d0150520239d6a5c8`, tree `49d2e03cbb60d81d010bfc524ae2e1a4cd1f425a`; author and committer Bradley Gleave with prescribed email, no trailers, worktree clean. Source bundle verifies with public backend main `c23b9d9f` as prerequisite.

This checkpoint preserves the builder's first submitted packet unchanged. New test assertions have not run against PostgreSQL; neither final validation nor independent R3 clearance is claimed.

Parent identified execution-runner defects before authorizing any install or database operation:

- `npm-ci.sh` names a different lock than the canonical `execution/test-validation.lock`.
- `run-proof.sh reset` issues DROP DATABASE without first proving the server is the intended disposable fixture.
- `stamp()` changes directories inside a pipeline subshell, so later relative test commands can run from the wrong directory.

The builder is correcting these in a successor packet with offline negative proof. Do not execute the archived runner as-is. Source remains useful; runner approval and final execution are separate.

The builder request's approximate 23:02 timestamp is ahead of the parent receipt at approximately 22:59 UTC. Treat exact log timestamps as observations, not that approximate prose timestamp.
