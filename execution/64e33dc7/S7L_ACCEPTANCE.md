# S7-L runtime acceptance (parent, EXEC-DACEDDC8, 17:03Z)

**ACCEPTED:** candidate `df713fd9217df524915348ef8a42c797f288dde1`, tree `796f437fea80550a379b5f54dc485bc5dbba67e1`, branch `exec64/s7l-replacement`. Lineage: `a68cdac7` → `54970cd9` → `839b54c5` → `93389265`.

## Basis

- **Source:** the accepted S7-L source history is unchanged. The only delta after `a68cdac7` is the one-path test-worker correction `test/utils/g2-s7l-worker.cjs` (blob `155ffdcc`), which was dual-reviewed GO.
- **Reviews:** `s7l/reviews/WORKER_CORRECTION_REVIEW_A.md` and `_B.md` (`d9634549…`) are both final GO, class C only.
- **Real-PG proof (PG-4b):** run exactly once, 16:58:12–17:00:21Z. Driver `8b03f4c2…`, fixture `74aed261…`, binding `6c912b96…`.
  - Sentinel: `RC=0 STAGE=done END=2026-09-25T17:00:21Z HEAD=df713fd9… LOCK_INODE=674373`.
  - Jest: 1 of 1 suites and 24 of 24 tests passed, including L05/L12, which failed in v3.
  - Receipt `s7l/binding/v4/run/PROOF_RUN_RECEIPT.md` `b51d289e…`; `RUN_FREEZE.sha256` `83af3886…` checked by the parent and OK.
- **Consumed:** the v4 binding is consumed. The failed v3 proof and its disposition are preserved.

## Scope of acceptance

This acceptance covers S7-L's non-production landing to `integration/importer` by fast-forward (LAND-1). It does not authorize a production merge or deployment.
