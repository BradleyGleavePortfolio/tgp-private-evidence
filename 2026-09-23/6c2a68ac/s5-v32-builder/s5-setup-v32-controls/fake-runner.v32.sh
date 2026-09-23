#!/usr/bin/env bash
# Private fake runner v3.2 (successor of fake v3.1 4e7858a2; for the S5 setup-exclusion v3.2 controls). ONLY delta (S5-V31-A-01): start_line publishes token=${S5_LEASE_INHERITED:-none}
# after ppid=, exactly where runner v101y L210 publishes it, so the launcher v3.2 START binding (pgid=$SESSION AND token=$TOKEN) is exercised by the early-death shape. v3.1 header follows.
# [v3.1 header, retained] Private fake runner v3.1 for the S5 setup-exclusion v3.1 controls (no npm, no canonical paths). Successor of fake v2 5c18e3b3 (which is INCOMPATIBLE with v3/v3.1 in EVERY
# scenario: it never writes a current-attempt-bound setup.EXIT_RECORD, so any adopted v2 fake is classified absent/not-this-attempt after launch -> unknown -> indefinite hold; V3-B-02).
# Every adopted scenario here first writes the runner's own EXIT_RECORD exactly as v101x does at its start: truncating START line (L206 format) and, unless the scenario models an
# exit BEFORE that point, the INHERITED binding line (L212 format: " lease INHERITED fd=9 path=$S5X_LOCK token=$S5_LEASE_INHERITED " with the launcher's own LOCK string and token).
# Children are bounded (sleep) and fd 9 is closed for any sub-session child (canonical shape). Nothing here signals anything.
set -u; IL=${S5X_EX:?}/logs/setup-v1; R=$IL/setup.EXIT_RECORD; ts() { date -u +%FT%TZ; }; mkdir -p "$IL" || exit 74
start_line() { echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID token=${S5_LEASE_INHERITED:-none} sid=$(ps -o sid= $$ | tr -d ' ') fake_sha256=$(sha256sum "$0" | cut -c1-64) scenario=${S5X_SCENARIO:-}" > "$R" || exit 74; }   # v3.2: token= as in v101y L210
bind_line() { echo "$(ts) lease INHERITED fd=9 path=${S5X_LOCK:?} token=${S5_LEASE_INHERITED:?} holder_pid=fake (fake: same fixed-string form as v101x L212)" >> "$R" || exit 74; }
case "${S5X_SCENARIO:?}" in
  early-death-75) # V3-B-01 closure shape: adopted runner writes START (L206) and exits BEFORE the L212 binding line (models die lease-holder-record-mismatch 75); no children, no npm
    start_line; { echo "$(ts) step=lease-holder-record-mismatch rc=75 (fake: exits before the INHERITED line)"; echo "FIRST_EXIT lease-holder-record-mismatch rc=75 how=exited"; echo "FINAL rc=75"; } >> "$R"; exit 75 ;;
  never-runs) exit 64 ;;   # P3a: the gate must never be adopted; if this body ever runs the raw status 64 is attributable
esac
start_line; [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "${S5X_LOCK:?}" ] || exit 75; [ -n "${S5_LEASE_INHERITED:-}" ] || exit 75; bind_line
case "$S5X_SCENARIO" in
  bound-normal-slow) sleep "${S5X_SLOW:-6}"; echo "FINAL rc=0" >> "$R"; exit 0 ;;   # P2: acknowledged RUNNING window for the driver's fixture, then normal completion
  bound-subsession-90) # P1: canonical shape (as fake v2 subsession-90) plus the current binding: inner setsid session (fd 9 closed) outlives the runner; IDENTITY bound by self_sid; exit 90
    A=$IL/attempts/attempt-fake; mkdir -p "$A" || exit 74; MYSID=$(ps -o sid= -p $$ | tr -d ' ')
    ( exec setsid sleep "${S5X_SUB_SLEEP:-16}" ) 9>&- < /dev/null > /dev/null 2>&1 & SP=$!
    i=0; until [ "$(ps -o sid= -p "$SP" 2>/dev/null | tr -d ' ')" = "$SP" ]; do i=$((i+1)); [ $i -ge 100 ] && exit 70; sleep 0.05; done
    printf '%s\n' "pid=$SP attempt=attempt-fake pgid_sid=[$SP $SP] self_pgid=$(ps -o pgid= -p $$ | tr -d ' ') self_sid=$MYSID decoy=none budget=fake grace=fake" > "$A/IDENTITY.tmp" && mv -f "$A/IDENTITY.tmp" "$A/IDENTITY" || exit 74
    { echo "$(ts) npm-ci IDENTITY attempt=attempt-fake identity_rc=0 adoption=published state=released"; echo "$(ts) EXCLUSION_UNPRESERVED after 0s: fake owned work unresolved and no marker written"; echo "$(ts) CLEANUP_FAILURES=1"; echo "FINAL rc=90 (fake)"; } >> "$R" || exit 74
    echo "$SP" > "$S5X_EX/SUB_READY.tmp" && mv -f "$S5X_EX/SUB_READY.tmp" "$S5X_EX/SUB_READY" || exit 74; exit 90 ;;
  *) exit 64 ;;
esac
