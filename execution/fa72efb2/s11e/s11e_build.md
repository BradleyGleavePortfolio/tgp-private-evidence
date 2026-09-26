# S11-E build — readers resolve source tokens to families through the engine's registry

Worker: S11-D r4 / S11-E subagent, parent fa72efb2. Grant: `s11e/S11E_BUILD_GRANT.md`. Rules: `execution/fa72efb2/WORKER_RULES.md`. Date: 2026-09-26 (UTC 20:xx–21:06).

Clone: `/home/user/workspace/worktrees/fa72-s11d2`, branch `fa72/s11d-r2`, built on `913811fd` (S11-D r4).

## Heads / trees

| | commit | tree | parent | author / committer |
|---|---|---|---|---|
| (1) src | `da095ee560471632ac6fdfda0c9d39e31f9dc354` | `008b56b9b8a3aa15f3518a91ce7aea6ed4bd5479` | `913811fdd37016e13ed4e01ddaed7678982641fc` | Bradley Gleave <bradley@bradleytgpcoaching.com> (both) |
| (2) spec pin | `66fca8edee31a304f38d059d04e88cdd364852c4` (HEAD) | `31b49f1722df1e8e2a418f4915a89088f073f947` | `da095ee5…` | Bradley Gleave <bradley@bradleytgpcoaching.com> (both) |

Both commits went through lefthook pre-commit (banned-cast-tokens, eslint, prettier, tsc, prod-readiness-quick) and commit-msg (no-ai-tokens): all ✔️. No `--no-verify`, no amend, no push, no trailers (a `git log -3 | rg -i "co-authored|generated|claude|anthropic"` hits only the word "regenerated" in commit 1's body, describing the contract regeneration; the hook's `generated with` pattern does not match it). Working tree clean after (2). No PostgreSQL, no harness/prisma edits, no npm install / prisma generate.

## Design

**One pure module** `src/scout/scout-family-scope.ts` (124 lines, blob `fe0f7d2b3fae`):

