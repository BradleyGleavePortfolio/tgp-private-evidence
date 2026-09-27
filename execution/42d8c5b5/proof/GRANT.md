# PROOF-RT runner grant (EXEC-42D8C5B5) — T3, claude_opus_5_5 (runtime executor, parent-delegated)
Purpose: stop hand re-pinning a 450-line binding per slice (16+ substitutions each time; repeated cost across S11-A1..S11-D).
Build ONE parameterized runner per real-PG lane for THIS runtime, prove it on the landed baseline, so every later candidate proof
is `runner <HEAD> <run-dir>` with zero preparation.
Inputs (read, reuse, simplify): /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v2/{s11-pg-proof.sh,
s11-fixture.sh,README.md} (S11 lane, last GREEN 127/127 on 54be96f1), s11d/binding/v2 (adds the journey-full stage),
s10d2/binding/v2/{d2-pg-proof.sh,d2-fixture.sh} and s11b/binding/s10b-lane-v2 (S10-B lane). Runtime: execution/42d8c5b5/runtime
(PG 17.6 at /home/user/workspace/execution/42d8c5b5/runtime/pg17/dist, donor node_modules worktrees/x42-donor, prettier prefix).
Deliver in /home/user/workspace/repos/tgp-private-evidence/execution/42d8c5b5/proof/:
 - lane-s11.sh <HEAD_SHA> <RUN_DIR> [--stages list]: all S11 stages (bootstrap, rls-g2-s11, journey-core, readiness, settle-redrive,
   journey-induction, journey-full if the file exists at HEAD, guard with G2_S11_* unset); stop at first failure; never retries.
 - lane-s10b.sh <HEAD_SHA> <RUN_DIR>: the S10-B lane (s10-unseen + s10b + s10c pg specs as in the D2/S11-B bindings).
 - Each: fetches HEAD from /home/user/workspace/repos/backend (parent keeps it fetched incl. cand/x42/*), fresh scratch clone at
   HEAD, verifies package-lock sha == donor's (else refuse), node_modules as the precedent does (never mutate the donor), prisma
   generate, fresh PG cluster on a free port, holds the canonical lock (inode 657581) for the WHOLE run via flock -w, O_EXCL run dir,
   hard timeouts, guaranteed teardown, and writes RUN_DIR/RESULT (RC, stage, HEAD, tree, package-lock sha, migration count,
   runner sha256, per-stage pass/fail/skip counts parsed from jest). Binding = HEAD+tree+runner sha; no per-blob pin tables.
 - Any stage that reports skipped tests where live was expected = FAIL (never report skipped as passed).
Then run each runner ONCE on baseline 54be96f18c314cae35d1e5d3000af9f06d693d81 (expected S11 lane 127/127 per s11a2 v2; S10-B lane
per its last green receipts) as runtime qualification. If a baseline run fails, classify (runtime/runner B vs product) and fix the
runner only; do not touch product code. Run dirs under execution/42d8c5b5/proof/baseline-*/.
Report: execution/42d8c5b5/proof/REPORT.md (usage, what is bound, baseline results with counts and durations). Keep it short.
You may run PG and the lanes (parent delegation for this grant only). Rules: execution/42d8c5b5/WORKER_RULES.md (rule 5 PG ban
lifted for you; never run while another run holds the lock — flock handles it).
