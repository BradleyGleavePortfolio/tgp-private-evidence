# S8-C runtime acceptance (parent, EXEC-DACEDDC8, 17:41Z)

**ACCEPTED:** candidate `f428db9ab65f638da1651b8cd792c6f93b4983c1`, tree `f2623be642ddfbba025ffe8360256a683ac57997`, branch `exec64/s8c-replacement`.

Lineage: `87018a42` (accepted S8-C source) → `e0cee7e0` (bootstrap) → `9cc76401` (harness `updated_at`) → `4d7d4b4e` (spec F1/F2/F3) → `f428db9a` (User-count baseline). Every commit after `87018a42` touches test files only; `prisma/`, `src/` and `docs/contracts` are identical to `87018a42`.

## Basis

- **Reviews:**
  - REV-2 bootstrap: A and B both GO.
  - REV-3 harness and spec: A `a63a80f8…` and B both final GO, class C only.
- **Real-PG proof (PG-4c):** run exactly once, ending 17:39:23Z. Driver `b641db2d…`, fixture `34a42ab8…`, binding `2995ed83…`.
  - Sentinel: `RC=0 STAGE=done HEAD=f428db9a… LOCK_INODE=674373`.
  - Jest: 1 of 1 suites and 13 of 13 tests passed.
- **Preserved:** the consumed v3 and v4 failed proofs and their dispositions, and the non-accepting scratch diagnostics.

## Scope of acceptance

This acceptance covers non-production composition and landing onto `integration/importer` (currently `df713fd9`) under LAND-2. It does not authorize a production merge or deployment.
