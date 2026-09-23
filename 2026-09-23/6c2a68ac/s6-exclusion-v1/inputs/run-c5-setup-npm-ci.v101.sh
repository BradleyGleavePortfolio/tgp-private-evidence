#!/usr/bin/env bash
# OP88-S6-SETUP-ADAPT V10.1 — ADDITIVE SETUP SUCCESSOR of the audited S6 setup v3 91fe0f1b (run-c5-setup-npm-ci.v3.sh; original preserved byte-identical;
# NOT LAUNCHED; no grant implied). Mechanical consumer adaptation to the UNCHANGED OWN-BLOCK v10.1 (4aebf96f…, embedded byte-identical between the
# `# >>> OWN-BLOCK v10.1` / `# <<< OWN-BLOCK v10.1` markers) with the already-reviewed S5 V10.1 setup consumer semantics (run-s5-setup-npm-ci.v101.sh
# 5f94783b…) mapped line for line: closes C6_SETUP_CORRECTION_REQUEST §3 R1 (child lost on TERM in the spawn→sleep 0.2→ps sample window: the pid is
# registered synchronously after `&` and the signal trap reaps registered/pending/confirmed ownership, never CUR_PGID-dependent), R2 (a sampled caller
# PGID could be signalled: identity is confirmed pgid==sid==pid, direct child, != self group BEFORE release; no ps-sample fallback to a number),
# R3 (job-control mode: OWN_STAMP records monitor mode + setsid/timeout/ps versions and own_precondition REFUSES `set -m`) and S6_C6_REVIEW_B Part B
# (b) single-pid TERM/KILL when only the pid is known (own_reap_all/own_signal), (c) phase-bound $! fallback (own_pending), (d) `wait` in THIS shell
# only after verified absence (own_finish; zombies are not survivors). The `npm ci` is released ONLY after the adoption gate (identity confirmed,
# IDENTITY record published and checked, ADOPT published and verified by the gate child); otherwise the gate child exits 75/76 and NO install runs.
# Every post-release fatal path goes through `die` (reap → collect → census → quarantine marker → finish). final_accounting uses the CURRENT registry
# census; historical OWNED_PGIDS is evidence only; legacy reap_group removed (unused).
# UNCHANGED from 91fe0f1b: paths (WT/EX/LOGS/LOCK), npm ci argv/env/pins (the S5 consumer's --ignore-scripts is an S5-backend choice and is NOT carried over;
# the v3 argv is kept byte-identical), lock fd 9 (+ 9>&- in the child), provenance gates (HEAD d51a1910, clean tree, node_modules absent, ancestor package.json absent),
# ancestor-inventory gate, budgets (1200 s + 30 s grace), after-checks (clean tree, strict 20-module resolution), FIRST_EXIT vs FINAL semantics, rc 90 fail-closed.
# LAST-EXCLUSION BOUNDARY (explicitly mapped, NOT claimed safe — see ../docs/FINDINGS_AND_APPLICABILITY.md §5): when NO quarantine marker can be written
# (primary $EX/QUARANTINE, fallback $LOGS/QUARANTINE) while owned work is unresolved, this consumer copies the reviewed S5 V10 behaviour: hold the lease
# (fd 9) polling the census for HOLD_BOUND s, then exit FINAL 90 with EXCLUSION_UNPRESERVED recorded. That branch releases the lease with owned work
# possibly alive; it is the known residual boundary of this consumer class (S5 setup-exclusion slice, separate owner), inherited here UNCHANGED and
# reported, not solved. No wrapper/launcher is built in this packet.
# External bound unchanged: timeout -k 30 1290 = 1200 budget + 30 grace + 2 confirm + <=13 reap + checks + accounting (nominal allowance, not a completion attestation).
# Invoke (parent-granted ONLY; identical shape to v3, new script path):
#   mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/setup-v3 && \
#   setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/e8d546f9/s6-owned-launch-v101/run-c5-setup-npm-ci.v101.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/setup-v3/run-setup.out 2>&1 < /dev/null &
# Original v3 header follows.
# C5-S6 SETUP-ONLY V3 — successor of 6fa69510… closing the parent's two allocation questions and B-04:
#   (1) a nonzero post-install reap_group (cleanup_exit) or any owned survivor now FAILS CLOSED (FINAL rc 90 when the
#       primary npm rc was 0); the primary rc stays in FIRST_EXIT. V2 line 82 only logged cleanup_exit.
#   (2) ancestor-inventory equality (/home/user/node_modules names+mtimes) is now a GATE, not a report: CHANGED => FINAL != 0.
#   (3) lock fd 9 closed in the npm child (9>&-), so a quarantined survivor cannot keep the canonical lock.
#   Everything else (one install, guards, budgets, raw npm logs, strict resolution) unchanged from V2.
# C5-S6 SETUP-ONLY — exactly one `npm ci` from the committed lockfile on d51 in the isolated worktree.
# NOT LAUNCHED until the parent grants it. Runs no tests, no scripts of ours, touches nothing outside $WT/node_modules
# (+ npm's own cache under $HOME/.npm and the raw npm logs redirected into our evidence dir).
# Invoke (parent-granted; external bound 1200 s install + 60 s cleanup margin):
#   mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/setup-v3 && \
#   setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/s6-diagnostic/v3/run-c5-setup-npm-ci.v3.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/setup-v3/run-setup.out 2>&1 < /dev/null &
# Guards: canonical lock held by this runner (fd 9) through cleanup; cwd == $WT; HEAD == d51; tree clean before;
# node_modules ABSENT before (one install, never a second); /home/user/package.json absent; the platform-owned
# /home/user/node_modules (pre-existing, 212 links, Sep 20) is inventoried before/after and must be UNCHANGED —
# it is never deleted, moved or treated as a project install. After: tree still clean, node_modules present,
# lockfile unchanged, STRICT resolution of relevant modules into $WT/node_modules recorded.
set -u
WT=/home/user/workspace/worktrees/s6-diagnostic
EX=/home/user/workspace/execution/s6-diagnostic
LOGS=$EX/logs/setup-v3
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/setup.EXIT_RECORD
INSTALL_BUDGET=1200; INSTALL_GRACE=30
START=$(date +%s)
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
CPU="taskset -c 0,1"
OWNED_PGIDS=""; CUR_PID=""; CUR_PGID=""; FIRST_EXIT=""; CLEANUP_FAILURES=0; ACCOUNTED=0

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

