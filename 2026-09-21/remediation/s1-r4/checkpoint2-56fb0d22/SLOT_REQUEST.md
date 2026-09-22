# S1 R4 slot request (smallest plan) — awaiting parent-named slot; nothing executed yet

Preferred: NO separate slot — S2 runs `test/db/s1-r4-truncate-discriminator.sh` on its own protected fixture inside its
lock-bearing wrapper (see INTEGRATION_FOR_S2.md). Only if the parent prefers an S1-owned run:

| field | value |
|---|---|
| source | worktree `/home/user/workspace/worktrees/s1-r4`, branch `execute/20260921-s1-r4`, head `41f4d6a985e5037bf53831a38ed00a9a4314cf7d`, tree `8ab0eb9e942686896a0039038a2d3bbbe2aa4b06`, porcelain clean (0 lines) at request time |
| commands | (a) fixture: preserved `infra/s1-fixture.sh init && start` pattern from the S1 R3 packet (PG 17.6 zonky embedded binaries, `cluster_name=s1-disposable-pg17`, datadir under `/home/user/pg17/clusters/`, 127.0.0.1:54321, superuser `s1_super`); (b) `npm ci --ignore-scripts` in the worktree pinned by `package-lock.json` sha256 `62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390` (Prisma CLI 6.19.3, expected CLI sha256 `c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0`); (c) `run-proof.rev2.sh`-style wrapper: clean check → `s1_guard_offline` → `flock -n` on `/home/user/workspace/execution/test-validation.lock` (fd 9) → `s1_guard_preflight` → stamps → `timeout --foreground 1500 bash test/db/s1-rls-close-public-exposure.sh s1_rls_r4proof` (full 128-check harness incl. §4b) → then `timeout --foreground 300 bash test/db/s1-r4-truncate-discriminator.sh s1_rls_r4proof` with `S1_R4_LOCK_HOLDER` set (standalone entry point on DB1's protected end state) → `infra/s1-fixture.sh destroy` |
| dependency provenance | node v20.20.1 (host `/usr/local/bin/node`); Prisma from lockfile above; PostgreSQL 17.6 via the same zonky artifacts recorded in the S1 R3 packet (or the parent's approved fixture); psql client as in run 4 (18.6) or whatever the fixture provides — stamped |
| target identity | loopback 127.0.0.1:54321, databases `s1_rls_r4proof` and `s1_rls_r4proof_lock` only, confirmation literal `DESTROY-127.0.0.1:54321/s1_rls_r4proof,s1_rls_r4proof_lock`; guard refuses anything else (exit 64) |
| duration / resources | harness ≈ 3–6 min (run 4 baseline) + discriminator ≈ 1–2 min; ceilings 1500 s / 300 s; 2 CPU / < 1 GB RAM; disk ≈ 300 MB (PG binaries + node_modules) |
| negative controls | guard offline spec (72 cases) unchanged; harness §3b–§3e and §8 as before; NEW: predecessor verifier exit 0 vs current non-zero under C1 and C3 drift, rollback-only TRUNCATE probe (42501 without grant, 00000 with), effective-only PUBLIC case with 0 direct ACL entries |
| artifact destinations | `/home/user/workspace/execution/s1-r4/runs/<utc>/{wrapper.log,harness.log,harness.detail.log,discriminator.log,discriminator.detail.log,exit-codes.txt}`; hashes appended to `SHA256SUMS`; report update `REPORT.md` |
| what a pass proves | S1-R3-A-01 closed on PG 17.6 synthetic fixture with both verifier routes; prior 89 checks still green at the successor head |
| what it does not prove | live/hosted role facts (S1-A-06), PG 15 behaviour (S1-R3B-04), release.sh gate wiring (S1-R3B-02), verifier topology completeness (S1-A-07) |
