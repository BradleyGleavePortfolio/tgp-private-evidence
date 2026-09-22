# S4 R6 V5 — slot request (Stage 1 private controls, Stage 2 native validation)

Builder: OP88-S4-V5-PREP canonical fixer (sole writer `execution/op88/s4-v5`). Date 2026-09-22 (America/Los_Angeles).
Basis: frozen V4 packet (manifest `3c9276aa…`, 9/9 verified) + BOTH frozen V4 reviews (Audit A `AUDIT.json 76003cc7…`,
Audit B `REPORT.md d3c8beb9…` / `FINDINGS.json 3775989c…`). Contract: `execution/OP88_WAVE1.md` §OP88-S4-V5-PREP (lines 119-134,
file hash `f0d348dd…` at freeze; section text unchanged from the `8e4893f6…` copy read at start).

State of this packet, truthfully: **implemented (manual edits) · hashed · diffed · syntax-checked. NOTHING EXECUTED.** No control,
probe, lock acquisition, install, network, DB or browser action was taken. Success of Stage 1/2 later does not prove runtime control
pass, native gates, artifact/browser correctness, remote revocation, native completion or release.

## 1. Exact delta (V4 → V5), file by file

`V4_TO_V5.diff` is the byte-exact unified diff (renamed pairs `*-v4.*` → `*-v5.*`). Hashes in `SHA256SUMS`.

| V5 file | vs V4 | change class |
|---|---|---|
| `runner/chrome-pipe-discriminator-v5.mjs` | byte-identical `c261ffb4…` | rename only (PIN_PIPE_V5 unchanged bytes) |
| `runner/s4-r6-validate-v5.sh` | +14 −11 | path/name mapping (v4→v5, lib/pipe filenames, PIN_PIPE_V5), header truth. No step/pin/criterion/join change. |
| `runner/s4-r6-lib-v5.sh` | +26 −9 | **A-01** deferral through primary latch; **B-03/N01** truthful lock attribution; control-only seam |
| `launcher/s4-r6-launch-v5.sh` | +84 −35 | **A-02** wall-clock phases + bounded readers; **A-03/B-01** survivors before TIMEOUT/INTERRUPTED; **A-04/B-05** checked identity-safe quarantine handoff, `QUARANTINE_HOLDER_FAILED 10`; record fields |
| `controls/run-controls-v5.sh` | +118 −60 | **A-02** bounded cancel without KILL of the lease holder, `finish()` on all exits; **A-06/B-04** guarded raw exits/budget 600; manifest pin 91; new control; seam passthrough |
| `controls/control-predicates-v5.py` | +62 −16 | **A-05** fail-closed parsed-record/nonempty-steps; **U01** uutils exit set; new scenario; V5 formula |
| `controls/s4-r6-control-stub-v5.sh` | +14 −6 | new `live-step-double-term` case; path mapping |

Untouched: product head `91990ae9aec72f47a67591892ac09fa1f59d2f16` / tree `840fb285…`; all proposal-4 originals; both audit dirs.

## 2. Finding → change → concrete discriminator (also machine-readable in `FINDINGS_MAP.json`)

