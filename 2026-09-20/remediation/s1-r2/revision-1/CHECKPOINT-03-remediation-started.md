# S1 checkpoint 03 — remediation started (17:28 UTC)

Frozen R1 head 620b47fc preserved (tag `s1-db-R1`, bundle `bundles/s1-database-R1-620b47f.bundle`); the R1-time untracked harness is preserved verbatim at `held-620b47fc/s1-rls-close-public-exposure.sh.r1-untracked` with its first run `held-620b47fc/proof-run-01.log` (37 pass / 13 fail — failures were harness bugs, a verify.sql array-literal bug and missing fixtures; also surfaced that `prisma migrate resolve --rolled-back` after a reversal prints "marked as rolled back" when an earlier failed row exists, i.e. no-op success rather than P3012).

Both R1 reports read. Working set (uncommitted, worktree `execute/20260920-s1-database`):
- `rollback.sql` → `down.sql` (A-01/B-02), refs updated; `RESET lock_timeout/statement_timeout` at end of both (A-03); "proven by spec.ts" replaced by the real harness path landing in the same head (A-02/B-01); transactionality reworded as observed behaviour (B-04); protect_partition checks namespace + pg_inherits parentage (A-07/B-05); verify.sql array bug fixed and allowed-path assertions added (service_role privileges, partitions attached) (B-06); recovery guidance: resolve --rolled-back is NOT a recovery for out-of-band reversal — re-apply with `psql --single-transaction` and verify (S5/A-05).
- Harness `test/db/s1-rls-close-public-exposure.sh`: separate DB for lock/failed-deploy history, exact SQLSTATE parsing, real fixtures, populated-data, partition, reversibility-gate parity (pg_dump -s --no-owner --no-privileges forward→down→forward) and clean-history P3012 invariant.
- Runtime packet rev 2 already rewritten to the single validated Node/Prisma probe (A-04/B-03).

Running now: proof run 02 under test-validation.lock (`proof-run-02.log`). Next: fix any harness defects, commit with G05 identity, bundle (base c23b9d9f only), disposition report + publication manifest incl. PG17 infra recreation.
