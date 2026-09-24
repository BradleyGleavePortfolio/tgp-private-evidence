# C slice (narrow-key contraction + C.down refusal / forward-repair) — readiness brief

T3 read-only brief writer, 2026-09-24 ~17:50–18:15Z, per `execution/cf8ff737/C_READINESS_BRIEF_GRANT.md`. Requested route Claude Opus 5.5 / XHigh; model identity and effort are not telemetry and are not claimed. Nothing was checked out, generated, tested, locked or pushed. The only write is this file. Historical LOC/density ceremony is not carried (R brief L5 convention).

## 0. Source of truth (git objects; lines are blob lines)

- **R** = `7d2895e1` (`worktrees/s7-r-ready`). **PROD-CI-1** = `c7a5fe8d`, the `integration/importer` tip, parent R; its diff vs R touches only `.github/workflows/migration-dry-run.yml` and one comment line in `scripts/release.sh`. Backend `main` is still `c23b9d9f` (LANDING_LEDGER L16).
- **N/Q1** is uncommitted in `worktrees/s7-nq1` on HEAD `7d2895e1` (18 files, +909/−193). There is no `nq1/SOURCE_READY.md`, so it is **not accepted**. Read only via `GIT_OPTIONAL_LOCKS=0 git -C … diff`.
- **Migrations @c7a5fe8d, newest last:** `20261224000000_rls_close_public_exposure`, `20270117000000_durable_import_setup`, E `20270118000000_scout_ledger_platform_expand`, B `20270119000000_scout_ledger_obsolete_writer_fence`, R `20270120000000_scout_identity_ready`. E/B/R each ship `migration.sql` + `down.sql`, no `verify.sql`.
- **Naming (C).** The grant's "M01/M02/M08/M09" = handoff §6 original cases 01/02/08/09 (handoff L166, L167, L173, L174), not the handoff M-table (M08 concurrent ingest/rollback, M09 cursor, L216-217). §4 covers both sets.

## 1. C migration contract (Q1)

**Directory:** `prisma/migrations/20270121000000_scout_identity_contract/{migration.sql,down.sql}` (next monotonic id after R). **No `verify.sql`:** release.sh requires one only for entries in `scripts/release-required-verifiers.txt` (L130-137, L184-189; sole entry `20261224000000_rls_close_public_exposure`), yet runs every discovered `verify.sql` on every release (L271-278), so a C verifier would turn every release after a C.down red. E/B/R ship none.

**Objects dropped are unique indexes, not constraints** (both `CREATE UNIQUE INDEX`):
- staging `"ScoutIngestEntity_coach_id_intent_id_source_id_key"` (coach_id, intent_id, source_id) — `20261222000000_scout_ingest_entity/migration.sql` L46-47;
- ledger `"ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_id_key"` (coach_id, intent_id, entity_type, source_id) — `20261223000200_scout_reconstruction/migration.sql` L66-67.

The ledger name is 70 chars; PostgreSQL stores the 63-char truncation. R compares via `::name` (R migration L41-44; R down L34-36). C must use the literal original text (truncates identically) or the explicit 63-char form — never a new name. Drops are plain `DROP INDEX public."…"` in the transaction: no `CONCURRENTLY` (breaks two-table atomicity), no `CASCADE` (any dependent object makes the drop refuse atomically).

**C.up envelope.** Copy R verbatim (R migration L17-20): `BEGIN`; `SET LOCAL lock_timeout='5s'`, `statement_timeout='30s'`; `LOCK` both tables `ACCESS EXCLUSIVE`. `DROP INDEX` is catalog-only; the real risk is the 5s lock wait against in-flight writers, which fails atomically.

