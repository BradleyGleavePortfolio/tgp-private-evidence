# OP88-OWNED-LAUNCH-S5S6

Operator: op 88 / v12vantage88. Parent architecture/ownership decision, not an independent audit.

## Slice record

- Repository/PR: private execution tooling for backend S5 (#528/#529) and mobile S6 (#289-292). No new product PR, package dependency, service, application API or source change.
- Base/head: S5 publicc23b9d9f → candidate143d451e + patchc36258b3; S6 publica5933fd6 → candidated51a1910/tree62bf67b8. These product heads remain unchanged.
- Runner inputs: S5 V7 T0-only a13d44a5 and setup74736a58; S6 frozen C6-only746e244d and setup91fe0f1b, all full hashes in frozen packets. Hazardv5a91bb732/adapter/instrumentcf470101 remain immutable.
- Purpose: one minimal correction of the shared spawn/sleep/sample ownership class, then exact adaptations to these four scripts, rather than independent competing fixes.
- Non-goals: no generic supervisor framework/service, namespace/cgroup project, new dependencies, product/auth/query changes, schema, assertion change, original evidence rewrite, install/runtime or hook bypass.
- Dependencies: independent S5-V7-A02/A03; parentP88-S5-SETUP-01; S6_C6_PREP.md and C6_SETUP_CORRECTION_REQUEST.md; existing V8 work must be preserved.
- Sole writer/canonical builder: Claude Fable5 worker s5_selective_v7_fixer_mud58q6n. Writes only new execution/op88/s5-v8-t0 source plus an additive execution/op88/s5-s6-owned-launch packet. S6 builder's frozen C6 packet is READ ONLY; its builder does not concurrently edit the primitive or runner.
- Tier/rationale: T4 trusted recovery/process identity/evidence enforcement across validation lanes. Cross-cutting scope explicitly acknowledged, no downgrade. Parent retains architecture/acceptance.
- Required review: TWO independent exact primitive/consumer applicability reviews before any process controls/install/runtime; reviewers must not be authors or read one another's current conclusions. Narrow hazard/classifier review proceeds separately. Eventual product final audits remain downstream.
- Acceptance: no interrupt window can lose a launched owned child; workloads execute only after safe recoverable identity/adoption; never treat sampled caller PGID or retired numeric IDs as signal authority; verified current identity and no unowned signals; truthful primary/cleanup exits and failed publication; bounded cancellation/reap within stated allowances or explicit fail-closed recovery, not an unchecked wait or silent handoff.
- Required evidence: one exact causal correction and deterministic no-network/no-DB controls for interrupted startup, delayed setsid/current identity, publication failure, caller-group decoy, normal exit and timeout/cleanup. Preserve original command/env/input/assertion behavior. Map same contract into each of four scripts with exact diffs and hashes; preserve S6 C-only selection, classifier, instrument and hazard preconditions. No controls are authorized yet.
- Implementation constraint: reuse the smallest proven existing technique from current source. A tiny shared helper is permitted only if it actually reduces duplicated safety logic; no obligation to invent a new abstraction. If broader ownership architecture is necessary, freeze progress and return the precise boundary for parent rescope before expanding.
- Recovery: originals frozen; no product commits. New controls own only new synthetic children/private files; canonical lock and application roots remain untouched until a separate grant. Preserve failures and record incomplete cleanup.
- Success does not prove: installed dependencies, T0 outcome, S6 causal outcome, real database/native/browser behavior, product safety or release.

## Parallel work

S6 independent hazard/classifier/observer review can proceed on its frozen packet with the known launch primitive explicitly held. S2 V5.6 and S4 V5 own different runner compositions and continue independently; do not transplant unpublished code or share mutable helpers with them. S1/S3 source is ready and runtime remains upstream-gated.

## V9 bounded rescope ruling

V8 remains frozen and unexecuted. Builder's checkpoint-2 acknowledged that next-command registration is not atomic, workload executes before adoption, and retired numeric identities are not safe signal authority. Parent authorizes a bounded child-side verified-adoption gate as the smallest existing technique, not a general framework or product scope expansion.

Prepare additive V9 primitive/two S5 consumers/controls only. A fresh private attempt identity/path and checked publication are required before workload release. Failed, expired or interrupted adoption cannot run the workload. A trap's `$!` is not universally authentic: use phase-bound current identity and direct-child evidence, retire authority separately from retained historical evidence, and preserve ownership of descendants after leader exit. Every branch must avoid unconfirmed waits/unowned signals and propagate cleanup/publication failures honestly.

Independent V8 A and B are frozen under audits/owned-launch-v8-a (manifest9f54e9d7) and owned-launch-v8-b (manifestb22a6140), respectively; sole fixer may now read both. A's concrete control findings retain the HOLD despite B's narrower controls-safe opinion. Incorporate both reports before final V9 review. Preserve V9 milestone36f04f84 unchanged; use an additive final closure mapping if no code changes are needed, otherwise a new successor revision. S6 adaptations stay paused until primitive acceptance; completed narrow hazard/classifier/observer review does not grant runtime.

## V10 exact residual repair

OP88-OWNED-LAUNCH-V10 inherits the full T4 repository/PR/base/product-head/ownership/recovery contract above. Sole canonical Fable builder s5_selective_v7_fixer_mud58q6n writes only new execution/op88/s5-v10-t0; V9 manifest36f04f84 and final closure345c1b7f remain immutable. BOTH V9 A audit104a6bba/manifest56d46b9f and B manifestcceedc52 are frozen and available to the fixer. V9B05 additionally requires observed-gone to remain distinct from failed/unknown census; no fail-open skip/retirement. All material A findings remain binding despite narrower B closure labels.

Acceptance: wait in the actual launching shell, not command substitution; restore actual consumer trap wiring before spawn; required recoverable identity publication before ADOPT release; every fatal postrelease path reaches owned cleanup; complete checked receipt/quarantine outcomes and separate primary/cleanup/publication statuses; current live ownership census, not legacy retired IDs/zombies. Preserve valid V9 adoption/session corrections. Control evidence must bind actual shell statuses and consumer wiring, acknowledged supported failure/TERM-ignore seams and honest cleanup-inclusive allowances; do not weaken assertions to accept nonchild wait127. Two independent exact-successor reviews remain required before any fake-child controls/install/T0, S6 adaptations still paused. If failed recovery-marker publication needs different exclusion ownership, freeze that boundary for parent ruling rather than release active detached work. No generic framework or new dependencies; edits/hash/diff/syntax only, no runtime/probes/lock/network/install.
