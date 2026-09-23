#!/usr/bin/env bash
# OP88-S5-SETUP-EXCLUSION outer launcher v1 (NOT LAUNCHED; parent option (a)). Explicitly owned lease holder for the S5 setup: acquires the
# canonical lease ONCE, publishes holder identity (pid, sid, /proc start time, token, hashes) BEFORE any child exists, launches the pinned
# v10x runner through the unchanged OWN-BLOCK v10 primitive (identity confirmed + IDENTITY published before ADOPT release), waits in THIS
# shell for the RAW runner result (separated from cleanup/publication/recovery), and releases the lease ONLY after the exact owned session is
# verified EMPTY and the RELEASE record is published — or after a CHECKED RECOVERY HANDOFF (parent-written $EX/RECOVERY_ACCEPT naming this
# token+holder pid+start time). On live/unknown ownership, census error, or failed marker publication it enters an OBSERVABLE SELF-HOLD:
# it stays alive holding fd 9, records SELF_HOLD (primary $EX, fallback $LOGS, last resort stderr + the holder record already published) and
# heartbeats every 30 s with the current census; it never kills itself to satisfy a duration claim and never frees exclusion with owned
# work live or unknown. Owned children (never the holder) may be escalated TERM->KILL once, inside the exact owned session only.
# Normal bounded execution: inner `timeout -k 30 1290` around the runner + NORMAL_BOUND 1380 s here; exceptional SELF-HOLD is a distinct,
# recorded state (STATE=SELF-HOLD in $EX/LEASE_HOLDER heartbeat + SELF_HOLD record). Invoke WITHOUT an outer timeout on this process:
#   setsid nohup bash launch-s5-setup-exclusion.v1.sh > $LOGS/launcher.out 2>&1 < /dev/null &
# Private fault controls run the same bytes with S5X_PRIVATE=1 and private LOCK/EX/LOGS/RUNNER (refused if any path is canonical).
set -u
[ "${S5_SETUP_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_SETUP_GRANT=granted-by-parent not set"; exit 2; }
CANON_LOCK=/home/user/workspace/execution/test-validation.lock; CANON_EX=/home/user/workspace/execution/s5-r4
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${S5X_PRIVATE:-0}" = 1 ]; then LOCK=${S5X_LOCK:?}; EX=${S5X_EX:?}; RUNNER=${S5X_RUNNER:?}; INNER_BOUND=${S5X_INNER_BOUND:-1290}; INNER_KILL=${S5X_INNER_KILL:-30}; NORMAL_BOUND=${S5X_NORMAL_BOUND:-1380}; HEARTBEAT=${S5X_HEARTBEAT:-30}
  case "$LOCK$EX" in *"$CANON_LOCK"*|*"$CANON_EX"*) echo "REFUSE: private mode may not touch canonical paths"; exit 2;; esac