**C.up preconditions (fail-closed, schema-qualified, before any DDL):**
1. **Narrow keys exact on both tables.** Reuse the R.down L19-40 loop verbatim (exact `pg_get_indexdef`, relkind `r`, RLS enabled+forced, unique/valid/ready/immediate, no predicate/expressions) → `'G2-C unexpected identity prerequisite'`. Refuses a raw rerun (case 14) and a wrong-owner/decoy object (case 21).
2. **R exactly as shipped.** Reuse the R.down L44-75 predicate: wide `ScoutIngestEntity_identity_key` / `ScoutReconstructionLedger_identity_key` on (c,i,e,p,s) exact and valid; both `*_source_platform_canonical` CHECKs validated; ledger `source_platform` NOT NULL → `'G2-C wide identity absent'`.
3. **Both `source_platform` columns** NOT NULL TEXT, no default (R migration L62-84 shape, `attnotnull` on both), plus an explicit `NOT EXISTS … IS NULL` on both tables (redundant, cheap; recommended belt-and-braces).
4. **B's fence** is neither asserted nor touched: NOT NULL already refuses what it refuses; B.down owns it (§2 chain).

Then drop both narrow indexes and `COMMIT`. Post-state: wide keys, CHECKs, NOT NULL, RLS flags and policies unchanged; zero data changes.

**schema.prisma (base = N/Q1 accepted head).** Delete staging narrow `@@unique([coach_id, intent_id, source_id])` (L6893) and rewrite comments L6874-6877 ("(c,i,s) unique key makes the endpoint idempotent") and L6894-6895. Delete ledger narrow `@@unique([coach_id, intent_id, entity_type, source_id])` (L6951) and rewrite N's replacement comment ("narrow key is retained until C"). The ledger `String?`→`String` flip (L6945) is N's. Wide `@@unique(…, map: …)` L6896/L6956 unchanged. The client is generated at build (`prisma-client-js`, L4-6; none committed), so `tsc` detects any leftover narrow selector.

## 2. C.down contract (Q2)

**Envelope** as C.up / R.down L9-12. **Preconditions:** C exactly as shipped — no relation in `public` named either narrow index (case 21 decoy discriminator) and the R.down L44-75 wide/CHECK/NOT NULL predicate exact — else `'G2-C contract absent'` (refuses C.down rerun and C.down on a pre-C DB).

**Collision pre-check before any CREATE** (under ACCESS EXCLUSIVE, so race-free): `EXISTS` duplicate (coach_id, intent_id, source_id) in staging **or** duplicate (coach_id, intent_id, entity_type, source_id) in the ledger → `RAISE EXCEPTION … USING ERRCODE = 'unique_violation'` (23505), fixed identifier-free text, recommended:

> `G2-C.down refused: cross-family/cross-platform identities exist; restoring narrow keys would lose data. Forward repair only: keep C, fix forward with N-compatible writers; no deletion.`

Why explicit: a bare `CREATE UNIQUE INDEX` 23505 prints `DETAIL: Key (…)=(…)` into release/psql logs, leaking coach/source identifiers. Both tables are checked before either CREATE; the transaction still makes any late failure atomic (case 20: no half-narrow state). Nothing is deleted, deduplicated or re-statused (handoff L154).

**Recreate** both indexes byte-exact (original names/columns, schema-qualified `public."…"`, shadow `search_path` case 15), then re-run the R.down L19-40 loop as an in-transaction **postcondition** so a non-exact recreation refuses atomically; `COMMIT`. Result = R: wide keys, p, CHECKs, NOT NULL kept (handoff L98); N may continue; T only after successful recreation (handoff L154).

**Chain-harness compatibility (PROD-CI-1 `migration-dry-run.yml` @c7a5fe8d):**

| Situation | Harness behaviour | C requirement |
|---|---|---|
| C newest (CHAIN=[C]) | reset → bootstrap → `migrate deploy` (L567-571) → dump → `C/down.sql` via psql (L640-646) → re-apply `C/migration.sql` via psql (L649-655) → byte diff (L664-669) | Holds on an **empty** DB iff C.down recreates exact names/definitions and C.up re-drops them. |
| C in the chain of every older NEW dir (R, B, E, 20270117, 20261224 while new vs the PR base) | CHAIN = dir + all later dirs (L621); every later dir **must** have `down.sql` or the older dir FAILs (L623-630); downs newest-first C.down → R.down → B.down → E.down | C **must** ship `down.sql` (IRREVERSIBLE would fail five green checks). R.down L19-40, B.down L18-20, E.down L17-19 require exact narrow keys, so C.down exactness is load-bearing for every older check. |
| Non-PR dispatch | no base → nothing checked (L505-508) | — |

