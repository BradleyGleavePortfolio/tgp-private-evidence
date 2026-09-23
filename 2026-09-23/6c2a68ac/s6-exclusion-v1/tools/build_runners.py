#!/usr/bin/env python3
# Deterministic derivation of the two S6 runner variants from the pinned frozen consumers.
# Every replaced base line is asserted byte-exact first (fail-closed on any drift). Nothing is executed.
import sys, hashlib
D = "/home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/"

def load(p, want):
    b = open(p, "rb").read()
    h = hashlib.sha256(b).hexdigest()
    assert h == want, (p, h)
    return b.decode().split("\n")

def rep(lines, n, expect_prefix, new):
    # n is 1-based line number in the ORIGINAL numbering; expect_prefix must match the start of that line
    cur = lines[n - 1]
    assert cur.startswith(expect_prefix), (n, cur[:120])
    lines[n - 1] = new if isinstance(new, str) else "\n".join(new)

INH = lambda var, ex_note, die_busy: [
 'if [ -n "${%s:-}" ]; then   # S6 H-S1/H-R1 (= S5 v101x/v101y contract): lease owned by the outer launcher; verify, never re-acquire, never release here' % var,
 '  [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "$LOCK" ] || die lease-fd-not-inherited 75 "%s set but fd 9 is not open on $LOCK"' % var,
 '  grep -q "^token=$%s " "$EX/LEASE_HOLDER" 2>/dev/null || die lease-holder-record-mismatch 75 "$EX/LEASE_HOLDER does not name token=$%s"' % (var, var),
 '  HP=$(sed -n "s/^token=[^ ]* holder_pid=\\([0-9]*\\) .*/\\1/p" "$EX/LEASE_HOLDER" 2>/dev/null); [ -n "$HP" ] && [ -d "/proc/$HP" ] || die lease-holder-gone 75 "holder pid=[$HP] not present"',
 '  echo "$(ts) lease INHERITED fd=9 path=$LOCK token=$%s holder_pid=$HP (outer launcher retains exclusion after this runner exits)" >> "$EXIT_RECORD"' % var,
 'else %s; fi' % die_busy,
]

# ---------------- F1: S6 setup runner v101y (from 8b1ae8c0) ----------------
L = load(D + "inputs/run-c5-setup-npm-ci.v101.sh", "8b1ae8c06a7484ca92d0b1ff93c22c933c824e372c308bbc58fea4764ef3dcf3")
assert L[0] == "#!/usr/bin/env bash"
rep(L, 200, 'echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d \' \') ppid=$PPID runner_sha256=',
    'echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d \' \') ppid=$PPID token=${S6_LEASE_INHERITED:-none} runner_sha256=$(sha256sum "$0" | cut -c1-64)" > "$EXIT_RECORD"   # S6 v101y (= S5 v101y / S5-V31-A-01 contract): exact current-attempt identity in the earliest publication')
rep(L, 202, 'exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"',
    INH("S6_LEASE_INHERITED", "", 'exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"'))
hdr = [
 "# OP88-S6-SETUP-EXCLUSION runner variant v101y (ADDITIVE successor of the frozen S6 setup consumer run-c5-setup-npm-ci.v101.sh 8b1ae8c0; original preserved byte-identical; NOT LAUNCHED;",
 "# no grant implied). ONLY delta, mirroring the accepted S5 V32 runner v101y 61b565e4 contract onto this consumer (S6_EXCLUSION_SCOPE_MAP H-S1 + S5-V31-A-01 START token): (1) the START",
 "# line (the runner's FIRST write, which truncates $EXIT_RECORD) additionally publishes token=${S6_LEASE_INHERITED:-none}, the inherited lease token only THIS attempt's runner received",
 "# from the outer launcher, so the launcher binds the shared record to this attempt by exact identity from the earliest publication on; (2) when S6_LEASE_INHERITED=<token> is set the",
 "# runner verifies fd 9 already open on $LOCK (readlink /proc/$$/fd/9), that $EX/LEASE_HOLDER names the same token and a live holder pid, writes the ` lease INHERITED fd=9 path=$LOCK",
 "# token=<t> holder_pid=<p> ` binding line and does NOT flock (the outer open-file description keeps the lease after this runner exits; the npm child still gets 9>&-). Without",
 "# S6_LEASE_INHERITED the v101 behaviour (own flock) is unchanged (else branch = the v101 L202 bytes). The runner's HOLD_BOUND/EXCLUSION_UNPRESERVED branch remains as evidence but is no",
 "# longer a release path under the launcher. Everything else is the v101 bytes: OWN-BLOCK v10.1 4aebf96f byte-identical, npm ci argv/env/pins, provenance gates, die/quarantine/finish.",
 "# Under the launcher the invoke line below is REPLACED by launch-s6-setup-exclusion.v1.sh (setsid nohup bash <launcher>; no outer timeout on the holder). v101 header follows.",
 "# [v101 header, retained] " + L[1][2:],
]
L[1:2] = hdr
open(D + "run-c5-setup-npm-ci.v101y.sh", "w").write("\n".join(L))

