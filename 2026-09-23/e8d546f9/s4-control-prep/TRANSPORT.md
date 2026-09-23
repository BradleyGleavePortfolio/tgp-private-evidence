# S4 V6.1 Stage 1 — exact tool transport (transport-only; inner caller unchanged)

Status: prepared, syntax-checked, **not executed**. Awaits the parent's explicit activate message after `execution/e8d546f9/S4_STAGE1_GRANT.md` is published. Staged bytes at `/home/user/workspace/execution/s4-r6-validation/v6` remain frozen (`671d08c3…`, 12/12).

## Inner caller (accepted, byte-pinned, never edited)

`stage1-caller.cmd` in this directory — sha256 `680a0161ae4290709286103e3b195c5fb916b50bce7f9fb9dee500c8292ac1cc` — is exactly one line, byte-identical (checked with `diff`) to the §4 caller in `SLOT_REQUEST_V61.md` and to the Stage 1 caller in the frozen V6 `SLOT_REQUEST_V6.md`:

```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash controls/run-controls-v6.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
```

The transport executes that line with `bash stage1-caller.cmd`; the resulting `bash -c '<line>'` process is the accepted caller, unmodified, with its stdout/stderr redirected to a file and its raw exit persisted to a receipt. No `--kill-after`, no `timeout`, no environment variables, no signal handling added.

## Why detached (facts from REPORT.md §3)

The `bash` tool blocks to completion and preserves the true exit, but every call is bounded by a fixed platform supervisor `--timeout 900` that TERMs then KILLs the call's process group, and the sandbox tears down the call's process group on return. The declared Stage 1 budget is 1500 s (typical 2–3 min). Detaching the caller into its own session (`setsid -f`, stdin `/dev/null`) is the only way the tool can honour the full 1500 s without a second allowance or a KILL mid-teardown; it is the same mechanism the S2 setup lane used successfully in this sandbox for its three stages (raw 0, exit sentinels written).

Process topology under the transport: tool shell (session leader, discarded at return) → `setsid -f` wrapper bash (**new session, leader W**) → `bash stage1-caller.cmd` (pgid W) → accepted `bash -c` (pgid W) → driver (pgid W) → launcher, a non-job-control background child (pgid W ≠ launcher pid ⇒ topology refusal 73 not triggered) → runner and standby holder in their own `setsid` sessions, as designed. Non-interactive, job control off throughout.

## T1 — activate (one `bash` tool call; returns within seconds; run exactly once)

```
R=/home/user/workspace/execution/e8d546f9/s4-stage1-result; C=/home/user/workspace/execution/e8d546f9/s4-control-prep/stage1-caller.cmd
[ -e "$R/stage1.log" ] && { echo "REFUSED: $R/stage1.log exists — single run only; no re-run without a new grant"; exit 3; }
[ "$(sha256sum "$C" | cut -d' ' -f1)" = 680a0161ae4290709286103e3b195c5fb916b50bce7f9fb9dee500c8292ac1cc ] || { echo "REFUSED: caller bytes changed"; exit 4; }
( cd /home/user/workspace/execution/s4-r6-validation/v6 && sha256sum -c --quiet SHA256SUMS && [ "$(sha256sum SHA256SUMS | cut -d' ' -f1)" = 671d08c3633378ef392a4aee6bbb70b78319994727d74e439b75830a6d63d8ee ] ) || { echo "REFUSED: staged packet is not the frozen 671d08c3 bytes"; exit 5; }
mkdir -p "$R" && cd "$R" || exit 70
setsid -f bash -c 'echo "launch_utc=$(date -u +%FT%TZ) pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d " ") sid=$(ps -o sid= -p $$ | tr -d " ") caller_sha256=$(sha256sum "$1" | cut -d" " -f1)"; bash "$1"; rc=$?; echo "end_utc=$(date -u +%FT%TZ) exit=$rc"; printf "%s\n" "$rc" > "$2.tmp" && mv -f "$2.tmp" "$2"; exit "$rc"' _ "$C" "$R/stage1.exit" </dev/null >"$R/stage1.log" 2>&1
sleep 2; head -1 "$R/stage1.log"; sed -n 's/^launch_utc=.* pid=\([0-9]*\) .*/\1/p' "$R/stage1.log" | head -1 > "$R/stage1.pid"; echo "wrapper pid=$(cat "$R/stage1.pid") log=$R/stage1.log exit_receipt=$R/stage1.exit"
```

