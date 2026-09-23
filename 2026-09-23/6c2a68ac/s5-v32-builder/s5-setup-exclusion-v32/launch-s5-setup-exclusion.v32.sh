#!/usr/bin/env bash
# OP88-S5-SETUP-EXCLUSION outer launcher v3.2 (successor of v3.1 d5d9b2b8; NOT LAUNCHED). v3.2 closes ONLY audits/s5-v31-a S5-V31-A-01: v3.1's START fallback bound the shared runner
# record by pgid=$SESSION plus a one-second UTC stamp floor (SPAWN_TS), i.e. number/time correlation that an equal-second or future-dated stale record with a reused session number could
# satisfy. v3.2 binds by EXACT identity: the runner (v101y, PIN_RUNNER updated) now publishes token=<inherited lease token> in its START line, and runner_bound accepts a START line only
# when it carries pgid=$SESSION AND token=$TOKEN; the stamp floor and SPAWN_TS are removed (no stamp is read). Markers `v3.2 (S5-V31-A-01)` in runner_bound / runner_truth, the RUNNER
# path/pin and the state line. Everything else is byte-identical to v3.1; v3.1 header follows.
# [v3.1 header, retained] OP88-S5-SETUP-EXCLUSION outer launcher v3.1 (successor of v3 a10c615f; NOT LAUNCHED). v3.1 closes ONLY audits/s5-setup-v3-b V3-B-01: an adopted runner that exits before its
# INHERITED binding line (v101x L212) left a truncated current record that v3 classified not-this-attempt -> unrecoverable unknown hold. v3.1 also accepts the runner's own START
# line when it is bound to THIS attempt: pgid=$SESSION (the outer session we created) AND stamped not before this holder's spawn (a stale record predates it). Markers `v3.1 (V3-B-01)`
# in runner_bound / runner_truth, state line (SPAWN_TS) and the spawn line. Everything else is byte-identical to v3; v3 header follows.
# [v3 header, retained] OP88-S5-SETUP-EXCLUSION outer launcher v3 (successor of v2 b32cc20d; NOT LAUNCHED). v3 closes ONLY audits/s5-setup-v2-a S5SV2-A-01 (inner evidence unavailable was reclassified as
# no inner work; inner sids were re-discovered and replaced each census) and S5SV2-A-02 (a failed corrective LEASE_RELEASE rewrite still exited with the stale receipt), plus
# audits/s5-setup-v2-b V2-B-01 (shared setup.EXIT_RECORD read without binding to this attempt's token) and V2-B-02 (prior LEASE_HOLDER / fallback SELF_HOLD overwritten, not preserved):
# see the `v3 (...)` markers in preserve_prior / inner_sids / runner_truth / session_state / release and the state line INNER_KNOWN/RSTATE. Everything else is byte-identical to v2; v2 header follows.
# [v2 header, retained] OP88-S5-SETUP-EXCLUSION outer launcher v2 (successor of v1 1773ac7d; NOT LAUNCHED; parent option (a)). Explicitly owned lease holder for the S5 setup: acquires the
# canonical lease ONCE, publishes holder identity (pid, sid, /proc start time, token, hashes) BEFORE any child exists, launches the pinned
# v101x runner through the embedded OWN-BLOCK v10.1 primitive (identity confirmed + IDENTITY published before ADOPT release), waits in THIS
# shell for the RAW runner result (separated from cleanup/publication/recovery), and releases the lease ONLY after BOTH the exact owned outer
# session AND every INNER install session the runner itself published ($EX/logs/setup-v1/attempts/*/IDENTITY with self_sid == our session; the
# npm session is created by the runner's own setsid) are positively observed EMPTY and the RELEASE record is published. v2 closes setup-exclusion
# review A S5X-A-01/02/03/05/07 and B SEB-B-01/03 for this consumer (A-06 and SEB-B-02 are harness-side: controls-exclusion v2): no handoff/transfer capability exists any more (RECOVERY_ACCEPT is never read;
# live/unknown work is never transferred), census decisions are typed over explicit sids (never registry emptiness; foreign/unknown stay unresolved),
# every release caller retains control on publication failure, RAW is latched in this shell on the signal path, PUBLICATION accumulates causes, and
# prior attempts' LEASE_RELEASE/SELF_HOLD records are preserved by token before a new holder is published. On live/foreign/unknown ownership or
# failed publication it enters an OBSERVABLE SELF-HOLD: stays alive holding fd 9, records SELF_HOLD (primary $EX, fallback $LOGS, last resort
# stderr), heartbeats every 30 s with the current typed census; it never kills itself to satisfy a duration claim. Owned children (never the holder)
# may be escalated TERM->KILL once, inside the exact owned OUTER session only; inner sessions are censused, never signalled by this holder.
# Normal bounded execution: inner `timeout -k 30 1290` around the runner + NORMAL_BOUND 1380 s here; exceptional SELF-HOLD is a distinct recorded
# state (STATE=SELF-HOLD in $EX/LEASE_HOLDER heartbeat + SELF_HOLD record). Invoke WITHOUT an outer timeout on this process:
#   setsid nohup bash launch-s5-setup-exclusion.v2.sh > $LOGS/launcher.out 2>&1 < /dev/null &
# Private fault controls run the same bytes with S5X_PRIVATE=1 and private LOCK/EX/LOGS/RUNNER (refused if any path is canonical).
set -u
[ "${S5_SETUP_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_SETUP_GRANT=granted-by-parent not set"; exit 2; }
CANON_LOCK=/home/user/workspace/execution/test-validation.lock; CANON_EX=/home/user/workspace/execution/s5-r4
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${S5X_PRIVATE:-0}" = 1 ]; then LOCK=${S5X_LOCK:?}; EX=${S5X_EX:?}; RUNNER=${S5X_RUNNER:?}; INNER_BOUND=${S5X_INNER_BOUND:-1290}; INNER_KILL=${S5X_INNER_KILL:-30}; NORMAL_BOUND=${S5X_NORMAL_BOUND:-1380}; HEARTBEAT=${S5X_HEARTBEAT:-30}
  case "$LOCK$EX" in *"$CANON_LOCK"*|*"$CANON_EX"*) echo "REFUSE: private mode may not touch canonical paths"; exit 2;; esac
