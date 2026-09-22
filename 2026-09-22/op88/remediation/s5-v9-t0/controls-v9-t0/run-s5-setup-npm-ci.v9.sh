#!/usr/bin/env bash
# OP88-S5-V9 ADDITIVE SETUP SUCCESSOR of V8 bca83158 (v1 74736a58 and V8 preserved; NOT LAUNCHED). Parent-approved bounded child-side
# ADOPTION GATE: `npm ci` execs only after this attempt's identity is confirmed and adoption is published to a fresh private attempt path
# under $LOGS/attempts and verified by the child; otherwise the child exits 75/76 and NO install runs. Folds OWN-V8-A-01..A-06: phase-bound
# $! fallback, retire after actual wait, no `wait` on unconfirmed termination (RC synthetic 137, raw "unobserved" recorded), group/descendant
# escalation independent of leader liveness with foreign-number refusal, and fail-closed exclusion: any unverified termination writes
# $EX/QUARANTINE (the existing control precondition path that refuses later runs) BEFORE finish, so the lease is never released as clean
# with owned work possibly alive. Identity/EXIT/FINAL record writes are checked (rc 74 on failure). npm ci command/env/pins unchanged. V8 header follows.
# OP88-S5-V8 ADDITIVE SETUP SUCCESSOR of frozen setup-v1 74736a58 (NOT LAUNCHED; original preserved byte-identical). Closes
# P88-S5-SETUP-01 (same class as S5-V7-A-02/A-03): v1 L90-91 spawned npm ci, slept 0.2 s, then sampled the pgid; a TERM in that
# window reached on_signal with CUR_PGID empty (no reap), and a pre-setsid sample could adopt the runner's OWN group as signal target.
# v8 embeds the SAME OWN-BLOCK v8 as ctl-t0-only.v8.sh (byte-identical): register the pid synchronously after `&`; confirm
# pgid==sid==pid and != self pgid within 2 s or die rc 2 (startup-identity-unconfirmed) after pid-only TERM/KILL; on_signal reaps
# every registered pid regardless of CUR_PGID; group signals only to the re-confirmed own-session leader; bounded waits with no
# unconditional `wait` after an unconfirmed KILL (synthetic rc 137 => die). Everything else (pins, gates, lock fd 9, --ignore-scripts,
# ancestor gate, FIRST_EXIT/FINAL, after-checks, external timeout -k 30 1290 = 1200 budget + 30 grace + 2 confirm + <=13 reap + checks
# + accounting, a nominal allowance not a completion attestation) is the v1 bytes. Original v1 header follows.
# S5-R4 TIER2 SETUP-ONLY V1 — proportionate adaptation of the audited S6 setup 91fe0f1b (run-c5-setup-npm-ci.v3.sh):
# exactly one `npm ci --ignore-scripts` from the committed backend lockfile in the isolated s5-r4 worktree.
# Adapted ONLY: backend pins (HEAD 143d451e, lock blob 354de3da), the EXPECTED dirty patch (2 test files, fingerprint
# 6850b32e… before AND after), `--ignore-scripts` (skips `postinstall: prisma generate` and `prepare: lefthook install`:
# no Prisma engine download, no hook install, no hidden installation), and the strict identity list
# (jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, jest-circus, jest-runtime, @jest/core, babel-jest, @babel/core,
# @prisma/client 6.19.3 package present without a generated client). Mechanics (owned pgid, budget TERM/KILL,
# fail-closed reap, ancestor gate, lock fd closed in child, FIRST_EXIT vs FINAL) are unchanged from 91fe0f1b.
# NOT LAUNCHED until the parent grants it. No tests, no scripts, no Prisma generate, no hooks, no commit.
# Invoke (parent-granted; external bound 1200 s install + 60 s cleanup + 30 s kill margin):
#   mkdir -p /home/user/workspace/execution/s5-r4/logs/setup-v1 && \
#   setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/s5-r4/setup-v1/run-s5-setup-npm-ci.v1.sh \
#     > /home/user/workspace/execution/s5-r4/logs/setup-v1/run-setup.out 2>&1 < /dev/null &
set -u
WT=/home/user/workspace/worktrees/s5-r4
EX=/home/user/workspace/execution/s5-r4
LOGS=$EX/logs/setup-v1
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/setup.EXIT_RECORD
PIN_HEAD=143d451ead6ccdbebd92ca3031ba7a89867d6cfc
PIN_LOCK_BLOB=354de3dae19449970497da6e4d87f0a1225a8f43
PIN_DIRTY_FINGERPRINT=6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0
PIN_DIRTY_STATUS=$' M test/rls-g2-pg17-etq0.spec.ts\n M test/utils/g2-pg17-bootstrap.sh'
INSTALL_BUDGET=1200; INSTALL_GRACE=30
START=$(date +%s)
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
CPU="taskset -c 0,1"
OWNED_PGIDS=""; CUR_PID=""; CUR_PGID=""; FIRST_EXIT=""; CLEANUP_FAILURES=0; ACCOUNTED=0
# >>> OWN-BLOCK v9 (successor of v8 cc8346cd per checkpoint-2 rows 1-3 and parent ruling: bounded child-side adoption gate; byte-identical
# in ctl-t0-only.v9.sh and run-s5-setup-npm-ci.v9.sh; controls source this file). Consumer MUST set OWN_ROOT (private evidence dir) first.
# Contract: workload execs only after (a) current-attempt identity confirmed pgid==sid==pid, direct child, not self group and (b) adoption
# published to a FRESH private attempt path and verified by the child (content == "<child pid> <attempt token>"); no ack / expired / parent
# gone => child exits 75/76 without workload. Trap recovery covers pre-spawn, after-fork-before-register and interrupted-adoption phases via
# phase-bound, direct-child-verified $!. Authority is retired explicitly after actual wait; retired numeric ids are never signalled.
# Folds OWN-V8-A-01..A-06 (audits/owned-launch-v8-a): descendant/group authority survives leader exit but only while the group is still
# the session we created (every member sid==pgid), unconfirmed termination never reaches `wait` (own_finish), reap/publication status
# is returned to the consumer to govern its exit. Folds S6 review B Part B: R3 job-control mode is stamped and refused (under `set -m` the
# background child is a group leader, `setsid` forks and $! names an exited intermediate; v9 also fail-closes there because the gate child's
# $$ never matches the published pid), and zombie members are excluded from group liveness (no false SURVIVOR before `wait`).
OWN_SELF_PGID=$(ps -o pgid= -p $$ | tr -d ' '); OWN_SELF_SID=$(ps -o sid= -p $$ | tr -d ' ')
OWN_PIDS=""; OWN_PGIDS=""; OWN_RETIRED=""; OWN_LAST_DECOY=""; OWN_PHASE=idle
# child-side gate: bash -c "$OWN_GATE" own-gate <attempt-dir> <parent-pid> <workload...>; polls 0.05 s up to 100x (5 s); 76 if parent gone, 75 if never adopted
OWN_GATE='a=$1; p=$2; shift 2; i=0; while :; do kill -0 "$p" 2>/dev/null || exit 76; [ -r "$a/ADOPT" ] && [ "$(cat "$a/ADOPT" 2>/dev/null)" = "$$ ${a##*/}" ] && break; i=$((i+1)); [ "$i" -ge 100 ] && exit 75; sleep 0.05; done; exec "$@"'
own_stamp() { echo "monitor=$([[ -o monitor ]] && echo on || echo off) bash=$BASH_VERSION setsid=[$(setsid --version 2>&1 | head -1)] timeout=[$(timeout --version 2>&1 | head -1)] ps=[$(ps --version 2>&1 | head -1)]"; }
own_precondition() { [[ -o monitor ]] && return 1; command -v setsid >/dev/null && command -v pgrep >/dev/null && command -v ps >/dev/null; }   # refuse job-control mode / missing tools
own_attempt() { local d; d=$(mktemp -d "$OWN_ROOT/attempt-XXXXXX" 2>/dev/null) || return 1; [ -d "$d" ] && [ ! -e "$d/ADOPT" ] || return 1; echo "$d"; }   # fresh private path per attempt
own_spawn_begin() { OWN_PHASE=spawning; }                                          # the command immediately BEFORE the `... &` line
own_register() { OWN_PIDS="$OWN_PIDS $1"; OWN_PHASE=registered; }                 # the command immediately AFTER `&`, with $!
own_is_child() { [ "$(ps -o ppid= -p "$1" 2>/dev/null | tr -d ' ')" = "$$" ]; }   # numeric id is authoritative only while it is our direct child
own_identity() { ps -o pgid= -o sid= -p "$1" 2>/dev/null | tr -s ' ' | sed 's/^ //;s/ $//'; }
own_alive() { own_is_child "$1" || return 1; [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != Z ]; }
own_pending() { # phase-bound fallback for a fork whose register line never ran: $! only while OWN_PHASE=spawning, live direct child, not registered/retired
  [ "$OWN_PHASE" = spawning ] || return 0; local p=${!:-}; [ -n "$p" ] || return 0
  case " $OWN_PIDS $OWN_RETIRED " in *" $p "*) return 0;; esac; own_alive "$p" && echo "$p"; return 0; }
