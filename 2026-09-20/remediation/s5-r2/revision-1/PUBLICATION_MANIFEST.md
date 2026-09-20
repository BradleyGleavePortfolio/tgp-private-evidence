# S5 G2 — publication manifest (for the parent, sole archive/handoff writer)

Everything listed lives under `/home/user/workspace/execution/s5-g2/` unless stated. Excluded by design: `node_modules` (any), PostgreSQL cluster data (`/home/user/pg17/clusters/*`), secrets (the lane-s5 fixture password is env-only; it appears historically only in `run-proof.sh.held-delta` line 11 — redact or drop that file, see below).

## 1. Candidate commits (branch `execute/20260920-s5-g2`, worktree `/home/user/workspace/worktrees/s5-g2`)
| # | commit | tree | note |
|---|---|---|---|
| 1 | `65b1da27d9dab4f51f5fad6d8a05be8b64e53dde` | `9bbc0223e809e8e9b10b541bbde98b11903be362` | R1 audit snapshot (= `785d9022`) |
| 2 | `5270e103cd5d051405e74dbb0e32796ac07b4964` | `1c06cdfa03365d396ab1055dabb491d2efd8ec25` | role matrix / non-superuser migrator / fail-fast runner / E negatives |
| 3 | `485c67973b56758fb9b8404579f5ddaec87136bd` | `2fbf5028413557f99faea3f1de27b1352a4fe8d4` | **HEAD** — observed-behaviour expectations, deterministic lock holder, worker handshake |
Base `d7404cd4` (#529) on public prerequisite `c23b9d9f` (backend main). Author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` on all three.

## 2. Bundles (prerequisite `c23b9d9f` only; verify with `git bundle verify <file>` inside a clone containing c23b9d9f)
- `s5-g2-candidate.bundle` — `c23b9d9f..execute/20260920-s5-g2` → HEAD 485c6797 (28 commits incl. #525/#528/#529 chain). Verified "okay".
- `s5-g2-candidate-checkpoint-1124.bundle` — incremental checkpoint to 5270e103 (11:24 PDT). Verified.

## 3. Scripts / recreation
- `run-proof.sh` — proof runner (stages `guard|bootstrap|live|all|reset`; requires `G2_PG17_PASSWORD`; takes `execution/test-validation.lock`). `run-proof.sh.resume-v2` identical copy. `run-proof.sh.held-delta` — R1-era version, **contains the fixture password inline (line 11): redact before publication or omit** (superseded).
- `npm-ci.sh`, `npm-ci-secondary.sh` — worktree `npm ci --ignore-scripts` + `prisma generate` under the install locks (parent 09:40 exception).
- In-repo (candidate commits): `test/utils/g2-pg17-bootstrap.sh`, `test/utils/g2-pg17-db.ts`, `test/utils/g2-pg17-harness.ts`, `test/scout/g2-pg17-db-guard.spec.ts`, `test/rls-g2-pg17-etq0.spec.ts`, `test/utils/g2-tq0-worker.cjs`.
- Old-writer fixture (NOT to be published as-is: 25 MB + 46 MB incl. Prisma engine binary; `old-root-925780e0/node_modules` is a symlink into the worktree):
  - `old-root-925780e0/` = `git archive 925780e0 | tar -x -C old-root-925780e0` plus `ln -s <worktree>/node_modules old-root-925780e0/node_modules`.
  - `old-client-925780e0/` = Prisma client generated from the 925780e0 schema with `generator client { output = "<abs>/old-client-925780e0" }` added (`npx prisma generate --schema <that copy>`); the spec asserts `old-client-925780e0/schema.prisma` and `old-root-925780e0/src/scout/*` match `git show 925780e0:…`.
  - Recreation steps are documented from evidence (schema diff shows only the `output` line); not re-executed in this lane.
- Infrastructure (S1-owned, cite only): `execution/s1-database/PG17_INFRA.md`, `/home/user/pg17/lane-pg.sh s5 <start|stop|status|url>`.

## 4. Logs (`logs/`) — publish ALL, failed and passed
Passed: `run-proof-all-resume7.out` + `{guard-unit,bootstrap,live-etq0,env-all,exit-all,pg-status}-20260920T184713Z.log` (50/50, PROOF_EXIT=0); confirmation on clean HEAD 485c6797: `run-proof-all-resume8-clean-head.out` + `*-20260920T185210Z.log` (result in REPORT addendum).
Failed (explained, kept): `run-proof-all-resume.out`, `run-proof-all-resume2.out`, `run-proof-all-resume3.out`, `run-proof-live-1.out`, `run-proof-live-2.out`, `run-proof-all-resume4.out` (182819Z), `run-proof-all-resume5.out` (183610Z), `run-proof-all-resume6.out` (184148Z) with their `*-<TS>.log` companions (181433Z, 181540Z, 181632Z, 181914Z, 182017Z, 182819Z, 183610Z, 184148Z). Resets: `run-proof-reset*.out`, `reset-*.log`, `env-reset-*`, `exit-reset-*`. R1 pre-resume: `bootstrap.log`, `live-etq0.log`, `env.log`, `exit-all.log`, `guard-unit.log`, `npm-ci.log`.
Logs contain no password (URLs are `postgresql://<role>@127.0.0.1:54325/...`, password from env); they contain synthetic fixture identifiers only.

## 5. Reports / dispositions / checkpoints
`REPORT.md` (final), `FINDING_DISPOSITIONS.md`, `CHECKPOINT-resume-1057.md`, `CHECKPOINT-1124.md`, `MILESTONE-R1-checkpoint.md`, `held-delta-post-65b1da27.patch` (R1 held delta, superseded by commits 2–3; contains no secrets). R1 audits: `execution/audits/s5-r1/{a,b}/REPORT.md` (parent-owned).

## 6. Not included / not produced
No R2 audit (not performed by S5; no clearance claimed). No production/hosted evidence. No customer data. No changes to S1-owned files; S1 escalations are listed in `REPORT.md` §Findings.