else LOCK=$CANON_LOCK; EX=$CANON_EX; RUNNER="$HERE/run-s5-setup-npm-ci.v101y.sh"; INNER_BOUND=1290; INNER_KILL=30; NORMAL_BOUND=1380; HEARTBEAT=30; fi
LOGS=$EX/logs/setup-exclusion; mkdir -p "$LOGS" || exit 74; LOG=$LOGS/launcher.EXIT_RECORD; ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
say() { echo "$(ts) $*" >> "$LOG" || { echo "LAUNCHER_LOG_WRITE_FAILED $*" >&2; return 1; }; }
PIN_RUNNER=61b565e48fa4c14f765fe223bfc3a8baac27ca2867763c91e6a57135fc4ea1b3; [ "${S5X_PRIVATE:-0}" = 1 ] || { [ "$(sha256sum "$RUNNER" | cut -c1-64)" = "$PIN_RUNNER" ] || { echo "REFUSE: runner hash != $PIN_RUNNER"; exit 2; }; }   # v3.2 (S5-V31-A-01): pin = runner v101y (START publishes the inherited token); v101x was 81ff20b0
# >>> OWN-BLOCK v10.1 (successor of v10 df200b52 per audits/owned-launch-v10-a OWN-V10-A02 ONLY: leader collection is separated from session authority.
# own_finish collects the leader at the actual `wait` (pid leaves OWN_PIDS, enters OWN_RETIRED evidence; a pid is never waited twice, so no fabricated
# non-child 127 can appear as a COLLECTED rc); SESSION authority (the confirmed pgid in OWN_PGIDS) is removed by own_retire ONLY on a positively
# observed-empty (own_group_current rc1) or positively foreign (rc2) session — live (rc0) or census-error (rc3) keep it (own_retire rc2, OWN_LAST_SESSION),
# never merely because the leader is gone. own_collect therefore collects exited leaders and reports SESSION_RETIRED / SESSION_KEPT per typed census.
# Nothing else changes: byte-identical to v10 below this header except own_finish, own_collect, own_retire and the OWN_LAST_SESSION initialiser. v10 header follows.)
# [v10 header, retained] OWN-BLOCK v10 (successor of v9 9d713d2c per audits/owned-launch-v9-a A-01..A-05; v8 cc8346cd per checkpoint-2 rows 1-3 and parent ruling: bounded child-side adoption gate; byte-identical
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
OWN_PIDS=""; OWN_PGIDS=""; OWN_RETIRED=""; OWN_LAST_DECOY=""; OWN_PHASE=idle; OWN_LAST_SESSION=none
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
own_finish() { # <pid> -> OWN_FIN=observed|unobserved|not-registered|mechanism-error-subshell, OWN_FIN_RC. Call DIRECTLY in the launching shell; `wait` only after verified absence.
  # v10.1 (A02): on observed the LEADER is collected here (removed from OWN_PIDS, kept in OWN_RETIRED as evidence) — a pid is waited exactly once (a second `wait` would fabricate 127);
  # SESSION authority in OWN_PGIDS is untouched: only own_retire removes it, and only after a positively observed-empty/foreign session census.
  OWN_FIN_RC=""; [ "$BASHPID" = "$$" ] || { OWN_FIN=mechanism-error-subshell; return 2; }
  if own_alive "$1"; then OWN_FIN=unobserved; return 1; fi; case " $OWN_PIDS " in *" $1 "*) ;; *) OWN_FIN=not-registered; return 3;; esac
  wait "$1" 2>/dev/null; OWN_FIN_RC=$?; OWN_FIN=observed; own_collect_leader "$1"; return 0; }
