# N0 build report — publish north star docs

Date: 2026-09-27  
Author: Bradley Gleave <bradley@bradleytgpcoaching.com>

The canonical `NORTH_STAR.md` was copied byte-for-byte from this evidence directory into each target repository. Each repository has one docs-only commit on `docs/north-star`, one non-force push, and one open pull request. No pull request was merged.

| Repository | Base | Head SHA | Pull request |
| --- | --- | --- | --- |
| `tgp-agent-context` | `main` | `5c8a322518988bd12dbad9dc57bfa9c44ee87558` | https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/36 |
| `tgp-importer-extension` | `main` | `d8fd80decb40a464144ec8db17464175ab87b1a6` | https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/31 |
| `growth-project-backend` | `integration/importer` | `9435afef9a013831304f9b677da381c9d1a89988` | https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/572 |
| `growth-project-mobile` | `main` | `c54dd40542a16517d9620fc930c806aa7886339d` | https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/298 |

## Canonical copies

- `tgp-agent-context/NORTH_STAR.md`
- `tgp-importer-extension/docs/NORTH_STAR.md`
- `growth-project-backend/docs/importer/NORTH_STAR.md`
- `growth-project-mobile/docs/importer/NORTH_STAR.md`

## Files receiving the superseded banner

### `tgp-agent-context` (PR #36)

- `DECISION_LOG.md`
- `audit_briefs/M-NEW-PROFILE-TRUECOACH_BUILDER_BRIEF.md`
- `audit_briefs/M-NEW-RECONCILER_BUILDER_BRIEF.md`
- `audit_briefs/M-NEW-SUBSTRATE-A_BUILDER_BRIEF.md`
- `handoffs/2026-06-27-M-plan-full-reconstruction.md`
- `handoffs/2026-06-27-op-50.5-next-agent-handoff.md`
- `handoffs/2026-06-27-op-50.5-sandbox-death.md`
- `handoffs/HANDOFF_AGENT_51_FROM_AGENT_50.md`
- `handoffs/HANDOFF_AGENT_52_FROM_AGENT_51.md`
- `handoffs/importer-wave/IMPORTER-I_BUILD_BRIEF.md`
- `handoffs/importer-wave/OPERATOR_HANDOFF.md`
- `handoffs/importer-wave/V5_MULTI_ADAPTER_BUILD_BRIEF.md`
- `handoffs/importer-wave/product-ideas-importer-wave.md`
- `handoffs/op74/OWNERSHIP_AND_PR_LADDER.md`
- `handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md`
- `handoffs/op81/audits/astra-r2.md`
- `handoffs/op81/audits/plan-r1.md`
- `handoffs/op81/audits/plan-r2.md`
- `planning/M-NEW-LIVE-scout-proposal.md`
- `planning/M_PLAN_REALITY_CHECK_v2.md`
- `roadmap/M-IMPORTER-EXTENSION_v1.md`
- `roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md`
- `roadmap/OPERATOR_DECISIONS_LOG.md`
- `roadmap/OPERATOR_DECISIONS_LOG_op50.5_appendix.md`
- `roadmap/OPERATOR_DECISIONS_LOG_ruling9.md`
- `roadmap/rulings/R-IMPORTER-AUTONOMY-1_2026-07-27.md`
- `roadmap/rulings/R-SITE-AGNOSTIC-1_2026-07-20.md`
- `roadmap/rulings/R-V5-PR3-1_2026-07-21.md`
- `roadmap/specs/A02-import-tooling.md`

### `tgp-importer-extension` (PR #31)

- `docs/AUTO_DISCOVERY.md`
- `docs/DESIGN.md`
- `docs/REAL_GOAL_EXECUTION_PLAN.md`
- `docs/ROADMAP.md`
- `docs/first-principles.md`

`docs/export-recipes/` contained only `.gitkeep` and no document files, so there was no document to banner there.

## Pointer-only files

- `growth-project-backend/docs/decisions/2026-09-26-s10-induction.md`
- `growth-project-backend/docs/decisions/2026-09-26-s11-journey.md`
- `growth-project-mobile/docs/importer/MOBILE_IMPORT_DECISION.md`
- `growth-project-mobile/src/screens/coach/import-journey/README.md`

No code, tests, package files, schemas, contracts, runtime behavior, or privileges were changed.
