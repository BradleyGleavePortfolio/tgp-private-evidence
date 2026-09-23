#!/usr/bin/env bash
# OP88-S5-V10.1 T0-ONLY driver successor (of V10 2797a72a; NOT EXECUTED; V10 frozen). Corrects owned-launch-v10-a OWN-V10-A02 in this consumer ONLY:
#  the post-wait session census is a TYPED result sess=empty|live|foreign|unknown (own_group_current rc1/0/2/3, re-read after any escalation); census-error (rc3)
#  is no longer an empty string: it fails <id>.owned, blocks own_retire (so the EXIT trap still reaps/censuses that session => CENSUS_ERROR => FINAL 90) and is
#  written to the EXIT record and log as session=unknown. Session authority is removed only on sess=empty AND observed in-shell wait (own_retire re-checks).
#  Embedded OWN-BLOCK is v10.1 (byte-identical to own-block-v101.sh; verify-embedded-block.sh). Jest argv/env, gates, pins, assertions, bounds, traps, records: v10 bytes. V10 header follows.
# OP88-S5-V10 T0-ONLY driver successor (of V9 38f8ec01; NOT EXECUTED; V9 + closure immutable). Corrects owned-launch-v9-a A-01..A-04 in this consumer:
#  A-01 wait is performed in this (child-owning) shell via own_finish variables OWN_FIN/OWN_FIN_RC — never through $(...); a subshell call is a named mechanism error.
#  A-02 `trap on_exit EXIT` and TERM/INT/HUP are registered BEFORE the control root and before any spawn (the V9 derivation had dropped them).
#  A-03 required IDENTITY evidence is published (own_record, checked) BEFORE ADOPT release; failure => never released, no adoption. Every post-release
#       fatal publication path (START log, EXIT record) is latched as released-then-cancelled and routed through owned cleanup + failing check, never a bare exit.
#  A-04 records are atomic tmp->mv->readback; created-but-incomplete files are failures; primary / cleanup / publication outcomes are reported separately.
# Bounds now stated INCLUDING cleanup: budget 90 + grace 10 + KILL confirm 3 + session escalation 3 + reserve 10 <= AGG_BOUND 120 admission; EXIT-trap reap <= 13 s;
# driver end-to-end <= ~135 s; outer timeout --foreground -k 20 140 remains a nominal allowance, not a completion attestation. V9 header follows.
# OP88-S5-V9 T0-ONLY driver successor (of V8 c226266e; NOT EXECUTED). V8 and its checkpoint stay frozen. Adds the parent-approved bounded
# child-side ADOPTION GATE: the Jest workload execs only after this attempt's identity is confirmed (pgid==sid==pid, direct child, not the
# caller group) AND adoption is published to a fresh private attempt path and verified by the child; no ack/expired/parent-gone => child
# exits 75/76 with NO workload. Folds OWN-V8-A-01..A-06: phase-bound $! fallback for pre-register interruption, retire authority after actual
# wait, no `wait` on any unconfirmed-termination branch (raw exit "unobserved" is reported separately from the synthetic validation rc),
# group/descendant escalation independent of leader liveness with foreign-number refusal, reap/publication status governs the driver exit.
# New checks: <id>.identity, <id>.adoption (published AND child rc not 75/76), <id>.owned (leader observed, group empty). Attempt evidence
# (ADOPT, IDENTITY, EXIT) is retained under $OUT/attempts-<ts>/ separately from the removable control root. Bounds unchanged from V8.
# V8 header follows.
# OP88-S5-V8 T0-ONLY driver successor (of V7 ctl-t0-only.sh a13d44a5; NOT EXECUTED). Closes the inherited startup-ownership
# hole S5-V7-A-02 and the deadline/cleanup finding S5-V7-A-03 with ONE embedded OWN-BLOCK v8 (byte-identical to own-block-v8.sh):
#  A-02: the spawned pid is registered synchronously after `&` (before any sleep); the child is CONFIRMED only when pgid==sid==pid
#        and != the driver's own pgid (bounded 2 s poll); group signals are sent only to a confirmed own-session leader re-checked at
#        signal time, otherwise pid-only; the caller group is never a target; an unconfirmed identity fails check T0.identity (stop).
#        TERM/INT/HUP during the startup window now reaps by registered pid through the EXIT trap (own_reap_all).
#  A-03: admission budget = min(RUN_BUDGET, remaining - RUN_GRACE - RUN_RESERVE) so budget+grace+reserve fit inside AGG_BOUND; after
#        KILL the driver polls a bounded 3 s and, if the child is still not gone, records how=budget-KILL-unconfirmed with synthetic
#        rc 137 instead of an unconditional `wait`; survivors fail the .owned check and are censused in the EXIT trap.
# Everything else is the V7/V6 bytes: grant/QUARANTINE preconditions, HEAD/dirty-fingerprint/jest/identity/harness/config gates (rc 2
# before any child), private control root, I0, unchanged predecessor spec, fake harness 2de5fe24, config a6eeb1cd, T0.defect and
# T0.refusal_reason predicates, first-failure stop, root retention. No spec/harness/config/lib edit. Wave 6 remains FAIL; its 12 PASS
# total includes I0 and partial T3 as well as T1/T2 (not "12 T1/T2 passes"); T1/T2/T3 are not rerun.
# Bounds: RUN_BUDGET 90 + RUN_GRACE 10 + RUN_RESERVE 10 <= AGG_BOUND 120; driver end-to-end <= ~135 s incl. EXIT-trap reap (grace 10 + 3);
# recommended outer: timeout --foreground -k 20 140 (140 + 20 = nominal 160 s allowance, not a completion attestation).
# Original V7 header follows.
# OP88-S5-V7 T0-ONLY driver (successor of controls-v6-gate b7207f46; NOT EXECUTED). Derived from the exact v6 bytes by
# DELETING the T1/T2/T3 run_gate blocks (v6 L69-L81) and lowering the aggregate bound to one run; nothing else changes:
# grant/QUARANTINE preconditions, HEAD + dirty-fingerprint + jest + strict dependency identities + harness/config hash gates
# (rc 2 before any child), owned setsid group (90 s -> TERM -> 10 s -> KILL), .owned census, first-failure stop, EXIT-trap reap,
# root retention, unchanged predecessor (git show 143d451e:...), fake harness 2de5fe24 and control config a6eeb1cd.
# T1/T2 valid wave-6 observations (12 PASS, 06:06:47-52Z) are NOT repeated; T3 is closed by the separate JSON-aware read-only
# checker (check-t3-teardown.cjs) on the preserved T3 JSONL/log; wave 6 remains FAIL and immutable. This driver runs real Jest
# ONCE (predecessor spec, scenario refused-identity) and asserts T0.defect (FAILING predecessor behaviour) + T0.refusal_reason.
# Budget: 1 run <= 90 s + 10 s grace; aggregate bound 120 s; recommended outer: timeout --foreground -k 20 140.
# Original v6 header follows.
# S5 R4 Tier 2 control v6 (successor of controls-v5-gate 4d09589c; NOT EXECUTED). v6 closes audit B T2-1 with three
# named refusal-reason checks read from the Jest logs (T1/T0: identity toMatchObject received database
# not_the_disposable_db; T2: appliedMigrations toBe('164') Received: "165"), each also excluding 'Exceeded timeout',
# so rc != 0 + marker no longer classifies the refusal. Optional T2-2: a disclosed one-line dirty-fingerprint gate
# (pinned 6850b32e…) makes the driver self-attributing. Fake harness, control config and specs unchanged.
# Original v5 header follows.
# S5 R4 Tier 2 control v5 (successor of controls-v3/teardown-gate/ctl-teardown-gate.sh; NOT EXECUTED): real installed
# jest-circus hook semantics on the REAL candidate and PREDECESSOR spec texts with the byte-identical FAKE recording
# harness (no connection, no psql, no child process). v5 adds only: (a) pinned-input hash gate for the fake harness,
# control jest config and spec copies; (b) each Jest run is an OWNED child in its own process group with a budget
# (TERM -> grace -> KILL), reaped and censused before the next run; any survivor is a check failure (stop); (c) explicit
# per-run and aggregate elapsed records; (d) dependency gate: worktree node_modules from the granted setup-v1 with
# jest 30.4.2 / ts-jest 29.4.9 / typescript 5.9.3 resolved strictly inside the worktree. No spec/assertion changes.
# Requires S5_CTL_GRANT=granted-by-parent. Takes NO lock, no network, no DB, no npx, no install, no Prisma generate.
# Budget: <= 90 s per Jest run (cold ts-jest), 4 runs, aggregate bound 380 s; recommended outer: timeout --foreground -k 20 400.
source "$(dirname "${BASH_SOURCE[0]}")/../controls-v3/lib.sh"
control_preconditions
W=$CANDIDATE_WORKTREE; V3=$(cd "$(dirname "${BASH_SOURCE[0]}")/../controls-v3/teardown-gate" && pwd)
PIN_HARNESS=2de5fe248126637b28cd0687fea3e4ce43e0c1552ba6a034b21479fac088ab21
PIN_CONFIG=a6eeb1cd1797388a2f81e5b2980bcc9b62e25852e3cd9923aa8168d482ab5e71
PIN_HEAD=143d451ead6ccdbebd92ca3031ba7a89867d6cfc
PIN_DIRTY_FINGERPRINT=6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0   # v6 (T2-2, optional attribution gate)
RUN_BUDGET=90; RUN_GRACE=10; AGG_BOUND=120; RUN_RESERVE=10; T0=$(date +%s)
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
log "OWN_STAMP $(own_stamp)"; own_precondition || { log "REFUSE: job-control (set -m) active or setsid/pgrep/ps missing — identity contract unverifiable"; exit 2; }
# ---- dependency + input gates (all refusals rc 2, before any child)
[ "$(git -C "$W" rev-parse HEAD)" = "$PIN_HEAD" ] || { log "REFUSE: worktree HEAD != $PIN_HEAD"; exit 2; }
[ "$(cd "$W" && { git diff HEAD; printf '%s\n' "$(git status --porcelain --untracked-files=all)"; } | sha256sum | cut -c1-64)" = "$PIN_DIRTY_FINGERPRINT" ] || { log "REFUSE: worktree dirty fingerprint != pinned $PIN_DIRTY_FINGERPRINT (T2-2 attribution gate)"; exit 2; }
[ -x "$W/node_modules/.bin/jest" ] || { log "REFUSE: $W/node_modules/.bin/jest absent; granted setup-v1 required first"; exit 2; }
ids="$(cd "$W" && node -e 'const p=require("path");const w=process.cwd();let bad=0;for(const [m,v] of [["jest","30.4.2"],["ts-jest","29.4.9"],["typescript","5.9.3"],["jest-circus",null]]){let r;try{r=require.resolve(m+"/package.json",{paths:[w]})}catch(e){console.log("BAD "+m+" unresolved");bad++;continue}const got=require(r).version;const inside=r.startsWith(p.join(w,"node_modules")+p.sep);const ok=inside&&(!v||v===got);console.log((ok?"OK ":"BAD")+" "+m+"@"+got+" "+r);if(!ok)bad++}process.exit(bad?1:0)' 2>&1)"; idrc=$?
log "DEPENDENCY_IDENTITIES rc=$idrc"; printf '%s\n' "$ids" | while read -r l; do log "  $l"; done
[ "$idrc" = 0 ] || { log "REFUSE: strict jest/ts-jest/typescript identities not satisfied"; exit 2; }
[ "$(sha256sum "$V3/fake-harness.ts" | cut -c1-64)" = "$PIN_HARNESS" ] || { log "REFUSE: fake-harness.ts hash != pinned $PIN_HARNESS"; exit 2; }
[ "$(sha256sum "$V3/jest.control.config.js" | cut -c1-64)" = "$PIN_CONFIG" ] || { log "REFUSE: jest.control.config.js hash != pinned $PIN_CONFIG"; exit 2; }
# ---- private control root
on_exit() { local prim=$? o rrc surv=0 c; o=$(own_reap_all "$RUN_GRACE"); rrc=$?; [ -n "$o" ] && printf '%s\n' "$o" | while read -r l; do log "CLEANUP $l"; done
  own_collect > "$OUT/collect-$CTL_TS.txt"; while read -r l; do log "CLEANUP $l"; done < "$OUT/collect-$CTL_TS.txt"   # in-shell wait (function redirection is not a subshell)
  own_census | while read -r l; do log "CENSUS $l"; done; own_census >/dev/null || surv=1
  printf '%s\n' "$o" | grep -Eq 'SURVIVOR|GROUP_SURVIVORS' && surv=1
  if [ -n "${CR:-}" ]; then if [ "$surv" = 1 ] || [ "${S5_CTL_KEEP:-}" = 1 ]; then log "CONTROL_ROOT_RETAINED $CR (keep=${S5_CTL_KEEP:-0} survivors=$surv)"; else rm -rf "$CR"; fi; fi
  log "AGGREGATE_ELAPSED $(( $(date +%s) - T0 ))s primary_rc=$prim cleanup_rc=$rrc survivors=$surv publication_failures=${PUB_FAIL:-0}" || { echo "LOG_WRITE_FAILED" >&2; exit 74; }
  if [ "$rrc" != 0 ] || [ "$surv" = 1 ]; then log "FINAL rc=90 (primary_rc=$prim; cleanup failed => fail-closed)"; exit 90; fi
  if [ "${PUB_FAIL:-0}" != 0 ] && [ "$prim" = 0 ]; then log "FINAL rc=74 (primary_rc=0 but required publication failed)"; exit 74; fi; exit "$prim"; }
