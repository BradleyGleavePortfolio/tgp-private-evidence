#!/usr/bin/env bash
# OP88-S6-C6-EXCLUSION runner variant v101y (ADDITIVE successor of the frozen S6 C6 consumer run-c6-hazard-v5-conly.v101.sh 2c9748a4; original preserved byte-identical; NOT LAUNCHED;
# no grant implied). ONLY deltas, mirroring the accepted S5 V32 runner v101y 61b565e4 contract onto this consumer (S6_EXCLUSION_SCOPE_MAP H-R1 + H-R2 + S5-V31-A-01 START token):
# (1) the START line (first, truncating write of c6.EXIT_RECORD) additionally publishes token=${S6_LEASE_INHERITED:-none}; (2) when S6_LEASE_INHERITED=<token> is set the runner verifies
# fd 9 already open on $LOCK, that $EX/LEASE_HOLDER names the same token and a live holder pid, writes the ` lease INHERITED fd=9 path=$LOCK token=<t> holder_pid=<p> ` binding line and
# does NOT flock (else branch = the v101 L342-L344 bytes incl. its lock-busy text; every gate child still gets 9>&-); (3) the per-step IDENTITY record starts `pid=<p> step=<s> attempt=…`
# (field ORDER only; content unchanged) so the launcher's anchored `^pid=` read binds both the selftest and the C attempt. The runner's HOLD_BOUND/EXCLUSION_UNPRESERVED branch remains as
# evidence but is no longer a release path under the launcher. Everything else is the v101 bytes: OWN-BLOCK v10.1 4aebf96f byte-identical, frozen C6 packet MANIFEST.c6.sha256 check,
# hazard v5/adapter/instrument/classifier, Jest argv/selection/budgets, selftest-then-C sequencing, die/quarantine/finish. Under the launcher the invoke line below is REPLACED by
# launch-s6-c6-exclusion.v1.sh (setsid nohup bash <launcher>; no outer timeout on the holder; frozen observer f140787a unused). v101 header follows.
# [v101 header, retained] OP88-S6-C6-RUNNER-ADAPT V10.1 — ADDITIVE successor of the frozen C6 runner 746e244d (run-c6-hazard-v5-conly.sh; original preserved byte-identical;
# NOT LAUNCHED; no grant implied). Mechanical consumer adaptation of the inherited V3.1 spawn/sleep/sample class (run_owned, on_signal, reap_group,
# final_accounting) to the UNCHANGED OWN-BLOCK v10.1 (4aebf96f…, embedded byte-identical between the `# >>> OWN-BLOCK v10.1` / `# <<< OWN-BLOCK v10.1`
# markers) with the already-reviewed S5 V10.1 consumer semantics (ctl-t0-only.v101.sh run_gate / run-s5-setup-npm-ci.v101.sh) mapped per line:
#   R1  child lost on TERM in `& ; sleep 0.2 ; ps` window  -> pid registered synchronously after `&` (own_register); on_signal/die reap registered pids,
#       the phase-bound pending fork (own_pending, Part B (c)) and every confirmed session, never CUR_PGID-dependent (Part B (b): single-pid TERM/KILL when
#       only the pid is known is own_signal's `pid` path).
#   R2  ps-sampled PGID could be the caller's own group -> identity confirmed pgid==sid==pid, direct child, != self pgid BEFORE release (own_confirm);
#       no numeric fallback; groups are signalled only after re-confirmation; foreign numbers are refused, never signalled.
#   R3  job-control (`set -m`) assumption -> OWN_STAMP (monitor mode + setsid/timeout/ps versions) written to c6.EXIT_RECORD and own_precondition REFUSES
#       monitor mode (die rc 2) before the lock is taken (Part B "stamp required").
#   (d) `wait` in THIS shell only after verified absence (own_finish); zombies are not survivors; unconfirmed termination => synthetic rc 137 + quarantine.
#   Each step's workload execs ONLY after the adoption gate (identity confirmed, IDENTITY record published+checked, ADOPT published+verified by the gate
#   child under $LOGS/attempts/attempt-XXXXXX); otherwise the gate child exits 75/76 and NO workload runs (die rc 2). Post-step census is TYPED
#   (session=empty|live|foreign|unknown); session authority is retired only on observed in-shell wait AND positively empty session. Every fatal path goes
#   through `die` (reap -> collect -> census -> quarantine marker -> finish). final_accounting uses the CURRENT registry census; historical OWNED_PGIDS is
#   evidence only; legacy reap_group removed (unused). M-1 (stop after cleanup survivors, rc 90) kept; FIRST_EXIT/FINAL semantics kept.
# UNCHANGED from 746e244d: paths (WT, C6, DIAG, IN, LOGS, LOCK), MANIFEST.c6.sha256 check of the frozen packet (instrument/inputs/classifier/observer/original
# runner bytes), provenance/HEAD/porcelain gates, strict 20-module resolution, hazard v5 a91bb732 + adapter 3796be8f fingerprint gates, Jest argv/env/
# selection, budgets (selftest 15+5, C 90+20, BUDGET 180, external 240+30), selftest + C ONLY (no A/B/D), no --forceExit/--detectOpenHandles, classifier
# c6classify.js and the C6-OUTCOME line, hash-guarded copy removal, ancestor-inventory gate. Neither FINAL 143 nor FINAL 0 is acceptance.
# LAST-EXCLUSION BOUNDARY (explicitly mapped, NOT claimed safe — ../docs/FINDINGS_AND_APPLICABILITY.md §5): if NO quarantine marker can be written
# (primary $EX/QUARANTINE, fallback $LOGS/QUARANTINE) while owned work is unresolved, this consumer copies the reviewed S5 V10 behaviour: hold the lease
# (fd 9) polling the census for HOLD_BOUND s, then exit FINAL 90 with EXCLUSION_UNPRESERVED recorded — that branch releases the lease with owned work
# possibly alive and is the known residual boundary of this consumer class (separate owner); inherited here UNCHANGED and reported, not solved.
# The external `timeout -k 30 240` of the frozen observer bounds any hold anyway; the observer (f140787a…, not edited here) still names the ORIGINAL runner
# path — launching THIS runner requires the parent to re-point that one path (mapped in docs, not done here).
# Records added to c6.EXIT_RECORD: `OWN_STAMP …`, per step `IDENTITY attempt=… identity_rc=… adoption=… state=…`, `cleanup_exit=<n> session=<typed> group_signal=…`,
# `final census …` lines (replace `final owned pgid=… members=[…]`); attempt evidence under $LOGS/attempts/attempt-*/{IDENTITY,ADOPT,EXIT}.
# Invoke (parent-granted ONLY; identical shape, new runner path; observer re-point is a separate one-line change NOT made here):
#   mkdir -p /home/user/workspace/execution/op88/s6-c6-prep/logs/c6 && \
#   setsid nohup timeout -k 30 240 bash /home/user/workspace/execution/e8d546f9/s6-owned-launch-v101/run-c6-hazard-v5-conly.v101.sh \
#     > /home/user/workspace/execution/op88/s6-c6-prep/logs/c6/run-c6.out 2>&1 < /dev/null &
# Original C6 header follows (its Invoke line describes the ORIGINAL runner path).
# C6-S6-HAZARD-V5-C-ONLY — additive wrapper derived from the frozen V3.1 runner (b7b328a5…0776), which is NOT altered.
#   Purpose (OP88-S6-C6-PREP, after frozen S6_C5_REVIEW_B.md §8): one C step only, hazard v5 (= v4 ee9b94df + `await
#   qc.queryClient.cancelQueries()` before the existing clear() in afterEach and afterAll; nothing else) with the UNCHANGED
#   adapter 3796be8f… and the UNCHANGED v3.1 instrument set (main.js cf470101…, hooks, summarize) verified by MANIFEST.c6.sha256.
#   Differences from V3.1, all declared (see ../DIFF_runner_v3.1_to_c6.patch and ../S6_C6_PREP.md §4):
#     paths  : packet dir C6=/home/user/workspace/execution/op88/s6-c6-prep/c6 (inputs/, diag/, MANIFEST.c6.sha256, c6classify.js);
#              logs in /home/user/workspace/execution/op88/s6-c6-prep/logs/c6 with prefix `c6.`; WT and LOCK unchanged.
#     steps  : selftest (instrument fit in the fresh install) then C only. A/B/D are NOT repeated (C5 A/B/D clean exits stand).
#     inputs : two declared untracked copies (hazard v5 + adapter); v5 fingerprint a91bb732… replaces the v4 gate ee9b94df….
#     budget : C 90 s + 20 s grace and selftest 15 s + 5 s UNCHANGED; inner BUDGET 180 (was 360, five steps); external 240 + 30.
#     outcome: the V3.1 line "C exited on its own => C-PERTURBATION-DIVERGENCE" is REPLACED by the pre-declared C6 outcome
#              classifier (c6classify.js): (i) 2 residual 600000 ms removeObserver timers + hang; (ii) 0 + clean exit;
#              (iii) 5 + hang; (iv) six-assertion/overlap/mode divergence = STOP; else UNCLASSIFIED. FINAL rc semantics unchanged
#              (primary rc preserved; any cleanup evidence forces nonzero). Neither FINAL 143 nor FINAL 0 is acceptance.
#   Unchanged from V3.1: lock fd 9 held by the runner, 9>&- in children, owned setsid groups, zombie-aware poll, TERM/KILL reaping,
#   M-1 stop after cleanup survivors, M-2 rm-failure count + porcelain gate, ancestor inventory gate, strict 20-module resolution,
#   hash-guarded copy removal, provenance HEAD gate d51a1910, no --forceExit/--detectOpenHandles, no install, no product edit.
#   Invoke (parent-granted only; after a separately granted positive setup; see ../C6_EXECUTION_REQUEST.md):
#     mkdir -p /home/user/workspace/execution/op88/s6-c6-prep/logs/c6 && \
#     setsid nohup timeout -k 30 240 bash /home/user/workspace/execution/op88/s6-c6-prep/c6/run-c6-hazard-v5-conly.sh \
#       > /home/user/workspace/execution/op88/s6-c6-prep/logs/c6/run-c6.out 2>&1 < /dev/null &
# (V3.1/V3/V2 headers kept below for lineage; their Invoke/Steps lines describe V3.1, not this wrapper.)
# C5-S6-RESOURCE-INVENTORY V3.1 — execution-only successor of V3 (1664fd47…) closing reviewer-B addendum-2 M-1/M-2:
#   M-1: a nonzero per-step cleanup_exit (owned group still has members after TERM/KILL) now STOPS the run immediately
#        (die rc 90) before any further child is spawned; the step's real first exit is preserved in FIRST_EXIT.
#   M-2: `rm -f` failure of a declared copy is logged and counted; worktree porcelain must be 0 after cleanup (gate).
#   Rebinds only the manifest name (MANIFEST.v3.1.sha256). Instrument cf470101…, hooks, specs, inputs unchanged.
# (V3 header kept below for lineage.)
# C5-S6-RESOURCE-INVENTORY V3 — execution-only successor of V2 (a38994e4…). Closes reviewer-B findings on the runner:
#   B-01 binding: DIAG=$V3/diag with the exact self-checked V3 instrument (main.js cf470101…) and MANIFEST.v3.sha256.
#   B-02: strict module list aligned to the 20 lockfile-present modules (no @babel/preset-env); require.resolve errors caught.
#   B-03: the five untracked copies are removed at the end ONLY if their bytes still equal the frozen sources (hash-guarded);
#         otherwise retained and reported. B-04: lock fd 9 closed in every child (9>&-). B-06: C's expected outcome is
#         budget-TERM(143) or budget-KILL(137) with >=1 post-teardown snapshot. Fail-closed: any nonzero cleanup_exit,
#         survivor, ancestor-inventory change or retained copy forces FINAL rc!=0 while FIRST_EXIT is preserved separately.
# (V2 header kept below for lineage.)
# C5-S6-RESOURCE-INVENTORY V2 — supervisor with explicit owned child process groups.
# NOT LAUNCHED until the parent grants a named slot. V1 (../run-c5-resource-inventory.sh) is preserved, not executed.
# V2 vs V1: (0) FACTUAL CORRECTION: /home/user/node_modules pre-exists (platform-owned, 212 links, Sep 20; no /home/user/package.json).
#   V1's absent-ancestor-root guard would refuse immediately and is wrong; V2 snapshots the ancestor inventory before/after
#   (must be unchanged) and requires STRICT resolution of every relevant module to $WT/node_modules. (1) runner acquires and HOLDS the canonical lock itself (fd 9) through cleanup; (2) every child is started
# with `setsid` into its own process group that this runner owns and records; no `timeout`, no command substitution
# around children; (3) per-step budget + grace enforced by this supervisor (poll loop) — first_exit (rc from `wait`,
# plus how it ended) is recorded separately from cleanup_exit; (4) TERM/INT/HUP and EXIT traps reap only OWNED groups,
# never the parent, flock, nohup or platform processes; (5) outer BUDGET enforced before every step; external bound
# is the invocation's `timeout` (below), whose group signal reaches this runner, not the owned child groups —
# the trap forwards to them.
# Invoke (parent-granted; external bound 420 s + 30 s):
#   mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/v3.1 && \
#   setsid nohup timeout -k 30 420 bash /home/user/workspace/execution/s6-diagnostic/v3/run-c5-resource-inventory.v3.1.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/v3.1/run-c5.v3.1.out 2>&1 < /dev/null &
# Steps: 0 selftest(pure node) → A noop → B import-only → D persistence lifecycle (no React) → C unchanged v4 hazard+adapter.
# No --forceExit, no --detectOpenHandles, no install, no product/adapter/hazard-test byte change, no assertion change.
set -u
WT=/home/user/workspace/worktrees/s6-diagnostic
C6=/home/user/workspace/execution/op88/s6-c6-prep/c6
DIAG=$C6/diag
IN=$C6/inputs
LOGS=/home/user/workspace/execution/op88/s6-c6-prep/logs/c6
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/c6.EXIT_RECORD
START=$(date +%s)
BUDGET=180            # inner budget (s): steps refuse to start if remaining < their own budget+grace (selftest 25 + C 115 + preflight)
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
export S6DIAG_WT=$WT
CPU="taskset -c 0,1"
TESTDIR=src/services/__tests__
OWNED_PGIDS=""        # every child group this runner created (space separated)
CUR_PID=""; CUR_PGID=""; CUR_STEP=""
FIRST_EXIT=""         # "<step> rc=<n> how=<exited|budget-TERM|budget-KILL|runner-signal>"
CLEANUP_FAILURES=0    # any nonzero cleanup_exit / survivor / ancestor change / retained copy -> FINAL cannot be 0
ACCOUNTED=0
COPIES="persistedQueryCache.hazardControls.test.tsx persistedQueryCache.hazardAdapter.tsx"
HAZARD_V5_SHA=a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d   # v5 = v4 ee9b94df… + two-hook cancelQueries delta
ADAPTER_SHA=3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3     # unchanged
EX=/home/user/workspace/execution/op88/s6-c6-prep   # quarantine marker root (primary $EX/QUARANTINE; fallback $LOGS/QUARANTINE)

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
ancestor_inventory() { ( cd /home/user/node_modules 2>/dev/null && ls -A --time-style=+%s -l | awk '{print $6, $7}' | sort ) | sha256sum | cut -d' ' -f1; }
alive() { # child still running (a not-yet-waited zombie counts as exited; kill -0 alone would report it alive)
  kill -0 "$1" 2>/dev/null || return 1
  [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != "Z" ]
}
rec() { echo "$(ts) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s ${3:-}" >> "$EXIT_RECORD"; }
elapsed() { echo $(( $(date +%s) - START )); }
sha() { sha256sum "$1" | cut -d' ' -f1; }

