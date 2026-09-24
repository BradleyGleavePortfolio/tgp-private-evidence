# R slice (required canonical platform + wide uniqueness, narrow retained) — source-only build brief

Worker `r_slice_source_only_preparation_mufnlmx0`, 2026-09-24 ~15:00Z. Requested route Claude Fable 5 (live label Claude Fable 5.1) / High; identity and effort are not telemetry and are not claimed. SOURCE-ONLY: nothing installed, generated, staged, committed, run, locked or pushed. No B/E/T/C1 re-audit; no independent-audit claim. Owned output: `execution/cf8ff737/r-prep/**` only.

Read: AGENT_RULES G01–G22; SCOPE.md (cf8ff737); op81 plan §"Integrity repair"; CYCLE3 handoff §§1–5 R rows and M04/M05/M10; RECOVERY_SEQUENCING R bullet. Historical LOC/density/ceremony in those docs is superseded by G06–G10/G21–G22 and is not carried here.

## 0. Source of truth for this brief (exact bytes read, never modified)

B/drain worktree `/home/user/workspace/worktrees/s7-b-drain`, HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` (tree `87798e74`), plus the 11 untracked frozen-v4 B paths (composite tree `f4922ca070e887fb7f613ce955b12621b5c33156`). Blobs cited below are `git hash-object` of the live files:

| File | Blob | R-relevant fact |
|---|---|---|
| `prisma/schema.prisma` | `eb390870` | Ledger `source_platform String?` + `@@unique([coach_id,intent_id,entity_type,source_id])` (E state). Staging `source_platform String` (NOT NULL since IMPORTER-B) + `@@unique([coach_id,intent_id,source_id])`. Targets already platform-qualified (`Person`, `ScoutReconstructedEntity`). |
| `20270118000000_scout_ledger_platform_expand/{migration,down}.sql` | `7f04920a` / `a023a538` | Guard pattern to copy verbatim: BEGIN; `lock_timeout=5s`; `statement_timeout=30s`; ACCESS EXCLUSIVE on both tables; DO-block verifying both narrow indexes by exact `pg_get_indexdef` (ledger name via `::name` truncation), RLS enabled+forced; entry-state refusal; COMMIT. |
| `20270119000000_scout_ledger_obsolete_writer_fence/{migration,down}.sql` | `55c85906` / `91e646dd` | B fence: BEFORE INSERT trigger `ScoutReconstructionLedger_platform_fence` → `public.scout_ledger_platform_fence()` raises `check_violation` on NULL p. Inserts only; UPDATEs unfenced. Exact-shape catalog check (tgtype 7, no WHEN, not secdef). |
| `src/scout/scout-platform.ts` | `bc6b3948` | `isCanonicalPlatform`: string, length ≤256, `^[a-z0-9]`, no char outside `[a-z0-9._:-]`. Comment: "shared with the later R CHECK". |
| `src/scout/scout-reconstruct.service.ts` | `a16bc817` | T writer: refuses noncanonical staged p (line 180, `ProvenanceConflict`); ledger upsert on narrow selector with `create: {..., source_platform: row.source_platform}`; claim `updateMany` `OR: [{source_platform: null}, {source_platform: row.source_platform}]` must affect exactly 1. |
| `src/scout/scout-ingest.dto.ts` | `c1d818b0` | `sourcePlatform`: `@IsString @MinLength(1) @MaxLength(256)` only — **no canonical check at ingest**. |
| `src/scout/scout-cursor.ts` | `734b9e6b` | Q0 already decodes v2 and applies `(source_id, source_platform)` tie-break for v2 boundaries; legacy boundary stays source-only ("Q0 deliberately keeps source-only legacy boundaries on E/R narrow keys"). |
| `src/scout/scout-ledger-backfill.ts` | `957fb8c6` | `readDrainState()` (total, nulls, mismatch, fenced) and `decideOutcome`: `drained` only when `nullAfter===0 && fenced`. `classify` marks noncanonical staging p as `invalid` (never resolved). |
| `test/utils/g2-b-drain-{pg-harness,harness,db,bootstrap}.{ts,sh}`, `g2-tq0-worker.cjs` | `c22a72c4`, —, `cb60f3f4`, `b4503eef`, `aa35e7e2` | Substitution-derived PG17 live harness: real psql, separately generated O/T clients in child processes, `prisma(...)`/`prismaMigrateDeploy`, `refused()`, `catalog()`, `holdTransaction()`, `worker(...,old)`, `stage/stageMany/legacy/resetData`, fixture role matrix (b_super / postgres BYPASSRLS / service_role / anon+authenticated). Guard requires confirmed loopback disposable DB + pinned cluster/database markers. |
| `test/rls-g2-b-drain.spec.ts` | `9b31fd18` | 7 stages / 19 cases: O rows, unfenced backfill, deploy exactness, fence vs O/T/roles, bounded fixture, concurrency, down/up. Structure to mirror, not re-run. |
| `.github/workflows/migration-dry-run.yml` | `ee17ac1a` | CI: `prisma migrate deploy` on postgres:15; for each NEW migration dir with `down.sql`: forward → down → forward, `pg_dump -s` must be byte-identical; schema-parity `migrate diff` is **informational only** (BL-MIGRATION-REBASELINE). |
| `scripts/release.sh` | `c86b3ab9` | Applies all pending migrations before rolling the app → E/B/R/C must be separately promoted artifacts (unchanged from handoff). |
| `.github/workflows/ci.yml`, `jest.rls.config.js` | —, `44c96915` | rls-live jobs run **named** spec files only (lines 302, 403); `test/rls-g2-*.spec.ts` are never selected by CI. Default jest ignores `test/rls-*`. |

## 1. What R is (from current source)

Database state after R (both tables, RLS/policies/roles untouched, B fence untouched):

| Object | Before R (E+B) | After R |
|---|---|---|
| `ScoutReconstructionLedger.source_platform` | TEXT NULL, no default, no constraint | TEXT **NOT NULL**, CHECK `ScoutReconstructionLedger_source_platform_canonical` |
| `ScoutIngestEntity.source_platform` | TEXT NOT NULL, unconstrained content | + CHECK `ScoutIngestEntity_source_platform_canonical` |
| Narrow unique `ScoutIngestEntity_coach_id_intent_id_source_id_key` (c,i,s) | present | **retained, same OID** |
| Narrow unique `ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_` (c,i,e,s; PG-truncated name) | present | **retained, same OID** |
| Wide unique `ScoutIngestEntity_identity_key` (c,i,e,p,s) | absent | created |
| Wide unique `ScoutReconstructionLedger_identity_key` (c,i,e,p,s) | absent | created |

CHECK expression (both tables): `source_platform COLLATE "C" ~ '^[a-z0-9][a-z0-9._:-]{0,255}$'` — the exact SQL mirror of `isCanonicalPlatform` (blob `bc6b3948`): first char `[a-z0-9]`, ≤256 chars, alphabet `[a-z0-9._:-]`. Wide column order (c,i,e,p,s) and `_identity_key` names follow the frozen F contract table (CYCLE3 §1) so C can later drop narrow keys without renaming.

Derived facts (no proof needed): while both narrow indexes exist, (c,i,s) ⇒ (c,i,e,p,s) unique on staging and (c,i,e,s) ⇒ (c,i,e,p,s) unique on ledger, so wide index builds cannot fail on duplicates at R; the only R-time refusals are NULL/noncanonical content, prerequisites and lock/statement budget. Wide indexes at R are dormant arbiters: identity semantics remain narrow until C (CYCLE3 line 25). Q0 readers (`734b9e6b`) already tolerate R; no reader change in R.

## 2. Minimal exact owned paths (R builder, one writer)

New:
- `prisma/migrations/<id>_scout_identity_ready/migration.sql`
- `prisma/migrations/<id>_scout_identity_ready/down.sql`
- `test/rls-g2-r-ready.spec.ts` (live PG17 proof)
- `test/utils/g2-r-ready-db.ts`, `test/utils/g2-r-ready-pg-harness.ts`, `test/utils/g2-r-ready-harness.ts`, `test/utils/g2-r-ready-bootstrap.sh` (literal substitution from the B files above; fifth disposable identity `g2_r_ready_disposable`, cluster marker `r-disposable-pg17`, own DB marker, own `G2_R_*` env; B lane port added to refused ports once known from B runtime receipts)
- `test/scout/g2-r-ready-db-guard.spec.ts` (DB-free guard, substitution from `g2-b-drain-db-guard.spec.ts`)

Modified:
- `prisma/schema.prisma` — ledger model only: add `@@unique([coach_id, intent_id, entity_type, source_platform, source_id], map: "ScoutReconstructionLedger_identity_key")`; staging model: add `@@unique([coach_id, intent_id, entity_type, source_platform, source_id], map: "ScoutIngestEntity_identity_key")`; both old `@@unique` retained. Field type change: see decision D1.

`<id>`: fresh monotonic after B's `20270119000000` (proposed `20270120000000`), fixed against the actual B-accepted integration head at build.

Not owned by R (no edits): `src/scout/**` (unless D1=b or D2=a below, each one file), any E/T/B/C1 migration, `test/rls-g2-b-drain.spec.ts` and every B/S5 harness file (stay byte-identical), CI/release workflows, RLS policies.

## 3. migration.sql contract

Same envelope as `55c85906`: BEGIN; SET LOCAL lock_timeout 5s / statement_timeout 30s; LOCK both tables ACCESS EXCLUSIVE; one DO block; DDL; COMMIT. Entry gate, each a distinct `G2-R …` exception, all before any DDL:

1. Both narrow indexes exact (copy loop verbatim; message `G2-R unexpected identity prerequisite`).
2. E column exactly as shipped (TEXT, typmod −1, nullable, no default/generated/identity, no constraint) — `G2-R unexpected platform column prerequisite`.
3. B fence present in exact shape (copy the pg_trigger/pg_proc predicate from `91e646dd`) — `G2-R fence absent` (drain evidence is durable only under the fence: `decideOutcome`, blob `957fb8c6`).
4. `count(*) WHERE source_platform IS NULL` on ledger = 0 — `G2-R unresolved NULL provenance`.
5. Ledger noncanonical count = 0 and staging noncanonical count = 0 (same regex, `COLLATE "C"`) — `G2-R noncanonical provenance` (ledger) / `G2-R noncanonical staged provenance` (staging).
6. Neither `_identity_key` relation exists in `public` and neither canonical constraint exists — `G2-R wide identity already present` (raw rerun fails atomically, as E/B do).
7. Any pre-existing `public` object owning either target index name → refused by (6); the decoy-owner discriminator (original ID 21) is covered by asserting `to_regclass` NULL for both names.

DDL: `ADD CONSTRAINT … CHECK (...)` on both tables (plain, validated under the held lock — NOT VALID/VALIDATE buys nothing inside one ACCESS EXCLUSIVE transaction); `ALTER TABLE ledger ALTER COLUMN source_platform SET NOT NULL`; `CREATE UNIQUE INDEX public."ScoutIngestEntity_identity_key" ON public."ScoutIngestEntity" USING btree (coach_id, intent_id, entity_type, source_platform, source_id)`; same for ledger. Schema-qualified everywhere (original ID 15 shadow search_path). No DROP, UPDATE, DELETE, DEFAULT, policy, role, trigger or writer change.

## 4. down.sql contract

Refuses unless R is exactly present (both wide indexes valid/unique/exact def, both checks, NOT NULL set, narrow indexes exact, fence present); then `DROP INDEX` both wide, `DROP CONSTRAINT` both checks, `ALTER COLUMN … DROP NOT NULL`. Retains every row, every assigned p, both narrow keys, the fence and the E column → returns exactly to E+B. Never derives, deletes or nulls provenance. Raw rerun refuses (`G2-R wide identity absent`). Comment must state the production ordering fact: R.down is safe only while no N writer is deployed (N depends on required p + wide unique); that ordering is parent/release-owned, not provable in SQL.

CI compatibility (blob `ee17ac1a`): on the empty CI database gates 4–5 hold trivially; forward → down → forward yields byte-identical `pg_dump -s` because names/definitions are deterministic. Schema-parity drift is informational (see D1).

## 5. Decisions the parent must freeze before build (true A/B implementation prerequisites)

**D1 — Prisma field type at R (B-class: wrong choice breaks typecheck or contract coherence).**
Historical handoff says "R changes to `String`". Against current source that flips `ScoutReconstructionLedgerWhereInput.source_platform` from `StringNullableFilter | string | null` to `StringFilter | string`, and the accepted T claim clause `{ source_platform: null }` (blob `a16bc817` line 282) plus the three spec fakes typed `Array<{ source_platform: string | null }>` (`scout-reconstruct.service.spec.ts:143`, `.families.spec.ts:131`, `conformance-alpha.e2e.spec.ts:256`) would stop compiling. (Type consequence is standard Prisma generation; no generated client exists in this sandbox to cite — confirm with `tsc` at build.)
- (a) **Recommended (G21 minimal):** keep `String?` in Prisma at R; DB is NOT NULL. Zero `src/**` change, T writer and its accepted specs byte-identical, generated client differs only by the two new compound selectors. Cost: informational parity drift of one `DROP NOT NULL` statement until N flips the type together with the writer it changes anyway. Record as an explicit, reasoned deviation from the historical row.
- (b) Flip to `String` now and drop the dead null branch in the claim (`where: {...identity, source_platform: row.source_platform}`) + retype three fakes. Cost: R touches the T writer (N's file) and three accepted specs; benefit: zero parity drift. Not recommended before B is accepted.

**D2 — Staging canonical CHECK vs ingest boundary (A-class customer-visible failure mode).**
Ingest DTO (blob `c1d818b0`) admits any 1–256-char `sourcePlatform`. Reconstruct already refuses noncanonical staged rows (409 `ProvenanceConflict`), so such rows never produce customer value today. After R's staging CHECK, a noncanonical envelope fails at INSERT with `23514` → ingest 500 instead of 400 (G02 violation: not an actionable error).
- (a) **Recommended:** include in R one DTO change — `@Matches(/^[a-z0-9][a-z0-9._:-]{0,255}$/)` on `sourcePlatform` (+ one validation-spec case, existing fixtures `truecoach`, `auto:coachrx.example.com`, `conformance_alpha` all remain valid) so the boundary answers 400 before the database does. Regenerate the exported importer contract if `scripts/export-importer-contract.ts` embeds DTO validators (check at build; contract lineage stays 2.x per RECOVERY_SEQUENCING step 3).
- (b) Defer the staging CHECK to C and ship ledger-only CHECK at R. Cheaper now, but leaves wide staging identity built over unconstrained content and re-opens the question at C.
Whichever is chosen, entry gate 5 (staging noncanonical = 0) stays; refusal is the correct local outcome.

**D3 — Fence retention.** Recommended: R leaves the B fence in place (redundant under NOT NULL, harmless, B-owned). Removal, if ever, is a C or later cleanup, not R scope.

**D4 — Wait state.** R implementation starts only after the parent records B acceptance (exact B head, gates, binding) and R can branch from that head. No R worktree, install, generate, commit or PG action before then.

## 6. Environment / ownership needs (local, real)

- **Worktree:** new isolated worktree from the B-accepted head; one writer. Never write into `worktrees/s7-b-drain`.
- **Dependencies:** same pinned tree the B grant reconstructs (Node 20.20.1, npm 10.8.2, lock `354de3da`, hidden-lock sha256 `05bc530a…`). Reuse by copy/hard link of B's verified `node_modules` if the parent permits; otherwise one `npm ci` under the same pins. No graph change.
- **Generated client:** R changes `schema.prisma`, so R must run its own `prisma generate` (6.19.3, recorded engine pins). The C1/B `index.d.ts` pin `bf679a16…` does **not** apply to R's head; record R's own hash. O client for negative control is generated inside the O checkout as the B bootstrap does.
- **Gates:** tsc, eslint (two-path), prettier 3.9.6 (B's tooling dir), check-r75, jest default (guard spec only), ordinary hooked Bradley author/committer commit (G05). Tier 4 (persistent identity contract, NOT NULL, unique keys): two independent adversarial audits on the exact head, read-only, after build — not part of this task.
- **PG lane:** PG 17.6 disposable cluster via substituted bootstrap; `psql` binary; canonical heavy slot `/home/user/workspace/execution/test-validation.lock` (nonblocking flock) — separate single-run parent grant, after J3's granted proof, as SCOPE orders. Estimated fixture: ≤2k synthetic rows/table (harness `stageMany`); no volume quota.

## 7. Proposed acceptance — freeze before build

Live proof `test/rls-g2-r-ready.spec.ts` on the fifth disposable identity, fixture history applied by file exactly as B does (S1, C1, E, B), all synthetic data:

| ID | Case | Pass condition |
|---|---|---|
| R01 | Deploy exactness | From E+B with only canonical/non-NULL rows: `prisma migrate deploy` applies exactly R; `catalog()` shows both narrow indexes with **unchanged OIDs**, two new valid unique wide indexes with exact `pg_get_indexdef`, two checks with exact `pg_get_constraintdef`, `attnotnull`, fence OID unchanged, policies/`relrowsecurity`/`relforcerowsecurity` byte-identical to before. |
| R02 | Refusal: NULL | One NULL ledger row (UPDATE-shaped as B does) → up raises `G2-R unresolved NULL provenance`; no wide index/check, column nullable, rows byte-identical; T worker still reconstructs on E. |
| R03 | Refusal: noncanonical | Ledger `TrueCoach` → `G2-R noncanonical provenance`; staging `Auto:X` → `G2-R noncanonical staged provenance`; atomic, nothing applied. |
| R04 | Refusal: fence absent | E without B → `G2-R fence absent`. |
| R05 | Raw rerun | `psql -f migration.sql` after R → `G2-R wide identity already present`; index OIDs unchanged, one row retained (original ID 14 shape). |
| R06 | T on R | Real T worker: new staged rows reconstruct; five-tuple replay count 0 / stored 1 (ID 03); ledger create carries p; claim count 1; per-family tally unchanged from E behaviour. |
| R07 | Narrow still arbitrates (negative control) | Two staging rows same (c,i,s) different p → second is DO NOTHING (dedup 1); two ledger rows same (c,i,e,s) different p → `23505` on the narrow key; wide keys present but not identity (ID 02 negative control, M05). |
| R08 | Content refusal at runtime | Owner and service_role: ledger `Bad_Platform` → `23514`; ledger NULL → fence `check_violation`; staging noncanonical → `23514`. anon/authenticated via SET ROLE with canonical values → `42501`, read/update/delete 0 (ID 19 subset, both tables). |
| R09 | O negative control | O binary on R fails closed on a new staged row: HTTP 500, no ledger row, no target (fence/NOT NULL); extends B stage 4 by one `worker(...,true)` call. |
| R10 | Lock budget | Held transaction on ledger → up hits `lock_timeout` 5s, `55P03`, nothing applied; release → up succeeds. |
| R11 | Ownership/shadow | Decoy `public` table owning `ScoutIngestEntity_identity_key` → refused, decoy untouched (ID 21); shadow-schema search_path cannot redirect up/down (ID 15). |
| R12 | Down/up | R.down: rows and all p values byte-identical, narrow keys/fence/E column retained, wide/checks/NOT NULL gone; T continues on E+B; re-up restores identical catalog (`pg_dump -s` parity as CI); raw down rerun refused. |

DB-free: `g2-r-ready-db-guard.spec.ts` (fifth identity accept/refuse matrix incl. B/S5/T-Q0/E/C1 identities and B's port); if D2=a, one `scout-ingest.validation` case: noncanonical `sourcePlatform` → 400 with field-level message; canonical fixtures unchanged.

Acceptance = R01–R12 pass on the exact R head with recorded run receipts, gates green, CI `migration-dry-run` forward/down/forward parity for the new directory, and both Tier 4 audits closed. Nothing above claims deployment, drain of any real environment, or customer acceptance.

## 8. Later production/release questions (NOT local blockers; parent/DB owner)

- Production ledger/staging volume, index-build and CHECK-scan duration inside `statement_timeout=30s` under ACCESS EXCLUSIVE; acceptable write pause. Timeout ⇒ stop and design an online build (CONCURRENTLY outside the transaction + separate VALIDATE), never extend blindly (CYCLE3 "scale stop"). No representative rehearsal exists; none is claimed.
- Real drain evidence: a `drained` backfill report against the actual deployed database with O images restart-fenced (parent-owned inventory). Local R proof uses synthetic rows only.
- R as a separately promoted artifact after B is deployed (release.sh applies all pending migrations before rolling).
- PostgreSQL 15 (CI) vs 17.6 (local lane) parity for the regex/`COLLATE "C"` CHECK — same semantics; the CI dry-run is the PG15 evidence.
- Schema-parity drift (`migrate diff`) remains informational repo-wide (BL-MIGRATION-REBASELINE); D1(a) adds one known statement.
- N/Q1 and C remain separate slices: writer selector flip, v2 emission, narrow-key contraction, and the C.down refusal/forward-repair rules are not R.

## 9. Next bounded build task (ready to dispatch when B is accepted)

Name: `r_identity_ready_t4_build`. Precondition recorded by parent: B accepted at head `<B_HEAD>`; D1/D2/D3 frozen (recommended a/a/retain); migration id fixed. Route Fable/High (no telemetry claim).

Owned: new worktree `worktrees/s7-r-ready` from `<B_HEAD>`; `execution/cf8ff737/r-ready/**`; paths in §2 only (+ `src/scout/scout-ingest.dto.ts` and its validation spec iff D2=a).

Steps (stop on first nonzero, no autonomous retry, no scope growth):
1. Reuse/copy the B-verified dependency tree under the recorded pins; `prisma generate`; record new `index.d.ts` hash and engine pins.
2. Write migration.sql/down.sql per §3–4 by copying the B envelope and guards; schema.prisma per §2/D1.
3. Substitute the four harness files + guard spec from B (`G2_B_`→`G2_R_`, identity/markers), keep B/S5 files byte-identical (verify by blob).
4. Write `test/rls-g2-r-ready.spec.ts` implementing R01–R12 exactly; no additional framework.
5. Gates: tsc, eslint two-path, prettier check, check-r75, default jest (guard + DTO spec). Hooked Bradley commit; report head, tree, blobs, gate receipts.
6. Produce filled PG binding (five-placeholder pattern) for the fifth identity; request the single PG run grant; do not take the heavy slot before it.
7. On grant: bootstrap, run R01–R12 once, preserve raw receipts under `execution/cf8ff737/r-ready/runtime/**`, release slot, return without self-acceptance.

Explicitly out of scope: any N/Q1/C code, reader changes, removing the fence, real database, deploy/push/merge, volume rehearsal claims, audits of E/T/B.
