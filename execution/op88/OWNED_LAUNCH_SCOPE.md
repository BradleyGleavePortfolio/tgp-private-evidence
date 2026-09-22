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