ts() { date -u +%FT%TZ; }
rec() { echo "$(ts) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s ${3:-}" >> "$EXIT_RECORD"; }
alive() { kill -0 "$1" 2>/dev/null || return 1; [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != "Z" ]; }
ancestor_inventory() { ( cd /home/user/node_modules 2>/dev/null && ls -A --time-style=+%s -l | awk '{print $6, $7}' | sort ) | sha256sum | cut -d' ' -f1; }
final_accounting() {
  [ "$ACCOUNTED" = 1 ] && return; ACCOUNTED=1
  if [ -n "${ANCESTOR_BEFORE:-}" ]; then local a; a=$(ancestor_inventory)
    if [ "$a" = "$ANCESTOR_BEFORE" ]; then echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a UNCHANGED" >> "$EXIT_RECORD"
    else echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a CHANGED — GATE FAILED (this runner never writes there)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; fi
  echo "$(ts) historical owned_pgids=[$OWNED_PGIDS] (evidence only, not current facts)" >> "$EXIT_RECORD"; own_collect "$(ts) final " >> "$EXIT_RECORD"; own_census | sed "s/^/$(ts) final census /" >> "$EXIT_RECORD"; own_census >/dev/null || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1))
  echo "$(ts) CLEANUP_FAILURES=$CLEANUP_FAILURES" >> "$EXIT_RECORD"
  ( cd "$WT" 2>/dev/null && echo "$(ts) tree_status_lines=$(git status --porcelain | wc -l) node_modules_present=$([ -d node_modules ] && echo yes || echo no)" >> "$EXIT_RECORD" )
  echo "$(ts) lock held until exit (fd 9)" >> "$EXIT_RECORD"; }
