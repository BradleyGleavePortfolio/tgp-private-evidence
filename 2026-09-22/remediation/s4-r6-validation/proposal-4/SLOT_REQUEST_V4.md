# S4 R6 — native validation V4 (execution-only successor of V3; prepared, NOT executed; no grant assumed)

Slice **S4-R6-VALIDATION-V4-PREP**. Product head unchanged and frozen: `91990ae9aec72f47a67591892ac09fa1f59d2f16`
(tree `840fb2855953d5363fbd144e11b3f81763d9cef7`); historical hooks **0/6**; narrow dual source acceptance
unchanged. No product/source edit. V1/V2/V3 and all audit packets immutable; V4 writes only
`execution/s4-r6-validation/v4/`. Inputs read in full: frozen V3 reviews A and B, the V4-PREP register entry.
Parent disposition followed: A's four concrete closures; A-02 resolved by **active-step ordering**, not by relabelling
the control predicate (B's V3B-01 alternative not adopted).

Only `bash -n`, `node --check`, `py_compile`, a static undefined-name walk over every embedded Python block
(0 unquoted heredocs, 0 undefined names), an argv-count check of both record writers (39/39, 24/24) and a
same-line-dependent-`local` scan (0 real hits) were run. No launcher, control, runner, probe, timeout target,
install, test, browser, lock or network action. `runs/`, `tooling/`, `v4/control-runs/` do not exist.

## V4 packet (hashes in `v4/SHA256SUMS`, non-self-including)

| file | sha256 |
|---|---|
| `launcher/s4-r6-launch-v4.sh` — supervisor **and lease holder** | `23ebfbc33899e6ee7a68227771a53f4c1cc7a94bc32fb5e495243bbe3a787e73` |
| `runner/s4-r6-validate-v4.sh` — verifies inherited lease, no self-lock | `86a4f6cca90aafdcdc8d6fbc71e6ed46e7eeaf51b3e80e15cca5f754f21d1b81` |
| `runner/s4-r6-lib-v4.sh` — shared wrapper/census/reap/signals/latch/record | `abfdd0bde019364b303e312dde907222886162e8d497b6bfaea2b2351a9684e7` |
| `runner/chrome-pipe-discriminator-v4.mjs` — byte-identical to V3/V2 | `c261ffb408dc5a724a17c5ad0889b500918fde5d1aa29420b39ced4c4d04531b` |
| `controls/s4-r6-control-stub-v4.sh` | `fc47b0d42bdd43fe7514782f9e2e1314cb99dffbbd9712a1dabe9bbe6d9c9a57` |
| `controls/control-predicates-v4.py` | `662e222c6593782f5e4df31ed2a92719281718f8bec095487a19610e3777e545` |
| `controls/run-controls-v4.sh` — hard-deadline driver with cancellation | `2b235725e08e211227b2836ebb2ddcc47f2923d916e3a7f461c1e034f27d4bb2` |
| `V3_TO_V4.diff` — exact `diff -u` V3→V4 (lib 33, runner 48, launcher 56, stub 36, predicates 30, driver 110 changed lines) | `f8dca6189ce2eec7e5fa8541decafb9ca89fcec2c2cb3966480e9b0b4a966bdb` |

## Finding → change map (S4-V3-A-0n)

| finding | V4 closure | where |
|---|---|---|
| **A-01** `local label=$1 f=…$label…` expands the unset local in one command → `set -u` abort at the first reap | Two commands: `local label=$1` then `local f=$OUT/steps/reap-$label.txt i`. Static scan of every `local` line in V4: no other same-line dependent declaration. Control expectations unchanged (control 1 still requires `owned_orphans_found=1`, reaped, verified). | lib `reap_owned` |
| **A-02** pending TERM trap runs before the step's latch → `SIGNAL_TERM` became primary | `step` sets `STEP_ACTIVE` before the command and clears it only after its own reap. `on_signal` (now shared in lib, installed by `install_signal_traps`) does **one assignment** (`PENDING_SIGNAL`) while a step is active — no latch, no re-entrant cleanup; bash restores `$?` after the handler, so `step` captures the actual command exit, latches it as **primary**, then records `SIGNAL_<sig>` as the **secondary** block and `signal_during_step` in the step JSON. With no active step the signal is itself the primary failure and cleanup runs immediately (separately truthful). Control 2 keeps `first_failure.step=C-live-step` and now also requires `blocks[0]` = step, `blocks[1]` = `SIGNAL_TERM`, `signal_during_step=TERM`. | lib `on_signal`, `install_signal_traps`, `step`; runner/stub call `install_signal_traps` |
| **A-03** 185 s was an admission estimate; no cancellation through the active launcher; +7 understated | Driver runs each launcher in the background under `run_bounded <outer+grace+25>`: on expiry it **cancels** the active launcher with TERM (the launcher's INTERRUPT route tears down its owned session, reaps, publishes), waits within the cleanup reserve, KILLs if needed, and stops (`exit 96`). Predicates bounded (`timeout --foreground 10`), scan 2 s. Admission before every control: `worst + CLEANUP_RESERVE_S(15) ≤ remaining`. `TOTAL_BUDGET_S=340` is the hard aggregate: 65+47+50+50+50+50 + 5 + 15 = 332. Launcher post-deadline phases are constants (grace, confirm 10, post-exit reap 8, publish 5 under `timeout --foreground`) and the record's `bounds.worst_case_s = outer+grace+confirm+post_exit_reap+publish+2` with the formula string; the request below uses the same formula. Driver TERM/INT traps forward cancellation to the active launcher. | `controls/run-controls-v4.sh`; launcher `POST_S/PUBLISH_S`, record |
| **A-04** canonical lock held only by the killable runner; released on KILL while cleanup pending; survivors merely reported | The **launcher** takes `flock -n` on the lease before spawning (VALIDATION: canonical `execution/test-validation.lock`; CONTROL: **private** `v4/control-runs/.private-control-lease.lock`, requested explicitly below, never canonical) and holds fd 9 through verified cleanup; refusal `LEASE_BUSY` (75) with record if busy, nothing spawned. The runner no longer locks: it **verifies** the inherited lease (`S4R6_LEASE` flag, holder pid == `$PPID` and alive, `/proc/$$/fd/9` → lease path) and refuses 75 otherwise; step children still close fd 9. On unverified survivors (`QUARANTINED_SURVIVORS`, either path) the lease is **not released**: a detached `sleep infinity` inheriting fd 9 keeps it, its pid is written to `QUARANTINE_LEASE_HOLDER` and the record (`lease.released_at_launcher_exit=false`, `quarantine_holder_pid`) — unsafe handoff, never SUCCESS, never permission for another lane; the parent must resolve survivors, then kill that pid explicitly. | launcher §1b, `hold_quarantine_lease`, record `lease`; runner lease block; stub lease block |
| positive closures preserved | Session boundary census/signalling, JSON argv writers, fast-exit identity by construction + handshake, expected-negative observed-vs-validation split, VPA-04 joins, VPA-05 latch, S00 pins — unchanged (see diff). | — |

Non-material, recorded not fixed: B N-2 (refusal classified by exit code alone), N-3 (job-control shell makes the launcher a
group leader → refusal 73 by design; grant text below states a non-job-control parent), N-4 (control outputs are created
under `v4/control-runs/`, accepted and recorded), N-5/N-6, A's pre-spawn refusal without record (no workload exists then).

## Explicit request: private control lease

Controls need a real `flock` to prove "lease held outside the workload" (control 5 probes it from outside with
`flock -n … true` and expects refusal). They use **only** `v4/control-runs/.private-control-lease.lock`, created by the
launcher in CONTROL kind; the canonical lock is never opened by any control path (stub refuses if the lease path is not
the private one). The driver checks the private lease is free before starting and released after every control.

## Exact commands, outputs, budgets, recovery

**Stage 1 — safety controls (separate grant; precede any validation slot):**
```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v4 && bash controls/run-controls-v4.sh; echo "driver exit=$?"'
```
Non-job-control parent required (as above); do not wrap in a non-foreground `timeout` (if a wrapper is wanted:
`timeout --foreground --kill-after=20 360 bash -c '…'`). Hard budget 340 s worst case incl. cancellation reserve; typical ≈ 45 s.
Outputs: `v4/control-runs/DRIVER-<utc>-<pid>.log`, one `v4/control-runs/CONTROL-V4-<utc>-<pid>-<rand>/` per control
(`console.log`, `LAUNCH_TOKEN`, `OWNED_SID`, `RUNNER_PID`, `steps/*.json|*.log`, `reaps.log`, `blocks.log`,
`predicates.log`, `EXIT_RECORD.json`, `RUN_COMPLETE.sentinel` where expected, `SUPERVISOR_RECORD.json`, `PREDICATES.txt`,
`QUARANTINE_LEASE_HOLDER` only on quarantine), `v4/control-runs/DIRECT-REFUSAL-<utc>.txt`, `.private-control-lease.lock`.
Driver exits: 0 all seven matched · 92 budget stop · 93 output-dir anomaly · 94 first mismatch/leftover/lease-not-released ·
95 private lease already held · 96 cancelled by hard deadline · 143/130 interrupted (active launcher cancelled first).

| # | scenario (actual launcher → stub → lib `step`) | outer/grace | required record facts (`control-predicates-v4.py`; all also require parsed supervisor record, `survivors_after_kill=[]`, private lease kind/path, `held_by_launcher=true`, `released_at_launcher_exit=true`, no quarantine holder, `worst_case_formula`) |
|---|---|---|---|
| 1 | `nested-orphan-after-exit` | 25/3 | `SUCCESS`/0; `steps[0].owned_orphans_found=1`, `orphans_reaped_verified=true`; `reaps.log` found=1 + verified empty; `reaped_by_supervisor=[]`; handshake; sentinel |
| 2 | `live-step-interrupt` | 4/6 | `TIMEOUT`/124; `timed_out`; `signalled∈{TERM,TERM+KILL}`; `members_at_deadline`≥2; runner exit confirmed ∈{124,137,143}; record present, `result=FAILED`, `first_failure.step=C-live-step`, `blocks[0]`=C-live-step, `blocks[1]`=SIGNAL_TERM, `steps[0].signal_during_step=TERM` |
| 3 | `predicate-rc0` | 10/3 | `RUNNER_NONZERO`/89; `first_failure.validation_exit=89`, `observed_exit=0`, `steps[0].status=EXIT_0` |
| 4 | `record-without-sentinel` | 10/3 | `FAILED_PUBLICATION`/7; `runner.exit=0`, `exit_record_result=SUCCESS`, `sentinel=false`, handshake |
| 5 | `lease-held-by-supervisor` | 10/3 | `SUCCESS`/0; `steps[0]=C-lease-outside-probe` `status=EXIT_3` (outside `flock -n` refused while workload active); `PREDICATE_OK … observed=3 wanted=3`; no first failure |
| 6 | `refuse` | 10/3 | `RUNNER_REFUSED`/71; exit confirmed; handshake null; refusal recorded; no orphans |
| 7 | direct real-runner invocation | 5 s | exit 71, exact message, `runs/` unchanged |

Recovery: any miss stops the driver (no retry, no re-run of the same bytes); a cancellation or quarantine leaves receipts
and, on quarantine, the private lease held by the recorded holder pid until the parent kills it. Nothing in Stage 1
touches the canonical lock, worktree, network or installs.

**Stage 2 — validation (later, separate grant, heavy slot free):**
```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v4 && bash launcher/s4-r6-launch-v4.sh; echo "launcher exit=$?"'
```
Canonical lease taken by the launcher before spawn (busy → `LEASE_BUSY` 75, nothing spawned; a free lease is not permission).
Bound: `bounds.worst_case_s` = 3300 + 45 + 10 + 8 + 5 + 2 = **3370 s** (typical ≈ 15 min); if a wrapper is wanted,
`timeout --foreground --kill-after=60 3400`. Outputs under `execution/s4-r6-validation/runs/VALIDATION-V4-…/` as in V3 plus
`QUARANTINE_LEASE_HOLDER` on quarantine. Launcher exits: 0 SUCCESS · 124 TIMEOUT · 143 INTERRUPTED · 5 QUARANTINED
(lease retained by holder pid) · 6 runner left orphans · 7 FAILED_PUBLICATION · 9 handshake · 75 LEASE_BUSY or runner
lease/lock refusal · 71/73 refusals · otherwise the runner's validation exit. Steps, pins and criteria unchanged from V2/V3.

## Control / native applicability

Controls prove: shared wrapper reaps nested-`timeout` orphans; active-step primary/secondary attribution under
session-wide TERM; observed-vs-validation exit split; parsed-record-without-sentinel gate; lease exclusion held by the
supervisor (private lease) while the workload runs; fast refusal identity; hard aggregate cancellation route (only if a
bound trips). They do **not** prove canonical-lock occupancy semantics beyond the identical code path, nor gates, Vitest,
gitleaks, package, browser, artifact or release facts. Stage 2 `SUCCESS` is builder evidence only; two independent final
evidence attestations remain required; hooks stay 0/6.

## Exact next request
1. Independent exact-successor review of the V4 files (diff `V3_TO_V4.diff`).
2. Stage 1 grant incl. the private control lease (≤340 s hard budget, no canonical lock/network/worktree).
3. Stage 2 when the heavy slot is free.

Nothing executed; no grant assumed; V4 frozen at the hashes above (any byte change = V5 + new request).
