# EXEC-CE3748CB dispatches (parent: session ce3748cb, successor to cf8ff737)

Requested routes only; no model/effort telemetry is claimed.

| Worker | Tier / requested route | Grant | Sole writable areas | State |
|---|---|---|---|---|
| `n_q1_v2r_builder_mufyro9p` | T4 / claude_fable_5_1 high | `NQ1_V2R_REBUILD_GRANT.md` | `worktrees/s7-nq1/**`, `execution/cf8ff737/nq1/**`, `/home/user/pg17/**` | ACTIVE: env recovery + v2 correction rebuild, stop before PG |
| `c_phase_1_re_draft_builder_mufyro8l` | T4 / claude_fable_5_1 high | `C_PHASE1_REDRAFT_GRANT.md` | `worktrees/s7-c/**` (named paths), `execution/cf8ff737/c/**` | ACTIVE: source-only phase-1 re-draft on 61b93cff |
| `ux_04_05_06_readiness_brief_mufyro6u` | T3 / claude_opus_5_5 high | `UX04_06_READINESS_GRANT.md` | `execution/ce3748cb/ux-readiness/**` | ACTIVE read-only |
| `s8_readiness_brief_mufyro6y` | T3 / claude_opus_5_5 high | `S8_READINESS_GRANT.md` | `execution/ce3748cb/s8-prep/**` | ACTIVE read-only |

Heavy slot: `/home/user/workspace/execution/test-validation.lock` — N/Q1 builder only, for npm ci/generate.
Owner-reserved, unchanged: ext PR #27 approval (+G05 merge-committer note); backend PR #530 production promotion.
