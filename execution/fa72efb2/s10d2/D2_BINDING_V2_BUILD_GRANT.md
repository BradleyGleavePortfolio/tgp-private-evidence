# D2 binding v2 — build grant (EXEC-FA72EFB2)
Grade T3; route Claude Opus 5.5. Source only (never run the runner/fixture/jest/PG; never take the lock).
Derive s10d2/binding/v2/ from s10d2/binding/v1 (reviewed GO; its run reached jest and failed only on candidate assertions
— PROOF_V1_FINDING.md) by MINIMUM substitution: candidate HEAD 275e458ca5a6b3684bb6ec83edb2a854056a6fd0 (+tree), SRC
/home/user/workspace/worktrees/fa72-d2 branch fa72/d2-r1, LAND_REF origin/land/s10d2 (the parent will push land/s10d2 to
275e458c before launch — pin it to 275e458c), the pg spec blob/sha pin, the expected test count 8 → 9 (verify it() count at
HEAD), and any D2 8-blob/pure-addition/modes checks affected by the spec change (base remains 7fdcbc04). Lane: the stopped
v1 cluster remains at runtime/clusters/s10d2 (pg-data retained) and run/s10d2 exists empty — decide from the v1 runner
whether v2 must use a fresh lane dir (e.g. clusters/s10d2-v2) or requires the parent to archive/remove the v1 lane first;
state exactly which. Also note the S11-B S10-B-lane binding (s11b/binding/s10b-lane-v1) shares port 55649 — runs are
sequential under the lock. Clone W=worktrees/fa72-d2-pg2 (fresh). Fix the receipts order only if it is a one-line
move with no other effect (compute RECEIPTS after the END line) — otherwise leave as template (C).
Produce DELTA-from-v1.diff, bash -n, BINDING.sha256 (relative), README with pins/expected counts/risks, launch-when-free.sh
(exec timeout -k 30 4500 bash "$D/d2-pg-proof.sh"). Rules: execution/fa72efb2/WORKER_RULES.md.