HOLD_BOUND=${HOLD_BOUND:-60}; QUAR_STATE=none
quarantine() { # <reason>: checked exclusion marker; QUAR_STATE=written|fallback|failed. On failed with unresolved ownership: hold the lease and poll (bounded), then FINAL 90 exclusion=unpreserved (KNOWN RESIDUAL BOUNDARY, mapped in docs/FINDINGS_AND_APPLICABILITY.md §5; not claimed safe)
  local body="QUARANTINE $(ts) s6-setup-v101 $1"$'\n'"worktree=$WT lock_path=$LOCK (lease released by exit; owned work may remain: no run may start here until parent clears)"
  if own_record "$EX/QUARANTINE" "$body"; then QUAR_STATE=written; elif own_record "$LOGS/QUARANTINE" "$body"; then QUAR_STATE=fallback; else QUAR_STATE=failed; fi
  echo "$(ts) QUARANTINE state=$QUAR_STATE reason=[$1]" >> "$EXIT_RECORD"; echo "QUARANTINE state=$QUAR_STATE $1" >&2
  if [ "$QUAR_STATE" = failed ]; then local h=0; echo "$(ts) EXCLUSION_HOLD: no marker writable; holding lock fd 9 up to ${HOLD_BOUND}s while ownership unresolved" >> "$EXIT_RECORD"
    while ! own_census >/dev/null 2>&1 && [ $h -lt "$HOLD_BOUND" ]; do sleep 2; h=$((h+2)); done; own_census >/dev/null 2>&1 && echo "$(ts) EXCLUSION_HOLD released after ${h}s: ownership resolved" >> "$EXIT_RECORD" || { echo "$(ts) EXCLUSION_UNPRESERVED after ${h}s: owned work unresolved and no marker written — parent boundary (known residual; lease released by exit)" >> "$EXIT_RECORD"; echo "EXCLUSION_UNPRESERVED" >&2; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }; fi; }
finish() { final_accounting
  if [ "$CLEANUP_FAILURES" -gt 0 ]; then echo "FINAL rc=$(( $1 == 0 ? 90 : $1 )) (primary rc=$1 in FIRST_EXIT; CLEANUP_FAILURES=$CLEANUP_FAILURES => fail-closed; node_modules state must be treated as unverified)" >> "$EXIT_RECORD"; [ "$1" -eq 0 ] && exit 90 || exit "$1"; fi
  echo "FINAL rc=$1" >> "$EXIT_RECORD" || { echo "FINAL_RECORD_WRITE_FAILED" >&2; exit 74; }; exit "$1"; }
on_signal() { trap '' TERM INT HUP; echo "$(ts) RUNNER-SIGNAL child_pid=${CUR_PID:-none} pgid=${CUR_PGID:-none}" >> "$EXIT_RECORD"
  local o rrc; o=$(own_reap_all 20); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) runner-signal /" >> "$EXIT_RECORD"   # R1/R2/Part B(b)(c): registered pids + phase-bound pending fork + confirmed groups (descendants), never CUR_PGID-dependent, never a sampled number
  own_collect "$(ts) runner-signal " >> "$EXIT_RECORD"; if [ "$rrc" != 0 ] || ! own_census >/dev/null; then CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "runner-signal: ownership unresolved after reap: $(printf '%s' "$o" | grep -E 'SURVIVOR|GROUP_SURVIVORS|CENSUS_ERROR' | tr '\n' ';')"; fi
  [ -n "$FIRST_EXIT" ] || FIRST_EXIT="npm-ci rc=143 how=runner-signal"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) install INCOMPLETE; node_modules state undefined — report, do not retry without a new grant" >> "$EXIT_RECORD"; finish 143; }
trap on_signal TERM INT HUP; trap final_accounting EXIT
die() { if [ -n "$OWN_PIDS$OWN_PGIDS" ] || [ "$OWN_PHASE" = spawning ]; then local o rrc; o=$(own_reap_all 20); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) die-cleanup /" >> "$EXIT_RECORD"; own_collect "$(ts) die-cleanup " >> "$EXIT_RECORD"; if [ "$rrc" != 0 ] || ! own_census >/dev/null; then CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "die step=$1 rc=$2: ownership unresolved after reap"; fi; fi
  rec "$1" "$2" "${3:-}"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$1 rc=$2 how=exited"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; finish "$2"; }

mkdir -p "$LOGS/npm-logs"
echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID runner_sha256=$(sha256sum "$0" | cut -c1-64)" > "$EXIT_RECORD"
echo "$(ts) OWN_STAMP $(own_stamp)" >> "$EXIT_RECORD" || { echo STAMP_WRITE_FAILED >&2; exit 74; }; own_precondition || die precondition-job-control-or-tools 2 "set -m active or setsid/pgrep/ps missing"   # R3 / Part B stamp required
exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"
cd "$WT" || die cd 1
[ "$PWD" = "$WT" ] || die cwd 1