else LOCK=$CANON_LOCK; EX=$CANON_EX; RUNNER="$HERE/run-s5-setup-npm-ci.v10x.sh"; INNER_BOUND=1290; INNER_KILL=30; NORMAL_BOUND=1380; HEARTBEAT=30; fi
LOGS=$EX/logs/setup-exclusion; mkdir -p "$LOGS" || exit 74; LOG=$LOGS/launcher.EXIT_RECORD; ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
say() { echo "$(ts) $*" >> "$LOG" || { echo "LAUNCHER_LOG_WRITE_FAILED $*" >&2; return 1; }; }
PIN_RUNNER=3a7b57d132fccbf16f4ad3ee0b56a314a2bccf7cfc48b6765a4305cbc2627c1c; [ "${S5X_PRIVATE:-0}" = 1 ] || { [ "$(sha256sum "$RUNNER" | cut -c1-64)" = "$PIN_RUNNER" ] || { echo "REFUSE: runner hash != $PIN_RUNNER"; exit 2; }; }
# >>> OWN-BLOCK v10 (successor of v9 9d713d2c per audits/owned-launch-v9-a A-01..A-05; v8 cc8346cd per checkpoint-2 rows 1-3 and parent ruling: bounded child-side adoption gate; byte-identical
# in ctl-t0-only.v9.sh and run-s5-setup-npm-ci.v9.sh; controls source this file). Consumer MUST set OWN_ROOT (private evidence dir) first.
# Contract: workload execs only after (a) current-attempt identity confirmed pgid==sid==pid, direct child, not self group and (b) adoption
# published to a FRESH private attempt path and verified by the child (content == "<child pid> <attempt token>"); no ack / expired / parent
# gone => child exits 75/76 without workload. Trap recovery covers pre-spawn, after-fork-before-register and interrupted-adoption phases via
# phase-bound, direct-child-verified $!. Authority is retired explicitly after actual wait; retired numeric ids are never signalled.
# Folds OWN-V8-A-01..A-06 (audits/owned-launch-v8-a): descendant/group authority survives leader exit but only while the group is still
# the session we created (every member sid==pgid), unconfirmed termination never reaches `wait` (own_finish), reap/publication status
# is returned to the consumer to govern its exit. v10: own_finish performs `wait` IN THE CALLING (child-owning) SHELL and returns through
# variables OWN_FIN/OWN_FIN_RC (never call it inside $(...); a subshell call is detected via BASHPID and reported as mechanism-error, distinct
# from a workload's genuine 127); own_collect reaps/retires every exited registered pid in the calling shell; own_record publishes any
# required evidence file atomically (tmp -> mv -> readback) and returns its outcome so consumers can latch it; own_census reports the CURRENT
# registry (live / zombie-only / foreign / retired) for final accounting instead of historical numeric ids. Folds owned-launch-v9-b
# V9B-05: every ps read goes through own_ps_field, which distinguishes present (rc0) / observed-gone (ps rc!=0 AND /proc/<pid> absent, rc1) /
# census-error (rc2: ps failed or empty while /proc/<pid> exists). Unknown is never gone, never retired, never signalled: liveness tests
# (own_alive, group emptiness) fail CLOSED on unknown, signal/retire tests require positive proof. Folds S6 review B Part B: R3 job-control mode is stamped and refused (under `set -m` the
# background child is a group leader, `setsid` forks and $! names an exited intermediate; v9 also fail-closes there because the gate child's
# $$ never matches the published pid), and zombie members are excluded from group liveness (no false SURVIVOR before `wait`).
OWN_SELF_PGID=$(ps -o pgid= -p $$ | tr -d ' '); OWN_SELF_SID=$(ps -o sid= -p $$ | tr -d ' ')
OWN_PIDS=""; OWN_PGIDS=""; OWN_RETIRED=""; OWN_LAST_DECOY=""; OWN_PHASE=idle
# child-side gate: bash -c "$OWN_GATE" own-gate <attempt-dir> <parent-pid> <workload...>; polls 0.05 s up to 100x (5 s); 76 if parent gone, 75 if never adopted
OWN_GATE='a=$1; p=$2; shift 2; i=0; while :; do kill -0 "$p" 2>/dev/null || exit 76; [ -r "$a/ADOPT" ] && [ "$(cat "$a/ADOPT" 2>/dev/null)" = "$$ ${a##*/}" ] && break; i=$((i+1)); [ "$i" -ge 100 ] && exit 75; sleep 0.05; done; exec "$@"'
own_stamp() { echo "monitor=$([[ -o monitor ]] && echo on || echo off) bash=$BASH_VERSION setsid=[$(setsid --version 2>&1 | head -1)] timeout=[$(timeout --version 2>&1 | head -1)] ps=[$(ps --version 2>&1 | head -1)]"; }
own_precondition() { [[ -o monitor ]] && return 1; [ -n "$OWN_SELF_PGID" ] && [ -n "$OWN_SELF_SID" ] || return 1; command -v setsid >/dev/null && command -v pgrep >/dev/null && command -v ps >/dev/null; }   # refuse job-control mode / missing tools
own_attempt() { local d; d=$(mktemp -d "$OWN_ROOT/attempt-XXXXXX" 2>/dev/null) || return 1; [ -d "$d" ] && [ ! -e "$d/ADOPT" ] || return 1; echo "$d"; }   # fresh private path per attempt
own_spawn_begin() { OWN_PHASE=spawning; }                                          # the command immediately BEFORE the `... &` line
own_register() { OWN_PIDS="$OWN_PIDS $1"; OWN_PHASE=registered; }                 # the command immediately AFTER `&`, with $!
own_ps_field() { # <pid> <field>: prints value; rc0 present; rc1 observed-gone (ps rc!=0/empty AND /proc/<pid> absent); rc2 census-error (ps failed/empty but /proc/<pid> exists)
  local v rc; v=$(ps -o "$2=" -p "$1" 2>/dev/null); rc=$?; if [ $rc -eq 0 ] && [ -n "${v// /}" ]; then printf '%s' "${v// /}"; return 0; fi; [ -d "/proc/$1" ] && return 2; return 1; }