copy_source() { echo "$IN/$1"; } # C6: both declared copies come from the packet inputs/ (no diag specs are placed)
cleanup_copies() { # B-03: remove a declared copy only if its bytes still equal the frozen source; else retain + report
  local f src dst; for f in $COPIES; do src=$(copy_source "$f"); dst=$WT/$TESTDIR/$f
    [ -e "$dst" ] || { echo "$(ts) copy $f absent (never placed or already removed)" >> "$EXIT_RECORD"; continue; }
    if [ "$(sha "$dst")" = "$(sha "$src")" ]; then
      if rm -f "$dst"; then echo "$(ts) copy $f removed (hash-guarded, equal to frozen source)" >> "$EXIT_RECORD"
      else echo "$(ts) copy $f rm FAILED — retained; counted" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi
    else echo "$(ts) copy $f RETAINED: bytes differ from frozen source ($(sha "$dst")) — report, not deleted" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; done
  local n; n=$(cd "$WT" && git status --porcelain | wc -l)
  ( cd "$WT" && echo "$(ts) worktree porcelain after cleanup: $n line(s) $(git status --porcelain | tr '\n' ' ')" >> "$EXIT_RECORD" )
  [ "$n" = 0 ] || { echo "$(ts) porcelain GATE FAILED ($n line(s) remain in worktree)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }; }
final_accounting() {
  [ "$ACCOUNTED" = 1 ] && return; ACCOUNTED=1
  if [ -n "${ANCESTOR_BEFORE:-}" ]; then local a; a=$(ancestor_inventory)
    if [ "$a" = "$ANCESTOR_BEFORE" ]; then echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a UNCHANGED" >> "$EXIT_RECORD"
    else echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a CHANGED — GATE FAILED (this runner never writes there; report to parent)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; fi
  [ "${COPIES_PLACED:-0}" = 1 ] && cleanup_copies
  echo "$(ts) historical owned_pgids=[$OWNED_PGIDS] (evidence only, not current facts)" >> "$EXIT_RECORD"; own_collect "$(ts) final " >> "$EXIT_RECORD"; own_census | sed "s/^/$(ts) final census /" >> "$EXIT_RECORD"; own_census >/dev/null || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1))
  echo "$(ts) CLEANUP_FAILURES=$CLEANUP_FAILURES lock held until exit (fd 9); runner pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ')" >> "$EXIT_RECORD"
}
HOLD_BOUND=${HOLD_BOUND:-60}; QUAR_STATE=none
quarantine() { # <reason>: checked exclusion marker; QUAR_STATE=written|fallback|failed. On failed with unresolved ownership: hold the lease and poll (bounded), then FINAL 90 exclusion=unpreserved (KNOWN RESIDUAL BOUNDARY, mapped in docs/FINDINGS_AND_APPLICABILITY.md §5; not claimed safe)
  local body="QUARANTINE $(ts) s6-c6-runner-v101 $1"$'\n'"worktree=$WT lock_path=$LOCK (lease released by exit; owned work may remain: no run may start here until parent clears)"
  if own_record "$EX/QUARANTINE" "$body"; then QUAR_STATE=written; elif own_record "$LOGS/QUARANTINE" "$body"; then QUAR_STATE=fallback; else QUAR_STATE=failed; fi
  echo "$(ts) QUARANTINE state=$QUAR_STATE reason=[$1]" >> "$EXIT_RECORD"; echo "QUARANTINE state=$QUAR_STATE $1" >&2
  if [ "$QUAR_STATE" = failed ]; then local h=0; echo "$(ts) EXCLUSION_HOLD: no marker writable; holding lock fd 9 up to ${HOLD_BOUND}s while ownership unresolved" >> "$EXIT_RECORD"
    while ! own_census >/dev/null 2>&1 && [ $h -lt "$HOLD_BOUND" ]; do sleep 2; h=$((h+2)); done; own_census >/dev/null 2>&1 && echo "$(ts) EXCLUSION_HOLD released after ${h}s: ownership resolved" >> "$EXIT_RECORD" || { echo "$(ts) EXCLUSION_UNPRESERVED after ${h}s: owned work unresolved and no marker written — parent boundary (known residual; lease released by exit)" >> "$EXIT_RECORD"; echo "EXCLUSION_UNPRESERVED" >&2; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }; fi; }
