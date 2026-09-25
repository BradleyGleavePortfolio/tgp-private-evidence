# DRAFT_READY addendum 01 — sequencing correction (2026-09-24 21:09 PDT)

Parent mail (priority high) received after DRAFT_READY:

- No bootstrap and no real-PG proof are authorized by the source-slot relay. The "then bootstrap + PG proof" sequence in DRAFT_READY §7 is **withdrawn**; §7 stands only as the description of the drafted proof files, not as an execution plan.
- Authorized order, each step on its own explicit relay/grant:
  1. Source gates only: prettier / eslint / `tsc` (heap 4096) / R75 / affected default-config Jest / hooks, then single commit (Bradley Gleave author+committer, no trailers), then bundle. No push.
  2. Dual independent exact-head / binding attestations (not mine to self-issue).
  3. Separate one-run PG grant for `test/utils/g2-s8c-bootstrap.sh` + `test/rls-g2-s8c.spec.ts` on the 55642 lane.
- Every failure at any step is preserved verbatim in this lane; nothing is retried to green silently.
- Parent will narrowly address the A1 `mapping-spec.ts` `programs` typing and the A2 generator ownership. Instruction: do **not** drop `programs` and do **not** broaden edits — the DTO hunk and `native.programs` registration stay as checkpointed; the A1 fallback in DRAFT_READY §4 is void unless the parent says otherwise.
- Status: idle, no heavy work, awaiting explicit relay. Checkpointed bytes unchanged (`CHECKPOINT_MANIFEST.sha256` still verifies).
