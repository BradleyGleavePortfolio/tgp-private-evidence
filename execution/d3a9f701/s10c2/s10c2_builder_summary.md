# S10-C2 builder summary: the importer contract gains the two S10-B induction routes

**The candidate is uncommitted and source only.**
- No npm, jest, tsc or prisma was run. No lock or PostgreSQL was used, and nothing was committed.
- `docs/contracts/importer-openapi.json` is **not** edited. The gate regenerates it with
  `npm run contract:importer`, after S10-C's own regeneration.

**Where the work is:**
- Worktree: `/home/user/workspace/worktrees/d3a9-s10c2`, branch `exec-d3a9/s10c2`.
- Base: `711c1f8f` plus S10-C's frozen base layer. I did not touch the base layer. Before my
  edits it had no diff in `scripts/`, `test/contracts/` or `docs/contracts/`.
- The diff is `/home/user/workspace/s10c2.diff` (sha256 `e95b93b5…6c8d`), 3 hunks.

## Files (owned paths only)

| Path | Before (base layer) | After | Lines |
| --- | --- | --- | --- |
| `scripts/importer-contract.ts` | `7e89abfeab3d8c162293d475c74d8e595105cf4f6a100fba87cf2fd8d4486cde` | `4b063bcd6ccb839848e5448ece28a1b5cfdddcc63f30bad9b621705713f2d5f7` | +7 / −0 |
| `test/contracts/importer-contract.spec.ts` | `594113ec16095be9fee9829054588e04541831edef010704146dea2207fce5fe` | `023eac22fd47b0bb6b01bf63dcbaac5907bfefe5bea404186ee52720941cee43` | +130 / −0 |

**Product lines: 7, all in `scripts/importer-contract.ts`.** That is 2 path entries and 5
comment lines.

## Changes

**`scripts/importer-contract.ts`:**
- `IMPORTER_BARE_PATHS` gains `'/scout/runs/declaration'` and `'/scout/runs/observation'` after
  `runs/cancel`. These are exactly the `@Post('runs/declaration')` and `@Post('runs/observation')`
  on `@Controller('scout')` in `src/scout/induction/observation.controller.ts`, which the S10-C
  layer mounts through `ScoutModule` → `ObservationModule`.
- A comment records their posture:
  - bearer auth, coach/owner roles;
  - a uniform FEATURE_SCOUT_INGEST (R-DARK-1) 404 from the `/api/scout` prefix gate. This 404 is
    already documented by the controller's class-level `@ApiResponse(404)`.
- **`CONTRACT_VERSION` is unchanged at `2.0.0-c1-s2.0`.** R80 policy, as that file states, is to
  bump by hand only for a client-visible importer surface change. The additive precedent is
  explicit, though:
  - S8-F `e1ec2fec` and S9-C (`s9c_builder_summary.md` L72) regenerated with no bump;
  - S9-DOC L703 says "no `CONTRACT_VERSION` bump";
  - S10-DOC L470 lists a bump under "not decided", "additive per the S8-F precedent; generator
    owner confirms".
  - A comment line records this.
  - **Parent/generator owner:** confirm or override. A bump is a one-line change here plus the
    `info.version` expectation in the spec (L552).

**`test/contracts/importer-contract.spec.ts`:** one new `describe` block, inserted as a single
hunk after the S7-L block (around L1096-1231). It is far from the S11-C hunk at L529-533, so
S11-C re-applies cleanly and the two stay hunk-separable. It asserts:
1. Both routes:
   - have `security: [{ bearer: [] }]`;
   - take a requestBody `$ref` of `ScoutRunDeclarationDto` / `ScoutRunObservationDto`;
   - answer 200 with a `$ref` of `ScoutRunDeclarationResult` / `ScoutRunObservationResult`;
   - have response codes exactly `200,400,401,403,404,409,429`.
2. Declaration:
   - the DTO props and required fields are `intent_id` and `platforms`;
   - `platforms` is a `minItems: 1` array of `ScoutRunDeclarationPlatformDto`, with props
     `account_scope_id_digests` (array, `minItems: 1`, `uniqueItems`, string items) and
     `source_platform`;
   - the result props are `challenge_b64` (length 44/44), `declared_at` (date-time string) and
     `intent_id`.
3. Observation:
   - the DTO props are `intent_id` and `observations`;
   - `observations` is a `minItems: 1` array of `ScoutRunObservationEvidenceSchema`, with its
     exact 9 keys and `basis_kind` enum `['source_signed_enumeration']`;
   - the result props are `execution_epoch` (min 1), `intent_id`, `replayed` (min 0) and
     `stored` (min 0).
4. The 409 code enums are exact:
   - declaration: `declaration_after_ingest, declaration_conflict, legacy_run, run_fenced,
     run_not_started, run_terminal`;
   - observation: `declaration_missing, legacy_run, observation_after_claim,
     observation_conflict, observation_not_declared, run_fenced, run_not_started, run_terminal`.
5. Both 404 descriptions match `/FEATURE_SCOUT_INGEST/` and `/R-DARK-1/`.

The existing `exposes exactly the importer routes` test and
`importer-contract-extraction.spec.ts` derive from `IMPORTER_BARE_PATHS`, so they pick up the
two routes automatically.

## Expected `importer-openapi.json` delta (gate regeneration)

- **`paths`** gains `/api/scout/runs/declaration` and `/api/scout/runs/observation`. Each is
  `post`, tag `scout`, `security: [{ bearer: [] }]`, with a requestBody `$ref` DTO, and:
  - a 200 typed result;
  - 400/401/403/404 as `ErrorEnvelope` (404 with the FEATURE_SCOUT_INGEST / R-DARK-1 /
    no-existence-oracle wording);
  - a 409 `envelopeWithCode` enum;
  - a 429 `RateLimitError`.
- **`components.schemas`** gains six schemas, pulled in transitively:
  - `ScoutRunDeclarationDto`, `ScoutRunDeclarationPlatformDto`, `ScoutRunDeclarationResult`;
  - `ScoutRunObservationDto`, `ScoutRunObservationEvidenceSchema`, `ScoutRunObservationResult`.
  - `ErrorEnvelope` and `RateLimitError` already exist.
- **Unchanged:** existing paths, `securitySchemes` (only `bearer`) and `info.version`
  (`2.0.0-c1-s2.0`).
- **Also in the regeneration but not from this slice:** S10-C's base-layer DTO changes, and
  later S11-C's `PairSessionResult.readiness` plus `PairReadiness`.

## Notes

- The drift test (`byte-identical to a fresh regeneration`) stays red until the gate
  regenerates. This is expected, and I did not hand-edit to hide it.
- One assumption is unverified because nothing was run. It is that `@nestjs/swagger` 11 applies
  the class-level `@ApiResponse` 400/401/403/404/429 to both methods, as it does for
  `ScoutRunController`, and emits `type: [X]` as
  `{ type: 'array', items: { $ref } }` with `minItems`. The first gated run of this spec
  confirms both.
