# S11-DE rebuild (T4) — BUILD report

Clone: `/home/user/workspace/worktrees/x42-s11de` (branch `x42/s11de`, `git clone --no-hardlinks` of `/home/user/workspace/repos/backend`; origin push-url disabled; remote `preserve` = GitHub). Base `aed23289` (origin/land/s11d, S11-D r3). Identity author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, lefthook pre-commit + commit-msg ran on both commits, no trailers, no amend. Working tree clean after commit 2. No PostgreSQL used. Evidence repo not committed.

## Commits (both on `refs/heads/cand/x42/s11de`; pushed after each commit)

| # | head | tree | subject | LOC |
|---|------|------|---------|-----|
| 1 | `238ecc15554ff3fa337dcdebe982a778348ddad1` | `bed5551c5254039dfdf0a7e032a64e335dc1a001` | feat(scout): roster and entities readers resolve source tokens through the registry (S11-E) | prod (src) +302/−33; docs (contract) +15/−3; test +781/−93 |
| 2 | `c8ca65f95efd5126e2e5c86e8ffd61e551e78a6c` | `f17baf621f5fb4a772e28782cdac6ae015a10a7e` | test(scout): S11-D round 4 — leg A readiness read, worker registry seam, J20 range end (S11-E) | test +52/−15; prod 0 |

Pushed cand ref: `refs/heads/cand/x42/s11de` = `c8ca65f95efd5126e2e5c86e8ffd61e551e78a6c` (ls-remote confirmed; first push `238ecc15`, second `238ecc15..c8ca65f9`). Prod LOC 302 < 1,000 cap.

## Commit 1 — design (file:line at 238ecc15)

- `src/scout/scout-family-scope.ts` (new, 140 lines, pure): `classifyFamilyScope(sourceMappers, family, stagedGroups, ledgerGroups)` :74 — every staged `(source_platform, entity_type)` group is classified by `resolveFamily` (`src/scout/reconciliation/facts.service.ts:264-275`, the S10-C one classifier: step token → declared family, else legacy token == declared family, else null). `null` → `unclassified += count`; `=== family` → `staged += count` and the pair joins the scope; ledger groups contribute pairs only (so a ledger pair whose staged twin is gone stays readable). `familyScopeWhere(coachId, intentId, scope)` :124 → `{coach_id, intent_id, OR: pairs}` (pairs sorted by platform, token — deterministic SQL); `inFamilyScope` :106.
- `src/scout/scout-roster.service.ts`: `private readonly sourceMappers = buildSourceMapperRegistry()` :63 (same factory as `scout-reconstruct.service.ts:71`; instance field so the worker can hand in the composed registry). Inside the RepeatableRead tx after the settle gate: two bounded tenant-scoped aggregates `scoutIngestEntity.groupBy(by:[source_platform, entity_type])` :120 and `scoutReconstructionLedger.groupBy(by:[status, source_platform, entity_type])` :125 replace the old `count` + status `groupBy`; byStatus is summed from in-scope ledger groups :138; empty scope → legacy cursor 400 `malformed cursor` :147 (as its Q1 lookup would have), v2/none → truthful empty page with no ledger findMany; page/Q1 reads use `familyScopeWhere` :151 with `status:'reconstructed'` and the cursor continuation `AND`-ed. Accounting gains `unclassified: scope.unclassified` :219; `staged` = in-scope staged count.
- `src/scout/scout-entities.service.ts`: same pattern :156-177 (ledger groupBy by platform/token only); result gains `unclassified_staged` :237. Canonical-row join (`entity_type: family` on ScoutReconstructedEntity) unchanged — the canonical row carries the canonical family.
- `src/scout/scout-cursor.ts:8`: `resolveScoutCursor` scope type widened to accept the pair predicate (no behaviour change).
- DTOs: `ScoutRosterAccountingDto.unclassified`, `ScoutEntitiesResult.unclassified_staged` — additive required numbers; roster `staged` description now states what it counts. Controllers, analytics props, ledger identity, tenant scope (coach_id, intent_id) unchanged.
- Contract `docs/contracts/importer-openapi.json` regenerated twice under the lock: sha256 `a32f9503…9363` both runs (byte-stable); +15/−3 = the two additive properties + required lists.
- Slug/token literals in src: `rg "s10_unseen|s11_second|trainerize|conformance|truecoach|u10-"` over the touched src files → only pre-existing DTO `example: 'truecoach'` lines (unchanged from base) and pre-existing `scout-cursor.ts:73 family === 'clients'`. No new slug or token literal; my one docblock mention of a slug was removed before commit. J20's pinned-commit blob scan (both fixture slugs) over 238ecc15's src `.ts` blobs: 0 hits (simulated locally, below).

