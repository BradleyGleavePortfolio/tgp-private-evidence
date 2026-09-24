# S7-2 C1 independent review B — Part 2: minimal PG fixture variant + execution binding (source only)

Reviewer: independent non-builder B (T4) continuation, session `95633079`. Observed 2026-09-24 ~06:17–06:35Z. Requested route Claude Fable 5 / High (requested routing, not observed telemetry).

Additive to the sealed source-phase review B (`resume-evidence/execution/e7d2385c/audits/s7-c1-b/`, `MANIFEST.sha256` re-verified OK) and to Part 3 (`ACTUAL_COMMIT_AND_TARGETED_RESULTS.md`, `1e260a64…`, disposed A0/B0 by the parent). Carried forward unchanged: source verdict, C1–C9, Part 3 C10–C15 and its head attestation of `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`. This Part performs exactly the sealed B "Part 2" item and reviews the two new files only; it grants or blocks nothing beyond that. Reviewer A's conclusions were not read (`audits/c1-a/**` and `s7-c1-a/**` conclusions unopened; a file-hash listing incidentally showed a copy of the preparation doc under `s7-c1-a/inputs/`, which I only hashed).

Mode: static reads, `diff`/`cmp`/sha256, git object reads in `worktrees/s7-c1` (`GIT_OPTIONAL_LOCKS=0`, read-only), `command -v`/`ls` for tool presence. No fixture/binding/installer/jest/psql/prisma invocation, no probe, no install, no cluster, no source re-audit, no test. The only thing executed was the packet's sed-only `derive-c1-fixture.sh` copied to `/tmp/derive/` with the donor copy, to confirm determinism of the text derivation (it writes nothing outside `/tmp`). Sole writes: `execution/95633079/audits/c1-b/**`.

## 1. Packet and provenance pins

| Item | Observed |
|---|---|
| Packet | `execution/95633079/c1-pg/`, `MANIFEST.sha256` sha256 `e612bd35ee52f4ec0a849416720693592fdc485fcdd8749299b41e03d657163b`, 15/15 entries OK |
| Variant `c1-fixture.sh` | sha256 `27b816afb53ebaa5afbad73b6075eddd366d611799a44a44fa549b5f43ca5040`, 93 lines, `bash -n` OK |
| Binding `c1-pg-proof.sh` | sha256 `505061752aa09d4b6cfbd60bbc45835ee3613932dbcca1816130bed975c4eef2`, 115 lines, `bash -n` OK; pins `EXPECT_FIXTURE_SHA=27b816af…` |
| Donor `donor/s5-fixture.sh` | sha256 `3a7d57bf951ab27e2161dc91db1d816f31d4af079ede076e7a2dfd1c44f3a721` == the donor pinned in sealed B §6/§8 == byte extracted by me from `checkpoint-private/execution/e7d2385c/evidence/s5-proof-preparation-080b9574.tar.gz` (`caa41b4f…`) at `s5-proof-preparation/retrieved/2026-09-22/remediation/s5-r4/checkpoint-1/s5-fixture.sh`; `donor/SHA256SUMS` lists it |
| `C1_PG_PROOF_PREPARATION.md` (recorded input) | sha256 `1a683bf9…` == the copy in `resume-evidence/execution/e7d2385c/s7-c1-pg-preparation/` whose manifest `63076c47…` still verifies — the same §4–§6 I reviewed in sealed B §6 |
| `recorded-inputs/` | `PINS.txt` (2026-09-23T21:42Z observations), `setup-10-clients.sh` `622f1997…`, `setup-20-pg17.sh` `96a2a443…`, `_common.sh` `af881779…`, both setup logs ending `exit=0` |
| Target head | `worktrees/s7-c1` HEAD `a0ea1bea…`, `HEAD:test/rls-c1-setup.spec.ts` = `cc3b0e4da17add10aade720c1b7e10a9f78db937` (== `EXPECT_SPEC_BLOB`; formatter-only vs PR526 per sealed C9), `jest.config.js`/`jest.rls.config.js`/`src/prisma.service.ts` byte-identical to foundation `5c760b77` |

