# S4 R5 parent disposition

Recorded 2026-09-22 at 01:07 UTC. This is the parent's reconciliation and prospective scope, not an independent audit or a rewrite of either frozen review.

## Exact candidate and decision

Candidate `88287cff47240aa58b5f0fea5da08670f1e87df6`, tree `a2879859882770f45b88f1651438436fd96376f9`, remains NOT CLEARED for the complete source boundary. Both independent R5 reviews are complete and frozen; both withhold final artifact/T4 attestation.

- **Original credential authority findings:** both reviews support narrow source/offline closure of S4-R4-A-01 and S4-R4-A-02/S4-R4B-01. Preserve that evidence; do not relabel the entire repair as ineffective.
- **S4-R5-A-01:** auditor A reproduced a later classification-to-report gap in both Start paths. Four of 82 finite interleavings emitted `auth_required` after replacement B became current, while B remained locally valid.
- **Temporal and impact limits:** none of those four schedules establishes notification after the replacement acknowledgement reached the caller. No replacement-credential misuse, token deletion, browser reproduction or customer impact is claimed.
- **Review disagreement:** B's independent schedules found no new material source defect. That absence does not refute A's concrete additional interleaving; B's revision 1 remains unchanged, and the parent retains A's medium/material truthful-reporting blocker.

The primary records are `execution/audits/s4-r5/a/REPORT.md` and `execution/audits/s4-r5/b/REPORT.md`, with their probes, attribution and non-self-including checksum manifests. The parent verified both manifests without modifying their packets.

## Prospective R6 source scope

The canonical S4 builder is authorized to create an isolated successor above exact `88287cff`, using `worktrees/s4-r6` and `execution/s4-r6`. R4/R5 source, audit and execution records remain frozen.

- **Reporting authority:** carry the accepted Start generation through the final preflight reporting action. Revalidate synchronously immediately before `auth_required` and corresponding status mutation in both entrypoints; obsolete work reports replacement instead.
- **Preserved behavior:** do not touch or present B's credentials, suppress genuine current-owner authentication failures, weaken cold-refresh or coalescing controls, or broaden into transport/UX/telemetry/framework/dependency changes.
- **Discrimination:** preserve and execute attributable predecessor/candidate late-boundary probes and genuine current-owner failure/success controls. Retain the stated acknowledgement and browser limits; new tests must not convert narrower evidence into a broader claim.
- **Execution limits:** dependency-free checks may run sequentially within the granted cheap-check bounds. Scoped lint/type/focused checks and commit hooks may use the established same-lock R4 dependency closure with explicit path and dirty-to-commit attribution; no install, database use, full suite, packaging or browser run is granted.
- **Identity and freeze:** Bradley Gleave must be author and committer, with no AI trailers or hook bypass. Freeze exact head/tree, bundle, receipts, non-self manifest and a new validation request before heavy work.

Independent successor reviews will receive exact successor applicability and separate writable directories. Neither R5 report will be amended into a later-head attestation.

## Final artifact requirements

Changed shipping bytes require a fresh ZIP, exact-head validation and successful browser evidence. R4's 1714-test run, ZIP and aborted browser attempt cannot certify R6.

A known-good base ZIP is a comparison, not an expected-failing negative. The new request must name an intentional loader-breaking mutation, preserve original/mutated hashes and mutation details, and require the intended exception/receiver failure with no unrelated errors; exit status alone is insufficient.

The Chrome-alone pipe test remains a transport diagnostic, not extension-loader proof. No product push, merge, deployment, production mutation or customer completion is authorized by this disposition.
