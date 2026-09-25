# S8-F PG proof binding v1 (source-only; nothing here has been executed)

Drafted under grant S8F-COMP-1 phase 2 (parent mail 2026-09-25 11:06 PDT) from the committed S8-F head
e1ec2fecb71f315b6721d426ba0dacb84f304498 (parent 1c10e2a1, branch exec-dace/s8f, worktree daceddc8-s8f).
Derived by substitution from the accepted S8-C v4 binding (`../../s8c/binding/v4/`).

Files
- `s8f-pg-proof.sh` — the complete one-run orchestration (pins FILLED): canonical nonblocking `flock -n` on
  `execution/test-validation.lock` (fd 9, append-open, never deleted) taken before any state change and held until
  exit; once-only sentinel; head/tree/blob/fixture pins; head is exactly one commit on base 1c10e2a1 and the base..head
  delta is exactly the 17 S8-F commit paths; prisma tree identical to base; accepted S8-C / native-writer / shim /
  jest.rls blobs unchanged; hooked-commit check; isolated donor `node_modules` pins (S7-L-schema client 9042e713);
  PG17 / psql / node binary hashes; 172 tracked migrations; fresh lane preflight (lane dir absent, socket dir empty,
  port 55643 free, no postgres, every other lane under `clusters/*` and `proof-*/clusters/*` hashed and never started);
  init → start → committed `bash test/utils/g2-s8f-bootstrap.sh` (no subcommand) → identity (data_directory, 170006,
  cluster marker, DB marker, applied migrations == 172) → `jest --config jest.rls.config.js test/rls-g2-s8f.spec.ts
  --runInBand --ci` exactly once → bounded fast stop (data dir retained) → post (other lanes, worktree, generated
  client unchanged) → `RECEIPTS.sha256` + sentinel. Every stage `timeout -k 30 <bound>`-bounded; first nonzero stops;
  failure path attempts one bounded stop if this run started the postmaster. Outer: `timeout -k 30 3600`.
- `s8f-fixture.sh` — lock-free lane helper (`init|start|stop|status|destroy`), refuses standalone use unless
  `S8F_RUNNER_PID` is a live `s8f-pg-proof.sh`; fresh-init-only; marker-gated start/destroy; refuses data paths inside
  `pg17/dist` or under `/home/user/pg17`. Port 55643, superuser s8f_super, cluster_name s8f-disposable-pg17, lane
  `recovery-reset/proof-s8f-v1/clusters/s8-f`, socket `proof-s8f-v1/run/s8-f`.
- `PINS.txt`, `s8f-pg-proof.sh.unfilled`, `unfilled-to-filled.diff`, `tool-pins-reverify.txt`, `BINDING.sha256`.

Harness / spec notes required by the grant (details in `../../composition/COMMIT_READY.md`):
- NOT NULL no-default audit: every raw INSERT in `test/utils/g2-s8f-pg-harness.ts` and `test/rls-g2-s8f.spec.ts`
  supplies all NOT NULL no-default columns (incl. WorkoutPlan/WorkoutProgram `updated_at`); no change was needed.
- Counts: the spec asserts API page counts over intent-scoped rows after `resetData()` and a role-denial `count(*)`
  that accepts 0 or permission-denied; no absolute count over a seeded table is asserted. Baseline-safe.
- db-guard: `test/scout/g2-s8f-db-guard.spec.ts` pins markers/ports only and asserts no migration list; the bootstrap
  asserts applied == tracked; this runner pins tracked == applied == 172 (base-prefix history, S8-F adds none).

Not run. Not granted. Next: parent review of COMMIT_READY.md → separate single-run PG grant → this runner once.