CI is PostgreSQL 15.18 (L123, L461) on empty tables; refusal paths (collision, rerun, decoy) are proven only by local PG17 (§4). G2 specs are not in the rls-live lane, which runs named files (`ci.yml` L302, L403). (C: same qualification as R.)

**R.down staged refusal holds with C applied.** R.down's first loop needs both narrow keys exact; with C applied they are absent → `'G2-R unexpected identity prerequisite'`, atomic (R down L19-40). B.down/E.down refuse the same way. No R/B/E change; the message does not name C → runbook "run C.down first". (C)

## 3. Code that must change or be verified at C (Q3)

At R the only narrow selector in `src` is `scout-reconstruct.service.ts:273` (`coach_id_intent_id_entity_type_source_id`); N replaces it with the five-field selector and deletes the claim. The staging selector `coach_id_intent_id_source_id` is unused.

**Must change (default Jest/tsc otherwise red or wrong):**

| Path (blob line) | Why | C action |
|---|---|---|
| `test/scout/scout-ingest.idempotency.spec.ts` L35, L48-58 | Regex `/@@unique\(\[([^\]]+)\]\)/` matches only a map-less `@@unique`; after the narrow line is deleted it matches nothing → fail. | Pin the wide key: cols/order (c,i,e,p,s), `captured_at` excluded, map name, narrow absent. Historical-DDL checks L64-83 stay. |
| `test/scout/reconstruct/scout-reconstruct.migration.spec.ts` L90-94 | Same regex on the ledger → TypeError. | Same wide-key pin; L101-107 historical DDL stays. |
| N fakes `test/scout/reconstruct/{conformance-alpha.e2e,scout-reconstruct.families,scout-reconstruct.service}.spec.ts` | N diff makes fakes raise P2002 on a taken narrow key and asserts "narrow-key collision … 409 with nothing written" (N diff hunks ~+50, +124, +197, +261-262, +288) — models R. | Remove narrow emulation; flip: same s on another platform → distinct ledger row + target (unit mirror of M07; PG is authority). |
| `src/scout/scout-reconstruct.service.ts` (N version) doc + `retryContention` comment | Says persistent P2002 "is a provenance collision on the retained narrow key" — impossible at C. | Doc only: unexpected unique violation. **Keep** the 409/nothing-written fail-closed fallback. Order (source_id, source_platform) is total per family at C. |
| `src/scout/scout-ingest.service.ts` L47-64 | Documents (c,i,s) as the idempotency key. | Doc: key is (c,i,e,p,s). No code change. |
| `src/scout/scout-ingest.controller.ts:39`, `src/scout/scout-reconstruct.controller.ts:42` | "Idempotent on (coach_id, intent_id, sourceId)" / "(…, entity_type, source_id)" become false. | Fix text; regenerate `docs/contracts/importer-openapi.json` (L1616, L1873) via `scripts/importer-contract.ts`; drift guard `test/contracts/importer-contract.spec.ts` L17-22 needs byte identity. N edits all three → C rebases on N. |
| `test/scout/scout-ingest.service.spec.ts:85` | Comment names the (c,i,s) key. | Text only. (C) |

**Verify only (no change expected):**
- Targets `families.ts` L69-86, L107-125 keyed (coach, platform, external id) / (coach, platform, entity_type, source_id): same-s cross-platform rows already get distinct targets.
- Readers/cursor are Q1's. At R, ties across p are impossible, so N/Q1 proves ties only on a temporary future-schema fixture (NQ1 brief L102, Q04). **At C ties become real** → C re-runs the tie case on the real schema (C16).
- `src/scout/scout-ledger-backfill.ts` is NULL-only (no-op at C); `readDrainState` joins on narrow (c,i,e,s) (L234-240) and over-counts `mismatch` for cross-platform rows after C, reported only, not in the outcome (L284-290). Retire the CLI after R or runbook note. (C)
- Accepted E/B/R/ETQ0/TQ0 PG specs/harnesses (`test/rls-g2-*.spec.ts`, `test/utils/g2-*`) pin narrow keys for their own heads: frozen evidence, not edited or re-run on the C head; default Jest ignores `test/rls-*` (NQ1 brief L113). (C)

