# S2-SETUP-FIXTURE-PREP — preparation-only packet (2026-09-22 04:47–05:0x UTC)

Owner: existing S2 Fable builder (requested Claude Fable 5 / High; requested identity only, no runtime telemetry claimed). Writes: `execution/s2-setup-prep/` only. `execution/s2-runner53/` re-verified unchanged (84-file `SHA256SUMS.outer` passes). Product source unchanged: `worktrees/s2-runner53` head `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4…f359`, 0 porcelain lines before and after. **Nothing was executed except `bash -n` syntax checks, `sha256sum`, `diff`, `cmp` and read-only `ls`/`command -v` probes.** No install, server, DB, destroy, network, canonical-lock or control execution.

## 1. Inputs (preserved originals, hashed in `originals/SHA256SUMS.originals`)

| Original | sha256 | Source packet |
|---|---|---|
| `s2-fixture.sh` (latest preserved fixture) | `08987e4cd566e0ee7ee8ef76ac4c39bc327ffd92fb85dfaf52fac8058d8df44c` | `2026-09-21/remediation/s2-composition/setup-and-runner-readiness/infra/` |
| `_common.sh` | `af881779…0616a` | `checkpoint-1/infra/` (identical bytes in setup-and-runner-readiness) |
| `setup-10-clients.sh` | `622f1997…d7fbd` | idem |
| `setup-20-pg17.sh` | `96a2a443…16b5` | idem |
| `setup-30-npm-ci.sh` | `74c5af93…9dc6` | idem |
| `launch-detached.sh` | `64302b3e…a36d` | setup-and-runner-readiness |
| `check-lock.sh` | `94ce982b…f544` | setup-and-runner-readiness (copied byte-identical) |
| `PG17-PROVENANCE.txt` | `a7282e42…8531` | setup-and-runner-readiness (jar `23da5a04…`, txz `26fa6334…`, postgres `23cd1748…`, initdb `b7db9bc2…`, Maven sha1 `81633223…`) |
| frozen runner v5.3 | `fbc8b9af592b370429a66bf164d3c5ac0f0b1bac0f57474c50ac293ebebd1bfc` | `execution/s2-runner53/` |

The fixture `6062f4ce…d61` named by request 03 is **not preserved** in the inspected current packet (only `33452b03` in checkpoint-1 and `08987e4c` above); no historical sweep was done. Nothing here claims or imitates 6062f4ce bytes.

## 2. Outputs (all `bash -n` clean; diffs in `diffs/`)

