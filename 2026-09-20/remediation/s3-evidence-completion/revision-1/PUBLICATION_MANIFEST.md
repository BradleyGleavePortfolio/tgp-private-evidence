# S3 publication manifest (for parent → private evidence archive `tgp-private-evidence`)

Candidate: growth-project-backend branch `execute/20260920-s3-backend`, head `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`, base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (public main). 23 commits, all author+committer Bradley Gleave. Held deltas: none (worktree clean at head). Checksums for every file below: `execution/s3-backend/SHA256SUMS.txt`.

Sanitization: logs scanned for connection strings, `DATABASE_URL`, bearer tokens, `sk_*`, `ghp_*`, AWS key ids, `password=`, and `secret/token/api_key=<value>` patterns — none found. Logs contain only sandbox paths (`/home/user/workspace/...`), package names/versions, test names, and structured test-log output. Fixture emails in test output are the repo's own fixtures.

## A. Candidate commits (publish as bundle; do not push to main)
| Path | Content | Size |
|---|---|---|
| `execution/s3-backend/s3-backend-5c7b42b3.bundle` | `git bundle create … main..execute/20260920-s3-backend execute/20260920-s3-backend`; incremental, requires only `c23b9d9f` (public). `git bundle verify` OK. Restore: `git fetch <bundle> execute/20260920-s3-backend`. | 104 KB |
| (not for publication) `execution/s3-backend/s3-r1-candidate.bundle` | parent's full-history checkpoint of the same head — duplicate of public history | 64 MB |

Preserved commit range includes: #524 head `238f0f1f`, #525 head `925780e0` (22 commits) + S3 `5c7b42b3` (bounded readiness). Commit list: `git log --format='%H %s' c23b9d9f..5c7b42b3` from the bundle.

## B. Reports
| Path | Content |
|---|---|
| `execution/s3-backend/REPORT.md` | builder report (identity, toolchain, selection/execution table, findings, recovery, next action) |
| `execution/s3-backend/R1_DISPOSITIONS.md` | disposition of every auditor A/B finding with log references |
| `execution/audits/s3-r1/a/REPORT.md`, `execution/audits/s3-r1/b/REPORT.md` | independent R1 audits (parent-owned; unchanged by S3) |
| `execution/s3-backend/SHA256SUMS.txt` | checksums of bundle, logs, scripts |

## C. Execution logs (`execution/s3-backend/logs/`), each with head/tree/node/npm header from `02` onward; `11`+ also stamp NODE_OPTIONS and loadavg
| Log | What | Result |
|---|---|---|
| 01-npm-ci.log | `npm ci --ignore-scripts --no-audit --no-fund`; `npx prisma generate` | exit 0 / exit 0 |
| 02-focused-a.log | 28-suite focused selection, default heap, heavy lock | 27 PASS, 1 FAIL (c12 probe ETIMEDOUT) — preserved failed evidence |
| 03-readiness-red-on-925780e.log | first red note (superseded by 16) | red |
| 04-check-r75.log | `scripts/check-r75.js --mode=range` on 925780e0..4b6385af (FAIL, `as never`) and c23b9d9f..5c7b42b3 (OK) | preserved both |
| 05-tsc.log | `tsc --noEmit` default heap | exit 134 OOM — preserved |
| 06-lint.log | `npm run lint` | 0 errors / 21 pre-existing warnings |
| 07-full-jest.log | full suite default heap in-band | exit 134 OOM after 40 PASS — preserved |
| 08-f1-diagnostic.log | c12 spec re-execution + standalone probe (first attempt exit 127 harness error preserved) | 10/10 PASS; probe 3955 ms; standalone 695 ms |
| 09-tsc-ci-env.log | `tsc --noEmit`, NODE_OPTIONS=--max-old-space-size=4096 | exit 0 |
| 10-full-jest-sharded.log | full suite, CI heap, 4 shards | all exit 0; 545 PASS / 12 pre-existing skipped; 8209 tests passed |
| 11-readiness-trio.log | three readiness specs | PASS 20/20 |
| 12-control-source-lint.log | CI control-source eslint `--max-warnings 0` | exit 0 |
| 13-build.log | `npm run build` | exit 0 |
| 14-c12-timing.log | c12 probe ×3 + spec | 474/549/456 ms; 10/10 PASS |
| 15-npm-audit.log | `npm audit --package-lock-only … --audit-level=high` | 0 vulnerabilities |
| 16-readiness-red-baseline-925780e.log | attributable red on 925780e0 / green on 5c7b42b3 | red / green |

## D. Scripts and commands (`execution/s3-backend/logs/`)
`run-install.sh` (install under heavy lock), `run-focused.sh`, `run-step.sh`, `run-step2.sh` (lock-serialized step runners; header stamping), `run-chain.sh`, `run-chain2.sh`, `run-chain3.sh` (step sequences), `run-full-sharded.sh` (4-shard full suite), `f1-diagnostic.sh`, `c12-timing.sh` (probe body embedded in 14-c12-timing.log). Probe sources used ad hoc: `/tmp/f1-probe.js` (printed verbatim in `14-c12-timing.log`), `/tmp/readiness-red.ts` (printed verbatim in `16-…log`) — the log copies are canonical; the `/tmp` files are sandbox-transient.

## E. Paths outside `execution/s3-backend/` referenced by this work
- `worktrees/s3-backend` (builder worktree, head 5c7b42b3; `node_modules` 717 MB not for publication)
- `worktrees/audit-s3-r1` (frozen read-only R1 snapshot, same head; parent-owned)
- `execution/heavy-validation.lock.holders`, `execution/test-validation.lock.holders` (shared lock timelines; S3 entries labelled `S3 …`)
- `execution/FLY_RUNTIME_METADATA.md` (parent; deployed baseline image reference, read only)
- Temporary detached checkout `worktrees/s3-red-925780e` created for log 16 and removed afterwards (`git worktree remove`).

## F. Not included / not done
No main push, merge, deploy, flag, hosted-settings change, or production query. RLS suites and Docker/Fly behaviour not executed. No audit clearance is claimed by S3.