Unit specs (commit 1): both service fakes gained `groupBy` with real distinct-group semantics (`groupRows`) and an AND/OR predicate matcher; `seed()` takes platform/token/staged. New suites `ScoutRosterService S11-E registry-scoped family selection` (7 tests) and `ScoutEntitiesService S11-E registry-scoped family selection` (8 tests): token-mapped source read as the family with no `entity_type` literal on any ledger read; legacy + mapped merged in deterministic order across pages; other family excluded from every count (entities also proves a family-NAMED step token classifies by its step); unregistered platform + unmapped token → `unclassified` 3 / `unclassified_staged` 2, never served, Persons never looked up; empty scope (legacy cursor 400, v2 cursor empty page, no findMany); boundedness (exactly two aggregates + one `limit+1` read at 687 rows). Platform/token for the mapped fixtures are resolved FROM `buildSourceMapperRegistry()` (first spec with a step → family whose token ≠ family), failing loudly if none — no slug typed. Existing fixtures moved off unregistered slugs (`trainerize`, `a/b/c-plat`) onto registered conformance specs; F03 `programs` fixture sits on the registry-resolved platform that declares `programs` (`PROGRAMS_PLATFORM`). Contract/controller fixtures gained the two fields; `test/contracts/importer-contract.spec.ts:350` props list gains `unclassified_staged`.

## Commit 2 — assertions traced

(a) `test/scout/s11/journey-full.pg.spec.ts` leg A J17: `h.pairCurrent('P2', COACH_A, intentId)` → `h.pairCurrent('P2', COACH_A)`. Path: `test/utils/g2-s11-harness.ts:322 pairCurrent = (host, coach, nonce?)` → worker `pairing.current(coach, nonce)` → `src/extension-pair/extension-pair.service.ts:192-193` (`nonce ? {setup_nonce} : {superseded_at: null}`). Passing the intent id as nonce selected a non-existent setup → 404 (PROOF_V2_FINDING). Live-passing precedent for the nonce-less terminal read: `test/scout/s11/readiness.pg.spec.ts:139-144` (R4) and leg A J01 in the same spec. Added `expect(h.persons(COACH_A)).toEqual([])` before the empty-roster reads (precedent `journey-induction.pg.spec.ts:147`, `settle-redrive.pg.spec.ts:146`; `h.persons` = harness :264 direct Person read).
(b) `test/utils/g2-s11-worker.cjs` roster/entities cases: construct the reader, `reader.sourceMappers = reconstruct.sourceMappers` (same CJS assignment as the engine seam at worker L314/L329), then read. Leg B adds `expect(roster.result.accounting.unclassified).toBe(0)` beside `accounting.staged === rosterIds.size` (the proof v2 failing line). Path: `ScoutRosterService.getRoster` → `classifyFamilyScope(this.sourceMappers, 'clients', …)`; with the composed registry the D2 roster token classifies to `clients` (`staged` counts it) and the A2 second source's tokens classify to their own families (`unclassified` 0). Guard spec (`test/utils/g2-s11-db-guard.spec.ts`) uses `toContain` rules on the worker — passes (RC 0 below).
(c) J20: `SLICE_COMMITS` gains `238ecc15…`; `const S11_RANGE_END = '238ecc15…'`; ancestor check iterates `[...SLICE_COMMITS, S11_RANGE_END]`; full-range walk uses `rev-list 3db615c0^..S11_RANGE_END`. Local simulation (plain git, cheap): all 8 pins resolve and are ancestors of HEAD; every src-touching commit in `3db615c0^..238ecc15` (7fdcbc04, 144269d1, 645fb6db, dda794d7, 238ecc15) is pinned; slug scan (`s10_unseen`, `s11_second` read from the fixtures) over pinned commits' changed src `.ts` blobs → 0 hits.