finish() { # $1 = primary rc. FIRST_EXIT already recorded by caller. Fail closed on any cleanup evidence.
  final_accounting
  if [ "$CLEANUP_FAILURES" -gt 0 ]; then echo "FINAL rc=$(( $1 == 0 ? 90 : $1 )) (primary rc=$1 preserved in FIRST_EXIT; CLEANUP_FAILURES=$CLEANUP_FAILURES => fail-closed, rc 90 if primary was 0)" >> "$EXIT_RECORD"; [ "$1" -eq 0 ] && exit 90 || exit "$1"; fi
  echo "FINAL rc=$1" >> "$EXIT_RECORD" || { echo "FINAL_RECORD_WRITE_FAILED" >&2; exit 74; }; exit "$1"
}
on_signal() { # runner itself received TERM/INT/HUP (external bound or operator): reap the current owned group, keep first exit
  trap '' TERM INT HUP
  echo "$(ts) RUNNER-SIGNAL received during step=${CUR_STEP:-none} child_pid=${CUR_PID:-none} child_pgid=${CUR_PGID:-none}" >> "$EXIT_RECORD"
  local o rrc; o=$(own_reap_all 10); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) runner-signal /" >> "$EXIT_RECORD"   # R1/R2/Part B(b)(c): registered pids + phase-bound pending fork + confirmed sessions (descendants), never CUR_PGID-dependent, never a sampled number
  own_collect "$(ts) runner-signal " >> "$EXIT_RECORD"; if [ "$rrc" != 0 ] || ! own_census >/dev/null; then CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "runner-signal step=${CUR_STEP:-none}: ownership unresolved after reap: $(printf '%s' "$o" | grep -E 'SURVIVOR|GROUP_SURVIVORS|CENSUS_ERROR' | tr '\n' ';')"; fi
  [ -n "$FIRST_EXIT" ] || FIRST_EXIT="${CUR_STEP:-none} rc=143 how=runner-signal"
  echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) runner terminated externally (primary 143)" >> "$EXIT_RECORD"
  finish 143
}
on_exit() { final_accounting; }
trap on_signal TERM INT HUP
trap on_exit EXIT

