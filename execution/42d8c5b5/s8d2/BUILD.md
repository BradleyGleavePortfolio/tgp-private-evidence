# S8-D2 — coach roster `imported_people[]` + markers, `roster_bridge_pending` retirement — BUILD (42d8c5b5)

Builder: T4 (worker rules `execution/42d8c5b5/WORKER_RULES.md`; grant `s8d2/GRANT.md`).
Contract: `docs/decisions/2026-09-26-s8d-person-link.md` (read from `preserve/land/s8d-doc`) §5.2 + §6 row S8-D2, §1.2 (qualifier retirement), §3.3 (suggestions L1), §2.3 (Person holds no contact column).

## Heads

| what | value |
|---|---|
| base | `419a756da4e6eebc28e22b19d0c08d72549f6d4e` (= origin/cand/x42/s12b1-on-s8d1) |
| candidate HEAD | `854fc456653eb3e6896fca85c5a897af1c73daf0` |
| candidate tree | `f47fd05fd0e7e9f5fb4420db6a8a71c156e0346a` |
| pushed | `refs/heads/cand/x42/s8d2` → `854fc456` (verified with `git ls-remote preserve`) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (both; lefthook pre-commit + commit-msg ran, no `--no-verify`) |
| clone | `/home/user/workspace/worktrees/x42-s8d2`, branch `x42/s8d2`; `origin` push disabled, `preserve` = growth-project-backend |
| commits | 1 (`feat(coach): S8-D2 imported-people roster collection, link markers, roster_bridge_pending retired`) |

## Design

**Coach roster (§5.2).** `GET /api/coach/clients/imported` (new, `CoachController.getImportedPeople`, `@Roles('coach','owner')`,
declared before `clients/:id/*`) → `ImportedPeopleService.list(coachId, cursor?, take?)`:

- `person.findMany({ where: { coach_id: <bearer id>, state: { notIn: [Claimed, Deleted] } }, select: {id, display_name, state,
  source_platform}, orderBy: [created_at desc, id asc], take: limit+1, cursor })` — Suspended is listed with its state.
- Row = `{person_id, display_name, state, source_platform, joined: false, invite: null, proposal: null, suggestions: []|[...]}`
  (exactly the §5.2 shape). Envelope = `{imported_people[], label: 'imported, not yet joined', page: {limit, next_cursor, has_more}}`.
- Markers (`src/coach/person-link-markers.ts`): `personLinkMarker`, `inviteMarker`, `proposalMarker` return `null`;
  `PERSON_LINK_BACKING_TABLES = {PersonLink:false, PersonInvite:false, PersonLinkProposal:false}` records why (no such model in
  `prisma/schema.prisma`). Nothing derives a marker from `state`, a name match or any proxy. D3/D4a/D4b/D5/D6 replace these three functions.
- Suggestions (§3.3 L1): same-coach `User` rows with `role = student`, `archived_at = null`, `name IN (<page's trimmed display names>)
  case-insensitive`, then `normaliseName` (trim, collapse whitespace, case-fold) equality in memory; ≤ 5 per Person, id order; one
  bounded read per page; never persisted, never applied (the fake in the spec exposes `findMany` only).