own_collect_leader() { # <pid>: leader authority ends at the actual wait: drop from OWN_PIDS, add once to OWN_RETIRED (evidence). Never touches OWN_PGIDS (session authority).
  local p n=""; for p in $OWN_PIDS; do [ "$p" = "$1" ] || n="$n $p"; done; OWN_PIDS=$n; case " $OWN_RETIRED " in *" $1 "*) ;; *) OWN_RETIRED="$OWN_RETIRED $1";; esac; }
own_collect() { # [prefix]: in the launching shell (call directly, optionally with `>> file` — never inside $(...) or a pipe): wait (collect) every registered pid no longer alive;
  # v10.1 (A02): the exited leader's SESSION authority is retired only when own_retire positively observes it empty/foreign, otherwise it is KEPT for reap/census/recovery
  local p pre=${1:-}; for p in $OWN_PIDS; do own_alive "$p" && continue; own_finish "$p" || { echo "${pre}COLLECT_ERROR pid=$p state=$OWN_FIN"; continue; }; echo "${pre}COLLECTED pid=$p rc=$OWN_FIN_RC"
    case " $OWN_PGIDS " in *" $p "*) if own_retire "$p"; then echo "${pre}SESSION_RETIRED sid=$p ($OWN_LAST_SESSION)"; else echo "${pre}SESSION_KEPT sid=$p ($OWN_LAST_SESSION: authority retained, not resolved by leader exit)"; fi;; esac; done; return 0; }
own_record() { # <path> <content>: atomic checked publication; rc0 only when the file exists with exactly this content (tmp -> mv -> readback)
  local tmp="$1.tmp.$$"; printf '%s\n' "$2" > "$tmp" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; return 1; }
  mv -f "$tmp" "$1" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; return 2; }; [ "$(cat "$1" 2>/dev/null)" = "$2" ] || return 3; }
own_census() { # current registry truth: prints one line per active pid/group and retired id; rc1 if any LIVE owned process remains (zombies/foreign/retired never count)
  local p pg rc=0 st; for p in $OWN_PIDS; do if own_alive "$p"; then echo "${OWN_LAST_STATE^^} pid=$p identity=[$(own_identity "$p" 2>/dev/null)]"; rc=1; elif [ "$OWN_LAST_STATE" = zombie ]; then echo "ZOMBIE pid=$p (unwaited; collect)"; else echo "GONE pid=$p ($OWN_LAST_STATE)"; fi; done
  for pg in $OWN_PGIDS; do own_group_current "$pg"; st=$?; case $st in 0) echo "LIVE_SESSION sid=$pg members=[$(own_session_members "$pg" | tr '\n' ',')]"; rc=1;; 1) echo "EMPTY_SESSION sid=$pg";; 2) echo "FOREIGN_NUMBER sid=$pg (not owned, not counted)";; *) echo "CENSUS_ERROR sid=$pg (unknown: counted as unresolved)"; rc=1;; esac; done
  for p in $OWN_RETIRED; do echo "RETIRED id=$p (evidence only)"; done; return $rc; }
