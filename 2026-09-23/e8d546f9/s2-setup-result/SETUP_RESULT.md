# S2 fresh setup — result (revision 1, frozen)

Grant: `tgp-private-evidence/execution/e8d546f9/S2_SETUP_GRANT.md` (sha256 `89b77ec5d0cbb11a19c58f7d4d1c62634744d4672280ca4500af2017dedefa52`). Sole executor `restore_upstream_proof_inputs_muddwjad` (requested Claude Fable 5; runtime identity not observable, not asserted). Executed 2026-09-23 00:55:59Z–01:04:17Z, one attempt per stage, sequential, unchanged SETUP05 bytes. Environment-only result: proves a fresh environment exists — never controls, real composition, S1 TRUNCATE, audit or release.

## 1. Preconditions confirmed before start (`00-preflight.txt`, 00:55:59Z)

Restoration report frozen first (`execution/e8d546f9/upstream/REPORT.md` b16955a1…, addendum af3f094d…). `execution/s2-setup-prep` PRE-OK 37/37; six script hashes exactly as granted (`_common` 34548a06…, `setup-10` 2d12bf7f…, `setup-20` 5e631d1c…, `setup-30` bdd80789…, `launch-detached` 8d0e2c7c…, `check-lock` 94ce982b…). Worktree `worktrees/s2-runner53` HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, porcelain 0, `package-lock.json` `62b05b90…1390`, `node_modules` git-ignored and absent. Resources: 10 GB disk, 7.7 GB RAM available, 2 CPU, load 0.02; canonical lock file absent; no other heavy workload (census matched only the platform code-mode node daemon). Outside-root baseline `/home/user/node_modules` 209 entries, no prisma, no `/home/user/package*.json` (`outside-root-inventory-before.txt`). `/home/user/pg17` and `psql` absent → all three stages took their install paths.

ENV01 action: `chmod u+w` on `execution/s2-setup-prep` and `infra` only long enough to `mkdir infra/logs` and `runs`, then `u-w` again → both parents 0555 before and after; new dirs 0755; PRE-OK 37/37 re-verified; 0 writable source files.

## 2. Stage outcomes (raw sentinels; `STAGE_EXITS.txt`, `runs/<name>.{cmd,exit,log}` copies, `infra/logs/*.log` copies)

| Stage | Exact command (per grant) | Start → end (UTC) | `runs/<name>.exit` | wait rc | Acceptance evidence | Post-stage observation |
|---|---|---|---|---|---|---|
| S10 `setup-10-e8d546f9` | `launch-detached.sh start … timeout --kill-after=60 1560 bash …/setup-10-clients.sh`; `wait … 1700` | 00:56:17 → 00:56:29 (12 s) | **0** (pid 6107) | 0 | `apt_update_exit=0`, `apt_install_exit=0`, `postgresql-client-18 18.6-0ubuntu0.26.04.1 install ok installed`; `psql (PostgreSQL) 18.6` ≥ 17 | pid dead, no apt/dpkg survivors, lock FREE, PRE-OK, WT porcelain 0 |
| S20 `setup-20-e8d546f9` | `… timeout --kill-after=60 480 bash …/setup-20-pg17.sh`; `wait … 600` | 00:57:02 → 00:57:04 (2 s) | **0** (pid 7429) | 0 | `/home/user/pg17/PROVENANCE.txt` `result=success`; jar `23da5a04…1d29d`, txz `26fa6334…067c0`, postgres `23cd1748…f873a`, initdb `b7db9bc2…0882a` — all four exact pins, re-hashed on disk (`PG17-PROVENANCE.actual.txt`); `server_binary=postgres (PostgreSQL) 17.6` | no `clusters/`, no postgres process, no 543xx listener, no curl/unzip/tar survivors, lock FREE, PRE-OK, WT porcelain 0 |
| S30 `setup-30-e8d546f9` | `… timeout --kill-after=60 2160 bash …/setup-30-npm-ci.sh`; `wait … 2300` | 00:57:42 → 01:03:38 (5 m 56 s) | **0** (pid 8027) | 0 | `npm_ci_exit=0`, `prisma_generate_exit=0`; `outside_root_before == outside_root_after` (`nm=209 pkg=absent lock=absent prisma_outside=absent`; inventory files byte-identical); stamp `head=d5cd9b8b…`, `lock=62b05b90…1390`, `prisma_cli_sha256=c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0` (= runner v5.7 `EXPECT_PRISMA_CLI_SHA`, compared not assumed), `result=success` (`install-stamp.actual.txt`); prisma 6.19.3 / @prisma/client 6.19.3; 666 node_modules entries, 712 MB; `clean_after=yes head_after=d5cd9b8b…` | pid dead, no npm/node survivors, lock FREE, PRE-OK, WT HEAD/tree unchanged, porcelain 0 |