die() { if [ -n "$OWN_PIDS$OWN_PGIDS" ] || [ "$OWN_PHASE" = spawning ]; then local o rrc; o=$(own_reap_all 10); rrc=$?; printf '%s\n' "$o" | sed "s/^/$(ts) die-cleanup /" >> "$EXIT_RECORD"; own_collect "$(ts) die-cleanup " >> "$EXIT_RECORD"; if [ "$rrc" != 0 ] || ! own_census >/dev/null; then CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "die step=$1 rc=$2: ownership unresolved after reap"; fi; fi
  rec "$1" "$2" "${3:-}"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$1 rc=$2 how=exited"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; finish "$2"; }

# --- supervised child in its own owned process group ------------------------------------------------------------------
# run_owned <step> <budget> <grace> <stdout/err log> -- <command...>
# sets RUN_RC (wait status) and RUN_HOW (exited|budget-TERM|budget-KILL)
# v10.1: the child is `setsid bash -c "$OWN_GATE" own-gate <attempt> $$ <command...>`; the workload execs only after adoption is published and verified.
run_owned() {
  local step=$1 budget=$2 grace=$3 log=$4; shift 4; [ "$1" = "--" ] && shift
  local need=$(( budget + grace + 5 ))
  if [ $(( BUDGET - $(elapsed) )) -lt "$need" ]; then RUN_RC=75; RUN_HOW=budget-refused; echo "$(ts) step=$step REFUSED: remaining $(( BUDGET - $(elapsed) ))s < needed ${need}s" >> "$EXIT_RECORD"; return; fi
  CUR_STEP=$step
  local att idrc pub=not-attempted state=never-released fin gcs sess=unknown m="" go ce
  att=$(own_attempt) || die "$step-attempt-path" 74 "fresh private attempt path could not be created under $OWN_ROOT"
  own_spawn_begin
  setsid bash -c "$OWN_GATE" own-gate "$att" $$ "$@" > "$log" 2>&1 < /dev/null 9>&- &
  CUR_PID=$!; own_register "$CUR_PID"                                  # R1: registered synchronously; no sleep, no ps sample
  own_confirm "$CUR_PID" 2; idrc=$?                                    # R2: pgid==sid==pid, direct child, != self pgid (rc0) within 2 s; rc1 gone, rc2 unconfirmed, rc3 census-error
  if [ "$idrc" = 0 ]; then   # required recoverable identity published and verified BEFORE release
    if own_record "$att/IDENTITY" "pid=$CUR_PID step=$step attempt=${att##*/} pgid_sid=[$(own_identity "$CUR_PID")] self_pgid=$OWN_SELF_PGID self_sid=$OWN_SELF_SID decoy=${OWN_LAST_DECOY:-none} budget=${budget}s grace=${grace}s cmd=[$*]"; then pub=$(own_adopt "$CUR_PID" "$att"); [ "$pub" = published ] && state=released; else pub=identity-publication-failed; fi; fi   # S6 H-R2: field order only (pid= first, as the setup IDENTITY and the launcher's anchored `^pid=` read require); content unchanged
  echo "$(ts) step=$step IDENTITY attempt=${att##*/} identity_rc=$idrc adoption=$pub state=$state" >> "$EXIT_RECORD" || { [ "$state" = released ] && state=released-then-cancelled; die "$step-post-release-record-failed" 74 "EXIT_RECORD append failed after state=$state (die reaps/quarantines before finish)"; }
  if [ "$state" != released ]; then own_signal "$CUR_PID" TERM >/dev/null; own_wait_gone "$CUR_PID" 5 || { own_signal "$CUR_PID" KILL >/dev/null; own_wait_gone "$CUR_PID" 3; }
    own_finish "$CUR_PID"; fin="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; [ "$OWN_FIN" = observed ] && own_retire "$CUR_PID"
    die "$step-startup-adoption-refused" 2 "identity_rc=$idrc adoption=$pub raw=$fin state=$state (never released: the gate child exits 75/76 without the workload; caller group never signalled)"; fi
  CUR_PGID=$CUR_PID; OWNED_PGIDS="$OWNED_PGIDS $CUR_PGID"              # confirmed + identity published + adopted: workload released (OWNED_PGIDS kept as historical evidence only)
  echo "$(ts) step=$step START child_pid=$CUR_PID child_pgid=$CUR_PGID budget=${budget}s grace=${grace}s cmd=[$*]" >> "$EXIT_RECORD"
  local waited=0
  while own_alive "$CUR_PID" && [ $waited -lt "$budget" ]; do sleep 1; waited=$((waited+1)); done
  if own_alive "$CUR_PID"; then
    RUN_HOW=budget-TERM
    echo "$(ts) step=$step BUDGET ${budget}s reached: TERM owned $(own_signal "$CUR_PID" TERM) pid=$CUR_PID" >> "$EXIT_RECORD"
    own_wait_gone "$CUR_PID" "$grace" || { RUN_HOW=budget-KILL; echo "$(ts) step=$step grace ${grace}s exhausted: KILL owned $(own_signal "$CUR_PID" KILL) pid=$CUR_PID" >> "$EXIT_RECORD"; own_wait_gone "$CUR_PID" 3 || RUN_HOW=budget-KILL-unconfirmed; }
  else
    RUN_HOW=exited
  fi
  own_finish "$CUR_PID"; fin="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; case $OWN_FIN in observed) RUN_RC=$OWN_FIN_RC;; unobserved) RUN_RC=137; RUN_HOW=$RUN_HOW-unconfirmed; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); quarantine "step=$step termination unverified pid=$CUR_PID how=$RUN_HOW";; *) RUN_RC=70; RUN_HOW=$RUN_HOW-wait-mechanism-error; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1));; esac   # Part B (d): wait in THIS shell, only after verified absence
  echo "$(ts) step=$step first_exit rc=$RUN_RC how=$RUN_HOW child_pid=$CUR_PID raw=$fin" >> "$EXIT_RECORD"
  # any stragglers in the owned SESSION (grandchildren, any process group of the session we created) are reaped separately: cleanup_exit, never merged into first_exit; census is TYPED
  go=$(own_group_signal "$CUR_PGID" TERM); own_group_wait_empty "$CUR_PGID" 10 || { go="$go+KILL:$(own_group_signal "$CUR_PGID" KILL)"; own_group_wait_empty "$CUR_PGID" 3; }
  own_group_current "$CUR_PGID"; gcs=$?
  case $gcs in 1) sess=empty; ce=0;; 0) sess=live; ce=1; m=$(own_session_members "$CUR_PGID"); [ -n "$m" ] || m="live-members-unlisted"; quarantine "post:$step descendants survive sid=$CUR_PGID [${m//$'\n'/,}]";; 2) sess=foreign; ce=0; m="foreign-group-not-signalled"; echo "$(ts) post:$step foreign occupant of number $CUR_PGID (not owned, not signalled)" >> "$EXIT_RECORD";; *) sess=unknown; ce=1; m="census-error-session-unresolved"; quarantine "post:$step census error sid=$CUR_PGID (unknown ownership)";; esac
  own_record "$att/EXIT" "step=$step raw=$fin validation_rc=$RUN_RC how=$RUN_HOW state=$state session=$sess survivors=[${m//$'\n'/,}]" || { echo "$(ts) step=$step EXIT_RECORD_PUBLICATION_FAILED $att" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }
  echo "$(ts) step=$step cleanup_exit=$ce session=$sess group_signal=$go" >> "$EXIT_RECORD"
  [ "$ce" -eq 0 ] && [ "$OWN_FIN" = observed ] && [ "$sess" = empty ] && own_retire "$CUR_PID"   # session authority removed only after actual in-shell wait AND positively observed-empty session
  CUR_PID=""; CUR_PGID=""; CUR_STEP=""
  [ "$ce" -eq 0 ] || { CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$step rc=$RUN_RC how=$RUN_HOW"
    die "$step-cleanup-survivors" 90 "cleanup_exit=$ce session=$sess; quarantined owned session unresolved — stop, do not start next step"; }
}
JEST_ARGS() { # $1 spec
  echo "$1 --ci --runInBand --verbose --setupFilesAfterEnv=$WT/jest.setup.js --setupFilesAfterEnv=$DIAG/s6diag.setupAfterEnv.js --globalSetup=$DIAG/s6diag.globalSetup.js --globalTeardown=$DIAG/s6diag.globalTeardown.js"
}
jest_step() { # $1 step $2 budget $3 grace $4 spec → RUN_RC/RUN_HOW, summary written
  local step=$1
  S6DIAG_LOG=$LOGS/c6.$step.inventory.jsonl S6DIAG_STEP=$step \
    run_owned "$step" "$2" "$3" "$LOGS/c6.$step.jest.log" -- $CPU node node_modules/jest/bin/jest.js $(JEST_ARGS "$4")
  node "$DIAG/s6diag.summarize.js" "$LOGS/c6.$step.inventory.jsonl" "$LOGS/c6.$step.jest.log" "$step" "$RUN_RC" > "$LOGS/c6.$step.summary.txt" 2>&1
  echo "$(ts) step=$step summary: $(head -1 "$LOGS/c6.$step.summary.txt")" >> "$EXIT_RECORD"
}

