# S11-B r2 — raw-query serialization retry fix (EXEC-FA72EFB2)
Grade T4 (settle/terminal retry semantics). Route: Claude Fable 5 builds; GPT-6 Sol reviews the delta.
Read PROOF_A_V1_FINDING.md (root cause, pg.log evidence). Clone /home/user/workspace/worktrees/fa72-s11b, branch
fa72/s11b-r1 HEAD 4d31616f (clean). Make ONE new commit on top (do not amend):
1. Verify against the installed Prisma 6.19.3 runtime (node_modules/@prisma/client, read-only) how a PostgreSQL 40001/40P01
   raised by `$queryRaw`/`$executeRaw` inside an interactive transaction surfaces (expected: PrismaClientKnownRequestError
   code P2010 with meta.code '40001'/'40P01' — confirm the exact meta shape; cite file:line).
2. `isSerializationFailure`: also true for that raw-query shape with SQLSTATE 40001 or 40P01 only; every other P2010 stays
   false. Keep the doc comment truthful. No other product change.
3. Unit tests in test/scout/lifecycle/lifecycle.service.spec.ts (next to L866): raw 40001 → true, raw 40P01 → true, raw other
   SQLSTATE → false, P2010 without meta → false; plus one settleWithSnapshot-level case: a raw 40001 on attempt 1 is retried
   and attempt 2's result returned.
4. Read-only scan: list every other catch in src/scout that keys on P2034 (e.g. scout-reconstruct.service.ts L672) and
   whether a raw statement can raise 40001 there — report only (C), do not change.
Gates under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`, only while
/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists: prettier/eslint on touched files, the touched unit specs
(lifecycle.service.spec.ts, s11b-settle-redrive.spec.ts), commit through hooks (tsc runs there). Bradley author/committer, no
trailers, no push. No PG. Report s11b/s11b_r2_fix.md: evidence, diff, commands+RC, new head/tree, blob shas.
