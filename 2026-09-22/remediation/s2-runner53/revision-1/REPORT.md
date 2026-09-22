# S2-RUNNER-53 — execution-only runner closure (v5.3) on unchanged d5cd9b8b — 2026-09-22 04:29–04:45 UTC

Worker: sole S2-RUNNER-53 builder (requested Claude Fable 5 / High; requested identity only — no runtime model telemetry is exposed to this worker, none is claimed). Writes confined to `worktrees/s2-runner53` (restore only, no commits) and `execution/s2-runner53`. No remote action, no product/DB/heavy run, no canonical-lock acquisition, no install.

## 1. Restoration (recovery, not reimplementation)

| Item | Value | Check |
|---|---|---|
| Bundle | `tgp-private-evidence/2026-09-21/remediation/s2-composition/b2-failed-and-r3-source/s2-composition-r3-d5cd9b8b-from-public-c23b9d9.bundle` | sha256 `3b6cee481319dd518268b7573ebed142fa234e193b874d8712a6cdf5493c0f75` = brief/request 03 (`restore/bundle.sha256`) |
| `git bundle verify` | okay; contains `refs/heads/execute/20260921-s2-composition-r2` = d5cd9b8b; requires public `c23b9d9f` | `restore/bundle-verify.txt` |
| Isolated repo | `/home/user/workspace/worktrees/s2-runner53` (local clone of `source/backend` @ c23b9d9f, `origin` removed, 0 remotes; bundle fetched; branch `execute/20260921-s2-composition-r2`) | — |
| Head / tree | `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c` / `c0ab87d4dc584b2a7ccad53db16fa551b93fe359` (= request 03) | `restore/RESTORE_VERIFICATION.txt` |
| Clean | 0 porcelain lines before and after all controls | idem |
| Ancestry | parent `21ea3252`; ancestors `9742037b`, S1 `56fb0d22`, public `c23b9d9f` all confirmed; delta vs 21ea3252 = 1 file (+12/−7) `test/release/s1s2-composition.sh` | idem |
| Blob identities | harness `c766a8d9…3867`, release.sh `8831f8f7…f073`, package-lock `62b05b90…1390`; S1 paths identical to 56fb0d22; closure files identical to 9742037b | idem |
| Commit set | identical to archived `commits-r3.txt`; all 22 commits author=committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 0 AI/co-author trailers | `restore/commits-restored.txt` |

Source d5cd is unchanged; no commit was created, so no new bundle is needed — the archived bundle above is the exact source artifact. Archive and baseline repositories were not edited.

## 2. v5.2 not preserved → explicit reimplementation as v5.3

The named packet holds runner versions v4.0 (reconstructed), v4.1 (as-run), v5.0 and v5.1 only (`runner-history/`). The v5.2 runner recorded in `LAST_OPERATOR_STATE.md` / handoff as `7e280683…5ccb` is **not present** anywhere in the local private archive (grep over the evidence checkout finds the hash only in the state/handoff/dispatch prose). Per the brief, no historical search was performed. **v5.3 is a reimplementation from frozen v5.1 (`0f4467e0…2e15`) plus the recorded counterexamples**; it does not claim to recover or contain v5.2 bytes.

Also not preserved: the fixture `infra/s2-fixture.sh` sha `6062f4ce…d61` named by request 03 (archive holds `33452b03` and `08987e4c`, both with a fixed `clusters/s2comp` data dir, no `S2_FIXTURE_NS`). v5.3 pins `EXPECT_FIXTURE_SHA=6062f4ce…` and **refuses (70)** in real mode if the fixture is absent/different, so the gap fails closed instead of silently substituting a fixture. Not reimplemented here (outside the runner-closure slice).

## 3. Runner v5.3 — `run-composition-r3-v5.3-when-granted.sh`

sha256 **`fbc8b9af592b370429a66bf164d3c5ac0f0b1bac0f57474c50ac293ebebd1bfc`** (235 lines; frozen before the controls, byte-identical after — `controls/SHA256SUMS.inputs-before-controls` re-verified). Diff vs v5.1: `runner-history-v5.1-to-v5.3.diff` (305 lines). Paths re-pointed to this lane (`WT=worktrees/s2-runner53`, `LANE=execution/s2-runner53`); the v5.1 comparison against the absent `worktrees/s2-composition` files is replaced by `git diff --quiet 9742037b HEAD -- package-lock.json package.json prisma/schema.prisma` (same admissibility fact, self-contained).

Closure vs acceptance:

