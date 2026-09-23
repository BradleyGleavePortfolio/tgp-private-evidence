# S4 R6 native caller V2 — exact tool transport (transport-only; inner caller unchanged)

Status: prepared, **not executed**. Awaits the parent's explicit activate message that references the published S4 native/canonical-lock grant. Derived from `s4-control-prep/TRANSPORT.md` (`2f9c6f69…`) with ONLY these substitutions: caller file → `native-caller-v2.cmd` (this directory, sha256 `ef45fd8d…`), result dir → `execution/e8d546f9/s4-native-result`, log/exit/pid names → `native.log` / `native.exit` / `native.pid`, and the byte guard of the caller now covers both accepted caller files (the one-line `.cmd` and the restored script it invokes). No timeout, no KILL, no environment variables, no signal handling, no new semantics added.

## Inner caller (accepted, byte-pinned, never edited)

`native-caller-v2.cmd` — sha256 `ef45fd8d8cc6276de070a9cd0a1674e34174360863327db09c564345d52bae84` — is exactly one line, byte-identical to the frozen packet's `s4-native-caller-v2/native-caller-v2.cmd` (manifest `7bff8f2c…`, reviews A `1b2634a0…` / B `8bece05b…` clean):

```
bash /home/user/workspace/execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh
```

The script at that path is the restored exact V2 caller, sha256 `ba73a99b2602e5640a6339b3e1ec0e79e02272e00914fc5a60faf22f5630a1c1` (read-only). The transport executes `bash native-caller-v2.cmd`; the resulting `bash …/s4-r6-native-caller-v2.sh` process is the accepted caller (the observer), unmodified, stdout/stderr redirected to a file and its raw exit persisted to a receipt. The caller itself spawns the unchanged V6.1 launcher (`85e1bafd…`), verifies the `v6` manifest (20 s, exit 91 on failure, nothing spawned), observes at most `OBSERVE_S` = 3422 s (defaults `S4R6_OUTER_S`/`S4R6_GRACE_S` unset → 3300/45), sends at most one TERM, waits 127 s, and returns; nominal allowance per request §4.1: ≥ 3569 s post-spawn, 3589 s including the manifest allowance, **no KILL deadline** — a launcher alive past it is reported (97), never terminated.

## Why detached

