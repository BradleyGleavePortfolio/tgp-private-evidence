# S11-A2 (03e7a234) — independent T4 review (EXEC-FA72EFB2)
Route: GPT-6 Sol (T4 lens independent of the Claude Fable 5 builder). Read-only; no PG/jest; never take the lock; edit nothing but
your report. Subject: /home/user/workspace/worktrees/fa72-s11a2 fa72/s11a2 HEAD 03e7a2344ef95b019c751983527bbc9f78200921 (tree
738b7116), parent dda794d7 (= integration/importer), land/s11a2 = HEAD, PR #564. Builder report s11a2_build.md; grant
S11A2_BUILD_GRANT.md; authority docs/decisions/2026-09-26-s11-journey.md (D-S11-6, §3 J09–J11, Q-S11-4) and the D2 learning
(s10d2/d2_diagnose_fix.md: staged clients rows can never be `complete` until S8-D).
Questions: (1) J09/J10/J11 assertions are guaranteed by code (verify file:line), discriminating (would fail if the property broke),
and honest — no `complete` on a shape that cannot be complete; C-ID never masks C-COV; unknown never becomes zero. (2) J11 barrier
is deterministic (pg_stat_activity lock observation, no sleeps-as-sync) and both orderings are real; XOR assertion is exact.
(3) Harness edit obeys D-S11-6: only `declare`/`observe` + the S10-B/S10-C composition + two-source inputs; A1 paths untouched;
the worker uses real services (no fabricated server behaviour); guard spec updates are exact (95). (4) Second source is data only:
no src/prisma diff; test-only key never reachable from src. (5) Live risks for the first PG run (worker count ~38, 10 s
observation window, cold start) — classify. Classify A/B/C (A/B five fields). Write s11a2/s11a2_review.md; verdict GO/NO-GO.