own_is_child() { # positive proof only: rc0 ppid==$$; rc1 gone/not ours; rc2 census-error (OWN_LAST_STATE=unknown) — callers that SIGNAL or RETIRE must see rc0
  local pp; pp=$(own_ps_field "$1" ppid); case $? in 0) [ "$pp" = "$$" ] && { OWN_LAST_STATE=child; return 0; }; OWN_LAST_STATE=notchild; return 1;; 1) OWN_LAST_STATE=gone; return 1;; *) OWN_LAST_STATE=unknown; return 2;; esac; }
own_identity() { local pg sid; pg=$(own_ps_field "$1" pgid) || return $?; sid=$(own_ps_field "$1" sid) || return $?; echo "$pg $sid"; }
own_alive() { # rc0 = alive OR unknown (absence not proven: fail closed); rc1 = proven gone / zombie / not our child. State in OWN_LAST_STATE
  local st; own_is_child "$1"; case $? in 1) return 1;; 2) return 0;; esac
  st=$(own_ps_field "$1" stat); case $? in 0) [ "${st:0:1}" = Z ] && { OWN_LAST_STATE=zombie; return 1; }; OWN_LAST_STATE=alive; return 0;; 1) OWN_LAST_STATE=gone; return 1;; *) OWN_LAST_STATE=unknown; return 0;; esac; }
own_pending() { # phase-bound fallback for a fork whose register line never ran: $! only while OWN_PHASE=spawning, live direct child, not registered/retired
  [ "$OWN_PHASE" = spawning ] || return 0; local p=${!:-}; [ -n "$p" ] || return 0
  case " $OWN_PIDS $OWN_RETIRED " in *" $p "*) return 0;; esac; own_alive "$p" && echo "$p"; return 0; }
own_confirm() { # <pid> [max_s=2]: rc0 confirmed (pgid==sid==pid, direct child, not self group; added to OWN_PGIDS); rc1 gone; rc2 unconfirmed
  local pid=$1 n=$(( ${2:-2} * 20 )) i=0 id pg sid
  while :; do own_is_child "$pid"; case $? in 1) return 1;; 2) i=$((i+1)); [ $i -ge $n ] && return 3; sleep 0.05; continue;; esac   # rc3 = census-error, never confirmed
    id=$(own_identity "$pid"); case $? in 1) return 1;; 2) i=$((i+1)); [ $i -ge $n ] && return 3; sleep 0.05; continue;; esac; pg=${id% *}; sid=${id#* }
    if [ "$pg" = "$pid" ] && [ "$sid" = "$pid" ] && [ "$pg" != "$OWN_SELF_PGID" ]; then OWN_PGIDS="$OWN_PGIDS $pg"; return 0; fi
    [ "$pg" = "$OWN_SELF_PGID" ] && OWN_LAST_DECOY="$pg"
    i=$((i+1)); [ $i -ge $n ] && return 2; sleep 0.05; done; }
