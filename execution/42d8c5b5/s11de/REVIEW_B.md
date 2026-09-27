# S11-DE independent review B (T4, adversarial) — reviewer claude_opus_5_5

Candidate: `cand/x42/s11de` = `c8ca65f95efd5126e2e5c86e8ffd61e551e78a6c` (tree `f17baf62…`), commit 1 `238ecc15554ff3fa337dcdebe982a778348ddad1` (tree `bed5551c…`, src), on `aed23289`. Both commits author+committer Bradley Gleave, no trailers. Diff aed23289..c8ca65f9: 15 files, +1150/−144 (src +302/−33 per BUILD; verified stat).
Read-only clone `/tmp/rb/be` (`git clone --no-hardlinks`, push-url disabled). No commits, pushes or PostgreSQL. No coordination with reviewer A.

## Verdict: NO-GO (one B, which will fail the parent's leg-B live proof again). Commit 1 (src) is GO on its own.

## B1 — the worker "registry seam" hands the roster reader the WRONG registry in J19 leg B (the third live failure of this spec)

Trace (all at c8ca65f9):
- `journey-full.pg.spec.ts:431` `h.rosterOf('P1', COACH_B, intentId)` → `test/utils/g2-s11-harness.ts:366` `on(host,'phone',{action:'roster',…})` → `:314-315` `run({ ...REGISTRY, ...options })`. `REGISTRY` (`:123`) = `{ spec: SPEC, rules: RULES }`, the single A1 fixture platform `s11-proof`. `rosterOf` never carries `INDUCTION` (`:419`).
- Worker `test/utils/g2-s11-worker.cjs:299-335`: `input.induction` is undefined, so the `input.spec` branch runs: `buildSourceMapperRegistry([SPEC])` — ONLY `s11-proof`, NOT the repository defaults — and `reconstruct.sourceMappers = sourceMappers`.
- New commit-2 lines (roster case): `roster.sourceMappers = reconstruct.sourceMappers` → the reader classifies with `{s11-proof}`.
- Leg B stages `s10_unseen` (`u10-members`×2, `u10-routines`, `u10-sessions`) + `s11_second` (`t11-blocks`, `t11-routines`) (fixtures `test/fixtures/scout/s10_unseen/staged-rows.json`, `s11/s11_second/staged-rows.json`; spec :365-378).

Probe (ts-node, pure, `/tmp/rb/probe.ts`, RC 0): `classifyFamilyScope(registry,'clients',legB groups)` →
- REGISTRY-only (what the worker now injects): `staged 0, unclassified 6, pairs []`
- INDUCTION composed (defaults + s11_second): `staged 2, unclassified 0, pairs [(s10_unseen,u10-members)]`
- repository default (commit 1 alone, no seam): `staged 2, unclassified 2`

So leg B fails at the new line `expect(accounting.unclassified).toBe(0)` (6), then `staged` (0 vs 2) and `persons` ([] vs the two ids) — the seam turns the proof-v2 failure into a worse one. BUILD's trace "with the composed registry the D2 roster token classifies to clients" is wrong: the roster action never receives the composed registry. Leg A (:337-342) passes only because it asserts `staged 0`/`persons []`, which a blind reader also yields (the new `h.persons(COACH_A)` read is what discriminates it).
- HARM: third consecutive live failure of J19 leg B; burns a parent PG proof slot; the src fix is unproven live.
- EXACT THING BLOCKED: J19 leg B pass → S11-D r4 proof v3 → landing S11-DE.
- MINIMUM CLOSURE (test-only): leg-A and leg-B roster reads in `journey-full.pg.spec.ts` (:337, :341, :431, :458) go through the two-source registry, e.g. `h.onInduction(host,'phone',{action:'roster',coach,intent})` (or add `induction.roster`/`induction.entities` wrappers next to `induction.status`). Keep `rosterOf`/`entitiesOf` on `REGISTRY` for journey-core (A1 platform `s11-proof`, where the seam IS correct). Re-trace with the probe above (expect staged 2 / unclassified 0), then run the focused jest set and the guard spec (it pins harness strings with `toContain`; update it if you add wrappers).
- STATE UNLOCKED: proof v3 of `journey-full.pg.spec.ts` on the fixed head; S11-DE GO.

