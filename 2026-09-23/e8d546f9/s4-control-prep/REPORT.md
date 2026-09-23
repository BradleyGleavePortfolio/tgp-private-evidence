# S4 V6.1 — source restoration and Stage 1 control readiness (S4-V61-BUILD, same T4 slice)

Sole writes: this directory plus the one permitted mechanical restoration below. Builder identity: requested policy Claude Fable 5 / High; observable runtime model/settings not exposed, not asserted. Current auditor B output NOT read. Frozen V6.1 packet `execution/e8d546f9/s4-v61` untouched (manifest `671d08c3633378ef392a4aee6bbb70b78319994727d74e439b75830a6d63d8ee`).

## 1. Restoration (done, mechanical, verified) — `logs/R1-restore-and-verify.txt`

* Target `/home/user/workspace/execution/s4-r6-validation/v6` was **absent** at 01:04Z (`ls` failed on both the parent dir and the target); no existing content was overwritten or preserved because none existed.
* Copied the **whole** frozen packet directory with `cp -a` (12 manifest files + `SHA256SUMS` + `FREEZE.json`, which sits outside the manifest and is inert at runtime).
* At the target: `sha256sum -c SHA256SUMS` **12/12 OK**; target manifest sha256 `671d08c3…` == frozen; `diff -r` source↔target **identical**; every source-file hash listed in R1 (launcher `85e1bafd…`, driver `817a0dc8…`, predicates `a74cc2a4…`, stub `6ddf0353…`, lib `64db67a6…`, runner `94edb27d…`, pipe `c261ffb4…`).
* Frozen V6 predecessor re-verified untouched (`8b04adaf…`, 12/12). `…/v6/control-runs/` and `…/s4-r6-validation/runs/` do not exist (the driver `mkdir -p`s `control-runs`; `runs` is Stage 2 only and is read with `2>/dev/null` by the direct-refusal control, so its absence is fine).
* Not restored / not needed for Stage 1: `worktrees/s4-r6`, `execution/s4-r6/{predecessor,probes}`, `execution/s4-r6-validation/tooling` (all absent; Stage 2 only).
* Observed, not touched: `/home/user/workspace/execution/test-validation.lock` exists (0 bytes, 00:57Z, another lane). Stage 1 never opens it; the driver's only lock is `…/v6/control-runs/.private-control-lease.lock`.

## 2. Exact one-run command (unchanged accepted caller, request §4)

```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash controls/run-controls-v6.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
```

Run once, as the **sole** command of one `bash` tool call, from the packet-owning worker after the parent's explicit activation. No wrapper, no `setsid`/`nohup`, no `--kill-after`, no redirection added, no environment variables added (`S4R6_*` are set by the driver per control). Pass = raw tool exit **0** AND `driver exit=0` line AND every `control-runs/CONTROL-V6-*/PREDICATES.txt` free of `MISS` AND `control-runs/DRIVER-TERMINAL-*.txt` containing `EXIT code=0 … identity=BOUND leftovers_first='' (state=EMPTY) … private_lease_free=true live_quarantine_holder=''`. Anything else: STOP, preserve `control-runs`, no re-run without a new grant.

## 3. Tool execution approach — what the current shell tool does (observed and read, not assumed)

Evidence: `logs/T1-tool-semantics-sleep-only.log` (+ `.log.exit`), `logs/T2-supervisor-strings.txt`, and the supervisor argv read from `/proc/<ppid>/cmdline` during this session.

| fact | source | consequence for the Stage 1 caller |
|---|---|---|
| Every `bash` tool call runs as `asi-supervise-v2 --timeout 900 --capture-output <stdout.log> <stderr.log> 50000 32000 50 <cmd>`, executing `/bin/bash -lc "export …; <cmd>"` | `/proc/<ppid>/cmdline`; binary strings `/bin/bash`, `-lc` | The tool shell is a **non-interactive, non-job-control** bash (`[[ -o monitor ]]` off, no `i` in `$-`) — the request's "non-job-control parent" condition holds as-is. |
| The tool shell is made a **session and process-group leader** (`pid == pgid == sid`) | T1 line 1 (`pid=11261 pgid=11261 sid=11261`); binary strings `setsid`, `setpgid` | The caller `bash -c` is a child of that leader (the command string has more than one statement, so no exec-in-place), the driver a grandchild, the launcher a background child of the driver in the **same** process group (no job control) ⇒ launcher `pgid == tool-shell pid != launcher pid` ⇒ the launcher's topology refusal (73) is **not** triggered. Runner and standby holder use `setsid` and leave the group, as designed. |
| `yield_time_ms` (≤ 30 s) is **not** a cut-off: a 40 s command run with `yield_time_ms=30000` returned after completion with its full output and its true exit code (3) | T1 (`start 01:04:53`, `after 40s 01:05:33`), `.exit` = `3` | The tool preserves the actual long-running caller exit **as-is**; no harness or detachment is needed for runs shorter than the supervisor timeout. One data point (40 s); longer durations are inferred from the supervisor's own `--timeout 900`, not measured. |
| Hard ceiling **900 s** per tool call, fixed by the platform (not overridable from the command); on expiry the supervisor **terminates the command group** (TERM), then **kills the command group** (KILL), then checks for leftovers | argv `--timeout 900`; strings `terminate command group`, `kill command group`, `kill leftover command group`, `process group survived SIGKILL` | **The declared Stage 1 hard budget (1500 s, worst 1445 s) exceeds the tool ceiling.** Typical run ≈ 2–3 min, so a run that reaches 900 s has already absorbed several full worst-case phases and is itself a STOP condition. If it happens: the group TERM reaches caller, driver and launcher at once — the driver's trap runs `finish 143 driver-TERM` (once-budgeted cancel), the launcher takes its INTERRUPT teardown — but the supervisor's subsequent KILL (grace not documented) can cut the driver/launcher mid-teardown. The runner session and the standby holder are outside the group: the runner ends under its own bounds; the **standby holder keeps the private lease** with identity in `console.log` (`standby holder verified pid=… starttime=… token=…`) and via `pgrep -af s4r6-quarantine-holder-<RUN_ID>`; recovery per request §6 on the private lease only; the next driver run refuses 95 until then. Consequence bounded to `control-runs`; nothing canonical. |
| Captured stdout/stderr go to `current_session_context/tool_calls/bash/stdout_<id>.log` / `stderr_<id>.log` plus `stdout_<id>.log.exit` (exit code); tool return preview is truncated at 50 000 bytes | argv; T1 `.exit` file | The tool return alone is not the evidence of record. After the run, copy the `driver exit=` line, the full stdout/stderr logs and `.exit` file into the result directory; the authoritative facts remain `control-runs/DRIVER-<utc>-<pid>.log`, `DRIVER-TERMINAL-*.txt`, every `CONTROL-V6-*/PREDICATES.txt`, `SUPERVISOR_RECORD.json`, and any `DRIVER-UNRESOLVED-*` / `QUARANTINE_LEASE_HOLDER`. The `tool_calls/bash` directory is shared across lanes; identify the file by the `V6 controls start` first line, not by name. |