trap on_exit EXIT; trap 'log SIGNAL; exit 143' TERM INT HUP   # A-02: registered before the control root exists and before any spawn
PUB_FAIL=0
CR="$(mktemp -d /tmp/s5-r4-gate-XXXXXX)"; export CR
OWN_ROOT="$OUT/attempts-$CTL_TS"; mkdir -p "$OWN_ROOT" || { log "OWN_ROOT_FAILED $OWN_ROOT"; exit 74; }   # attempt evidence retained separately from $CR
mkdir -p "$CR/test/utils" "$CR/fakeroot/node_modules/.prisma/client" "$CR/fakeroot/oldroot/src/scout" "$CR/fakeroot/oldclient"
cp "$W/test/rls-g2-pg17-etq0.spec.ts" "$CR/test/candidate.spec.ts"
git -C "$W" show "$PIN_HEAD:test/rls-g2-pg17-etq0.spec.ts" > "$CR/test/predecessor.spec.ts"
cp "$W/test/utils/g2-pg17-db.ts" "$CR/test/utils/g2-pg17-db.ts"
cp "$V3/fake-harness.ts" "$CR/test/utils/g2-pg17-harness.ts"; cp "$V3/jest.control.config.js" "$CR/jest.config.js"
ln -s "$W/node_modules" "$CR/node_modules"
printf 'model ScoutReconstructionLedger {\n  id String\n}\n' > "$CR/fakeroot/oldclient/schema.prisma"
printf 'model ScoutReconstructionLedger {\n  id String\n  source_platform String?\n}\n' > "$CR/fakeroot/node_modules/.prisma/client/schema.prisma"
for f in scout-reconstruct.service.ts scout-roster.service.ts scout-entities.service.ts; do printf 'fake O service source\n' > "$CR/fakeroot/oldroot/src/scout/$f"; done
cand_sha=$(sha256sum "$CR/test/candidate.spec.ts" | cut -c1-64); wt_sha=$(sha256sum "$W/test/rls-g2-pg17-etq0.spec.ts" | cut -c1-64)
log "GATE_CONTROL_ROOT $CR candidate_spec_sha256=$cand_sha (worktree $wt_sha) predecessor_spec_sha256=$(sha256sum "$CR/test/predecessor.spec.ts" | cut -c1-64) fake_harness_sha256=$PIN_HARNESS config_sha256=$PIN_CONFIG"
check I0.inputs "$( [ "$cand_sha" = "$wt_sha" ]; echo $? )" "candidate spec copy is byte-identical to the dirty worktree file"
run_gate() { # <id> <spec> <scenario> -> GATE_RC/GATE_RAW; checks <id>.identity <id>.adoption <id>.owned; state: never-released | released | released-then-cancelled
  local rec="$OUT/gate-$CTL_TS-$1.jsonl" out="$OUT/gate-$CTL_TS-$1.jest.log" t0 pid w=0 how=exited ident crc m="" att pub=not-attempted state=never-released fin gcs sess=unknown; : > "$rec"
  local left=$((AGG_BOUND - ($(date +%s) - T0))) budget; budget=$(own_budget "$left" "$RUN_BUDGET" "$RUN_GRACE" "$RUN_RESERVE")
  [ "$budget" -ge 5 ] || { log "AGGREGATE_BOUND_HIT before $1 (left=${left}s admissible=${budget}s: budget+grace+KILL/session confirm+reserve must fit)"; GATE_RC=124; return; }
  att=$(own_attempt) || { log "$1 ATTEMPT_PATH_FAILED root=$OWN_ROOT"; GATE_RC=70; check "$1.adoption" 1 "fresh private attempt path could be created"; }
  t0=$(date +%s); own_spawn_begin
  ( cd "$CR" && exec setsid bash -c "$OWN_GATE" own-gate "$att" $$ env -i PATH="/usr/local/bin:/usr/bin:/bin" HOME="$CR" G2_CTL_ROOT="$CR" G2_CTL_RECORD="$rec" G2_CTL_FAKEROOT="$CR/fakeroot" G2_CTL_SCENARIO="$3" NODE_OPTIONS=--max-old-space-size=2048 CI=1 \
      "$W/node_modules/.bin/jest" --config "$CR/jest.config.js" --runInBand "test/$2" ) > "$out" 2>&1 < /dev/null &
  pid=$!; own_register "$pid"
  own_confirm "$pid" 2; crc=$?; case $crc in 0) ident=confirmed;; 1) ident=exited-before-confirm;; 3) ident=census-error;; *) ident=unconfirmed;; esac
  if [ "$ident" = confirmed ]; then   # A-03: required recoverable identity is published and verified BEFORE release
    if own_record "$att/IDENTITY" "pid=$pid attempt=${att##*/} pgid_sid=[$(own_identity "$pid")] self_pgid=$OWN_SELF_PGID self_sid=$OWN_SELF_SID decoy=${OWN_LAST_DECOY:-none} scenario=$3 spec=$2 budget=${budget}s"; then pub=$(own_adopt "$pid" "$att"); [ "$pub" = published ] && state=released; else pub=identity-publication-failed; PUB_FAIL=$((PUB_FAIL+1)); fi; fi
  log "$1 START pid=$pid identity=$ident adoption=$pub state=$state attempt=${att##*/}" || { PUB_FAIL=$((PUB_FAIL+1)); [ "$state" = released ] && state=released-then-cancelled; }
  if [ "$state" != released ]; then how=refused-$pub; own_signal "$pid" TERM >/dev/null; own_wait_gone "$pid" 5 || { own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; }; fi
  while [ "$state" = released ] && own_alive "$pid" && [ $w -lt "$budget" ]; do sleep 1; w=$((w+1)); done
  if [ "$state" = released ] && own_alive "$pid"; then how=budget-TERM; own_signal "$pid" TERM >/dev/null; own_wait_gone "$pid" "$RUN_GRACE" || { how=budget-KILL; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; }; fi
  own_finish "$pid"; fin="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; GATE_RAW=$fin   # A-01: wait in THIS shell; observed only after verified absence
  case $OWN_FIN in observed) GATE_RC=$OWN_FIN_RC;; unobserved) GATE_RC=137; how=$how-unconfirmed;; *) GATE_RC=70; how=$how-wait-mechanism-error;; esac
  own_group_current "$pid"; gcs=$?; if [ "$gcs" = 0 ]; then own_group_signal "$pid" TERM >/dev/null; own_group_wait_empty "$pid" 2 || { own_group_signal "$pid" KILL >/dev/null; own_group_wait_empty "$pid" 1; }; own_group_current "$pid"; gcs=$?; fi
  case $gcs in 1) sess=empty; m="";; 0) sess=live; m=$(own_session_members "$pid"); [ -n "$m" ] || m="live-members-unlisted";; 2) sess=foreign; m="foreign-group-not-signalled";; *) sess=unknown; m="census-error-session-unresolved";; esac   # A02 (V10.1): typed; unknown is never empty
  own_record "$att/EXIT" "raw=$fin validation_rc=$GATE_RC how=$how state=$state session=$sess survivors=[${m//$'\n'/,}]" || { PUB_FAIL=$((PUB_FAIL+1)); log "$1 EXIT_RECORD_PUBLICATION_FAILED $att"; }
  [ "$OWN_FIN" = observed ] && [ "$sess" = empty ] && own_retire "$pid"   # A-02(V8)+A02(V10.1): session authority removed only after actual in-shell wait AND positively observed-empty session (own_retire re-checks)
  log "$1 EXIT raw=$fin validation_rc=$GATE_RC how=$how identity=$ident adoption=$pub state=$state session=$sess elapsed=$(( $(date +%s) - t0 ))s record_lines=$(wc -l < "$rec") survivors=[${m//$'\n'/,}] publication_failures=$PUB_FAIL (nonzero jest rc is EXPECTED: beforeAll throws)"
  check "$1.identity" "$( [ "$ident" = confirmed ]; echo $? )" "jest child confirmed as its own session/group leader and direct child (never the caller group) within 2 s"
  check "$1.adoption" "$( [ "$state" = released ] && [ "$GATE_RC" != 75 ] && [ "$GATE_RC" != 76 ] && [ "$PUB_FAIL" = 0 ] && [ -s "$att/IDENTITY" ] && [ -s "$att/EXIT" ]; echo $? )" "identity published before release, adoption published/verified on fresh path, workload released (rc not 75/76), no publication failure, complete IDENTITY/EXIT records"
  check "$1.owned" "$( [ "$sess" = empty ] && [ "$how" = exited ] && [ "$OWN_FIN" = observed ]; echo $? )" "jest child exit observed by in-shell wait within budget and its session POSITIVELY observed empty (live/foreign/census-error never count as empty)"
}
mut() { grep -c '"mutating":true' "$1"; }
run_gate T0 predecessor.spec.ts refused-identity; R="$OUT/gate-$CTL_TS-T0.jsonl"
check T0.defect "$( [ "$(mut "$R")" -ge 2 ] && grep -q 'DROP CONSTRAINT IF EXISTS g2p_target_refusal' "$R" && grep -q '"fn":"resetData"' "$R"; echo $? )" "PREDECESSOR refused-identity: $(mut "$R") mutating teardown calls recorded (frozen S5-R3-A-01 under real Jest hook semantics; FAILING behaviour)"
check T0.refusal_reason "$( J="$OUT/gate-$CTL_TS-T0.jest.log"; grep -q 'not_the_disposable_db' "$J" && grep -q 'toMatchObject' "$J" && ! grep -q 'Exceeded timeout' "$J"; echo $? )" "PREDECESSOR beforeAll failed at the identity toMatchObject (received database not_the_disposable_db), not a hook timeout; the mutating teardown followed that refusal (T2-1)"
summary