## 2. Fixture variant vs donor — exact diff characterisation

- My `diff -u donor/s5-fixture.sh c1-fixture.sh` is byte-identical (bodies) to the recorded `c1-fixture.diff-vs-3a7d57bf.txt`: 3 hunks, 31−/29+.
- Deterministic derivation: running the packet's `derive-c1-fixture.sh` (sed line-addressed substitutions, refuses on donor hash mismatch) in `/tmp` reproduced `c1-fixture.sh` byte-for-byte (`27b816af…`).
- After normalising the pure renames (`S5_`→`C1_` prefixes on `FIXTURE_*`, `RUNNER_PID`, `STOP_TIMEOUT`; `run-proof.sh`→`c1-pg-proof.sh`; `s5-fixture.sh`→`c1-fixture.sh`; "S5 marker/cluster"→"C1 marker/cluster"; the conf-block comment) and ignoring the header comment block (lines 1–15), the ONLY remaining differences are:
  1. line 21: `PORT=54325; SUPER=s5_super; PASS=s5_local_synthetic; MARKER=s5-disposable-pg17` → `PORT=55439; SUPER=user; MARKER=c1-disposable-pg17` (PASS dropped);
  2. line 22: `DATA=…/clusters/s5; LOG=…/clusters/s5.log; SOCK=…/run/s5` → `DATA=…/clusters/c1-builder/pg-data; LOG=…/clusters/c1-builder/pg.log; SOCK=…/run/c1`;
  3. line 30: `mkdir -p "$SOCK" "$PG17_HOME/clusters"` → `mkdir -p "$SOCK" "$(dirname "$DATA")"` — in the donor `$PG17_HOME/clusters` was literally `dirname "$DATA"`; the variant's DATA is one level deeper, and the pre-`initdb` redirect `>"$DATA.initdb.log"` needs that parent to exist. This is the one structural line the parent named as necessary; it creates only `clusters/c1-builder`, never the data directory itself, so the fresh-init-only refusal on `$DATA` is unaffected;
  4. lines 44–46: `pwfile=$(mktemp)…`, `initdb … -A scram-sha-256 --pwfile="$pwfile"`, `rm -f "$pwfile"` → single `initdb -D "$DATA" -U "$SUPER" -A trust -E UTF8 --locale=C.UTF-8 >"$DATA.initdb.log" 2>&1 </dev/null`.
