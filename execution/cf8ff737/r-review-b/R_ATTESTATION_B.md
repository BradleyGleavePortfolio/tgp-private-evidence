# R identity-ready — independent T4 review B, exact-head attestation (Phase 1)

Reviewer B, EXEC-CF8FF737, 2026-09-24 ~16:40Z. Read-only against `worktrees/s7-r-ready`, `r-ready/**`, `/home/user/pg17/clusters/*` (hash reads only). Did not read `r-review-a/`. No tsc/Jest/install, no PG process, no push, no worktree edit. Requested route Claude Fable 5 / High; no model/effort telemetry claimed. Accepted B/E/T/C1 bytes not re-audited.

Disclosure: one `flock -n <lock> true` probe (sub-millisecond, nonblocking, released immediately) was run to report the heavy-slot state; it held nothing and blocked no one. Recorded for honesty; no other lock interaction.

## 1. Candidate identity (recomputed)

| Item | Recomputed | Report |
|---|---|---|
| HEAD | `df36e3310d4088501c93bcac3ce07617d02c749d` | match |
| TREE | `74ddf4dd57657300d96b9a7b0cdd6e6237a52abd` | match |
| parent | `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c` (accepted B v5) | match |
| author/committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both; no trailers in body | G05 ok |
| hooks | Lefthook v2.1.9 pre-commit (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc) + commit-msg (no-ai-tokens), receipt 12 | genuine |
| diff scope | 11 files, +1961/−1: migration dir (2), `schema.prisma`, `scout-ingest.dto.ts`, DTO validation spec, `rls-g2-r-ready.spec.ts`, guard spec, 4 harness files | all inside grant-owned paths; no B/E/T/C1/contract/CI file touched |
| worktree | porcelain clean; `s7-b-drain` not in diff | ok |
| receipts | `RECEIPTS.sha256` 12/12 OK; lock held 16:14:36Z–16:18:37Z, verified free after | ok |

Binding pins (recomputed): `r-pg-proof.sh` sha256 `ac437b90…be15` = report; `r-fixture.sh` `6e71d754…35f3` = report; `HEAD:test/rls-g2-r-ready.spec.ts` = `a6f3f166…81ee` = EXPECT_SPEC_BLOB; `HEAD:test/utils/g2-r-ready-bootstrap.sh` = `67b77f7a…35bc` = EXPECT_BOOTSTRAP_BLOB; `node_modules/.prisma/client/index.d.ts` `7c367454…8f71` = EXPECT_NM_CLIENT_SHA; `node_modules/.package-lock.json` `05bc530a…6a44` = EXPECT_NM_LOCK_SHA; `BINDING.sha256` 3/3 OK; `bash -n` ok; 0 unfilled placeholders (the only `__` is the refusal pattern itself).

## 2. Findings

### B-1 (B, proof-invalidating) — binding pins the R proof's data directory to the B cluster

