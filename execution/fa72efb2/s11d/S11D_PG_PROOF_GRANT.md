# S11-D real-PG proof — parent grant (EXEC-FA72EFB2)
Candidate 38d0d366 on 54be96f1 (review Round 2 GO, s11d_review.md); binding v1 independent T3 GO (binding/v1/S11D_BINDING_REVIEW.md).
B1 closure: fa72-s11d2 + hooks + origin/land/s11d frozen; no npm/lefthook there; pgrep -cx postgres = 0 immediately before launch.
Qualifier C1: the two cherry-picks were hookless (PARENT_REBASE_NOTE.md). One run via binding/v1/launch-when-free.sh (7800 s).
Expected full 6, guard 95. Failure after STARTED: preserve, classify, never rerun the same bytes.
