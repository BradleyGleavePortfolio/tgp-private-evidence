# B/drain — Reviewer B (successor) FINAL FINDING on candidate 0d69c7ba (v5)

Reviewer: independent non-builder reviewer B **successor**, session cf8ff737 (same review continued from notes 01/02, actual-head attestation, PG failure diagnosis, v5 delta attestation). Requested T4 Fable/High; no runtime telemetry observable, none claimed. Read-only; no runtime, no gate run, no peer-A material.

## 1. PRE-1 rename bound (`runtime-v5/PRE1_RENAME_RECEIPT.txt`)

`mv /home/user/pg17/clusters/b-drain → …/b-drain.v4-failed-75a2863b-20260924T151250Z` at 15:36:10Z, rc0; prechecks src present / dst absent / `postmaster.pid` absent / 0 postgres procs / port 55461 free / canonical lock free. Before == after: `pg_control` `d037d71b…`, `postgresql.conf` `173acaa2…`, du 77372, 2559 entries, `postmaster.pid` absent. I re-hashed the renamed `pg_control` now: `d037d71b…` — the failed-v4 datadir is preserved byte-identical. Exactly the named precondition, nothing more.

## 2. Runner bound (`runtime-v5/run/`, `OUTER_RECEIPTS.sha256` 8/8 OK, `RECEIPTS.sha256` present)

- `LAUNCH.txt`: `timeout -k 30 3600 bash …/runtime-v5/binding/b-pg-proof.sh` 15:37:47Z, runner sha `e895b16e…` == my attested v5 binding (unchanged run).
- `START head_expect=0d69c7ba…`, `PRECONDITIONS_OK` (postgres 17.6 sha `23cd1748…873a` provenance success, psql 18.6 client, node v20.20.1), `PREFLIGHT_OK bdir=absent port55461=free postgres_procs=0 porcelain=empty`, S5 ABSENT, C1 ABSENT.
- `FIXTURE_INIT rc=0` (`b-disposable-pg17`, 55461, `b_super`), `FIXTURE_START rc=0`, `OLD_ROOT rc=0` re-created under `runtime-v5/old-root` at `925780e0`, 164 migrations, no alternates.
- `BOOTSTRAP rc=0` 15:38:03Z: 164 old migrations applied to `g2_b_drain_disposable`, O-client generated with engine `a2924eab…` == candidate client engine `a2924eab…` (`CANDIDATE_CLIENT_VERIFIED`), `G2_B_BOOTSTRAP_OK`.
- `IDENTITY_OK` data_directory `/home/user/pg17/clusters/b-drain/pg-data`, server 170006, cluster_name `b-disposable-pg17`.
- `JEST_START` 15:38:03Z (`--config jest.rls.config.js test/rls-g2-b-drain.spec.ts --runInBand --ci`) → `JEST_END rc=0` 15:38:56Z: run time 52.444 s, exit within ~1 s of completion — **natural exit, no open handle, no TERM**.
- `FIXTURE_STOP rc=0`, `STOP_STATE_OK postgres_procs=0 port55461=free datadir_retained`, `POST s5 ABSENT unchanged`, `POST_OK`, `END rc=0 stage=done 2026-09-24T15:38:57Z`. Sentinel: `RC=0 STAGE=done END=2026-09-24T15:38:57Z HEAD=0d69c7ba…`.

## 3. Live spec result bound (`runtime-v5/run/jest.log`)

`PASS rls-live test/rls-g2-b-drain.spec.ts`, **Tests: 19 passed, 19 total** — the exact 19 `it(` of committed spec blob `9b31fd18…` (unchanged since v4; count explained in the diagnosis note §2). All 8 previously failing tests now pass with the same spec text: 5.2 (890 ms), 5.4, 6.1, 6.2, 6.3 (1242 ms, worker released), 6.4, 7.1 `down keeps column, rows and history; NULL inserts are admitted again` (1688 ms), 7.2 `re-applying the file restores the identical fence`. The 11 previously passing tests still pass. `PG17_FENCE` oracle line present. This directly confirms the root cause in my diagnosis: the sole change between the failing and passing runs is the two `cardinality(t.tgattr::int2[]) = 0` predicates; the fixture, bootstrap, spec, tooling and PG binaries were pinned identical.

## 4. Post-run state (checked live, read-only, 15:4xZ)

HEAD `0d69c7ba…` unchanged, worktree clean (porcelain 0); 0 postgres processes; no 55461 listener; `clusters/b-drain/pg-data` retained and stopped; renamed v4 datadir present; first proof `runtime/run/RECEIPTS.sha256` 5/5 OK and v4 filled binding `a64d24de…` byte-unchanged; sealed template `25eb6837…` intact (verified in the v5 attestation). Lock file path exists as a file (normal for a flock file); parent reports the slot free — I did not touch it.

## 5. Findings

- **No A. No B.** No environment stop, no candidate defect, no unexplained result.
- C-13 (record/continue): `clusters/b-drain` now holds the v5 datadir; any future B-lane run would again hit PRE-1 — handled by the same preserving rename, not by a control.
- C-6 (detached HEAD), C-3 (prod-readiness-quick no-op), C-8/C-9 (jest banner 30.4.1 vs package 30.4.2; psql 18.6 client vs 17.6 server), C-10 (duplicate `BEGIN` warning) carried; none affect acceptance.

## 6. FINAL B FINDING — ACCEPT

Reviewer B accepts candidate **`0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`** (tree `d02f9b12…`, parent `75a2863b…`, message `fix(importer): recognize empty trigger column vectors`) for the B/drain lane:
- v4 source verdict SOURCE_GRANTABLE applies to all 2152 unchanged tree entries; the 2-line v5 delta is exactly the authorized minimum closure for the A finding and is confirmed correct by the live proof;
- actual head identity, genuine hooks, phase-A gates (tsc/eslint/prettier/check-r75/42-case DB-free suites) rc0;
- single real-PostgreSQL 17.6 proof under the sealed v3 template, unchanged filled binding `e895b16e…`, 19/19 with natural exit, fail-closed runner END rc0, zero survivors;
- failed v4 history (`75a2863b`, `runtime/**`, renamed datadir) preserved, not rewritten.

Acceptance scope, stated exactly: this is B-lane engineering acceptance of the candidate on a local disposable fixture. It is **not** landing, remote push/merge, deployment, canary, customer/production enablement, or product acceptance; R remains gated on the parent's final dual disposition and ordinary release path. No owner-reserved decision is triggered by this finding.

Review closed for this candidate. A further review is required only if the candidate or a material dependency (spec blob, bootstrap, fixture, PG binaries, dependency tree) changes.
