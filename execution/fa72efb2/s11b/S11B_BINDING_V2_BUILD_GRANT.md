# S11-B bindings v2 (both lanes) — build grant (EXEC-FA72EFB2)
Grade T3; route Claude Opus 5.5. Source only (never run runner/fixture/jest/PG; never take the lock).
Derive s11b/binding/s11-lane-v2/ from s11-lane-v1 and s11b/binding/s10b-lane-v2/ from s10b-lane-v1 (both reviewed GO,
S11B_BINDING_REVIEW.md; the s11-lane-v1 run failed only on candidate J13 — PROOF_A_V1_FINDING.md; s10b-lane-v1 never ran)
by MINIMUM substitution: candidate HEAD 9149f82381c38cdee8caf9b2b7ff47b2d358ac21 (+tree), chain 7fdcbc04 → 4d31616f →
9149f823 (two commits; add an r1→r2 diff check = exactly lifecycle.service.ts + lifecycle.service.spec.ts), delta now 6 paths
(+ test/scout/lifecycle/lifecycle.service.spec.ts), FREEZE-s11b regenerated for 6 paths, lifecycle.service.ts blob pin,
LAND_REF origin/land/s11b = 9149f823 (already pushed). Lanes: s11-lane uses clusters/s11 (absent now; v1 leftovers archived) —
confirm; s10b-lane keeps clusters/s11b-s10b (never created). W clones: fa72-s11b-pg3 (s11) and fa72-s11b-pg2 (s10b; absent).
Launchers: s11 `exec timeout -k 30 10200 bash "$D/s11-pg-proof.sh"`; s10b `exec timeout -k 30 4500 bash "$D/s10b-lane-pg-proof.sh"`.
DELTA-from-v1 diffs, bash -n, BINDING.sha256 (relative), README (pins, expected counts A 6/8/6/8/94, B 32, risks).
Rules: execution/fa72efb2/WORKER_RULES.md.
