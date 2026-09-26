# S12-B2 test-only source manifests excluded from production — build grant (EXEC-FA72EFB2)
Grade T3 (security hygiene; closes D2 C1: with the committed TEST-ONLY key a production run declaring `s10_unseen` could be proven
`complete` on its own tenant). Route: Claude Opus 5.5 builds; independent review GPT-6 Sol.
Spec: s12/S12_PILOT_READINESS.md L140 and D2 C1 (s10d2/d2_review.md). Generic, source-agnostic mechanism (NEW SOURCE → CORE DIFF = 0
must still hold for future sources): a manifest/verifier/key marked test-only (find the existing marker or add one in data, not a
slug list in src) is refused or not loaded when NODE_ENV=production; refusal is explicit and fails closed (never silently treated as
an unknown-but-allowed source); dev/test behaviour unchanged so every landed PG proof stays valid. No source slug literal in src.
Check the D-S10-5 core-diff gate (scripts/s10-core-diff-gate.sh) and S11-D J20: if the change touches files they guard, say exactly
how the gate is re-pinned in the same reviewed landing (do not weaken it).
Clone: `git clone --no-hardlinks /home/user/workspace/worktrees/fa72-s11d2 /home/user/workspace/worktrees/fa72-s12b2` (standalone),
origin → no_push://disabled-fa72efb2, Bradley identity, node_modules `cp -al` from worktrees/fa72-s11a1/node_modules, lefthook
install; base aed23289024898cceca7385d3778cd7373b7424d.
Specs: production-mode refusal of each test-only artifact kind; non-production unchanged; a non-test manifest unaffected in
production; no slug in src (rg). Gates under the flock rule while PROOF_SLOT_FREE exists: prettier, eslint, tsc, jest touched suites.
ONE commit through hooks, Bradley, no trailers, no push. Report s12b2/s12b2_build.md (design, file:line, LOC, gate impact,
commands+RC, head/tree, PG lane needs, risks). Rules: execution/fa72efb2/WORKER_RULES.md.
