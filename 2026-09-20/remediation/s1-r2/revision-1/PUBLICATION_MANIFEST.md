# S1 T4 publication manifest (for parent → PRIVATE tgp-private-evidence)

Everything needed to recover, re-run and re-audit S1-DB-01 without this sandbox. Contains no real secrets,
credentials, customer data or production identifiers other than the already-documented Fly machine/image ids
in the packet (`DATABASE_URL` values in logs are the synthetic fixture only; screened: 0 hits for non-synthetic
hosts/tokens). Backend repo is PUBLIC — do not push the candidate branch there; ship the bundles privately.

## A. Source commits (git bundles — require ONLY public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`)
| File | sha256 | Contents |
|---|---|---|
| `bundles/s1-database-R1-620b47f.bundle` | `1fdc1213ea3a2c8920240ec39cfbefd61af2f980a4e1e621e60a4aaa5e7e5fbf` | frozen R1: `620b47fc…` (tree `e9fc265e…`), audited by A/B |
| `bundles/s1-database-R2-90a6647.bundle` | `0ffd66f12e95c082871942f885e07591d4f80992e8039a9cbb8a02cb14ef066c` | R2 remediation: `90a66475…` (tree `01c7fba4…`), parent 620b47fc; **supersedes R1** (contains both commits) |

`git bundle verify` on each prints "requires this ref: c23b9d9f…" and nothing else (checked). Recovery:
```
git clone https://github.com/<public backend> tgp-backend && cd tgp-backend
git fetch /path/s1-database-R2-90a6647.bundle execute/20260920-s1-database:execute/20260920-s1-database
git checkout execute/20260920-s1-database && git rev-parse HEAD   # 90a6647513f3566393764eee87237d9b5b1f150b
```
Commits: author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author trailers.
Changed vs base (5 files, +908): `prisma/migrations/20261224000000_rls_close_public_exposure/{migration,verify,down}.sql`,
`test/db/_support/supabase-like-bootstrap.sql`, `test/db/s1-rls-close-public-exposure.sh`.

## B. Reports / dispositions (this directory)
`REPORT.md` (handoff), `R1_FINDINGS_DISPOSITION.md`, `RUNTIME_ROLE_VERIFICATION_PACKET.md` (rev 2) + `whoami-db-role.js`
(sha256 `1bb859251aee15105e9d0d856ea102521e0fefe0d57036137833d760baca7090`), `MILESTONE-01-infra.md`, `MILESTONE-02-R1-frozen.md`,
`CHECKPOINT-03-remediation-started.md`, `PG17_INFRA.md`.

## C. Evidence logs (head-bound)
| File | Bound to | Result |
|---|---|---|
| `replay-main-c23b9d9.log` | worktree at 620b47fc (candidate included) | 165 migrations from empty on PG 17.6 as non-superuser BYPASSRLS `postgres`, exit 0 |
| `held-620b47fc/proof-run-01.log` (+ `proof-run-01.detail.log`) | 620b47fc + untracked R1 harness (`held-620b47fc/…r1-untracked`) | 37/13 — harness defects, verify.sql array bug, missing fixtures; first observation of resolve --rolled-back no-op |
| `proof-run-02.log`, `proof-run-03.log`, `proof-run-04.log` (+ `.detail.log`, schema dumps) | 620b47fc **+dirty** (R2 work in progress) | 53/15 → 67/1 (pg_dump `\restrict` tokens) → 68/0 |
| **`proof-run-05-head-90a6647.log`** (sha256 `c113512cb5d180ab9a5ad2c3b2608877bf042c906bbcd2c24132cf22f8642e79`) + `.detail.log` + `.schema-forward1/2.sql`, `.schema-after-down.sql` | **90a66475, clean tree** | **68 passed, 0 failed, server 17.6** |
The `*.schema-*.sql` dumps are the full synthetic schema (~700 KB each; public-repo schema, no data) — keep at least the run-05 set for the parity evidence.

## D. Synthetic infrastructure recreation (outside workspace)
`infra/RECREATE_PG17_SYNTHETIC.md` — download URL (Maven Central zonky `embedded-postgres-binaries-linux-amd64:17.6.0`),
jar sha1 `8163322358dbe4e6c2abccc90f2e543f8cfc65db`, extraction, client tools, cluster script usage, exact proof command.
`infra/lane-pg.sh` (sha256 `f860261c42a0ec875c51bfe7f4ff477fb963885955a0926b1ffe7160721c8345`; portable via `PG17_HOME`, default `~/pg17`).
Not included by design: PG binaries, cluster data directories, node_modules.

## E. Runner scripts used in the sandbox (documentary; contain sandbox paths)
`run-replay.sh`, `run-proof.sh` (+ `run-replay.nohup`) — wrappers that took `execution/test-validation.lock` and wrote the logs above.

## F. Held deltas
None outstanding: the R1-time untracked harness is preserved under `held-620b47fc/` and its remediated form is committed in 90a66475. Worktree is clean at 90a66475.