own_adopt() { # <pid> <attempt>: publish after own_confirm rc0 ONLY. prints published|publication-write-failed|publication-rename-failed|publication-readback-mismatch; rc1 on any failure
  local pid=$1 a=$2 want="$1 ${2##*/}" tmp="$2/ADOPT.tmp"
  printf '%s' "$want" > "$tmp" 2>/dev/null || { echo publication-write-failed; return 1; }
  mv -f "$tmp" "$a/ADOPT" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; echo publication-rename-failed; return 1; }
  [ "$(cat "$a/ADOPT" 2>/dev/null)" = "$want" ] || { echo publication-readback-mismatch; return 1; }; echo published; }
own_signal() { # <pid> <SIG>: no signal unless current direct child; group only if identity re-confirmed now; prints group|pid|gone|notchild
  local pid=$1 sig=$2 id pg sid; own_is_child "$pid"; case $? in 1) echo "$OWN_LAST_STATE"; return 0;; 2) echo census-error; return 0;; esac; id=$(own_identity "$pid") || { echo census-error; return 0; }; pg=${id% *}; sid=${id#* }
  if [ "$pg" = "$pid" ] && [ "$sid" = "$pid" ] && [ "$pg" != "$OWN_SELF_PGID" ]; then kill "-$sig" -- "-$pg" 2>/dev/null; echo group; else kill "-$sig" "$pid" 2>/dev/null; echo pid; fi; }
own_session_members() { # live members of the session we created (sid == confirmed leader pid), any process group. rc0 listed (possibly none); rc2 census-error (ps failed)
  local out; out=$(ps -eo pid=,sid=,stat= 2>/dev/null) || return 2; [ -n "$out" ] || return 2; printf '%s\n' "$out" | awk -v s="$1" '$2==s && substr($3,1,1)!="Z"{print $1}'; }
own_group_current() { # <sid>: rc0 live members; rc1 observed empty; rc2 the pgid NUMBER has a PRESENT member outside our session (foreign: never signal); rc3 census-error (unknown: never gone)
  local m p sid st; m=$(pgrep -g "$1" 2>/dev/null); [ -z "$m" ] && [ "$(pgrep -g "$1" >/dev/null 2>&1; echo $?)" -gt 1 ] && return 3
  for p in $m; do st=$(own_ps_field "$p" stat); case $? in 1) continue;; 2) return 3;; esac; [ "${st:0:1}" = Z ] && continue
    sid=$(own_ps_field "$p" sid); case $? in 1) continue;; 2) return 3;; esac; [ "$sid" = "$1" ] || return 2; done
  m=$(own_session_members "$1") || return 3; [ -n "$m" ] && return 0; return 1; }
own_group_signal() { # <sid> <SIG>: signal every process group of OUR session (each verified to contain only session members); prints group:n|empty|refused|census-error
  case " $OWN_PGIDS " in *" $1 "*) ;; *) echo refused; return 0;; esac; [ "$1" != "$OWN_SELF_PGID" ] && [ "$1" != "$OWN_SELF_SID" ] || { echo refused; return 0; }
  own_group_current "$1"; case $? in 1) echo empty; return 0;; 2) echo refused; return 0;; 3) echo census-error; return 0;; esac
  local p g n=0 ok sid; for g in $(for p in $(own_session_members "$1"); do own_ps_field "$p" pgid; echo; done | sort -u); do [ -n "$g" ] || continue
    ok=1; for p in $(pgrep -g "$g" 2>/dev/null); do sid=$(own_ps_field "$p" sid); case $? in 0) [ "$sid" = "$1" ] || ok=0;; 1) ;; 2) ok=0;; esac; done
    [ "$ok" = 1 ] && [ "$g" != "$OWN_SELF_PGID" ] && { kill "-$2" -- "-$g" 2>/dev/null; n=$((n+1)); }; done; echo "group:$n"; }
