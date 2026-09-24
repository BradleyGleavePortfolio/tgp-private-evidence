# S7-2 C1 independent review B — Part 4: attestation of the actual real-PostgreSQL proof (final phase)

Reviewer: independent non-builder B (T4) continuation, session `95633079`. Observed 2026-09-24 ~06:31–06:36Z. Requested route Claude Fable 5 / High (requested routing, not observed telemetry).

Additive to: sealed source-phase B (`resume-evidence/execution/e7d2385c/audits/s7-c1-b/`, manifest re-verified OK this session), Part 3 (`ACTUAL_COMMIT_AND_TARGETED_RESULTS.md` `1e260a64…`, A0/B0, C10–C15) and Part 2 (`PART2_MINIMAL_FIXTURE_AND_EXECUTION_BINDING.md` `f2ee0076…`, A0/B0, C16–C20). All carried forward unchanged; nothing from those phases is re-reviewed here. Scope of this Part: independently attest the raw results, exact head, cleanup, retention and lock state of the one PG proof run, against the frozen §6 acceptance (`C1_PG_PROOF_PREPARATION.md` `1a683bf9…`) — no new criteria.

Mode: static reads only — sha256 of receipts, `cat`/`tail`/`grep`/`ls`/`stat` of packet files, cluster directory and server log, `pgrep`/`ss`/`/proc/locks` read-only observations, `git rev-parse`/`git status --porcelain` with `GIT_OPTIONAL_LOCKS=0`. No fixture/binding/installer/jest/psql/prisma/node invocation, no probe connection, no install, no lock acquisition, no write outside `execution/95633079/audits/c1-b/**`.

Disclosure: no file under `audits/c1-a/**` or `s7-c1-a/**` was opened. The packet's `README_ADDENDUM.md` (a v2/v3-manifested executor file) was read for the receipt layout; it quotes A's one-line verdict and two A qualification labels (C07/C08). It was read after my Part 2 verdict was written and frozen (file mtimes: Part 2 report 06:30Z, addendum first read ~06:32Z); nothing in Parts 2–4 derives from it beyond the executor's own statement of the pre-final-checksum behaviour, which I verified independently below.

## 1. Receipt set and integrity (all hashes recomputed by me)

| File | sha256 (mine) | Executor / manifest claim | Match |
|---|---|---|---|
| `c1-pg/ACTUAL_PG_PROOF_RECEIPT.md` | `ce422b42195974ca66258dda55e1a9944bda160bbe5d39adbec8d22eec3c0b49` | parent mail `ce422b42…` | yes |
| `c1-pg/MANIFEST.v3.sha256` | `4aec32daebaddd9c6a581fd86b8f71e7a192712895a353aa57b008181add6baa`; `sha256sum -c` all OK | parent `4aec32da…` | yes |
| `c1-pg/MANIFEST.sha256` (v1, reviewed in Part 2) | `e612bd35…`; still all OK — reviewed `c1-fixture.sh` `27b816af…` and `c1-pg-proof.sh` `50506175…` unchanged | — | yes |
| `run/c1-pg-proof.sentinel` | `431b4cfc…`; content `RC=0 STAGE=done END=2026-09-24T06:30:27Z HEAD=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` | receipt `431b4cfc…` | yes |
| `run/c1-pg-proof.log` (23 lines) | `c0b13a6ea75c048d0f583ae48916aff15761b8225544a8c0b965c51841e298ed` | receipt `c0b13a6e…` | yes |
| `run/jest.log` (31 lines) | `33b1695ec06e9edd998806fd220a917bc4e85b7fb0a911a361fe31323e522261` | `run/RECEIPTS.sha256` and receipt | yes |
| `run/RECEIPTS.sha256` | proof.log entry `96fe471e…` ≠ final log — **I confirmed `head -n -2 c1-pg-proof.log` hashes to exactly `96fe471e…`**, i.e. the snapshot was taken before the last two lines (`POST_OK`, `END`) were appended, as the binding's step order dictates (RECEIPTS written inside the post step). Same property for `env/RECEIPTS.sha256`: `head -n -1 c1-env-recovery.log` = `f0fd01e0…` (before `END`). Pre-final snapshot, not a terminal seal; not a failure; no rerun implied. | executor's stated behaviour | yes |
| `run/LAUNCH.txt` | `GRANT2_LAUNCH 2026-09-24T06:29:57Z cmd='timeout -k 30 900 bash c1-pg-proof.sh' sha=50506175… fixture=27b816af…` — the exact launch line granted in Part 2 §6 | — | yes |
| `run/launcher.out` (1416 B) | stdout copy of the binding's `log()` lines; `diff` vs the log shows only the four fixture/psql stdout lines (`C1_FIXTURE_INIT_OK…`, `C1_FIXTURE_START_OK pid=22075`, `CREATE DATABASE`, `C1_FIXTURE_STOP_OK`) which the binding routes to the log file only — consistent | receipt table says "empty" — inaccurate (see C22) | content consistent |
| `env/LAUNCH.txt`, `env/c1-env-recovery.sentinel` (`RC=0 STAGE=done END=2026-09-24T06:29:19Z`), `env/c1-env-recovery.log` | v3 hashes match; log shows psql 18.6 sha `a200e38c…`, Maven SHA1 == pinned `81633223…`, jar `23da5a04…`, txz `26fa6334…`, `postgres`/`initdb` == `23cd1748…`/`b7db9bc2…`, `pg_ctl` `af53d826…` (recorded prefix), `server='postgres (PostgreSQL) 17.6'`, `clusters_dir=absent postgres_procs=0`, `END rc=0` | receipt Grant 1 table | yes |
| `/home/user/pg17/PROVENANCE.txt` | sha256 prefix `aba2a25a…`, `result=success`, `utc=2026-09-24T06:29:19Z`, postgres sha == pin | receipt | yes |

