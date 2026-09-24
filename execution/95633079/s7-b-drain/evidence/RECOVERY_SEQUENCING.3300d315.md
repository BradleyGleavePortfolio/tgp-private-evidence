# Backend Recovery: Safe Slices and Rollout Constraints

## Decision

Do not mechanically divide the frozen 27-path recovery into three landing PRs. Preserve the complete candidate, repair backend dependencies first, then allocate one backend writer to build independently verified slices with a backwards-compatible database transition.

This is parent read-only analysis of base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` and frozen tree `a8908132a9c4882dbe80f9fbc1052532c7e68c3b`. No product edit, new composed tree, test run, waiver or release authorization is implied. The original patch and all assertions remain preserved.

## R138 decision gate

- **Question and simplify:** A requested three-workstream plan does not require exactly three commits or PRs. Delete speculative parallel implementation and duplicate validation, not regression tests or required gates.
- **Hyperscaler practice:** Use small independently validated changes and compatibility-aware promotion, consistent with the [AWS Builders' Library continuous-delivery guidance](https://aws.amazon.com/builders-library/going-faster-with-continuous-delivery/). A reversible local SQL transaction does not by itself establish a safe mixed-version application rollout.
- **Good without bad:** Recover useful diagnostics and input validation in bounded slices while retaining the full identity-loss proof. Keep dependent schema, generated contracts and writer transitions under one owner; do not leave an intermediate deployment with incompatible writers.
- **Root cause:** The blocker is both the actual all-code size gate and schema/writer compatibility, not merely a large test file. Changing the gate exclusions or moving required proof to a later PR would conceal rather than repair it.

Rollback for this decision is to retain the existing frozen candidate and reject any proposed slice that cannot pass its own behavior, size, density and deployment checks. No historical migration is rewritten; no production database is touched.

## Measured boundaries

The checked-in backend LOC workflow counts `src`, `test`, migrations, scripts and workflows, not just production source. Its exact frozen delta is 1,335 net lines. The measurement script and complete per-file results are preserved in `build-reports/recovery-sequencing/`.

| Candidate grouping | Actual workflow net lines | Added tests / added src | Disposition |
|---|---:|---:|---|
| ORM diagnostic sanitization: three source paths and its existing 85-line spec | 133 | 85 / 54 = 1.574 | Potentially independent, but fails the 2.0 floor as currently grouped. Add meaningful missing branch/behavior tests, not filler. |
| Request validation/redaction and generated contract, excluding identity structural tests | 192 | 137 / 83 = 1.651 | Potentially independent after checking the service comment and contract semantics against the actual base. Density still below the floor. |
| Database compatibility/proof kernel, excluding adjacent regression deltas | 897 | 791 / 21 | Cannot pass the actual 400-line gate as an unchanged atomic slice. Recalculate the exact R74 and actual workflow density separately on every implemented stage. |

These are file groupings, not buildable candidate PRs. Correction following the read-only rollout review: R74's density denominator is added `src` TS/JS, not SQL migrations. The actual workflow additionally counts one script addition for validation, so that grouping is 137 / 84 under the workflow rather than 137 / 83 under R74. Full-candidate density is 1192 / 158 = 7.544 canonical and 1192 / 159 = 7.497 actual workflow. The first two groupings still fail the 2.0 floor. The earlier wording implying SQL belongs in the R74 density denominator was incorrect; this does not alter the independently measured 1,335-line actual size failure. All remaining reconstruction and structural-idempotency test changes still need assignment and preservation.

## Compatibility finding

The frozen migration adds required `ScoutReconstructionLedger.source_platform`, replaces the old ledger uniqueness target and changes the staging key. The frozen reconstruction writer supplies the new field and uses the new five-part selector; the base writer does neither. An old binary continuing or returning after the migration is therefore not shown to be compatible.

The existing 21-case live proof establishes substantial final-state behavior, RLS and transactional failure safety. It does not establish a mixed-version expand/contract rollout. Its successful down migration in collision-free fixtures also does not prove rollback after newly permitted identities have been written: the candidate correctly refuses lossy rollback when those identities collide.

Parent disposition: treat R82 deployment compatibility as unresolved, notwithstanding the original builder's final-state PASS interpretation. This is a preserved diagnostic derived from the exact SQL and base/candidate writer contracts, not a newly run live reproduction or an independent final audit.

The next database design must demonstrate:

- **Expand:** An additive schema stage that keeps the currently deployed writer functional, including its old uniqueness selector and inserts. Any nullable transitional field must have explicit handling rather than fabricated platform values.
- **Transition:** New and old writer/read behavior tested together, bounded unambiguous backfill, concurrent-write handling, and an explicit signal that obsolete writers are drained before tightening constraints.
- **Contract:** Five-part identity enforcement, required platform and retirement of narrow uniqueness only when the rollout preconditions hold. Keep all original RLS, replay, cross-type/platform identity, schema-shadowing, index-ownership and orphan-history assertions.
- **Rollback:** State the rollback boundary before new identities make narrowing lossy. Refuse destructive repair; demonstrate compatible application rollback in the allowed window and a forward repair after that boundary.

## Proposed staged implementation, not verified rollout

The completed Cycle 3 read-only handoff makes the following boundaries concrete without claiming implementation or test success:

- **E, nullable expansion:** Add nullable ledger platform without fabricated defaults while retaining old selectors and policies.
- **T/Q0, compatibility bridges:** A transitional writer retains narrow selectors, supplies and transactionally claims known platform provenance, and never overwrites a mismatch. Readers must decode the proposed later cursor version before any emitter switches.
- **B/drain, backfill and old-writer retirement:** Backfill only unambiguous identities in bounded, resumable batches; preserve metadata and reject ambiguity. Drain and fence old writers before asserting zero remaining nulls.
- **R, required platform with both keys:** Introduce required/canonical platform and wide uniqueness while retaining narrow uniqueness. Old binaries that omit platform are not compatible with this stage.
- **N/Q1, final writer and reader emission:** Promote the wide-selector writer only on its compatible schema and the new cursor emitter only after all readers understand it.
- **C, separate contraction:** Drop narrow uniqueness only after obsolete writers/readers are retired and all proofs pass. Rollback must refuse lossy narrowing rather than delete identities.

The release script applies all pending migrations before the rolling application update. E, R and C therefore require separately promoted artifacts, not merely different migration directories bundled into one release. The final contraction/proof forecast is 360–550 net lines and is explicitly not certified to fit the 400-line gate. No activation is authorized.

Static inspection also confirms a reader incompatibility in `scout-roster.service.ts` and `scout-entities.service.ts`: the frozen candidate still orders/filters and advances cursors using source ID alone. After identities widen, two rows with the same source ID on different platforms can cause a page boundary to skip one. Reader compatibility and deterministic composite pagination are required before contraction. This is a concrete source-level counterexample, not a newly run live test.

The original 21 final-state cases and 62 original assertion expressions remain mapped in the preserved handoff. Twelve additional proof groups cover mixed binaries, concurrency/backfill, provenance, schema readiness, final writers, rollback, cursor continuity, RLS/targets, CI PostgreSQL 15 and late-ingest snapshot semantics. Proposed token formats, backfill sizing and promotion details are not frozen contracts. The next sole backend writer still starts with the independent four-path diagnostics slice after dependency-writer release.

## Proof that cannot be delayed or discarded

The 572-line live suite has 21 cases covering identity separation, received/deduplicated counts, replay, timestamps, coach/intent isolation, up/down behavior, collision refusal, FORCE/restrictive RLS, hostile permissive policies, real service-role access, platform reconstruction, backfill/orphans, search-path/index ownership and ledger-only rollback failure. The 59-line target helper and 110-line destructive-harness boundary spec guard against running that proof on an unsafe database.

The added CI step deliberately requires the intended live suite, zero pending cases and at least 21 passing cases. A refactor into staged suites must account for every case and validate exact suite/case selection at each stage; it cannot lower counts to make an incomplete selection appear green. Mocks may test targeting failures but are not replacements for real Prisma/PostgreSQL behavior.

A test-harness prerequisite may be a legitimate standalone slice only if it is useful, executable and assertion-bearing on its own base. Landing a failing future feature test behind a skip, or moving obligatory changed-code proof after the feature lands, is not permitted.

## Execution order and concurrency

1. Freeze the isolated backend dependency repair and release its writer ownership before diagnostics preparation; complete its remaining verification without concurrent source changes.
2. Prepare the small diagnostics slice in a separate exact-tree clone while unrelated importer verification runs. Demonstrate red before a new production repair, and allocate diagnostics execution serially. Preserve existing diagnostics tests and meaningful missing cases; keep the original recovery tree intact.
3. Build the input-validation slice against the resulting pinned base, with the authoritative generator producing the full contract. Recovery's breaking change stays in the 2.x lineage; C1's provisional 1.5/1.6 values cannot overwrite it.
4. Build the staged database transition with per-stage compatibility and all original assertions mapped. Measure each real stage against both canonical and actual workflow gates.
5. Integrate the already frozen C1a/C1b candidates sequentially on the resulting compatible backend base; regenerate contracts and rerun required tests, then complete exact-head CI and independent audits before landing/freeze.
6. Only after C1 lands and freezes may M5 and the extension consumer implement against that contract. The extension also requires accepted pagination integration; mobile requires reconciliation of the stale prerequisite stack.

Backend sequencing can run as parent read-only work alongside importer acceptance and isolated diagnostics preparation. The source-frozen dependency worker is report-only and cannot compete for writes. Contract generation and expensive validation remain serialized; no worker writes mobile or the immutable shared context input.