## Reader → lane table (every live pg/rls spec exercising the roster/entities readers)

| Spec | Lane | Reader use | Expected count change under 238ecc15 |
|------|------|-----------|-------------------------------------|
| `test/scout/s11/journey-full.pg.spec.ts` leg A (:337-345) | G2_S11 pg | roster on both hosts, empty | none: `persons []`, `staged 0`; `unclassified` 0 (nothing staged for COACH_A); new `h.persons` read `[]` |
| same, leg B (:431-460) | G2_S11 pg | roster P1, cross-coach P2 | `accounting.staged` 0 → `rosterIds.size` (2) — the proof v2 failure; `unclassified` 0 (worker seam); cross-coach still 404 |
| `test/scout/s11/journey-core.pg.spec.ts:95-97` | G2_S11 pg | roster/entities per host, equality across hosts | none (equality; both hosts now classify through the same composed registry) |
| `test/rls-g2-ledger-expand.spec.ts:256-262` | G2_TEST_* env-gated | roster page 1 + next, entities workouts | assertions unchanged (`has_more` true/false, 1 entity); unasserted `accounting.staged` 4 → 3 with `unclassified` 1 (the `sourcePlatform:'unknown'` staged row is unregistered) |
| `test/rls-g2-s8f.spec.ts` (F07 :233-243, F10 :266-272) | G2 s8f pg | entities page_count, roster reconstructed | none: all rows `truecoach` + legacy tokens (`workouts`/`clients`) classify |
| `test/scout/entities/scout-entities.rls.live.spec.ts` | live-db gated | RLS posture on the canonical table (no reader call) | none |

## Gates (all under `flock -w 3600 …/test-validation.lock`, `NODE_OPTIONS=--max-old-space-size=3072`, `--runInBand`)

Commit 1 (`/tmp/s11de/gates1.log`, 18:06–18:09Z): `npm run contract:importer` ×2 RC 0/0, sha256 identical; `prettier --check` (3.9.9) on all touched files RC 0 (a broader `test/**` sweep flagged 5 pre-existing untouched files — not in scope); `eslint --no-warn-ignored --max-warnings 0` on touched files RC 0 (`/tmp/s11de_jest2.log`); `tsc --noEmit` RC 0; `jest test/scout test/contracts/importer-contract.spec.ts test/utils/g2-s11-db-guard.spec.ts` RC 0 — 71 suites passed, 6 skipped (live), 1837 tests passed. Lefthook pre-commit (r75, tsc, eslint, prettier, prod-readiness-quick) + commit-msg passed, COMMIT_RC=0.
Commit 2 (`/tmp/s11de/gates2.log`): prettier RC 0, eslint RC 0, tsc RC 0, `jest test/utils/g2-s11-db-guard.spec.ts test/scout/scout-cursor.spec.ts test/scout/s11` RC 0 (2 suites 114 tests passed; 5 live suites skipped — no PostgreSQL). Lefthook passed, COMMIT_RC=0.

## Findings

A (risk, not blocking) — live proof of leg B not run here (no PostgreSQL by rule). HARM: the `staged === rosterIds.size` and `unclassified === 0` assertions are traced (worker seam → `classifyFamilyScope` → composed registry) and unit-proven on a fake with real groupBy semantics, but not observed on pg. EXACT THING BLOCKED: J19 leg B live pass. MINIMUM CLOSURE: run `journey-full.pg.spec.ts` under G2_S11_DATABASE_URL on `c8ca65f9`. STATE UNLOCKED: S11-D r4 proof v3.
B (behaviour note) — `accounting.staged` semantics narrowed from "all staged rows of the intent with token == family" to "staged rows classifying to the family"; rows of unregistered platforms move to `unclassified` (see `rls-g2-ledger-expand` row: 4 → 3 + 1). No live assertion depends on the old value; contract description updated. Product decision NOT needed (the grant mandates the additive field, never silent zero).
C (harness) — `pairCurrent` nonce-less read requires the coach's setup to be non-superseded at J17; leg A creates exactly one setup for COACH_A, matching the R4 precedent. If a future leg supersedes the setup, switch to `h.pairSession(host, coach, intentId)` (leg B :404 precedent).