Unchanged from Stage 1: the `bash` tool is bounded by a fixed platform supervisor (900 s, TERM then KILL of the call's process group) and the sandbox tears down the call's process group on return; the caller's declared bound (up to ~3589 s) exceeds that. `setsid -f` with stdin `/dev/null` is the same mechanism that carried Stage 1 (`stage1.exit` 0, `driver exit=0`) and the S2 setup stages.

Process topology: tool shell (discarded at return) → `setsid -f` wrapper bash (new session, leader W) → `bash native-caller-v2.cmd` (pgid W) → accepted caller `bash …/s4-r6-native-caller-v2.sh` (pgid W, `set +m`) → launcher as a non-job-control background child (pgid W ≠ launcher pid ⇒ topology refusal 73 not triggered) → runner and standby holder in their own `setsid` sessions, as designed.

## T1 — activate (one `bash` tool call; returns within seconds; run exactly once; ONLY after the parent's activate message)

```
R=/home/user/workspace/execution/e8d546f9/s4-native-result; C=/home/user/workspace/execution/e8d546f9/s4-native-prep/native-caller-v2.cmd; S=/home/user/workspace/execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh
[ -e "$R/native.log" ] && { echo "REFUSED: $R/native.log exists — single run only; no re-run without a new grant"; exit 3; }
[ "$(sha256sum "$C" | cut -d' ' -f1)" = ef45fd8d8cc6276de070a9cd0a1674e34174360863327db09c564345d52bae84 ] && [ "$(sha256sum "$S" | cut -d' ' -f1)" = ba73a99b2602e5640a6339b3e1ec0e79e02272e00914fc5a60faf22f5630a1c1 ] || { echo "REFUSED: caller bytes changed"; exit 4; }
( cd /home/user/workspace/execution/s4-r6-validation/v6 && sha256sum -c --quiet SHA256SUMS && [ "$(sha256sum SHA256SUMS | cut -d' ' -f1)" = 671d08c3633378ef392a4aee6bbb70b78319994727d74e439b75830a6d63d8ee ] ) || { echo "REFUSED: staged packet is not the frozen 671d08c3 bytes"; exit 5; }
mkdir -p "$R" && cd "$R" || exit 70
setsid -f bash -c 'echo "launch_utc=$(date -u +%FT%TZ) pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d " ") sid=$(ps -o sid= -p $$ | tr -d " ") caller_sha256=$(sha256sum "$1" | cut -d" " -f1)"; bash "$1"; rc=$?; echo "end_utc=$(date -u +%FT%TZ) exit=$rc"; printf "%s\n" "$rc" > "$2.tmp" && mv -f "$2.tmp" "$2"; exit "$rc"' _ "$C" "$R/native.exit" </dev/null >"$R/native.log" 2>&1
sleep 2; head -1 "$R/native.log"; sed -n 's/^launch_utc=.* pid=\([0-9]*\) .*/\1/p' "$R/native.log" | head -1 > "$R/native.pid"; echo "wrapper pid=$(cat "$R/native.pid") log=$R/native.log exit_receipt=$R/native.exit"
```

Guards are refusals only (nothing spawned): existing result log, caller-bytes mismatch (either file), staged-packet mismatch. The wrapper's first log line records wrapper pid/pgid/sid and the `.cmd` sha256; `native.exit` is written atomically (tmp+mv) with the caller's raw exit (= the caller's `OBSERVER_RETURN`); the caller's own `launcher exit=…` and `caller receipt=… observer_return=…` lines are the last lines of `native.log` before `end_utc=… exit=N`. The caller's stderr notes (`spawned launcher pid=… caller_pid=… starttime=…`) land in `native.log` too.

## T2 — poll (repeat; each call ≤ ~840 s; expect up to ~5 polls for a full-bound run; no signal is ever sent by this step)

```
R=/home/user/workspace/execution/e8d546f9/s4-native-result; until=$(( $(date +%s) + 840 ))
while :; do
  if [ -f "$R/native.exit" ]; then echo "EXITED code=$(cat "$R/native.exit")"; tail -3 "$R/native.log"; break; fi
  p=$(cat "$R/native.pid" 2>/dev/null)
  if [ -n "$p" ] && kill -0 "$p" 2>/dev/null; then st="RUNNING wrapper_pid=$p log_lines=$(wc -l < "$R/native.log") since=$(head -1 "$R/native.log" | cut -d' ' -f1)"; else st="DEAD-NO-SENTINEL wrapper_pid=${p:-?} (killed before writing the exit receipt; treat as FAILED/unknown; inspect caller-receipts and runs)"; fi
  [ "$(date +%s)" -lt "$until" ] && [ "${st%% *}" = RUNNING ] && { sleep 15; continue; }
  echo "$st"; break
done
```

## T3 — collect (after `native.exit` exists; read/copy/hash only) — THREE distinct artefacts

```
R=/home/user/workspace/execution/e8d546f9/s4-native-result; VAL=/home/user/workspace/execution/s4-r6-validation
cp -a "$VAL/caller-receipts" "$R/caller-receipts" 2>/dev/null; cp -a "$VAL/runs" "$R/runs" 2>/dev/null; ( cd "$VAL/v6" && sha256sum -c --quiet SHA256SUMS && echo "staged packet still 671d08c3: $(sha256sum SHA256SUMS | cut -c1-16)" ) > "$R/packet-after-run.txt"
( cd "$R" && find . -type f ! -name SHA256SUMS.native | sort | xargs sha256sum > SHA256SUMS.native )
echo "[1] transport observer exit (native.exit) = $(cat "$R/native.exit")"
echo "[2] caller receipt(s):"; ls "$R"/caller-receipts/NATIVE-CALLER-*.txt 2>/dev/null; grep -h 'ACTUAL_LAUNCHER_EXIT=' "$R"/caller-receipts/NATIVE-CALLER-*.txt 2>/dev/null; echo "receipt complete (SEMANTICS line present): $(grep -c '^SEMANTICS:' "$R"/caller-receipts/NATIVE-CALLER-*.txt 2>/dev/null)"; ls "$VAL"/caller-receipts/*.tmp 2>/dev/null && echo "PARTIAL .tmp receipt present — not a result"
echo "[3] SUPERVISOR_RECORD:"; ls "$R"/runs/VALIDATION-V6-*/SUPERVISOR_RECORD.json 2>/dev/null; for f in "$R"/runs/VALIDATION-V6-*/SUPERVISOR_RECORD.json; do [ -f "$f" ] && python3 -c 'import json,sys;L=json.load(open(sys.argv[1]));print("overall=",L.get("overall"),"launcher_exit=",L.get("launcher_exit"),"runner.exit=",(L.get("runner") or {}).get("exit"),"lease.self_hold=",(L.get("lease") or {}).get("self_hold"))' "$f"; done
echo "stdout contract lines:"; grep -h -E '^(launcher exit=|caller receipt=)' "$R/native.log"
```

The three artefacts are kept separate and are never merged into one verdict: **[1]** `native.exit` = the caller process's exit (`OBSERVER_RETURN`: N actual launcher exit, or 97/94/91/90/70); **[2]** the caller receipt `caller-receipts/NATIVE-CALLER-<utc>-<pid>.txt` (all-or-nothing in V2; carries `ACTUAL_LAUNCHER_EXIT=`, identity, census, `UNRESOLVED=`); **[3]** the launcher's `runs/VALIDATION-V6-*/SUPERVISOR_RECORD.json` (`overall`, `runner.exit`, `lease.self_hold` — the only source for the cause of an actual exit 12).

Native success (request §5) requires **[1] = 0 AND [2] complete with `ACTUAL_LAUNCHER_EXIT=0 OBSERVER_RETURN=0` AND [3] consistent** — never 97, a would-be 12, a missing/partial receipt (`.tmp`), or an UNKNOWN census. Anything else: STOP, preserve everything, no re-run; 97 is a recorded recovery boundary for the parent.

## Cancellation / recovery (only if the parent orders it; never automatic)

* Cancel = **one** `kill -TERM <caller pid>` — the caller pid is `caller_pid=` in the `spawned launcher pid=…` note in `native.log`; the caller's trap forwards exactly one TERM to the launcher via `cancel_active` and waits its 127 s allowance, then returns 97 with a receipt. Never KILL the caller, launcher or holder; never signal the wrapper pid; never send a second TERM.
* `DEAD-NO-SENTINEL`, 97, or a run past the nominal allowance: read the receipt's `UNRESOLVED=`/`live_launcher_*`/`recorded_quarantine_holder` lines, `runs/*/console.log`, `*/QUARANTINE_LEASE_HOLDER`, `SUPERVISOR_RECORD.json`; any live holder is identified by pid + starttime + token + `readlink /proc/<pid>/fd/9 == /home/user/workspace/execution/test-validation.lock` and the owned session verified EMPTY (UNKNOWN never counts) before anything is signalled (ruling §Recovery). Escalate to the parent rather than act on uncertainty.

## Fallback transport (not preferred): direct blocking call

Running `native-caller-v2.cmd`'s line as the sole `bash` tool command preserves the raw exit but caps the run at the platform's 900 s (TERM+KILL of the whole group at expiry) — incompatible with the caller's 3422 s observer bound and with the ruling's "no KILL of the last exclusion owner". Use only if the parent explicitly prefers no detachment and accepts that bound.
