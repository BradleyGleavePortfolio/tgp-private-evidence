# S8-D1 (42c8ed30) — independent T4 review (EXEC-FA72EFB2)
Route: GPT-6 Sol (independent of the Claude Fable 5 builder). Read-only; no PG/jest; never take the lock; edit nothing but your report.
Subject: /home/user/workspace/worktrees/fa72-s8d1 fa72/s8d1 HEAD 42c8ed30d4c846740211959e189e448d4f72cb3d (tree 650a32e4), parent
38d0d366 (S11-D candidate on integration/importer 54be96f1). Builder report s8d1/s8d1_build.md; grant S8D1_BUILD_GRANT.md; contract
docs/decisions/2026-09-26-s8d-person-link.md §5.1 (reviewed GO, fa72-s8d f91dea4d); owner decision OWNER_DECISION_S8D_2026-09-26.md.
Questions: (1) Contract fidelity §5.1 steps 1–4: create-only (no display_name overwrite on replay), provenance verification
(foreign coach / wrong kind → identity_conflict; missing/Deleted → native_target_removed; never resurrect, never create a second
Person), one-time adoption of pre-D1 Persons, target-before-provenance in one transaction, typed result so the ledger kind is
stamped. (2) Identity safety: no User minted; email/name never a linking key; the external ref includes coach_id; cross-tenant
impossible; concurrency (two runs of the same coach racing on the same external ref — unique keys, P2002 handling, serialization).
(3) S9 honesty: Deleted → removed (bucket i); historical NULL-kind ledgers stay bucket f; a run is `complete` only when every family
is complete; unknown never becomes zero; roster_bridge_pending untouched. (4) The s10-unseen (h) flip to `complete` is justified by
code, not by wishful fixture; the other flipped assertions (engine spec replay display-name) are honest. (5) Spec quality:
discriminating, no tests-of-tests; inventory completeness (rg for other specs/fakes asserting the legacy persist shape).
(6) The deferred journey-full patch s8d1/journey-full_leg-b_j20_required-changes.patch — correct and minimal? (7) LOC honest; no
migration; no fixture slug in src. Classify A/B/C (A/B five fields). Write s8d1/s8d1_review.md; verdict GO/NO-GO.
