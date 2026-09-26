# S9-B rebuilt-files review A (T4)

Decision: GO for the six rebuilt files, subject to the separately authorized gate and real PostgreSQL run. This is a read-only static review; no typecheck, lint, Jest, PostgreSQL, formatting, or commit was run.

- All five recovered files match `gate/PINS.env` exactly: facts service `e2f40a79…58357`, facts spec `9dcfbd96…2014f3c`, DB guard `39ba033b…2ae9`, guard spec `a99cf9c9…e4fbf`, decision addendum `be591e97…aa6515`.
- `src/scout/reconciliation/reconciliation.module.ts:16-20` only provides and exports the facts service; no import into the customer path, controller, hook, or writer.
- `test/rls-g2-s9.spec.ts` has exactly ten ordinary `it()` tests, with no skipped/focused cases. It asserts real worker/Prisma/PostgreSQL facts, unknown/null and partial outcomes, drift, both tenant directions and foreign ownership, read-only query logs and before/after table digests, bounded pagination and replay uniqueness. The two tenant cases inspect coach-scoped results and unchanged other-tenant native rows; they do not assert that zero foreign native rows were fetched internally (indeed owner verification by native ID may read one before rejecting it). This does not defeat the specified tenant-output isolation, but avoid describing it as a literal SQL-level no-foreign-row-read proof.
- Harness/worker use `G2_S9_*`, `g2-s9-db.ts` guard, fresh worker process, `RepeatableRead` transaction and server isolation probe; bootstrap is executable 755, uses pinned markers, validates loopback/version/cluster before mutations, refuses unmarked existing database, and matches port 55645/ten-test binding. No embedded password was found.
- No definite blocking TypeScript/ESLint defect found by static comparison with S8-C siblings. Rebuilt TS/CJS are pre-format bytes; gate SHA values for the six rebuilt files need refresh after the authorized formatting step.

Blocking findings: none (A/B/C not applicable).
