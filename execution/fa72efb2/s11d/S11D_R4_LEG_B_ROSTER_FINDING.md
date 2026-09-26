# S11-D Round 4 — leg B roster read: PRODUCT FINDING (STOP, not a spec bend) — EXEC-FA72EFB2

Raised by the T4 fixer for S11-D r4 (worktree `/home/user/workspace/worktrees/fa72-s11d2`, branch `fa72/s11d-r2`, base
`aed23289`). Proof v2 (`s11d/binding/v2/run/jest-full.log:475-490`, preserved, not edited) stopped leg B at
`journey-full.pg.spec.ts:426` — `expect(roster.result.accounting.staged).toBe(rosterIds.size)`: expected 2, received 0. The live
roster body (log line 436, process `g2g_33`) was
`{"accounting":{"staged":0,"reconstructed":0,"skipped":0,"failed":0},"persons":[],"page":{...},"roster_bridge_pending":true}`.

## Diagnosis (file:line, all at aed23289)

The IMPORTER-G roster reader and the S8-G/S10-D induction engine disagree on what `entity_type` a `clients` identity is stored under:

1. Staging keeps the SOURCE TOKEN. `ScoutIngestService.ingest` stores `entity_type: dto.entity_type`
   (`src/scout/scout-ingest.service.ts:88`); the S11 worker posts the fixture token — live: `"entity_type":"u10-members"`
   (jest-full.log:310, `g2g_24`). The token maps to family `clients` only through the spec
   (`src/scout/reconstruct/sources/s10_unseen.json:5`, `"u10-members": "clients"`).
2. The engine plans per staged `(source_platform, entity_type)` group and keeps `token: group.entity_type`
   (`src/scout/reconstruct/orchestration/family-plan.ts:88-92`), selects rows by `entity_type: source.token`
   (`src/scout/scout-reconstruct.service.ts:248-253`) and ledgers each row under
   `ledgerType = row.entity_type ?? family.entityType` (`:445`) — i.e. the ledger row's `entity_type` is `u10-members`, not
   `clients` (`writeLedger` identity `:576-582`). S9 joins staged↔ledger on that same wide identity
   (`src/scout/reconciliation/facts.service.ts:87-88`, `:414-416`), which is why D2 case (h) and leg B's own settled-basis
   assertions (`journey-full.pg.spec.ts:382-397`, PASSED live) see the two identities as `unresolved:evidence_only` with
   `observed_unique: 2`.
3. The roster reader is hard-scoped to the canonical family literal: `where = { coach_id, intent_id, entity_type:
   RECONSTRUCT_ENTITY_TYPE }` (`src/scout/scout-roster.service.ts:72-76`), `RECONSTRUCT_ENTITY_TYPE = RECONSTRUCT_FAMILY.clients =
   'clients'` (`src/scout/scout-reconstruct.dto.ts:91`). `staged = scoutIngestEntity.count({ where })` (`:109`), the ledger
   groupBy (`:110-114`) and the page read (`:119-128`) all use it; there is no token resolution and the controller exposes
   no family/token parameter (`src/scout/scout-roster.controller.ts:85-90`). The worker's `roster` action is exactly
   `getRoster(coach, intent, undefined, undefined)` (`test/utils/g2-s11-worker.cjs:409-416`).

Therefore, for ANY source whose roster token is not literally `clients` (every S10-D/S11 source: `u10-members`, and S11-A1's
`people`, `test/utils/g2-s11-harness.ts:55-56`), `GET scout/reconstruct/roster` returns `staged 0 / persons []` even though the
Person rows and the ledger rows exist. The only live-passing precedent in which the roster lists people is
`test/rls-g2-ledger-expand.spec.ts:244-256,310`, which ingests with `entity_type: 'clients'` (the legacy token == family
convention, `facts.service.ts:80-83`) and reconstructs via the direct `reconstruct(coach, intent, 'clients')` call. D2 case (h)
(`test/scout/s10/s10-unseen.pg.spec.ts:429-453`) never calls the roster reader — it counts `Person` rows by SQL (`:293`, `:451`).
S11-A1's step-11 roster read (`test/scout/s11/journey-core.pg.spec.ts:262-267`) asserts only `intent_id` and cross-host byte
equality, never contents. So no live-passing roster precedent exists for a token-mapped source; the S11-D assertion was never
runnable at this head.

Same pattern in the sibling IMPORTER-I reader: `scout-entities.service.ts:113,180,236,330` filter `entity_type: family`; not
asserted by this file (recorded, not widened).

Not fixed by S8-D1: at `worktrees/fa72-s8d1` HEAD `03b574e4` the reader is unchanged (`scout-roster.service.ts:75` still
`RECONSTRUCT_ENTITY_TYPE`) and the engine still ledgers `ledgerType = row.entity_type ?? family.entityType`
(`scout-reconstruct.service.ts:445`). S8-D1's own §6 patch for this file (`s8d1/s8d1_build.md:125`,
"`accounting.staged === rosterIds.size`") carries the same unrunnable expectation.

## Why this is STOP, not a spec fix

The S11 decision record wording is "finishing with a native roster read (step 11) that lists exactly the reconstructed identities"
(`docs/decisions/2026-09-26-s11-journey.md:432-433`) and the S11-D grant requires the roster-bearing leg's "roster read lists exactly
the staged people as imported, not yet joined". The product at this head cannot satisfy that for the `s10_unseen` source without a
`src` change (either the reader resolving tokens to families through the registry, or the engine ledgering under the canonical
family — the latter would also change S9's join key). D-S11-6: a case needing new product behaviour stops and is re-graded. The
assertion was left byte-identical at `journey-full.pg.spec.ts` (leg B, `:426-436` pre-edit numbering) — NOT rewritten to assert the
empty projection.

## Classification: B

- CLASS: product/contract gap — native review reader (IMPORTER-G) blind to token-mapped sources; `accounting.staged: 0` is a
  silent zero for a run that staged 2 roster identities (mission invariant "unknown never silently becomes zero").
- CONCRETE HARM: the coach's post-settle roster review shows nothing for any newly inducted source; J19 step 11 cannot be proved as
  worded; S8-D1's §6 leg-B expectation is also unrunnable.
- EXACT DECISION BLOCKED: landing S11-D J19 leg B as specified (#565), and the S8-D1 §6 patch expectation for this file.
- MINIMUM CLOSURE (owner/parent): re-grade — (a) a src slice that makes the roster (and entities) reader resolve the run's staged
  tokens to canonical families (S8-D2 already owns the roster contract change — the natural home), after which leg B's
  `accounting.staged === rosterIds.size` / exact ids / `InvitePending` assertions become runnable as written; or (b) an explicit
  decision-record amendment re-wording step 11 for token-mapped sources at this head, with leg B asserting Person rows by SQL (D2 (h)
  precedent) and documenting the reader gap. Neither is a T4 fixer's call.
- EXECUTION UNLOCKED: S11-D landing; a truthful S8-D2 roster contract.

## What r4 did instead

Leg A's J17 terminal read (`:312`, a genuine spec defect: `intentId` passed as `pairCurrent`'s SETUP-NONCE argument) is fixed and
committed; leg A's empty roster is now discriminated by a direct `h.persons(COACH_A)` empty read. Leg B is unchanged and WILL still
fail live at the `accounting.staged` line until the decision above is taken — do not bind a proof run of r4 expecting 6/6.