own_wait_gone() { local pid=$1 n=$(( $2 * 10 )) i=0; while own_alive "$pid" && [ $i -lt $n ]; do sleep 0.1; i=$((i+1)); done; ! own_alive "$pid"; }   # bounded; never `wait`
own_retire() { # <pid>: ONLY after actual `wait` or verified absence. rc1 if still alive (nothing changes). Leader authority: dropped (idempotent with own_collect_leader).
  # v10.1 (A02): SESSION authority (pid in OWN_PGIDS) is removed ONLY when own_group_current positively reports observed-empty (rc1) or foreign (rc2) => rc0,
  # OWN_LAST_SESSION=empty|foreign|none; live (rc0) or census-error (rc3) => rc2, OWN_LAST_SESSION=live|unknown, pgid KEPT (still reaped/censused; never signalled by number)
  ! own_alive "$1" || return 1; own_collect_leader "$1"; case " $OWN_PGIDS " in *" $1 "*) ;; *) OWN_LAST_SESSION=none; return 0;; esac
  own_group_current "$1"; case $? in 1) OWN_LAST_SESSION=empty;; 2) OWN_LAST_SESSION=foreign;; 0) OWN_LAST_SESSION=live; return 2;; *) OWN_LAST_SESSION=unknown; return 2;; esac
  local p n=""; for p in $OWN_PGIDS; do [ "$p" = "$1" ] || n="$n $p"; done; OWN_PGIDS=$n; }
own_reap_all() { # <grace_s>: registered pids + phase-bound pending fork; TERM -> bounded -> KILL -> 3 s bounded; census confirmed groups; rc1 on survivor
  local pid rc=0 how pg m; for pid in $OWN_PIDS $(own_pending); do own_alive "$pid" || continue   # leader/pid phase; descendants handled per confirmed group below regardless of leader liveness
    how=$(own_signal "$pid" TERM); if ! own_wait_gone "$pid" "$1"; then how="$how+KILL:$(own_signal "$pid" KILL)"; own_wait_gone "$pid" 3 || { echo "SURVIVOR pid=$pid how=$how"; rc=1; continue; }; fi
    echo "REAPED pid=$pid how=$how"; done
  for pg in $OWN_PGIDS; do own_group_current "$pg"; case $? in 1) continue;; 2) echo "GROUP_FOREIGN pgid=$pg (number reused by another session: not signalled)"; continue;; 3) echo "GROUP_CENSUS_ERROR sid=$pg (unknown: not signalled, not retired)"; rc=1; continue;; esac
    how=$(own_group_signal "$pg" TERM); own_group_wait_empty "$pg" "$1" || { how="$how+KILL:$(own_group_signal "$pg" KILL)"; own_group_wait_empty "$pg" 3 || { m=$(own_session_members "$pg"); echo "GROUP_SURVIVORS sid=$pg how=$how [${m//$'\n'/,}]"; rc=1; continue; }; }
    echo "GROUP_REAPED pgid=$pg how=$how"; done; return $rc; }
own_budget() { local b=$(( $1 - $3 - $4 )); [ "$b" -gt "$2" ] && b=$2; [ "$b" -lt 0 ] && b=0; echo "$b"; }
# <<< OWN-BLOCK v10.1

