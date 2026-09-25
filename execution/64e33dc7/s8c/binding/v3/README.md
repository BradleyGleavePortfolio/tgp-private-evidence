# S8-C PG proof binding (source-only; nothing here has been executed)

Files
- `s8c-pg-proof.sh` — the complete one-run orchestration: canonical nonblocking `flock -n` on
  `execution/test-validation.lock` (fd 9, append-open, never deleted) taken before any state change and held until
  exit (through stop, post checks and receipt hashing); once-only sentinel; candidate pins (head, tree, six proof-file
  blobs, fixture sha) refused while unfilled; base ancestry + prisma tree identical to base; accepted S8-B / sidecar /
  contract / jest.rls blobs unchanged; hooked-commit check; isolated donor `node_modules` pins; PG17 / psql / node
  binary hashes; fresh lane preflight (lane dir absent, socket dir empty, port 55642 free, no postgres, other lanes
  under the runtime root hashed and never started); init → start → committed `g2-s8c-bootstrap.sh bootstrap` →
  identity (data_directory, 170006, cluster marker, DB marker, 171 migrations) → `jest --config jest.rls.config.js
  test/rls-g2-s8c.spec.ts --runInBand --ci` exactly once → bounded fast stop (data dir retained) → post (other lanes,
  worktree, generated client unchanged) → `RECEIPTS.sha256` + sentinel `RC= STAGE= END= HEAD= LOCK_INODE=`.
  Every stage is `timeout -k 30 <bound>`-bounded; first nonzero stops; failure path attempts one bounded stop if this
  run started the postmaster and records survivor pid / listener count. Outer: `timeout -k 30 3600`.
- `s8c-fixture.sh` — lock-free lane helper (`init|start|stop|status|destroy`), refuses standalone use unless
  `S8C_RUNNER_PID` is a live `s8c-pg-proof.sh`; fresh-init-only; marker-gated start/destroy; refuses data paths inside
  `pg17/dist` or under the historical `/home/user/pg17`.
- `PINS.txt` — all pins; nine head-derived values unfilled until the attested head exists.

Order (parent mails 2026-09-24 21:17 and 21:24 PDT): source gates → hooked commit → exact source/binding export →
**fill the nine pins from the committed head** (authorized preparation; sed; keep `s8c-pg-proof.sh.unfilled`; record
filled sha + unfilled→filled diff in `BINDING.sha256`; re-verify tool pins read-only) → two independent non-builder
attestations of final head + filled binding → separate parent-granted single real-PG proof → this runner once. No
initdb, server, bootstrap, migration or PG test before that grant.