mkdir -p "$LOGS"
echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID token=${S6_LEASE_INHERITED:-none} runner_sha256=$(sha256sum "$0" | cut -c1-64)" > "$EXIT_RECORD"   # S6 v101y (= S5 v101y / S5-V31-A-01 contract): exact current-attempt identity in the earliest publication
echo "$(ts) OWN_STAMP $(own_stamp)" >> "$EXIT_RECORD" || { echo STAMP_WRITE_FAILED >&2; exit 74; }; own_precondition || die precondition-job-control-or-tools 2 "set -m active or setsid/pgrep/ps missing"   # R3 / Part B stamp required
# canonical lock: INHERITED on fd 9 from the outer launcher when S6_LEASE_INHERITED is set (verified, never re-acquired/released here); otherwise acquired by the runner itself and held on fd 9 until the process exits (after all cleanup)
if [ -n "${S6_LEASE_INHERITED:-}" ]; then   # S6 H-S1/H-R1 (= S5 v101x/v101y contract): lease owned by the outer launcher; verify, never re-acquire, never release here
  [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "$LOCK" ] || die lease-fd-not-inherited 75 "S6_LEASE_INHERITED set but fd 9 is not open on $LOCK"
  grep -q "^token=$S6_LEASE_INHERITED " "$EX/LEASE_HOLDER" 2>/dev/null || die lease-holder-record-mismatch 75 "$EX/LEASE_HOLDER does not name token=$S6_LEASE_INHERITED"
  HP=$(sed -n "s/^token=[^ ]* holder_pid=\([0-9]*\) .*/\1/p" "$EX/LEASE_HOLDER" 2>/dev/null); [ -n "$HP" ] && [ -d "/proc/$HP" ] || die lease-holder-gone 75 "holder pid=[$HP] not present"
  echo "$(ts) lease INHERITED fd=9 path=$LOCK token=$S6_LEASE_INHERITED holder_pid=$HP (outer launcher retains exclusion after this runner exits)" >> "$EXIT_RECORD"
