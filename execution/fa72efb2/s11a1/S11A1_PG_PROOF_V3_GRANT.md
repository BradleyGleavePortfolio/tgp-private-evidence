# S11-A1 real-PG proof v3 — single-run grant (EXEC-FA72EFB2)

Candidate: 3db615c0a5e64a63b910d34ce7c732ee6e63f24d (tree 6ea6852c) = PR #559 land/s11a1-v3, one commit on
integration/importer 6a33df9b. = v2 53b2f70a + PROOF_V2-fix.diff (delta GO, d3a9f701/s11a1/reviews-s11a1_binding_review.md).
Binding: execution/fa72efb2/s11a1/binding/v3 (BINDING.sha256), independent T3 delta review GO
(s11a1_v3_binding_review.md; C-only). Runtime: execution/fa72efb2/runtime (rt-setup RC=0). Lock inode 686480.
Grant: ONE run, parent-executed: `timeout -k 30 7200 bash .../binding/v3/s11-pg-proof.sh`, launched only when no
worker holds the canonical lock (a pre-lock refusal rc 75 before STARTED does not consume the run and may be relaunched).
Expected: jest-rls 6/6, journey 8/8, guard 94/94, teardown OK, RC=0. Any failure after STARTED: preserve unchanged,
classify per Safety ROI, fix minimally, new binding version; no rerun of these bytes.