## Audit results (no finding)
- Tenant scope: both groupBys use `{coach_id,intent_id}`. `familyScopeWhere` re-asserts both. Legacy cursor lookup `{...where,status,source_id}` and page `{...where,status,AND:[cursorWhere]}` stay inside the scope. The gate (ScoutImport ownership) is unchanged and runs first.
- Empty scope cannot widen: `familyScopeWhere` throws on `pairs.length===0`, and both readers short-circuit before it (legacy cursor → 400, v2/none → empty page, no ledger findMany). The pairs set is bounded by the registry, because only classified pairs enter it. Unregistered tokens never reach the OR.
- Registry parity: in prod both readers use `buildSourceMapperRegistry()` default, same as `scout-reconstruct.service.ts:71` and facts. The classifier is `resolveFamily` (S10-C). The planner (`family-plan.ts:94`) uses step-only `resolveStagedFamily`. It still reconciles, because a legacy family token without a step entry is planned unmapped → ledgered `skipped` under the same pair, which the reader attributes to the family (staged = r+s+f holds). An unregistered platform is excluded from staged and ledger status alike and counted in `unclassified`.
- Legacy token==family is still served (truecoach steps are identity; resolveFamily fallback). Other-family rows are excluded. A family-named step token (conformance_beta `programs`→workouts) now classifies by its step, which closes a pre-existing token==family misread.
- Bounded: 2 aggregates + ≤1 cursor lookup + 1 `limit+1` page + 1 materialize. That replaces count+groupBy, so there is no N+1.
- DTO/contract: additive required numbers. `staged` description rewritten honestly. The contract diff is exactly the 2 properties + required lists.
- No slug/token literal added in src (rg over added src lines: 0).
- J20: my rev-list walk of `3db615c0^..238ecc15` finds src-touching commits {238ecc15, dda794d7, 645fb6db, 144269d1, 7fdcbc04}, all pinned. `S11_RANGE_END` is ancestor-checked. Sound (as with the existing pins, this assumes SHA-preserving landing).
- Leg A J17 fix: traced to `pairCurrent(host,coach,nonce?)`. OK.

## C (record and continue)
- C1: merged pairs on ONE platform (sharedIdSpaces fan-in, e.g. s10_unseen `u10-routines`+`u10-sessions`, or a step token + legacy token) can put two reconstructed ledger rows with the same `(source_id, source_platform)` into one family scope. Order/cursor keys lack `entity_type`, so the tie order is nondeterministic, the same target can be listed twice, and a tie split at a page boundary drops one. No current fixture/source emits the same id under two tokens. Follow-up: tie-break or dedupe by target.
- C2: BUILD's live-lane table omits `rls-g2-nq1`, `rls-g2-pg17-etq0`, `rls-g2-r-ready`, `rls-g2-s8b`, `rls-g2-b-drain`, `rls-g2-c-contract` (roster/entities reads). All are truecoach-staged, so I expect no count change. Exception: nq1 N05 expects a 500 on a NULL-provenance ledger row. The new first NULL touch is the ledger `groupBy` (expected Prisma null-conversion → 500), not verified.
- C3: the BUILD row for `rls-g2-ledger-expand` ("assertions unchanged") is imprecise. That lane has ledger `source_platform IS NULL` rows (count 5), which the new reader cannot attribute to any pair. The lane already fails at base on the v2 cursor encode of a NULL platform, so this is not a regression. It is a historical lane.
- C4: journey-core roster/entities now read non-empty (the seam is correct there). The equality-only assertions are unchanged.

## Commands
- `git clone --no-hardlinks …/repos/backend /tmp/rb/be`, checkout c8ca65f9, diffs/rg/rev-list: RC 0.
- `/tmp/rb/probe.ts` via `node -r ts-node/register/transpile-only` (pure, no DB): RC 0 (output above).
- Focused jest (roster/entities service specs + g2-s11-db-guard) was queued under the canonical lock (`/tmp/rb/jest.log`). The lock was held by other workers throughout, so I did NOT observe a result and claim none. The builder's gate claims are unverified by me.

---

# Round 2 — delta review of `cand/x42/s11de` = `1ee239c09a19af8da1eb99677f320ec7576a6a5e`

Heads: commit 1 `ce37c6eeb49be1d65ee7c38f86068bd92af824b0` (tree `ae23c357…`, src + v3 cursor), commit 2 `1ee239c0…` (tree `99ae5ad5…`, tests), both on `aed23289`, both authored and committed by Bradley Gleave. Fetched from `/home/user/workspace/repos/backend` `refs/remotes/origin/cand/x42/s11de` into read-only `/tmp/rb/be`. I did not read REVIEW_A.md. Commit 3 had not landed, so I ignored it.

## Verdict: GO. No open A or B.

