# S8-D2 handoff status (builder claude_fable_5, T4)

- Repo: BradleyGleavePortfolio/growth-project-backend. Branch (local): `x42/s8d2` in `/home/user/workspace/worktrees/x42-s8d2`.
- Base: `419a756da4e6eebc28e22b19d0c08d72549f6d4e` (origin/cand/x42/s12b1-on-s8d1).
- Pushed head: `refs/heads/cand/x42/s8d2` = `854fc456653eb3e6896fca85c5a897af1c73daf0` (tree `f47fd05f…`), verified with `git ls-remote`. Working tree clean; no WIP, no patch needed.
- Full report: `execution/42d8c5b5/s8d2/BUILD.md` (+ `gates.log`, `gates2.log`, `gates3.log` beside it).

## DONE and verified (locally, no PostgreSQL)
- `GET /api/coach/clients/imported` (sibling of `/coach/clients`): coach's Persons with state ∉ {Claimed, Deleted}, Suspended shown; row `{person_id, display_name, state, source_platform, joined:false, invite:null, proposal:null, suggestions[]}`; envelope with fixed label "imported, not yet joined" and bounded cursor page (take 1..50, default 20); bearer id is the only tenant key.
- Markers null via `src/coach/person-link-markers.ts` (PersonLink/PersonInvite/PersonLinkProposal absent, never fabricated). `/coach/clients` rows gain `person_link: null`.
- Suggestions: same-coach non-archived students, exact normalised-name equality, read-only, ≤5/Person.
- `ROSTER_BRIDGE_PENDING = false` (field kept); S9 facts emit no qualifier; vocabulary untouched.
- Contract: route added to `IMPORTER_BARE_PATHS`; `docs/contracts/importer-openapi.json` regenerated x2 byte-identical; contract pins added.
- Gates RC 0: prettier 3.9.9, eslint, tsc, contract regen x2, jest batches A–G (test/coach*, roles-enforced, g2-s11 guard, test/contracts, test/scout/**, src/scout), lefthook pre-commit/commit-msg. Commit identity Bradley Gleave, no AI trailer.

## NOT done
- PG lanes (parent/GH proof only): `test/scout/s11/journey-full.pg.spec.ts` (J19 leg B now `qualifiers: []`, `roster_bridge_pending: false`), `test/scout/s10/s10-unseen.pg.spec.ts` case (h), `test/rls-g2-s8f.spec.ts` F10, `test/rls-g2-s9c.spec.ts` — edited by reading, not run.
- No RLS/tenant probe for the new route (recommended: two coaches, cross-coach Persons and same-named students never leak).
- Independent T4 review not yet done.

## Open review points (derivations for the acceptor to accept or reverse)
1. Sibling ROUTE, not a sibling field (both coach rosters are bare `User[]`; a field would break every consumer).
2. Label emitted once per response, not per row. 3. Owner sees own coach id only. 4. Suggestions exact-match, not fuzzy.
5. `/v1/coach/me/clients` has no `person_link`. 6. Route is not behind `/api/scout` flags / S12-B1 pilot allowlist (returns `[]` until an import ran); gating would move S12-B1's pinned route inventory.

## Exact next step for a new operator
Run the GH proof lanes on `cand/x42/s8d2` (the four PG specs above) + the acceptor; then dispatch the T4 review with `s8d2/BUILD.md` as input. No code changes pending.
