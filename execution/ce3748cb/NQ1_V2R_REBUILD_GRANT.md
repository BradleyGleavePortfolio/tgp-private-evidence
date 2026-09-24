# N/Q1 v2r — environment recovery + v2 correction rebuild grant (T4)

Parent EXEC-CE3748CB, ~20:15Z. Supersedes nothing accepted. Reuses `execution/cf8ff737/NQ1_V2_MINIMUM_CORRECTION_GRANT.md` (the four corrections, stop condition, gates) verbatim as the product/spec authority. The lost head `8c33e00f` design (predecessor turn 43) is guidance, not a pin.

## Sole writer / owned paths
- `/home/user/workspace/worktrees/s7-nq1/**` (branch `s7-nq1`, HEAD 61b93cff, recovered byte-exact)
- `/home/user/workspace/execution/cf8ff737/nq1/**` (receipts continue at 16+; v1 files never edited)
- `/home/user/pg17/**` (tooling install only; `clusters/nq1` created fresh by the fixture at the PG grant)
- `/home/user/workspace/execution/cf8ff737/nq1/env/**` (new: environment recovery receipts)

## Phase E — environment recovery (mechanical, deterministic)
1. PG17: reuse `2026-09-22/remediation/s2-setup-prep/proposal-1/infra/setup-20-pg17.sh` logic (or equivalent): download the pinned Maven jar, verify jar/txz sha, extract to `/home/user/pg17/dist`, verify `postgres` sha `23cd1748…` and `initdb` sha `b7db9bc2…`. Mismatch = STOP and report.
2. `/usr/bin/psql` client (setup-10-clients.sh logic; apt `postgresql-client` acceptable). Record version.
3. Isolated node_modules for the worktree per the N/Q1 receipt-02/03 method: `npm ci` from the committed lock, verify `node_modules/.package-lock.json` sha `05bc530a…`, then N-only `prisma generate`, verify client `index.d.ts` sha `92d42c56…`. Mismatch = STOP and report.
4. Heavy-slot: take `/home/user/workspace/execution/test-validation.lock` (flock -n) for npm ci and generate; release after.

## Phase V — v2 correction (spec/harness only)
Exactly the four corrections of the v2 grant, paths `test/rls-g2-nq1.spec.ts` and `test/utils/g2-nq1-*` only. Genuine non-success path: the product's own unmapped canonical platform → `skipped` / `unsupported_platform:<token>`; expectations derived from fixture + product logic. One ordinary lefthook-hooked commit on 61b93cff, author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, `NODE_OPTIONS=--max-old-space-size=4096`. Light gates (tsc, eslint, prettier, check-r75) on touched files. No PG run.

## Binding
Refill HEAD/TREE/SPEC (and any changed harness blob) pins in `nq1/binding/nq1-pg-proof.sh`, keep v1 copy, reseal `BINDING.sha256`. Donor clusters `s5/c1-builder/b-drain/r-ready` no longer exist (sandbox loss): if the runner's preflight requires their presence, the minimum closure is a mechanical edit recording them as absent-and-never-started (hash `ABSENT`), marked in `PINS.txt`; no other runner change. Export `nq1/export/nq1-v2r-<sha>.{bundle,patch}` + sha file (bundle must include the full chain from 7d2895e1).

## Deliverable / stop
Write `nq1/SOURCE_READY_V2R.md` (head, tree, diffstat, gates, env receipts, binding sha, runner delta if any) and STOP. The PG run is a separate grant after two independent delta attestations. Do not push. Do not touch other worktrees or lanes.
