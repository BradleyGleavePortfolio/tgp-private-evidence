# S9B-GATE-3 grant — parent, session d3a9f701, 2026-09-26T01:12:25Z
S9B-GATE-2 (preserved in attempt-2/) stopped rc=74 at STAGE=r75 after prettier/eslint/tsc all passed (TSC rc=0):
the driver called scripts/check-r75.js with no mode; the checker at BASE supports only --mode=staged|range → operational rc=2.
Class B (gate-driver/checker interface). Harm: gate cannot reach jest/commit; no product consequence. Blocked: S9-B gate only.
Minimum fix: drop the invalid no-mode call (1 line); R75 remains enforced by --mode=staged at STAGE=stage + pre-commit hook + CI.
Rerun inputs: W restored to preconditions by moving (not deleting) gate-2's node_modules copy → runtime/set-aside/s9b-gate2-node_modules
and installed hooks → attempt-2/installed-hooks/. Formatted bytes kept (prettier 3.9.9 layout-only reflow made by gate-2); PINS.env
re-pinned for the 5 reflowed paths to gate-2 POSTFORMAT sha256 (facts.service.ts, facts.service.spec.ts, rls-g2-s9.spec.ts, g2-s9-worker.cjs, doc; doc delta still +99/-0).
Driver sha256 2b569e594dacf038d933e31a76acc6bf858a51a8ae3b1feedd7b5dd4830ac120; PINS.env sha256 97acfbb3e5a031be9b48654368d9f64a8f5dd9e9077f1c3ded473098a6013600. Exactly one run. Final review of rebuilt files: A GO, B GO (C-only).