own_group_wait_empty() { # <sid> <s>: rc0 ONLY on observed-empty (rc1); keeps polling on live/unknown; rc2 foreign
  local n=$(( $2 * 10 )) i=0 st; while :; do own_group_current "$1"; st=$?; case $st in 1) return 0;; 2) return 2;; esac; [ $i -lt $n ] || return 1; sleep 0.1; i=$((i+1)); done; }
own_finish() { # <pid> -> OWN_FIN=observed|unobserved|mechanism-error-subshell, OWN_FIN_RC. Call DIRECTLY in the launching shell; `wait` only after verified absence
  OWN_FIN_RC=""; [ "$BASHPID" = "$$" ] || { OWN_FIN=mechanism-error-subshell; return 2; }
  if own_alive "$1"; then OWN_FIN=unobserved; return 1; fi; wait "$1" 2>/dev/null; OWN_FIN_RC=$?; OWN_FIN=observed; return 0; }
own_collect() { # [prefix]: in the launching shell (call directly, optionally with `>> file` — never inside $(...) or a pipe): wait+retire every registered pid no longer alive
  local p pre=${1:-}; for p in $OWN_PIDS; do own_alive "$p" && continue; own_finish "$p" || { echo "${pre}COLLECT_ERROR pid=$p state=$OWN_FIN"; continue; }; echo "${pre}COLLECTED pid=$p rc=$OWN_FIN_RC"; own_retire "$p"; done; return 0; }
own_record() { # <path> <content>: atomic checked publication; rc0 only when the file exists with exactly this content (tmp -> mv -> readback)
  local tmp="$1.tmp.$$"; printf '%s\n' "$2" > "$tmp" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; return 1; }
  mv -f "$tmp" "$1" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; return 2; }; [ "$(cat "$1" 2>/dev/null)" = "$2" ] || return 3; }
own_census() { # current registry truth: prints one line per active pid/group and retired id; rc1 if any LIVE owned process remains (zombies/foreign/retired never count)
  local p pg rc=0 st; for p in $OWN_PIDS; do if own_alive "$p"; then echo "${OWN_LAST_STATE^^} pid=$p identity=[$(own_identity "$p" 2>/dev/null)]"; rc=1; elif [ "$OWN_LAST_STATE" = zombie ]; then echo "ZOMBIE pid=$p (unwaited; collect)"; else echo "GONE pid=$p ($OWN_LAST_STATE)"; fi; done
  for pg in $OWN_PGIDS; do own_group_current "$pg"; st=$?; case $st in 0) echo "LIVE_SESSION sid=$pg members=[$(own_session_members "$pg" | tr '\n' ',')]"; rc=1;; 1) echo "EMPTY_SESSION sid=$pg";; 2) echo "FOREIGN_NUMBER sid=$pg (not owned, not counted)";; *) echo "CENSUS_ERROR sid=$pg (unknown: counted as unresolved)"; rc=1;; esac; done
  for p in $OWN_RETIRED; do echo "RETIRED id=$p (evidence only)"; done; return $rc; }
own_wait_gone() { local pid=$1 n=$(( $2 * 10 )) i=0; while own_alive "$pid" && [ $i -lt $n ]; do sleep 0.1; i=$((i+1)); done; ! own_alive "$pid"; }   # bounded; never `wait`
own_retire() { # <pid>: ONLY after actual `wait` or verified absence; removes signal authority (pid and its group), keeps evidence elsewhere. rc1 if still alive
  ! own_alive "$1" || return 1; local p n=""; for p in $OWN_PIDS; do [ "$p" = "$1" ] || n="$n $p"; done; OWN_PIDS=$n
  n=""; for p in $OWN_PGIDS; do [ "$p" = "$1" ] || n="$n $p"; done; OWN_PGIDS=$n; OWN_RETIRED="$OWN_RETIRED $1"; }
