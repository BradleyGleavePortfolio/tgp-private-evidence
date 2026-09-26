# D2 r2 (275e458c) — independent T4 delta review (EXEC-FA72EFB2)
Route: GPT-6 Sol (second T4 lens; not the fixer). Read-only; no PG; never take the lock; edit nothing but your report.
Subject: /home/user/workspace/worktrees/fa72-d2 fa72/d2-r1 HEAD 275e458ca5a6b3684bb6ec83edb2a854056a6fd0, parent 144269d1
(accepted, T4 GO, proven failing live on 4 cases — PROOF_V1_FINDING.md), base 7fdcbc04. Delta = ONE file
test/scout/s10/s10-unseen.pg.spec.ts (+114/−21). Fixer's report: d2_diagnose_fix.md (+ repro/). Review the DELTA only.
Questions: (1) Is the root cause right (legacy clients handoff → ledger target_kind NULL → S9-A bucket f → C-ID precedes
C-COV)? Verify each file:line. (2) Is every changed/new assertion derived from code and truthful — nothing weakened to pass,
nothing asserted that the code does not guarantee (these assertions have never run live; the next PG run is their only
check — flag any likely-false one as B)? (3) Does the reshaped proof still demonstrate the D2 property (NEW SOURCE → CORE
DIFF = 0; unseen source settles `complete` when its identities are native) and honestly pin the roster gap in (h), without
claiming roster runs complete? (4) Unknown never silently zero: declared-only empty families are proven empty by source-signed
empty enumerations, not absent. (5) Core-diff gate + the 8-path set still hold (read-only re-check).
Classify A/B/C (A/B with the five fields). Write s10d2/d2_r2_review.md; verdict GO/NO-GO.
