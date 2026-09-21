# S2 composition — guarded execution plan (SLOT REQUEST 02: disposable PG17.6 proof) — nothing executed yet

Prerequisite: SLOT REQUEST 01 (`SLOT_REQUEST_01_setup.md`) completed — psql client, PG 17.6 dist at `/home/user/pg17/dist`
(SHA256-matched to S1's provenance), `npm ci` + `prisma generate` in `worktrees/s2-composition`. If the parent shares one
PG17.6 acquisition/psql install across lanes, S20/S10 are satisfied by that and only S30 (npm ci in this worktree) remains.

## 1. Source / tree / dirty fingerprint (frozen for this plan)
| item | value |
|---|---|
| worktree / branch | `/home/user/workspace/worktrees/s2-composition` · `execute/20260921-s2-composition` |
| **head** | `9742037b153221de565e651ad8ba3b721bc0fb31` |
| **tree** | `5469fbefcdbb7001151e7a02084951e3c57a5dfe` |
| lineage | `c23b9d9f` (public main) → `e15e25c2` (S2 frozen) + `b7d7fe59` (S1 frozen) → merge `0af39f6c` (tree `3d494b74`, = recorded merge-tree) → `eb6904d1` (S2 harness commit) + `41f4d6a9` (S1 R4 frozen, tree `8ab0eb9e`) → `9742037b`. b7 remains in history (S1 discriminator's fail-closed predecessor lookup works). |
| clean | 0 porcelain lines (with untracked). Runner refuses otherwise. |
| identity | all 4 new commits author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers (`bundle/commits.txt`) |
| byte identity | S1-owned: verify.sql `266e62e9…9448` (S1 R4), migration/down/guard/bootstrap = b7d7fe59 = 41f4d6a9; predecessor verify at `b7d7fe59:` = `2bbce0d7…323e`. S2-owned: release.sh `9908234e…f80ac`, contract file, Dockerfile = e15e25c2. |
| lockfile | `package-lock.json` sha256 `62b05b90…1390` (Prisma 6.19.3) — unchanged across all parents |
| S2 harness | `test/release/s1s2-composition.sh` sha256 `499b3836…cb56` (S2-owned, in tree) |

## 2. Commands (single runner; all under ONE nonblocking `flock -n` hold on `/home/user/workspace/execution/test-validation.lock`, fd 9, exit 75 if busy)
`bash /home/user/workspace/execution/s2-composition/run-composition-when-granted.sh` — steps, each exit preserved:
| step | what | DB contact | bound |
|---|---|---|---|
| stamp | head/tree/dirty, node/npm/psql/postgres/prisma versions, prisma CLI sha256, lock sha, install stamp; refuses on head ≠ `9742037b`, dirty, lock hash, missing psql/prisma | none | s |
| 10 | S1 offline guard spec `test/db/s1-harness-guard.spec.sh` (72 stubbed cases) | none | 120 s |
| 20/21 | harness-level refusals: hosted-looking URL → must exit 64; correct loopback URL without confirm literal → exit 64 (before any server exists) | none | s |
| 30/31/32 | `infra/s2-fixture.sh init` (first time) / `start` / `status`: PG 17.6 from `/home/user/pg17/dist`, data dir `/home/user/pg17/clusters/s2comp`, `listen_addresses=127.0.0.1`, port **54321**, `cluster_name=s1-disposable-pg17` (guard marker), superuser `s1_super` (synthetic pw). No databases created. | server start only | 60 s |
| 40 | `timeout --foreground 1500 test/release/s1s2-composition.sh s1_rls_s2comp` — guard offline → guard preflight (read-only, one connection) → C0/C0b (no DB) → P (DROP/CREATE `s1_rls_s2comp`, `s1_rls_s2comp_lock`; bootstrap; REAL `prisma migrate deploy` of the 164 parent dirs as `postgres`; `rls_fitness_backend.sql`) → C1 C2 C3 C4 C5 C5r C7 C8 (see harness header) | destructive, only the two named DBs | 1500 s |
| 45 | (only if 40 passed) S1-owned `test/db/s1-r4-truncate-discriminator.sh s1_rls_s2comp` on the protected end state, `S1_R4_LOCK_HOLDER` stamped, `S1_PRISMA_CLI` = worktree prisma | GRANT/REVOKE TRUNCATE on `"MuxProcessedEvent"`, rolled-back TRUNCATE; restored | 300 s |
| 50 | fixture stop (data dir kept unless parent asks to destroy); `SHA256SUMS` of the run dir | — | s |
Expected total ≈ 4–8 min on 2 vCPU (two full 164-migration replays ≈ 1–2 min each; 9 release.sh runs; C7 waits for the 5 s lock_timeout).

## 3. Dependency provenance
node v20.20.1 (host), Prisma CLI 6.19.3 from the pinned lockfile (`npm ci --ignore-scripts`, explicit `prisma generate`, engines `c2990dca…`), PG 17.6 zonky `embedded-postgres-binaries-linux-amd64-17.6.0` with SHA1 `81633223…65db` and S1-recorded SHA256s (jar `23da5a04…`, postgres `23cd1748…`, initdb `b7db9bc2…`), psql = apt `postgresql-client-18` (as S1 run 4) — all stamped actual, not assumed.

## 4. Target identity (guard-enforced BEFORE connection; refusals proven offline in `offline-refusals/R1–R9`, all exit 64, no /tmp artifacts)
Literal `127.0.0.1` only; port pinned 54321; DB names `s1_rls_s2comp`, `s1_rls_s2comp_lock` (`^s1_rls_[a-z0-9_]{1,40}$`); confirm literal `DESTROY-127.0.0.1:54321/s1_rls_s2comp,s1_rls_s2comp_lock`; preflight requires PG 17.x, superuser, `cluster_name='s1-disposable-pg17'`, data dir under `/home/user/pg17/clusters/`, no foreign DBs, fixture role flags. App URLs use the bootstrap's synthetic `postgres`/`postgres_local_synthetic` (non-superuser BYPASSRLS — the S1 production analogue). No hosted/customer URL exists anywhere in the lane; nothing pushes.

## 5. Negative controls inside the proof
C0/C0b refusal without DB contact (asserts no `step 1:`, no P1001, no migrate log); C3 out-of-band down.sql → status "up to date" yet release exits 1 with S1 EXPOSURE text; C5 allowed-path revoke → exit 1 with ALLOWED-PATH text; C7 real Prisma P3018/55P03 failure → non-zero, failed ledger row, pre-state intact; plus guard refusals and the S1 R4 predecessor-vs-successor discriminator. Any `check` mismatch → harness exit 1; runner exit non-zero; no success artifact is produced on failure.

## 6. Artifact destinations
`/home/user/workspace/execution/s2-composition/composition/<UTC stamp>/` — `stamp.txt`, `lock.txt`, `10-guard-spec.log`, `20/21-refusal-*.log`, `3x-fixture-*.log`, `40-composition.log`, `harness/` (harness.log, `C*.release.log`, per-control captured `/tmp/prisma_*.log` + `release_verifiers_discovered.txt`, `P1/P2.parent-deploy.log`, `C1v.verify-psql.log`, `C8.resolve.log`), `s1-r4/s1-r4-discriminator{,.detail}.log`, `exit-codes.txt`, `SHA256SUMS`. S1 R4 gets its discriminator logs by path (no copy into `execution/s1-r4/` by S2).

## 7. Not proven by this plan (stated up front)
PG 15.18 / CI bootstrap behaviour, hosted serving-role facts (S1-A-06), production backup/PITR, deployment clearance, verifier topology completeness (S1-A-07). Prior S2 exact-head evidence (jest/fake-prisma/lint at e15e25c2) and S1 89-check evidence (b7d7fe59) bind to their parents, not to `9742037b`.