own_reap_all() { # <grace_s>: registered pids + phase-bound pending fork; TERM -> bounded -> KILL -> 3 s bounded; census confirmed groups; rc1 on survivor
  local pid rc=0 how pg m; for pid in $OWN_PIDS $(own_pending); do own_alive "$pid" || continue   # leader/pid phase; descendants handled per confirmed group below regardless of leader liveness
    how=$(own_signal "$pid" TERM); if ! own_wait_gone "$pid" "$1"; then how="$how+KILL:$(own_signal "$pid" KILL)"; own_wait_gone "$pid" 3 || { echo "SURVIVOR pid=$pid how=$how"; rc=1; continue; }; fi
    echo "REAPED pid=$pid how=$how"; done
  for pg in $OWN_PGIDS; do own_group_current "$pg"; case $? in 1) continue;; 2) echo "GROUP_FOREIGN pgid=$pg (number reused by another session: not signalled)"; continue;; 3) echo "GROUP_CENSUS_ERROR sid=$pg (unknown: not signalled, not retired)"; rc=1; continue;; esac
    how=$(own_group_signal "$pg" TERM); own_group_wait_empty "$pg" "$1" || { how="$how+KILL:$(own_group_signal "$pg" KILL)"; own_group_wait_empty "$pg" 3 || { m=$(own_session_members "$pg"); echo "GROUP_SURVIVORS sid=$pg how=$how [${m//$'\n'/,}]"; rc=1; continue; }; }
    echo "GROUP_REAPED pgid=$pg how=$how"; done; return $rc; }
own_budget() { local b=$(( $1 - $3 - $4 )); [ "$b" -gt "$2" ] && b=$2; [ "$b" -lt 0 ] && b=0; echo "$b"; }
# <<< OWN-BLOCK v10

say "LAUNCHER_START pid=$$ stamp=[$(own_stamp)] launcher_sha256=$(sha256sum "$0" | cut -c1-64) runner=$RUNNER runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64) lock=$LOCK ex=$EX private=${S5X_PRIVATE:-0}" || exit 74
own_precondition || { say "REFUSE precondition (job control on or tools missing)"; exit 2; }
TOKEN="$(date -u +%Y%m%dT%H%M%SZ)-$$-$RANDOM"; START_TIME=$(cut -d' ' -f22 "/proc/$$/stat"); STATE=ACQUIRING
# ---- lease: acquire once, publish holder BEFORE any child (pre-exec ownership publication)
exec 9>"$LOCK" || { say "LEASE_OPEN_FAILED $LOCK"; exit 75; }
flock -n 9 || { say "LEASE_BUSY $LOCK (another holder; nothing launched)"; exit 75; }
holder_line() { echo "token=$TOKEN holder_pid=$$ holder_sid=$OWN_SELF_SID holder_pgid=$OWN_SELF_PGID start_time=$START_TIME state=$1 since=$(ts) lock=$LOCK launcher_sha256=$(sha256sum "$0" | cut -c1-64) runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64)"; }
own_record "$EX/LEASE_HOLDER" "$(holder_line HELD)" || { say "HOLDER_PUBLICATION_FAILED $EX/LEASE_HOLDER: lease released (nothing launched)"; exit 74; }
STATE=HELD; say "LEASE_HELD token=$TOKEN fd=9 holder published"
RAW=none; RAW_RC=""; CLEANUP=none; PUBLICATION=ok; RECOVERY=none; SESSION=""; ESCALATED=0
publish_state() { own_record "$EX/LEASE_HOLDER" "$(holder_line "$1")" && return 0; PUBLICATION=holder-update-failed; say "HOLDER_UPDATE_FAILED state=$1"; return 1; }
record_or_fallback() { # <name> <content>: primary $EX, fallback $LOGS, last resort stderr; sets PUBLICATION
  if own_record "$EX/$1" "$2"; then say "$1 published $EX/$1"; return 0; fi
  if own_record "$LOGS/$1" "$2"; then PUBLICATION="$1-fallback"; say "$1 published FALLBACK $LOGS/$1"; return 0; fi
  PUBLICATION="$1-failed"; echo "$(ts) $1 PUBLICATION FAILED (primary+fallback): $2" >&2; say "$1 PUBLICATION FAILED primary+fallback"; return 1; }
