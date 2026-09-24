# UX-01 test timing disposition

Parent EXEC-95633079 records the first-nonzero result on ordinary commit `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`, tree `a33cb8919495ed24e30623188dbb9f59c67df8bd`. No acceptance is claimed; the 55 passed cases, one failed case and unexecuted stages remain distinct.

- **CLASS:** B, affected new loading-state test proof only.
- **CONCRETE HARM:** the test expects an intermediate state after async `renderHook` has already flushed an unheld mocked read, falsely rejecting unchanged product behavior and preventing a trustworthy passing proof.
- **EXACT DECISION BLOCKED:** UX-01's local candidate acceptance. B/drain, accepted predecessor evidence and presentation acceptances are unaffected.
- **MINIMUM CLOSURE:** inside only the failing test body, use its neighboring `deferred<string | null>()` and `getItem` spy pattern to hold the read. Preserve the existing loading/null assertions, resolve null under async `act`, and retain ready/null assertions. No product edit, artificial product delay, assertion deletion, new test system or scope expansion.
- **EXECUTION UNLOCKED:** after same A/B delta binding, an ordinary additive test-fix commit, the corrected named case and the never-run filtered sign-out test, typecheck and six-path ESLint. No entire56-case replay; unchanged55 passing cases transfer.

Original commit, raw RC1 logs and earlier source packets remain immutable. The heavy slot was released, with zero owned survivors; only source correction is presently granted. A/B reviewers continue their existing review, not a fresh full audit, and final actual-head/results attestations remain required.