| ID | Finding (frozen) | V5 change | Discriminator (what would show V4 vs V5) |
|---|---|---|---|
| **A-01** | `step()` cleared `STEP_ACTIVE` right after reap; a signal in the metadata zone (before the primary latch) became `blocks[0]` and stole `first_failure` | lib: `STEP_ACTIVE` stays set through head-state, metadata and the primary `block`; `pending` read first; after latch `STEP_ACTIVE=""` then any late `PENDING_SIGNAL` → secondary `SIGNAL_<sig>` "while latching" block | New control **`live-step-double-term`**: control-only seam (`S4R6_SEAM=step-after-reap`, KIND=CONTROL only) self-TERMs inside that zone. Predicates: `blocks[0]` startswith `C-live-step`, all later blocks `SIGNAL_TERM`, ≥2 `SIGNAL_TERM`, one "while latching", step log contains `SEAM step-after-reap`. Under V4 ordering `blocks[0]` would be `SIGNAL_TERM`. |
| **A-02** | Launcher phases counted loop iterations (each iteration = `pgrep`/`kill -0` + `sleep 1`, unbounded drift); record readers unbounded; driver cancel path exited 96 before session/lease scan | launcher: `wait_session_empty`/`wait_pid_gone` wall-clock deadlines; both readers `timeout --foreground READ_S=5`; `bounds.read_s`, `quarantine_verify_s`, `phases_are_wall_clock:true`, formula `outer+grace+confirm+post_exit_reap+publish+2*read+quarantine_verify+2`. driver: `run_bounded` wall-clock + aggregate guard; `finish()` on EVERY exit does cancel → owned-session scan/reap → lease probe → code | Common predicate `bounds.phases_are_wall_clock == true` and V5 formula string; driver log line `EXIT code=… leftovers_initial=… leftovers_final=… private_lease_free=…` on every exit incl. 92/93/96/97/143/130 |
| **A-03 / B-01** | `TIMED_OUT`/`INTERRUPT` classification preceded the survivors check → TIMEOUT exit 124 released the lease with unverified survivors | launcher §5: `if [[ -n $SURVIVORS ]]; then quarantine_exit; fi` BEFORE TIMEOUT/INTERRUPTED; cause stays in `bounds.timed_out`/`bounds.interrupt`/`owned_session.signalled`. Same on the INTERRUPT trap path. | A TIMEOUT run with survivors now exits **5** (or **10**) never 124; `lease.released_at_launcher_exit=false` with recorded holder. Reviewer decision point: TIMEOUT-with-survivors exit changes 124→5. |
| **A-04 / B-05** | Quarantine holder `setsid sleep infinity` unverified (no check it lived, held fd 9, or was recorded before exit); bare-PID recovery | `hold_quarantine_lease`: holder `setsid bash -c 'while :; do sleep 60 9>&-; done' <token>`; verified alive + `readlink /proc/<pid>/fd/9 == LEASE_PATH` + token in cmdline within `QH_VERIFY_S=5`; `QUARANTINE_LEASE_HOLDER` written tmp+mv BEFORE exit with pid+starttime+token+lease+recovery rule; on any failure the just-spawned holder is KILLed identity-checked (token) and the launcher publishes `QUARANTINE_HOLDER_FAILED` **10** with `lease.quarantine_ok=false`, `quarantine_failure=<reason>`, `released_at_launcher_exit=true` labelled UNSAFE RELEASE (never SUCCESS). `sleep` children close fd 9 so only the recorded pid holds the lease. | Record `lease.quarantine_holder_starttime/_token/quarantine_ok`; file `QUARANTINE_LEASE_HOLDER` has `starttime=` and `token=`; driver treats a recorded holder as STOP 94 (never kills it). Recovery snippet §6 kills only on triple identity match. |
| **A-05** | Predicates skipped record/step assertions when record unparsed or `steps` empty (`if rec.get("steps")`) → vacuous PASS | `parsed()` + mandatory `steps_ok()` (MISS, never skip) in nested-orphan, live-step-*, predicate-rc0, lease-held-by-supervisor; record-without-sentinel requires a parsed SUCCESS record + steps; refuse requires NO record; common: `lease.quarantine_ok is None`, `holder_pid` int | A run whose stub wrote an unparsable/empty record now prints `MISS record.steps is a parsed list of >= 1 step object(s) (mandatory)` and rc 1 |
| **A-06 / B-04** | Caller `bash -c '…; exit $?'` under `set -e`-like shape could turn a driver nonzero into an unguarded raw exit / masked code; aggregate 340 s unrealistic | Stage-1 command (§4) guards: `if bash driver; then rc=0; else rc=$?; fi; printf; exit "$rc"`; driver budget 600 s with itemised worst 597; no `--kill-after` wrapper (KILL of the driver would abandon its owned launcher) | Caller prints `driver exit=<n>`; driver prints the itemised budget on start and `EXIT code=` on finish |
| **B-03 / A-N01** | `EXIT_RECORD.lock` claimed `holder: runner` / runner pid though the launcher holds fd 9; "private-only names" | lib `publish_exit_record` argv 24→27 (`S4R6_LEASE_PATH`, `S4R6_LEASE`, `S4R6_LEASE_PID`); `lock = {path, kind, holder:"launcher", holder_pid:<launcher>, runner_sid, mode:"inherited fd 9 verified by runner; lease held by launcher for the run's lifetime"}` | Predicate (lease-held-by-supervisor): `record.lock.holder == "launcher"` and `record.lock.holder_pid == SUPERVISOR_RECORD.lease.holder_pid`, `record.lock.path == lease.path` |
| **B-02 / B-06** (B: optional labels) | Cancel-route/aggregate realism labels; direct-refusal control budget | driver: `CLEANUP_RESERVE_S=70` itemised; `UNRESOLVED` (exit 97) written with pid+starttime to `DRIVER-UNRESOLVED-*.txt` instead of KILLing the lease holder; direct-refusal control 7 s | driver log/receipt files |
| **U01** (builder, new) | V4 predicates accepted `{124,137,143}` for a TERM-killed step; the INSTALLED `timeout` is rust-coreutils 0.8.0 (`/usr/bin/timeout → /usr/lib/cargo/bin/coreutils/timeout`), which returns the raw child signal (15) — a V4 Stage 1 would have failed control 2 on a GNU inference | `SIGNAL_EXITS=[15,124,137,143]` for `runner.exit`, `first_failure.observed_exit`, `steps[0].exit`; predicate label says "installed uutils => 15 expected"; actual value printed | Predicate output line shows the observed integer; the run stamps it in `EXIT_RECORD.steps[0].exit`. Untested here: no execution. |