Guards are refusals only (nothing spawned): existing result log, caller-bytes mismatch, staged-packet mismatch. The wrapper's first log line records the wrapper pid/pgid/sid and the caller's sha256; `stage1.exit` is written atomically (tmp+mv) with the caller's raw exit; the caller's own `driver exit=N` line is the last line of `stage1.log` before `end_utc=… exit=N`.

## T2 — poll (repeat; each call ≤ ~840 s so it stays under the 900 s ceiling; no signal is ever sent by this step)

```
R=/home/user/workspace/execution/e8d546f9/s4-stage1-result; until=$(( $(date +%s) + 840 ))
while :; do
  if [ -f "$R/stage1.exit" ]; then echo "EXITED code=$(cat "$R/stage1.exit")"; tail -3 "$R/stage1.log"; break; fi
  p=$(cat "$R/stage1.pid" 2>/dev/null)
  if [ -n "$p" ] && kill -0 "$p" 2>/dev/null; then st="RUNNING wrapper_pid=$p log_lines=$(wc -l < "$R/stage1.log") since=$(head -1 "$R/stage1.log" | cut -d' ' -f1)"; else st="DEAD-NO-SENTINEL wrapper_pid=${p:-?} (killed before writing the exit receipt; treat as FAILED/unknown; inspect control-runs)"; fi
  [ "$(date +%s)" -lt "$until" ] && [ "${st%% *}" = RUNNING ] && { sleep 15; continue; }
  echo "$st"; break
done
```

## T3 — collect (after `stage1.exit` exists; read/copy/hash only)

```
R=/home/user/workspace/execution/e8d546f9/s4-stage1-result; V=/home/user/workspace/execution/s4-r6-validation/v6
cp -a "$V/control-runs" "$R/control-runs" && ( cd "$V" && sha256sum -c --quiet SHA256SUMS && echo "staged packet still 671d08c3: $(sha256sum SHA256SUMS | cut -c1-16)" ) > "$R/packet-after-run.txt"
grep -h "EXIT code=" "$R"/control-runs/DRIVER-TERMINAL-*.txt > "$R/terminal-receipt.txt" 2>/dev/null; grep -l MISS "$R"/control-runs/CONTROL-V6-*/PREDICATES.txt > "$R/predicates-with-MISS.txt" 2>/dev/null; :
( cd "$R" && find . -type f ! -name SHA256SUMS.stage1 | sort | xargs sha256sum > SHA256SUMS.stage1 )
echo "raw exit=$(cat "$R/stage1.exit") ; driver line: $(grep '^driver exit=' "$R/stage1.log")"; cat "$R/terminal-receipt.txt"; echo "PREDICATES files with MISS: $(wc -l < "$R/predicates-with-MISS.txt")"
```

Pass = `stage1.exit` **0** AND `driver exit=0` AND `predicates-with-MISS.txt` empty AND the terminal receipt line `EXIT code=0 … identity=BOUND leftovers_first='' (state=EMPTY) … private_lease_free=true live_quarantine_holder=''`. Anything else: STOP, preserve everything, no re-run.

## Cancellation / recovery (only if the parent orders it; never automatic)

* Cancel = **one** `kill -TERM <driver pid>` (the driver pid is in the first line of `control-runs/DRIVER-<utc>-<pid>.log`, `driver_pid=`); the driver's trap runs its once-budgeted `finish 143`. Never KILL the driver, launcher or holder; never signal the wrapper pid.
* `DEAD-NO-SENTINEL` or a run past 1500 s: read `control-runs/DRIVER-*.log`, `DRIVER-UNRESOLVED-*`, `*/QUARANTINE_LEASE_HOLDER`, `*/console.log`; any live holder is identified by pid+starttime+token+`readlink fd/9 == …/v6/control-runs/.private-control-lease.lock` before anything is signalled (request §6, private lease only). Escalate to the parent rather than act on uncertainty.

## Fallback transport (not preferred): direct blocking call

Running `stage1-caller.cmd`'s line as the sole `bash` tool command also preserves the raw exit (observed) but caps the run at the platform's 900 s (TERM+KILL of the whole group at expiry). Use only if the parent explicitly prefers no detachment and accepts 900 s as the external bound.