## 2. Frozen §6 acceptance — item by item, from raw receipts

| §6 criterion | Raw evidence | Met |
|---|---|---|
| Guards silent (none of `requires an explicitly acknowledged disposable cluster`, `not the permitted disposable database`, `server identity mismatch`) | `grep -c` over `jest.log` for all three strings, plus `skipped`/`todo`/`✕`: **0** | yes |
| `Test Suites: 1 passed, 1 total` | `jest.log` line 29 and proof log | yes |
| **`Tests: 22 passed, 22 total`**, 0 skipped/todo/failed | `jest.log` line 30; 22 `✓` lines counted; the 22 titles are the 15 `it` + `it.each` 3/2/2 expansions of blob `cc3b0e4d` (three `denies inactive/ineligible owner …` student/deleted/missing; two `injected … update failure`; two `restrictive RLS denies anon/authenticated`) — matches the case inventory fixed in sealed B | yes |
| jest rc 0 | `JEST_END rc=0 2026-09-24T06:30:27Z`; sentinel `RC=0` | yes |
| Exact command, once, no `--testTimeout`/`--forceExit` | `JEST_START … cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci'` — verbatim §5 step 6; one `JEST_START`/`JEST_END` pair; `Ran all test suites matching test/rls-c1-setup.spec.ts.` | yes |
| Identity: real PG 17, permitted data dir | `IDENTITY_OK data_directory=/home/user/pg17/clusters/c1-builder/pg-data server_version_num=170006`; `PRECONDITIONS_OK server='postgres (PostgreSQL) 17.6'` | yes |
| Fixture init/start/stop raw rc 0 | `FIXTURE_INIT rc=0`, `FIXTURE_START rc=0` (`pid=22075`), `CREATE_DATABASE rc=0`, `FIXTURE_STOP rc=0` — all 06:29:59Z–06:30:27Z; `pg.log.pg_ctl`: `server started` / `server stopped` | yes |
| Stop leaves 0 postgres processes, no `postmaster.pid`, port free | binding: `STOP_STATE_OK postgres_procs=0 port55439=free`; **my re-check ~06:34Z**: `pgrep -cx postgres` = 0, `ss -ltn` listeners on 55439 = 0, `pg-data/postmaster.pid` absent; server log for pid 22075: `received fast shutdown request` 06:30:27.350 → `checkpoint complete` → `database system is shut down` 06:30:27.366; exactly one `database system is ready to accept connections` (one start, one stop); no `FATAL`/`PANIC` | yes |
| Data dir retained | `/home/user/pg17/clusters/c1-builder/pg-data` present (mtime 06:30:27Z), `postgresql.conf` has `cluster_name = 'c1-disposable-pg17'`, `port = 55439`, `listen_addresses = '127.0.0.1'`, `unix_socket_directories = '/home/user/pg17/run/c1'`; `pg_hba.conf` trust on local/127.0.0.1/::1 only; `pg-data.initdb.log`, `pg.log`, `pg.log.pg_ctl` alongside; no destroy invoked | yes |
| `clusters/s5` unchanged and never started | Fresh sandbox: `PREFLIGHT s5_cluster=ABSENT (… not reconstructed)` and `POST s5_cluster=ABSENT unchanged`; my `ls`: `clusters/` contains only `c1-builder` — absence preserved, no reconstruction (per parent instruction) | yes (absent-unchanged) |
| Exact head, clean tree | `START … head_expect=a0ea1bea…`; preconditions pin HEAD/tree/spec blob; sentinel `HEAD=a0ea1bea…`; `PREFLIGHT_OK … worktree_porcelain_sha=e3b0c442…` (sha256 of empty = porcelain 0) and `POST_OK` unchanged; **my re-check**: `git rev-parse HEAD` = `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, `git status --porcelain` 0 lines, no `MERGE_HEAD` | yes |
| Bounds respected, outer ≤ 900 s | Launch `timeout -k 30 900`; `START 06:29:57Z` → `END 06:30:27Z`: 30 s wall; jest 26.684 s (< 600), every step well inside its bound; no `timeout` rc 124/137 anywhere | yes |
| No survivors, no QUARANTINE, lock released | binding exited normally (sentinel `STAGE=done`), so fd 9 closed; **my re-check**: `/proc/locks` has no entry for the lock file's inode (735612) → 0 holders; `pgrep -af` for `c1-pg-proof|c1-fixture|c1-env-recovery|pg_ctl|jest` → none; no `QUARANTINE` string in any receipt | yes |
| Nothing relabelled | Raw rcs printed per step; RECEIPTS snapshot mismatch left as-is and explained, not rewritten; original `13-C1_ACTUAL_RESULTS_SEAL.md` and v1 manifest untouched | yes |

All frozen §6 criteria are met by the raw receipts and independently re-observed state.

## 3. Findings for this Part (Safety-ROI classes)

**Class A: none. Class B: none.**

Class C (record, qualify, continue — no new cycle), numbered after C20:
- **C21** `jest.log` line 1 is a Nest `ERROR [ExtensionPairService] pair init: exhausted code-mint attempts` (pid 22108, 06:30:25). This is the service's own `logger.error` at `src/extension-pair/extension-pair.service.ts:164`, emitted by the passing case `five actual code collisions roll back new intent and preserve previous setup` (spec line 291), which deliberately exhausts mint attempts. Expected log noise from a negative-path test, not a failure signal; `PASS` and 22/22 follow it.
- **C22** Receipt-document imprecisions only: `ACTUAL_PG_PROOF_RECEIPT.md` lists `run/launcher.out` as "empty" — it is 1416 B (v3 hash `90dda9a6…`), a consistent stdout subset of the log; and `jest --version` printed `30.4.1` while `node_modules/jest`, `jest-cli`, `@jest/core` `package.json` are all `30.4.2` (recorded pin) — I confirmed the three package files; the banner discrepancy is jest's own CLI banner, recorded as observed, no action.
- **C23** `run/RECEIPTS.sha256` and `env/RECEIPTS.sha256` are pre-final snapshots by construction (hash taken two / one line(s) before the log ends); verified exactly. The governing terminal receipts are the raw log, `jest.log`, the sentinel and `MANIFEST.v3.sha256` (which hashes the final logs). Recorded once more so no later reader treats the "FAILED" line from `sha256sum -c RECEIPTS.sha256` as a proof failure.
- **C24** Cleanup is an identity-bound receipt, not a guarantee: my 0-process / 0-listener / 0-lock-holder readings are for the C1 identities (postgres cluster `c1-disposable-pg17` pid 22075, port 55439, the binding's fd 9). Any processes or lock the extension lane holds from now on are that lane's, not C1 survivors.

## 4. Final B verdict — FROZEN

Carried unchanged: source phase GRANTABLE (A0/B0, C1–C9); Part 3 actual commit `a0ea1bea…` + targeted Jest 190/190 attested (C10–C15); Part 2 fixture `27b816af…` substitution-only and binding `50506175…` grantable (C16–C20).

**Part 4: the one real-PostgreSQL proof of the existing 22-case `test/rls-c1-setup.spec.ts` (blob `cc3b0e4d`) at committed head `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` is ATTESTED as run exactly once under the frozen §5 sequence with all frozen §6 acceptance criteria met: `Tests: 22 passed, 22 total`, `Test Suites: 1 passed, 1 total`, jest rc 0, guards silent, PG `170006` at the permitted data directory, fixture init/start/create/stop rc 0, clean fast shutdown, 0 postgres processes, port 55439 free, no `postmaster.pid`, data dir retained, S5 absent-unchanged (never reconstructed), HEAD exact and tree clean before and after, bounds respected (30 s wall), lock released, no survivors.**

**C1 (S7-2) from reviewer B: ACCEPTED** — A=0, B=0 across all four parts; C1–C24 recorded as qualifications that request no rerun, no new cycle, no harness or test change. Scope of the acceptance is exactly what the receipts show: this spec on this head against a fresh pinned disposable PG 17.6; not E/T-Q0, S1–S3 suites, full-history migration drift, production readiness or any remote/deploy state (the 190-test targeted lane was attested separately in Part 3).