say "LAUNCHER_START pid=$$ stamp=[$(own_stamp)] launcher_sha256=$(sha256sum "$0" | cut -c1-64) runner=$RUNNER runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64) lock=$LOCK ex=$EX private=${S5X_PRIVATE:-0}" || exit 74
own_precondition || { say "REFUSE precondition (job control on or tools missing)"; exit 2; }
TOKEN="$(date -u +%Y%m%dT%H%M%SZ)-$$-$RANDOM"; START_TIME=$(cut -d' ' -f22 "/proc/$$/stat"); STATE=ACQUIRING
# ---- lease: acquire once, publish holder BEFORE any child (pre-exec ownership publication)
exec 9>"$LOCK" || { say "LEASE_OPEN_FAILED $LOCK"; exit 75; }
flock -n 9 || { say "LEASE_BUSY $LOCK (another holder; nothing launched)"; exit 75; }
# v2 (S5X-A-05): preserve any prior attempt's LEASE_RELEASE / SELF_HOLD by its token BEFORE this holder is published (mechanical mv; nothing deleted)
preserve_prior() { local f t; mkdir -p "$LOGS/prior" || { say "PRIOR_DIR_FAILED"; return 1; }
  for f in LEASE_RELEASE SELF_HOLD; do [ -e "$EX/$f" ] || continue; t=$(sed -n 's/^token=\([^ ]*\) .*/\1/p' "$EX/$f" 2>/dev/null | head -1)
    mv -f "$EX/$f" "$LOGS/prior/${t:-untagged}.$f.$(ts)" || { say "PRIOR_RECORD_PRESERVE_FAILED $EX/$f"; return 1; }; say "PRIOR_RECORD_PRESERVED $f token=${t:-untagged}"; done
  # v3 (V2-B-02): the prior holder's LEASE_HOLDER (its only record when it ended without RELEASE) and the fallback $LOGS/SELF_HOLD are preserved the same way (mv by token) instead of being overwritten
  local n; for f in "$EX/LEASE_HOLDER" "$LOGS/SELF_HOLD"; do [ -e "$f" ] || continue; t=$(sed -n 's/^token=\([^ ]*\) .*/\1/p' "$f" 2>/dev/null | head -1); n=${f##*/}; [ "$f" = "$EX/LEASE_HOLDER" ] || n=$n.fallback
    mv -f "$f" "$LOGS/prior/${t:-untagged}.$n.$(ts)" || { say "PRIOR_RECORD_PRESERVE_FAILED $f"; return 1; }; say "PRIOR_RECORD_PRESERVED $n token=${t:-untagged}"; done; }
preserve_prior || { say "PRIOR_RECORDS_NOT_PRESERVED: lease released (nothing launched)"; exit 74; }
holder_line() { echo "token=$TOKEN holder_pid=$$ holder_sid=$OWN_SELF_SID holder_pgid=$OWN_SELF_PGID start_time=$START_TIME state=$1 since=$(ts) lock=$LOCK launcher_sha256=$(sha256sum "$0" | cut -c1-64) runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64)"; }
own_record "$EX/LEASE_HOLDER" "$(holder_line HELD)" || { say "HOLDER_PUBLICATION_FAILED $EX/LEASE_HOLDER: lease released (nothing launched)"; exit 74; }
STATE=HELD; say "LEASE_HELD token=$TOKEN fd=9 holder published"
RAW=none; RAW_RC=""; CLEANUP=none; PUBLICATION=ok; RECOVERY=none; SESSION=""; ESCALATED=0; PID=""; INNER=""; RUNNER_NOTE=none; CENSUS=unknown; CENSUS_DETAIL=""
INNER_KNOWN=""; RSTATE=never-released   # v3.2 (S5-V31-A-01): v3.1's SPAWN_TS stamp floor removed (binding is by token, no stamp is read). v3 (S5SV2-A-01): inner sids once established are RETAINED here (census-only) until each is positively observed empty; RSTATE initialised before any census can run
pub_add() { case "$PUBLICATION" in ok) PUBLICATION=$1;; *"$1"*) ;; *) PUBLICATION="$PUBLICATION+$1";; esac; }   # v2 (S5X-A-07): causes accumulate, never replace
publish_state() { own_record "$EX/LEASE_HOLDER" "$(holder_line "$1")" && return 0; pub_add holder-update-failed; say "HOLDER_UPDATE_FAILED state=$1"; return 1; }
record_or_fallback() { # <name> <content>: primary $EX, fallback $LOGS, last resort stderr; accumulates PUBLICATION
  if own_record "$EX/$1" "$2"; then say "$1 published $EX/$1"; return 0; fi
  if own_record "$LOGS/$1" "$2"; then pub_add "$1-fallback"; say "$1 published FALLBACK $LOGS/$1"; return 0; fi
  pub_add "$1-failed"; echo "$(ts) $1 PUBLICATION FAILED (primary+fallback): $2" >&2; say "$1 PUBLICATION FAILED primary+fallback"; return 1; }