# provenance before
ANCESTOR_BEFORE=$(ancestor_inventory)
{ echo "cwd=$PWD"; echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"
  echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"; echo "lock_sha256=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "package_json_sha256=$(sha256sum package.json | cut -d' ' -f1)"; echo "lockfileVersion=$(grep -m1 '"lockfileVersion"' package-lock.json)"
  echo "node=$(node -v) node_path=$(command -v node) npm=$(npm -v) npm_path=$(command -v npm)"
  echo "node_modules_present_before=$([ -d node_modules ] && echo yes || echo no)"
  echo "ancestor_package_json_absent=$([ ! -e /home/user/package.json ] && echo yes || echo NO)"
  echo "ancestor_node_modules=$(ls -ld /home/user/node_modules 2>&1) entries=$(ls -A /home/user/node_modules 2>/dev/null | wc -l) inventory_before=$ANCESTOR_BEFORE (platform-owned; read-only for this runner)"
  echo "npm_cache=$(npm config get cache 2>/dev/null)"; echo "registry=$(npm config get registry 2>/dev/null)"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/setup.provenance.txt" 2>&1
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -z "$(git status --porcelain)" ] || die provenance-tree-not-clean 2
[ ! -d node_modules ] || die provenance-node-modules-already-present-one-install-only 2
[ ! -e /home/user/package.json ] || die provenance-ancestor-package-json-present 2
rec provenance 0

# the one install, in its own owned session/process group behind the adoption gate, raw npm logs kept in evidence dir (argv unchanged from v3)
OWN_ROOT="$LOGS/attempts"; mkdir -p "$OWN_ROOT" || die attempts-dir 74; ATT=$(own_attempt) || die attempt-path 74 "fresh private attempt path could not be created under $OWN_ROOT"
own_spawn_begin
setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ $CPU npm ci --no-audit --no-fund --loglevel=error --logs-dir="$LOGS/npm-logs" --logs-max=10 > "$LOGS/setup.npm-ci.out" 2>&1 < /dev/null 9>&- &
CUR_PID=$!; own_register "$CUR_PID"
own_confirm "$CUR_PID" 2; IDRC=$?; PUB=not-attempted; STATE=never-released
if [ "$IDRC" = 0 ]; then   # required recoverable identity published and verified BEFORE release
  if own_record "$ATT/IDENTITY" "pid=$CUR_PID attempt=${ATT##*/} pgid_sid=[$(own_identity "$CUR_PID")] self_pgid=$OWN_SELF_PGID self_sid=$OWN_SELF_SID decoy=${OWN_LAST_DECOY:-none} budget=${INSTALL_BUDGET}s grace=${INSTALL_GRACE}s"; then PUB=$(own_adopt "$CUR_PID" "$ATT"); [ "$PUB" = published ] && STATE=released; else PUB=identity-publication-failed; fi; fi
echo "$(ts) npm-ci IDENTITY attempt=${ATT##*/} identity_rc=$IDRC adoption=$PUB state=$STATE" >> "$EXIT_RECORD" || { [ "$STATE" = released ] && STATE=released-then-cancelled; die post-release-record-failed 74 "EXIT_RECORD append failed after state=$STATE (die reaps/quarantines before finish)"; }
if [ "$STATE" != released ]; then own_signal "$CUR_PID" TERM >/dev/null; own_wait_gone "$CUR_PID" 5 || { own_signal "$CUR_PID" KILL >/dev/null; own_wait_gone "$CUR_PID" 3; }
  own_finish "$CUR_PID"; FIN="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; [ "$OWN_FIN" = observed ] && own_retire "$CUR_PID"
  die startup-adoption-refused 2 "identity_rc=$IDRC adoption=$PUB raw=$FIN state=$STATE (never released: the gate child exits 75/76 without npm ci; caller group never signalled)"; fi