Preserved positive closures (unchanged bytes or semantics): V2/V3/V4 initialisation order, own-session spawn via `setsid`, JSON via
quoted heredocs only (0 unquoted, checked), exit-split (`expect_exit` validation vs observed), prerequisite refusals (71/73/75/6/7/9),
artifact joins/pins in the runner (only names/paths mapped), non-job-control parent check, lease held by launcher before spawn.

## 3. Fresh path mapping (explicit; all currently ABSENT in this workspace — nothing created)

| purpose | path | present now |
|---|---|---|
| restored V5 packet root (the driver `cd`s here and runs `sha256sum -c --quiet SHA256SUMS`) | `/home/user/workspace/execution/s4-r6-validation/v5/` ← copy of `execution/op88/s4-v5/` (all files, same relative layout) | no |
| Stage-1 private receipts / private lease | `…/s4-r6-validation/v5/control-runs/` (created by driver) · `…/v5/control-runs/.private-control-lease.lock` | no |
| Stage-2 run dirs | `/home/user/workspace/execution/s4-r6-validation/runs/` | no |
| Stage-2 worktree | `/home/user/workspace/worktrees/s4-r6` at head `91990ae9aec72f47a67591892ac09fa1f59d2f16` | no |
| Stage-2 predecessor/probes | `execution/s4-r6/predecessor-88287cff`, `execution/s4-r6/probes` | no |
| Stage-2 tooling | `execution/s4-r6-validation/tooling` | no |
| canonical lock (Stage 2 only; launcher holds it via fd 9) | `/home/user/workspace/execution/test-validation.lock` | no |

Restoration is a copy, not an edit: after copying, `cd …/v5 && sha256sum -c SHA256SUMS` must report every listed file OK (the driver
refuses with 91 otherwise). Environment assumed (listed, not probed): bash 5.3.9, rust-coreutils 0.8.0 (`sleep`, `timeout`,
`sha256sum`, `date`, `head`, `od`, `tr`, `readlink`, `tee`, `wc`, `cut`), util-linux 2.41.3 (`flock`, `setsid`), procps 4.0.4
(`pgrep`, `ps`), python 3.14.3, mawk.

## 4. Stage 1 — private controls request (independently executable after grant)

Prerequisites: (a) two independent risk-scoped exact-V5 reviews on THESE bytes (`SHA256SUMS`); (b) packet restored per §3 and
manifest verified; (c) no `worktrees/s4-r6`, canonical lock or product access needed — Stage 1 touches only `…/v5/control-runs`.

Command (guarded raw exit, A-06/B-04; run from a NON-job-control parent, i.e. plain `bash -c`, not an interactive shell):

```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v5 || exit 70; if bash controls/run-controls-v5.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
```

