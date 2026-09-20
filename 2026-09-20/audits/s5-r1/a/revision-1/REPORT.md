# S5 G2 (E → T/Q0) Independent Audit — Auditor A, Round 1

Status: **NOT CLEARED** (evidence gaps + material representativeness/recovery findings; see §7).
Model: Claude Fable 5, High requested (actual reasoning setting not exposed; not claimed).
Auditor: A (independent of builder and of peer auditor B; `execution/audits/s5-r1/b/` was not read).
Report written: 2026-09-20 ~17:15Z. Only file written by this audit: this REPORT.md.

## 1. Snapshot identity (verified with `git rev-parse` / `git cat-file` in `worktrees/audit-s5-r1`)

| Item | Value |
|---|---|
| Audit worktree | `worktrees/audit-s5-r1` |
| Head (parent-captured temporary-index commit) | `785d902286b5bfd15eac71c544f4837fb81ba0c0` |
| Tree | `9bbc0223e809e8e9b10b541bbde98b11903be362` |
| Parent | `d7404cd49578647cf72bb633819d8e86ffc3da3a` |
| Scoped base | `925780e0a1906593e5383c618311b6b17364b8dc` (ancestor of head; O = old writer) |
| Builder branch head at audit time | `65b1da27d9dab4f51f5fad6d8a05be8b64e53dde`, tree identical `9bbc0223…` (builder branch untouched, 5 new files not committed there) |
| Commits base..parent | `8644715c` (E migration), `fdbbaefb` (T writer / Q0 readers), `d7404cd4` (decision docs) |
| Migration dirs | main `c23b9d9f` 164; base `925780e0` 164; parent/head 165 (adds `20270118000000_scout_ledger_platform_expand`) |

Head adds exactly 5 files over `d7404cd4`: `test/utils/g2-pg17-bootstrap.sh`, `test/utils/g2-pg17-db.ts`, `test/utils/g2-pg17-harness.ts`, `test/scout/g2-pg17-db-guard.spec.ts`, `test/rls-g2-pg17-etq0.spec.ts` (718 lines, 5 stages).

## 2. Reviewed scope and actual actions

Read (read-only, snapshot worktree unless stated):
- All 5 snapshot files above; `test/utils/g2-tq0-worker.cjs` (client-pinning worker used by the harness).
- E migration `prisma/migrations/20270118000000_scout_ledger_platform_expand/{migration,down}.sql`.
- T/Q0: `src/scout/scout-reconstruct.service.ts`, `scout-cursor.ts`, `scout-platform.ts`, `reconstruct/families.ts`, DTO/contract diffs (`scout-reconstruct.dto.ts`, `docs/contracts/importer-openapi.json`, roster/entities services) vs `925780e0`.
- Old writer at `925780e0` (`reconstructRow`/`persistReconstructed`/ledger upsert) and reader diffs.
- Decision docs `docs/decisions/2026-09-18-g2-ledger-platform-expand.md` and `…-g2-tq0-writer-readers.md`.
- Jest lane selection: `jest.config.js`, `jest.rls.config.js`, `.github/workflows/ci.yml`, `migration-dry-run.yml`.
- RLS provenance of the 4 tables (`20261223000200`, `20261223000300` migrations), `scripts/ci/supabase-shim.sql`.
- Earlier frozen specs `test/rls-g2-tq0.spec.ts`, `test/rls-g2-ledger-expand.spec.ts` (test titles only, for coverage comparison).
- Evidence: `execution/s5-g2/{MILESTONE-R1-checkpoint.md,run-proof.sh,npm-ci.sh,npm-ci-secondary.sh}`, `execution/s5-g2/logs/*` (including the run that completed at 17:12:19Z), `execution/test-validation.lock.log`, `execution/s1-database/PG17_INFRA.md`, Supabase live metadata captured earlier in this session (`current_session_context/tool_calls/call_external_tool/output_mu9ztqf0.json`, observed 2026-09-20T15:50:47Z — metadata only, no customer rows).
- Governing: `execution/audits/R1_COMMON.md`, `repos/context/AGENT_RULES.md`, `execution/EXECUTION_RULES.md`, takeover brief S5 row.

