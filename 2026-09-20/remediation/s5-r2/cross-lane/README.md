# S1 cross-lane disposition: directions, not implementation

The original [S1 disposition](S5_CROSS_LANE_DISPOSITION.md) is preserved byte-identically. S1 head `90a6647513f3566393764eee87237d9b5b1f150b` remained clean and unchanged; no tests or source edits followed this request.

Parent accepts these constraints for further review: distinguish successful out-of-band reversal from failed-migration recovery; do not equate PG15 CI with PG17.6 synthetic evidence; label ledger-wide counts truthfully; enforce drain/fencing as a process boundary rather than relying on transaction locks. These are not R2 audit verdicts.

## Applicability cautions for the next review

- The proposed `pg_stat_activity state='active'` check alone is not a complete fencing proof. Final procedure must address all relevant writers, restarts/new arrivals, idle-in-transaction sessions and applicable locks; exact verification and recovery must be tested before live execution. The observed race does not establish universal ordering of transaction and lock timeouts.
- Calling PG15 a compatibility floor is proposed documentation framing, not a new verified governance decision. Do not rewrite a historical runbook as re-measured on PG17.6 unless its actual scenario was reproduced; current evidence covers the identified S1/S5 synthetic suites only.
- A proposed per-run provenance filter is not approved service design. Validate actual provenance semantics and the customer-facing accounting contract before writing such a change.
- Transactional forward repair requires migration-specific idempotence and post-repair catalog/data verification. S1's proof does not attest E's content, and S5's synthetic E evidence does not establish production readiness.

Owners: S1 recovery packet; S2 delivery/worker ordering and CI wording; service owner accounting; parent C1 ordering and integrated fencing. No new source work is dispatched by this document.
