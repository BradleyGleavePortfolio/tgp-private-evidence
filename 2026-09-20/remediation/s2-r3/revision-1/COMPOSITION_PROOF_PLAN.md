# S1+S2 synthetic composition proof — bounded plan (NOT executed; no branch changes)

Purpose: prove, with the **real Prisma CLI** against an **S1-owned disposable PostgreSQL**, that the S2 runner
(`scripts/release.sh`) composed with the S1 migration behaves as claimed end-to-end — step 0 finds the required
verifier, step 2 really applies the migration, step 4 really runs `verify.sql` and a real non-zero from
`prisma db execute` propagates to release_command exit 1. Nothing hosted, no customer DB, no historical
migrations against anything but the disposable target S1 provides.

## What is already covered (do not duplicate)
| Claim | Covered by | Evidence |
|---|---|---|
| Real `prisma migrate deploy` applies the S1 migration; `prisma db execute --file verify.sql` exits 1 on pre-state / allowed-path drift, 0 on protected state | S1 harness `test/db/s1-rls-close-public-exposure.sh` (`prisma_verify_rc`, checks DB2) | `execution/s1-r3/REPORT.md` S1-R2B-04 (unrun, S1's slot) |
| release.sh step 0 contract validation, discovery fail-closed, step 4 loop/accounting, exit paths | S2 offline probe p03 (fake `npx`) 16/16 at `1c6db2b6` | `execution/s2-r3/logs/FINAL-proof-at-1c6db2b6.log` |
| Heads compose without conflict; manifests identical | `git merge-tree` → `cadade60`; blob compare | `COMPOSITION_NOTE.md` |

## The uncovered gap (this plan)
Neither lane has run **`scripts/release.sh` itself** with the **real** Prisma CLI on the **integrated tree**. Specifically:
1. step 0 at the integrated tree reports `verifiers_required = 1 (all present)` (not the S2-alone refusal);
2. step 2's real `migrate deploy` and step 4's real `db execute` execute (not stubs), and the success line reads
   `verifiers_passed=1 verifiers_required=1`;
3. a **real** `RAISE` from `verify.sql` propagates through `release.sh` step 4 to exit 1 with the
   `catalog verifier FAILED` banner and the Prisma error text in the tail;
4. negative control: the S2-alone tree (`1c6db2b6`, no S1 migration) refuses at step 0 **without opening a DB
   connection** (DIRECT_URL pointing at a closed port; no P1001 in output).

## Preconditions (all from S1 / parent; S2 requests, never provisions)
- Shared locked `node_modules` (S1-owned `npm ci`; manifests byte-identical to S2 — verified). `npx prisma` in
  release.sh must resolve to it: run with `PATH=<shared>/node_modules/.bin:$PATH` and record `command -v prisma`,
  `prisma --version`.
- A **disposable** Postgres target from S1 **only after S1's own proof is done**, passed as one URL
  `S1S2_PG_URL` (superuser or migration-capable role S1 chooses), plus S1's confirmation string mechanism
  (`S1_PG_DISPOSABLE_CONFIRM` semantics from `test/db/_support/s1-target-guard.sh`) so the runner refuses any
  non-127.0.0.1 / non-confirmed target. S1 also supplies (a) the pre-state bootstrap it uses
  (`test/db/_support/supabase-like-bootstrap.sql`) and (b) one out-of-band drift statement that its own harness
  already shows makes `verify.sql` RAISE (fixture content is S1's; S2 does not author SQL).
- Slot grant for ≈5 serial process invocations (each seconds; total < 3 min), under non-blocking flock.

## Baseline labelling and truthfulness (parent 23:09Z)
- The disposable target is prepared by **S1's fixture exactly as S1's own harness does**: fresh DB → `supabase-like-bootstrap.sql`
  (roles/auth shim, non-superuser `postgres`) → real `prisma migrate deploy` of the **full parent chain** (S1 ADDENDUM_02: **164** parent
  migration directories observed replayed in S1 run 4; 165 timestamped directories with the candidate; S1 harness lines 93–98 is the proof) →
  out-of-band `prisma/migrations/rls_fitness_backend.sql` (production pre-state twin). Then `release.sh` (C1) has exactly one
  pending migration, mirroring production's `pending_before=1`.
- Label everywhere: **"synthetic composition proof on an S1 production-pre-state twin"**. It is NOT a full release proof:
  no Fly release machine, no hosted secrets/env, no `fly.toml` `release_command` invocation, no customer data, no
  production `_prisma_migrations` history. If the fixture cannot legitimately replay the whole parent chain, the run is
  labelled **"pinned release.sh + contract + S1 verifier on a synthetic baseline"** and claims only the C0/C3 exit-code
  propagation and step-0 acceptance — never migration-graph correctness.
- Bytes are never modified: `scripts/release.sh`, `scripts/release-required-verifiers.txt`, `migration.sql`, `verify.sql`
  are used exactly as extracted from `cadade60` (hash-object equality to `1c6db2b6` / `7cbbb039` recorded before and
  after the run). The RAISE in C3 must be Prisma's real exit code (`prisma db execute` → non-zero), not an injected stub.
- `release.sh` hardcodes `/tmp/prisma_migrate.log`, `/tmp/prisma_status.log`, `/tmp/prisma_verify.log`,
  `/tmp/prisma_verifier.log`, `/tmp/release_verifiers_discovered.txt` and does **not** honour `TMPDIR` (6 literal `/tmp/`
  paths, 0 `TMPDIR` references at `cadade60`). The runner therefore: (a) takes the flock **before** touching `/tmp`;
  (b) snapshots any existing `/tmp/prisma_*` and `/tmp/release_verifiers_*` (copy + sha256) into the composition
  output dir; (c) after each C-step copies the fresh logs into `C*/` and restores the snapshot bytes so S1's proof
  artifacts are byte-identical afterwards (verified by sha256); (d) never runs two real-Prisma processes concurrently
  (S1 and S2 real-Prisma work strictly serialized by the same lock). Making release.sh honour `TMPDIR` is a candidate
  follow-up for a later S2 head, not a change to `1c6db2b6`.

## Composition heads (SLOT D update)
S2 head is now `e15e25c28824b43558f7c231eec26a5ac64bafa9` (supersedes `1c6db2b6`); S1 head is `b7d7fe5`. The integrated tree
must be recomputed as `git merge-tree --write-tree b7d7fe5 e15e25c2` (the earlier `cadade60` was 7cbbb039+1c6db2b6 and is stale).
Preparation follows S1 ADDENDUM_02 exactly: dedicated DB `s1_rls_s2comp` (inside the guard's `^s1_rls_` namespace; `s1_rls_proof`
untouched), bootstrap, temporary prisma copy minus only the candidate, real `migrate deploy` as `postgres` (expect 164, record
actual), `rls_fitness_backend.sql`, then the unmodified integrated `scripts/release.sh`.

## Integrated tree without branch changes
```
git -C repos/backend archive 3d494b74b1e2894060540a6944c3c9462ae253c8   # merge-tree b7d7fe5+e15e25c2, exit 0, computed 23:31Z | tar -x -C "$TMP/s1s2"   # tree only, no ref/commit created
git -C repos/backend archive e15e25c28824b43558f7c231eec26a5ac64bafa9 | tar -x -C "$TMP/s2only"
```
Record: `git rev-parse cadade60^{tree}` (tree id), `sha256sum` of `scripts/release.sh`, `scripts/release-required-verifiers.txt`,
`prisma/migrations/20261224000000_rls_close_public_exposure/{migration,verify}.sql` in `$TMP/s1s2` and confirm they equal
the blobs at `1c6db2b6` / `7cbbb039` respectively (`git rev-parse <sha>:<path>` vs `git hash-object`).

## Steps (serial, each stamped: start/end, PATH, prisma version, exit code, `_prisma_migrations` snapshot)
| # | Tree | Target state | Command | Expected | What it distinguishes |
|---|---|---|---|---|---|
| C0 | s2only | any (DIRECT_URL=`postgresql://x:x@127.0.0.1:1/x`, closed port) | `bash scripts/release.sh` | exit 1; output contains `REQUIRED catalog verifier missing`; **no** `step 1:` line, **no** `P1001`/connect error | step 0 refuses before contact (real prisma present but never invoked — assert `/tmp/prisma_migrate.log` absent) |
| C1 | s1s2 | S1 pre-state twin (bootstrap + full parent chain via real `migrate deploy` + legacy RLS file); candidate NOT applied | `bash scripts/release.sh` | exit 0; `verifiers_required = 1 (all present)`, `pending_before=1`, `step 2:` present, `verifiers_passed = 1 (discovered=1, required=1)`, `ALL_APPLIED=165` (164 parent + candidate per S1 ADDENDUM_02; exact count recorded from output, not assumed) | real deploy of the candidate + real verifier pass through the S2 runner on the full graph |
| C1v | — | after C1 | `psql "$S1S2_PG_URL" -c "select migration_name, finished_at is not null from _prisma_migrations"` (read-only) | row for `20261224000000_rls_close_public_exposure`, finished | deploy was real, not a stub |
| C2 | s1s2 | after C1 | `bash scripts/release.sh` again | exit 0; `pending_before=0`; verifier still runs (`verifier: prisma/migrations/…/verify.sql`), `verifiers_passed = 1` | idempotent re-release; verifier runs even with nothing pending |
| C3 | s1s2 | apply S1's drift statement via `psql` (out-of-band) | `bash scripts/release.sh` | **exit 1**; `catalog verifier FAILED: prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql`; tail shows Prisma's error text (S1's RAISE message); `migrate status` said up to date before it | real RAISE → real `db execute` non-zero → release_command exit 1 (the S2-R2-A-03 / S1-R2B-04 composition claim) |
| C4 | s1s2 | after C3 | S1's documented forward re-apply, then `bash scripts/release.sh` | exit 0 again | recovery path documented in runbook §11.4.6 actually restores green |

Discriminators recorded per step: `command -v prisma` path (must be under the shared tree), `prisma --version`,
`PATH` (must contain no `execution/s2-r3` probe fake-bin dirs), presence/absence of `/tmp/prisma_migrate.log`
and `/tmp/prisma_verifier.log` contents, `_prisma_migrations` snapshot before/after.

## Exit criteria
All of C0–C4 match "Expected" on the recorded tree id; any mismatch is reported as-is (no retry loop). Output:
`execution/s2-r3/composition/<stamp>/{REPORT.md, C*.log, tree-ids.txt, psql-snapshots.txt}` + checksum addendum.
Still **not** claimed afterwards: hosted behaviour, Fly release_command environment parity, production state.

## Ownership / escalation
- S1: fixture SQL, drift statement, disposable target and its guard; verifier content.
- S2: `release.sh`, contract file, this runner; any release.sh defect found → S2 fix on a new head (never amend `1c6db2b6`).
- Parent: slot, sequencing after S1's own proof, whether C0–C4 are enough before the R3 audit pair.

Runner: not written yet — the S1 `run-proof.rev2.sh` wrapper pattern (flock, stamps, target guard) should be reused
with S2's rev-2 wrapper conventions (unique attempt logs, fail-closed cmp of manifests, outer timeout, exit 124
preserved). Writing it before the S1 target/guard interface is fixed would duplicate S1's guard logic; S2 will
write it as `run-composition-when-granted.sh` once S1 confirms the target-handoff variables.