Final `check-lock.sh` 01:04:17Z: `lock FREE`, no holder. The canonical lock file `execution/test-validation.lock` now exists, empty (size 0): created by the first granted `check-lock.sh` probe at 00:56:17Z (documented probe behaviour; each stage held it nonblocking only for its own duration via `_common.sh`). `check-lock.sh` exits 1 by construction (its last command is the fd-scan test finding no holder); the printed line is the observation.

The exact `wait` commands were run verbatim but detached (`setsid`) with output to `NN-wait.txt` so the tool call did not block; completion was additionally observed via `status` and the sentinel file. No PID was ever signalled; no old PID used.

## 3. Writes made (all within grant)

System: `postgresql-client-18`, `postgresql-client-common` (dpkg). `/home/user/pg17/{download,dist,PROVENANCE.txt}`. `worktrees/s2-runner53/node_modules/**` (git-ignored; includes `.s2-composition-install-stamp` and generated Prisma client). `execution/s2-setup-prep/infra/logs/{setup-10-clients-20260923T005617Z,setup-20-pg17-20260923T005702Z,setup-30-npm-ci-20260923T005742Z}.log`, `execution/s2-setup-prep/runs/setup-{10,20,30}-e8d546f9.{cmd,pid,log,exit}`. `~/.npm/_logs/2026-09-23T00_57_42_774Z-debug-0.log` (copied to `npm-debug-logs/`; grep for token/auth/password/secret: 25 hits, all package names such as `jsonwebtoken`, `@inquirer/password` — no credentials). `execution/test-validation.lock` (empty, by probe). This lane: `execution/e8d546f9/s2-setup-result/**`. Global `/home/user/node_modules` untouched (209 → 209, identical listing). No server, initdb, cluster, DB, destroy, product/source/schema edit, hook, commit, or remote action. Disk 10 G → 9 G available.

## 4. Deviations / negatives

None. No refusal (70/75), no timeout, no retry, no manual cleanup.

## 5. What this enables and does not

Satisfies PROOF_REQUEST_13-class environment preconditions (client ≥ 17, pinned PG 17.6 dist, locked node_modules with exact CLI bytes) and runner v5.7 real-mode prechecks by file state (`node_modules/prisma/build/index.js` = `c2a77456…`, stamp `lock=` line, `/home/user/pg17/dist/bin/postgres` present, fixture `9fcc3696…` in LANE). Does NOT grant or perform controls (CONTROL_REQUEST_12), fixture init/start, real composition, discriminator, or any review. Stub-only controls still need the ENV01 `runner-selftest-r531/` writable directory at their own grant time (not created here).

## 6. Owned outputs

`execution/e8d546f9/s2-setup-result/{SETUP_RESULT.md, STATUS_INTERIM.md (superseded, kept), 00-preflight.txt, 10-setup-10.txt, 10-wait.txt, 20-setup-20.txt, 20-wait.txt, 30-setup-30.txt, 30-wait.txt, STAGE_EXITS.txt, PG17-PROVENANCE.actual.txt, install-stamp.actual.txt, outside-root-inventory-{before,after}.txt, setup-*-e8d546f9.{cmd,exit,log}, setup-*-2026…Z.log, npm-debug-logs/*}`. `MANIFEST.sha256` covers every file in this directory except itself.