**Ingest `ON CONFLICT DO NOTHING` at C.** `createMany({ skipDuplicates: true })` (L80-83) compiles to `INSERT … ON CONFLICT DO NOTHING` without a target (doc L50-52), so every unique index arbitrates: at C, the wide (c,i,e,p,s) key and PK `id` (client `uuid()`, schema L6883; never collides). Hence full-tuple replay, changed `captured_at` and in-batch duplicates still dedupe (cases 03-05); other intent/coach insert (06-07); **same s across families** (separate envelopes; `entity_type` per batch, L71) **inserts, count 2** (case 01); same s across platforms in one batch inserts, deduped 0 (cases 02, 12). `deduped = received − count` (L85) stays accurate under concurrency (speculative insertion). This is the activation boundary (handoff L98).

## 4. Proof plan (Q4)

**Harness.** Reuse the R pattern (`g2-r-ready-{bootstrap.sh,db.ts,harness.ts,pg-harness.ts}`, `rls-g2-r-ready.spec.ts`) with the N/Q1 conventions (NQ1 brief L89: five-placeholder binding, single-run grant, heavy slot `execution/test-validation.lock`). New: `test/rls-g2-c-contract.spec.ts`, `test/utils/g2-c-{bootstrap.sh,db.ts,harness.ts,pg-harness.ts}`, seventh identity `g2_c_disposable`, marker `c-disposable-pg17`, `G2_C_*` env, default-Jest `test/scout/g2-c-db-guard.spec.ts`.

**Setup.** History S1, C1, E, B, R applied by file; `migrate deploy` must apply **exactly one** migration (C). The "old" process is the N/Q1 accepted head with a client generated in that checkout (substituting `G2_R_OLD_ROOT/CLIENT`); N runs across C, C.down and re-C. Real service/client for all ingest/reconstruct cases (case 12 requirement); independent connections and process barriers for concurrency (handoff L222).

| ID | Case (source) | Pass condition |
|---|---|---|
| C01 | Catalog (M10, case 10) | R snapshot has both narrow exact. After C: narrow absent; wide, CHECKs, NOT NULL, RLS flags, full policy catalog byte-equal to R; zero pending migrations. |
| C02 | **Negative control on R** (case 02 L167) | Before C, same run: three families sharing s → deduped 2; same s other platform → deduped 1. R still dedupes. |
| C03 | Cross-family activation (case **01** L166) | After C: same s in `clients` and `workouts` → inserts 2; stored types exactly client/workout. |
| C04 | Three types share s (case **02**) | received − count = 0. |
| C05 | Retained idempotency (cases 03-07) | Full-tuple replay 0 (stored 1); `captured_at` change 0; in-batch dup → 1; other intent 1; other coach 1. |
| C06 | Real service, two platforms (case 12) | received 2 / deduped 0; timestamp/payload replay → deduped 2, rows unchanged. |
| C07 | Reconstruct three platforms (case 16) | truecoach / conformance_alpha / unknown, same workout s → reconstructed 2, skipped 1, failed 0; replay → 3 ledger rows, 2 targets, same tally. |
| C08 | N+N final-writer races (M07) | Barriers: same full tuple → one ledger row + one target; other platform/family → distinct outcomes; success never downgraded. |
| C09 | Concurrent ingest vs C.up/C.down (M08) | Writer holding locks → C.up and C.down each fail at `lock_timeout` atomically, catalog unchanged; replay + new identities concurrent with committed contraction: counts accurate, all rows kept. |
| C10 | Collision-free full reverse (case **08** L173) | C.down → R.down → B.down → E.down, then E/B/R/C forward: staging rows byte-equivalent; C.down alone returns the exact C01 R catalog, wide kept. |
| C11 | Cross-family collision (case **09** L174) | C.down → 23505, fixed message, no identifiers; 2 rows + wide remain; narrow absent on **both** tables. |
| C12 | Platform collision in staging (case 18) | As C11. |
| C13 | Ledger-only collision (case 20) | Refused; staging narrow **not** created (no half-narrow). |
| C14 | Entry guards (cases 14, 15, 21) | C.up rerun, C.down rerun, C.down without C, wrong-owner/decoy narrow-named object → each refuses, decoy unchanged; shadow `search_path` redirects neither direction. |
| C15 | Staged refusals with C applied | R.down, B.down, E.down each refuse atomically; catalog unchanged. |
| C16 | Real ties (M09 at C) | N/Q1 readers on C schema: `limit=1` over s tied across p1..p3 enumerates all exactly once; legacy boundary with ≥2 ties → documented 400 restart. |
| C17 | Security (case 19) | Non-bypass anon/auth CRUD denied on both tables after C and after C.down; service-role tx rollback. |
| C18 | Late ingest (M12) | Only if F1(i): ingest between count and pages → next replay converges; tally equals ledger. |

