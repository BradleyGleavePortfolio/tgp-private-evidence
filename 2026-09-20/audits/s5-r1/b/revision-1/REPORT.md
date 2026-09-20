# S5 independent audit B — round 1 (T4R1)

Auditor: S5 independent auditor B (Claude Fable 5, High requested; actual reasoning setting not exposed, not claimed). Independent of the builder and of peer auditor A; peer report not read; no expected verdict received. Private output; parent is publisher.

## 1. Identity of the audited snapshot

| Item | Value |
|---|---|
| Snapshot worktree | `worktrees/audit-s5-r1` (detached) |
| Head | `785d902286b5bfd15eac71c544f4837fb81ba0c0` |
| Tree | `9bbc0223e809e8e9b10b541bbde98b11903be362` |
| Parent | `d7404cd49578647cf72bb633819d8e86ffc3da3a` (G2 docs commit, #529) |
| Scoped base | `925780e0a1906593e5383c618311b6b17364b8dc` (#525 backend candidate head; not in `main` c23b9d9f) |
| Author/committer | Bradley Gleave (verified on the commit object; no co-author trailer) |
| Builder worktree | `worktrees/s5-g2`, HEAD `65b1da27…` — same tree `9bbc0223…` as the snapshot (verified) |
| Nature | Parent-captured temporary-index, audit-only commit of 5 new S5 proof/harness files (+1125 lines, no deletions): `test/rls-g2-pg17-etq0.spec.ts` (718), `test/utils/g2-pg17-harness.ts` (188), `test/utils/g2-pg17-bootstrap.sh` (101), `test/utils/g2-pg17-db.ts` (62), `test/scout/g2-pg17-db-guard.spec.ts` (56). Builder branch untouched. Not asserted complete or release-candidate. |

Cumulative G2 scope reviewed (`925780e0..d7404cd4`): E = `8644715c` (schema `ScoutReconstructionLedger.source_platform String?` + migration `20270118000000_scout_ledger_platform_expand` up/down), T/Q0 = `fdbbaefb` (new `src/scout/scout-cursor.ts`, `scout-platform.ts`, reworked `scout-reconstruct.service.ts`, cursor-decoding changes in roster/entities services, DTO/OpenAPI cursor limit 512→8192, contract 1.4.0→1.4.1), docs = `d7404cd4`.

## 2. Actions actually taken (all read-only; no install, commit, push, generate, deploy, hosted or customer access)

- `git` inspection of the snapshot worktree (log, diff-stat, `git show` of base-revision files, E→T→docs diffs).
- Source read of the 5 S5 files, the E migration up/down SQL, both G2 design docs, `scout-cursor.ts`, `scout-platform.ts`, `scout-reconstruct.service.ts` (old and new), `scout-roster.service.ts`, `scout-entities.service.ts`, mappers/registry, Person/ledger/staging models and their RLS migrations, `jest.config.js`, `jest.rls.config.js`, CI workflow DB versions, existing E/T specs (`test/rls-g2-ledger-expand.spec.ts`, `test/rls-g2-tq0.spec.ts`), `execution/s5-g2/*` (checkpoint, runners, logs), `execution/s1-database/PG17_INFRA.md`, S1 replay log, S1 runtime-role packet, S1 `supabase-like-bootstrap.sql`, brief acceptance row (line 61).
- Two read-only catalog queries against the local synthetic S5 PG 17.6 cluster (`127.0.0.1:54325` / unix socket) as the lane superuser: `pg_roles`, `pg_database`, `server_version`, and table/migration-history counts in `g2_s5_etq0_disposable`. No writes.
- No test execution by this auditor. The builder's own proof run (17:11–17:13Z, `execution/s5-g2/logs/`) appeared during the audit and is treated as evidence (section 5).

## 3. Reviewed vs. unreviewed scope

Reviewed: harness design and target guard; bootstrap script; spec logic for all five stages (representative old→new evolution, E up under load, contract limits/collisions, cursors & provenance, recovery/down); cumulative E migration SQL; T writer claim/precedence/retry semantics; Q0 cursor decode/encode and reader materialisation; RLS policy set for `Person`, `ScoutIngestEntity`, `ScoutReconstructionLedger`, `ScoutReconstructedEntity`; S1 PG17 infra claims; builder logs.

Not reviewed / out of scope: the ~10 importer/observability commits between `main` and `925780e0` (pre-existing #525 scope); runtime behaviour of any spec (none executed by me); the non-scout parts of the 164 base migrations; Prisma 6.19.3 query-engine internals (see S5-B-06); production Supabase role/version truth beyond what the operational takeover deliverable records (PG 17.6).

## 4. Findings (stable IDs S5-B-NN)

### S5-B-01 — MATERIAL (harness defect): bootstrap cannot complete on the S5 cluster; no live proof has run
Evidence: `test/utils/g2-pg17-bootstrap.sh` step 3 applies `scripts/ci/supabase-shim.sql`, whose line 37 is `GRANT anon, authenticated, service_role TO postgres;`. The S5 cluster was initialised with superuser `s5_super` only (`PG17_INFRA.md`; confirmed by `pg_roles`: `s5_super`, and after the builder's run also `anon`, `authenticated`, `service_role`; **no `postgres`**). Builder log `execution/s5-g2/logs/bootstrap.log`: `psql:…/supabase-shim.sql:37: ERROR: role "postgres" does not exist`. With `ON_ERROR_STOP=1` + `set -e` the bootstrap aborts before step 4/5; `g2_s5_etq0_disposable` exists but contains 0 public tables and no `_prisma_migrations` (verified).
Even if step 3 is patched, step 5 `prisma migrate deploy` will fail at `prisma/migrations/20260613000000_message_rls_split_update/migration.sql:120` (`ALTER FUNCTION app.mark_message_read(text) OWNER TO postgres;`).
Consequence: none of the E/T/Q0 live assertions has ever executed; every acceptance claim depending on them is unproven.
Smallest remediation (S5-owned; lanes may create roles inside their own cluster per PG17_INFRA): before the shim, create a Supabase-like `postgres` role (LOGIN, NOSUPERUSER, CREATEDB, CREATEROLE, BYPASSRLS, synthetic password from env) — S1's `test/db/_support/supabase-like-bootstrap.sql` already does exactly this and can be reused verbatim — then re-run `bash execution/s5-g2/run-proof.sh bootstrap`.

### S5-B-02 — MATERIAL (runner defect): `run-proof.sh all` does not fail closed after bootstrap failure; live spec then crashed
Evidence: `execution/s5-g2/run-proof.sh` runs guard → bootstrap → live unconditionally, summing return codes. `run-proof-all.out`/`exit-all.log`: guard PASS (26/26), bootstrap ERROR, live spec `FATAL ERROR: Reached heap limit … JavaScript heap out of memory` at ~2.04 GB after ~42 s, `Aborted (core dumped)`, `PROOF_EXIT=137`. The runner was modified at 17:13Z (after the 17:12Z crash) to add `NODE_OPTIONS=--max-old-space-size=4096`; whether that fixes the OOM is unverified. Root cause of the OOM (ts-jest compile vs. spec behaviour against an empty database) is undetermined.
Consequence: a green-looking "all" run could mask a failed bootstrap; the live result on record is a crash, not a test outcome.
Smallest remediation: `|| exit` after each stage (or `set -e` around the stage chain); re-run `guard`, `bootstrap`, `live` separately and keep separate logs; record the actual heap setting in `env.log`.

### S5-B-03 — NONMATERIAL now / MATERIAL for the "representative release mechanism" claim: all DDL runs as a cluster superuser
Evidence: bootstrap and spec connect as `s5_super` (superuser, BYPASSRLS); spec `beforeAll` asserts `super: true`; E up/down, catalog checks and the `SET LOCAL row_security = off` path in `down.sql` all execute as superuser. Production Supabase applies migrations as non-superuser `postgres` (BYPASSRLS, object owner) per S1's runtime-role packet. The down.sql "error rather than hide" behaviour for a role subject to RLS is therefore not exercised. The spec also `GRANT ALL` to `anon`/`authenticated` and adds test CHECK constraints (`g2p_target_refusal`, `g2p_entity_refusal`) — documented intent (prove policy denial, not missing grants; S1's bootstrap notes Supabase default privileges grant API roles CRUD on new tables, so this is a fair proxy), but the disposable schema deviates from production shape while the RLS assertions run.
Smallest remediation: run `migrate deploy`, E up and down as the Supabase-like `postgres` role from S5-B-01; keep the superuser only for role/database creation; assert `super: false, bypassrls: true` for the migration connection.

### S5-B-04 — MATERIAL (recovery packet gap, owner S1; correctly surfaced by S5, not fixed): manual `down.sql` leaves migration history claiming E applied
Evidence: `20270118000000_scout_ledger_platform_expand/down.sql` drops the column but does not touch `_prisma_migrations`; spec stage 5 characterises that a subsequent `prisma migrate deploy` reports nothing pending while the column is absent (T writer then 500s), and re-applies E via raw `sql(up)` rather than the documented Prisma recovery (`prisma migrate resolve --rolled-back …` → `migrate deploy`). Neither the E design doc nor `down.sql` states the `migrate resolve` step.
Consequence: operator rollback followed by the normal release script silently leaves E un-reapplied. Must be in the staged rollout/recovery packet before E promotion.
Smallest remediation (S1, sole schema/migration writer): a header comment in `down.sql` and a step in the E doc: after `down.sql`, run `prisma migrate resolve --rolled-back 20270118000000_scout_ledger_platform_expand`; spec stage 5 should exercise that path instead of `sql(up)`.

### S5-B-05 — NONMATERIAL (documentation truth): in-tree G2 docs assert hosted PG15; production is PG 17.6
Evidence: `docs/…/2026-09-18-g2-ledger-platform-expand.md` ("Local PG18.6 proof is not hosted PG15") and the T/Q0 doc/spec (`test/rls-g2-tq0.spec.ts`, `test/rls-g2-ledger-expand.spec.ts` guard port 55439, "PostgreSQL 15") vs. `PG17_INFRA.md` and the operational takeover deliverable (Supabase project active on PostgreSQL 17.6 via management metadata). CI dry-run/rls-live jobs use `postgres:15`/`15.18`.
Consequence: the earlier E and T/Q0 specs ran (if at all) on a non-representative version in an unreproducible environment (port 55439, user `user`); their results are not evidence here. The new PG17 spec is the only executable proof, and it has not run. Docs should be corrected by their owner before promotion.

### S5-B-06 — EVIDENCE GAP (execution-dependent assumptions in the spec)
1. "two absent skip inserts observe real P2002 contention" expects ROLLBACK counts `[0,1]`; Prisma 6.19 may compile `upsert({update:{}})` on a single compound-unique `where` to native `INSERT … ON CONFLICT`, in which case no P2002 occurs (`[0,0]`) and the test fails although the product converges correctly. Recorded worker query logs will settle this.
2. Volume: 1,050 staged rows, 600-row O run, 84-page reads, within the 90 s worker kill timer and 180 s jest timeout on a 2 vCPU sandbox — timing false-negatives possible.
3. Lock-timeout test expects ≥5 s <30 s; `blocked()` relies on `application_name` from the URL — plausible, unverified.
4. `resetData()` delete order vs. FKs; O client generated via sed-injected `output` into a custom dir sharing `node_modules` (bootstrap asserts identical `package.json`/lock between O and candidate — good fail-closed; O `prisma generate` never ran because bootstrap aborted).
None of these are defects; they are what execution must show.

### S5-B-07 — CONTRACT LIMITS correctly characterised, not fixed (carry forward to B-drain/R/N/Q1/C; not batchable)
Staging key `ScoutIngestEntity(coach_id,intent_id,source_id)` excludes `entity_type` and platform; ledger key excludes platform; Q0 accepts legacy+v2 cursors but emits legacy (tied-row skip after a v2→legacy chain only on a future wide schema, characterised in a temporary fixture); O writer can downgrade a T success/clear `target_id` while leaving provenance; O rollback resumes NULL creation; precedence is a T-writer-only guarantee; accounting is ledger-derived, so `staged = reconstructed+skipped+failed` does not hold when ledger rows exist without staged rows (pre-existing O behaviour, spec asserts `reconstructed:1` on `staged:0`). These are acknowledged limits of the E and T/Q0 releases; each later stage must remain a separate release with its own proof.

### Positive observations (reviewed, not executed)
Target guard refuses well-known/S1/Agent83 ports, non-loopback hosts, wrong DB names, inline passwords, extra URL options; requires `db:port` confirmation; password only from env (26/26 guard unit tests passed in the builder's run). `refused()` checks error text; catalog OID/RLS-flag/policy equality checks bracket E up/down; RLS denial covered for `anon`/`authenticated` including hostile JWT claims; worker `Module._resolveFilename` hook binds `@prisma/client` per selected client (sound old/new isolation); `decodeScoutCursor` canonical re-encode, 8192 bound, NUL/surrogate/scope/order/version checks match the spec's malformed list; `isCanonicalPlatform` regex and 256 bound consistent; RLS policies on all four scout/Person tables are FORCE + RESTRICTIVE deny for API roles + PERMISSIVE for `service_role`, consistent with the spec's expectations. S5 wrote only test files — S1 remains sole schema/generator writer.

## 5. Evidence inventory

Available: `execution/s5-g2/logs/npm-ci.log` (npm ci rc=0, prisma generate 6.19.3 rc=0); `guard-unit.log`/`run-proof-all.out` (guard PASS 26/26 on builder HEAD `65b1da27`, same tree as snapshot); `bootstrap.log` (FAIL, role `postgres` missing); `live-etq0.log` (node OOM, exit 137); `env.log` (node 20.20.1, psql client 18.6 — client version is not server evidence); `pg-status.log` (S5 cluster running); S1 `replay-main-c23b9d9.log` (165 migrations as `postgres` on S1's cluster — S1 scope, not this candidate's E/T on the S5 lane).
Missing: any executed E/T/Q0 live assertion; O client generation; recorded query shapes (S5-B-06); a staged rollout/recovery packet document (acceptance row item) — S5 does not claim it yet.
Requested through the parent (why / what): (a) after S5-B-01 fix, `bash execution/s5-g2/run-proof.sh bootstrap` then `… live`, separately, to obtain the first real live outcome; (b) confirm the effective heap setting in `env.log`; (c) S1 to answer S5-B-04.

## 6. Disposition summary

| ID | Type | Material | Owner |
|---|---|---|---|
| S5-B-01 | harness defect | yes | S5 |
| S5-B-02 | runner defect + crashed run | yes | S5 |
| S5-B-03 | representativeness | conditional | S5 |
| S5-B-04 | recovery/doc gap | yes | S1 |
| S5-B-05 | doc truth | no | docs owner |
| S5-B-06 | evidence gap | n/a | execution |
| S5-B-07 | documented contract limits | no (carry) | later stages |

## 7. Verdict

**NOT CLEARED.** No live test of the cumulative E/T/Q0 contract has executed; the only recorded run failed at bootstrap and then crashed (S5-B-01, S5-B-02). Material findings S5-B-01/02 (harness) and S5-B-04 (S1 recovery packet) are open. On source review alone, the harness design is largely adequate to the acceptance row (representative PG 17.6 lane, old/new writer, collisions, cursors/provenance, accounting, preservation/recovery), with the representativeness caveat in S5-B-03; the cumulative G2 contract is acceptable only as staged, separate E then T/Q0 releases with S5-B-04 resolved and S5-B-07 limits carried forward. Limits of this audit: no execution by the auditor; Prisma engine behaviour not inspected; production truth taken from S1/operational deliverable, not observed.