## B1: closed
- `journey-full.pg.spec.ts` :108-110 `rosterVia = h.onInduction(host,'phone',{action:'roster',coach,intent})` replaces all four `h.rosterOf` calls (:340/:347 leg A, :437/:468 leg B). `onInduction` → `run({...INDUCTION, ...options, host, role})` (`g2-s11-harness.ts:421`). In the worker, `input.induction` is defined, so its composing branch (`g2-s11-worker.cjs:299-321`) runs `buildSourceMapperRegistry([...loadSourceMappingSpecs(), s11_second])` and sets `reconstruct.sourceMappers`. The roster case then hands that registry to the reader.
- Re-ran `/tmp/rb/probe.ts` at 1ee239c0 (classifier unchanged): INDUCTION → `staged 2, unclassified 0, pairs [(s10_unseen, u10-members)]`. The pairs hold only the `u10-members` rows `u10-m-1`/`u10-m-2`, so persons = those two (`sourcePersonId` = trimmed source id, `mapping-spec.ts:197`). Leg A stages no `u10-members` (native_clean filters clients out), so `staged 0` and `persons []` hold. The P1/P2 equality holds because both hosts use the same registry.
- `rosterOf`/`entitiesOf` are left on `REGISTRY` for journey-core, which is correct for the A1 `s11-proof` platform.

## v3 cursor (commit 1): no finding
- **Order and continuation:** order is `(source_id, source_platform, entity_type)`, which matches the ledger unique key within tenant scope, so the order is total. `scoutCursorWhere` uses 3 clauses, or 2 clauses for `t: null`. Both readers select `entity_type` and emit v3 with the last ledger row's token.
- **Decode:** a `v3.` prefix needs `v===3`, a canonical platform, `t` ≤128 chars (`value` rules) and a byte-exact canonical re-encode. The token is bound to `c`/`i`/`f`. Legacy raw roster ids cannot collide with the `v2.`/`v3.` prefixes, because base64url has no `.`.
- **Size:** `t` ≤128 matches ingest `@MaxLength(128)` (present since 3478b61d, the ingest introduction), so every stored token is encodable. The legacy route writes short family names.
- **v2 compatibility:** one `take:2` lookup `{...scope(coach, intent, OR pairs, status reconstructed), source_id, source_platform}`.
  - 0 rows → `t:null`, continue after the pair (no tie possible).
  - 1 row → that row's token.
  - ≥2 rows → 400, with no page or person read.

  This is correct. It is fail-closed, and the old pair boundary with one in-scope row equals the new row boundary.
- **Legacy tokens:** they now also select `entity_type`. `rows[0]` is used only when exactly one row passes `isCanonicalPlatform`.
- **Scope:** every lookup and page read carries `familyScopeWhere` plus status, and the cursor clause is AND-ed. A forged v3 `t` or `p` can only move the boundary inside the scope, never widen it. The empty-scope short-circuit is unchanged: a legacy token gets 400, and v2/v3 get an empty page.
- **Callers:** encode/resolve are used only by the two readers.
- **Contract:** descriptions only, no schema shape change.
- **J20:** `SLICE_COMMITS` and `S11_RANGE_END` = `ce37c6ee`. The build report's walk of `3db615c0^..ce37c6ee` finds {ce37c6ee, dda794d7, 645fb6db, 144269d1, 7fdcbc04}, all pinned, and matches my round-1 walk (with ce37c6ee in place of 238ecc15).

## C (record and continue)
- **C5 (rolling deploy):** an instance still on the old build rejects a v3 token with 400 `malformed cursor`, which is fail-closed; the client must restart from page 1. This is only a deploy-window annoyance, provided clients treat 400 as "restart pagination".
- **C6 (env-gated historical lanes pin v2):** these lanes assert v2 tokens or feed tokens to the OLD reader.
  - `rls-g2-c-contract` :855-885 (the builder flagged it; the parent's commit 3 covers it).
  - `rls-g2-pg17-etq0` :1099-1170.
  - `rls-g2-nq1` Q07 :820-900. It still passes statically: the v2 inputs are accepted (the `valid`/`longV2` paths now issue one bounded lookup, which is not asserted against), and the refusals happen at decode time.

  No S11 lane depends on v2 emission.
- **C2/C3 carried:** nq1 N05's null-conversion 500 now comes from a ledger `groupBy`. That is the same failure class, but not verified live.

## Commands
- `git fetch /home/user/workspace/repos/backend refs/remotes/origin/cand/x42/s11de`, then diff/rg over `c8ca65f9..1ee239c0` and `aed23289..1ee239c0`: RC 0.
- `/tmp/rb/probe.ts` at 1ee239c0 (pure ts-node, no DB): RC 0.
- The round-1 focused jest (roster + entities service specs, db-guard) ran under the lock at 19:17Z on c8ca65f9: 3 suites, 195 tests, RC 0.
- The round-2 focused jest at 1ee239c0 (`scout-cursor` + roster + entities + db-guard) is queued under the lock (`/tmp/rb/jest2.log`). It had not started when I wrote this, so I claim no result. Gate evidence for round 2 is the build report's.
