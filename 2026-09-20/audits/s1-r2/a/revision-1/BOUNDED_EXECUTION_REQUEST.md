# S1 R2 auditor A — bounded additional execution request

Requested of the parent; NOT executed by this auditor. No full-suite or second full replay requested.

## 1. Late-statement atomicity and same-session timeout reset

Reason: the archived harness blocks `DunningAttempt` inside the first substantive `DO` statement (harness lines 103–118). Earlier table updates are in that SAME statement, so their rollback does not distinguish per-statement atomicity from whole-file atomicity. Fresh-connection timeout reads at lines 118 and 139 cannot test session leakage.

Use only an isolated synthetic database recreated by the parent from the already-attributable fixture, under the parent-owned validation slot. Never use hosted or customer databases, and never run the candidate harness on an arbitrary URL.

Minimal experiment:

1. In the existing synthetic lock fixture, first establish the documented pre-S1 catalog state. Preserve/reuse the run-05 fixture and create a separate parent-owned disposable database if needed; do not share a mutating DB with another audit.
2. Keep one session open with `BEGIN; SELECT 1 FROM ONLY public.community_messages_2027_01 LIMIT 1; SELECT pg_sleep(12); ROLLBACK;`.
3. Run the exact candidate through the real Prisma migrate-deploy path in the other session, with an outer 20-second limit. Capture the lock error at the partition-protection stage, after the 14-table DO completed, rather than at DunningAttempt.
4. After failure, assert all 14 server-only tables remain in pre-state, helper definitions/ACLs remain pre-state, and the failed history row is present. Then use the documented failed-attempt resolve/deploy recovery and run verify.sql.
5. In ONE psql connection, run the exact forward file under `--single-transaction`, followed by `SHOW lock_timeout; SHOW statement_timeout;` in that same connection. Assert reset values against the fixture's defaults. Repeat for down if desired; reapply protection before retaining the fixture.

Do not infer success from absence of errors alone. Bind logs to full head `90a6647513f3566393764eee87237d9b5b1f150b`, server/Prisma version and actual connection role flags.

If this request cannot be scheduled, the report remains complete with a bounded evidence gap; do not wait for the other current R2 auditor.

## 2. Harness guard negative tests after remediation

No database needed: intercept `psql` with a command-recording stub and verify that non-loopback URLs, wrong port, non-disposable database names, URI/query overrides, and SQL metacharacters in the database argument are rejected BEFORE any database command. Parent must not execute the unsafe current script with real production-like credentials. Require an explicit disposable-cluster confirmation and exact synthetic role/version preflight before its destructive path.