## Round 2 (review A A1 + review B B1 + C items) — identity hold lifted, pushed

Clone `/home/user/workspace/worktrees/x42-s11de`, branch `x42/s11de-r2b`, on `aed23289`. Both commits author+committer Bradley Gleave, lefthook on, no trailers, no amend.

| | SHA | tree | scope |
|---|---|---|---|
| commit 1 (src + A1 fix) | `ce37c6eeb49be1d65ee7c38f86068bd92af824b0` | `ae23c357d1ac4761120473dddaa7d0ccca465ba3` | src +456/−85 (net, 7 files), docs/contract +18/−6, test +1414/−153 |
| commit 2 (tests + B1 + J20 pins) | `1ee239c09a19af8da1eb99677f320ec7576a6a5e` | `99ae5ad5b881962a44431333644ca07d4e8e8a9e` | test +71/−24 (journey-full, worker.cjs) |

`refs/heads/cand/x42/s11de` = `1ee239c0` (force-with-lease from `c8ca65f9` → `ce37c6ee` → `1ee239c0`). Patches: `execution/42d8c5b5/s11de/r2/0001-*.patch`, `0002-*.patch`. The scratch pair (`4d30cae7` / `49d2a8c7`, same trees as commit 1 / commit 2 except the J20 SHA literals) stays local on `x42/s11de-r2`, never pushed.

### A1 closure — cursor decision (src, commit 1)
- Total order in both readers: `(source_id, source_platform, entity_type)` — `scoutCursorOrder()` 3 keys; `scoutCursorWhere` 3-clause OR (2 clauses for a pair boundary).
- Emitted cursor is **v3** (`v3.` prefix, `{v:3,c,i,f,o:'source_id:asc,source_platform:asc,entity_type:asc',s,p,t}`), `t` = the ledger token, bounded to 128 (the ingest `entity_type` `@MaxLength(128)`), so four maximal identifiers still fit `SCOUT_CURSOR_MAX_LENGTH` (asserted in scout-cursor.spec).
- Pair-only **v2** tokens (minted before r2) are accepted and completed by ONE bounded lookup (`take: 2`, `where: {coach_id, intent_id, OR: pairs, status, source_id, source_platform}`): 0 rows → continue after the pair (`t: null`, no tie possible); 1 row → that row's token; **≥2 rows → 400 `malformed cursor`, fail closed, no page read** (chosen over guessing: a page boundary between tied rows cannot be resolved). Legacy source-only tokens: exactly one row (now `select {source_platform, entity_type}`) → full triple, else 400 — unchanged semantics.
- The scope predicate `{coach_id, intent_id, OR: classified pairs, status:'reconstructed'}` is on every lookup and page read (asserted per read in the new regressions).
- Regressions (both service specs): two tokens, one platform, same source ids, limit 1 across pages → 4 rows served exactly once, in key order, identical on a second walk; tie-boundary AND clause asserted; v2 ambiguous → 400 with exactly one lookup and no page/person read; v2 one-row → resolves; v2 zero-row → 2-clause continuation; legacy at a tied id → 400. Token pairs resolved from the registry (entities: the spec with two steps → workouts, i.e. the genuine `sharedIdSpaces` case; roster: mapped step + declared family literal on one platform); no slug typed.
- C items: J20 comment now names `S11_RANGE_END` (not HEAD); OpenAPI roster description lists `unclassified`; cursor DTO descriptions say "emits scoped v3".

### B1 closure (test, commit 2)
`journey-full.pg.spec.ts`: `rosterVia(host, coach, intent) = h.onInduction(host,'phone',{action:'roster',…})` replaces the four `h.rosterOf` calls (:337/:341 leg A, :431/:458 leg B). `rosterOf`/`entitiesOf` unchanged (journey-core). No harness change → no guard pin change (guard spec passes). Trace against the INDUCTION registry (defaults + s11_second): staged groups (s10_unseen,u10-members)×2 → clients; (s10_unseen,u10-routines|u10-sessions) → workouts; (s11_second,t11-blocks) → programs; (s11_second,t11-routines) → workouts ⇒ roster `staged 2`, `unclassified 0`; persons = `u10-m-1`,`u10-m-2` (`sourcePersonId = trimmedSourceId`, mapping-spec.ts:211), state InvitePending, platform s10_unseen. Leg A: staged 0, persons [] (no roster rows staged).

