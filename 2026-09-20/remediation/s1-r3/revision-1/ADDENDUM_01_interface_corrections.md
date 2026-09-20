# ADDENDUM 01 — factual corrections to `S2_COMPOSITION_INTERFACE.md` (original preserved unchanged)

Written 2026-09-20 ~23:30 UTC after the parent's receipt of run 4 (89/0 at `b7d7fe5`). Product source and all prior evidence files are frozen; this file only corrects interface facts for S2. Verified by reading `test/db/_support/s1-target-guard.sh` and `test/db/s1-rls-close-public-exposure.sh` at `b7d7fe5964680050ab441c195055ea946282a9c3` and `proof-run-04-head-b7d7fe5*.log`.

## A. Guard FOREIGN_DB rule — namespace, not per-database
Guard line 130–131 / 169: `foreign = datname not in (postgres,template0,template1) and datname !~ '^s1_rls_'` → **every** database matching `^s1_rls_` is admitted; only databases *outside* that prefix cause `FOREIGN_DB`. The `<db>` argument itself must match `^s1_rls_[a-z0-9_]{1,40}$` (offline layer), and the harness destroys only `<db>` and `<db>_lock`.

Consequences for S2:
- The existing `s1_rls_proof` / `s1_rls_proof_lock` on the fixture would **not** make an S2 run named `s1_rls_s2comp` refuse; the two names coexist under the guard as written. My original §1 suggestion was therefore admissible but unnecessary.
- Per the parent's preference, S2 should **reuse the exact existing proof database name `s1_rls_proof`** (confirmation `DESTROY-127.0.0.1:54321/s1_rls_proof,s1_rls_proof_lock`) after an explicit parent slot. Its DROP/CREATE of that database destroys run-4's *database state*, which is fine: S1's evidence is the logs, schema dumps and hashes in the packet, not the live database. No guard change, no widening, no bypass.
- Anything S2 wants to create must still be inside `s1_rls_*`; a differently named database anywhere on the cluster will make **every** later guard preflight refuse (for S1 too).

## B. §4 reversal sequence — corrected to what run 4 actually proved
My §4 said "Reversal: `down.sql` then `migrate resolve --rolled-back`". That is **wrong** for a clean applied history. Run 4 proves three distinct facts:

1. **Recovery from a REAL failed deploy** (failed `_prisma_migrations` row present, log line 60): `migrate resolve --rolled-back 20261224000000_rls_close_public_exposure` succeeds, then `migrate deploy` re-applies, then `verify.sql` exit 0. `resolve --rolled-back` is only for a migration in the **failed** state.
2. **Clean applied history INVARIANT** (log line 116, detail 1419–1421): after an out-of-band `down.sql`, `migrate resolve --rolled-back` **refuses with P3012** ("cannot be rolled back because it is not in a failed state"). The ledger stays "applied". The proven forward path is a **direct re-apply** — `psql --single-transaction -v ON_ERROR_STOP=1 -f migration.sql` — after which `migrate status` reports up to date (log line 324: "history untouched") and the forward-2 schema dump equals forward-1 (`eb10563c…` both).
3. **Mixed history** (an earlier failed row *and* an applied row, log lines 72–73): `resolve --rolled-back` exits 0 but touches only the failed row; the applied row remains applied ("Prisma state unchanged by reversal"). Do not read that exit 0 as a reversal of the applied migration.

Corrected guidance for S2's C1–C4:
- Induced failure → `resolve --rolled-back` → `deploy` → `verify` (fact 1).
- Out-of-band reversal test → `down.sql` → **direct** `migration.sql` re-apply → `verify`; do **not** call `resolve --rolled-back` (fact 2), and if S2 does, expect P3012 as the correct outcome.
- Never treat a `resolve --rolled-back` exit 0 as evidence of ledger reversal without reading the applied row (fact 3).

## C. Manifest note
`SHA256SUMS` in the packet does not list `infra/logs/*` (setup 10/20/30 logs) although `REPORT.md` references them. The parent archives the originals with its own checksums; for convenience their hashes are in `SHA256SUMS.addendum` alongside this file. `SHA256SUMS` itself is left as archived.
