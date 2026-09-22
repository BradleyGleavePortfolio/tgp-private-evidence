# >>> OWN-BLOCK v8 (S5-V7-A-02 / A-03 / P88-S5-SETUP-01 minimal correction; byte-identical in ctl-t0-only.v8.sh and
# run-s5-setup-npm-ci.v8.sh; controls source this file). Startup identity/publication, caller-group exclusion, bounded
# termination without unconditional wait, and admission budgeting. bash 5 + procps ps/pgrep + coreutils only.
OWN_SELF_PGID=$(ps -o pgid= -p $$ | tr -d ' '); OWN_SELF_SID=$(ps -o sid= -p $$ | tr -d ' ')
OWN_PIDS=""; OWN_PGIDS=""; OWN_LAST_DECOY=""   # OWN_PIDS: every spawned pid, registered synchronously; OWN_PGIDS: CONFIRMED own-session leaders only
own_register() { OWN_PIDS="$OWN_PIDS $1"; }                  # call as the very next command after `&` with $! — no sleep before
own_identity() { ps -o pgid= -o sid= -p "$1" 2>/dev/null | tr -s ' ' | sed 's/^ //;s/ $//'; }   # "pgid sid" or empty when gone
own_alive() { kill -0 "$1" 2>/dev/null || return 1; [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != Z ]; }   # zombie is not alive
own_confirm() { # <pid> [max_s=2]: rc0 pgid==sid==pid confirmed (added to OWN_PGIDS); rc1 gone before confirm; rc2 unconfirmed (never a group target)
  local pid=$1 n=$(( ${2:-2} * 20 )) i=0 id pg sid
  while :; do id=$(own_identity "$pid"); [ -z "$id" ] && return 1; pg=${id% *}; sid=${id#* }
    if [ "$pg" = "$pid" ] && [ "$sid" = "$pid" ] && [ "$pg" != "$OWN_SELF_PGID" ]; then OWN_PGIDS="$OWN_PGIDS $pg"; return 0; fi
    [ "$pg" = "$OWN_SELF_PGID" ] && OWN_LAST_DECOY="$pg"
    i=$((i+1)); [ $i -ge $n ] && return 2; sleep 0.05; done; }
own_signal() { # <pid> <SIG>: group signal ONLY if identity re-confirmed now (pgid==sid==pid, not self group); else pid-only. Prints group|pid|gone
  local pid=$1 sig=$2 id pg sid; id=$(own_identity "$pid"); [ -z "$id" ] && { echo gone; return 0; }; pg=${id% *}; sid=${id#* }
  if [ "$pg" = "$pid" ] && [ "$sid" = "$pid" ] && [ "$pg" != "$OWN_SELF_PGID" ]; then kill "-$sig" -- "-$pg" 2>/dev/null; echo group; else kill "-$sig" "$pid" 2>/dev/null; echo pid; fi; }
own_wait_gone() { # <pid> <seconds>: bounded poll (0.1 s steps); rc0 not alive, rc1 still alive. Never blocks in `wait`.
  local pid=$1 n=$(( $2 * 10 )) i=0; while own_alive "$pid" && [ $i -lt $n ]; do sleep 0.1; i=$((i+1)); done; ! own_alive "$pid"; }
own_reap_all() { # <grace_s>: for every registered pid: TERM (group if confirmed) -> bounded wait -> KILL -> 3 s bounded wait; then census confirmed groups. rc1 on any survivor
  local pid rc=0 how pg m
  for pid in $OWN_PIDS; do own_alive "$pid" || continue
    how=$(own_signal "$pid" TERM); if ! own_wait_gone "$pid" "$1"; then how="$how+KILL:$(own_signal "$pid" KILL)"; own_wait_gone "$pid" 3 || { echo "SURVIVOR pid=$pid how=$how"; rc=1; continue; }; fi
    echo "REAPED pid=$pid how=$how"; done
  for pg in $OWN_PGIDS; do m=$(pgrep -g "$pg" || true); [ -n "$m" ] && { echo "GROUP_SURVIVORS pgid=$pg [${m//$'\n'/,}]"; rc=1; }; done
  return $rc; }
own_budget() { # <remaining_s> <want_s> <grace_s> <reserve_s>: admissible run budget = min(want, remaining - grace - reserve), floor 0
  local b=$(( $1 - $3 - $4 )); [ "$b" -gt "$2" ] && b=$2; [ "$b" -lt 0 ] && b=0; echo "$b"; }
# <<< OWN-BLOCK v8