CUR_PGID=$CUR_PID; OWNED_PGIDS="$CUR_PGID"                       # confirmed + identity published + adopted: install released (OWNED_PGIDS kept as historical evidence only)
echo "$(ts) npm-ci START child_pid=$CUR_PID child_pgid=$CUR_PGID budget=${INSTALL_BUDGET}s grace=${INSTALL_GRACE}s cmd=[npm ci --no-audit --no-fund --loglevel=error]" >> "$EXIT_RECORD"
w=0; while own_alive "$CUR_PID" && [ $w -lt "$INSTALL_BUDGET" ]; do sleep 2; w=$((w+2)); done
HOW=exited
if own_alive "$CUR_PID"; then HOW=budget-TERM; echo "$(ts) npm-ci BUDGET reached: TERM owned $(own_signal "$CUR_PID" TERM) pid=$CUR_PID" >> "$EXIT_RECORD"
  own_wait_gone "$CUR_PID" "$INSTALL_GRACE" || { HOW=budget-KILL; own_signal "$CUR_PID" KILL >/dev/null; own_wait_gone "$CUR_PID" 3 || HOW=budget-KILL-unconfirmed; }; fi
own_finish "$CUR_PID"; FIN="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; case $OWN_FIN in observed) RC=$OWN_FIN_RC;; unobserved) RC=137; HOW=$HOW-unconfirmed; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "npm-ci termination unverified pid=$CUR_PID how=$HOW";; *) RC=70; HOW=$HOW-wait-mechanism-error; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1));; esac   # Part B (d): wait in THIS shell, only after verified absence
own_record "$ATT/EXIT" "raw=$FIN validation_rc=$RC how=$HOW state=$STATE" || { echo "$(ts) EXIT_RECORD_PUBLICATION_FAILED $ATT" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }
echo "$(ts) npm-ci first_exit rc=$RC how=$HOW npm_logs=[$(ls "$LOGS/npm-logs" 2>/dev/null | tr '\n' ',')]" >> "$EXIT_RECORD"
GO=$(own_group_signal "$CUR_PGID" TERM); own_group_wait_empty "$CUR_PGID" 10 || { GO="$GO+KILL:$(own_group_signal "$CUR_PGID" KILL)"; own_group_wait_empty "$CUR_PGID" 3; }
own_group_current "$CUR_PGID"; case $? in 0) CE=1; quarantine "post:npm-ci descendants survive sid=$CUR_PGID [$(own_session_members "$CUR_PGID" | tr '\n' ',')]";; 1) CE=0;; 2) CE=0; echo "$(ts) post:npm-ci foreign occupant of number $CUR_PGID (not owned, not signalled)" >> "$EXIT_RECORD";; *) CE=1; quarantine "post:npm-ci census error sid=$CUR_PGID (unknown ownership)";; esac
echo "$(ts) npm-ci cleanup_exit=$CE group_signal=$GO" >> "$EXIT_RECORD"; [ "$CE" -eq 0 ] || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); [ "$CE" -eq 0 ] && [ "$OWN_FIN" = observed ] && own_retire "$CUR_PID"; CUR_PID=""; CUR_PGID=""
FIRST_EXIT="npm-ci rc=$RC how=$HOW"
[ "$RC" -eq 0 ] || die npm-ci "$RC" "how=$HOW (node_modules may be partial: report; no retry)"

# provenance after: clean tree, lockfile unchanged, strict resolution into $WT/node_modules, versions
{ echo "tree_status_after:"; git status --porcelain; echo "lock_sha256_after=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "node_modules_top_entries=$(ls -A node_modules | wc -l)"; echo "node_modules_bytes=$(du -sb node_modules 2>/dev/null | cut -f1)"
  echo "npm_ls_summary: $(npm ls --depth=0 2>/dev/null | tail -1)"; } > "$LOGS/setup.after.txt" 2>&1
[ -z "$(git status --porcelain)" ] || die after-tree-not-clean 6
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest","jest-circus","jest-runtime","@jest/core","babel-jest","@babel/core","babel-preset-expo","zustand","scheduler"]) {
  let r; try { r=require.resolve(m+"/package.json",{paths:[wt]}); } catch(e){ console.log(`BAD ${m} unresolved`); bad++; continue; }
  const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/setup.module-paths.txt" 2>&1 || die after-strict-resolution 5
rec after-checks 0
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) primary setup rc=0 (node_modules present in $WT; tree clean; strict resolution OK) — FINAL decided by cleanup/ancestor gates" >> "$EXIT_RECORD"
finish 0
