#!/usr/bin/env bash
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
CR="$(mktemp -d /tmp/s5-r4-gate-XXXXXX)"; export CR
on_exit() { local surv=0 o; o=$(own_reap_all "$RUN_GRACE"); [ -n "$o" ] && printf '%s\n' "$o" | while read -r l; do log "CLEANUP $l"; done; printf '%s\n' "$o" | grep -q SURVIVOR && surv=1; if [ "$surv" = 1 ] || [ "${S5_CTL_KEEP:-}" = 1 ]; then log "CONTROL_ROOT_RETAINED $CR (keep=${S5_CTL_KEEP:-0} survivors=$surv)"; else rm -rf "$CR"; fi; log "AGGREGATE_ELAPSED $(( $(date +%s) - T0 ))s"; }
trap on_exit EXIT; trap 'log SIGNAL; exit 143' TERM INT HUP
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
run_gate() { # <id> <spec> <scenario>  -> GATE_RC, and checks <id>.identity (confirmed own session) and <id>.owned (no survivors)
  local rec="$OUT/gate-$CTL_TS-$1.jsonl" out="$OUT/gate-$CTL_TS-$1.jest.log" t0 pid w=0 how=exited ident crc m=""; : > "$rec"
  local left=$((AGG_BOUND - ($(date +%s) - T0))) budget; budget=$(own_budget "$left" "$RUN_BUDGET" "$RUN_GRACE" "$RUN_RESERVE")
  [ "$budget" -ge 5 ] || { log "AGGREGATE_BOUND_HIT before $1 (left=${left}s admissible=${budget}s: budget+grace+reserve must fit)"; GATE_RC=124; return; }
  t0=$(date +%s)
  ( cd "$CR" && exec setsid env -i PATH="/usr/local/bin:/usr/bin:/bin" HOME="$CR" G2_CTL_ROOT="$CR" G2_CTL_RECORD="$rec" G2_CTL_FAKEROOT="$CR/fakeroot" G2_CTL_SCENARIO="$3" NODE_OPTIONS=--max-old-space-size=2048 CI=1 \
      "$W/node_modules/.bin/jest" --config "$CR/jest.config.js" --runInBand "test/$2" ) > "$out" 2>&1 < /dev/null &
  pid=$!; own_register "$pid"                                   # A-02: registered synchronously; no sleep before registration
  own_confirm "$pid" 2; crc=$?; case $crc in 0) ident=confirmed;; 1) ident=exited-before-confirm;; *) ident=unconfirmed;; esac
  log "$1 START pid=$pid identity=$ident pgid_sid=[$(own_identity "$pid")] self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none} scenario=$3 spec=$2 budget=${budget}s"
  if [ "$ident" != confirmed ]; then how=identity-refused; own_signal "$pid" TERM >/dev/null; own_wait_gone "$pid" 5 || own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3 || m="pid:$pid"; fi
  while [ "$ident" = confirmed ] && own_alive "$pid" && [ $w -lt "$budget" ]; do sleep 1; w=$((w+1)); done
  if [ "$ident" = confirmed ] && own_alive "$pid"; then how=budget-TERM; own_signal "$pid" TERM >/dev/null; own_wait_gone "$pid" "$RUN_GRACE" || { how=budget-KILL; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3 || how=budget-KILL-unconfirmed; }; fi
  if [ "$how" = budget-KILL-unconfirmed ]; then GATE_RC=137; else wait "$pid" 2>/dev/null; GATE_RC=$?; fi      # A-03: no unconditional wait after unconfirmed termination
  [ "$ident" = confirmed ] && { m=$(pgrep -g "$pid" || true); [ -n "$m" ] && { own_signal "$pid" TERM >/dev/null; sleep 2; own_signal "$pid" KILL >/dev/null; sleep 1; m=$(pgrep -g "$pid" || true); }; }
  log "$1 EXIT jest_rc=$GATE_RC how=$how identity=$ident elapsed=$(( $(date +%s) - t0 ))s record_lines=$(wc -l < "$rec") survivors=[${m//$'\n'/,}] (nonzero jest rc is EXPECTED: beforeAll throws)"
  check "$1.identity" "$( [ "$ident" = confirmed ]; echo $? )" "jest child confirmed as its own session/group leader (pgid==sid==pid, not the caller group) within 2 s"
  check "$1.owned" "$( [ -z "$m" ] && [ "$how" = exited ]; echo $? )" "jest child exited within budget and its process group is empty"
}
mut() { grep -c '"mutating":true' "$1"; }
run_gate T0 predecessor.spec.ts refused-identity; R="$OUT/gate-$CTL_TS-T0.jsonl"
check T0.defect "$( [ "$(mut "$R")" -ge 2 ] && grep -q 'DROP CONSTRAINT IF EXISTS g2p_target_refusal' "$R" && grep -q '"fn":"resetData"' "$R"; echo $? )" "PREDECESSOR refused-identity: $(mut "$R") mutating teardown calls recorded (frozen S5-R3-A-01 under real Jest hook semantics; FAILING behaviour)"
check T0.refusal_reason "$( J="$OUT/gate-$CTL_TS-T0.jest.log"; grep -q 'not_the_disposable_db' "$J" && grep -q 'toMatchObject' "$J" && ! grep -q 'Exceeded timeout' "$J"; echo $? )" "PREDECESSOR beforeAll failed at the identity toMatchObject (received database not_the_disposable_db), not a hook timeout; the mutating teardown followed that refusal (T2-1)"
summary