own_confirm() { # <pid> [max_s=2]: rc0 confirmed (pgid==sid==pid, direct child, not self group; added to OWN_PGIDS); rc1 gone; rc2 unconfirmed
  local pid=$1 n=$(( ${2:-2} * 20 )) i=0 id pg sid
  while :; do own_is_child "$pid" || return 1; id=$(own_identity "$pid"); [ -z "$id" ] && return 1; pg=${id% *}; sid=${id#* }
    if [ "$pg" = "$pid" ] && [ "$sid" = "$pid" ] && [ "$pg" != "$OWN_SELF_PGID" ]; then OWN_PGIDS="$OWN_PGIDS $pg"; return 0; fi
    [ "$pg" = "$OWN_SELF_PGID" ] && OWN_LAST_DECOY="$pg"
    i=$((i+1)); [ $i -ge $n ] && return 2; sleep 0.05; done; }
own_adopt() { # <pid> <attempt>: publish after own_confirm rc0 ONLY. prints published|publication-write-failed|publication-rename-failed|publication-readback-mismatch; rc1 on any failure
  local pid=$1 a=$2 want="$1 ${2##*/}" tmp="$2/ADOPT.tmp"
  printf '%s' "$want" > "$tmp" 2>/dev/null || { echo publication-write-failed; return 1; }
  mv -f "$tmp" "$a/ADOPT" 2>/dev/null || { rm -f "$tmp" 2>/dev/null; echo publication-rename-failed; return 1; }
  [ "$(cat "$a/ADOPT" 2>/dev/null)" = "$want" ] || { echo publication-readback-mismatch; return 1; }; echo published; }
own_signal() { # <pid> <SIG>: no signal unless current direct child; group only if identity re-confirmed now; prints group|pid|gone|notchild
  local pid=$1 sig=$2 id pg sid; own_is_child "$pid" || { echo notchild; return 0; }; id=$(own_identity "$pid"); [ -z "$id" ] && { echo gone; return 0; }; pg=${id% *}; sid=${id#* }
  if [ "$pg" = "$pid" ] && [ "$sid" = "$pid" ] && [ "$pg" != "$OWN_SELF_PGID" ]; then kill "-$sig" -- "-$pg" 2>/dev/null; echo group; else kill "-$sig" "$pid" 2>/dev/null; echo pid; fi; }
own_session_members() { ps -eo pid=,sid=,stat= 2>/dev/null | awk -v s="$1" '$2==s && substr($3,1,1)!="Z"{print $1}'; }   # live members of the session we created (sid == confirmed leader pid), any process group (e.g. timeout re-groups)
own_group_current() { # <sid/pgid>: rc0 session still has live members; rc1 none; rc2 the pgid NUMBER now has members outside our session (reused/foreign: never signal)
  local m p; m=$(pgrep -g "$1" 2>/dev/null || true); for p in $m; do [ "$(ps -o stat= -p "$p" 2>/dev/null | cut -c1)" = Z ] && continue; [ "$(ps -o sid= -p "$p" 2>/dev/null | tr -d ' ')" = "$1" ] || return 2; done
  [ -n "$(own_session_members "$1")" ] || return 1; }
own_group_signal() { # <sid> <SIG>: signal every process group of OUR session (each group verified to contain only session members); prints group[:n]|empty|refused
  case " $OWN_PGIDS " in *" $1 "*) ;; *) echo refused; return 0;; esac; [ "$1" != "$OWN_SELF_PGID" ] && [ "$1" != "$OWN_SELF_SID" ] || { echo refused; return 0; }
  own_group_current "$1"; case $? in 1) echo empty; return 0;; 2) echo refused; return 0;; esac
  local p g n=0 ok; for g in $(for p in $(own_session_members "$1"); do ps -o pgid= -p "$p" 2>/dev/null | tr -d ' '; done | sort -u); do
    ok=1; for p in $(pgrep -g "$g" 2>/dev/null); do [ "$(ps -o sid= -p "$p" 2>/dev/null | tr -d ' ')" = "$1" ] || ok=0; done
    [ "$ok" = 1 ] && [ "$g" != "$OWN_SELF_PGID" ] && { kill "-$2" -- "-$g" 2>/dev/null; n=$((n+1)); }; done; echo "group:$n"; }