**Default Jest:** the two rewritten structural guards, flipped N fakes, contract drift spec, `g2-c-db-guard.spec.ts`; `tsc` clean with narrow selectors gone. PG15 only via CI `migration-dry-run` on the PR (empty-DB forward/down/forward).

**Tier T4** — persistent-identity activation and lossy-down refusal boundary (handoff L98, L154). Two independent adversarial exact-head reviews (lens 1 SQL migration + chain contract; lens 2 ingest/writer/reader semantics + concurrency), then one single-run PG grant (NQ1_BUILD_GRANT L71-72 pattern).

**Owned paths** (one writer, or two with the proof sub-slice split as in N/Q1): `prisma/migrations/20270121000000_scout_identity_contract/**`; `prisma/schema.prisma` (two `@@unique` lines + three comments only); `src/scout/{scout-ingest.service,scout-ingest.controller,scout-reconstruct.controller,scout-reconstruct.service}.ts` (doc/text only); regenerated `docs/contracts/importer-openapi.json`; the two structural specs, three N fake specs, `scout-ingest.service.spec.ts` (comment); the PG spec/harness/guard files above; `docs/decisions/2026-09-2x-g2-identity-contract.md` (runbook: down order, forward repair, `migrate resolve` after a production C.down since downs do not rewrite `_prisma_migrations`, as R.down L7-8); binding under `execution/cf8ff737/c/`. **Not owned:** E/B/R migrations, harnesses, specs; readers/cursor; backfill; CI/release.

**Estimate (net):** SQL ~160-220; schema/docs/API ~40-60; unit/structural ~120-180; PG proof 1,200-1,700 (R precedent ≈1,600, NQ1 brief L74). Handoff 360–550 / ">400 STOP" (L245) is superseded LOC doctrine: recorded, not gating.

**Dependency.** Build on the **N/Q1 accepted head**; overlaps: `schema.prisma` ledger hunk, `scout-reconstruct.service.ts`, three reconstruct specs, openapi/contract script/spec. SQL, down and harness files are disjoint and may be drafted from `7d2895e1` now, then rebased. The PG run waits for N/Q1 acceptance and the heavy slot. C is outside N/Q1 scope (NQ1_BUILD_GRANT L47).

## 5. Promotion note (Q5; advisory for the owner; not a local blocker)

