# S12 (real acceptance and pilot) — preparation to the owner boundary (EXEC-FA72EFB2)
Grade T3 (planning; touches owner-reserved boundaries, so every reserved step is ASKED, never assumed). Route: Claude Opus 5.5.
Source only: read the backend at /home/user/workspace/worktrees/fa72-s11d2 (integration/importer 54be96f1 + S11-D r3), mobile
/home/user/workspace/repos/mobile, extension docs in evidence; decision records docs/decisions/2026-09-2*.md (S8, S9, S10, S11,
S8-D person-link at worktrees/fa72-s8d f91dea4d); evidence execution/fa72efb2/{TAKEOVER.md, LAST_OPERATOR_STATE.md}, SCOPE.md
reserved list (execution/1910a060/SCOPE.md L114-118), owner notes (D2 C1 test-key limit before production enablement; Q-S11-1..4;
G3-AUTH; CWS; extension automation Q-S11-2). No code, no PG, no network calls to real services, no accounts, no spending.
Deliver s12/S12_PILOT_READINESS.md:
1. What "S12 accepted" means: the exact end-to-end pilot journey (coach installs extension → pairs → imports from ONE real source
   account → run settles truthfully → roster/programs visible in mobile → client invite per D-S8-LINK once S8-D4b/D5 land), each step
   mapped to the landed proof that already covers it synthetically (J01–J20, D2, S9/S10 specs) and what only a real account adds.
2. Readiness checklist split into (a) DONE on integration/importer, (b) buildable now without the owner (slices, with grades),
   (c) OWNER-RESERVED — each with a plain-words question for Bradley: which real source platform/account and whose data; consent
   and data-handling for real client data; production deployment of integration/importer → main (and backend main 1c10e2a1 state);
   production feature flags; extension publication (CWS) and automation (Q-S11-2); G3-AUTH; Q-S11-1..4; spending; the RLS
   environment check (WorkoutSession/WeightLog/Habit policies exist only in out-of-band rls_fitness_backend.sql — confirm live
   policies before any person-owned writer goes live); D2 C1.
3. Pilot safety: tenant isolation (pilot coach only), kill switch, rollback, what is observed/logged, success and stop criteria,
   and what "Unknown does NOT silently become zero" means for the pilot report.
4. The smallest owner decision set that unblocks S12, ordered, with a recommended default for each (clearly marked as a
   recommendation, not a decision).
Ground claims in file:line. Rules: execution/fa72efb2/WORKER_RULES.md. Report s12/s12_prep.md (summary, owner questions).
