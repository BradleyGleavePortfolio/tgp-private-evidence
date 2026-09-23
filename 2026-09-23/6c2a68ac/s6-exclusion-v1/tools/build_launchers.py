#!/usr/bin/env python3
# Deterministic derivation of the two S6 launcher copies from the accepted S5 V32 launcher (55acc00f).
# Every replaced base line is asserted byte-exact first (fail-closed on any drift). Nothing is executed.
import hashlib
D = "/home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/"
BASE = D + "inputs/launch-s5-setup-exclusion.v32.sh"
b = open(BASE, "rb").read(); assert hashlib.sha256(b).hexdigest() == "55acc00fe9b04d0e015f37bbdac90e582925c4b4564f7aaaa55c21a13304cf0a"
BASE_LINES = b.decode().split("\n")

def sha(p): return hashlib.sha256(open(p, "rb").read()).hexdigest()
PIN = {"setup": sha(D + "run-c5-setup-npm-ci.v101y.sh"), "c6": sha(D + "run-c6-hazard-v5-conly.v101y.sh")}

C = {
 "setup": dict(name="launch-s6-setup-exclusion.v1.sh", tag="OP88-S6-SETUP-EXCLUSION", grant="S6_SETUP_GRANT",
   ex="/home/user/workspace/execution/s6-diagnostic", runner="run-c5-setup-npm-ci.v101y.sh", runner_base="run-c5-setup-npm-ci.v101.sh 8b1ae8c0",
   ib="1290", ik="30", nb="1380", logs="s6-setup-exclusion", inner_logs="setup-v3", rec="setup.EXIT_RECORD", steps="ONE inner install session (npm ci)"),
 "c6": dict(name="launch-s6-c6-exclusion.v1.sh", tag="OP88-S6-C6-EXCLUSION", grant="S6_C6_GRANT",
   ex="/home/user/workspace/execution/op88/s6-c6-prep", runner="run-c6-hazard-v5-conly.v101y.sh", runner_base="run-c6-hazard-v5-conly.v101.sh 2c9748a4",
   ib="240", ik="30", nb="300", logs="c6-exclusion", inner_logs="c6", rec="c6.EXIT_RECORD", steps="up to TWO inner sessions (selftest node, then Jest C), each named as a released attempt"),
}

def rep(L, n, expect, new):
    cur = L[n - 1]; assert cur.startswith(expect), (n, cur[:140], expect[:80])
    L[n - 1] = new if isinstance(new, str) else "\n".join(new)

QG = [
 '# S6 H-L2 (Choice A): two EX roots stay; refuse BEFORE the lease when ANY of the four exact quarantine marker paths exists (setup primary/fallback, C6 primary/fallback). Marker presence => refusal',
 '# (no bypass, exit 71, nothing launched, lock never opened). Marker ABSENCE is never sufficiency: flock -n (live holder), preserve_prior (prior records by token) and the typed census still bind.',
 'for q in /home/user/workspace/execution/s6-diagnostic/QUARANTINE /home/user/workspace/execution/s6-diagnostic/logs/setup-v3/QUARANTINE /home/user/workspace/execution/op88/s6-c6-prep/QUARANTINE /home/user/workspace/execution/op88/s6-c6-prep/logs/c6/QUARANTINE; do',
 '  [ -e "$q" ] && { say "REFUSE quarantine marker present $q (parent must clear; no run)"; exit 71; }; done',
]