- `release.sh` applies **every** pending migration before the app rolls (L9-10, L247-249) → separate stages need separate `main` heads. `fly-deploy.yml` @c7a5fe8d is dispatch-only from `main` (L3-4, L58), requires `release_sha` = current `main` head (L22-23, L100, L120-121) and the `apply-migrations` ack (L39-40).
- Advance `main` to each **exact stage commit** and dispatch separately: (1) pre-E `20261224`/`20270117` (owned elsewhere); (2) **E** (+T image); (3) **B**, then production backfill to `drained`; (4) **R**; (5) **N/Q1** image, no migration (PROD-CI-1 rides here or with R); (6) **C**, only after N/Q1 is fully rolled. E/B sit inside the `c23b9d9f..0d69c7ba` fast-forward (LANDING_LEDGER L11); identify stage commits by the commit adding each migration dir (parent read, not done here). Each stage PR gets its own `migration-dry-run` over only its new dirs.
- `main` @c23b9d9f still has `on: push: branches: [main]`; the lineage's file is dispatch-only, and push runs normally use the pushed commit's workflow. LANDING_LEDGER L35-37 still treats a merge as a production deploy — keep that stance and verify at promotion.
- **Production-data preconditions** (not inferable locally; handoff L272): B backfill `drained` on prod (nulls 0, fenced) before R — any NULL/noncanonical p makes R.up refuse atomically (R migration L107-121), a safe release failure; all T/Q0 and O images and in-flight work drained before C (handoff L97, L152; NQ1 brief L66); C.up's 5s lock wait under prod write load; C.down's two index builds within 30s at prod volume, else stop and design an online build (R brief L130 scale stop); **C is effectively one-way after the first cross-family/cross-platform row** — rollback is then forward-repair only (handoff L154); the owner should weigh this at the C dispatch.

## 6. Findings (Safety ROI)

**F1 — A (C activation path only): late-ingest sealing contract (M12) undecided.**
- Evidence: handoff "Decision before activating C" (L220) and "Implement and prove chosen invariant, or block C" (L273). Ingest has no settled/intent-state check (`scout-ingest.service.ts` L66-85). Reconstruct asserts settled (L69, L133) but counts first (L77), then pages by offset `skip` (L88-90). NQ1 brief L113(3) calls offset paging "safe only because reconstruct is post-settle" — that premise holds only if ingest is sealed, which it is not.
- Harm: late ingest during a pass shifts pages → a row missed or revisited while `staged` and the tally disagree without signal. Pre-existing, not C-caused; C widens the set of distinct identities on this surface.
- Blocked: freezing C build scope (C18 and any seal code in or out) and C production activation.
- Minimum closure: parent/domain decision recorded before the C build grant — (i) contract "reconstruction is not a snapshot; the next idempotent replay converges; tally is ledger truth" + C18, no product code (**recommended**); or (ii) ingest refuses a settled intent with 409, which changes extension-visible replay-after-settle (today 202 deduped) → API/owner matter (handoff L274).
- Unlocks: the C build grant. The status-precedence half of L273 is already implemented (success dominates, `scout-reconstruct.service.ts` L289-299; kept by N) and needs only C08 proof.

**F2 — A (production promotion only; owner decision input; no local block): draft PR #530** (`integration/importer` → `main`, LANDING_LEDGER L35-37) is the single production boundary.
- Harm: a one-unit merge applies E, B, R (later N/C) in one release, violating handoff L100 and skipping the prod backfill between B and R. If pre-E ledger rows exist, R refuses after E+B have committed, leaving the E+B schema live under the old `main` image, whose writers the B fence refuses.
- Blocked: only the owner's promotion method. Closure: promote stepwise (§5), never #530 whole. Unlocks: safe per-stage deploys.

**C (record and continue):** R.down message does not name C (§2); backfill `mismatch` over-counts after C (§3); refusal paths PG17-only, CI PG15 empty-DB parity only; no `verify.sql` and C.down does not rewrite migration history (runbook); case-ID naming (§0). Process note: an earlier read in this task ran `git status --short` / `git diff --stat` in `s7-nq1` without `GIT_OPTIONAL_LOCKS=0`; the index mtime (17:29:42Z) predates this task's start (17:48Z), so no index write occurred; later reads used `GIT_OPTIONAL_LOCKS=0 git -C … diff` only.

## 7. Next bounded task (after N/Q1 acceptance and the F1 decision)

Grant a T4 C build on the N/Q1 accepted head with the §4 owned paths; the builder stops at `c/SOURCE_READY.md`; then two T4 attestations (§4 lenses) and one PG grant for C01-C17 (+C18 if F1(i)). SQL/down/harness drafting may start from `7d2895e1` in a fresh builder-owned worktree now. Nothing here authorizes a production action.
