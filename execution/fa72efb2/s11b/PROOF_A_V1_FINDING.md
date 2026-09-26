# S11-B S11-lane real-PG proof (s11-lane-v1) — FAILED (preserved unchanged) — EXEC-FA72EFB2

Run: binding/s11-lane-v1/run, candidate 4d31616f on 7fdcbc04, LAUNCH 16:30:45Z, END rc=1 stage=jest-redrive 16:40:39Z,
teardown clean (postgres_procs=0, port free, datadir absent); lane logs archived to run/post-teardown (POST_TEARDOWN.sha256),
clusters/s11 removed. Stages: bootstrap OK; rls 6/6; journey 8/8; readiness 6/6; settle-redrive 7/8; guard not reached.
FAIL J13 (two replayed claims race on P1/P2): one worker got HTTP 500 `{"code":"P2010"}` (spec L353).
pg.log (post-teardown/pg.log L31-37): backend 29448, after its refused completion INSERT (P2002, the re-drive branch):
`ERROR: could not serialize access due to concurrent update` on the settle tail's
`SELECT … FROM "ScoutImport" … FOR NO KEY UPDATE` (lifecycle.service.ts lockRun, $queryRaw inside the REPEATABLE READ
settle transaction).

Root cause: `ScoutLifecycleService.isSerializationFailure` (lifecycle.service.ts L501-504, landed S9-C code) recognises only
Prisma P2034. A 40001 raised by a `$queryRaw` statement surfaces as P2010 ("raw query failed", meta.code 40001), so
`settleWithSnapshot` never retries it and the loser propagates a 500 instead of retrying, seeing the terminal and acking.
The documented S9-C contract (L476-487: "PostgreSQL raises a serialization failure … the whole transaction is then retried")
is therefore not met on the raw lock path. Review A's J13 reasoning ("P2034 → retry") assumed the documented contract.

Classification: B. CONCRETE HARM: a concurrent settle on one run (two replayed claims — now reachable via S11-B — or a
fence/cancel/revoke committing during a settle) returns 500 to a host instead of the retried, idempotent outcome; the run
state is not corrupted (the failed tx rolls back; the winner's terminal stands). EXACT DECISION BLOCKED: landing S11-B (#562).
MINIMUM CLOSURE: classify raw-query serialization/deadlock failures (P2010 with meta.code 40001/40P01) as retryable in
isSerializationFailure, unit-test it, new candidate + T4 delta review + new binding version + one new S11-lane run, then the
S10-B-lane run on the same candidate. These bytes are not rerun. EXECUTION UNLOCKED: S11-B landing.
Receipt note: same template order as PROOF_V1_FINDING (END line appended after RECEIPTS) — C.