census_state() { own_census >/dev/null 2>&1 && echo empty || { own_census 2>/dev/null | grep -q 'CENSUS_ERROR\|UNKNOWN' && echo unknown || echo live; }; }
handoff_accepted() { # checked recovery handoff: $EX/RECOVERY_ACCEPT must name this token, holder pid and start time
  [ -r "$EX/RECOVERY_ACCEPT" ] || return 1; grep -q "^accept token=$TOKEN holder_pid=$$ start_time=$START_TIME acceptor=[^ ]\+" "$EX/RECOVERY_ACCEPT"; }
release() { # <final_rc>: only after verified EMPTY session or accepted handoff; publishes RELEASE then exits (fd 9 closes with the process)
  local how=$1 rc=$2; own_record "$EX/LEASE_RELEASE" "token=$TOKEN holder_pid=$$ start_time=$START_TIME released_at=$(ts) how=$how raw=$RAW${RAW_RC:+ $RAW_RC} cleanup=$CLEANUP publication=$PUBLICATION recovery=$RECOVERY session=$SESSION final_rc=$rc" || { PUBLICATION=release-record-failed; say "RELEASE_RECORD_FAILED: entering SELF-HOLD instead of releasing"; return 1; }
  publish_state "RELEASED($how)"; say "LEASE_RELEASED how=$how raw=$RAW${RAW_RC:+ $RAW_RC} cleanup=$CLEANUP publication=$PUBLICATION recovery=$RECOVERY final_rc=$rc"; exit "$rc"; }
self_hold() { # <reason>: observable retained exclusion; loops until verified empty (-> release) or checked handoff; never self-terminates
  STATE=SELF-HOLD; publish_state SELF-HOLD; record_or_fallback SELF_HOLD "token=$TOKEN holder_pid=$$ start_time=$START_TIME since=$(ts) reason=[$1] raw=$RAW${RAW_RC:+ $RAW_RC} cleanup=$CLEANUP publication=$PUBLICATION session=$SESSION census=[$(own_census 2>/dev/null | tr '\n' ';')] (lease fd 9 retained; parent handoff: write $EX/RECOVERY_ACCEPT 'accept token=$TOKEN holder_pid=$$ start_time=$START_TIME acceptor=<id>')"
  say "SELF_HOLD reason=[$1] (heartbeat every ${HEARTBEAT}s; no self-imposed bound)"
  while :; do own_collect "heartbeat " >> "$LOG"; local cs; cs=$(census_state)
    if handoff_accepted; then RECOVERY="handoff-accepted:$(sed -n 's/.*acceptor=\([^ ]*\).*/\1/p' "$EX/RECOVERY_ACCEPT" | head -1)"; say "RECOVERY_HANDOFF accepted census=$cs"; release "handoff" 90; fi
    if [ "$cs" = empty ] && [ "$PUBLICATION" != "SELF_HOLD-failed" ]; then release "self-hold-then-empty" 90; fi
    [ "$cs" = empty ] && [ "$PUBLICATION" = "SELF_HOLD-failed" ] && { record_or_fallback SELF_HOLD "retry token=$TOKEN empty_at=$(ts)" && release "self-hold-then-empty" 90; }
    say "HEARTBEAT state=SELF-HOLD census=$cs publication=$PUBLICATION"; publish_state SELF-HOLD >/dev/null; sleep "$HEARTBEAT"; done; }