own_group_wait_empty() { local n=$(( $2 * 10 )) i=0; while own_group_current "$1" >/dev/null 2>&1 && [ $i -lt $n ]; do sleep 0.1; i=$((i+1)); done; ! own_group_current "$1" >/dev/null 2>&1; }
own_finish() { # <pid>: `wait` ONLY when the child is verifiably not alive (exited/zombie). prints "observed <rc>" or "unobserved"; never blocks on a live child
  if own_alive "$1"; then echo unobserved; return 1; fi; local rc; wait "$1" 2>/dev/null; rc=$?; echo "observed $rc"; }
own_wait_gone() { local pid=$1 n=$(( $2 * 10 )) i=0; while own_alive "$pid" && [ $i -lt $n ]; do sleep 0.1; i=$((i+1)); done; ! own_alive "$pid"; }   # bounded; never `wait`
own_retire() { # <pid>: ONLY after actual `wait` or verified absence; removes signal authority (pid and its group), keeps evidence elsewhere. rc1 if still alive
  ! own_alive "$1" || return 1; local p n=""; for p in $OWN_PIDS; do [ "$p" = "$1" ] || n="$n $p"; done; OWN_PIDS=$n
  n=""; for p in $OWN_PGIDS; do [ "$p" = "$1" ] || n="$n $p"; done; OWN_PGIDS=$n; OWN_RETIRED="$OWN_RETIRED $1"; }