- `TokenGroup {source_platform, entity_type, _count:{_all}}`, `FamilyPair`, `FamilyScope {pairs, staged, unclassified}` (L31–47).
- `classifyFamilyScope(sourceMappers, family, stagedGroups, ledgerGroups=[])` (L70–96): for every staged `(platform, token)` group calls `resolveFamily` from `src/scout/reconciliation/facts.service.ts:264-275` — the S10-C ONE classifier (step token → family via the spec's `steps`; legacy token == family if the spec declares that family; else `null`). `null` → `unclassified += count`; `=== family` → `staged += count`, pair added; other family → skipped. Ledger groups contribute pairs only (a ledger row whose staged twin is gone is still attributed), never counts. Pairs are sorted by (platform, token) so the predicate is deterministic.
- `inFamilyScope(scope,row)` (L99), `familyScopeWhere(coachId,intentId,scope)` → `{coach_id, intent_id, OR: pairs}` (L110; throws on an empty scope so it can never widen to "all rows").
- No platform slug or token literal anywhere in src (`rg "s10_unseen|s11_second|trainerize"` over the six changed src files: 0 hits; per-commit blob scan below).

**Roster reader** `src/scout/scout-roster.service.ts` (blob `ffb3e8662615`): `private readonly sourceMappers = buildSourceMapperRegistry()` (L62) — the same builder and the same default (repository data-only specs) the engine uses at `scout-reconstruct.service.ts:71`. Inside the existing RepeatableRead transaction, after the settled-intent gate: `scoutIngestEntity.groupBy(by:['source_platform','entity_type'], where:{coach_id,intent_id}, _count)` (L111) + `scoutReconstructionLedger.groupBy(by:['status','source_platform','entity_type'], …)` (L116) → `classifyFamilyScope(..., RECONSTRUCT_ENTITY_TYPE, …)` (L121); reconstructed/skipped/failed are summed from the in-scope ledger groups (L129). Empty scope (L137): a legacy cursor (no `p`) → `BadRequest('malformed cursor')` exactly as its lookup would fail; otherwise the truthful empty page with no ledger findMany. Page read: `{...familyScopeWhere, status:'reconstructed', AND:[scoutCursorWhere(position)]}` (L162; the cursor continuation is AND-ed because the scope already owns the `OR`). Accounting `{staged: scope.staged, reconstructed, skipped, failed, unclassified: scope.unclassified}` (L210). The old `count({where})` and status-only `groupBy` are removed (two aggregates replace two aggregates; no N+1; no per-pair query).

**Entities reader** `src/scout/scout-entities.service.ts` (blob `10ac524d7026`): same pattern with the requested `family` (L93 registry, L145/150 aggregates, L154 classify, L160 empty scope, L166 where, L185 page AND, L225 `unclassified_staged`). The canonical-row join `entity_type: family` in `materialize` is unchanged — `ScoutReconstructedEntity.entity_type` IS the canonical family (`families.ts:127,134`), only the staged/ledger tables carry the source token.

**Engine ledger identity unchanged**: `scout-reconstruct.service.ts` untouched (ledgerType :445, writeLedger :576–582). S9 joins are unaffected.

**DTOs (additive, required numbers)**: `scout-roster.dto.ts:128` `ScoutRosterAccountingDto.unclassified` (+ `staged` description now says "classified to the roster (clients) family by the source's own step token"); `scout-entities.dto.ts:237` `ScoutEntitiesResult.unclassified_staged`. Rationale for a new field rather than reuse: the grant forbids a silent zero when staged rows exist that the reader cannot classify; no existing field can carry that without lying (`staged` must stay the roster count for the J19 leg-B invariant `staged === rosterIds.size`; `page_count` is the page). Reusing `failed`/`skipped` would invent server behaviour. `unclassified` counts STAGED rows only.

**Cursor** `src/scout/scout-cursor.ts:112`: `resolveScoutCursor`'s `scope` type widened to `Prisma.ScoutReconstructionLedgerWhereInput & {coach_id; intent_id; status}` so the pair predicate flows through the Q1 legacy-boundary lookup unchanged in behaviour.

**Contract** `docs/contracts/importer-openapi.json` regenerated with `npm run contract:importer` twice — byte-stable (sha256 `be1ba1b2…d405` both runs), prettier --check OK; diff is exactly the two new properties + required entries + the reworded `staged` description.

## Tests (unit, all live in commit 1)

- `test/scout/roster/scout-roster.service.spec.ts` (1215 lines, blob `4ef73fe8fb55`, +393/−61): fake Prisma gains `scoutIngestEntity.groupBy` / `scoutReconstructionLedger.groupBy` with real distinct-group semantics and a generic predicate matcher (equality, `gt`/`in`, nested `AND`/`OR`); `groupReads` observability; `seed({platform, token, prefix, …})`. Existing assertions updated only where the where-shape changed (scope `OR: [{source_platform:'truecoach', entity_type:'clients'}]`, cursor under `where.AND`), `unclassified: 0` added to `toEqual` accountings, tie-test extra platforms → registered conformance specs, the former "Not-Canonical" platform test rewritten as "a ledger row whose platform no spec registers is never paged or anchored" with `unclassified: 1`. New `describe('ScoutRosterService S11-E registry-scoped family selection')` (L982–): token-mapped source (`conformance_alpha`/`members`) read as the roster with `staged === reconstructed+skipped+failed` and no `entity_type:'clients'` literal in any ledger read; legacy + mapped merged in one deterministic (source_id, platform) order across pages; other-family (`routines`) rows excluded from every count; unregistered platform + unmapped token → `unclassified: 3`, never served even with a corrupt reconstructed ledger row + Person; empty-scope: legacy cursor 400, v2 cursor empty page, no ledger findMany; boundedness: exactly two tenant-scoped aggregates + one `limit+1` read at 687 rows. 38/38.
- `test/scout/entities/scout-entities.service.spec.ts` (1674 lines, blob `9721d9b5c990`, +362/−52): same fake rework; the two fixtures that modelled "a second platform" as the unregistered slug `trainerize` now use `conformance_beta` (legacy token == family); the tie test uses `conformance_beta`/`conformance_alpha`; F03's `programs` fixture is placed on the platform whose spec declares `programs`, resolved FROM the registry (`PROGRAMS_PLATFORM`, no slug typed — fails loudly if none). New `describe('ScoutEntitiesService S11-E …')` (L1468–): token-mapped `routines`→`workouts`; merged order + pairs; other-family exclusion incl. `programs`-token-on-conformance_beta classifying to `workouts` (step wins over literal, exactly as the engine plans); `unclassified_staged: 2`; empty scope + cursors; boundedness. 59/59.
- Fixtures: `scout-entities.contract.spec.ts` (`unclassified_staged` in the exact props list + `unclassified_staged: 0` in fixtures), `scout-entities.controller.spec.ts`, `scout-roster.controller.spec.ts` (`unclassified: 0`), `test/contracts/importer-contract.spec.ts:347` exact `ScoutEntitiesResult` props list + `unclassified_staged`.

## LOC (commit 1, `git diff --numstat 913811fd da095ee5`)

- prod (`src/`): **+265 / −32** across 6 files (`scout-family-scope.ts` +124 new; roster service +60/−21; entities service +44/−9; roster dto +22/−1; entities dto +10; cursor +5/−1).
- test: **+773 / −117** across 6 files. Contract JSON +15/−3. Total 13 files, +1053/−152.
- Commit 2: `test/scout/s11/journey-full.pg.spec.ts` +29/−12 (blob `7ee0be00b122`, 667 lines).

## Commit (2): J20 pin + range close

`test/scout/s11/journey-full.pg.spec.ts`: `SLICE_COMMITS` gains `da095ee5…` (L521, comment `// S11-E (readers resolve source tokens through the registry)`); new literal `const S11_RANGE_END = 'da095ee560471632ac6fdfda0c9d39e31f9dc354'` (L527) with the closing-range comment; the pins case iterates `[...SLICE_COMMITS, S11_RANGE_END]` and ancestor-checks each against HEAD (L548–550); the full-range walk uses `rev-list 3db615c0^..S11_RANGE_END` (L558–566). Precedent followed: `s8d1/journey-full_leg-b_j20_required-changes.r3.patch`, J20 part only — none of its leg-B changes were taken. Leg A and leg B J19 assertions are byte-identical to 913811fd (no `accounting.unclassified` assertion added — see risk 1 for why adding one now would pin a harness gap as expected behaviour).

Local simulation of the J20 git-only checks (no PG): `S11_RANGE_END` is an ancestor of HEAD; every src-touching commit in `3db615c0^..da095ee5` (7fdcbc04, 144269d1, 645fb6db, dda794d7, da095ee5) is pinned — none missing; slug scan (`rg "s10_unseen|s11_second"`) over each pinned commit's own changed `src/**/*.ts` full blobs: 0 hits for all 8 pins including da095ee5.

## Expected S11-lane effect (live PG, parent-run)

- `journey-full.pg.spec.ts` **leg B** (:436–453): `accounting.staged` now counts the `(s10_unseen, u10-members)` pair → 2 === `rosterIds.size`; persons = the two `u10-members` identities (previously the S11-D r4 finding: 0 vs 2). Expected to PASS. `accounting.unclassified` will be > 0 there (= the second source's staged row count; see risk 1) but is not asserted.
- **leg A** (:341–347): `persons []`, `staged 0` still hold (u10-routines/u10-sessions classify to `workouts`, not the roster; the second source's rows are unclassified, not roster). PASS.
- **J20**: pins/ancestors, full-range walk to `S11_RANGE_END`, per-commit slug rule and the core-diff gate — expected PASS (simulated above for the git parts); later slices on top no longer break the walk.
- `journey-core.pg.spec.ts` J02 (:263–273): roster/entities equality P1 == P2 and `intent_id`/`family` match — PASS, but the roster/entities content on the core lane is now honest-empty with non-zero `unclassified` (risk 1).
- Unit lane: `test/scout` + `test/contracts/importer-contract.spec.ts` + `test/utils/g2-s11-db-guard.spec.ts`: 71 suites / 1880 tests → all pass after the last fixture fix (see commands).

## Commands (all heavy ones under `flock -w 3600 …/test-validation.lock`, PROOF_SLOT_FREE present at each launch, `NODE_OPTIONS=--max-old-space-size=3072`, `--runInBand`)

1. prettier --write (touched files) — RC 0 (several times during authoring).
2. jest roster spec (first run) — RC 1 (3 TS errors in the fake's `Row` typing) → fixed → RC 0, 38/38.
3. jest entities spec — RC 1 (target-id collision across platforms in `seed`; F03 `programs` on truecoach unclassifiable) → fixed → RC 0, 59/59 (`/tmp/s11e_jest_entities2.log`).
4. `/tmp/s11e_gates1.sh` (`/tmp/s11e_gates1.log`): `npm run contract:importer` ×2 RC 0/0, sha256 identical; `prettier --check` (13 files) RC 0; `eslint --no-warn-ignored --max-warnings 0` (12 ts files) RC 0; `tsc --noEmit` RC 0; `jest test/scout test/contracts/importer-contract.spec.ts test/utils/g2-s11-db-guard.spec.ts` RC 1 — 1 failure: `scout-entities.contract.spec.ts:138` exact props list (missed fixture) → fixed.
5. `/tmp/s11e_gates2.sh` (`/tmp/s11e_gates2.log`): eslint RC 0; `jest test/scout/entities test/scout/roster test/contracts/importer-contract.spec.ts` RC 0 (9 suites, 219 passed, 5 skipped).
6. Commit 1 (`/tmp/s11e_commit1.sh`, `/tmp/s11e_commit1.log`): `git commit -F /tmp/s11e_commit1_msg.txt` with GIT_AUTHOR_*/GIT_COMMITTER_* = Bradley — lefthook all ✔️, COMMIT_RC=0 → `da095ee5`.
7. Slug rule on commit 1: 6 changed src ts blobs, 0 hits.
8. Commit 2 (`/tmp/s11e_commit2.sh`, `/tmp/s11e_commit2.log`): eslint journey-full RC 0; `jest test/utils/g2-s11-db-guard.spec.ts test/scout/scout-cursor.spec.ts` RC 0 (114/114); `git commit -F /tmp/s11e_commit2_msg.txt` lefthook ✔️, COMMIT_RC=0 → `66fca8ed`.
9. One earlier jest launch was killed by the tool's 630 s ceiling while queued behind another worker's lock (S12-B2 tsc); relaunched with `nohup setsid`. One `nohup` launch of gates1 silently did not start (no log created); relaunched successfully. Neither produced partial state.

## Risks / findings

1. **CLASS B (harness, not src) — the S11 worker builds the reader services without the injected registry.** `test/utils/g2-s11-worker.cjs:410,418` do `new ScoutRosterService(prisma, analytics)` / `new ScoutEntitiesService(...)` and never assign `sourceMappers`, while the engine gets `reconstruct.sourceMappers = sourceMappers` (:314/:329) composed from the injected A1 spec (`s11-proof`) or A2 packages (`s11_second`). CONCRETE HARM: on the S11 lane the readers classify the injected platforms' rows as unclassified (honest from the repository registry, but divergent from the engine that ran); journey-core roster/entities read empty pages with `unclassified > 0`, and leg B's `accounting.unclassified` equals the second source's staged count. No current S11 assertion breaks (leg B asserts `staged`/persons only; core asserts equality/ids). EXACT DECISION BLOCKED: whether the S11 harness should mirror the engine injection for the readers. MINIMUM CLOSURE (parent-owned, harness only, ~2 lines): after constructing each reader in the worker, assign `.sourceMappers = reconstruct.sourceMappers` (same CJS pattern already used for the engine; the readers hold the registry as an instance field for exactly this reason, mirroring `scout-reconstruct.service.ts:71`). The guard spec uses `toContain` on the worker text, so an added line does not break it. EXECUTION UNLOCKED: with that, S11-lane roster/entities reads become byte-equal to the engine's classification and leg B could gain `expect(roster.result.accounting.unclassified).toBe(0)`. I did not add that assertion now because it would fail against the un-injected worker.
2. **Product-side `programs` family**: no repository spec maps a step to `programs`; only `s10_unseen` declares it as a family (legacy convention). A truecoach `programs` token is therefore unclassified under the registry — the old F03 fixture modelled a row the engine could never have written. Fixed in the spec by resolving the platform from the registry; flagging in case the parent considers `programs`-on-truecoach an intended shape (it is not per `truecoach.json`).
3. **Merge overlap**: S8-D1 worktree (`fa72-s8d1`, HEAD 03b574e4) also patches journey-full J20 (`S11_RANGE_END = aed23289`) and roster reader territory. Landing both requires rebasing one; the J20 literal must end up as `da095ee5` (the S11-E commit is the last S11 src commit), not `aed23289`, or the full-range walk will flag da095ee5 as unpinned/out of range.
4. `test/rls-g2-ledger-expand.spec.ts` (env-gated) seeds unregistered platforms `unknown`/`other`; reviewed, its assertions (`has_more`, `entities.length 1`) remain consistent because the served rows are truecoach. Not run (G2 env not present).
5. `unclassified` semantics: counts staged rows only; ledger-only rows of an unclassifiable pair are neither served nor counted (they have no staged twin to count). Documented in the DTO description.
