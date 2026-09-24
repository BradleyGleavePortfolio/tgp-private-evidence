# Owner authority amendment: autonomous landing and backlog merge

Received September 24, 2026 at 09:26 PDT (16:26Z), from Bradley, verbatim in the session transcript. It applies both going forward and retroactively.

## What is now authorized

The parent may push, open or update PRs, merge, verify the remote head, record and continue, with no routine return to Bradley. This applies to any product work that meets all of these conditions:

- it has reached its exact defined acceptance boundary;
- its deterministic gates have passed;
- its real database or runtime proof has passed, where one is required;
- its required independent review is done;
- it has no open A or B finding;
- it is dependency-valid against its landing base.

C findings never block landing.

The accepted backlog must also be landed, applying these rules:

- Collapse superseded slices into the smallest dependency-correct accepted composition.
- Do not re-audit, rerun or re-review unchanged accepted bytes.
- If landing itself changes bytes, classify only that delta.

## Still reserved

These still need Bradley:

- production deployment
- customer enablement
- destructive production mutation
- live source-account operation
- security or governance change
- external commitment
- new spending

A merge that auto-triggers production deployment is not ordinary landing.

## Parent determination of deploy triggers (live remote, 16:30Z)

### Backend `growth-project-backend`, main `c23b9d9f`

**A push to main deploys to production.** `.github/workflows/fly-deploy.yml` triggers on push to `main` and deploys to Fly app `backend-spring-lake-3890`. The deploy's `fly.toml` `release_command = "bash ./scripts/release.sh"` runs `prisma migrate deploy` against the production database.

`release-please` and `sbom` also run on main. No workflow deploys from any other branch; the `fly-*-set` workflows are dispatch-only and production-only.

**Decision:**

- **No decoupling.** Changing the production deploy trigger would be a deployment/governance change, so the parent will not decouple it.
- **Land on an integration branch.** Backend work lands on the non-production integration branch `integration/importer`, created from current main. Pull requests target it, so PR CI runs there, including `migration-dry-run` on postgres:15.
- **Only the main merge goes to Bradley.** The one remaining owner boundary is `integration/importer` → `main`, because that merge is the production deploy and runs migrations.

### Mobile `growth-project-mobile`, main `a5933fd6`

The only workflows are CI and CodeQL. `eas.json` has build profiles only, and `app.json` has no `updates` channel, so there is no over-the-air update from main.

**Decision:** merging to main is ordinary landing.

**Qualification (C):** an out-of-repo Expo dashboard build-on-push trigger cannot be seen from the repo. None is evidenced.

### Extension `tgp-importer-extension`, main `0111be66`

The only workflows are CI on all branches and CodeQL. The CI "Deploy readiness board" step is only a check script. Nothing publishes to a store.

**Decision:** merging to main is ordinary landing.

## Execution

1. **Backlog census.** A read-only T3 landing census maps each accepted boundary to the remote PRs and branches, current main, supersession and conflicts, and produces the smallest dependency-correct landing plan.
2. **Remote writes.** These stay with the parent. They are always ordinary pushes: no force, Bradley as author and committer, no AI trailers.
3. **Order.** Backend follows S1–S6 → S7 foundation/C1/B → R → N/Q1 → C, and so on. UX lands independently once its dependencies are met.
