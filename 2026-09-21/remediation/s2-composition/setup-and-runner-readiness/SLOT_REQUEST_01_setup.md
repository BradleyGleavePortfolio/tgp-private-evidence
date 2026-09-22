# S2 composition — SLOT REQUEST 01: setup-only (no DB server, no DB connection, no proof)

Requester: S2 R3 composition builder (requested model Claude Fable 5 / High; actual runtime identity not
observable from inside the sandbox). Sole writer of `worktrees/s2-composition` and `execution/s2-composition`.
Lock: `/home/user/workspace/execution/test-validation.lock`, `flock -n` per step (exit 75 if busy, never waits);
lock released between steps. Nothing here touches hosted/provider/customer endpoints, pushes, or S1 source.

## Source fingerprint (re-verified 2026-09-21 23:4xZ)
| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/s2-composition`, branch `execute/20260921-s2-composition` |
| head (final composition) | `9742037b153221de565e651ad8ba3b721bc0fb31` — merge of `eb6904d1` (S2 harness on the e15e25c2+b7d7fe59 merge `0af39f6c`) with frozen S1 R4 `41f4d6a985e5037bf53831a38ed00a9a4314cf7d` |
| tree | `5469fbefcdbb7001151e7a02084951e3c57a5dfe` (0 conflicts at every merge; S1/S2 paths disjoint from base `c23b9d9f`) |
| author/committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both (verified `git var` before, `%an/%ae/%cn/%ce` after) |
| clean | yes (`git status --porcelain --untracked-files=all` = 0 lines) |
| package-lock.json sha256 | `62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390` (identical at base, S1 head, S2 head, merge) |
| S1 content | all S1-owned paths blob-identical to frozen S1 R4 `41f4d6a9` (verify.sql `266e62e9…9448`); migration/down/guard/bootstrap also identical to `b7d7fe59`, which remains in history |

## Steps requested (serial, each under its own nonblocking lock hold; total ≈ 6–10 min on 2 vCPU)
| # | command (cwd `/home/user/workspace`) | provenance / checks | bounds | output |
|---|---|---|---|---|
| S10 | `execution/s2-composition/infra/setup-10-clients.sh` | Ubuntu apt `postgresql-client-18` (same as S1 step 10; psql 18.6 was the client used in S1 run 4). `sudo -n` only. Refuses client < 17. | timeout 600 s update + 900 s install; network: apt | `execution/s2-composition/infra/logs/setup-10-clients-<utc>.log` |
| S20 | `execution/s2-composition/infra/setup-20-pg17.sh` | Maven Central `embedded-postgres-binaries-linux-amd64-17.6.0.jar`; Maven `.sha1` must equal pinned `8163322358dbe4e6c2abccc90f2e543f8cfc65db`; **additionally** jar/txz/postgres/initdb SHA256 must equal S1's recorded `PG17_PROVENANCE.txt` (`23da5a04…`, `26fa6334…`, `23cd1748…`, `b7db9bc2…`) or the step refuses (exit 70). Extract only to `/home/user/pg17/dist`; no server started. | timeout 300 s download; ≈ 40 MB | log + `/home/user/pg17/PROVENANCE.txt` |
| S30 | `execution/s2-composition/infra/setup-30-npm-ci.sh` | in `worktrees/s2-composition`: refuses unless head = `9742037b153221de565e651ad8ba3b721bc0fb31` **and** lock sha256 = `62b05b90…` **and** clean; `npm ci --ignore-scripts --no-audit --no-fund` (npm registry per lockfile integrity hashes), then explicit `node node_modules/prisma/build/index.js generate` (downloads engines `c2990dca…`; records CLI sha256, expected `c2a77456…` per S1 log — actual recorded, mismatch reported not hidden); requires clean tree after (node_modules is git-ignored). | timeout 1500 s + 600 s; ≈ 1 GB disk (9.4 GB free) | log + `node_modules/.s2-composition-install-stamp` |

Not in this slot: `initdb`/server start, any `psql` connection, any `prisma` DB command, the composition proof. Those
come in SLOT REQUEST 02 (`GUARD_EXECUTION_PLAN.md`) once S30 is done. S20 is the shared PG 17.6 acquisition (dist only at
`/home/user/pg17/dist`, no initdb/server); other lanes may consume the same dist.

## Negative controls inside the setup steps
- S20 refuses on SHA1 mismatch, SHA256 mismatch vs S1 provenance, or `postgres --version` ≠ 17.6.
- S30 refuses on wrong head, wrong lockfile hash, dirty tree before or after install.
- Every step preserves the child exit code; a busy lock exits 75 without waiting.

## Artifact destinations
`execution/s2-composition/infra/logs/*.log`, `/home/user/pg17/PROVENANCE.txt`, install stamp in the (git-ignored) `node_modules`.
