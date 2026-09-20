# S1–S6 R2 parent disposition

Captured 2026-09-20, extended at 22:48 UTC after S6's independent pair completed. This is the parent operator's reconciliation, not a replacement audit or a rewrite of either reviewer. Original reports, probes and failed evidence remain unchanged in the [R2 index](R2_INDEX.md).

## Decision

| Lane | Frozen head | Parent outcome |
|---|---|---|
| S1 | `90a6647513f3566393764eee87237d9b5b1f150b` | NOT CLEARED: destructive fixture boundary and non-discriminating proof require correction. |
| S2 | `0b05fcf5352287109ac88ed2ba3682e441e3a076` | NOT CLEARED: dispatch-to-shell injection, ungated machine start, verifier discovery failure, recovery overclaims. |
| S3 | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` | Accept bounded source/local evidence. No unresolved material S3-local finding; integrated landing/release prerequisites remain. |
| S4 | `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057` | NOT CLEARED: cumulative authentication-body deadline/recovery defect. Loader/package evidence accepted only for its stated scope. |
| S5 | `485c67973b56758fb9b8404579f5ddaec87136bd` | Accept synthetic PG17.6 E→T/Q0 validation evidence. Cumulative G2 and E/T release boundaries NOT CLEARED. |
| S6 | `55db31a0696ebd07d0cb9abb18ffd31dce29457d` | NOT CLEARED: real fallback identity-cache composition, unsupported import-outcome copy and unbounded unresolved-identity state. Exact-head local/export proof accepted within scope. |

No product PR was merged, candidate published as a product branch, hosted control changed, database contacted, release dispatched or feature enabled by this audit round. Accepted evidence is not accepted deployment.

## How the independent conclusions were reconciled

- **S1:** both reviewers identify fresh-session timeout checks and first-statement rollback checks as insufficient for the claimed properties. B accepts the DDL by inspection; A additionally identifies an unsafe destructive harness. Narrower source acceptance does not clear a destructive execution path or establish missing behavioral proof.
- **S2:** A reproduced input execution and verifier-discovery fail-open behavior and identified a machine-start operation outside mutation gates. B's probes cover different paths and its favorable code conclusion does not rebut A's counterexamples. Require narrow remediation, not a majority vote.
- **S3:** both accept the attributable unchanged-head local results. c12 contention remains inference; repeated passes demonstrate the consumer seam but do not prove a unique historical failure cause. Wrapper status propagation, unstamped type-check heap and unnamed skips remain nonmaterial evidence-hygiene follow-ups.
- **S4:** B relied on unchanged R1 coverage for session/net modules; A independently reproduced an inherited body-consumption stall there. A cumulative customer-flow defect remains material even when it predates R2 and the new package is reproducible. The source needs a new candidate.
- **S5:** both accept the six-file test delta and clean-head run, while preserving operational recovery, writer fencing and hosted-applicability gates. One missing terminal assertion does not erase logged characterization, but logs must not be represented as regression assertions.
- **S6:** both independently reproduce actual identity-cache failure through the intentionally active fallback. Pairing's null-identity guard is locally sound but cannot restore a user that the real cache never reads. A's customer-truth finding and B's unbounded preparing-state consequence require coherent R3 repair. Parent does not take B's possible flag-off landing suggestion as clearance: the global identity failure is not scoped away by the pairing switch. Full tests and authentic exports do not refute the probes.

## Narrow remediation queue

These are executable next slices, not changes already made. Maintain one owner for schema/migration/generator work. Start from new successor worktrees; do not rewrite the audited snapshots.

| Owner | Slice and exit |
|---|---|
| S1 | Guard destructive harness before any new DB connection: explicit disposable identity/namespace, loopback/port restrictions, safe identifier handling, confirmation and negative tests. Then run the requested late-stage lock and same-session timeout checks against an isolated fixture. Bound success-path versus failure-path reset claims separately. |
| S2 | Move dispatch data out of shell-source interpolation into quoted environment values; enforce allowed app targets; remove machine start from diagnostic workflow or give it the same explicit mutation gate. Add adversarial input and no-side-effect tests. |
| S2 with S1 | Fail closed on verifier discovery errors and require the integrated expected verifier set. Prove actual `prisma db execute` nonzero/zero behavior on synthetic pre/post states. Resolve allowed-role/grant postconditions without automatically widening grants or demoting checks. |
| S2 | Correct pre-migration/post-migration/post-rollout recovery truth, forward-only rollback rules and first-release image identity; run shell/action lint on the successor. Hosted protection, image build and integrated preview execution remain separate prerequisites. |
| S4 | Bound pairing and refresh through response-body consumption, preserve epoch isolation, and ensure clear/re-establish recovers from stalled work. Add stall/recovery regressions; rerun affected gates, create a new package hash, repeat positive/negative loader proof, then obtain independent final-head attestations. |
| S1 packet owner; S5 validation owner | Replace generic E idempotence guidance with state-dependent E-specific recovery. Correct O recreation to a detached identity-checked Git clone/worktree. Add terminal worker/result and post-completion target assertions to the ordered race proof before relying on those properties. Do not rerun DB solely to duplicate accepted historical evidence. |
| Parent | Preserve S3 proof and sequence safe integration with S1/S2. Optional env-stamped type-check requires restoring dependencies first; not currently executed. Continue S6 remediation independently, without new C1 consumers or activation. |
| S6 | Coherent async fallback identity cache with truthful synchronous mirror semantics, mutation/account/logout race protection, real cache/identity composition tests, bounded unresolved-identity UI and state-bounded pairing copy. No native dependency activation, crypto change or new backend progress/revoke contract. |

## Release and authority gates retained

- **Hosted governance:** exact required checks, trusted policy inputs, eligible independent reviewer route and environment protection remain unimplemented. B's read-only observation found the backend main unprotected, no rulesets and no exact `production` environment. Do not substitute a successful check for enforcement.
- **Database applicability:** serving role, owners/grantors, relevant history drift, backup/restore point and actual writer/process fencing remain unknown or unproven. Synthetic identities do not establish hosted identities; no customer-row access is needed for future metadata verification.
- **Recovery:** failed deployment may leave schema or machines changed. E intentionally refuses raw reruns; column presence alone is not a complete invariant. Preserve applied migration history and committed provenance.
- **Distribution permissions:** `debugger` is granted ambient capability even with no shipped caller; optional wildcard host permission is dormant until requested. Resolve least privilege or explicit residual acceptance before distribution. No store publication is requested now.
- **Customer product:** loader success is not native import completion; E→T/Q0 is not later G2 stages; local mobile export is not installed-device acceptance. C1/G2 integration, native completion and pilot acceptance remain later boundaries.

## Evidence reuse and follow-up rules

Keep all original findings and report hashes. New source heads require fresh applicability decisions and scoped independent re-attestation, not inherited green labels. Optional duplicate S3/S4/S5 execution is deferred in favor of the active S6 validation and material fixes; no deferred request is recorded as a completed check.

No Bradley input is required for these ordinary engineering slices. Reserved hosted authority, privacy/security residual acceptance, distribution and live actions must be resolved at their actual boundaries, not used to block local remediation.
