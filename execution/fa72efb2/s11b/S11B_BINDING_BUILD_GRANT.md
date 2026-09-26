# S11-B real-PG proof bindings (two lanes) — build grant (EXEC-FA72EFB2)
Grade T3 (proof-bearing runners derived by substitution from accepted runners). Route: Claude Opus 5.5.
Source only: never run a runner/fixture/jest/PG/bootstrap; never take the lock.
Candidate: /home/user/workspace/worktrees/fa72-s11b branch fa72/s11b-r1 HEAD 4d31616f9288402c0cdd6a74fb30b4b15d0658d3
(tree 366efa9f807cf8c1550bfc8a3394b6840f90287b), parent 7fdcbc044dba1747d0db2f2750ced951f3b6b752 (= integration/importer,
S11-C landed); refs/remotes/origin/land/s11b = 4d31616f (PR #562); clean; hooks ran. Delta = 5 paths:
src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts
test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts (blobs identical to reviewed 45b4da1d).

Binding A — S11 lane: execution/fa72efb2/s11b/binding/s11-lane-v1/ from the accepted, RC=0 template
execution/fa72efb2/s11c/binding/v1/s11-pg-proof.sh (+ byte-copied fixture; keep runner filename s11-pg-proof.sh).
Minimum changes: D/W (worktrees/fa72-s11b-pg1)/SRC (worktrees/fa72-s11b); BASE 7fdcbc04 (tree a802231e); HEAD/TREE; LAND_REF
origin/land/s11b; EXPECT_DELTA = the 5 paths + new FREEZE-s11b (== delta); keep FREEZE-v3 (8 A1 files identical at HEAD) and
FREEZE-s11c re-used as "7 S11-C files identical at HEAD" (not == delta); blob pins for the new spec + the two product files;
settle-redrive.pg.spec.ts live switch / BADPAT / it() count (expected 8). Commands once each: bootstrap; rls 6; journey 8;
readiness 6; NEW settle-redrive 8 (default config, own log, receipts); guard 94. Settle-redrive cases J12/J13 fork workers
with 90 s kill timers — give the stage an honest bound and raise the outer timeout if the stage sum requires (state it).
Binding B — S10-B lane (R36 flip in test/rls-g2-s10c.spec.ts): execution/fa72efb2/s11b/binding/s10b-lane-v1/ from
execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh (reviewed GO; its lane/bootstrap/fresh-clone mechanics ran fine in this
runtime — the run failed only on D2 candidate assertions) and, for the spec command/counts, the accepted
execution/d3a9f701/s10c/binding/v6 (rls-g2-s10b 24 + rls-g2-s10c 8 via jest.rls.config.js). Minimum changes: candidate pins
as above; drop the D2-specific 8-blob/core-diff checks and replace with the S11-B delta/FREEZE-s11b checks; spec command
`./node_modules/.bin/jest -c jest.rls.config.js --runInBand --ci test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts`,
expected 32 (verify counts at HEAD; R36 is one of the 8); lane dir clusters/s11b-s10b (port 55649 is fine; no lane left
there — check runtime/clusters now), W=worktrees/fa72-s11b-pg2.
Both: pre-STARTED refusals leave the run unconsumed; receipts as templates; bash -n; DELTA diffs vs each template;
BINDING.sha256 relative to each binding dir; README with pins + provenance + expected counts + open risks.
Rules: execution/fa72efb2/WORKER_RULES.md. Return file list + sha256s, changed pins, expected counts, risks.