on_signal() { trap '' TERM INT HUP; say "LAUNCHER_SIGNAL state=$STATE (lease retained; escalating owned session once, then verify)"; CLEANUP=signal; exceptional "signal"; }
exceptional() { # <reason>: one escalation inside the exact owned session, then verify; never touches the holder
  local o rrc cs; if [ -z "$SESSION" ] && [ -n "$OWN_PIDS$(own_pending)" ]; then :; fi
  o=$(own_reap_all 30); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) escalate /" >> "$LOG"; own_collect "escalate " >> "$LOG"; ESCALATED=1; CLEANUP="escalated(rc=$rrc)"
  cs=$(census_state); say "AFTER_ESCALATION census=$cs reap_rc=$rrc"
  [ "$cs" = empty ] && [ "$rrc" = 0 ] && release "$1-then-empty" 90; self_hold "$1: census=$cs reap_rc=$rrc"; }
trap on_signal TERM INT HUP
# ---- launch the runner through the primitive (identity + IDENTITY publication before ADOPT release)
OWN_ROOT="$LOGS/attempts"; mkdir -p "$OWN_ROOT" || { say "ATTEMPTS_DIR_FAILED"; release "nothing-launched" 74; }
ATT=$(own_attempt) || { say "ATTEMPT_PATH_FAILED"; release "nothing-launched" 74; }
STATE=LAUNCHING; publish_state LAUNCHING
own_spawn_begin
( exec setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ env S5_LEASE_INHERITED="$TOKEN" S5_SETUP_GRANT="$S5_SETUP_GRANT" timeout -k "$INNER_KILL" "$INNER_BOUND" bash "$RUNNER" ) > "$LOGS/runner.out" 2>&1 < /dev/null &
PID=$!; own_register "$PID"; SESSION=$PID
own_confirm "$PID" 2; CRC=$?; PUB=not-attempted; RSTATE=never-released
if [ "$CRC" = 0 ]; then
  if own_record "$ATT/IDENTITY" "pid=$PID attempt=${ATT##*/} identity=[$(own_identity "$PID")] holder_pid=$$ token=$TOKEN self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none}"; then PUB=$(own_adopt "$PID" "$ATT"); [ "$PUB" = published ] && RSTATE=released; else PUB=identity-publication-failed; fi; fi
say "RUNNER_LAUNCH pid=$PID confirm_rc=$CRC adoption=$PUB state=$RSTATE" || { [ "$RSTATE" = released ] && RSTATE=released-then-cancelled; PUBLICATION=launch-record-failed; }
if [ "$RSTATE" != released ]; then own_signal "$PID" TERM >/dev/null; own_wait_gone "$PID" 5 || { own_signal "$PID" KILL >/dev/null; own_wait_gone "$PID" 3; }
  own_finish "$PID"; RAW=$OWN_FIN; RAW_RC=$OWN_FIN_RC; CLEANUP=refused-$PUB; exceptional "runner-not-released($RSTATE)"; fi
STATE=RUNNING; publish_state RUNNING
# ---- normal bounded execution: wait for the runner in THIS shell (raw result), then verify the exact session empty
own_wait_gone "$PID" "$NORMAL_BOUND" || { say "NORMAL_BOUND_EXCEEDED ${NORMAL_BOUND}s: runner leader still alive (inner timeout should have ended it)"; }
own_finish "$PID"; RAW=$OWN_FIN; RAW_RC=$OWN_FIN_RC; say "RUNNER_RAW $RAW${RAW_RC:+ rc=$RAW_RC} (separate from cleanup/publication/recovery)"
own_group_current "$SESSION"; GC=$?
case $GC in
  1) [ "$RAW" = observed ] && own_retire "$PID"; CLEANUP=verified-empty; release "normal" "${RAW_RC:-70}" ;;
  0) say "SESSION_LIVE after runner exit: members=[$(own_session_members "$SESSION" | tr '\n' ',')]"; exceptional "session-live-after-runner" ;;
  2) say "SESSION_NUMBER_FOREIGN sid=$SESSION (not ours; not signalled)"; CLEANUP=foreign-number; self_hold "foreign occupant of session number: ownership unresolved" ;;
  *) say "CENSUS_ERROR sid=$SESSION"; self_hold "census error: unknown ownership" ;;
esac