# v2 (S5X-A-01 / SEB-B-01): the actual install session is created by the runner's own setsid and published by the runner itself; bind by self_sid == our SESSION
INNER_LOGS=$EX/logs/setup-v1
inner_sids() { # prints inner sids bound to $SESSION (possibly none). rc0; rc2 = inner evidence UNAVAILABLE (unknown, never empty): attempts dir present but not listable, an IDENTITY present but
  # unreadable, a binding grep that errors (not a clean no-match), or a bound IDENTITY whose pid is unreadable. v3 (S5SV2-A-01): unreadable/unlistable evidence is no longer skipped as if absent.
  local f p rc=0; [ -n "$SESSION" ] || return 0
  [ -e "$INNER_LOGS/attempts" ] && { [ -r "$INNER_LOGS/attempts" ] && [ -x "$INNER_LOGS/attempts" ] || return 2; }
  for f in "$INNER_LOGS"/attempts/*/IDENTITY; do [ -e "$f" ] || continue; [ -r "$f" ] || { rc=2; continue; }; grep -q " self_sid=$SESSION " "$f" 2>/dev/null; case $? in 0) ;; 1) continue;; *) rc=2; continue;; esac
    p=$(sed -n 's/^pid=\([0-9][0-9]*\) .*/\1/p' "$f" 2>/dev/null | head -1); if [ -n "$p" ]; then echo "$p"; else rc=2; fi; done; return $rc; }
runner_bound() { # <record>: rc0 only when the shared record is THIS attempt's runner's. (a) its INHERITED line carries our token (v101y L216); or (b) v3.2 (S5-V31-A-01): a START line
  # (v101y L210, the runner's first and truncating write, before L216) carries BOTH pgid=$SESSION (the outer session we created) AND token=$TOKEN (the inherited lease token that only this
  # attempt's runner received). No stamp or number correlation is used: a stale record cannot carry this token whatever its stamp or session number. Neither form imports facts by itself.
  grep -qF -- " lease INHERITED fd=9 path=$LOCK token=$TOKEN " "$1" 2>/dev/null && return 0
  [ -n "$SESSION" ] || return 1; grep -q "^[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z START pid=[0-9][0-9]* pgid=$SESSION ppid=[0-9][0-9]* token=$TOKEN " "$1" 2>/dev/null; }
runner_truth() { # the runner's own EXIT_RECORD, evidence only (no release path is derived from it): sets RUNNER_NOTE
  local r=$INNER_LOGS/setup.EXIT_RECORD rel=0 fin=none unp=0 cf=none
  [ -e "$r" ] || { RUNNER_NOTE="exit_record=absent"; return 0; }; [ -r "$r" ] || { RUNNER_NOTE="exit_record=unreadable"; return 0; }   # v3 (S5SV2-A-01): unreadable is not absent
  runner_bound "$r" || { RUNNER_NOTE="exit_record=not-this-attempt"; return 0; }   # v3 (V2-B-01) / v3.2 (S5-V31-A-01): the shared record counts only when bound to THIS attempt by our token (INHERITED line, or START line with our session AND our token); no inherited attempt facts
  grep -q 'npm-ci IDENTITY .* state=released' "$r" 2>/dev/null && rel=1; grep -q 'EXCLUSION_UNPRESERVED' "$r" 2>/dev/null && unp=1
  fin=$(sed -n 's/^FINAL rc=\([0-9]*\).*/\1/p' "$r" 2>/dev/null | tail -1); cf=$(sed -n 's/.*CLEANUP_FAILURES=\([0-9]*\).*/\1/p' "$r" 2>/dev/null | tail -1)
  RUNNER_NOTE="released=$rel final=${fin:-none} unpreserved=$unp cleanup_failures=${cf:-none}"; }
session_state() { # typed census over the explicit outer SESSION and every inner sid bound to it -> CENSUS=empty|live|foreign|unknown, CENSUS_DETAIL, INNER. Never reads registry emptiness.
  local s st ids irc d="" live=0 foreign=0 unknown=0; runner_truth
  ids=$(inner_sids); irc=$?; [ "$irc" = 2 ] && { unknown=1; d="inner:evidence-unavailable"; }
  for s in $ids; do case " $INNER_KNOWN " in *" $s "*) ;; *) INNER_KNOWN="$INNER_KNOWN $s";; esac; done; ids=${INNER_KNOWN# }; INNER=${ids// /,}   # v3 (A-01): retained union, never replaced by a later (possibly lost) read
  case "$RUNNER_NOTE" in *released=1*) [ -n "$ids" ] || { unknown=1; d="$d inner:released-but-no-IDENTITY"; };; esac
  case "$RSTATE:$RUNNER_NOTE" in never-released:*) ;; *:exit_record=*) unknown=1; d="$d inner:${RUNNER_NOTE#exit_record=}-exit-record-after-runner-launch";; esac   # v3 (A-01/B-01): evidence absent/unreadable/not-this-attempt != never launched; only a never-adopted runner is positive no-inner-launch
  [ -n "$SESSION" ] || { if [ -z "$OWN_PIDS" ] && [ -z "$(own_pending)" ]; then d="$d outer:nothing-launched"; else unknown=1; d="$d outer:unregistered-fork"; fi; }   # no registered/pending child => positively nothing owned
  for s in $SESSION $ids; do own_group_current "$s"; st=$?
    case $st in 0) live=1; d="$d $s:live";; 1) d="$d $s:empty";; 2) foreign=1; d="$d $s:foreign";; *) unknown=1; d="$d $s:unknown";; esac; done
  CENSUS_DETAIL=${d# }; if [ $unknown = 1 ]; then CENSUS=unknown; elif [ $live = 1 ]; then CENSUS=live; elif [ $foreign = 1 ]; then CENSUS=foreign; else CENSUS=empty; fi; }
latch_raw() { # v2 (S5X-A-07): observe the runner's raw status in THIS shell as soon as absence is verified; a pid is waited once (v10.1 own_finish refuses a second wait)
  [ "$RAW" = observed ] && return 0; [ -n "$PID" ] || return 0; own_alive "$PID" && return 0
  own_finish "$PID"; case $OWN_FIN in observed) RAW=observed; RAW_RC=$OWN_FIN_RC; say "RUNNER_RAW_LATCHED $RAW rc=$RAW_RC";; not-registered) ;; *) [ "$RAW" = none ] && RAW=$OWN_FIN;; esac; return 0; }