No `timeout --kill-after` wrapper (a KILL of the driver would abandon its owned launcher/session). If an outer wrapper is
mandated: `timeout --foreground 660 bash controls/run-controls-v5.sh` (TERM only; the driver's TERM trap runs `finish 143`).

Bounds (wall-clock, itemised in the driver header): hard budget **600 s**; per-control worst = outer + grace + 60 (launcher post
40 + predicates 10 + scan 5 + lease 5); worst 88+70+70+73+73+73+73 (seven launcher controls) + 7 (direct refusal) + 70 (reserve) =
**597 s**; typical ≈ 60–90 s (the nested-orphan stub exits early; the two live-step controls each hit a 4 s outer deadline).

Controls in driver order (`CONTROLS=` rows: name|outer|grace|per-control worst|seam): `nested-orphan-after-exit|25|3|88|` ·
`live-step-interrupt|4|6|70|` · **`live-step-double-term|4|6|70|step-after-reap`** (identical shape to live-step-interrupt — 60 s step
around `sleep 300`, 4 s launcher deadline — plus the lib seam) · `predicate-rc0|10|3|73|` · `record-without-sentinel|10|3|73|` ·
`lease-held-by-supervisor|10|3|73|` · `refuse|10|3|73|` · then direct-refusal (real runner invoked without launcher → 71, no run dir).

Driver exit codes: 0 all controls passed · 70 mkdir/cd failed · 91 V5 manifest mismatch (nothing executed) · 92 budget admission
refused · 93 run-dir anomaly · 94 first unexpected result (predicate MISS, leftovers as left by launcher, lease not released, OR a
recorded quarantine holder — never killed by the driver) · 95 private lease pre-held · 96 cancelled, launcher exited, session clean ·
**97 cancelled-unresolved**: launcher still alive after its own worst case, left holding the lease, identity (pid+starttime) in
`control-runs/DRIVER-UNRESOLVED-*.txt` · **98 unsafe release observed** (leftovers after reap while lease free) · 143/130 driver signalled
(after `finish`). Receipts: `control-runs/<RUN_ID>/{SUPERVISOR_RECORD.json,EXIT_RECORD.json,PREDICATES.txt,console.log,steps/…}`,
`control-runs/DRIVER-*.log`.

Pass = driver 0 AND every `PREDICATES.txt` shows no `MISS` AND `EXIT code=0 … leftovers_initial='' private_lease_free=true quarantine_holder=''`.
Anything else: STOP, preserve `control-runs`, report; do not re-run without a new grant.

## 5. Stage 2 — native validation request (NOT executable until all prerequisites hold)

Prerequisites: Stage 1 passed once under its own grant on these exact bytes; both independent V5 reviews on record; §3 paths
present (`worktrees/s4-r6` at `91990ae9…`, predecessor/probes/tooling, canonical lock path creatable); operator grant for the canonical
lock `execution/test-validation.lock` (held by the launcher via fd 9 for the whole run).

```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v5 || exit 70; if bash launcher/s4-r6-launch-v5.sh; then rc=0; else rc=$?; fi; printf "launcher exit=%s\n" "$rc"; exit "$rc"'
```

Bounds: OUTER 3300 + GRACE 45 + CONFIRM 10 + POST 8 + PUBLISH 5 + 2×READ 10 + QH_VERIFY 5 + 2 = **3385 s** worst (recorded as
`bounds.worst_case_s`). Launcher exits: 0 SUCCESS · 124 TIMEOUT (session verified empty) · 143 INTERRUPTED (verified empty) ·
**5 QUARANTINED_SURVIVORS** (verified+recorded holder keeps the lock; see §6) · **10 QUARANTINE_HOLDER_FAILED** (unsafe release
recorded; treat the lock path as suspect until the listed survivors are verified gone) · 6 lease busy · 7 job-control parent ·
9 runner sha mismatch · 75 prerequisites · 71/73 runner refusals · else the runner's own exit (record in `runs/<RUN_ID>/EXIT_RECORD.json`).

## 6. Recovery rule for a quarantine holder (identity-checked; NOT executed here; only after survivors are verified gone)

```
f=<run_dir>/QUARANTINE_LEASE_HOLDER
pid=$(sed -n 's/^pid=\([0-9]*\) .*/\1/p' "$f"); st=$(sed -n 's/.* starttime=\([0-9]*\) .*/\1/p' "$f")
tok=$(sed -n 's/.* token=\([^ ]*\) .*/\1/p' "$f"); lease=$(sed -n 's/.* lease=\([^ ]*\) .*/\1/p' "$f")
[[ $(sed 's/^.*) //' /proc/$pid/stat | awk '{print $20}') == "$st" ]] \
 && tr '\0' ' ' < /proc/$pid/cmdline | grep -q -- "$tok" \
 && [[ $(readlink /proc/$pid/fd/9) == "$lease" ]] \
 && kill -TERM "$pid"      # all three must match; otherwise do NOT signal — report instead
```

## 7. Reviewer decision points (flagged, not hidden)

1. Control-only seam in the shared lib (`KIND==CONTROL && S4R6_SEAM==step-after-reap`): inert for VALIDATION; reviewers may prefer it
   in the stub, but only the lib can fire inside the metadata zone.
2. Survivors-first precedence changes TIMEOUT-with-survivors from 124 to 5/10 (cause preserved in record).
3. Driver budget 340→600 s; new exit codes 10 (launcher), 91/97/98 (driver).
4. Predicate counts for SIGNAL_TERM blocks are lower bounds (≥1 / ≥2) because the launcher's TERM route (group pass then per-pid pass)
   can legitimately deliver a second TERM into the metadata zone; the ordering predicates (`blocks[0]` = step) carry the A-01 discrimination.
5. Driver-side bounded TERM/KILL reap of an owned session whose launcher has ALREADY exited (leftovers are still judged from the
   pre-reap list → 94; unreaped leftovers with a free lease → 98). The driver never signals a live launcher beyond one TERM.

## 8. Smallest next action

Dispatch the two independent risk-scoped exact-V5 reviews against `SHA256SUMS` of this packet; on both clean, grant Stage 1 (§4) separately.