**Conclusion (updated 01:12Z after the parent allowed transport-only redirection/detachment/receipt):** the exact transport is specified in `TRANSPORT.md` — `setsid -f` wrapper, stdin `/dev/null`, stdout/stderr to `s4-stage1-result/stage1.log`, raw exit to `stage1.exit` (tmp+mv), inner caller executed byte-identical from `stage1-caller.cmd` (sha256 `680a0161…`, `diff`-identical to §4). Rationale below is retained as the measured basis. The current tool supports the accepted caller as-is (blocking to completion, true exit preserved, non-job-control, topology compatible). **No new harness and no caller change are proposed.** One disclosed limit remains: the tool's fixed 900 s ceiling is below the declared 1500 s budget. Options are the parent's: (a) accept 900 s as an external, attributable infrastructure bound (recommended: a run that is still going at 900 s is not a pass under any outcome, and the consequence is confined to the private lease with a recorded, identity-checked holder); or (b) if the full 1500 s must be honoured by the caller's observer, that requires a detached launch with its own log/exit capture — i.e. exactly the harness this brief forbids; not built, not recommended for a run whose expected duration is 2–3 min.

## 4. Readiness checklist (for the parent's activation decision)

| item | state |
|---|---|
| Frozen V6.1 bytes at the runtime path, 12/12, source hashes match | **yes** (R1) |
| Both independent exact-delta attestations of `671d08c3…` | A frozen per parent mail; **B outstanding** (not read) — parent gate |
| Heavy slot | S2 setup is the current owner — parent gate; Stage 1 needs no canonical lock, no install, no network, ~2 CPUs for `sleep`/`pgrep`/`python3` workloads only |
| Private lease `…/v6/control-runs/.private-control-lease.lock` | does not exist yet; the driver's pre-start `flock -n` probe creates/checks it (95 if held) |
| Environment (version flags only, nothing probed): bash 5.3.9; uutils `timeout` 0.8.0; util-linux `flock` 2.41.3, `setsid`; procps `pgrep` 4.0.4; python 3.14.3; `mawk` | matches the packet's listed assumptions (`INPUTS.json`); `pgrep` rc-1-on-no-match and uutils raw-15 remain **unmeasured** until Stage 1 |
| Host | 2 CPUs, 7966 MB, `pid_max=32768` (the B-01 correction is relevant on this host: pid reuse under forking is plausible at this `pid_max`) |
| Tool path for the run | `bash` tool, single call, exact §2 command, `yield_time_ms=30000`, `max_output_tokens=12000`; 900 s ceiling disclosed above |

## 5. What was and was not executed here

Executed: `cp -a`, `sha256sum`, `diff -r`, `ls`, version flags, reading `/proc/<ppid>/cmdline` and binary strings of the tool supervisor, and **one tool-semantics check consisting solely of `echo`/`ps`/`sleep 40`/`exit 3`** (T1) — no packet file, no lock, no `flock`, no `pgrep -s`, no launcher/driver/stub/runner/predicate invocation, no control, no install, no network, no product path. Nothing in `…/v6` has been run; `control-runs` does not exist. If the parent regards the `sleep`-only check as outside "no process", it is disclosed here and its full output is in `logs/T1-*`.

## 6. Smallest next action

Both V6.1 reviews are frozen clear (A `32c35647…`, B `94c5921e…` per parent mail) and the S2 setup slot has completed. On the parent's explicit activate message (after `execution/e8d546f9/S4_STAGE1_GRANT.md`): run `TRANSPORT.md` T1 exactly once, poll with T2, collect with T3 into `execution/e8d546f9/s4-stage1-result`. Nothing runs before that message. No Stage 2, native, canonical-lock, install or browser step is requested.