else exec 9>"$LOCK"; flock -n 9 || die lock-busy 75 "canonical lock held by another owner; not a grant problem to solve here"; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"; fi
OWN_ROOT="$LOGS/attempts"; mkdir -p "$OWN_ROOT" || die attempts-dir 74   # private per-attempt evidence (IDENTITY/ADOPT/EXIT) under the run logs
cd "$WT" || die cd 1

# 0. provenance
{ echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"; echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"
  echo "node=$(node -v) npm=$(npm -v)"; echo "node_modules_present=$([ -d node_modules ] && echo yes || echo no)"
  echo "ancestor_package_json_absent=$([ ! -e /home/user/package.json ] && echo yes || echo NO)"
  echo "ancestor_node_modules=$(ls -ld /home/user/node_modules 2>&1) entries=$(ls -A /home/user/node_modules 2>/dev/null | wc -l) (platform-owned, pre-existing Sep 20; never touched by this runner)"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/c6.provenance.txt" 2>&1
# ancestor inventory snapshot (read-only): names + mtimes of /home/user/node_modules entries; compared again at the end
ANCESTOR_BEFORE=$(ancestor_inventory); echo "ancestor_inventory_before=$ANCESTOR_BEFORE" >> "$LOGS/c6.provenance.txt"
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -d node_modules ] || die provenance-node-modules-absent-setup-not-granted 2
grep -q "ancestor_package_json_absent=yes" "$LOGS/c6.provenance.txt" || die provenance-ancestor-package-json 2
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die provenance-clean 2
rec provenance 0