own_reap_all() { # <grace_s>: registered pids + phase-bound pending fork; TERM -> bounded -> KILL -> 3 s bounded; census confirmed groups; rc1 on survivor
  local pid rc=0 how pg m; for pid in $OWN_PIDS $(own_pending); do own_alive "$pid" || continue   # leader/pid phase; descendants handled per confirmed group below regardless of leader liveness
    how=$(own_signal "$pid" TERM); if ! own_wait_gone "$pid" "$1"; then how="$how+KILL:$(own_signal "$pid" KILL)"; own_wait_gone "$pid" 3 || { echo "SURVIVOR pid=$pid how=$how"; rc=1; continue; }; fi
    echo "REAPED pid=$pid how=$how"; done
  for pg in $OWN_PGIDS; do own_group_current "$pg"; case $? in 1) continue;; 2) echo "GROUP_FOREIGN pgid=$pg (number reused by another session: not signalled)"; continue;; esac
    how=$(own_group_signal "$pg" TERM); own_group_wait_empty "$pg" "$1" || { how="$how+KILL:$(own_group_signal "$pg" KILL)"; own_group_wait_empty "$pg" 3 || { m=$(own_session_members "$pg"); echo "GROUP_SURVIVORS sid=$pg how=$how [${m//$'\n'/,}]"; rc=1; continue; }; }
    echo "GROUP_REAPED pgid=$pg how=$how"; done; return $rc; }
own_budget() { local b=$(( $1 - $3 - $4 )); [ "$b" -gt "$2" ] && b=$2; [ "$b" -lt 0 ] && b=0; echo "$b"; }
# <<< OWN-BLOCK v9