| Acceptance | Implementation | Control |
|---|---|---|
| TERM/INT/timeout halt owned work **before** fixture stop | every step runs in its own process group (`setsid`, pid/pgid/label recorded; isolation anomaly → 70). `trap on_signal TERM INT HUP` (registered after the EXIT trap): label step `interrupted(<sig>)`, TERM the group, bounded reap, KILL, bounded reap, then cleanup. Cleanup also re-scans owned work on the normal path before touching the fixture. | K3 (ordering SIGNAL < REAP ok < fixture stop), K2 |
| failed reap forbids stop/mutation | `REAP=FAILED` → `QUARANTINE.txt` (survivor pids/cmdlines), `fixture_stop=REFUSED`, cleanup class **72**, nothing erased, no further mutation | K4 |
| lock retained through cleanup or explicit quarantined refusal | fd 9 held by the runner through cleanup (probed and stamped `HELD` at cleanup begin and end); on quarantine/survivors the stamp says `NOT safely handed off` | K3, K4 |
| whole cleanup fits outer grace with stated margin | constants: reap 10+5 s, fixture stop `timeout -k 3 20` (fixture's own `pg_ctl -w` default of 60 s alone would exceed grace), status `-k 2 5`, scan/hash allowance 3 s → **worst 48 s of the 60 s `-k` grace, margin 12 s**; stamped at start and cleanup; actual `cleanup_seconds` recorded | K4 observed 17.00 s on the worst reap path; K3 0.39 s |
| first failure never hidden | `first_exit` (first failing step or signal code 143/130/129) and `cleanup_exit` (0/71/72) recorded separately in `exit-codes.txt` and stamp; process exit = first_exit if nonzero else cleanup class | K5 (0 → 71), K6 (3, no stop), K3/K4 (143 with 0 / 72) |

Carried unchanged from v5.1: single nonblocking lock on fd 9 from before fixture init to exit; fd 9 closed for every child except fixture init; 75 lock busy; head/dirty/lockfile/closure refusals 70; refusals 20/21 must be 64 before any server; fresh-only namespace/54321/no-postgres prechecks; pre-existing release.sh `/tmp` scratch files → 70 untouched; survivor scan anchored to real child cmdlines plus 54321 listener; stop attempted whenever start was attempted; SHA256SUMS written last.

## 4. Controls actually executed (stub mode, no DB/network/install/canonical lock)

Driver `controls/run-controls.sh` sha256 `4d4bc661…4689`; stubs in `controls/stubs/` (hashes in `controls/SHA256SUMS.inputs-before-controls`); results `controls/20260922T043943Z/CONTROLS_RESULT.txt` (+ per-control driver logs, `SHA256SUMS`), runner outputs `runner-selftest-r53/<utc>/`. Sequential, one at a time; **total wall clock 30.85 s of the 60 s allowance**; lane-private lock `controls/stubs/test-validation.lock`; canonical `execution/test-validation.lock` never created/touched; pre-snapshot of owned patterns empty; every survivor was killed by the driver **by recorded pid** (only pids matching our stub patterns and their descendants) and confirmed gone. Two further isolation probes (~2 s) are in `controls/wait-status-15-isolation.txt`.

| Control | Command shape | Expected | Actual |
|---|---|---|---|
| K1 predecessor **mechanism** (reimplemented v5.1 shape — foreground `timeout --foreground` step + EXIT-trap stop; **not v5.1 bytes**) | `timeout --foreground -k 5 2 bash k1-predecessor-mechanism.sh` | outer 124; fixture stop runs under live step child; step child tree survives | 124; `50 fixture-stop exit=0`; survivors `timeout…harness.sh k1db`, `bash …harness.sh k1db`, `sleep 20` alive after exit → predecessor defect reproduced, then killed by driver |
| K2 v5.3 success | `S2_RUNNER_STUBS=… bash runner` | 0; all registers 0; refusals 64/64 | `final=0 first_exit=0 cleanup_exit=0 reap=ok … refusal_hosted=64 refusal_noconfirm=64 fixture_stop=0 survivors=none`; REAL head/tree/clean check at d5cd; real harness offline refusals `URL_HOST` / `CONFIRM` (string layer, no connection); fixture init saw inherited fd 9, harness saw fd 9 closed |
| K3 TERM during step 40 (stub harness sleeps 30 s) | `timeout --foreground -k 20 3 env S2_RUNNER_STUBS=… bash runner` | halt+reap before stop; `composition=interrupted(TERM)`; first_exit 143; no survivors | outer 124; `final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok … composition=interrupted(TERM) s1_r4_discriminator=notrun fixture_stop=0 survivors=none`; stamp order SIGNAL(17) < REAP ok(20) < fixture stop(22); lock HELD through cleanup; cleanup 0.39 s; no child survived |
| K4 TERM with a `setsid`-escaping child | as K3 with `STUB_HARNESS_MODE=escape` | reap FAILED within 15 s; stop REFUSED; 72; QUARANTINE.txt; lock not handed off | `final=143 first_exit=143 cleanup_exit=72 signal=TERM reap=FAILED … fixture_stop=REFUSED survivors=present`; `QUARANTINE.txt` = `12670 s2r53-stub-escapee 40`; no `50-fixture-stop.log`; cleanup 17.00 s (TERM 10 s + KILL 5 s + ~2 s); escapee then killed by driver by pid |
| K5 stop rc=1 on normal path | `STUB_STOP_RC=1 …` | first_exit 0 preserved, cleanup 71, exit 71 | `final=71 first_exit=0 cleanup_exit=71 … fixture_stop=1 survivors=none` |
| K6 guard spec rc=3 | `STUB_GUARD_RC=3 …` | exit 3; later steps notrun; no stop | `final=3 first_exit=3 cleanup_exit=0 … fixture=notrun composition=notrun fixture_stop=notrun` |

Strike count 0; no unexplained failure. One explained observation: the HALT stamp shows `wait status 15` (not 143) for the step child. Isolated (`controls/wait-status-15-isolation.txt`): with **uutils coreutils 0.8.0 `timeout --foreground`** run under `setsid`, a TERM delivered to the whole group makes `timeout` exit 15 rather than 143; TERM to the `timeout` pid alone gives 143. Diagnostic label only — the runner's `interrupted(TERM)` register and `first_exit=143` come from the runner's own trap. Not changed (a byte change would require re-running the controls beyond the 60 s allowance); flagged for reviewers.

## 5. Not executed / limits (do not read as proof)

- STUB MODE only: no PostgreSQL, no harness proof, no S1 discriminator, no real fixture stop timing. v5.3 proves nothing about release composition, the S1 discriminator, hosted enforcement, production safety or customer acceptance.
- Real mode was never entered; its refusal branches (toolchain, node_modules, PG17, fixture hash, namespace/54321/postgres/`/tmp` prechecks) were syntax-checked (`bash -n`) but not exercised here.
- The fixture stop budget (`timeout -k 3 20`) was not exercised against a hanging stop (would cost ≥23 s); bounded by construction only. Real `pg_ctl -m fast` stop time on a 165-migration cluster is unmeasured in this lane (B2 stopped in <2 s per its logs, historical).
- v5.1 itself was **not** run: its hard-coded `WT=worktrees/s2-composition-r2` and `LANE=execution/s2-composition` are absent / outside this worker's write area, and its toolchain prechecks fail closed here. K1 is a reimplemented mechanism counterexample; the original v5.1 TERM control remains the frozen evidence in request 03A.
- Sandbox toolchain (`controls/TOOLCHAIN.txt`): `timeout`/`sha256sum` are **uutils coreutils 0.8.0** (not GNU), util-linux 2.41.3 flock/setsid, procps-ng 4.0.4, bash 5.3.9, git 2.53.0, node 20.20.1; **psql, PG17 dist, node_modules and the A2 dependency closure are absent** — B3 cannot run in this sandbox without a separately granted setup slot. v5.3 does not stamp the `timeout` implementation; recommended v5.3.1 addition under a new control allowance.
- Inner step bounds (120/120/120/120/120/30/1500/300 s) sum to more than the 2100 s outer bound, as in v5.1; the outer TERM path is now closed, but a run that legitimately needs the full inner budgets would still be cut by the outer bound and reported as `interrupted(TERM)`.
- `S2_RUNNER_STUBS` remains an env switch (as in v5.1); the launch command must include `env -u S2_RUNNER_STUBS`. No head/DB/keep-fixture override exists.
- No audit clearance is claimed. This is a T4 execution-control change: two independent risk-scoped reviews of the frozen runner bytes plus cumulative applicability to d5cd are required before any real proof.

## 6. Evidence layout (this lane)

```
execution/s2-runner53/
  REPORT.md  NEXT_REQUEST.md  SHA256SUMS.outer (non-self-including)
  run-composition-r3-v5.3-when-granted.sh        fbc8b9af…1bfc
  runner-history-v5.1-to-v5.3.diff
  restore/{bundle.sha256,bundle-verify.txt,bundle-heads.txt,RESTORE_VERIFICATION.txt,commits-restored.txt}
  controls/{run-controls.sh,k1-predecessor-mechanism.sh,stubs/*.sh,SHA256SUMS.inputs-before-controls,TOOLCHAIN.txt,wait-status-15-isolation.txt,driver.stdout.log}
  controls/20260922T043943Z/{CONTROLS_RESULT.txt,k1/,k2..k6.driver.log,SHA256SUMS}
  runner-selftest-r53/<utc>/{stamp.txt,exit-codes.txt,step logs,QUARANTINE.txt(K4),SHA256SUMS}
```
Worktree `worktrees/s2-runner53`: d5cd9b8b, clean, 0 remotes, nothing committed.
