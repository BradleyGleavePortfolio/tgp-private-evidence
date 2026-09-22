# S2 fresh-setup readiness — exact invocation from already-preserved bytes (OP88, T4 inherited S2 scope). NOT executed.

Verdict: **existing reviewed bytes suffice.** The preserved `execution/s2-setup-prep/infra/{_common,setup-10-clients,setup-20-pg17,setup-30-npm-ci,launch-detached,check-lock}.sh` are byte-identical to the inputs frozen in `SLOT_REQUEST_05_SETUP_ONLY.md` (hashes below, re-hashed now; lane `sha256sum -c SHA256SUMS.outer` → PRE-OK, 37/37) and are the exact bytes that ran once successfully under grant SETUP-05 (2026-09-22 05:04–05:11Z, `tgp-private-evidence/2026-09-22/remediation/s2-setup-prep/setup05/grant05/SETUP05_RESULT.md`, all three raw exits 0). No new harness, revision or security work is needed. One environment authorization is required before the first step can start (§4).

## 1. Exact scripts and pins (current hashes = SLOT_REQUEST_05 inputs)
| File | sha256 | Role / pins |
|---|---|---|
| infra/_common.sh | 34548a06ca75c787fdf0ac13c4e90233a28d7716ff18e7cac0211b342808fdaf | L8 canonical lock `/home/user/workspace/execution/test-validation.lock`, L15–16 `flock -n` per step (exit 75 if busy); L12 `mkdir -p infra/logs` |
| infra/setup-10-clients.sh | 2d12bf7f9daca68eaaef40914248227501dc7803c4371569dda8073357ddbb58 | apt `postgresql-client-18` (fallback 17/generic) via `sudo -n`; refuses major < 17 (70) |
| infra/setup-20-pg17.sh | 5e631d1cd0039c21b76855c830f466e00ac6da20e25ecac631890625eb4227b5 | zonky `embedded-postgres-binaries-linux-amd64-17.6.0.jar` from repo1.maven.org; SHA1 8163322358dbe4e6c2abccc90f2e543f8cfc65db; SHA256 jar 23da5a04…1d29d, txz 26fa6334…067c0, postgres 23cd1748…f873a, initdb b7db9bc2…0882a (S1-recorded); extract to `/home/user/pg17/dist`; writes `/home/user/pg17/PROVENANCE.txt`; existing dist without provenance → 70, never rm -rf |
| infra/setup-30-npm-ci.sh | bdd8078948a8b58f074e53d9cf4596e26f9e8cc862c61334e548323a45b404c6 | `WT=worktrees/s2-runner53`, `EXPECT_HEAD=d5cd9b8b…`, `EXPECT_LOCK=62b05b90…1390`; `npm ci --ignore-scripts` (≤1500 s) + guarded `prisma generate` (≤600 s, `PRISMA_GENERATE_SKIP_AUTOINSTALL=1`, outside-root snapshot); writes stamp `node_modules/.s2-composition-install-stamp` with lines `head=…`, `lock=62b05b90…`, `prisma_cli_sha256=…`, `result=success` |
| infra/launch-detached.sh | 8d0e2c7ce4721afaa7ff5bdfdfb2cb525790b424b8a163319c9de2e2eb4d7181 | setsid launcher; `runs/<name>.{pid,log,exit,cmd}`; L15 `mkdir -p runs` |
| infra/check-lock.sh | 94ce982b1685e39a4e0afb8b1297ec8428ac06b54b507ec86fb47c8d3b0cf544 | read-only lock probe (`flock -n $L true`; **creates the empty lock file if absent** — observed in grant05) |
| infra/s2-fixture-r53.sh | 9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881 | not run by setup; pinned by runner v5.7 (`EXPECT_FIXTURE_SHA`) |

Producer↔consumer check for PROOF_REQUEST_13 §2 (P-02): setup-30 writes `lock=$EXPECT_LOCK` as its own line; runner v5.7 L411 requires `grep -q "^lock=$EXPECT_LOCK_SHA$" node_modules/.s2-composition-install-stamp` with the same value 62b05b90…1390 — format and value match. Runner `EXPECT_PRISMA_CLI_SHA` c2a77456…e1a0 equals the CLI sha grant05 obtained from this lockfile (compare at run time, do not assume).

## 2. Current environment (read 2026-09-22 22:1xZ; nothing installed or started)
- ABSENT: `psql`/`pg_dump`; `/home/user/pg17`; `worktrees/s2-runner53/node_modules` and the install stamp. → all three steps will take their install paths (no "already present"/stamp short-circuit).
- PRESENT: worktree at d5cd9b8b…, `git status --porcelain --untracked-files=all` empty, `package-lock.json` 62b05b90…1390; node v20.20.1, npm 10.8.2; sudo, curl, unzip, tar, xz, sha1sum, flock, setsid, apt-get, dpkg-query; `timeout` = uutils 0.8.0 (supports `-k/--kill-after`, `-f/--foreground`); `sudo -n true` → rc 0; `/home/user/node_modules` 209 entries, no prisma, `/home/user/package*.json` absent (matches grant05 outside-root baseline); canonical lock file absent (not opened); 2 CPU, ~7 GB RAM, 9.6 GB free.
- Disclosure: this readiness pass ran `sudo -n true` (privilege check) and one DNS lookup (`getent hosts repo1.maven.org` → Cloudflare CDN addresses). No other network, probes, lock or writes outside this report directory.