# 1. frozen C6 packet bytes: unchanged v3.1 instrument set (diag/*, same hashes as MANIFEST.v3.1.sha256), inputs/ (v5 + adapter),
#    c6classify.js and this runner. Non-self-including (the manifest file itself is not listed).
(cd "$C6" && sha256sum -c --quiet MANIFEST.c6.sha256) > "$LOGS/c6.manifest-check.txt" 2>&1 || die manifest-mismatch-reattribution-required 3
rec manifest 0

# 2. STRICT module resolution: every relevant module must resolve to $WT/node_modules (the ancestor /home/user/node_modules
#    contains @babel/* and would be the fallback if the worktree copy were missing — any such fallback is a hard stop)
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest","jest-circus","jest-runtime","@jest/core","babel-jest","@babel/core","babel-preset-expo","zustand","scheduler"]) {
  let r; try { r=require.resolve(m+"/package.json",{paths:[wt]}); } catch(e){ console.log(`BAD ${m} unresolved: ${e.code||e.message}`); bad++; continue; }
  const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/c6.module-paths.txt" 2>&1 || die module-paths 5
rec module-paths 0

# 3. exact inputs (untracked copies, declared) and digests
COPIES_PLACED=1
cp "$IN/persistedQueryCache.hazardControls.test.tsx" "$IN/persistedQueryCache.hazardAdapter.tsx" "$TESTDIR/"
[ "$(sha $TESTDIR/persistedQueryCache.hazardControls.test.tsx)" = "$HAZARD_V5_SHA" ] || die fingerprint-v5-hazard 4
[ "$(sha $TESTDIR/persistedQueryCache.hazardAdapter.tsx)" = "$ADAPTER_SHA" ] || die fingerprint-adapter 4
{ sha256sum $TESTDIR/persistedQueryCache.hazard*; git status --porcelain; } > "$LOGS/c6.fingerprint.txt" 2>&1
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die fingerprint-clean 4
rec copy-inputs 0