- Byte-identical (confirmed by the normalised diff being empty elsewhere): `set -euo pipefail`; `PG17_HOME`/`PGHOME`; caller guard shape (`/proc/$PID` + cmdline grep, rc 2) re-pointed only; `pg_ctl` presence check (rc 2); `pgbin` with `9>&-` fd hygiene; `postmaster_alive`, `ppid_of`, `data_dir_users`; `init` fresh-init-only refusal (rc 3) and the full `postgresql.conf` tuning block (`cluster_name = '$MARKER'`, `port = $PORT`, `listen_addresses = '127.0.0.1'`, `unix_socket_directories = '$SOCK'`, memory/fsync/log settings); `start` marker refusal (rc 3), `pg_ctl -w -t 60 start`; `stop` bounded `-m fast -w -t "$STOP_TIMEOUT"` with survivor → rc 4 and non-zero pg_ctl rc propagated; `status`; `destroy` marker check, stop-first with never-discarded failure (rc 4), `data_dir_users` refusal (rc 4), `rm -rf --` + verified absence (rc 5), `DESTROY_OK` only after absence. No new subcommand; no `CREATE DATABASE` inside the fixture.
- This matches the sealed B Part 2 acceptance list exactly (PORT=55439, SUPER=user, MARKER, DATA/LOG/SOCK, `initdb -A trust` without pwfile, guard re-pointed) plus the parent-authorised deeper-`dirname` mkdir; the single `CREATE DATABASE` lives in the binding (§4 "plus one database-creation command").
- Fitness for the unchanged spec (`cc3b0e4d`, read at HEAD): `-A trust` yields loopback `host … 127.0.0.1/32 trust`, which is what lets both the spec's `psql … postgresql://user@127.0.0.1:55439/c1_setup_disposable` (no password permitted by the spec's URL guard) and Prisma as `service_role` (created `LOGIN BYPASSRLS` by the spec's `beforeAll`, no password) connect; `SUPER=user` satisfies `parsed.username === 'user'` and is a superuser able to `CREATE ROLE`/`GRANT`; `DATA` ends with `/c1-builder/pg-data` as the spec's `directory.endsWith(...)` requires; port 55439 ≠ S5's 54325; `listen_addresses` loopback only.

## 3. Execution binding vs frozen §5/§6 — step-by-step

| §5 step | Binding (`c1-pg-proof.sh`) | Result |
|---|---|---|
| Lock | `exec 9>"$LOCK"; flock -n 9 || exit 75` on `execution/test-validation.lock`; run-once: exits 76 if `run/c1-pg-proof.sentinel` exists (neither writes a sentinel — correct, nothing ran) | as §5 |
| env | Identical export lines to §5 (`GIT_OPTIONAL_LOCKS`, `NODE_OPTIONS=--max-old-space-size=4096`, offline npm flags, `C1_SETUP_TEST_DATABASE_URL=postgresql://user@127.0.0.1:55439/c1_setup_disposable`, `C1_TEST_PSQL=/usr/bin/psql`, `C1_TEST_DATA_DIRECTORY=/home/user/pg17/clusters/c1-builder/pg-data`, `C1_SETUP_DISPOSABLE_ACK=c1-local-only-55439`) plus `C1_RUNNER_PID=$$ C1_STOP_TIMEOUT=45` for the fixture guard | matches spec guards lines 12–39 exactly |
| preconditions (added, read-only, rc 70) | fixture sha `27b816af…`; HEAD `a0ea1bea…`; tree `87798e74…`; spec blob `cc3b0e4d…`; porcelain 0; no `MERGE_HEAD`; `jest`/`ts-node` present; Prisma client contains `ImportIntent`; `dist/bin/{postgres,initdb,pg_ctl}` present with postgres `23cd1748…`/initdb `b7db9bc2…` == recorded S1/S2 provenance and `--version` 17.6; `/usr/bin/psql` present; `readlink -f /home/user/pg17` real path | pins the candidate and toolchain; no acceptance criterion added |
| 1 preflight (rc 71) | `clusters/c1-builder` absent; `ss -ltn` 0 listeners on 55439; `pgrep -cx postgres` == 0; S5 cluster: if present → no `postmaster.pid`, conf/pg_control sha recorded; if absent → `s5_cluster=ABSENT` recorded as-is; worktree porcelain sha recorded | §5 step 1, with the absent-S5 case handled by preservation, not reconstruction (parent instruction) |
| 2 init | `timeout -k 30 60 bash "$FIX" init`; requires `^C1_FIXTURE_INIT_OK data=…/c1-builder/pg-data port=55439 superuser=user` | as §5 (60 s) |
| 3 start | `STARTED=1; timeout -k 30 60 bash "$FIX" start`; requires `^C1_FIXTURE_START_OK pid=` | as §5 (60 s) |
| 4 create DB | `timeout -k 30 30 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At postgresql://user@127.0.0.1:55439/postgres -c 'CREATE DATABASE c1_setup_disposable'` — the ONE creation command | verbatim §4/§5 (30 s) |
| 5 identity | `SHOW data_directory` == `$C1_TEST_DATA_DIRECTORY`; `SHOW server_version_num` == `170006`; 15 s each; rc 73 | as §5 |
| 6 proof | `( cd "$W" && timeout -k 30 600 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci ) > run/jest.log`; raw `JRC` captured before summary grep; guard-refusal strings only logged (a module-load throw already fails the suite → rc ≠ 0 → stop); no `--testTimeout`/`--forceExit`/`--detectOpenHandles`/coverage | verbatim §5 command; existing 22-case spec, once, unchanged criteria |
| 7 stop | `STARTED=0; timeout -k 30 75 bash "$FIX" stop` (inner `pg_ctl -t 45` via `C1_STOP_TIMEOUT=45`); then 0 postgres procs, 0 listeners, no `postmaster.pid`, data dir retained (rc 74) | as §5/§6 (data dir RETAINED, no destroy path invoked) |
| 8 post | S5 unchanged (or still absent); worktree porcelain sha and HEAD unchanged; `run/RECEIPTS.sha256` | as §5 |
| failure | `fail()` logs `STOP_FIRST_FAILURE`, runs ONE bounded fixture `stop` only if a start happened, writes the sentinel with the FIRST rc; no retry | survivor rule preserved |

Jest selection check: `jest.rls.config.js` at HEAD sets `testMatch` `<rootDir>/test/rls-*.spec.ts` and clears the base RLS ignores; base `roots` include `<rootDir>/test`; `setupFiles` `test/jest.setup.ts` only seeds dummy env defaults (does not override the `C1_*` vars, `DATABASE_URL` default is unused because the spec constructs `PrismaService` with an explicit datasource URL); base `testTimeout` 10 s with the spec's own 30 s `beforeAll` and 45 s case — consistent with §5 "not passed: `--testTimeout`". The spec spawns children with `-r ts-node/register` (ts-node presence is a binding precondition).

Lock/fd hygiene: the fixture's `pgbin` closes fd 9 so no postmaster inherits the canonical lock (inherited donor behaviour). Jest children inherit fd 9 while running; a leaked child would keep the lock held and make the next `flock -n` fail loudly (75), not silently.

## 4. Pinned missing-PG-tool recovery (assessed as inputs; nothing run)

This sandbox: `/home/user/pg17` absent, `psql` absent (`command -v`), `ss`/`pgrep`/`flock`/`timeout`/`sudo` present. `ENVIRONMENT_RECOVERY.md` records the S5 cluster as absent and requires it to remain absent — the binding's preflight/post handle exactly that (`ABSENT` → must not appear), so no S5 reconstruction is implied anywhere.

- `setup-20-pg17.sh` (`96a2a443…`, recorded log exit 0 on 2026-09-21): downloads the zonky 17.6.0 jar from Maven Central (bounded 300 s), verifies Maven SHA1 == pinned `81633223…`, jar sha256 == `23da5a04…`, inner txz sha256 == `26fa6334…`, extracts to `/home/user/pg17/dist`, verifies `--version` 17.6 and postgres/initdb sha256 == `23cd1748…`/`b7db9bc2…`, and only then writes `PROVENANCE.txt result=success`; any mismatch exits 70 before provenance. It `rm -rf`s only `$PG17_HOME/dist`, never `clusters/`. The binding independently re-checks the same two binary hashes and the version at its preconditions, so a wrong server cannot reach `init`.
- `setup-10-clients.sh` (`622f1997…`): apt `postgresql-client-18` (falls back to 17/generic), refuses client major < 17; recorded result psql 18.6. The binding requires only `/usr/bin/psql` executable; the spec uses `psql -X -At` for SQL text, whose semantics do not depend on the 18.x point version.
- Both installers source `_common.sh`, which takes the SAME canonical `flock -n` on `execution/test-validation.lock` (75 if busy) and logs under `execution/s2-composition/infra/logs/`. The next heavy owner must therefore run them as the lock holder in the ordinary way (each step takes and releases the lock itself), not while separately holding the lock in the same shell, and should copy `_common.sh` alongside or run the direct equivalents as `ENVIRONMENT_RECOVERY.md` already notes.

## 5. Findings for this Part (Safety-ROI classes)

**Class A: none** — the fixture and binding touch only a loopback disposable cluster on a new port/data directory, with fresh-init-only, marker-guarded start/stop, no destroy invoked, no remote, no product source change; the spec under test is the frozen `cc3b0e4d` blob.

**Class B: none** — the binding pins fixture bytes, head, tree, spec blob, toolchain hashes and server identity; raw rcs are captured before any summary; first failure stops with a single bounded stop; sentinel carries the first rc; nothing can attribute a stale or foreign result to `a0ea1bea`.

Class C (record, qualify, continue — no new cycle), numbered after C15:
- **C16** Bounds: README states step bounds sum 810 s; the nominal maxima are 60+60+30+15+15+600+75 = 855 s (§5's "stop 45 s" is preserved as the inner `pg_ctl -t 45`; the 75 s wrapper adds margin). Realistic worst paths stay under the outer `timeout -k 30 900` (jest full 600 s + one cleanup stop ≈ 745 s; success ≈ 700 s). Only a multi-step pathological hang could exceed 900 s, in which case the outer kill would skip the fixture stop and leave a loopback postmaster survivor — visible at the next preflight (`postgres` procs / port 55439), never silent. Recorded; no change requested.
- **C17** Port check `ss -ltn … | grep -c … || true` would silently read 0 if `ss` were absent; `ss` is present here, and the `pgrep` check fails closed (empty → mismatch → rc 71). Moot in this sandbox.
- **C18** psql client version is not pinned by the binding (presence only); recorded 18.6; immaterial to the SQL text the spec issues.
- **C19** Recovery installers take the canonical lock themselves and log to an `s2-composition` path; operational note for the next heavy owner only.
- **C20** `run/` receipts directory is created by the binding at launch (`mkdir -p "$R"`) before the lock is taken, so a lock-busy (75) attempt leaves an empty `run/` but no sentinel — harmless, and the run-once guard keys on the sentinel, not the directory.

## 6. Part 2 verdict — FROZEN

**Fixture variant `c1-fixture.sh` (`27b816af…`): ACCEPTED as substitution-only against donor `3a7d57bf…`** — constants, `initdb -A trust` without pwfile, caller guard re-pointed, prefix/message renames, plus the necessary `dirname "$DATA"` mkdir; refusal/marker/bounded-stop/survivor/destroy semantics byte-identical. `derive-c1-fixture.sh` reproduces it deterministically.

**Execution binding `c1-pg-proof.sh` (`505061752…`): GRANTABLE from B's side** for exactly ONE run of the existing 22-case `test/rls-c1-setup.spec.ts` (blob `cc3b0e4d`) on head `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, launched as `timeout -k 30 900 bash /home/user/workspace/execution/95633079/c1-pg/c1-pg-proof.sh` by the canonical heavy-lock owner, after that owner recovers the absent PG 17.6 dist and psql client to the recorded pins (the binding refuses rc 70 otherwise). Preconditions for the grant to apply: packet manifest still `e612bd35…`; no `run/c1-pg-proof.sentinel`; S5 cluster still absent (preserve absence, no reconstruction); no S5/S6 runtime concurrently.

Acceptance for that run is §6 as written, observed as-is and not redefined: guards silent; `Test Suites: 1 passed, 1 total`; `Tests: 22 passed, 22 total`; 0 skipped/todo/failed; jest rc 0; fixture init/start/stop raw rc 0; after stop 0 postgres processes, port 55439 free, no `postmaster.pid`, data dir retained; S5 absent-unchanged; worktree HEAD/porcelain unchanged; sentinel `RC=0 STAGE=done`; lock released; no survivors.

**No acceptance is granted here.** Final C1 acceptance requires Part 4 — my attestation of the actual PG receipts (`run/c1-pg-proof.log`, `run/jest.log`, sentinel, `RECEIPTS.sha256`) — which the parent will send when frozen.