# ---------------- F2: S6 C6 runner v101y (from 2c9748a4) ----------------
L = load(D + "inputs/run-c6-hazard-v5-conly.v101.sh", "2c9748a468cef65779365b153e7d691120e1472d3e390b8a55f30e71103628c9")
assert L[0] == "#!/usr/bin/env bash"
old298 = '    if own_record "$att/IDENTITY" "step=$step pid=$CUR_PID attempt=${att##*/} pgid_sid=['
new298 = L[297].replace('"step=$step pid=$CUR_PID attempt=${att##*/} pgid_sid=[', '"pid=$CUR_PID step=$step attempt=${att##*/} pgid_sid=[', 1)
assert new298 != L[297]
rep(L, 298, old298, new298 + "   # S6 H-R2: field order only (pid= first, as the setup IDENTITY and the launcher's anchored `^pid=` read require); content unchanged")
rep(L, 339, 'echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d \' \') ppid=$PPID runner_sha256=',
    'echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d \' \') ppid=$PPID token=${S6_LEASE_INHERITED:-none} runner_sha256=$(sha256sum "$0" | cut -c1-64)" > "$EXIT_RECORD"   # S6 v101y (= S5 v101y / S5-V31-A-01 contract): exact current-attempt identity in the earliest publication')
rep(L, 341, '# canonical lock: acquired by the runner itself, held on fd 9 until the process exits (after all cleanup)',
    '# canonical lock: INHERITED on fd 9 from the outer launcher when S6_LEASE_INHERITED is set (verified, never re-acquired/released here); otherwise acquired by the runner itself and held on fd 9 until the process exits (after all cleanup)')
assert L[341] == 'exec 9>"$LOCK"'
assert L[342].startswith('flock -n 9 || die lock-busy 75 "canonical lock held by another owner; not a grant problem to solve here"')
assert L[343] == 'echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"'
L[341:344] = INH("S6_LEASE_INHERITED", "", 'exec 9>"$LOCK"; flock -n 9 || die lock-busy 75 "canonical lock held by another owner; not a grant problem to solve here"; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"')
hdr = [
 "# OP88-S6-C6-EXCLUSION runner variant v101y (ADDITIVE successor of the frozen S6 C6 consumer run-c6-hazard-v5-conly.v101.sh 2c9748a4; original preserved byte-identical; NOT LAUNCHED;",
 "# no grant implied). ONLY deltas, mirroring the accepted S5 V32 runner v101y 61b565e4 contract onto this consumer (S6_EXCLUSION_SCOPE_MAP H-R1 + H-R2 + S5-V31-A-01 START token):",
 "# (1) the START line (first, truncating write of c6.EXIT_RECORD) additionally publishes token=${S6_LEASE_INHERITED:-none}; (2) when S6_LEASE_INHERITED=<token> is set the runner verifies",
 "# fd 9 already open on $LOCK, that $EX/LEASE_HOLDER names the same token and a live holder pid, writes the ` lease INHERITED fd=9 path=$LOCK token=<t> holder_pid=<p> ` binding line and",
 "# does NOT flock (else branch = the v101 L342-L344 bytes incl. its lock-busy text; every gate child still gets 9>&-); (3) the per-step IDENTITY record starts `pid=<p> step=<s> attempt=…`",
 "# (field ORDER only; content unchanged) so the launcher's anchored `^pid=` read binds both the selftest and the C attempt. The runner's HOLD_BOUND/EXCLUSION_UNPRESERVED branch remains as",
 "# evidence but is no longer a release path under the launcher. Everything else is the v101 bytes: OWN-BLOCK v10.1 4aebf96f byte-identical, frozen C6 packet MANIFEST.c6.sha256 check,",
 "# hazard v5/adapter/instrument/classifier, Jest argv/selection/budgets, selftest-then-C sequencing, die/quarantine/finish. Under the launcher the invoke line below is REPLACED by",
 "# launch-s6-c6-exclusion.v1.sh (setsid nohup bash <launcher>; no outer timeout on the holder; frozen observer f140787a unused). v101 header follows.",
 "# [v101 header, retained] " + L[1][2:],
]
L[1:2] = hdr
open(D + "run-c6-hazard-v5-conly.v101y.sh", "w").write("\n".join(L))
print("runners derived")