`binding/r-pg-proof.sh` line 45: `G2_R_DATA_DIRECTORY=$BDIR/pg-data` where `BDIR=/home/user/pg17/clusters/b-drain` (line 36). The fixture (`r-fixture.sh` line 22) initialises and starts `/home/user/pg17/clusters/r-ready/pg-data`. The derive script rewrote every other `$BDIR` lane reference to `$RDIR` but left this one (see `r-pg-proof.sh.diff-vs-b-v5` lines 79/85; in B v5 `$BDIR` was correct because B's own cluster was `b-drain`).

- Concrete harm: the granted once-only run passes init/start/old-root/bootstrap (several minutes), then step 6 `SHOW data_directory` returns `…/r-ready/pg-data` ≠ `…/b-drain/pg-data` → `IDENTITY_FAIL`, `fail 73`, sentinel written, Jest never runs. Even if step 6 were bypassed, the spec's `beforeAll` asserts `identity.directory === process.env.G2_R_DATA_DIRECTORY` and `/\/pg17\/clusters\/r-ready\/pg-data$/` on the same env value → suite fails before any R case. No R01–R12 evidence; grant consumed.
- Data safety: none affected. The value is only compared; the B data dir is never opened, started or written (fixture uses `$DATA` = r-ready). Retained B clusters remain safe.
- Exact decision blocked: issuing `R_SINGLE_PG_PROOF_GRANT.md` against binding sha `ac437b90…`.
- Minimum closure: one token in the binding only — line 45 `$BDIR/pg-data` → `$RDIR/pg-data` (and the corresponding substitution added to `derive-r-pg-proof.py` if the generator stays authoritative); recompute `BINDING.sha256`/`PINS.txt` filled sha; update the report's binding sha. No product commit change; head `df36e33` unchanged; re-attest the new binding sha (both reviewers).
- Execution unlocked after closure: the single PG run.

### B-2 (B, proof-invalidating) — R11 asserts `wide()` is ABSENT while the decoy intentionally occupies an R name

`test/rls-g2-r-ready.spec.ts` R11 (stage 2) creates `public.g2r_decoy` with index `"ScoutIngestEntity_identity_key"` (then a CHECK named `"ScoutReconstructionLedger_source_platform_canonical"`) and calls `expectRefusedUp(...)`, whose second assertion is `expect(wide()).toEqual(ABSENT)`. `wide()` (harness lines 32–42) selects by `relname IN (...) AND relnamespace='public'` / `conname IN (...) AND connamespace='public'` with no `indrelid`/`conrelid` filter, so it returns the decoy index (first half) and the decoy constraint (second half). `indexes: [[…g2r_decoy…]] ≠ []` → deterministic assertion failure.

- Concrete harm: R11 fails at the first `expectRefusedUp`; the test body aborts before `DROP INDEX`/`DROP TABLE`, leaving `g2r_decoy` and the decoy index in place. Stage 3 R01 `prisma migrate deploy` then hits `G2-R wide identity already present` (correct refusal) → R01 fails, and R05/R11-shadow/R06–R09/R12 cascade. Jest rc≠0. The migration would be blamed for a test-authoring defect; the once-only grant is consumed. (`afterAll` drops the decoy, so no fixture damage.)
- Exact decision blocked: issuing the PG grant against spec blob `a6f3f166…` / head `df36e33`.
- Minimum closure (spec file only, no migration/DTO/harness change): in R11, do not assert `ABSENT`; snapshot `wide()` after the decoy is created and assert it is unchanged after the refusal, plus `ledgerNotNull === false` and no R object on the two real tables (e.g. `wide().indexes.every(([, , , , def]) => def.includes('g2r_decoy'))`). Alternatively give `expectRefusedUp` an optional expected-`wide()` parameter defaulting to `ABSENT`. This is a new hooked Bradley commit on `s7-r-ready` (tsc/eslint/prettier/check-r75/default Jest; default Jest does not run this spec) → new HEAD/TREE/SPEC blob → refill binding pins (and B-1) → both reviewers re-attest the new head. R01–R12 behaviours themselves are unchanged.
- Execution unlocked after closure: the single PG run.

Sequencing note: B-1 and B-2 are independent; B-2 forces a new head, which forces a pin refill anyway, so both close in one binding refill. Total closure is ~10 changed lines and one gate pass; no re-audit of unchanged bytes is needed beyond the R11 hunk and the binding line.

### C (recorded only; none gate)

- C-1 Migration role RLS visibility. Both tables are `relforcerowsecurity`; the data gates (NULL/noncanonical) are `SELECT … FROM` the tables and are truthful only if the migration role has BYPASSRLS (fixture `postgres`: NOSUPERUSER BYPASSRLS; Supabase `postgres` likewise). If a non-BYPASSRLS role ran the file, the gates would pass vacuously but `SET NOT NULL` (23502) and `ADD CONSTRAINT CHECK` (23514) still refuse — never coerce. Precondition to state in the release runbook: run R as a BYPASSRLS migration role.
- C-2 `down.sql` omits two brief §4 items: it does not require the B fence to be present, and it lacks the comment that R.down is safe only while no N writer is deployed. Behaviour: down drops only R's four objects and `DROP NOT NULL`; no row/value touched; end state is E+B (or E if the fence had been separately removed, a previously accepted shape). Ordering is release-owned. Record; add the comment at N or on any later touch.
- C-3 PG18 forward-compat: on PG18 NOT NULL constraints appear in `pg_constraint`, so the staging column check (migration lines 61–70, "no constraint references attnum") would refuse with `G2-R unexpected platform column prerequisite`. Fails closed; CI is PG15, lane PG17. Not an R defect today.
- C-4 Commit subject/body say "NOT NULL source_platform on ScoutIngestEntity and ScoutReconstructionLedger"; staging was already NOT NULL (the file verifies it, only the ledger is altered). Message imprecision only.
- C-5 R12 "pg_dump -s parity" is proxied by catalog observations (table flags, policies, sorted index defs, constraint tokens), not an actual `pg_dump -s`. Adequate locally; the CI dry-run remains the PG15 forward→down→forward evidence and is not claimed.
- C-6 Binding post-check hashes only `clusters/b-drain`; the retained `b-drain.v4-failed-75a2863b-20260924T151250Z` is not hashed. R never references it. Reviewer baseline (read-only, 16:35Z): v5 conf `173acaa2…6a56`, pg_control `9b99d606…2158`; v4-failed conf `173acaa2…6a56`, pg_control `d037d71b…dd28d`; no postmaster.pid in either. I will re-hash after the run.
- C-7 Contract: `docs/contracts/importer-openapi.json` untouched (not in diff); `test/contracts/importer-contract.spec.ts` regenerates in-process and compares byte-for-byte — passed in gate receipt 11 with the DTO change present, so the C1 pair-surface bytes are unchanged by evidence, not assertion. `minLength/maxLength` in the artifact come from `@ApiProperty`, not class-validator; no `pattern` is emitted.
- C-8 Builder's stated qualifications (client schema.prisma formatting-only diff; one authoring `prettier --write`) carried unchanged.

## 3. Checks that pass (data safety and detection power)

- NULL: refused by `G2-R unresolved NULL provenance` before DDL; no UPDATE/DEFAULT/derivation anywhere in the file (grep: no `UPDATE`, `DELETE`, `DEFAULT`, `DROP`). Fallback refusal 23502.
- Noncanonical: refused per table with distinct messages; the CHECK regex `^[a-z0-9][a-z0-9._:-]{0,255}$` `COLLATE "C"` appears exactly 4× and is the exact mirror of `isCanonicalPlatform` (ASCII-only alphabet ⇒ JS code-unit length = SQL char length; `$` in PG ARE is end-of-string, trailing `\n` refused on both sides; empty refused on both).
- Wide duplicates: impossible while both narrow indexes exist, and both are entry prerequisites (exact `pg_get_indexdef`, valid/ready/immediate, no predicate/expressions). If violated anyway, `CREATE UNIQUE INDEX` fails 23505 — refusal, not coercion.
- Lock/transaction: `BEGIN; SET LOCAL lock_timeout 5s / statement_timeout 30s; LOCK both ACCESS EXCLUSIVE;` single DO gate before any DDL; PG DDL is transactional → atomic; same envelope as accepted E/B; R10 asserts 55P03 in 4.5–30 s with nothing applied.
- Fence predicate: `cardinality(t.tgattr::int2[]) = 0` only; `'{}'::int2[]` text absent from the whole diff. Fence block identical to B down.sql apart from the message prefix.
- Prerequisite loop identical to B/E apart from `G2-R` prefix (proven on PG17 in B v5, including the 63-char truncated ledger index name via `::name`).
- D1: `schema.prisma` adds exactly the two `@@unique(... map: "*_identity_key")` with wide column order (c,i,e,p,s), retains both narrow, ledger stays `String?`, drift comment present. Matches migration index names/columns exactly.
- D2: DTO delegates to `isCanonicalPlatform` via `ValidateBy` (parity by construction); spec table of 32 values incl. `\n`, `\r\n`, NUL, ZWSP, non-ASCII, 256/257 bounds, non-strings; HTTP path asserts 400 + field-level message `entities.0.sourcePlatform must be a canonical platform token` and 0 staged rows; canonical fixtures still 202.
- Ordering: `20270120000000_scout_identity_ready` is the lexical maximum of 169 numeric migration dirs; no collision.
- Down/up: down drops exactly 2 CHECKs, 2 indexes, `DROP NOT NULL`; refuses when R not exactly present (`G2-R wide identity absent`), incl. narrow-index shape; `conkey = ARRAY[attnum]` is 1-D vs 1-D (not the v4 empty-vector pattern). R12 asserts rows/values byte-identical, narrow OIDs and fence identical, index count −2, then re-up shape equality.
- Vacuity spot-checks: `refused()` throws on success and asserts message; `refusedCode()` asserts SQLSTATE via `\set VERBOSITY verbose`; `sqlFile` uses `ON_ERROR_STOP=1` so `toThrow` is real; `expectRefusedUp` compares full ledger/staging snapshots and `_prisma_migrations` count; R01 compares catalog with OIDs, adds exactly two defs, checks `finished_at >= now()` window; R09 requires `result` undefined AND `failure.status === 500`; R08 covers INSERT and UPDATE, owner + service_role + anon/authenticated. Only R11 is defective (B-2).
- Wrong-table: `wide()`/`narrow()` include `conrelid::regclass` / index def text, and R01 asserts the relation per constraint; `catalog()` scopes to the four tables by OID.
- Harness/guard: substitution-only from B (name/marker/port/env swaps, B port 55461 added to refused set, client-key verification added in bootstrap); B files not in diff ⇒ blob-identical; the binding also machine-checks 6 B + 5 S5 blobs and B ancestry.
- Binding isolation: fresh-init only (`RDIR` must not exist), port 55471 free, `pgrep -cx postgres` = 0, S5 absent, C1/B clusters hashed and required unchanged, stop bounded 45 s + kill, data dir retained, once-only sentinel (rc 76), nonblocking canonical lock (rc 75), placeholder refusal (rc 70), post-check worktree porcelain + HEAD unchanged.

## 4. Preconditions for the PG grant

1. Close B-1 and B-2 (one spec commit + one binding refill) and re-attest the new HEAD/TREE/SPEC blob and binding sha.
2. Lane state at grant: no postgres processes; `/home/user/pg17/clusters/r-ready` absent; `r-ready/runtime/` absent; port 55471 free; ≥3 GiB free (builder reported ~4.7 GiB).
3. Heavy slot free at run start; no UX-03 lane holding it.

## 5. Phase 1 verdict

NOT READY for the single PG run as bound: two B findings (B-1 binding data-directory pin; B-2 R11 assertion), both closable in minutes, no product-path A finding. Migration data-safety (refuse-not-coerce for NULL, noncanonical, duplicates; atomic; down lossless) is sound at this head and does not need to change for closure. Scope: local disposable PG17 synthetic fixture only; not PG15 CI, not deployment, not real-database drain, not customer acceptance.
