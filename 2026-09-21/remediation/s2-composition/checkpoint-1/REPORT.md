# S2 R3 composition builder — status report (source composed, harness written, NO heavy slot used, proof UNRUN)

Builder: S2 composition builder (requested model Claude Fable 5 / High; the actual runtime model identity is not
observable from inside the sandbox and is reported as requested-only). Sole writer of `worktrees/s2-composition` and
`execution/s2-composition`. No S1 source edited; no installs, DB, server, browser, push or hosted action performed.

## Ownership / head / tree
- Worktree `/home/user/workspace/worktrees/s2-composition`, branch `execute/20260921-s2-composition`,
  **head `9742037b153221de565e651ad8ba3b721bc0fb31`, tree `5469fbefcdbb7001151e7a02084951e3c57a5dfe`, clean (0 porcelain lines)**.
- Lineage: `c23b9d9f` → `e15e25c2` (S2) + `b7d7fe59` (S1) → `0af39f6c` (merge, tree `3d494b74` = recorded merge-tree, 0 conflicts,
  disjoint paths) → `eb6904d1` (S2 harness) + `41f4d6a9` (frozen S1 R4) → `9742037b`. All new commits author+committer
  `Bradley Gleave <bradley@bradleytgpcoaching.com>`, repo-local config, verified via `git var` before and `%an/%ae/%cn/%ce` after.
- Byte identity verified by blob id: every S1-owned path (migration.sql, down.sql, verify.sql `266e62e9…9448`, guard, bootstrap,
  S1 harness, truncate controls, discriminator) = `41f4d6a9`; migration/down/guard/bootstrap also = `b7d7fe59`; every S2-owned path
  (release.sh `9908234e…f80ac`, `release-required-verifiers.txt`, Dockerfile, workflows) = `e15e25c2`. 165 timestamped migration dirs.
- Provisional-vs-final: the b7-only composition `0af39f6c` was a provisional checkpoint; the final source is `9742037b` with the
  parent-named S1 successor. Prior S1/S2 exact-head evidence binds to the parents, not to this head.
- Recovered clones under `initialization/recovered/` were only fetched from (read-only); `repos/growth-project-backend` untouched.

## What was built (all cheap/source work; every script `bash -n` clean — shellcheck not installed)
| path | role |
|---|---|
| `worktrees/s2-composition/test/release/s1s2-composition.sh` (committed `eb6904d1`) | S2-owned composition proof: guard first (S1 `s1_guard_offline` + `s1_guard_preflight`, exit 64), stamps, then real `bash scripts/release.sh` runs: C0 S2-only tree refusal (no DB contact), C0b integrated tree minus verify.sql refusal, P real 164-parent `prisma migrate deploy` + out-of-band legacy RLS on both DBs (genuine ledger; counts asserted, not assumed), C1 positive (candidate 165, verifier discovered/passed, ALL_APPLIED = 164+1), C1v ledger + psql verify OK line, C2 idempotent, C3 out-of-band down.sql (status "up to date" yet verifier fails → exit 1), C4 S1-documented direct re-apply recovery, C5/C5r allowed-path drift/restore, C7 late-stage lock → real Prisma failure propagation + failed ledger row, C8 `resolve --rolled-back` recovery (S1 fact 1 failed-row vs C4 clean-applied distinction preserved). Captures release.sh's hardcoded `/tmp/prisma_*.log`/discovery list per control; refuses to start if they pre-exist; post-run clean-tree check. |
| `execution/s2-composition/run-composition-when-granted.sh` | lock-bearing runner (flock -n, exit 75), head/dirty/lock-hash refusals, S1 offline guard spec, two harness-level offline refusals, fixture start, harness under `timeout --foreground 1500`, then S1 R4 discriminator on the shared protected DB with `S1_R4_LOCK_HOLDER` stamped, exit-codes.txt, SHA256SUMS. |
| `execution/s2-composition/infra/{_common,setup-10-clients,setup-20-pg17,setup-30-npm-ci,s2-fixture}.sh` | copied from the S1 R3 evidence packet and retargeted (lane dir, worktree, head, data dir `clusters/s2comp`); setup-20 additionally refuses unless jar/txz/postgres/initdb SHA256 equal S1's recorded provenance. Fixture marker `s1-disposable-pg17` unchanged (guard requires it). |
| `execution/s2-composition/offline-refusals/R1–R9.log` | harness and S1 R4 discriminator refusals actually exercised at both heads with hostile inputs (hosted host, `localhost`, wrong port, non-`s1_rls_` name, missing confirm, no env, correct-offline-but-no-server): all exit 64, no `/tmp/prisma_*` created. (R4-bad-dbname.log holds the real bad-name control; its first attempt line in my console used a valid name and reached preflight, which also refused because no server/psql exists.) |
| `execution/s2-composition/SLOT_REQUEST_01_setup.md` | setup-only slot (apt psql client, PG17.6 acquisition with hash pins, npm ci + prisma generate); no DB. |
| `execution/s2-composition/GUARD_EXECUTION_PLAN.md` | SLOT REQUEST 02: the guarded proof plan (fingerprint, commands, provenance, target identity, bounds, negative controls, artifact paths). |
| `execution/s2-composition/bundle/s2-composition-9742037b-from-public-c23b9d9.bundle` (+ `commits.txt`) | `git bundle verify` okay; prerequisite public `c23b9d9f`. |
| `execution/s2-composition/HEAD.txt`, `SHA256SUMS` | head/tree/hashes; hashes of everything in the lane. |

