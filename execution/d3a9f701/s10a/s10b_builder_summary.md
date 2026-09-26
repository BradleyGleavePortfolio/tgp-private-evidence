# S10-B builder summary: run declaration and observation persistence

Worktree: `/home/user/workspace/worktrees/d3a9-s10b` (branch `exec-d3a9/s10b`, base `a4af8e33`). Nothing is committed or pushed. Only the owned paths were touched. I did not run tsc, jest, eslint, prettier, npm, prisma or postgres. The only checks I ran were `bash -n` on the bootstrap, `node --check` on the worker, and an `rg` scan for R75 banned tokens across every new `.ts`, `.cjs` and `.sh` file (0 hits). **None of the tests have been executed.**

## Files and sha256

| File | sha256 |
|---|---|
| prisma/migrations/20270124000000_scout_run_observation_expand/migration.sql | 345f12de9037d77c12f69abd96286411edfbaae1fb9df3767b1907fbada7aa15 |
| prisma/migrations/20270124000000_scout_run_observation_expand/down.sql | aee7c7351e89c55f4de03b403f731f96cdcc00183635b0ac48252467ca806905 |
| prisma/schema.prisma (modified, +63 lines) | d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96 |
| src/scout/induction/observation.controller.ts | c36e1858a1178478918568595203d4947d92aa2ef60e25ed6d58b6c0fb58b06a |
| src/scout/induction/observation.dto.ts | 753ec05f646591eede64d0646224bb05402acc29e298bfe64a7aa98a98df1e66 |
| src/scout/induction/observation.module.ts | 4d18b5111aa893bdb68dcba4267c199aee5eac2ad2543149a16094ff70b1b5c6 |
| src/scout/induction/observation.service.ts | c05832a5f3dcfae9154502f7e7967694b138ef174110d6c3509d7009633c34fc |
| test/scout/induction/observation.controller.spec.ts | d667e0b1d01f36342ccb0b1c6a0f22835c3788173105118ffbb66af0c490903b |
| test/scout/induction/observation.service.spec.ts | 0b423ecb317b7f497aa7abcf4de6217b293067821e75c773e8adff781f8271ee |
| test/rls-g2-s10b.spec.ts | 8ee13036e81b3bfbcd25e7ef9d34bf88f360ffdb2ba3684edc581b13675298c1 |
| test/utils/g2-s10b-bootstrap.sh (+x) | 3fc3f21da01f1748e715c3d0b6ed46dbe635300fffdbd160e2154c138baa80df |
| test/utils/g2-s10b-db.ts | 03e747a5b6d2237ca763daf3c146ab05c07866381878ffb50378e3bb5b3466bf |
| test/utils/g2-s10b-pg-harness.ts | e161105556da1b71b53404890a236e32f1a4d7ae6f5bbe88d6fe66d5479bd519 |
| test/utils/g2-s10b-harness.ts | c2783eb400ab2aaee61a94a515e44b7f46b1589d7dd939fb07d49a6cdbde3d84 |
| test/utils/g2-s10b-worker.cjs | f5a59dbf024c4d1ad8be899f4dedfdea10d622fa7a4f7a6ea42e2a1d72d181b7 |
| test/utils/g2-s10b-fixtures.ts (synthetic evidence and registry, shared by the unit specs and the worker) | 7f59132e33d8829c5d749e794077a83e083dd74dfb59b40b404ab9cac3e20ca7 |

**Change to an existing model:** `ScoutImport` gets three back-relation fields at schema.prisma L6893-6896: `declarations ScoutRunDeclaration[]`, `observations ScoutRunObservation[]` and `settledBasis ScoutRunSettledBasis?`. Prisma requires these for the child FKs. They add no column and no DB change, and nothing else in any existing model changed. The three new models are at L7032-7090.

**Harness lane:** port 55647 (entered in the confirmation; 55646 is added to the refused ports), database `g2_s10b_disposable`, admin `s10b_super`, `EXPECTED_MIGRATIONS=173`, base pin `a4af8e330bd4d6f882f0aebd411200b76d651aba`. Markers are `s10b-disposable-pg17` and `s10b-g2-run-observation-synthetic-disposable-fixture-safe-to-drop`.
- The bootstrap requires the prisma diff against the base to be exactly `schema.prisma` plus the S10-B `migration.sql` and `down.sql`, with no accepted migration modified.
- It also checks that the three tables have forced RLS and that the client carries the three models.
- The harness never deletes S10 child tables directly. `resetData` deletes the parent `ScoutImport` and relies on the cascade.

