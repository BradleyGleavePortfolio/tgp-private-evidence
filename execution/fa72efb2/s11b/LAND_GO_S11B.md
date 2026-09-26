# LAND GO — S11-B r2 (EXEC-FA72EFB2)
Candidate dda794d7 = 275e458c → 645fb6db (S11-B re-drive; dual T4 GO: s11b_review_A.md Claude Fable 5, s11b_review_B.md GPT-6 Sol)
→ dda794d7 (r2: raw-query serialization failures P2010/40001|40P01 retried in the settle tail; T4 delta GO s11b_r2_review.md).
Proofs: s11-lane-v1 FAILED (preserved, PROOF_A_V1_FINDING.md, class B → r2). s11-lane-v2 RC=0 17:20:20–17:32:47Z rls 6, journey 8,
readiness 6, settle-redrive 8 (J12–J15 incl. J13 race), guard 94. s10b-lane-v2 RC=0 17:34:43–17:39:10Z rls-g2-s10b 24 + rls-g2-s10c 8
(R36 flip). Bindings independent T3 GO (S11B_BINDING_V2_REVIEW.md). CI #563 green. Parent 275e458c = integration/importer.
Non-production → FF. Owner note (Q-S11-3): S11-B must be rolled out fully before a production run relies on claim replay.
Qualified C: the r2 fix also corrects landed S9-C behaviour (fence/cancel vs settle raw contention now retries instead of 500).