## 3. Exact invocation (identical to SLOT_REQUEST_05 lines as executed in grant05, incl. outer bounds)
```
cd /home/user/workspace/execution/s2-setup-prep
./infra/check-lock.sh                                                   # expect: lock FREE (creates the empty lock file if absent)
./infra/launch-detached.sh start setup-10 timeout --kill-after=60 1560 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-10-clients.sh; ./infra/launch-detached.sh wait setup-10 1700; echo "setup-10=$?"
./infra/check-lock.sh
./infra/launch-detached.sh start setup-20 timeout --kill-after=60 480  bash /home/user/workspace/execution/s2-setup-prep/infra/setup-20-pg17.sh;    ./infra/launch-detached.sh wait setup-20 600;  echo "setup-20=$?"
./infra/check-lock.sh
./infra/launch-detached.sh start setup-30 timeout --kill-after=60 2160 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-30-npm-ci.sh;  ./infra/launch-detached.sh wait setup-30 2300; echo "setup-30=$?"
./infra/check-lock.sh
```
Sequential, one attempt each, STOP at the first nonzero. Raw exit = `runs/<name>.exit` sentinel (the step's real code; `wait` returns 0 only for sentinel 0, 1 for nonzero sentinel, 2 for dead-without-sentinel = treat as failed). Codes: 75 canonical lock busy (no waiting), 70 refusal (hash/head/lock/dirty/outside-root/major<17), 124/137 outer timeout, apt/curl/npm raw codes passed through. Historical durations (grant05): S10 13 s, S20 2 s, S30 6 m 05 s.

## 4. Required grant, writes, network, footprint, cleanup
- **Authorization needed before step 1 (line-bound; environment, not a script defect):** `execution/s2-setup-prep/` and `infra/` are mode 0555 (restored read-only by upstream-prereqs-2; audit A ENV01). `_common.sh:12 mkdir -p "$LOGDIR"` (`infra/logs/`, absent) aborts under `set -e` before `step_begin` (no lock taken, no log); `launch-detached.sh:15 mkdir -p "$RUNS"` (`runs/`, absent) fails likewise. Grant action: make exactly `execution/s2-setup-prep/infra/logs/` and `execution/s2-setup-prep/runs/` creatable (e.g. `chmod u+w execution/s2-setup-prep execution/s2-setup-prep/infra` for the slot, or pre-create both directories writable). File bytes/hashes unaffected (PRE-OK still verifies). Not done by the builder.
- Canonical lock: each step holds `execution/test-validation.lock` nonblocking for its own duration (`_common.sh:15–16`); explicit slot permission required — a free lock is not permission. `check-lock.sh` creates the file if absent.
- Privilege: `sudo -n apt-get update/install` (S10 only).
- Network (actual endpoints): Ubuntu apt mirrors (S10); `https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0/` jar + `.sha1` (S20); npm registry for 1118 packages (S30). Nothing else.
- Writes/footprint: system package `postgresql-client-18` (dpkg); `/home/user/pg17/{download,dist,PROVENANCE.txt}` (~88 MB dist + jar); `worktrees/s2-runner53/node_modules` (git-ignored; grant05 disk 8.9 → 8.0 GB); `execution/s2-setup-prep/infra/logs/*.log`, `runs/setup-{10,20,30}.*`; `~/.npm/_logs`. No server, initdb, cluster, DB, destroy, product/source change; worktree must remain clean (refused otherwise).
- Resources: ≤2 CPU, <3 GB RAM, ~1.5 GB disk, sole heavy owner ≈ 7 min. Cleanup: none required on success (no processes remain; each stage's survivor/listener/lock census as in grant05 STAGE_EXITS.txt); on failure partial state is left in place for inspection, no retry/repair.

## 5. Prior independent applicability
Grant05 executed these exact bytes in this sandbox lineage with raw exits 0/0/0, outside-root inventory unchanged, worktree clean, lock FREE after every stage (SETUP05_RESULT.md, STAGE_EXITS.txt, install-stamp.actual.txt, PG17-PROVENANCE.actual.txt). That result is preserved evidence, **not** current state: the artifacts it produced are absent now (§2), so PROOF_REQUEST_13 §2 requires this fresh run and a new receipt; no earlier setup positive is reused.

## 6. Positive criteria (from actual logs, not assumed)
S10 exit 0, `psql --version` ≥ 17. S20 exit 0, `/home/user/pg17/PROVENANCE.txt` `result=success` with the four S1 SHA256s. S30 exit 0, `npm_ci_exit=0`, `prisma_generate_exit=0`, `outside_root_before == outside_root_after`, stamp lines `head=d5cd9b8b…`, `lock=62b05b90…1390`, `prisma_cli_sha256=` (compare with c2a77456…e1a0), `clean_after=yes`. Lock FREE after each step. Then PROOF_REQUEST_13 preconditions 2–3 are satisfied; 1 (controls green + dual review) and 4 (lock slot) remain separate grants.

Not requested here: fixture init/start, controls, proof, destroy, any source edit.
