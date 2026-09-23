# S6 observed validation failures: bounded test-only continuation

Parent EXEC-e7d2385c. Builder remains s6_frozen_source_recovery_muei56l7, requested Claude Fable 5 / High. Cumulative S6 remains T4. No product change, harness change, dependency update or added acceptance criterion is granted.

## Actual results and scoped continuation

Step00 passed. Step01 failed raw2 with four errors in the unchanged baseline `ExtensionPairingPanel.copy.test.tsx`; step02 failed raw1 with16 passed/3 failed of19 and exited normally. Preserve these failed receipts, not replacement success claims.

Steps03–09 are independently executable and are explicitly allowed to continue on unchanged P3 tree93ed7cfc. Do not edit the live worktree during that execution. Stop only the next affected unexpected boundary, then report the exact result.

## Minimum closure

CLASS: B for the required proof, not demonstrated product harm.

CONCRETE HARM: typecheck cannot pass because the copy-test helper describes an awaited RNTL result as a Promise. Two identity tests observe the supposed intermediate phase only after awaited RNTL lifecycle calls have already flushed the mock read; another logout assertion counts its own fixture seed.

EXACT DECISION BLOCKED: clean required typecheck, identity19 proof and aggregate acceptance relying on them. Other suites, product source closures and accepted S1–S4 do not reopen.

MINIMUM CLOSURE:

- T1 child, cumulative T4: apply only `ReturnType<typeof render>` → `Awaited<ReturnType<typeof render>>` to the baseline copy-test helper. Frozen isolated type-fix06b5a4cd already contains that one annotation; no runtime or assertion change.
- T4 proof child: repair only the three observed identity fixtures. Preserve both intermediate-state assertions by holding the intended read through the existing deferred-read pattern until the phase has been observed, then release and assert commitment. Do not delete/weaken those assertions. Baseline the logout fixture's seeded write. Keep19 intended cases, unchanged product bytes and no new test scenario.

EXECUTION UNLOCKED: same reviewers' changed-test-only follow-up, one rerun of the affected identity suite and failed typecheck, ordinary local commit, final exact-head/result attestations. Unchanged applicable results from the other suites transfer without reruns.

Prepare the successor in isolated `execution/e7d2385c/s6-observed-test-fix/**` after the current runtime boundary. Freeze exact before/after patch, candidate tree, unchanged-product comparison and the minimum finding closure. The live worktree stays P3 until explicit application/runtime activation. No baseline typecheck, extra Jest, new controls, installation or full source audit.