## Clause → file:line

Paths below: `M` = migration.sql, `Dn` = down.sql, `S` = observation.service.ts, `D` = observation.dto.ts, `C` = observation.controller.ts, `RLS` = test/rls-g2-s10b.spec.ts.

### D-S10-2: declaration and challenge
- Tables: M:88 (declaration), M:113 (observation), M:154 (settled basis). Models at schema.prisma L7042, L7057, L7078.
- One 32-byte server challenge per run: S:172 (`this.challenge()`, crypto.randomBytes). The DB enforces 32 bytes with `challenge_check` (M:101) and one challenge plus one `declared_at` per run with a trigger (M:197-219).
- Scopes are stored only as 64-hex digests (M:99, D:98-108).
- Declaration bounds: the doc fixes no number, so I chose ≤16 platforms × ≤16 scopes (D:42-43).
- Server-bound fields (`coach_id`, `challenge`, `declared_at`, epoch, `received_at`, `evidence_digest`) are never read from the body. Coach comes from `req.user.id` (C:103, C:151), and whitelist + forbidNonWhitelisted refuses these fields (controller spec, both routes).

### D-S10-4: routes and persistence
- Both routes run in one `$transaction` under `FOR NO KEY UPDATE` on the open `mode='server'` run (S:320-337).
- Declaration: atomic insert of the whole set (S:175, S:181-205). Exact replay returns the original challenge (S:146-159). `declaration_conflict` (S:153); `declaration_after_ingest` when a staged row or claim exists (S:160-171).
- Observation:
  - `observation_after_claim` on a claim row or phase `reconciling` (S:225-232).
  - `declaration_missing` (S:237).
  - Cardinality ≤ 4 × declared scopes (S:238, D:336).
  - `observation_not_declared` for an undeclared platform or scope, no manifest, or a family outside `expectedFamilies` (S:263-274).
  - Digest is `sha256Hex(canonicalJson(evidence))` (S:275-277). Same digest is a replay; a different one is `observation_conflict` (S:278-283).
  - Epoch and `received_at` are server-bound (S:288, S:295).
- Run refusals: `run_fenced` (S:332); `run_terminal` (S:334); expired goes through `classifyClosed`/`closedConflict` (S:339-344); `legacy_run`, uniform 404 and `run_not_started` (S:350-363).
- Body cap: the controller calls S10-A's `checkObservationBodySize` on the exact `rawBody` bytes, and a missing rawBody is refused (C:147-148). The S10-B envelope (exact keys, `intent_id`, ≤ static max, `parseEvidence` per entry, one entry per unit) is at D:303-331.
- Routes: `@Post('runs/declaration')` C:95 and `@Post('runs/observation')` C:137, each with `@Roles('coach','owner')` and 30/min.
- The module is not registered anywhere; ScoutModule wiring belongs to S10-C (observation.module.ts).
- RLS: ENABLE + FORCE, one service_role policy and RESTRICTIVE deny-all for anon and authenticated (M:252-288).

### D-S10-4: deletion controls
- DELETE and UPDATE are revoked from every runtime role; service_role gets SELECT and INSERT only (M:244-249).
- Trigger refuses every UPDATE, a top-level DELETE (`pg_trigger_depth()=1`) and TRUNCATE (M:178-190, triggers M:222-237).
- FKs are `ON DELETE CASCADE ON UPDATE RESTRICT`, as referential cleanup only (M:104-107, 142, 146, 171).
- `down.sql` checks the exact catalog, refuses while any row exists (Dn:62-67), and drops without CASCADE (Dn:73-77).

### R-cases
- **R25 (tier A):** not implemented here; it is the evaluator's judgment (S10-A/S10-C). S10-B only stores what that evaluator needs: the per-platform, per-scope declaration rows (M:88) and the declared platform set.
- **R29:**
  - Service spec: every code, replay, conflict before and after ingest, after-ingest, the 400 cases, mid-insert rollback, the not-declared cases, and cardinality.
  - Controller spec: 32 KiB accepted, 32769 bytes refused, duplicate unit, missing rawBody.
  - RLS: L241-401 on real rows.
  - Not provable in S10-B: the flag-off 404. It comes from the global `/api/scout` middleware once S10-C mounts the module.
