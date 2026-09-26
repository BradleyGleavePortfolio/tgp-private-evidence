# S9C-PROOF-2 failure classification (parent d3a9f701)
- Run: binding v2, candidate 98133050, jest 9/10, rc=1 at stage=jest; cleanup clean (postgres 0, port 0). Preserved at binding/v2/run/. CONSUMED — never rerun.
- Failing: R11 tenant isolation, test/rls-g2-s9c.spec.ts:563 expected A's report families == ['programs']; received ['client_history','clients','programs','workouts'].
- Class B (proof/test defect). Product follows D-S9-2 "Required families" (doc L163-168: union incl. every family the staged platform's mapping spec declares; reconcile.ts declaredOnly zero-row entries). The same spec's R12 test (L451-470) already relies on all four canonical families appearing. Facts reads are coach-scoped (facts.service.ts L49, L245-249).
- Concrete harm: none to product/customers; blocks S9-C acceptance (real-PG proof not green).
- Minimum fix: R11 asserts the four required families and that every non-programs family has staged_unique 0 / native_present_verified 0 (strictly stronger isolation: B staged a workout, so a leak would make A's workouts staged_unique 1). +16/-2 in one test file; no product bytes.
- Unblocks: new candidate (follow-up hooked commit) → binding v3 → one fresh PG proof → accept → land S9-C.