- `GET /api/coach/clients` rows gain `person_link: null` (additive; array shape unchanged) via `personLinkMarker(row.id)`.
- Pagination mirrors `/coach/clients` (`take` 1..50, default 20; cursor = last row's Person id). Query DTO validated by the global
  `ValidationPipe` (`cursor` ≤ 64 chars, `take` int 1..50).

**Importer-G roster.** `ROSTER_BRIDGE_PENDING = false as const` (`scout-roster.dto.ts`); field kept in `ScoutRosterResult` (retirement waits
for mobile); DTO/controller descriptions rewritten. **S9 facts:** `FAMILY_QUALIFIERS = {}` in `facts.service.ts` — no family emits
`roster_bridge_pending` any more; the vocabulary (`FamilyQualifier`, `lifecycle/reason-codes.ts FAMILY_QUALIFIERS`, contract enum) is
append-only and untouched, so historical basis rows still parse.

**Contract.** `/coach/clients/imported` added to `IMPORTER_BARE_PATHS`; `docs/contracts/importer-openapi.json` regenerated through
`scripts/export-importer-contract.ts` (x2, byte-identical — see gates). `CONTRACT_VERSION` unchanged (additive; S8-F/S9-C/S10-C2 precedent).

**Not gated by `/api/scout` flags / pilot allowlist.** The route renders server state only: with the importer dark no Person exists for
any coach and the response is `[]`. Adding it to `FEATURE_GATED_ROUTES` would move S12-B1's statically pinned route inventory — out of grant.

## Privacy review of every emitted field

| surface | field | source | tenant scope | note |
|---|---|---|---|---|
| `/coach/clients/imported` | `person_id` | `Person.id` (uuid) | `coach_id = bearer` | opaque server id |
| | `display_name` | `Person.display_name` | same | imported PII the coach imported; null stays null |
| | `state` | `Person.state` | same | never Claimed/Deleted (filtered in SQL) |
| | `source_platform` | `Person.source_platform` | same | slug only; **`source_person_id` is NOT emitted** |
| | `joined` | constant `false` | — | |
| | `invite`, `proposal` | resolver → `null` | — | tables absent; never fabricated |
| | `suggestions[].user_id`, `.display_name` | `User.id`, `User.name` | `User.coach_id = bearer`, `role = student`, `archived_at null` | rows the coach already sees in `/coach/clients`; **no email** |
| | `label` | constant | — | fixed copy |
| | `page.next_cursor` | last `Person.id` | — | opaque |
| `/coach/clients` rows | `person_link` | resolver → `null` | (existing row scope) | additive |
| `/scout/reconstruct/roster` | `roster_bridge_pending` | constant `false` | — | no new field |

Not emitted anywhere: `coach_id`, `source_person_id`, `created_at`/`updated_at` of Person, any email/phone/contact (Person has no such
column, §2.3), any User email. Cross-coach: both reads key on the bearer id; an `owner` or sub-coach caller sees Persons of their OWN
coach id only (no platform-wide read — deliberate, see deviations). No PostgreSQL RLS proof here (parent lane).

## Files

Production (`git diff --numstat 419a756d HEAD -- src scripts` = **+573 / −52**; 11 files; grant ceiling 1,000; §6 estimate 250–400 — the
overrun is DTO/OpenAPI documentation, not logic):

| file | Δ | change |
|---|---|---|
| `src/coach/imported-people.dto.ts` (new) | +221 | DTOs + constants (`IMPORTED_PEOPLE_LABEL`, page sizes, hidden states), OpenAPI descriptions |
| `src/coach/imported-people.service.ts` (new) | +151 | reader (above), `normaliseName`, `clampLimit` |
| `src/coach/person-link-markers.ts` (new) | +48 | three null resolvers + `PERSON_LINK_BACKING_TABLES` |
| `src/coach/coach.controller.ts` | +86/−12 | `GET clients/imported` handler + doctrine comment (prettier reflowed 3 unrelated lines) |
| `src/coach/coach.service.ts` | +25/−9 | `getClients` rows → `person_link: null` (prettier reflowed the archive/unarchive signatures) |
| `src/coach/coach.module.ts` | +6/−11 | provider (prettier collapsed the imports array) |
| `src/scout/scout-roster.dto.ts` | +14/−10 | `ROSTER_BRIDGE_PENDING = false as const`; description |
| `src/scout/scout-roster.service.ts`, `scout-roster.controller.ts` | +8/−6 | comments / description |
| `src/scout/reconciliation/facts.service.ts` | +9/−4 | `FAMILY_QUALIFIERS = {}` |
| `scripts/importer-contract.ts` | +5 | `/coach/clients/imported` |

Generated: `docs/contracts/importer-openapi.json` (regen x2 identical).

Tests (`git diff --numstat 419a756d HEAD -- test` = **+706 / −74**):

| file | change |
|---|---|
| `test/coach/imported-people.service.spec.ts` (new, 18 `it`) | tenant scope + state filter (Claimed/Deleted hidden, Suspended shown, other coach absent); exact select + exact row/envelope keys; no `source_person_id`/`email`/`@` in JSON; null display_name → no student read; markers null on every state; suggestions (normalised match; archived/other-coach/non-student/near-miss excluded; exact `user.findMany` args; cap + shared student; read-only fake); `normaliseName`; pagination (default/cap/bad take, 7 rows over 3 pages walked once, cursor/skip/take args, empty page); query DTO validation; controller `@Roles` + path + delegation; `getClients` `person_link: null` |
| `test/contracts/importer-contract.spec.ts` | +1 describe (S8-D2): GET only, params exactly `cursor`/`take` with bounds, 200/400/401/403; `ImportedPeopleResult`/`ImportedPersonDto`/marker/suggestion property sets; nullable markers; no `email`/`phone`/`source_person_id` in the schemas; `ScoutRosterResult` shape kept and `roster_bridge_pending` example `false` |
| `test/scout/roster/scout-roster.service.spec.ts`, `scout-roster.controller.spec.ts` | `true` → `false` (7 asserts + fixture) |
| `test/coach-ptm-risk-board.spec.ts` | 4th constructor stub for `CoachController` (prettier 3.9.9 also reflowed pre-existing lines) |
| `test/scout/reconciliation/facts.service.spec.ts` | clients `qualifiers` → `[]` (3) |
| `test/scout/s11/journey-full.pg.spec.ts` (PG, parent) | J19 leg B: clients cell `qualifiers: []`, roster `roster_bridge_pending` `false`; header/it-name comments. `S11_RANGE_END` untouched (`ce37c6ee`) |
| `test/scout/s10/s10-unseen.pg.spec.ts` (PG, parent) | case (h) `qualifiers: []`; header |
| `test/rls-g2-s8f.spec.ts`, `test/rls-g2-s9c.spec.ts` (PG, parent) | F10 `false`; S9-C clients `qualifiers: []` |

Untouched on purpose: `lifecycle.service.spec.ts` (vocabulary `FAMILY_QUALIFIERS` still `['roster_bridge_pending']`), `reconcile.spec.ts` /
`scout.service.spec.ts` (fixture pass-through of the token), contract enum pin (`qualifiers.items.enum`).

## Gates (clone; heavy ones under `flock -w 7200 /home/user/workspace/execution/test-validation.lock`, inode 657581)

Three lock acquisitions (the slot was held ~50 min by parent PG lanes in between); logs copied beside this file (`gates.log`, `gates2.log`, `gates3.log`).

| gate | command | RC |
|---|---|---|
| prettier 3.9.9 | `prettier --check <22 touched .ts + importer-openapi.json>` | 0 (run 2; run 1 also 0) |
| eslint | `npx eslint --no-warn-ignored --max-warnings 0 <touched .ts>` | 0 (run 2; run 1 = 1: one unused import, fixed) |
| tsc | `npx tsc --noEmit` | 0 (run 2; run 1 = 2: `coach-ptm-risk-board.spec.ts` needed the 4th constructor arg, fixed) |
| contract regen #1 | `npx ts-node scripts/export-importer-contract.ts` → 18 paths, 50 schemas | 0, sha256 `44aed422…4a71f8` |
| contract regen #2 | same | 0, sha256 identical (`44aed422…4a71f8`; same bytes committed) |
| jest A | `test/coach` + `coach.service.sub-coach-scope` + `coach-timeline` + `coach-ptm-risk-board` + `roles-enforced` + `utils/g2-s11-db-guard` | run 2: 1 failed (my fixture: inner-whitespace name is narrowed out by the DB pre-filter — fixture corrected, narrowing now asserted) → run 3 `test/coach/imported-people.service.spec.ts` + `coach-ptm-risk-board.spec.ts`: **29 passed**, RC 0 |
| jest B | `test/contracts` (incl. drift check + cross-process determinism of the committed artifact) | 0 — 116 passed |
| jest C | `test/scout/roster` `test/scout/reconciliation` `test/scout/lifecycle` `src/scout` | 0 — 502 passed |
| jest D | `test/scout/reconstruct` | 0 — 326 passed |
| jest E | `test/scout/induction` `orchestration` `s10` `s11` `entities` (PG files `describe.skip` without a DB: 6 suites / 47 tests skipped) | 0 — 363 passed |
| jest F | `test/scout/*.spec.ts` | 0 — 714 passed |
| jest G | `test/coach-*.spec.ts`, `test/coach.*.spec.ts` | 0 — 346 passed, 5 todo |
| lefthook pre-commit (commit) | banned-cast-tokens (R75), prettier, eslint, tsc, prod-readiness-quick; commit-msg no-ai-tokens | all ✔️ (tsc 103.9 s) |

Run 1's single `jest --runInBand` over everything OOM'd at the 3 GB heap after 50 PASS (RC 134) — a harness limit, not a test failure; the batches above are the same set split. Everything under the flock; `NODE_OPTIONS=--max-old-space-size=3072`, `--runInBand`. No PostgreSQL run here.


## PG lanes the parent must run (no PostgreSQL in this build)

1. `test/scout/s11/journey-full.pg.spec.ts` (J19 leg B now asserts `qualifiers: []` and `roster_bridge_pending: false`; J20 unchanged).
2. `test/scout/s10/s10-unseen.pg.spec.ts` case (h) (`qualifiers: []`).
3. `test/rls-g2-s8f.spec.ts` F10 (`roster_bridge_pending: false`) and `test/rls-g2-s9c.spec.ts` (clients `qualifiers: []`).
4. Recommended new RLS/tenant probe (not written here — no lane): two coaches, Persons for each, `GET /api/coach/clients/imported` as
   coach A lists only A's Persons; a same-named student of coach B never appears in A's `suggestions`; Suspended listed, Claimed/Deleted not.

## Deviations from the literal §5.2 text (derived, for parent acceptance)

1. **Sibling route, not a sibling field.** §5.2 says the "coach roster response gains a sibling collection"; both coach rosters
   (`GET /coach/clients`, `GET /v1/coach/me/clients`) return a bare `User[]`, so a sibling field would force an array→envelope break for
   every existing consumer — the opposite of §5.2's own rationale ("no existing consumer sees a non-User row"). Implemented as
   `GET /coach/clients/imported` beside `GET /coach/clients`; mobile UX-D2 makes two calls.
2. **`label` at envelope level.** §5.2 fixes the copy but lists no row field for it; emitted once per response, not per row.
3. **Owner sees own coach id only** (unlike `getClients`, where owner is platform-wide). Least privilege on PII; one-line change if the owner wants parity.
4. **Suggestions = exact normalised-name equality**, not fuzzy "similarity". Deterministic, no threshold to own; widening is a product choice.
5. **`/v1/coach/me/clients` gets no `person_link` marker** (not the reader §5.2 names). Follow-up when D5 gives the marker real semantics.
6. Route added to the importer contract (`IMPORTER_BARE_PATHS`) so UX-D2 has a typed shape; `CONTRACT_VERSION` not bumped (additive precedent).

## Risks

- **A (low):** the new route is reachable in production without a scout flag; it returns `[]` until the importer has run for that coach,
  and emits only what the coach imported. HARM if a Person row ever exists for a coach who did not import: the row is visible. BLOCKED:
  nothing today (no writer other than the flagged reconstruct path). CLOSURE: none needed; parent may prefer gating — that touches the
  S12-B1 pinned inventory (T2 pin move).
- **B (low):** suggestions rely on `User.name` equality; the spec's fake mirrors Prisma `mode: 'insensitive'` + `in` semantics rather than
  running SQL. PG lane 4 above closes it.
- **B:** the four PG specs changed here are asserted by reading, not by running (parent-only lanes).
- **C:** prettier 3.9.9 reflowed a few pre-existing lines in `coach.controller.ts` / `coach.service.ts` / `coach.module.ts` (hook requires
  `--check` on staged files); no semantic change.

## Owner product questions

None blocking; nothing in §7.2 gates D2. Items 1, 3 and 4 above are derivations the parent can reverse.
