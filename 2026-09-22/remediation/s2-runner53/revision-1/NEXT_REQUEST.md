# S2-RUNNER-53 — next required action (request, not a grant; nothing here is authorised until the parent says so)

## A. Review first (required before any real proof)
Two independent, risk-scoped reviews of the frozen runner bytes and their cumulative applicability to unchanged d5cd9b8b:
- runner `execution/s2-runner53/run-composition-r3-v5.3-when-granted.sh` sha256 `fbc8b9af592b370429a66bf164d3c5ac0f0b1bac0f57474c50ac293ebebd1bfc`
- diff `runner-history-v5.1-to-v5.3.diff` against frozen v5.1 `0f4467e00c1ec878f4b8ff204a910d271a817a3c6bdc28a0df44f25023842e15`
- controls `controls/20260922T043943Z/CONTROLS_RESULT.txt` and `runner-selftest-r53/*` (stub mode, NOT evidence of DB behaviour)
Review questions worth asking: (1) is a 15 s reap + 20 s stop budget adequate for the real fixture (pg_ctl -m fast on the 165-migration cluster)? (2) is refusing the fixture stop after a failed reap (leaving a postgres running under quarantine) the intended safety posture, versus stopping it anyway? (3) uutils `timeout --foreground` exit 15 under a group TERM — any effect on the outer launcher's 124/exit sentinel? (4) should the runner stamp the `timeout` implementation (proposed v5.3.1, one stamp line, re-controlled under a fresh ≤60 s allowance)?

## B. Prerequisites the parent must resolve before B3 can be launched in THIS sandbox
1. **Fixture bytes:** request 03 names `infra/s2-fixture.sh` sha `6062f4ce43ecd10ce9407f295293ea2515e18cfd42fea1b9581250e87f9a6d61` (namespaced `S2_FIXTURE_NS`), which is not in the named packet (archive has `33452b03` / `08987e4c`, fixed `clusters/s2comp`). v5.3 refuses (70) without it. Options: parent supplies the exact bytes from another checkpoint, or authorises an explicit reimplementation (S2_FIXTURE_NS data dir; lockcheck/inherited-fd9 semantics of `08987e4c`) which then also needs review.
2. **Setup slot (heavy, separately named):** this sandbox has no psql, no `/home/user/pg17` PG 17.6 dist, no `node_modules`/A2 closure. The historical S10/S20/S30 setup scripts are in `checkpoint-1/infra/` (paths hard-coded to `worktrees/s2-composition`); they would need re-pointing to `worktrees/s2-runner53` and the install-stamp `lock=62b05b90…` written — a source-adjacent change that must itself be granted and hashed. No install was performed by this worker.
3. **Canonical lock file** `/home/user/workspace/execution/test-validation.lock` does not exist yet in this sandbox; `exec 9>` will create it on first use. `check-lock.sh` (`94ce982b…f544`, setup-and-runner-readiness/) is the read-only probe.
4. **Launcher:** `launch-detached.sh` (`64302b3e…a36d`) hard-codes `LANE=execution/s2-composition/runs`; a lane-local copy pointing to `execution/s2-runner53/runs` is needed (or parent accepts writes to the historical lane path). Not copied here to avoid an unreviewed byte change.

## C. Proposed B3 launch (only after A and B; supersedes 03A's launch line; bounds unchanged)
```
cd /home/user/workspace/execution/s2-runner53 && ./launch-detached.sh start composition-r3 \
  env -u S2_RUNNER_STUBS timeout --foreground -k 60 2100 bash /home/user/workspace/execution/s2-runner53/run-composition-r3-v5.3-when-granted.sh
```
- bound 2100 s + 60 s kill grace; runner cleanup worst case 48 s (margin 12 s); ≤2 CPU / <3 GB; sole heavy owner; loopback 54321 only; fresh `clusters/s2comp-r3` only; historical clusters untouched.
- prechecks at launch (reported, not assumed): lock FREE via check-lock.sh; no pg17 postgres; no 54321 listener; `clusters/s2comp-r3` absent; `/tmp` release scratch files absent; head d5cd9b8b clean; fixture sha = `6062f4ce…`; runner sha = `fbc8b9af…`.
- steps: guard spec → refusals 64/64 → fresh PG 17.6 fixture → real 164+1 composition (harness, 68 checks) → S1 56fb0d22 discriminator (S1 interprets) → cleanup (reap check → bounded stop → survivor/listener/lock proof).
- positive criteria: `exit-codes.txt` `final=0 first_exit=0 cleanup_exit=0 reap=ok fixture_stop=0 survivors=none`, harness `== 68 passed`, discriminator exit 0; lock FREE after exit.
- negative/abnormal criteria (all must be visible, never generic): any nonzero step → `first_exit=<code>`; signal → `interrupted(<sig>)`+143; failed reap → 72 + `QUARANTINE.txt`, fixture left running, parent inspects before any other slot; stop failure/survivor → 71.
- output: `execution/s2-runner53/composition-r3/<utc>/` (stamp.txt, exit-codes.txt, 10–51 logs, harness/, s1-r4/, SHA256SUMS); launcher sentinel `runs/composition-r3.{pid,log,exit,cmd}`.
- On first unexpected failure the runner stops after that step (cleanup always); builder preserves and diagnoses; no retry, no repair without authorisation.

## D. What this lane does NOT request
No product/harness/S1/S3 edit, no PR, no push, no DB run now, no install now, no canonical-lock acquisition now, no publication (parent-only).