### Review B C2 — nq1 N05 (static, not run)
**Yes, expected to hold**, with the failure moving earlier: `test/rls-g2-nq1.spec.ts:475-477` expects 500 from the roster read on a NULL-provenance ledger row. New reader: `src/scout/scout-roster.service.ts:125-129` `scoutReconstructionLedger.groupBy({ by:['status','source_platform','entity_type'], where: tenant })` is tenant-only (not pair-filtered), so the NULL row is still touched by the N client (NOT NULL `source_platform`) before any pair predicate — same null-conversion failure class the old page read produced. Caveat: the 500 now originates in a groupBy, not a findMany; if Prisma's groupBy serializer tolerated the null, the row would fall out of every pair and the read would return 200 `{staged:1, reconstructed:0, unclassified:0}` — unverified by me; parent runs it if needed.

### Gates (all under the flock, `--runInBand`, `NODE_OPTIONS=--max-old-space-size=3072`)
Run on the round-2 working tree whose content equals the commit trees (commit 1 tree byte-identical; commit 2 tree differs only in the two SHA literals, re-pinned after the run):
- `npm run -s contract:importer` ×2: RC 0/0, sha256 `6541d3d0…433e4` both runs (byte-stable); contract diff vs base = the 2 additive properties + 3 description lines.
- prettier `--check docs/contracts/importer-openapi.json src/scout test/scout test/contracts test/utils`: RC 1 — 5 warnings, ALL pre-existing untouched files (`test/contracts/checkout-contract-gate.spec.ts`, `contract-provider.spec.ts`, `hellosign-webhook.controller.spec.ts`, `test/utils/bootstrap-test-schema.ts`, `test/utils/g2-tq0-worker.cjs`); every touched file clean (pre-commit prettier hook passed on both commits).
- eslint `--max-warnings 0` src/scout test/scout worker/guard/contract specs: RC 0. `tsc --noEmit`: RC 0 (×2, also in both pre-commit hooks).
- jest `test/scout test/contracts/importer-contract.spec.ts test/utils/g2-s11-db-guard.spec.ts`: 71 suites / 1854 passed / 46 skipped, RC 0. jest `guard + scout-cursor + test/scout/s11`: 121 passed / 32 skipped (pg lanes), RC 0.
- J20 simulated locally on `1ee239c0`: all pins + `S11_RANGE_END` ancestors; src-touching in `3db615c0^..ce37c6ee` = {ce37c6ee, dda794d7, 645fb6db, 144269d1, 7fdcbc04}, all pinned; no `s10_unseen`/`s11_second` in commit 1's src `*.ts` hunks.
- Not run: any PG lane (proof is the parent's), `rls-g2-*` lanes.

### Reader→lane table delta (r2)
- `test/rls-g2-c-contract.spec.ts:855-885`: asserts emitted tokens `toEqual([v2(...), v2(...), null])` and feeds the token to the OLD N/Q1 reader — BOTH break under v3 emission (expected equality fails; old decoder rejects `v3.`). Env-gated lane C, not in S11 scope; needs the parent's decision (update expectation to v3 / accept as historical).
- `test/rls-g2-pg17-etq0.spec.ts:1015-1080`: legacy/v2 cursor assertions against the current root; already stale vs Q1 per r1 table; unchanged status.
- `rls-g2-nq1` N05: see C2 above. `rls-g2-ledger-expand`: NULL-platform rows (count 5) unattributable to any pair — historical lane, fails at base already (review B C3).
- journey-core, rls-g2-s8f, readiness lanes: truecoach/single-platform, token == family → unchanged counts; cursors they consume are emitted by the same build (v3) so pagination round-trips.

### Findings
- A: none open from my side.
- B: `rls-g2-c-contract.spec.ts:855-885` will fail under v3 emission if that lane is ever re-run (HARM: stale lane assertion; BLOCKED: nothing in S11; MINIMUM CLOSURE: update the expected token builder to the v3 envelope or mark the lane historical; STATE UNLOCKED: lane C green).
- C: prettier debt in 5 untouched files (listed above); scratch commits `4d30cae7`/`49d2a8c7` left locally on `x42/s11de-r2` (never pushed).