## Auditor-request coverage mapping (planned evidence, unrun)
A-E01 items: integration commit/tree/parents + clean fingerprint (stamp), S1 hash applicability (stamp lists blob ids and sha256), target ownership + offline refusals before connection (R1–R9 + runner 20/21), lock held across preflight and mutations (runner fd 9), real 164 replay + legacy pre-state + genuine ledger + candidate via release entry (P, C1), positive/refusal/failure with real exits (C0/C0b/C1/C3/C5/C7), exposure AND allowed-path drift incl. out-of-band reversal where status is not truth (C3, C5), late-lock failure/recovery (C7/C8), verifier selection scope (step 0 contract + C0b), limitations (§7 of plan). B EVIDENCE-REQ-01: composed release log with `migrate deploy` then `db execute verify.sql`, protected run 0 with OK line (via psql route; prisma route exposes exit code only — noted), drifted run non-zero with ALLOWED-PATH/EXPOSURE, header stamps head + `sha256sum scripts/release.sh` + new verify hash `266e62e9…` (diff in S1 R4 patch). REQ-04: lockfile `62b05b90…` + `prisma --version` stamped. REQ-02 (live role facts) and REQ-03 (PG 15.18 CI) are out of this lane's scope.

## Limits / honesty
- Nothing has run against a database; all counts (164/165, 18 relations, exit codes) are assertions the harness will check, not results.
- C7's exact Prisma error text on 6.19.3 is asserted as `P3018|canceling statement due to lock timeout|55P03`; if Prisma's wording differs the check fails visibly and will be reported, not loosened silently.
- The harness relies on release.sh's fixed `/tmp` paths; concurrent release.sh runs on the same host would collide — the runner holds the canonical lock for the whole run and the harness refuses if the files pre-exist.
- Environment is the sole blocker: psql, PG 17.6 dist and `node_modules` are absent in this sandbox.

## Next request to parent
Grant SLOT REQUEST 01 (setup-only, ≈6–10 min: S10 psql client, S20 PG17.6 acquisition with SHA pins, S30 npm ci in `worktrees/s2-composition` at head `9742037b`) — or, if PG17.6/psql are acquired once for all lanes, only S30. Then SLOT REQUEST 02 (`GUARD_EXECUTION_PLAN.md`, ≈4–8 min) for the composition proof + shared S1 R4 discriminator.