| File | sha256 | Derived from | Delta |
|---|---|---|---|
| `infra/s2-fixture-r53.sh` **REIMPLEMENTATION** | `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881` | 08987e4c | 73 changed lines, see §3 |
| `infra/_common.sh` | `34548a06…fdaf` | af881779 | header + `INFRA` path → `execution/s2-setup-prep/infra` (4 lines) |
| `infra/setup-10-clients.sh` | `2d12bf7f…bb58` | 622f1997 | header only (prerequisite record); no functional change |
| `infra/setup-20-pg17.sh` | `5e631d1c…27b5` | 96a2a443 | C1 refuse (70) an existing `dist` without matching provenance instead of `rm -rf` + re-extract; C2 no `rm -rf dist` before extract; C3 `installed_by` path. All pinned SHA1/SHA256 values unchanged |
| `infra/setup-30-npm-ci.sh` | `bdd80789…04c6` | 74c5af93 | P1 `WT=worktrees/s2-runner53`, `EXPECT_HEAD=d5cd9b8b` fixed, `S2_EXPECT_HEAD` override removed; P2 auto-install guard (`PRISMA_GENERATE_SKIP_AUTOINSTALL=1`, generate only if `node_modules/prisma` and `@prisma/client` exist in `$WT`, before/after snapshot of `/home/user/node_modules` count and `/home/user/package{,-lock}.json` presence → refuse 70 on any change); P3 `installed_by`; P4 node/npm/psql identities in the stamp |
| `infra/launch-detached.sh` | `8d0e2c7c…7181` | 64302b3e | header + `LANE` → `execution/s2-setup-prep` (4 lines) |
| `infra/check-lock.sh` | `94ce982b…f544` | — | byte-identical copy |
| `run-composition-r53-v5.3.1-when-granted.sh` | `fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925` | frozen v5.3 | 48 changed lines: L1 lane paths + fixture file/hash pin `9fcc3696…`; L2 `NS=s2comp-r53`, `DB=s1_rls_s2comp_r53`, `PORT=54353` with every URL/confirm/listener/scan literal derived from `$PORT`; L3 `S2_FIXTURE_NS` export removed; L4 toolchain stamp (`timeout`/`flock`/`setsid`/`pgrep` `--version`, `$BASH_VERSION`, lane identity); L5 output dirs `composition-r53/`, `runner-selftest-r531/`; plus a precheck that the fixture's literal `PORT=`/`NS=` lines equal the runner's. No logic change to lock/steps/halt/reap/quarantine/budget/exit registers |
| `controls-proposed/run-runner-controls-v531.sh` | `759d958f…09ba` | s2-runner53 driver `4d4bc661…` | paths/runner/outputs only (11 lines); stubs byte-identical (`controls-proposed/stubs/SHA256SUMS.stubs-copied`) |
| `controls-proposed/run-fixture-lockcheck-controls.sh` | `84f988aa…a3b9` | new (mirrors READINESS_FIX_01's 4 lockcheck cases) | F1–F4 fd-9 guard cases on a temp lock + F5 `url` shape; no PG, no canonical lock |
| `controls-proposed/k1-predecessor-mechanism.sh` | `3359b84a…0483` | — | byte-identical copy |

## 3. Fixture delta 08987e4c → r53 (each item is either a lane pin or a named safety correction)

| # | Change | Why |
|---|---|---|
| D1 | `DATA=/home/user/pg17/clusters/s2comp-r53` (was fixed `s2comp`) | fresh, unique, session-owned namespace under the guard's fixed root; historical `s1`, `s2comp`, `s2comp-r2`, `s2comp-r3`, S5 dirs are never referenced (none exist here; none assumed) |
| D2 | `PORT=54353` (was 54321) | lane-unique port (S2 lanes historically 54321, S5 54325); guard accepts any pinned port via `S1_PG_PORT`; the harness/discriminator/guard-spec hard-code 54321 only in comments and the guard spec's offline cases |
| D3 | `init` refuses (70) if `DATA` exists, if anything listens on the port, or if a postgres already serves `DATA`; refuses if `initdb` is missing | refuse foreign/existing state without adopting or deleting |
| D4 | `start` refuses (70) an already-running server and a port listener | 08987e4c printed "already running" and continued — silent adoption of a server it did not start (**flagged unsafe inherited behaviour**) |
| D5 | `stop` uses `pg_ctl -m fast -w -t 15` | bounded; fits the runner's 20 s stop budget; failure exit propagates |
| D6 | `destroy` refuses unless `pg_ctl status` says not running AND no postgres references `DATA` AND `S2_FIXTURE_DESTROY_CONFIRM` equals the literal data dir | 08987e4c did `stop -m immediate || true; rm -rf` — **destructive removal after a failed/unknown stop** (flagged; acceptance: stop failure never allows destructive removal). The runner never calls destroy; no destroy is requested |
| D7 | `mkdir -p $SOCK $clusters` moved inside `init` after the refusals | 08987e4c created directories under `/home/user/pg17` on every subcommand, including refused ones |
| kept | fd-9 inherited-lock guard via `/proc` for init/destroy/lockcheck; `S2_FIXTURE_LOCK` honoured for `lockcheck` only; marker `cluster_name='s1-disposable-pg17'`; loopback only; synthetic creds; `9>&-` on every pg binary/psql; identical postgresql.conf tuning | reviewed behaviour retained |

No env override of DATA/PORT/marker/credentials exists in the fixture or the runner (the v5.3 `S2_FIXTURE_NS` export was removed because the fixture never read it in any preserved version).

## 4. Actual prerequisites in this sandbox (read-only probes, 04:5x UTC)

Present: `sudo -n` OK, `apt-get`/`apt-cache`/`dpkg-query`, `curl`, `unzip`, `tar`, `xz`, `sha1sum`, `node v20.20.1`, `npm 10.8.2` (prefix `/usr/local`, cache `/home/user/.npm`), `git 2.53.0`, `flock`/`setsid` util-linux 2.41.3, `pgrep`/`ps` procps-ng 4.0.4, `ss` iproute2 6.19, **`timeout`/`sha256sum` = uutils coreutils 0.8.0**, bash 5.3.9, Ubuntu 26.04, 2 vCPU, 7.7 GB free RAM, 9.2 GB free disk.
Absent: `psql`, `pg_dump`, `initdb`, `pg_ctl`, `/home/user/pg17`, `worktrees/s2-runner53/node_modules`, `/home/user/tgp-quarantine`, `/home/user/package.json`, `/home/user/package-lock.json`, `execution/test-validation.lock` (never created).
Noted: **`/home/user/node_modules` exists (209 entries, platform-owned, no `prisma`/`@prisma`)** — it is on Node's upward resolution path from the worktree. Not ours; never touched. setup-30 P2 snapshots it (count + prisma presence) and refuses if it changes; the runner and harness address Prisma by explicit path `node_modules/prisma/build/index.js` inside `$WT`, and the harness symlinks `$ROOT/node_modules` into its throwaway exports.
A2 is **not** assumed to exist: the runner refuses 70 without the stamp `lock=62b05b90…` written by setup-30.

## 5. Applicability of the s2-runner53 controls (K1–K6) to v5.3.1 — none inherited automatically

| Control | Applies to v5.3.1 bytes? | Disposition |
|---|---|---|
| K1 predecessor mechanism | independent of runner bytes (counterexample of v5.1 shape) | optional; retained in the driver |
| K2 success, K3 TERM ordering, K4 quarantine, K5 stop failure, K6 first failure | **no** — bytes changed (paths, port derivation, fixture pin/literal check, toolchain stamp). Logic is intended to be identical, but "intended" is not evidence | **re-run all five** against v5.3.1 via `controls-proposed/run-runner-controls-v531.sh` (historical total 30.85 s; request ≤ 60 s) |
| Real-mode refusal branches (toolchain/node_modules/PG17/fixture hash/literals/namespace/port/`/tmp`) | not exercised in v5.3 either | still not runnable without touching the canonical lock (`exec 9>` creates it); to be observed as launch prechecks under the proof grant |
| Fixture fd-9 guard | new file | F1–F5 via `controls-proposed/run-fixture-lockcheck-controls.sh` (< 3 s, temp lock only) |
| Fixture init/start/stop/destroy refusals (D3–D6) | new logic | **cannot be exercised without the canonical lock and PG binaries** (only `lockcheck` honours a temp lock). Proposed as post-setup, pre-proof controls F6–F9 under the setup grant's lock: `init` twice → second `REFUSED: exists`; `start` twice → second `REFUSED: already running`; `destroy` while running → `REFUSED: server still running`; `destroy` after stop without confirm → `REFUSED: S2_FIXTURE_DESTROY_CONFIRM`. Note F6–F9 create/start/stop a real cluster (no DB content, no harness) — they are setup-tier, not proof-tier, and leave `clusters/s2comp-r53` stopped and retained (never destroyed) for the proof run to refuse (fresh-only) — so **F6–F9 must use a scratch namespace or be scheduled to end with a parent-authorised destroy**; flagged for the parent's decision rather than decided here |

## 6. Flags for reviewers / parent (not decided here)
1. Port change 54321 → 54353 deviates from the B1/B2-proven configuration; guard/harness accept it via `S1_PG_PORT`, but it is a new literal set (`DESTROY-127.0.0.1:54353/s1_rls_s2comp_r53,s1_rls_s2comp_r53_lock`).
2. Fixture D4/D6 change inherited helper semantics (no adoption, no destroy-after-failed-stop). The runner never calls destroy; a cluster left by a refused/quarantined run stays on disk until the parent authorises `destroy` with the literal confirm.
3. F6–F9 (real fixture lifecycle refusals) conflict with the runner's fresh-only namespace unless run on a scratch namespace; the fixture has no namespace override by design. Options: accept F6–F9 as observed-in-proof behaviour only, or authorise a one-off destroy after them.
4. uutils `timeout` semantics (exit 15 under group TERM) remain; v5.3.1 stamps the implementation but does not alter behaviour.
5. setup-10 installs `postgresql-client-18` via apt with `sudo -n` (historical: 18.6-0ubuntu0.26.04.1); the guard/harness accept client ≥ 17. setup-20 downloads from Maven Central (SHA1 published only; SHA256s pinned to S1's recorded values).

## 7. What success of this preparation does NOT prove
Any install, PG bootstrap, composition or discriminator result, current hosted controls, real deployed containment, or product acceptance. No control has been executed; the v5.3 controls do not cover v5.3.1 bytes. No audit clearance is claimed; two independent frozen-packet reviews (runner + fixture + setup/launcher) precede any real proof.