ts() { date -u +%FT%TZ; }
rec() { echo "$(ts) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s ${3:-}" >> "$EXIT_RECORD"; }
alive() { kill -0 "$1" 2>/dev/null || return 1; [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != "Z" ]; }
ancestor_inventory() { ( cd /home/user/node_modules 2>/dev/null && ls -A --time-style=+%s -l | awk '{print $6, $7}' | sort ) | sha256sum | cut -d' ' -f1; }
dirty_fingerprint() { ( cd "$WT" && { git diff HEAD; printf '%s\n' "$(git status --porcelain --untracked-files=all)"; } | sha256sum | cut -c1-64 ); }
reap_group() { local pg=$1 grace=$2 label=$3
  case " $OWNED_PGIDS " in *" $pg "*) ;; *) echo "$(ts) REFUSE reap of unowned pgid=$pg ($label)" >> "$EXIT_RECORD"; return 2;; esac
  local m; m=$(pgrep -g "$pg" || true); [ -z "$m" ] && { echo "$(ts) cleanup label=$label pgid=$pg members=none cleanup_exit=0" >> "$EXIT_RECORD"; return 0; }
  echo "$(ts) cleanup label=$label pgid=$pg TERM members=[${m//$'\n'/,}]" >> "$EXIT_RECORD"; kill -TERM -- "-$pg" 2>/dev/null
  local i=0; while [ $i -lt "$grace" ] && pgrep -g "$pg" >/dev/null 2>&1; do sleep 1; i=$((i+1)); done
  if pgrep -g "$pg" >/dev/null 2>&1; then echo "$(ts) cleanup label=$label pgid=$pg KILL" >> "$EXIT_RECORD"; kill -KILL -- "-$pg" 2>/dev/null; sleep 1; fi
  m=$(pgrep -g "$pg" || true); [ -n "$m" ] && { echo "$(ts) cleanup label=$label SURVIVORS=[${m//$'\n'/,}] cleanup_exit=1" >> "$EXIT_RECORD"; return 1; }
  echo "$(ts) cleanup label=$label pgid=$pg members=none cleanup_exit=0" >> "$EXIT_RECORD"; return 0; }
final_accounting() {
  [ "$ACCOUNTED" = 1 ] && return; ACCOUNTED=1
  if [ -n "${ANCESTOR_BEFORE:-}" ]; then local a; a=$(ancestor_inventory)
    if [ "$a" = "$ANCESTOR_BEFORE" ]; then echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a UNCHANGED" >> "$EXIT_RECORD"
    else echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a CHANGED — GATE FAILED (this runner never writes there)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; fi
  local pg; for pg in $OWNED_PGIDS; do local m; m=$(pgrep -g "$pg" || true); echo "$(ts) final owned pgid=$pg members=[${m//$'\n'/,}]" >> "$EXIT_RECORD"; [ -n "$m" ] && CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); done
  echo "$(ts) CLEANUP_FAILURES=$CLEANUP_FAILURES" >> "$EXIT_RECORD"
  ( cd "$WT" 2>/dev/null && echo "$(ts) dirty_fingerprint_after=$(dirty_fingerprint) status_lines=$(git status --porcelain | wc -l) node_modules_present=$([ -d node_modules ] && echo yes || echo no) hooks_pre_commit=$([ -e .git/hooks/pre-commit ] && echo PRESENT || echo absent) generated_client=$([ -d node_modules/.prisma/client ] && echo PRESENT || echo absent)" >> "$EXIT_RECORD" )
  local p; for p in $OWN_PIDS; do echo "$(ts) final registered pid=$p alive=$(own_alive "$p" && echo YES || echo no) identity=[$(own_identity "$p")]" >> "$EXIT_RECORD"; own_alive "$p" && CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); done
  echo "$(ts) lock held until exit (fd 9)" >> "$EXIT_RECORD"; }
quarantine() { { echo "QUARANTINE $(ts) setup-v9 $1"; echo "worktree=$WT lock_path=$LOCK (lease released by exit; owned work may remain: no run may start here until parent clears)"; } >> "$EX/QUARANTINE" 2>/dev/null || echo "$(ts) QUARANTINE_WRITE_FAILED $EX/QUARANTINE" >> "$EXIT_RECORD"; echo "$(ts) QUARANTINE written $EX/QUARANTINE" >> "$EXIT_RECORD"; }
finish() { final_accounting
  if [ "$CLEANUP_FAILURES" -gt 0 ]; then echo "FINAL rc=$(( $1 == 0 ? 90 : $1 )) (primary rc=$1 in FIRST_EXIT; CLEANUP_FAILURES=$CLEANUP_FAILURES => fail-closed; node_modules state must be treated as unverified)" >> "$EXIT_RECORD"; [ "$1" -eq 0 ] && exit 90 || exit "$1"; fi
  echo "FINAL rc=$1" >> "$EXIT_RECORD" || { echo "FINAL_RECORD_WRITE_FAILED" >&2; exit 74; }; exit "$1"; }
