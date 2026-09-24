# S7-L0 + S7-L1 draft grant (T4) — parent ~21:20Z

Planning input accepted: `s7l-prep/S7L_BRIEF.md`. Parent freezes §6: deadline default 300 s (lazy, no timer); arbiter default `partial/reconciliation_not_performed` until an S9 verdict; contract lineage `2.0.0-c1-s2.0`; no new flag (server mode gated by existing dark flags). Findings: F1 A (S8-G/UX-04/05 binding only), F2–F4 C.

Sole writer; worktree `/home/user/workspace/worktrees/s7-l` (branch `s7-l`) from N/Q1 v1 `61b93cff` (rebase onto accepted C head later; mechanical).
Owned paths: `docs/decisions/2026-09-24-s7l-run-lifecycle.md` (L0), `prisma/migrations/20270123000000_scout_run_lifecycle_expand/{migration,down}.sql`, `test/rls-g2-s7l*.spec.ts`, `test/utils/g2-s7l-*`, `test/scout/g2-s7l-db-guard.spec.ts`, and `execution/ce3748cb/s7l/**` (binding derivation mirroring the N/Q1/C binding pattern, distinct lane/port 55501, identity `s7l_*`).
Not now: `prisma/schema.prisma` hunk, service/routes (L2), contract regen (L3), any PG run, commit of SQL/harness (source-only, uncommitted draft; L0 doc may be committed once genuine hooks are available via a node_modules copy from `worktrees/s7-nq1` after its env receipt; never bypass hooks).
Report `execution/ce3748cb/s7l/DRAFT_READY.md` (file table lines+sha256, deviations) and STOP.