release_line() { echo "token=$TOKEN holder_pid=$$ start_time=$START_TIME released_at=$REL_AT how=$1 raw=$RAW${RAW_RC:+ $RAW_RC} cleanup=$CLEANUP publication=$PUBLICATION recovery=$RECOVERY session=$SESSION inner=[${INNER:-none}] census=[$CENSUS_DETAIL] runner=[$RUNNER_NOTE] final_rc=$2"; }
release() { # <how> <final_rc>: ONLY after CENSUS=empty; publishes RELEASE then exits (fd 9 closes with the process). Returns 1 ONLY on publication failure: every caller must then hold.
  local how=$1 rc=$2; REL_AT=$(ts); own_record "$EX/LEASE_RELEASE" "$(release_line "$how" "$rc")" || { pub_add release-record-failed; say "RELEASE_RECORD_FAILED: holding (SELF-HOLD) instead of releasing"; return 1; }
  publish_state "RELEASED($how)" || { own_record "$EX/LEASE_RELEASE" "$(release_line "$how" "$rc")" || { pub_add release-record-rewrite-failed; say "RELEASE_RECORD_REWRITE_FAILED: receipt on disk is stale (publication=ok); holding (SELF-HOLD) instead of releasing"; return 1; }; }   # v3 (S5SV2-A-02): failed corrective write latches and the caller holds/retries; raw stays in raw=, final_rc is never 0 here
  say "LEASE_RELEASED how=$how raw=$RAW${RAW_RC:+ $RAW_RC} cleanup=$CLEANUP publication=$PUBLICATION recovery=$RECOVERY inner=[${INNER:-none}] final_rc=$rc"; exit "$rc"; }
self_hold() { # <reason>: observable retained exclusion; loops until CENSUS=empty AND RELEASE is publishable; never self-terminates. v2: NO handoff/transfer path exists.
  STATE=SELF-HOLD; publish_state SELF-HOLD; record_or_fallback SELF_HOLD "token=$TOKEN holder_pid=$$ start_time=$START_TIME since=$(ts) reason=[$1] raw=$RAW${RAW_RC:+ $RAW_RC} cleanup=$CLEANUP publication=$PUBLICATION session=$SESSION inner=[${INNER:-none}] census=[$CENSUS_DETAIL] runner=[$RUNNER_NOTE] (lease fd 9 retained until the exact outer and inner sessions are observed empty; no handoff exists; parent recovery is out of band)"
  say "SELF_HOLD reason=[$1] (heartbeat every ${HEARTBEAT}s; no self-imposed bound; no handoff)"
  while :; do latch_raw; own_collect "heartbeat " >> "$LOG"; session_state
    if [ "$CENSUS" = empty ]; then case "$PUBLICATION" in *SELF_HOLD-failed*) record_or_fallback SELF_HOLD "retry token=$TOKEN empty_at=$(ts) census=[$CENSUS_DETAIL]" && release "self-hold-then-empty" 90;; *) release "self-hold-then-empty" 90;; esac; fi
    say "HEARTBEAT state=SELF-HOLD census=$CENSUS detail=[$CENSUS_DETAIL] publication=$PUBLICATION"; publish_state SELF-HOLD >/dev/null; sleep "$HEARTBEAT"; done; }