for k, c in C.items():
    L = list(BASE_LINES)
    # ---- H-L3 grant variable (L33)
    rep(L, 33, '[ "${S5_SETUP_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_SETUP_GRANT=granted-by-parent not set"; exit 2; }',
        '[ "${%s:-}" = "granted-by-parent" ] || { echo "REFUSE: %s=granted-by-parent not set"; exit 2; }' % (c["grant"], c["grant"]))
    # ---- H-L1 constants (L34, L38, L39, L41); L36 private S5X branch retained VERBATIM (unused; refuses canonical paths)
    rep(L, 34, 'CANON_LOCK=/home/user/workspace/execution/test-validation.lock; CANON_EX=/home/user/workspace/execution/s5-r4',
        'CANON_LOCK=/home/user/workspace/execution/test-validation.lock; CANON_EX=%s' % c["ex"])
    assert L[35].startswith('if [ "${S5X_PRIVATE:-0}" = 1 ]; then LOCK=${S5X_LOCK:?}')
    rep(L, 38, 'else LOCK=$CANON_LOCK; EX=$CANON_EX; RUNNER="$HERE/run-s5-setup-npm-ci.v101y.sh"; INNER_BOUND=1290; INNER_KILL=30; NORMAL_BOUND=1380; HEARTBEAT=30; fi',
        'else LOCK=$CANON_LOCK; EX=$CANON_EX; RUNNER="$HERE/%s"; INNER_BOUND=%s; INNER_KILL=%s; NORMAL_BOUND=%s; HEARTBEAT=30; fi   # S6 H-L1: nominal safety bounds (= frozen consumer invoke), not a completion guarantee' % (c["runner"], c["ib"], c["ik"], c["nb"]))
    rep(L, 39, 'LOGS=$EX/logs/setup-exclusion; mkdir -p "$LOGS" || exit 74;',
        L[38].replace('LOGS=$EX/logs/setup-exclusion;', 'LOGS=$EX/logs/%s;' % c["logs"], 1))
    rep(L, 41, 'PIN_RUNNER=61b565e48fa4c14f765fe223bfc3a8baac27ca2867763c91e6a57135fc4ea1b3;',
        'PIN_RUNNER=%s; [ "${S5X_PRIVATE:-0}" = 1 ] || { [ "$(sha256sum "$RUNNER" | cut -c1-64)" = "$PIN_RUNNER" ] || { echo "REFUSE: runner hash != $PIN_RUNNER"; exit 2; }; }   # S6 H-L1: pin = S6 runner variant %s (v101y: inherited fd 9 + START publishes the inherited token; frozen base %s)' % (PIN[k], c["runner"], c["runner_base"]))
    # ---- L152 unchanged (LAUNCHER_START). L153 own_precondition. Insert H-L2 gate after L153 (before TOKEN/flock at L154-157).
    assert L[152].startswith('own_precondition || { say "REFUSE precondition')
    # ---- state line (L170): add REL_KNOWN/REL_BOUND
    rep(L, 170, 'INNER_KNOWN=""; RSTATE=never-released   # v3.2 (S5-V31-A-01):',
        'INNER_KNOWN=""; RSTATE=never-released; REL_KNOWN=""; REL_BOUND=""   # S6 H-L4: REL_KNOWN = released attempt names ever seen in THIS attempt\'s bound record (union, never shrinks); REL_BOUND = established attempt:pid bindings (union). ' + L[169].split('   # ', 1)[1])
    # ---- INNER_LOGS (L178)
    rep(L, 178, 'INNER_LOGS=$EX/logs/setup-v1', 'INNER_LOGS=$EX/logs/%s   # S6 H-L1: the runner\'s own LOGS (records + attempts/), unchanged in the runner' % c["inner_logs"])
    # ---- runner_bound comment (L185-186): line references -> S6 runner (comment only; grep bytes unchanged)
    rep(L, 185, 'runner_bound() { # <record>: rc0 only when the shared record is THIS attempt\'s runner\'s. (a) its INHERITED line carries our token (v101y L216); or (b) v3.2 (S5-V31-A-01): a START line',
        'runner_bound() { # <record>: rc0 only when the shared record is THIS attempt\'s runner\'s. (a) its INHERITED line carries our token (S6 runner v101y inherited branch); or (b) v3.2 (S5-V31-A-01): a START line')
    rep(L, 186, '  # (v101y L210, the runner\'s first and truncating write, before L216) carries BOTH pgid=$SESSION',
        '  # (S6 runner v101y START, the runner\'s first and truncating write, before its INHERITED line) carries BOTH pgid=$SESSION' + L[185].split('carries BOTH pgid=$SESSION', 1)[1])
    # ---- runner_truth record name (L191) and H-L4 released accounting (L194)
    rep(L, 191, '  local r=$INNER_LOGS/setup.EXIT_RECORD rel=0 fin=none unp=0 cf=none',
        '  local r=$INNER_LOGS/%s rel=0 fin=none unp=0 cf=none' % c["rec"])
    rep(L, 194, '  grep -q \'npm-ci IDENTITY .* state=released\' "$r" 2>/dev/null && rel=1; grep -q \'EXCLUSION_UNPRESERVED\' "$r" 2>/dev/null && unp=1',
        ['  for a in $(sed -n \'s/.* IDENTITY attempt=\\([^ ]*\\) .* state=released.*/\\1/p\' "$r" 2>/dev/null); do case " $REL_KNOWN " in *" $a "*) ;; *) REL_KNOWN="$REL_KNOWN $a";; esac; done   # S6 H-L4: every released attempt NAME from this attempt\'s bound record joins REL_KNOWN (matches `step=<s> IDENTITY attempt=…` and `npm-ci IDENTITY attempt=…`); replaces the v3.x released=1 boolean',
         '  rel=$(set -- $REL_KNOWN; echo $#); grep -q \'EXCLUSION_UNPRESERVED\' "$r" 2>/dev/null && unp=1   # released=<n> = count of distinct released attempt names ever observed'])
    # ---- H-L4 session_state: replace L201 (released-but-no-IDENTITY set-emptiness rule) by exact released-attempt -> bound IDENTITY -> retained SID accounting
    rep(L, 201, '  case "$RUNNER_NOTE" in *released=1*) [ -n "$ids" ] || { unknown=1; d="$d inner:released-but-no-IDENTITY"; };; esac',
        ['  # S6 H-L4 (addendum): EVERY released attempt named by the runner must map, at least once, to a readable IDENTITY bound to our SESSION (` self_sid=`) that yields a pid; that pid joins INNER_KNOWN',
         '  # and is censused until positively empty. Until each released attempt is bound: unknown => SELF-HOLD, regardless of how many OTHER ids are known/empty (a known selftest sid never certifies C).',
         '  local a f p; for a in $REL_KNOWN; do case " $REL_BOUND " in *" $a:"*) continue;; esac   # already bound once: its pid is in INNER_KNOWN and stays censused',
         '    f="$INNER_LOGS/attempts/$a/IDENTITY"; p=""',
         '    if [ -r "$f" ] && grep -q " self_sid=$SESSION " "$f" 2>/dev/null; then p=$(sed -n \'s/^pid=\\([0-9][0-9]*\\) .*/\\1/p\' "$f" 2>/dev/null | head -1); fi',
         '    if [ -n "$p" ]; then REL_BOUND="$REL_BOUND $a:$p"; case " $INNER_KNOWN " in *" $p "*) ;; *) INNER_KNOWN="$INNER_KNOWN $p";; esac',
         '    else unknown=1; d="$d inner:released-attempt-unbound:$a"; fi; done',
         '  ids=${INNER_KNOWN# }; INNER=${ids// /,}'])
    # ---- spawn line (L232): env var names
    rep(L, 232, '( exec setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ env S5_LEASE_INHERITED="$TOKEN" S5_SETUP_GRANT="$S5_SETUP_GRANT" timeout -k "$INNER_KILL" "$INNER_BOUND" bash "$RUNNER" ) > "$LOGS/runner.out" 2>&1 < /dev/null &',
        '( exec setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ env S6_LEASE_INHERITED="$TOKEN" %s="$%s" timeout -k "$INNER_KILL" "$INNER_BOUND" bash "$RUNNER" ) > "$LOGS/runner.out" 2>&1 < /dev/null &   # S6 H-L3: the inner timeout sits INSIDE session P and can only end the runner leader, never this holder' % (c["grant"], c["grant"]))
    # ---- insert H-L2 gate after L153 (do this AFTER all numbered replacements so numbering above stays base-relative)
    L[153:153] = QG
    # ---- header: new S6 header lines, then the retained v3.2 header
    assert L[1].startswith('# OP88-S5-SETUP-EXCLUSION outer launcher v3.2')
    hdr = [
     '# %s outer launcher v1 (ADDITIVE copy of the accepted S5 V32 launcher launch-s5-setup-exclusion.v32.sh 55acc00f, pinned to ONE runner; NOT LAUNCHED; no grant implied).' % c["tag"],
     '# Exact deltas from V32 (S6_EXCLUSION_SCOPE_MAP.md + ADDENDUM_HL4; parent-frozen choices O-A / Choice A): H-L1 consumer constants (CANON_EX=%s, RUNNER=%s,' % (c["ex"], c["runner"]),
     '#   PIN_RUNNER=<its sha256>, LOGS=$EX/logs/%s, INNER_LOGS=$EX/logs/%s, runner record %s, INNER_BOUND/INNER_KILL/NORMAL_BOUND %s/%s/%s nominal, HEARTBEAT 30); H-L2 four-marker' % (c["logs"], c["inner_logs"], c["rec"], c["ib"], c["ik"], c["nb"]),
     '#   quarantine refusal BEFORE the lease (exit 71; marker absence is never permission); H-L3 %s / S6_LEASE_INHERITED variable names; H-L4 released-attempt -> bound IDENTITY -> retained SID' % c["grant"],
     '#   accounting (REL_KNOWN/REL_BOUND; released=<n> count; CENSUS_DETAIL inner:released-attempt-unbound:<attempt>), replacing the v3.x released=1 boolean and the set-emptiness rule. This consumer has %s.' % c["steps"],
     '# UNCHANGED from V32: OWN-BLOCK v10.1 4aebf96f byte-identical; no handoff; raw-status truth; typed census; release ONLY after the exact outer session AND every retained inner sid are positively empty;',
     '#   SELF-HOLD (never last-owner timeout, never self-kill); runner_bound token binding (INHERITED line or START line with pgid=$SESSION AND token=$TOKEN); preserve_prior; the unused private S5X branch',
     '#   (verbatim; refuses canonical paths; no S6 harness exists). O-A: the frozen C6 observer f140787a is NOT used. Invoke WITHOUT an outer timeout on this process:',
     '#   setsid nohup env %s=granted-by-parent bash %s > <LOGS>/launcher.out 2>&1 < /dev/null &' % (c["grant"], c["name"]),
     '# [v3.2 header, retained] ' + L[1][2:],
    ]
    L[1:2] = hdr
    out = "\n".join(L)
    open(D + c["name"], "w").write(out)
    print(k, c["name"], hashlib.sha256(out.encode()).hexdigest(), "PIN_RUNNER", PIN[k])