Not done (deliberately): no install, no commit/push, no Prisma client generation, no DB connections, no type-check/compile run (the builder holds the single validation lock and the box has 2 vCPU; a whole-project `tsc` would contend with the builder's timing-sensitive proof — see S5-A-11). No live-DB access beyond the already-captured metadata.

## 3. Execution evidence actually observed

`execution/test-validation.lock.log`: `17:11:17Z HOLDER=s5-g2 PURPOSE=g2-pg17-proof-all` → `17:12:19Z RELEASE=s5-g2 rc=137`. Run was on builder head `65b1da27` (tree identical to the audit snapshot), Node v20.20.1, psql client 18.6, server `/home/user/pg17/clusters/s5` running (`logs/pg-status.log`).

| Stage | Result | Evidence |
|---|---|---|
| Guard unit spec `test/scout/g2-pg17-db-guard.spec.ts` | **PASS 26/26** (14.8 s) | `logs/guard-unit.log` |
| Bootstrap `test/utils/g2-pg17-bootstrap.sh` | **FAIL** at step 3: `supabase-shim.sql:37: ERROR: role "postgres" does not exist` | `logs/bootstrap.log` |
| Live spec `test/rls-g2-pg17-etq0.spec.ts` | **CRASH** — `FATAL ERROR: Reached heap limit … JavaScript heap out of memory` at ~2,042 MB after ~41 s; no test executed | `logs/live-etq0.log`, `PROOF_EXIT=137` |

`npm ci` + `prisma generate` in `worktrees/s5-g2`: rc=0 at 16:58:55Z (`logs/npm-ci.log`). `run-proof.sh` was modified at 17:13:01Z (after the failed run) to add `NODE_OPTIONS=--max-old-space-size=4096`; an empty `run-proof-bootstrap.out` (17:13:01Z) indicates a re-run was starting. Nothing after 17:12:19Z is asserted here.

Net: **zero of the five live stages (E apply/RLS/OIDs, migrate deploy, T writer, Q0 readers, recovery/lock budgets) has executed on any PG17 database.** The S5 milestone's own statement "Type-checked/compiled: NOT yet. Run live: NOT yet" remains accurate for the snapshot.

## 4. Findings (stable IDs S5-A-nn)

Disposition key: **M** = material (blocks clearance until resolved or evidenced), **N** = nonmaterial, **EG** = evidence gap, **IL** = infrastructure limit, **PX** = pre-existing/out of S5 scope (noted, not charged to S5).

### S5-A-01 — No live proof executed; first run failed before any test (EG, M)
Evidence: §3. Consequence: every claim in the T/Q0 and E decision docs that depends on "representative PostgreSQL" execution (writer/reader compatibility, collision handling, cursor provenance, accounting, populated preservation, recovery, lock budgets) is unproven on PG17. The spec has also never been compiled (ts-jest diagnostics would surface type errors only at run time).
Smallest remediation: fix S5-A-02/S5-A-04, then run `bash execution/s5-g2/run-proof.sh all` under `test-validation.lock`, keep `logs/{guard-unit,bootstrap,live-etq0}.log` and `git rev-parse HEAD HEAD^{tree}` of the run. **Request to parent:** share those logs; the audit cannot be cleared without them.

### S5-A-02 — Bootstrap assumes a `postgres` role that the S5 PG17 cluster does not have (harness defect in tree, M)
Evidence: `test/utils/g2-pg17-bootstrap.sh` step 3 applies `scripts/ci/supabase-shim.sql`, whose line 37 is `GRANT anon, authenticated, service_role TO postgres;` (the CI `postgres:15` image has that role; the S1-provisioned cluster has only `s5_super`, per `PG17_INFRA.md` "each lane may create … non-superuser BYPASSRLS `postgres`"). `set -euo pipefail` + `ON_ERROR_STOP=1` abort the bootstrap; steps 4–7 (O checkout wiring, 164-migration deploy, O client, candidate client) never ran. Re-running hits the same error (steps 1–3 are otherwise idempotent).
Consequence: proof cannot start. Smallest remediation (S5-owned, harness only): before the shim, `CREATE ROLE postgres NOSUPERUSER NOINHERIT BYPASSRLS CREATEDB CREATEROLE LOGIN PASSWORD …` (mirroring live metadata `rolsuper=false, rolbypassrls=true, rolcanlogin=true`) — which also addresses S5-A-03.

### S5-A-03 — Migrations, E up/down and catalog assertions run as superuser `s5_super`; production migration role is non-superuser (representativeness, M)
Evidence: `run-proof.sh` URL user `s5_super`; `PG17_INFRA.md` "s5_super (superuser)"; live metadata: `postgres` `rolsuper=false rolbypassrls=true`; `service_role` `rolbypassrls=true rolcanlogin=false` (harness grants it LOGIN, bootstrap step 3). `down.sql` relies on `SET LOCAL row_security = off`; both scripts `LOCK TABLE … ACCESS EXCLUSIVE` and `ALTER TABLE` on 4 FORCE-RLS tables. A superuser bypasses ownership/privilege checks and RLS regardless, so a green run would not demonstrate that these succeed for the role that will actually run `prisma migrate deploy` in production, nor that RLS/bypass semantics match (BYPASSRLS non-superuser vs superuser). The S1 lane explicitly models a non-superuser `postgres`; the S5 lane does not. Which role the deployed app connects as (`service_role` vs `postgres`) is unknown (S1 gap); worker connections as a LOGIN-enabled `service_role` are therefore a synthetic assumption.
Consequence: the brief's S5 mandate "dedicated representative-PostgreSQL tests" is not met even if the suite passes. Smallest remediation: as S5-A-02 — run bootstrap steps 5–7 and the spec's `sql()`/`prismaMigrateDeploy()` as `postgres` (non-superuser BYPASSRLS); keep `s5_super` only for `CREATE DATABASE`/`CREATE ROLE`; connect workers as the role S1 confirms as the serving role (request to parent → S1: role name and `pg_tables.tableowner` for the 4 tables, metadata only).

### S5-A-04 — Runner lacked the repo's known ts-jest heap requirement (runner defect, execution/, N once verified)
Evidence: `logs/live-etq0.log` OOM at ~2 GB; `.github/workflows/ci.yml` rls-live-tests already uses `--max-old-space-size=4096`; `run-proof.sh` gained `NODE_OPTIONS=--max-old-space-size=4096` at 17:13:01Z, after the failed run. Not in tree; unverified. Consequence: first live attempt produced no test results. Remediation already applied by S5; needs a run to confirm.

### S5-A-05 — E rollback (`down.sql`) leaves `_prisma_migrations` marked applied; documented recovery path missing (S1-owned defect, M for the E release packet)
Evidence: spec stage 5 (`test/rls-g2-pg17-etq0.spec.ts` ~lines 660–690) characterizes: after `down.sql`, `appliedMigrations()` stays 165 and `prisma migrate deploy` prints "No pending migrations"; the T binary then fails every reconstruct with 500 (`P2022`, column missing) while O still works; recovery required raw `up.sql`. `docs/decisions/2026-09-18-g2-ledger-platform-expand.md` does not mention `prisma migrate resolve --rolled-back` or any repair sequence. Consequence: an operator who runs the shipped `down.sql` and later redeploys/redeploys-forward gets a complete reconstruct outage until a manual, undocumented step. Primary rollback (redeploy O with the column retained) is the documented preference and is covered, so this is a secondary path — but G13 requires the recovery/forward-repair proof to be stated. Smallest remediation: S1 adds to the E packet: "after `down.sql`: `prisma migrate resolve --rolled-back 20270118000000_scout_ledger_platform_expand`, then `migrate deploy` re-applies"; S5 asserts that exact sequence in stage 5 instead of raw `up.sql`. S5 correctly self-reported this as a finding for S1 in its milestone.

### S5-A-06 — Synthetic history/schema does not model live drift; E prerequisite-refusal negatives absent from the PG17 spec (EG)
Evidence: live metadata: `_prisma_migrations` successful 164, **rolled_back 2**, unfinished 0; `public_table_count` 179. Bootstrap asserts exactly 164 applied and `rolled_back_at IS NULL` for all. S1 has separately flagged live-vs-main schema drift. If the 2 rolled-back names match repo directories, production `migrate deploy` would re-apply them before E — never exercised. E's exact-identity prerequisite (index definitions + FORCE RLS on all 4 tables) is the fail-closed guard for such drift, but the PG17 spec only exercises "already exists" (up rerun), "unexpected platform column" (down without column), non-NULL provenance refusal and lock timeouts. The frozen `test/rls-g2-ledger-expand.spec.ts` has the negatives ("wrong public index owner in up/down", "search_path decoys", "assigned provenance with no matching staging") but targets the PG18 lane and has no preserved execution evidence. Consequence: the guard that protects a drifted production is unproven on any preserved lane. Remediation: port those three negative cases into stage 1/5 of the PG17 spec (S5), and (parent → S1) supply the two rolled-back migration names so bootstrap can model them if they are in-repo.

### S5-A-07 — Version claims in candidate docs are inconsistent with the hosted target and with CI (doc truthfulness, N; S1/owner fix)
Evidence: T doc requires a "PostgreSQL 15 database"; E doc says "Local PG18.6 proof is not hosted PG15"; live `server_version` is 17.6 (Supabase metadata; `PG17_INFRA.md`); CI `rls-live-tests`/`migration-dry-run` use `postgres:15`/`15.18`. Also: neither `jest.rls.config.js` selection in CI nor any workflow runs the `rls-g2-pg17-*` spec — the PG17 proof is a manual lane, not CI-enforced (declared in the E doc; recorded here as a limit). Remediation: correct both docs to "hosted PG 17.6; CI still PG15; PG17 proof manual"; consider a `postgres:17` service for the G2 RLS job later (not S5 scope).

### S5-A-08 — Mixed-fleet O-after-T downgrade must be in the rollout packet as a fencing requirement (characterized limitation, M for packet wording only)
Evidence: spec "characterizes actual O after T" and "success holds claim while a failing old writer waits" expect O to overwrite `status/target_id` with `failed/null` while provenance stays; old writer `925780e0` upserts the ledger unconditionally (no claim). T doc admits precedence is a T-only guarantee. Consequence: during a mixed E→T fleet, a lagging O pod can destroy a T success record. Remediation: the T release packet must state "T is enabled only after O pods are fully drained (B)", keep E, B(drain), T as separate releases — never batched. This audit confirms the staged sequence E→T/Q0→B drain→R→NQ1→C is respected by the code (T claims only equal/NULL provenance, emits legacy cursors, no unique-key change).

### S5-A-09 — Accounting comment overclaims (N)
Evidence: `scout-reconstruct.service.ts` states `staged === reconstructed + skipped + failed` always holds; the spec's own "claims only exact identity" case expects `staged 0 / reconstructed 1` when legacy ledger rows exist without staging (pre-existing O tally behavior, unchanged by T). Consequence: misleading comment; result semantics are "ledger tally for the identity", not "staged partition". Remediation: reword comment (S1).

### S5-A-10 — Test-quality notes (N)
- `expect(() => stage(...)).toThrow()` / `legacy(...)` collisions (~lines 333/336) fire on the harness's own PK `id = coach-intent-source` scheme as well as the narrow unique key; they do not isolate the product key. Use a distinct `id` to make the assertion meaningful.
- Spec hard-codes `port: 54325` while the guard is env-driven (harmless today).
- Bootstrap is single-shot: `beforeAll` requires 164 applied and no column; after any run that reaches stage 1, a re-run needs a database drop the harness refuses to perform. Document the reset (`DROP DATABASE g2_s5_etq0_disposable` as `s5_super`, operator-only) in the milestone.
- Staging `ScoutIngestEntity.source_platform` has no CHECK constraint (bad tokens injected by SQL); T's 409 fail-stop before any write is the right product behavior and is asserted.

### S5-A-11 — Timing-sensitive assertions on a shared 2-vCPU box (IL)
`worker()` kills after 90 s (1,050-row runs), `blocked()` polls 400×25 ms = 10 s, lock-budget window requires 5 s ≤ elapsed < 30 s per direction, `--testTimeout=180000`. Concurrent lanes (S1 PG17 fixture, other builders) can turn these into false failures. Classify any such failure as infrastructure, re-run once idle; do not loosen the product-side timeouts to make the test pass.

### S5-A-12 — Contract version bump inherits the known C1 #526 collision (PX, dependency)
Evidence: `CONTRACT_VERSION` 1.4.0→1.4.1, `docs/contracts/importer-openapi.json` regenerated (cursor `maxLength` 8192, "Accepts legacy and scoped v2 tokens; emits legacy"). DTO descriptions match the regenerated JSON exactly (checked). The brief already routes the sibling lifecycle contract collision to G3; flagged here only so the two bumps are reconciled deliberately.

## 5. Positive verification (what the source review did establish)

- E: nullable, no-default `source_platform` only; bounded `lock_timeout`/`statement_timeout`; exact index-definition and FORCE-RLS prerequisites on all 4 tables; down refuses when any non-NULL provenance exists; both directions schema-qualified. No unique-key change, so cross-family/platform collisions remain narrow (documented, deferred to R).
- T: canonical-token validation of staged `source_platform` before any write (409); `persist` + claim in one interactive transaction; claim by row lock + conditional `updateMany` (equal-or-NULL provenance), so a late mismatch rolls back new and pre-existing target changes; whole-transaction retry once on `P2002`/`P2034`; failure records written honestly (`failed` with reason, no invented tally). Skip reason embeds the raw staged token but only after canonical validation.
- Q0: accepts legacy and v2 tokens, emits legacy only; cursor length bound 8192; composite ordering `(source_id, source_platform)`; NULL-provenance legacy rows remain visible; ledger-anchored `next_cursor`; foreign coach/intent/family and deleted/moved targets hidden; 400 on malformed/mismatched, 404 on unsettled intent.
- Harness safety: guard refuses non-loopback hosts, known S1/other-lane ports (5432/6543/54321/55417/55439), other database names, embedded passwords, extra query params, fragments; password only via `G2_PG17_PASSWORD` env into psql env / in-memory URL for child processes; query log captures SQL text only, never parameters; `blocked()` observes real `pg_stat_activity` lock waits; O runs from its exact `925780e0` checkout with an independently generated client, pinned per process by `g2-tq0-worker.cjs`.
- Lane isolation: bootstrap asserts `data_directory` ends `/pg17/clusters/s5`, `server_version_num` in `[170000,180000)` and equals the expected 170006.
- Default Jest lane cannot accidentally run the live spec (`testPathIgnorePatterns` matches `test/rls-*.spec.ts`; `jest.rls.config.js` matches it) — confirmed by the guard spec passing in the default lane.

## 6. Evidence gaps and requests routed through the parent

1. **Run the proof** after S5 fixes S5-A-02: `bash execution/s5-g2/run-proof.sh all` under `test-validation.lock`; provide `logs/guard-unit.log`, `logs/bootstrap.log`, `logs/live-etq0.log`, `logs/env.log`, and the head/tree hash of the tree that ran. Why: no live stage has executed (S5-A-01).
2. **S1 metadata (names only, no values):** the two `migration_name`s with `rolled_back_at IS NOT NULL`; `tableowner` of `ScoutReconstructionLedger`, `ScoutIngestEntity`, `Person`, `ScoutReconstructedEntity`; the role the deployed service connects as. Why: S5-A-03/S5-A-06 representativeness.
3. **S1 doc fix:** E packet recovery sequence (`migrate resolve --rolled-back` → `migrate deploy`) and the PG-version corrections (S5-A-05, S5-A-07).

## 7. Verdict and limits

**Verdict: NOT CLEARED.** Reasons, in order: (a) S5-A-01 — no live execution evidence exists and the only attempt failed in harness setup before any test; (b) S5-A-02/S5-A-03 — the harness, as snapshotted, cannot bootstrap on the S5 cluster and, once fixed as written, would still run as a superuser rather than the production-like non-superuser BYPASSRLS role, so a green run would not yet satisfy "representative PostgreSQL"; (c) S5-A-05 — the E packet's destructive-rollback recovery path is undocumented (S1-owned, S5 to assert).

Nothing in the source review contradicts the E/T/Q0 design or shows a product defect beyond those the builder already self-reported; the staged, non-batched release sequence is preserved; S1 remains the sole schema/generator writer and S5's changes are test-only. This snapshot was explicitly not asserted complete or release-ready, so "not cleared" is the expected status, not a regression.

Limits of this audit: static review only; no compile, no execution, no database access; the observed run was on the builder's head with an identical tree, not on the audit commit itself; peer report B not read; findings on timing and on Prisma query-log wording (e.g., `BEGIN`/`ROLLBACK` counts, upsert `INSERT` form) can only be confirmed by the requested run. No secrets, customer records, raw environment values or sensitive log payloads are reproduced here (the fixture password appears only in the builder's own runner script and is a documented synthetic local value; it is not repeated in this report).