on_signal() { trap '' TERM INT HUP; say "LAUNCHER_SIGNAL state=$STATE (lease retained; escalating owned outer session once, then verify)"; CLEANUP=signal; exceptional "signal"; }
exceptional() { # <reason>: one escalation inside the exact owned OUTER session (inner sessions censused, never signalled here), raw latched, then verify; never touches the holder
  local o rrc; o=$(own_reap_all 30); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) escalate /" >> "$LOG"; latch_raw; own_collect "escalate " >> "$LOG"; ESCALATED=1; CLEANUP="escalated(rc=$rrc)"
  session_state; say "AFTER_ESCALATION census=$CENSUS detail=[$CENSUS_DETAIL] reap_rc=$rrc raw=$RAW${RAW_RC:+ $RAW_RC}"
  [ "$CENSUS" = empty ] && [ "$rrc" = 0 ] && release "$1-then-empty" 90; self_hold "$1: census=$CENSUS reap_rc=$rrc"; }
trap on_signal TERM INT HUP
# ---- launch the runner through the primitive (identity + IDENTITY publication before ADOPT release)
OWN_ROOT="$LOGS/attempts"; mkdir -p "$OWN_ROOT" || { say "ATTEMPTS_DIR_FAILED"; release "nothing-launched" 74; say "RELEASE_RECORD_FAILED nothing launched: exit 74 (no owned work exists)"; exit 74; }
ATT=$(own_attempt) || { say "ATTEMPT_PATH_FAILED"; release "nothing-launched" 74; say "RELEASE_RECORD_FAILED nothing launched: exit 74 (no owned work exists)"; exit 74; }
STATE=LAUNCHING; publish_state LAUNCHING
own_spawn_begin
( exec setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ env S5_LEASE_INHERITED="$TOKEN" S5_SETUP_GRANT="$S5_SETUP_GRANT" timeout -k "$INNER_KILL" "$INNER_BOUND" bash "$RUNNER" ) > "$LOGS/runner.out" 2>&1 < /dev/null &
PID=$!; own_register "$PID"; SESSION=$PID
own_confirm "$PID" 2; CRC=$?; PUB=not-attempted; RSTATE=never-released
if [ "$CRC" = 0 ]; then
  if own_record "$ATT/IDENTITY" "pid=$PID attempt=${ATT##*/} identity=[$(own_identity "$PID")] holder_pid=$$ token=$TOKEN self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none}"; then PUB=$(own_adopt "$PID" "$ATT"); [ "$PUB" = published ] && RSTATE=released; else PUB=identity-publication-failed; fi; fi
say "RUNNER_LAUNCH pid=$PID confirm_rc=$CRC adoption=$PUB state=$RSTATE" || { [ "$RSTATE" = released ] && RSTATE=released-then-cancelled; pub_add launch-record-failed; }
if [ "$RSTATE" != released ]; then own_signal "$PID" TERM >/dev/null; own_wait_gone "$PID" 5 || { own_signal "$PID" KILL >/dev/null; own_wait_gone "$PID" 3; }
  own_finish "$PID"; RAW=$OWN_FIN; RAW_RC=$OWN_FIN_RC; CLEANUP=refused-$PUB; exceptional "runner-not-released($RSTATE)"; fi
STATE=RUNNING; publish_state RUNNING
# ---- normal bounded execution: wait for the runner in THIS shell (raw result), then verify the exact outer session AND every bound inner session empty
own_wait_gone "$PID" "$NORMAL_BOUND" || { say "NORMAL_BOUND_EXCEEDED ${NORMAL_BOUND}s: runner leader still alive (inner timeout should have ended it)"; }
own_finish "$PID"; RAW=$OWN_FIN; RAW_RC=$OWN_FIN_RC; say "RUNNER_RAW $RAW${RAW_RC:+ rc=$RAW_RC} (separate from cleanup/publication/recovery)"
session_state; say "SESSION_CENSUS census=$CENSUS detail=[$CENSUS_DETAIL] inner=[${INNER:-none}] runner=[$RUNNER_NOTE]"
case $CENSUS in
  empty) [ "$RAW" = observed ] && own_retire "$PID"; CLEANUP=verified-empty; release "normal" "${RAW_RC:-70}"; self_hold "release publication failed (normal; session empty)" ;;
  live) say "SESSION_LIVE after runner exit: detail=[$CENSUS_DETAIL]"; exceptional "session-live-after-runner" ;;
  foreign) say "SESSION_NUMBER_FOREIGN detail=[$CENSUS_DETAIL] (not ours; not signalled)"; CLEANUP=foreign-number; self_hold "foreign occupant of session number: ownership unresolved" ;;
  *) say "CENSUS_UNKNOWN detail=[$CENSUS_DETAIL]"; self_hold "census unknown: ownership unresolved" ;;
esac