# 4. step 0: instrument self-check (pure node, no node_modules, no product code) — kept: the install is fresh, the instrument must
#    still fit this process before its C observation is trusted.
S6DIAG_LOG=$LOGS/c6.selftest.inventory.jsonl S6DIAG_STEP=selftest run_owned selftest 15 5 "$LOGS/c6.selftest.out" -- $CPU node "$DIAG/s6diag.selftest.js"
rec selftest "$RUN_RC" "how=$RUN_HOW"; [ "$RUN_RC" -eq 0 ] || die selftest-instrument-unfit "$RUN_RC"

# 5. (V3.1 steps A/B/D are NOT repeated: their C5 clean exits stand; brief non-goal.)

# 6. step C: hazard v5 (cancelQueries before clear in afterEach/afterAll) + unchanged adapter under the unchanged inventory.
#    Same budget/grace as C5's C step (90 s + 20 s) so tick snapshots (+1/3/6/10/20/40/70 s) are comparable.
#    Pre-declared outcomes (S6_C5_REVIEW_B.md §8): (i) 2 residual 600000 ms removeObserver timers + budget-TERM/KILL;
#    (ii) 0 timers + clean exit (rc 0, beforeExit); (iii) 5 timers + hang; (iv) six-assertion/overlap/mode divergence = STOP.
#    A clean exit here is a pre-declared outcome, NOT the V3.1 "perturbation divergence" and NOT acceptance.
jest_step C 90 20 "$TESTDIR/persistedQueryCache.hazardControls.test.tsx"; rec C-hazard-v5-cancel-before-clear "$RUN_RC" "how=$RUN_HOW"
{ echo "tests_line: $(grep -m1 '^Tests:' "$LOGS/c6.C.jest.log")"
  echo "overlapping_act: $(grep -c 'overlapping act' "$LOGS/c6.C.jest.log")"
  echo "mode_line_present: $(grep -c '\[mode=d51-singleton\]' "$LOGS/c6.C.jest.log")"
  echo "did_not_exit_line: $(grep -c 'did not exit one second' "$LOGS/c6.C.jest.log")"
  echo "first_exit_rc: $RUN_RC how: $RUN_HOW"
  node "$C6/c6classify.js" "$LOGS/c6.C.inventory.jsonl" "$LOGS/c6.C.jest.log" "$RUN_RC" "$RUN_HOW" 2>&1; } > "$LOGS/c6.C.checks.txt"
grep -q '^Tests:       6 passed, 6 total' "$LOGS/c6.C.jest.log" || echo "C-BEHAVIOURAL-DIVERGENCE: six assertions not preserved under instrument — outcome (iv), STOP" >> "$EXIT_RECORD"
[ "$(grep -c 'overlapping act' "$LOGS/c6.C.jest.log")" = "0" ] || echo "C-OVERLAPPING-ACT under instrument — outcome (iv), STOP" >> "$EXIT_RECORD"
echo "$(ts) $(grep -m1 '^C6-OUTCOME=' "$LOGS/c6.C.checks.txt" || echo 'C6-OUTCOME=CLASSIFIER-ABSENT')" >> "$EXIT_RECORD"
FIRST_EXIT="C rc=$RUN_RC how=$RUN_HOW"
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"
echo "$(ts) C real first exit rc=$RUN_RC how=$RUN_HOW (interpret ONLY via the C6-OUTCOME line and raw c6.C.* files; neither 143 nor 0 is acceptance)" >> "$EXIT_RECORD"
finish "$RUN_RC"