on_signal() { trap '' TERM INT HUP; echo "$(ts) RUNNER-SIGNAL child_pid=${CUR_PID:-none} pgid=${CUR_PGID:-none}" >> "$EXIT_RECORD"
  local o rrc; o=$(own_reap_all 20); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) runner-signal /" >> "$EXIT_RECORD"   # v9: registered pids + phase-bound pending fork + confirmed groups (descendants), never CUR_PGID-dependent
  if [ "$rrc" != 0 ]; then CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "runner-signal unverified termination: $(printf '%s' "$o" | grep -E 'SURVIVOR|GROUP_SURVIVORS' | tr '\n' ';')"; fi
  [ -n "$FIRST_EXIT" ] || FIRST_EXIT="npm-ci rc=143 how=runner-signal"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) install INCOMPLETE; node_modules state undefined — report, do not retry without a new grant" >> "$EXIT_RECORD"; finish 143; }
trap on_signal TERM INT HUP; trap final_accounting EXIT
die() { rec "$1" "$2" "${3:-}"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$1 rc=$2 how=exited"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; finish "$2"; }

mkdir -p "$LOGS/npm-logs"
echo "$(ts) OWN_STAMP $(own_stamp)" >> "$EXIT_RECORD" || { echo STAMP_WRITE_FAILED >&2; exit 74; }; own_precondition || die precondition-job-control-or-tools 2 "set -m active or setsid/pgrep/ps missing"
echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID runner_sha256=$(sha256sum "$0" | cut -c1-64)" > "$EXIT_RECORD"
exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"
cd "$WT" || die cd 1
[ "$PWD" = "$WT" ] || die cwd 1

# provenance before (dirty patch is EXPECTED and pinned; anything else is a refusal)
ANCESTOR_BEFORE=$(ancestor_inventory); DIRTY_BEFORE=$(dirty_fingerprint)
{ echo "cwd=$PWD"; echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"
  echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"; echo "lock_sha256=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "package_json_sha256=$(sha256sum package.json | cut -d' ' -f1)"; echo "lockfileVersion=$(grep -m1 '"lockfileVersion"' package-lock.json)"
  echo "dirty_fingerprint_before=$DIRTY_BEFORE (expected $PIN_DIRTY_FINGERPRINT)"
  echo "node=$(node -v) node_path=$(command -v node) npm=$(npm -v) npm_path=$(command -v npm)"
  echo "node_modules_present_before=$([ -d node_modules ] && echo yes || echo no) hooks_pre_commit_before=$([ -e .git/hooks/pre-commit ] && echo PRESENT || echo absent)"
  echo "ancestor_package_json_absent=$([ ! -e /home/user/package.json ] && echo yes || echo NO)"
  echo "ancestor_node_modules=$(ls -ld /home/user/node_modules 2>&1) entries=$(ls -A /home/user/node_modules 2>/dev/null | wc -l) inventory_before=$ANCESTOR_BEFORE (platform-owned; read-only for this runner)"
  echo "npm_cache=$(npm config get cache 2>/dev/null)"; echo "registry=$(npm config get registry 2>/dev/null)"
  echo "npm_debug_log_dir_before=$(ls /home/user/.npm/_logs 2>/dev/null | wc -l) files"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/setup.provenance.txt" 2>&1
[ "$(git rev-parse HEAD)" = "$PIN_HEAD" ] || die provenance-head 2
[ "$(git ls-files -s package-lock.json | awk '{print $2}')" = "$PIN_LOCK_BLOB" ] || die provenance-lock-blob 2
[ "$(git status --porcelain)" = "$PIN_DIRTY_STATUS" ] || die provenance-dirty-status-not-the-pinned-patch 2
[ "$DIRTY_BEFORE" = "$PIN_DIRTY_FINGERPRINT" ] || die provenance-dirty-fingerprint 2
[ ! -d node_modules ] || die provenance-node-modules-already-present-one-install-only 2
[ ! -e /home/user/package.json ] || die provenance-ancestor-package-json-present 2
rec provenance 0

# the one install, in its own owned process group, lifecycle scripts ignored, raw npm logs kept in the evidence dir
OWN_ROOT="$LOGS/attempts"; mkdir -p "$OWN_ROOT" || die attempts-dir 74; ATT=$(own_attempt) || die attempt-path 74 "fresh private attempt path could not be created under $OWN_ROOT"
own_spawn_begin
setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ $CPU npm ci --no-audit --no-fund --ignore-scripts --loglevel=error --logs-dir="$LOGS/npm-logs" --logs-max=10 > "$LOGS/setup.npm-ci.out" 2>&1 < /dev/null 9>&- &
CUR_PID=$!; own_register "$CUR_PID"
own_confirm "$CUR_PID" 2; IDRC=$?; PUB=not-attempted; [ "$IDRC" = 0 ] && PUB=$(own_adopt "$CUR_PID" "$ATT")
printf 'pid=%s identity_rc=%s pgid_sid=[%s] self_pgid=%s decoy=%s adoption=%s\n' "$CUR_PID" "$IDRC" "$(own_identity "$CUR_PID")" "$OWN_SELF_PGID" "${OWN_LAST_DECOY:-none}" "$PUB" > "$ATT/IDENTITY" || PUB=identity-record-failed
echo "$(ts) npm-ci IDENTITY attempt=${ATT##*/} $(cat "$ATT/IDENTITY" 2>/dev/null)" >> "$EXIT_RECORD" || { echo IDENTITY_RECORD_WRITE_FAILED >&2; exit 74; }
if [ "$PUB" != published ]; then own_signal "$CUR_PID" TERM >/dev/null; own_wait_gone "$CUR_PID" 5 || { own_signal "$CUR_PID" KILL >/dev/null; own_wait_gone "$CUR_PID" 3; }
  FIN=$(own_finish "$CUR_PID"); [ "${FIN%% *}" = observed ] && own_retire "$CUR_PID" || { CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "adoption refused and termination unverified pid=$CUR_PID"; }
  die startup-adoption-refused 2 "identity_rc=$IDRC adoption=$PUB raw=$FIN; npm ci never released (child gate exits 75/76); caller group never signalled"; fi
CUR_PGID=$CUR_PID; OWNED_PGIDS="$CUR_PGID"                       # confirmed + adopted: the child IS its own session/group leader; install released
echo "$(ts) npm-ci START child_pid=$CUR_PID child_pgid=$CUR_PGID budget=${INSTALL_BUDGET}s grace=${INSTALL_GRACE}s cmd=[npm ci --no-audit --no-fund --ignore-scripts --loglevel=error]" >> "$EXIT_RECORD"
w=0; while own_alive "$CUR_PID" && [ $w -lt "$INSTALL_BUDGET" ]; do sleep 2; w=$((w+2)); done
HOW=exited
if own_alive "$CUR_PID"; then HOW=budget-TERM; echo "$(ts) npm-ci BUDGET reached: TERM owned $(own_signal "$CUR_PID" TERM) pid=$CUR_PID" >> "$EXIT_RECORD"
  own_wait_gone "$CUR_PID" "$INSTALL_GRACE" || { HOW=budget-KILL; own_signal "$CUR_PID" KILL >/dev/null; own_wait_gone "$CUR_PID" 3 || HOW=budget-KILL-unconfirmed; }; fi
FIN=$(own_finish "$CUR_PID"); if [ "${FIN%% *}" = observed ]; then RC=${FIN#* }; else RC=137; HOW=$HOW-unconfirmed; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "npm-ci termination unverified pid=$CUR_PID how=$HOW"; fi   # v9 A-04: wait only after verified absence
printf 'raw=%s validation_rc=%s how=%s\n' "$FIN" "$RC" "$HOW" > "$ATT/EXIT" || { echo "$(ts) EXIT_RECORD_WRITE_FAILED $ATT" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }
echo "$(ts) npm-ci first_exit rc=$RC how=$HOW npm_logs=[$(ls "$LOGS/npm-logs" 2>/dev/null | tr '\n' ',')]" >> "$EXIT_RECORD"
GO=$(own_group_signal "$CUR_PGID" TERM); own_group_wait_empty "$CUR_PGID" 10 || { GO="$GO+KILL:$(own_group_signal "$CUR_PGID" KILL)"; own_group_wait_empty "$CUR_PGID" 3; }
if own_group_current "$CUR_PGID"; then CE=1; quarantine "post:npm-ci descendants survive pgid=$CUR_PGID [$(own_session_members "$CUR_PGID" | tr '\n' ',')]"; else CE=0; fi
echo "$(ts) npm-ci cleanup_exit=$CE group_signal=$GO" >> "$EXIT_RECORD"; [ "$CE" -eq 0 ] || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); [ "$CE" -eq 0 ] && [ "${FIN%% *}" = observed ] && own_retire "$CUR_PID"; CUR_PID=""; CUR_PGID=""
FIRST_EXIT="npm-ci rc=$RC how=$HOW"
[ "$RC" -eq 0 ] || die npm-ci "$RC" "how=$HOW (node_modules may be partial: report; no retry)"

# provenance after: dirty patch unchanged (node_modules is gitignored), lockfile unchanged, strict identities, no hooks, no generated client
{ echo "tree_status_after:"; git status --porcelain; echo "lock_sha256_after=$(sha256sum package-lock.json | cut -d' ' -f1)"; echo "dirty_fingerprint_after=$(dirty_fingerprint)"
  echo "node_modules_top_entries=$(ls -A node_modules | wc -l)"; echo "node_modules_bytes=$(du -sb node_modules 2>/dev/null | cut -f1)"
  echo "node_modules_package_lock_sha256=$(sha256sum node_modules/.package-lock.json 2>/dev/null | cut -c1-64)"
  echo "bins: $(cd node_modules/.bin 2>/dev/null && ls jest tsc eslint prettier lefthook prisma 2>&1 | tr '\n' ' ')"
  echo "generated_client_absent=$([ ! -d node_modules/.prisma/client ] && echo yes || echo NO) hooks_pre_commit=$([ -e .git/hooks/pre-commit ] && echo PRESENT || echo absent)"; } > "$LOGS/setup.after.txt" 2>&1
[ "$(git status --porcelain)" = "$PIN_DIRTY_STATUS" ] || die after-dirty-status-changed 6
[ "$(dirty_fingerprint)" = "$PIN_DIRTY_FINGERPRINT" ] || die after-dirty-fingerprint-changed 6
[ ! -e .git/hooks/pre-commit ] || die after-hooks-installed-despite-ignore-scripts 6
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
const want={"jest":"30.4.2","ts-jest":"29.4.9","typescript":"5.9.3","@prisma/client":"6.19.3","prisma":"6.19.3","lefthook":"2.1.9","eslint":"10.5.0"};
for (const m of ["jest","jest-circus","jest-runtime","@jest/core","ts-jest","typescript","babel-jest","@babel/core","@prisma/client","prisma","lefthook","eslint"]) {
  let r; try { r=require.resolve(m+"/package.json",{paths:[wt]}); } catch(e){ console.log(`BAD ${m} unresolved`); bad++; continue; }
  const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep); const pinOk=!(m in want)||want[m]===v;
  console.log(`${inside&&pinOk?"OK ":"BAD"} ${m}@${v}${m in want?" (pin "+want[m]+")":""} ${r}`); if(!inside||!pinOk) bad++; }
try { require.resolve("prettier/package.json",{paths:[wt]}); console.log("NOTE prettier resolves (unexpected: not in application lock)"); } catch(e){ console.log("NOTE prettier absent from application lock (expected; hook-formatter resolution is a separate grant)"); }
process.exit(bad?1:0)' "$WT" > "$LOGS/setup.module-paths.txt" 2>&1 || die after-strict-resolution 5
rec after-checks 0
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) primary setup rc=0 (node_modules present in $WT; pinned dirty patch unchanged; strict identities OK; no hooks; no generated client) — FINAL decided by cleanup/ancestor gates" >> "$EXIT_RECORD"
finish 0