- **R30:** RLS L346 (after the epoch moves, the same unit becomes a new row at the new epoch) and RLS L323 (rows carry the locked epoch). "A settle at e' ≠ e ignores them" is S10-C.
- **R31:** catalog exactness at RLS L162. At RLS L403-509:
  - anon and authenticated refused; service_role rollback persists nothing.
  - The FK refuses cross-coach rows and undeclared units.
  - service_role UPDATE/DELETE refused by privilege; owner UPDATE/DELETE/TRUNCATE refused by the trigger.
  - Negative control: a nested non-FK DELETE in a service_role session gets permission denied.
  - Positive control: deleting a parent cascades only its own children; a differing challenge or `declared_at` is refused; the CHECKs.
  - Down/up: down refuses while rows exist, drops cleanly when empty, re-applies, and the re-applied expand refuses when the tables are already present (RLS L577).
- **R32:** RLS L511-575. Each of the four orderings (declaration vs first ingest, observation vs `/complete`) serialises on the row lock: one side is used and the other is either used too or refused with its code. The tests also assert no partial rows, no deadlock, and no P2034.

## Open ambiguities, resolved fail-closed
1. **Unit key.** The observation unit key is (coach, intent, epoch, platform, scope, family) and excludes `basis_kind`. That is stricter than "all binding columns except id": one row per unit per epoch.
2. **Extra FK.** I added a composite FK from observation to the declaration PK, so an undeclared (platform, scope) is also unrepresentable at DB level.
3. **UPDATE and TRUNCATE.** UPDATE is refused at every depth, which is safe because the FKs are ON UPDATE RESTRICT. TRUNCATE is refused by trigger; for the declaration table, PG may instead refuse it first because the table is an FK target, and the test accepts either message.
4. **Declaration trigger.** It locks the run row before comparing, and also compares `declared_at`.
5. **After-claim cases.** A first declaration after a claim is also `declaration_after_ingest`. An observation during phase `reconciling` counts as `observation_after_claim`.
6. **Order of checks.** An exact declaration replay still returns 200 only while the run is open; fenced, terminal or expired runs are refused first. On observation, the claim check comes before `declaration_missing`.
7. **Body errors.** A missing rawBody gets 400. Envelope and evidence rejections get 400 with a diagnostic reason (no new 409 codes). Cardinality over 4 × declared scopes also gets 400.
8. **Multiple scopes per platform.** They are accepted at storage. The doc (R25) says that case makes the family `known:false`, which is the evaluator's call, not a storage refusal.
9. **Default registry.** It is loaded lazily and fails loudly (`buildInductionRegistry` over the on-disk manifests, specs and native rules). Unit tests and the worker inject a synthetic registry through `OBSERVATION_SERVICE_OPTIONS`.
10. **Module.** It provides its own `ScoutLifecycleService` instance, which is stateless, only for refusals and classification. S10-B never settles.

## S10-A symbols imported (exact paths, not copied)
These are relative imports that resolve once S10-A's files are composed into `src/scout/induction/` (sources in `/home/user/workspace/worktrees/d3a9-s10a/src/scout/induction/`):
- `./contract`: `OBSERVATION_BODY_MAX_BYTES` (controller spec), `HEX64_PATTERN`, `OBSERVATION_CONFLICT_CODES`, `CHALLENGE_BYTES`, and the types `ArtifactRejection`, `ObservationConflictCode`, `ObservationEvidenceV1`, `InductionManifestV1` (fixtures).
- `./parse`: `checkObservationBodySize`, `parseEvidence`, `unitKey`, `isHex64`, type `ParsedEvidence`.
- `./digest`: `canonicalJson`, `sha256Hex`.
- `./manifest-registry`: `buildInductionRegistry`, `loadInductionManifests`, type `InductionRegistry`.

`parseObservationUpload` and `ParsedObservationUpload` are not imported. S10-B owns the envelope: `parseObservationEnvelope`, `withinDeclaredCardinality` and `EnvelopeRejection` (which adds `bad_intent` and `duplicate_unit`).

**Cross-slice dependency:** the new files will not type-check or run until S10-A's `contract/parse/digest/manifest-registry.ts` are present in the same tree.
