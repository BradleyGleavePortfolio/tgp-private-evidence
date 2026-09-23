#!/usr/bin/env bash
# S3 composed-lock release proof runner v5.8-s3 — EXEC-6c2a68ac S3-COMPOSED-PROOF-PREP (source-only, 2026-09-23). Derived from the ACCEPTED
# S2 v5.7 runner sha256 efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c (real proof: runner 0, 68/68, 48/48, seal bbde4b0b…).
# MINIMUM ADDITIVE BINDING SUCCESSOR: pins and lane paths only; every execution/refusal/assertion/cleanup/ownership/timeout/publication mechanism
# is byte-identical to v5.7. v5.8-s3 delta (see ../diffs/runner.diff and ../REPORT.md):
#   S3-1 target: WT=worktrees/s3-prep2, EXPECT_HEAD=be0ba827… (hooked two-parent commit), EXPECT_TREE=a584a1b9… (NEW check), EXPECT_LOCK_SHA=b7fed5ed…;
#        CLOSURE_REF=be0ba827… (the S3 install was made from the staged tree a584a1b9 that this commit carries, so the closure-identity check is
#        retained against the exact head rather than an ancestor).
#   S3-2 install binding: S3's node_modules was installed by the S3 lane (execution/6c2a68ac/s3-integration-result steps 02/03: `npm ci` from lock
#        b7fed5ed… raw 0, guarded `prisma generate` raw 0, v6.19.3) and legitimately has NO .s2-composition-install-stamp. The v5.7 stamp refusal
#        is REPLACED by an equivalent-strength binding to the actual installed graph: sha256 of node_modules/.package-lock.json must equal
#        EXPECT_INSTALLED_LOCK_SHA (observed 05bc530a…, mtime 16:44:09Z = the receipted npm ci end) AND the generated client must exist.
#        Nothing is fabricated; the S2-style stamp is neither written nor imitated. The conditional install_stamp echo is left in place (no-op).
#   S3-3 lane: fixture candidates/infra/s3-fixture-be0b.sh (NS=s3comp-be0b, PORT=54354, DB=s1_rls_s3comp_be0b); output lane
#        execution/6c2a68ac/s3-composed-proof (composition-s3/<utc>, runtime/); the stopped s2comp-r53 cluster is never touched.
#   S3-4 label: S1_R4_LOCK_HOLDER names this runner. Unchanged: EXPECT_PRISMA_CLI_SHA (S3's installed CLI bytes are the same c2a77456…),
#        steps 10–45, LEADER/adopt/halt/cleanup/receipt/publication code, stub seams (unused), relative-$0 self-stamp (invoke by ABSOLUTE path).
# ---- v5.7 header retained below for provenance ----
# S2 composition proof runner v5.7 — OP88-S2-V57. Derived (2026-09-22) from FROZEN v5.6 sha256 8980bca0936a34b25950f90bc97731d073c7d1dab95178ee80db8edb0d0e1de1
# (execution/op88/s2-v56, immutable). Execution-only successor closing the frozen V5.6 audits A (S2-V56-A01..A07) and B (D-01..D-05, R-1..R-3, P-01..P-03)
# where they touch this runner; no product/fixture/lockfile/stub change, no supervisor rewrite. v5.7 delta (FINDINGS_MAP_V57.md):
#   A02  inner manifest excludes ALL publication temporaries/outputs (SHA256SUMS*, RECEIPT.txt, PUBLICATION.txt) and the COMPLETED inner manifest is
#        re-verified (sha256sum -c) inside the same bounded pipeline before anything is certified.
#   A03  startup latch: PENDING_IDF/STEP_LABEL are set before the leader spawn and the interrupt handler recovers the just-spawned child from `$!`;
#        a pending published identity is awaited briefly (leader publishes within ms), adopted and group-signalled; an unpublished child gets a bounded
#        pid-only TERM/KILL and, if it survives, is an explicit survivor (never REAP ok). Leaders carry a marker (`: s2r57-step-leader;`) that is part
#        of the anchored owned-work scan, so an unreaped leader is visible. Same latch in owned_cleanup_cmd (cleanup clients).
#   A05  no unconditional wait on an unreaped child (cleanup client: alive after KILL → survivor, not waited); ANOMALY loops clipped to the cleanup
#        deadline (B R-2); the WHOLE publication tail (RECEIPT write+check, outer manifest write+verify) runs under ONE bounded `timeout -k 1`;
#        PUBLICATION.txt is written under its own small bound and its write is CHECKED (failure → 71); the actual exit is classified after all outcomes.
#   B R-1 interruption after ack: the registered identity is re-pointed (no duplicate registration) and the stamp says the workload MAY have started.
#   B R-3 receipt label `deadline_exceeded` (no `after_hash` claim).   A07: stub-mode private lock lives under $R57/runtime/ (enumerated write set).
#   Lane: execution/op88/s2-v57 (runner-selftest-r57/, composition-r57/, runtime/). Pins WT/LANE/EXPECT_* unchanged (restored per upstream-prereqs-2).
# ---- v5.6 header retained below for provenance ----
# S2 composition proof runner v5.6 — OP88-S2-V56 (S2-RUNNER-V5.6-PREP). Derived (2026-09-22) from FROZEN v5.5
# sha256 c3a4d2a9a234dda141122a44d46a3902a8575001a26ffcadc2029080a768de49 (s2-runner55, unchanged). Minimal correction of BOTH frozen v5.5
# reviews (A revision-1 fb91a51d…, B revision-1 8d35b223…); no product/fixture/lockfile/stub change, no supervisor rewrite. v5.6 delta (FINDINGS_MAP_V56.md):
#   F01 (A-01 / B-01) IDDIR: the trailing `IDDIR=` reset on the register line is removed; iddir_guard() proves IDDIR == "$OUT/.pgid", a directory,
#      and $OUT inside this lane before EVERY identity remove/write (no root path, no caller/lane-external path). Guard failure → refuse 70.
#   F02 (A-01 / A-02) one fail-closed startup contract for steps AND cleanup clients (LEADER text): the leader publishes its pid, exits 70 if the
#      publish fails, and does NOT exec the workload until the runner has registered the group and written an ack; no ack within ACK_WAIT → exit 70
#      with no workload ever started. Interruption resolves a published-but-unadopted identity (adopts it, group-signals) before any pid-only
#      fallback; an unconfirmed/dead cleanup client is never accepted as "empty" (cleanup_client_leak=yes → 71, rc 70).
#   F05 (A-05) receipt phase: the whole inner-manifest pipeline runs under one kill-after timeout bounded by the remaining deadline (no minimum
#      allowance once exhausted); RECEIPT.txt and SHA256SUMS.outer writes are status-checked and the outer manifest is re-verified; the actual
#      process exit is classified AFTER publication (a failed receipt/outer manifest/deadline-at-publication is never 0) and recorded in PUBLICATION.txt.
#   F06 (A-06) real mode: installed Prisma CLI existence + exact hash refusal now precede the first CLI (--version) execution.
#   Stub-mode-only seams for deterministic N5 controls (ignored in real mode): STUB_PUBLISH_FAIL=<label> (publish target unwritable),
#      STUB_HOLD_ACK=<label> (runner holds between reading the identity and adopting/acking until SIGTERM). Lane: execution/op88/s2-v56.
#   Unchanged: CHECKPOINT_DISABLE=1 export and explicit env -i carry, pins, steps 10–45, 164+1 harness, registers, quarantine, no destroy. v5.5 header follows.
# S2 composition proof runner v5.5 — S2-RUNNER-V5.5-PREP. Derived (2026-09-22) from FROZEN v5.4
# sha256 3f404479476c5b6a662c946268fd8ed59e3d69c867176431d921aca743604327 (execution/s2-runner54, unchanged). v5.5 delta (FINDINGS_MAP.md):
#   P1 (R54-A-04 / R54B-01) client boundary: CHECKPOINT_DISABLE=1 exported before any step and passed explicitly through the env -i refusal
#      steps; real mode binds the installed Prisma CLI bytes to EXPECT_PRISMA_CLI_SHA (grant05 stamp) and stamps the boundary. Scoped claim:
#      the optional Prisma checkpoint worker (fork detached:true) is excluded; arbitrary future setsid escapes remain OUTSIDE this claim.
#   P2 (R54-A §5 / R54B-02/-05) startup identity: each step leader publishes its own pid into an id file AFTER setsid and BEFORE exec; the
#      runner adopts only that self-published, invocation-created group; no id → the step is never accepted (rc kept if nonzero, else 70) and
#      only the pid is signalled, never a group; groups confirmed empty at quiescence are retired (pid-reuse safety); own pgid never targeted.
#   P3 (R54-A-02) fixture stop/status run as owned groups (same launcher) with a bounded post-exit census inside the cleanup deadline; any
#      member left → halted, counted as survivor → cleanup class 71.
#   P4 (R53-A-02 cont. / R54B-04) the cleanup deadline starts before the FIRST exceptional reap (quiescence failure, anomaly, signal, cleanup).
#   P5 (R54-A-03 / R54B-03) receipts: files are frozen before hashing; SHA256SUMS covers stamp/exit-codes/logs; RECEIPT.txt (post-hash timing,
#      hash status, authoritative final_exit) and SHA256SUMS.outer (hashes SHA256SUMS + RECEIPT.txt) are written afterwards and never mutate a
#      hashed file; a failed/over-deadline receipt forces cleanup class 71 and the process exit follows RECEIPT.txt.
#   Unchanged: pins, steps 10–45, 164+1 harness, first-vs-cleanup registers, quarantine posture, no destroy. v5.4 header follows.
# S2 composition proof runner v5.4 — S2-R54-EXECUTION-SAFETY. Derived (2026-09-22) from FROZEN v5.3.1
# sha256 fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925 (execution/s2-setup-prep, unchanged). v5.4 delta (FINDINGS_MAP.md):
#   O1 (A01/B01) every step group id is RETAINED in OWNED_PGIDS for the whole run; owned_scan covers all recorded groups (live members) plus the
#      unchanged anchored patterns (NOT widened); after each step's leader exits, a bounded post-exit quiescence check (QUIESCE_WAIT) must find
#      the group empty, otherwise the group is halted (TERM/KILL, bounded), the stage is refused (first_exit = step rc if nonzero else 70) and
#      the run ends via cleanup; halt targets are live groups, gated on group membership, never on the leader pid alone (inner 124 path).
#   O2 (A02) one elapsed cleanup deadline (CLEANUP_BUDGET s from cleanup/signal start): every reap poll, the fixture stop/status bounds and the
#      isolation-anomaly branch are clipped to the remaining time; no unconditional `wait` on a still-alive pid; deadline exhaustion is recorded
#      (deadline_exceeded=yes → cleanup class 71 at least); cleanup_seconds is measured before AND after the final evidence hashing.
#   O3 stub-mode-only: STUB_STEP40_BOUND may shorten step 40's bound so an inner-timeout counterexample fits a bounded control; ignored in real mode.
#   Unchanged: lock/fd-9 handling, target pins (head/lock/closure/fixture/NS/DB/PORT), steps 10–45 and the 164+1 harness, first-vs-cleanup exit
#   registers, refusal codes, quarantine posture (failed reap → fixture stop REFUSED, nothing erased), no destroy. v5.3.1 header follows.
# S2 composition proof runner v5.3.1 — S2-RUNNER-53 LANE. Derived (S2-SETUP-FIXTURE-PREP, 2026-09-22) from FROZEN v5.3
# sha256 fbc8b9af592b370429a66bf164d3c5ac0f0b1bac0f57474c50ac293ebebd1bfc (execution/s2-runner53, unchanged). v5.3.1 delta (see REPORT.md):
#   L1 lane paths: LANE=execution/s2-setup-prep, fixture infra/s2-fixture-r53.sh (REIMPLEMENTED fixture, sha pinned below; not 6062f4ce);
#   L2 fresh unique lane identity: NS=s2comp-r53, DB=s1_rls_s2comp_r53, PORT=54353 (was 54321; every listener/URL/confirm/scan literal now derives from $PORT);
#   L3 S2_FIXTURE_NS env export removed (fixture pins its own namespace; no env-controlled target);
#   L4 toolchain identity stamp (timeout/flock/setsid/pgrep implementations) — the sandbox `timeout` is uutils, not GNU (exit 15 vs 143 under group TERM, see s2-runner53 controls);
#   L5 output dirs composition-r53/ and runner-selftest-r531/. No other logic changed. v5.3 original header follows.
# S2 composition proof runner v5.3 — R3 LANE, EXECUTION-ONLY closure successor of v5.1 (sha256 0f4467e00c1ec878f4b8ff204a910d271a817a3c6bdc28a0df44f25023842e15).
# Source under test is UNCHANGED d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c (worktree /home/user/workspace/worktrees/s2-runner53). No product/harness/S1 edit.
#
# REIMPLEMENTATION NOTICE (G04): the v5.2 runner named in LAST_OPERATOR_STATE ("7e280683…5ccb") is NOT preserved in the named packet
# (b2-failed-and-r3-source/ holds v4.0/v4.1/v5.0/v5.1 only). v5.3 is therefore derived from the frozen v5.1 bytes plus the recorded
# counterexamples — 03A's TERM control (step child tree survives the runner; fixture stopped under a live harness; step mislabelled
# "notrun") and the state-recorded v5.2 limits (cleanup could take up to 25 s reap + 60 s stop > 60 s outer kill grace; fixture could be
# stopped after a FAILED reap). v5.3 does not claim to recover or contain v5.2 bytes.
#
# Closure implemented here (and only here):
#   1. every owned step runs in its OWN process group (setsid); the runner records pid/pgid/label of the live step;
#   2. TERM/INT/HUP → halt the live step's group (TERM, bounded reap; KILL, bounded reap), label it interrupted(<sig>), THEN cleanup;
#   3. a FAILED reap (any owned-work process survives) FORBIDS fixture stop / any further mutation: quarantine record, exit class 72,
#      "LOCK: NOT safely handed off"; nothing is erased;
#   4. cleanup is time-bounded by explicit constants whose worst case (48 s) fits the outer `timeout -k 60` grace with a 12 s margin;
#      fixture stop/status are wrapped in their own timeouts (the fixture script itself is used byte-for-byte, never edited);
#   5. the FIRST failing exit (or signal exit) is recorded separately from the CLEANUP exit; the process exit is the first failure
#      when there is one, otherwise the cleanup class (0 / 71 / 72). Both are always in exit-codes.txt and stamp.txt.
# Everything else (one nonblocking lock on fd 9 held from before fixture init through cleanup; fd 9 closed for every child except
# fixture init; refusals 64/64 before any server; fresh-only namespace / 54321 / no-postgres prechecks; pre-existing /tmp scratch
# files → REFUSE 70 untouched; anchored survivor scan; 75 lock busy; 70 refused precondition) is carried from v5.1.
#
# Offline self-test: S2_RUNNER_STUBS=<dir> swaps guard-spec/fixture/harness/discriminator for stub scripts, uses a lane-private lock
# and writes under runner-selftest-r53/ with a "STUB MODE — NOT EVIDENCE" banner. Refusal steps 20/21 still exercise the REAL harness's
# offline string layer (exit 64 before any psql/connection). Never for proof.
set -u
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s3-prep2   # S3-1: integrated S3 candidate worktree (S3 executor-owned; read/executed here, never written by this runner)
LANE=$ROOT/execution/6c2a68ac/s3-composed-proof-prep/candidates   # S3-3: frozen prep packet holding infra/s3-fixture-be0b.sh (hash-pinned below)
R57=$ROOT/execution/6c2a68ac/s3-composed-proof   # S3-3: this runner's output lane (variable name kept to leave F01 guard code untouched); every identity/output path must resolve under it
EXPECT_HEAD=be0ba8274e486dee77f15d18fe367a13ff08ecf5   # S3-1: hooked two-parent commit (parents d5cd9b8b + 5c7b42b3); no override
EXPECT_TREE=a584a1b95423f95dae8daabf673ef3776604acbb   # S3-1 (NEW): tree the S3 install/generate receipts were bound to (write-tree before/after every S3 step)
EXPECT_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # S3-1: integrated lock (deepmerge-ts 8.0.0; S2 was 62b05b90…/7.1.5)
EXPECT_INSTALLED_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44   # S3-2 (NEW): node_modules/.package-lock.json written by the receipted S3 `npm ci` (s3-integration-result step 02, 16:44:09Z)
EXPECT_PRISMA_CLI_SHA=c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0   # P1: installed prisma/build/index.js (6.19.3) recorded by grant05 setup-30; the checkpoint analysis (audits/s2-r54/a) is bound to these bytes
EXPECT_FIXTURE_SHA=9763698b9231af15648c1179df8c99d2e848f6738469cf4ebee8bff1259de21c   # S3-3: candidates/infra/s3-fixture-be0b.sh (accepted 9fcc3696 fixture with NS/PORT re-pinned only); refuse if absent/different
CLOSURE_REF=be0ba8274e486dee77f15d18fe367a13ff08ecf5   # S3-1: the S3 dependency closure was installed from this head's tree (a584a1b9); check retained against the exact head
DB=s1_rls_s3comp_be0b   # S3-3: within the S1 guard namespace ^s1_rls_[a-z0-9_]{1,40}$
NS=s3comp-be0b   # must equal the fixture's pinned NS (fixture is hash-pinned above)
PORT=54354      # must equal the fixture's pinned PORT; lane-unique (S2 lanes 54321/54353, S5 54325)
unset S2_KEEP_FIXTURE
export CHECKPOINT_DISABLE=1   # P1: inherited by every step (setsid/timeout/bash/env/npx/node pass the environment; consumers use no env -i/-u)
# ---- cleanup budget (seconds). Outer launch is `timeout --foreground -k 60 2100`: TERM at 2100 s, KILL 60 s later.
OUTER_GRACE=60; REAP_TERM_WAIT=10; REAP_KILL_WAIT=5; STOP_BUDGET=20; STOP_KILL=3; STATUS_BUDGET=5; STATUS_KILL=2; SCAN_HASH_ALLOW=3
CLEANUP_BUDGET=50; QUIESCE_WAIT=2; ANOMALY_WAIT=3   # O2: single elapsed deadline for the whole cleanup (< OUTER_GRACE); O1: post-exit group quiescence; isolation-anomaly bound
WORST=$((REAP_TERM_WAIT+REAP_KILL_WAIT+STOP_BUDGET+STOP_KILL+STATUS_BUDGET+STATUS_KILL+SCAN_HASH_ALLOW)); MARGIN=$((OUTER_GRACE-WORST))
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
STUBS=${S2_RUNNER_STUBS-}
if [ -n "$STUBS" ]; then
  mkdir -p "$R57/runtime"; LOCK=$R57/runtime/test-validation.lock; OUT=$R57/runner-selftest-r57/$STAMP   # A07: lane-private lock in the enumerated runtime/ write set (never $STUBS, never canonical)
  GUARD_SPEC="bash $STUBS/guard-spec.sh"; FIXTURE="bash $STUBS/fixture.sh"; HARNESS="bash $STUBS/harness.sh"; DISC="bash $STUBS/discriminator.sh"
  REFUSAL_HARNESS="bash $WT/test/release/s1s2-composition.sh"   # real offline refusal path is cheap and DB-free
  OWNED_PAT="^bash $STUBS/|^s2r53-stub-escapee|^bash $WT/test/release/s1s2-composition.sh|^bash -c : s2r57-step-leader;"   # A03: an unreaped step/cleanup leader is visible to the scan
else
  LOCK=$ROOT/execution/test-validation.lock; OUT=$R57/composition-s3/$STAMP
  GUARD_SPEC="bash test/db/s1-harness-guard.spec.sh"; FIXTURE="bash $LANE/infra/s3-fixture-be0b.sh"
  HARNESS="bash test/release/s1s2-composition.sh"; DISC="bash test/db/s1-r4-truncate-discriminator.sh"; REFUSAL_HARNESS=$HARNESS
  OWNED_PAT="^bash test/db/s1-harness-guard.spec.sh|^bash test/release/s1s2-composition.sh|^bash test/db/s1-r4-truncate-discriminator.sh|^psql .*(127\.0\.0\.1:$PORT|-p $PORT)|^node .*prisma/build/index.js"
fi
FIXTURE_PAT="^/home/user/pg17/dist/bin/postgres|^postgres: s1-disposable-pg17"
mkdir -p "$OUT"; IDDIR="$OUT/.pgid"; mkdir -p "$IDDIR"   # P2/F01: self-published step identities; initialised ONCE here and never reassigned
S="$OUT/stamp.txt"
stamp(){ echo "$*" | tee -a "$S"; }
lock_probe(){ if flock -n "$LOCK" true 2>/dev/null; then echo FREE; else echo HELD; fi; }
[ -n "$STUBS" ] && stamp "STUB MODE — NOT EVIDENCE (stubs=$STUBS, private lock=$LOCK)"

# ---- result registers. FIRST_EXIT = first failing step / signal; CLEANUP_EXIT = cleanup class; FINAL derived in cleanup, never an unconditional 0.
FIRST_EXIT=unset; CLEANUP_EXIT=unset; FINAL=1; SIGNAL=none; REAP=unchecked; RC_STOP=notrun; SURVIVORS=unchecked; FIXTURE_STARTED=0; CLEANUP_T0=
RC_GUARD=notrun; RC_R20=notrun; RC_R21=notrun; RC_FIXTURE=notrun; RC_COMP=notrun; RC_DISC=notrun
STEP_LABEL=none; STEP_PID=; STEP_PGID=; OWNED_PGIDS=; RETIRED_PGIDS=; DEADLINE_EXCEEDED=no; CLEANUP_DEADLINE=; MY_PGID=$(ps -o pgid= -p $$ | tr -d ' '); PARENT_PGID=$(ps -o pgid= -p $PPID 2>/dev/null | tr -d ' ')   # F01: no IDDIR reset here
iddir_guard(){   # F01 (A-01/B-01): before EVERY identity remove/write — IDDIR must be exactly "$OUT/.pgid", a directory, and $OUT must lie inside this lane
  case ${IDDIR-} in "$OUT/.pgid") ;; *) stamp "${1-}: IDDIR guard FAILED: IDDIR='${IDDIR-}' != '$OUT/.pgid' → refuse, nothing removed/written"; return 1;; esac
  case $OUT in "$R57"/*/*) ;; *) stamp "${1-}: IDDIR guard FAILED: OUT='$OUT' is not an invocation subdirectory of lane $R57 → refuse"; return 1;; esac
  [ -d "$IDDIR" ] || { stamp "${1-}: IDDIR guard FAILED: '$IDDIR' is not a directory → refuse"; return 1; }
}
# F02: shared leader text for steps and cleanup clients. After setsid: publish own pid (== session/group id) or exit 70; then WAIT for the runner's
# adoption ack ("<idfile>.ack") before exec — no ack within ACK_WAIT_TICKS×0.02 s → exit 70 and the workload is never started. Args: idfile ticks timeout-args…
ACK_WAIT_TICKS=150   # 3 s; the runner's identity poll is ≤ 2 s (40 × 0.05 s)
LEADER=': s2r57-step-leader; echo $$ > "$1" || exit 70; i=0; while [ ! -e "$1.ack" ]; do i=$((i+1)); [ "$i" -gt "$2" ] && exit 70; sleep 0.02; done; shift 2; exec timeout --foreground "$@"'   # A03: marker makes the leader cmdline scannable
PENDING_IDF=   # A03 latch: set before a leader spawn, cleared once STEP_PID/adoption bookkeeping holds the child; read by halt_owned_work
ADOPTED=; PUBLISHED=
adopt_published(){   # adopt_published <idfile> <pid> <label>: poll the self-published identity, validate (== pid, never own/caller group), REGISTER, then ack.
  local idf=$1 pid=$2 label=$3 pg= i; ADOPTED=   # returns 0 adopted (ADOPTED=pgid) | 1 not adoptable (ADOPTED empty) | 2 registered but ack failed (ADOPTED=pgid, TERM sent)
  for ((i=0;i<40;i++)); do [ -f "$idf" ] && [ -s "$idf" ] && { pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; kill -0 "$pid" 2>/dev/null || { sleep 0.05; [ -f "$idf" ] && [ -s "$idf" ] && pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; sleep 0.05; done   # -f: a non-regular path (N5a seam: directory) is NOT a publication; keep polling until the leader exits 70
  PUBLISHED=$pg
  [ -n "$pg" ] && { [ "$pg" = "$MY_PGID" ] || [ "$pg" = "$PARENT_PGID" ]; } && { stamp "$label: published identity $pg equals the runner's/caller's group → REJECTED (never adopted, never acked)"; return 1; }   # P2
  [ "$pg" = "$pid" ] || return 1
  if [ -n "$STUBS" ] && [ "${STUB_HOLD_ACK-}" = "$label" ]; then stamp "SEAM: $label identity $pg read; HOLDING before adoption/ack (stub seam STUB_HOLD_ACK) until a signal arrives"; while :; do sleep 0.1; done; fi   # N5b seam, stub mode only
  OWNED_PGIDS="$OWNED_PGIDS $pg"   # registered BEFORE the ack: the leader cannot exec until it is already a group signal target
  if : > "$idf.ack" 2>/dev/null; then ADOPTED=$pg; return 0; fi
  ADOPTED=$pg; deadline_start "ack-$label"; stamp "$label: identity $pg registered but the ack write FAILED → leader will not exec (self-exits 70); halting the registered group"; kill -TERM -- "-$pg" 2>/dev/null; return 2
}
deadline_start(){ [ -n "$CLEANUP_DEADLINE" ] || { CLEANUP_T0=$(date +%s.%N); CLEANUP_DEADLINE=$(( $(now_s) + CLEANUP_BUDGET )); stamp "DEADLINE: cleanup deadline started ($CLEANUP_BUDGET s) reason=$1"; }; }   # P4
now_s(){ date +%s; }
remaining(){ local r; [ -n "$CLEANUP_DEADLINE" ] || { echo 999; return; }; r=$((CLEANUP_DEADLINE-$(now_s))); [ $r -gt 0 ] && echo $r || echo 0; }   # pure (safe in subshells)
deadline_check(){ [ -n "$CLEANUP_DEADLINE" ] && [ "$(now_s)" -ge "$CLEANUP_DEADLINE" ] && DEADLINE_EXCEEDED=yes; :; }   # sets the flag in the main shell
live_groups(){ local g; for g in $OWNED_PGIDS; do { [ "$g" = "$MY_PGID" ] || [ "$g" = "$PARENT_PGID" ]; } && continue; pgrep -g "$g" >/dev/null 2>&1 && echo "$g"; done; }   # P2: never the runner's own group
retire_group(){ local g x rest=; for x in $OWNED_PGIDS; do [ "$x" = "$1" ] || rest="$rest $x"; done; OWNED_PGIDS=$rest; RETIRED_PGIDS="$RETIRED_PGIDS $1"; }   # P2: confirmed-empty groups leave the target set (pid reuse)
finish(){ FIRST_EXIT=$1; exit; }   # EXIT trap → cleanup decides the process exit

# ---- owned-work scan: processes of the live step's group plus anchored owned-work cmdlines (never the fixture server; never platform/unowned processes)
owned_scan(){   # O1: every recorded step group (live members) + anchored owned-work cmdlines; patterns deliberately NOT widened
  { local g; for g in $OWNED_PGIDS; do [ "$g" = "$MY_PGID" ] || pgrep -g "$g" -a 2>/dev/null; done; [ -n "${STEP_PID:-}" ] && kill -0 "$STEP_PID" 2>/dev/null && ps -o pid=,args= -p "$STEP_PID"; pgrep -af "$OWNED_PAT" 2>/dev/null; } | grep -vE "^[0-9]+ (pgrep|grep) " | awk -v me=$$ '$1!=me' | sort -u
}
# poll_until_quiet <max_s>: returns 0 when owned_scan is empty; bounded by max_s AND by the cleanup deadline (O2)
poll_until_quiet(){ local end=$(( $(now_s) + $1 )) lim; while :; do [ -z "$(owned_scan)" ] && return 0; lim=$end; [ -n "$CLEANUP_DEADLINE" ] && [ "$CLEANUP_DEADLINE" -lt "$lim" ] && lim=$CLEANUP_DEADLINE; [ "$(now_s)" -ge "$lim" ] && { deadline_check; return 1; }; sleep 0.1; done; }
# halt_owned_work: TERM the live step's group, bounded reap; then KILL, bounded reap. Sets REAP=ok|FAILED. Signals ONLY the recorded group.
halt_owned_work(){   # O1/O2: targets = every recorded group that still has members (not the leader pid); bounded, deadline-clipped; no blocking wait
  local t0=$(now_s) left groups g
  deadline_start halt   # P4: a reap is exceptional work; the deadline is running before the first signal
  # A03 latch: a signal handled between the leader spawn and `STEP_PID=$!` finds STEP_PID empty but PENDING_IDF set → recover the child from `$!`
  # (bash sets `$!` at fork time), so the just-spawned leader is never outside the halt's knowledge.
  local lastbg=${!-}
  if [ -z "${STEP_PID:-}" ] && [ -n "$PENDING_IDF" ] && [ -n "$lastbg" ] && kill -0 "$lastbg" 2>/dev/null; then STEP_PID=$lastbg; stamp "HALT: pending leader pid=$STEP_PID (spawned for '$STEP_LABEL', not yet booked) recovered from \$! → resolved below"; fi
  if [ -n "${STEP_PID:-}" ] && kill -0 "$STEP_PID" 2>/dev/null && ! echo " $OWNED_PGIDS " | grep -q " ${STEP_PGID:-none} "; then
    # F02 (A-02): resolve the CURRENT published identity first — a leader that published but was not yet adopted is adopted now and group-signalled;
    # only a leader with no published identity gets the bounded pid-only fallback (it has not exec'd: no ack → no workload).
    # A03: the leader publishes within milliseconds of the spawn — wait briefly (≤ 0.5 s, deadline-clipped) for a pending publication before deciding.
    local pub= idf="$IDDIR/$STEP_LABEL.pgid" i
    for ((i=0;i<10;i++)); do [ -f "$idf" ] && [ -s "$idf" ] && { pub=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; kill -0 "$STEP_PID" 2>/dev/null || break; [ "$(now_s)" -ge "$CLEANUP_DEADLINE" ] && break; sleep 0.05; done
    [ -n "$STEP_LABEL" ] && [ "$STEP_LABEL" != none ] || pub=
    if [ -n "$pub" ] && [ "$pub" = "$STEP_PID" ] && [ "$pub" != "$MY_PGID" ] && [ "$pub" != "$PARENT_PGID" ]; then
      if echo " $OWNED_PGIDS " | grep -q " $pub "; then STEP_PGID=$pub; stamp "HALT: in-flight step '$STEP_LABEL' pid=$STEP_PID identity $pub already REGISTERED (ack $([ -e "$idf.ack" ] && echo written → workload MAY have started || echo not written → workload never started)) → pointer restored, signalled as a group"   # B R-1: no duplicate registration, truthful wording
      else OWNED_PGIDS="$OWNED_PGIDS $pub"; STEP_PGID=$pub; stamp "HALT: in-flight step '$STEP_LABEL' pid=$STEP_PID had a PUBLISHED but unadopted identity $pub → adopted now and signalled as a group (never acked → workload never started)"; fi
    else
      # P2/A03 fallback: no published identity → bounded pid-only TERM/KILL; a child that survives is an explicit survivor (scan sees the leader marker) — never REAP ok
      stamp "HALT: in-flight step '$STEP_LABEL' pid=$STEP_PID has no published identity (published='${pub:-none}') → SIGTERM/SIGKILL by pid only (never a group; unacked leader cannot have exec'd), bounded ≤${ANOMALY_WAIT}s"; kill -TERM "$STEP_PID" 2>/dev/null
      local e=$(( $(now_s) + ANOMALY_WAIT )); while kill -0 "$STEP_PID" 2>/dev/null && [ "$(now_s)" -lt "$e" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done
      kill -0 "$STEP_PID" 2>/dev/null && { kill -KILL "$STEP_PID" 2>/dev/null; sleep 0.2; }
      if kill -0 "$STEP_PID" 2>/dev/null; then stamp "HALT: unpublished child pid=$STEP_PID STILL ALIVE after KILL → not waited on; counted as survivor (unsafe handoff)"; else wait "$STEP_PID" 2>/dev/null; stamp "HALT: unpublished child pid=$STEP_PID reaped (wait status $?)"; STEP_PID=; fi
    fi
  fi
  PENDING_IDF=
  groups=$(live_groups)
  if [ -n "$groups" ]; then
    stamp "HALT: live owned groups [$(echo $groups)] (current step '$STEP_LABEL' pid=${STEP_PID:-none}) → SIGTERM to each group (reap wait ≤${REAP_TERM_WAIT}s, remaining ${CLEANUP_DEADLINE:+$(remaining)s}${CLEANUP_DEADLINE:-unbounded-pre-cleanup})"
    for g in $groups; do kill -TERM -- "-$g" 2>/dev/null; done
    if ! poll_until_quiet "$REAP_TERM_WAIT"; then
      groups=$(live_groups); stamp "HALT: owned work still present after TERM → SIGKILL to groups [$(echo $groups)] (reap wait ≤${REAP_KILL_WAIT}s)"
      for g in $groups; do kill -KILL -- "-$g" 2>/dev/null; done
      poll_until_quiet "$REAP_KILL_WAIT" || true
    fi
    if [ -n "${STEP_PID:-}" ]; then
      if kill -0 "$STEP_PID" 2>/dev/null; then stamp "HALT: step child pid=$STEP_PID STILL ALIVE after KILL budget — not waiting on it (unreapable/blocked); counted as survivor"
      else wait "$STEP_PID" 2>/dev/null; stamp "HALT: step child pid=$STEP_PID reaped (wait status $?) after $(( $(now_s)-t0 ))s"; fi
    fi
  fi
  left=$(owned_scan)
  if [ -n "$left" ]; then REAP=FAILED; stamp "REAP FAILED: owned-work processes survive (listed in QUARANTINE.txt):"; echo "$left" | sed 's/^/  survivor: /' | tee -a "$S" > "$OUT/QUARANTINE.txt"
  else REAP=ok; stamp "REAP ok: no owned-work process survives (owned groups [$(echo ${OWNED_PGIDS:-none})] retired [$(echo ${RETIRED_PGIDS:-none})], anchored scan)"; fi
  STEP_PID=; STEP_PGID=
}
on_signal(){
  local sig=$1 code
  trap '' TERM INT HUP
  SIGNAL=$sig; deadline_start "signal-$sig"   # P4/O2
  case $sig in TERM) code=143;; INT) code=130;; HUP) code=129;; *) code=1;; esac
  stamp "SIGNAL SIG$sig at $(date -u +%FT%TZ) during step '$STEP_LABEL' (pid=${STEP_PID:-none} pgid=${STEP_PGID:-none}); owned work halts BEFORE any fixture stop; first_exit=$code (outer timeout itself reports 124)"
  case $STEP_LABEL in 10*) RC_GUARD="interrupted($sig)";; 20*) RC_R20="interrupted($sig)";; 21*) RC_R21="interrupted($sig)";;
    30*|31*|32*) RC_FIXTURE="interrupted($sig)";; 40*) RC_COMP="interrupted($sig)";; 45*) RC_DISC="interrupted($sig)";; esac
  halt_owned_work
  finish "$code"
}

# run_step <label> <bound_s> <log> [--inherit-fd9] -- <cmd...> : own process group per step; fd 9 closed unless --inherit-fd9 (fixture init only)
run_step(){
  local label=$1 bound=$2 log=$3; shift 3
  local inherit=0; [ "${1-}" = --inherit-fd9 ] && { inherit=1; shift; }; [ "${1-}" = -- ] && shift
  STEP_LABEL=$label
  # P2/F01/F02: the leader publishes ITS OWN pid (== new session/group id) after setsid, then waits for the runner's ack before exec (LEADER text)
  iddir_guard "$label" || finish 70
  local idf="$IDDIR/$label.pgid"; rm -f "$idf" "$idf.ack"
  if [ -n "$STUBS" ] && [ "${STUB_PUBLISH_FAIL-}" = "$label" ]; then mkdir -p "$idf"; stamp "SEAM: $label publish target made unwritable (stub seam STUB_PUBLISH_FAIL: a directory occupies the id-file path)"; fi   # N5a seam, stub mode only
  PENDING_IDF=$idf; STEP_PID=; STEP_PGID=   # A03: latch armed BEFORE the spawn; halt_owned_work recovers the child from $! if a signal lands before the next line completes
  if [ $inherit = 1 ]; then setsid bash -c "$LEADER" _ "$idf" "$ACK_WAIT_TICKS" "$bound" "$@" >"$log" 2>&1 &
  else setsid bash -c "$LEADER" _ "$idf" "$ACK_WAIT_TICKS" "$bound" "$@" >"$log" 2>&1 9>&- & fi
  STEP_PID=$!; STEP_PGID=; PENDING_IDF=   # child booked; the latch is disarmed (STEP_PID now carries it)
  adopt_published "$idf" "$STEP_PID" "$label"; local ad=$?
  if [ $ad -eq 2 ]; then STEP_PGID=$ADOPTED; halt_owned_work; STEP_PID=; STEP_PGID=; finish 70; fi   # registered group, ack failed → bounded group halt, refuse
  if [ $ad -ne 0 ]; then
    if kill -0 "$STEP_PID" 2>/dev/null; then
      # identity not published by a live child → not ours to group-signal: TERM/KILL by pid only (bounded), refuse 70, record nothing as a group
      deadline_start anomaly; stamp "$label: IDENTITY ANOMALY pid=$STEP_PID published='${PUBLISHED:-none}' (not adoptable; never acked → workload never started) → TERM by pid only (≤${ANOMALY_WAIT}s), refuse (70)"; kill -TERM "$STEP_PID" 2>/dev/null
      for ((i=0;i<ANOMALY_WAIT*10;i++)); do kill -0 "$STEP_PID" 2>/dev/null || break; [ "$(now_s)" -ge "$CLEANUP_DEADLINE" ] && break; sleep 0.1; done   # B R-2: deadline-clipped
      if kill -0 "$STEP_PID" 2>/dev/null; then kill -KILL "$STEP_PID" 2>/dev/null; for ((i=0;i<10;i++)); do kill -0 "$STEP_PID" 2>/dev/null || break; sleep 0.1; done; fi
      if kill -0 "$STEP_PID" 2>/dev/null; then stamp "$label: anomaly pid=$STEP_PID still alive after KILL; listed as survivor, no group adopted"; else wait "$STEP_PID" 2>/dev/null; fi
      STEP_PGID=; finish 70
    fi
    wait "$STEP_PID" 2>/dev/null; local rc0=$?
    stamp "$label: leader pid=$STEP_PID exited rc=$rc0 WITHOUT an adoptable published identity → stage NOT accepted; unacked leader never exec'd (unknown acquisition is never certified empty)"
    STEP_PID=; STEP_PGID=; [ "$rc0" -ne 0 ] && finish "$rc0" || finish 70
  fi
  STEP_PGID=$ADOPTED   # O1/P2/F02: invocation-created, self-published group, registered in OWNED_PGIDS and acked by adopt_published; retained until confirmed empty
  wait "$STEP_PID"; local rc=$?
  [ "$SIGNAL" != none ] && return 1   # a trapped signal already took over; never record this rc
  # O1: post-exit quiescence — the leader (timeout) exited; the GROUP must be empty before the stage counts as finished
  local end=$(( $(now_s) + QUIESCE_WAIT )) left
  while pgrep -g "$STEP_PGID" >/dev/null 2>&1 && [ "$(now_s)" -lt "$end" ]; do sleep 0.1; done
  left=$(pgrep -g "$STEP_PGID" -a 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) ")
  if [ -n "$left" ]; then
    deadline_start "quiescence-$label"   # P4: deadline runs BEFORE the first exceptional reap
    stamp "$label: leader pid=$STEP_PID exited rc=$rc but group $STEP_PGID still has members after ${QUIESCE_WAIT}s → stage NOT accepted; halting the group (owned survivors after step exit):"; echo "$left" | sed 's/^/  member: /' | tee -a "$S"
    halt_owned_work
    [ "$rc" -ne 0 ] && finish "$rc" || finish 70
  fi
  retire_group "$STEP_PGID"   # P2: confirmed empty → no longer a signal target
  STEP_PID=; STEP_PGID=; STEP_LABEL=none
  return $rc
}
# owned_cleanup_cmd <label> <bound> <kill> <log> -- <cmd...> : P3 — cleanup-phase client (fixture stop/status) in its own self-published group,
# bound clipped to the cleanup deadline, followed by a bounded group census; leftovers are halted and counted as survivors. Returns the cmd rc.
owned_cleanup_cmd(){
  local label=$1 bound=$2 kill=$3 log=$4; shift 4; [ "${1-}" = -- ] && shift
  iddir_guard "$label" || { stamp "$label: cleanup client NOT started (identity directory guard failed) → cleanup failure"; CLEANUP_LEAK=yes; return 70; }   # F01
  local idf="$IDDIR/$label.pgid" pid pg rc left ad e; rm -f "$idf" "$idf.ack"
  setsid bash -c "$LEADER" _ "$idf" "$ACK_WAIT_TICKS" -k "$kill" "$bound" "$@" >"$log" 2>&1 9>&- &   # F02: same fail-closed leader contract as run_step
  pid=$!; adopt_published "$idf" "$pid" "$label"; ad=$?; pg=$ADOPTED
  if [ $ad -ne 0 ]; then
    # F02 (A-02 / B-04): an unconfirmed cleanup client is never accepted as "empty": bounded halt (group if registered, else pid only), then cleanup failure
    if [ $ad -eq 2 ]; then e=$(( $(now_s) + ANOMALY_WAIT )); while pgrep -g "$pg" >/dev/null 2>&1 && [ "$(now_s)" -lt "$e" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done; pgrep -g "$pg" >/dev/null 2>&1 && { kill -KILL -- "-$pg" 2>/dev/null; sleep 0.3; }   # B R-2: deadline-clipped
      pgrep -g "$pg" >/dev/null 2>&1 && { CLEANUP_SURVIVOR_GROUPS="${CLEANUP_SURVIVOR_GROUPS-} $pg"; stamp "$label: registered group $pg STILL has members after KILL"; }
    elif kill -0 "$pid" 2>/dev/null; then stamp "$label: cleanup client pid=$pid alive without an adoptable identity (published='${pg:-none}') → TERM/KILL by pid only (≤${ANOMALY_WAIT}s), never a group"; kill -TERM "$pid" 2>/dev/null
      e=$(( $(now_s) + ANOMALY_WAIT )); while kill -0 "$pid" 2>/dev/null && [ "$(now_s)" -lt "$e" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done; kill -0 "$pid" 2>/dev/null && { kill -KILL "$pid" 2>/dev/null; sleep 0.3; }   # B R-2: deadline-clipped
    fi
    # A05: NO unconditional wait — a client still alive after KILL is an explicit survivor (scan sees the leader marker / group), not something to block on
    if kill -0 "$pid" 2>/dev/null; then rc=unreaped; CLEANUP_SURVIVOR_PIDS="${CLEANUP_SURVIVOR_PIDS-} $pid"; stamp "$label: cleanup client pid=$pid STILL ALIVE after KILL → not waited on; counted as survivor"; else wait "$pid" 2>/dev/null; rc=$?; fi
    CLEANUP_LEAK=yes; stamp "$label: cleanup client NOT accepted (leader exit rc=$rc, identity unconfirmed → workload never acked/started) → cleanup failure (never 'empty'), client rc reported as 70"
    return 70
  fi
  wait "$pid" 2>/dev/null; rc=$?
  if [ -n "$pg" ] && [ "$pg" = "$pid" ]; then
    local end=$(( $(now_s) + QUIESCE_WAIT )); while pgrep -g "$pg" >/dev/null 2>&1 && [ "$(now_s)" -lt "$end" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done
    left=$(pgrep -g "$pg" -a 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) ")
    if [ -n "$left" ]; then
      stamp "$label: client exited rc=$rc but its group $pg still has members → SIGTERM/SIGKILL group (bounded), counted as cleanup survivors:"; echo "$left" | sed 's/^/  member: /' | tee -a "$S"
      kill -TERM -- "-$pg" 2>/dev/null; local e2=$(( $(now_s) + 3 )); while pgrep -g "$pg" >/dev/null 2>&1 && [ "$(now_s)" -lt "$e2" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done
      pgrep -g "$pg" >/dev/null 2>&1 && { kill -KILL -- "-$pg" 2>/dev/null; sleep 0.3; }
      pgrep -g "$pg" >/dev/null 2>&1 && { CLEANUP_SURVIVOR_GROUPS="${CLEANUP_SURVIVOR_GROUPS-} $pg"; stamp "$label: group $pg STILL has members after KILL"; } || { stamp "$label: group $pg census empty after halt (but the client leaked: cleanup failure)"; CLEANUP_LEAK=yes; }
    else stamp "$label: group $pg census empty after exit (owned client fully reaped)"; retire_group "$pg"; fi
  fi   # B-04: the former unreachable `kill -0` after `wait` branch is removed; the unconfirmed path is handled above BEFORE wait
  return $rc
}
CLEANUP_LEAK=no; CLEANUP_SURVIVOR_GROUPS=; CLEANUP_SURVIVOR_PIDS=   # A05: unreaped cleanup-client pids are listed as survivors, never waited on

cleanup(){
  trap - EXIT; trap '' TERM INT HUP
  deadline_start cleanup   # P4: no-op if a signal/quiescence failure/anomaly already started it
  [ "$FIRST_EXIT" = unset ] && FIRST_EXIT=1
  stamp "CLEANUP begin $(date -u +%FT%TZ) first_exit=$FIRST_EXIT signal=$SIGNAL lock=$(lock_probe) (held by this runner) budget: reap ${REAP_TERM_WAIT}+${REAP_KILL_WAIT}s, stop ${STOP_BUDGET}+${STOP_KILL}s, status ${STATUS_BUDGET}+${STATUS_KILL}s, scan/hash ${SCAN_HASH_ALLOW}s → worst ${WORST}s; ENFORCED elapsed deadline ${CLEANUP_BUDGET}s (remaining $(remaining)s) of outer grace ${OUTER_GRACE}s"
  # Owned work must be gone BEFORE the fixture is touched — on the normal path as well as after a signal.
  [ "$REAP" = unchecked ] && halt_owned_work
  if [ "$REAP" = FAILED ]; then
    CLEANUP_EXIT=72; RC_STOP=REFUSED
    stamp "QUARANTINE: owned work not reaped → fixture stop REFUSED, no further mutation (fixture_started=$FIXTURE_STARTED). Nothing erased. Parent must inspect QUARANTINE.txt before any other slot."
  elif [ "$FIXTURE_STARTED" != 0 ] && [ "${S2_KEEP_FIXTURE:-0}" != 1 ]; then
    # Stop attempted whenever a start was ATTEMPTED. Bounded here (the fixture's own pg_ctl -w default is 60 s, which alone would exceed outer grace).
    local sb=$STOP_BUDGET rem; rem=$(remaining); [ $((rem-STOP_KILL-STATUS_BUDGET-STATUS_KILL-SCAN_HASH_ALLOW)) -lt $sb ] && sb=$((rem-STOP_KILL-STATUS_BUDGET-STATUS_KILL-SCAN_HASH_ALLOW))   # O2: clip to remaining deadline
    if [ "$sb" -lt 3 ]; then RC_STOP="SKIPPED(deadline)"; DEADLINE_EXCEEDED=yes; stamp "50 fixture-stop SKIPPED: cleanup deadline leaves ${rem}s (<3 s usable); fixture left as is, reported as cleanup failure"
    else
      owned_cleanup_cmd 50-fixture-stop "$sb" "$STOP_KILL" "$OUT/50-fixture-stop.log" -- $FIXTURE stop; RC_STOP=$?   # P3: owned group + census
      stamp "50 fixture-stop exit=$RC_STOP (124=stop bound ${sb}s exceeded; nominal ${STOP_BUDGET}s) $(tail -1 "$OUT/50-fixture-stop.log" 2>/dev/null)"
      rem=$(remaining); if [ "$rem" -ge $((STATUS_BUDGET+STATUS_KILL+SCAN_HASH_ALLOW)) ]; then owned_cleanup_cmd 51-fixture-status "$STATUS_BUDGET" "$STATUS_KILL" "$OUT/51-fixture-status-after-stop.log" -- $FIXTURE status; stamp "51 fixture-status-after-stop: $(head -1 "$OUT/51-fixture-status-after-stop.log")"; else stamp "51 fixture-status SKIPPED (remaining ${rem}s)"; fi
    fi
  fi
  # process evidence: fixture postgres, any owned-work child, any $PORT listener (anchored cmdline starts; see v4.1 false-positive note)
  SURVIVORS=$( { local g p; for g in $OWNED_PGIDS $CLEANUP_SURVIVOR_GROUPS; do [ "$g" = "$MY_PGID" ] || pgrep -g "$g" -a 2>/dev/null; done; for p in $CLEANUP_SURVIVOR_PIDS ${STEP_PID:-}; do kill -0 "$p" 2>/dev/null && ps -o pid=,args= -p "$p" 2>/dev/null; done; pgrep -af "$FIXTURE_PAT|$OWNED_PAT" 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) " | awk -v me=$$ '$1!=me'; ss -ltnH 2>/dev/null | grep -E ":${PORT}\b"; } | sort -u | sed 's/^/  survivor: /' )
  [ "$CLEANUP_LEAK" = yes ] && { SURVIVORS="$SURVIVORS
  survivor: (cleanup client leaked members; halted — see 50/51 lines)"; }
  if [ -n "$SURVIVORS" ]; then stamp "CLEANUP: surviving processes/listeners after cleanup:"; echo "$SURVIVORS" | tee -a "$S"; SURVIVORS=present; else SURVIVORS=none; stamp "CLEANUP: no surviving fixture/owned-work processes, nothing listening on $PORT"; fi
  if [ "$CLEANUP_EXIT" = unset ]; then
    deadline_check; if { [ "$RC_STOP" != notrun ] && [ "$RC_STOP" != 0 ]; } || [ "$SURVIVORS" = present ] || [ "$DEADLINE_EXCEEDED" = yes ] || [ "$CLEANUP_LEAK" = yes ]; then CLEANUP_EXIT=71; stamp "CLEANUP FAILURE: class 71 (stop_exit=$RC_STOP survivors=$SURVIVORS deadline_exceeded=$DEADLINE_EXCEEDED cleanup_client_leak=$CLEANUP_LEAK)"; else CLEANUP_EXIT=0; fi
  fi
  if [ "$FIRST_EXIT" != 0 ]; then FINAL=$FIRST_EXIT; else FINAL=$CLEANUP_EXIT; fi
  if [ "$REAP" = FAILED ] || [ "$SURVIVORS" = present ]; then stamp "LOCK: held by runner through cleanup ($(lock_probe)); NOT safely handed off — quarantine/survivors; parent must inspect before granting another slot"
  else stamp "LOCK: held by runner through cleanup ($(lock_probe)); released by runner exit; no survivors (probe after exit with check-lock.sh)"; fi
  local dur; dur=$(awk -v a="$CLEANUP_T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}')
  stamp "end_utc=$(date -u +%FT%TZ) final_exit=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT signal=$SIGNAL reap=$REAP cleanup_seconds=$dur deadline_exceeded=$DEADLINE_EXCEEDED (enforced ${CLEANUP_BUDGET}s, arithmetic worst ${WORST}s, grace ${OUTER_GRACE}s) owned_groups=[$(echo ${OWNED_PGIDS:-none})] retired_groups=[$(echo ${RETIRED_PGIDS:-none})] guard_spec=$RC_GUARD refusal_hosted=$RC_R20 refusal_noconfirm=$RC_R21 fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC fixture_stop=$RC_STOP survivors=$SURVIVORS (pre-receipt; authoritative final in RECEIPT.txt)"
  echo "final=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT signal=$SIGNAL reap=$REAP cleanup_seconds=$dur deadline_exceeded=$DEADLINE_EXCEEDED guard_spec=$RC_GUARD refusal_hosted=$RC_R20 refusal_noconfirm=$RC_R21 fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC fixture_stop=$RC_STOP survivors=$SURVIVORS" > "$OUT/exit-codes.txt"
  # P5/F05: stamp.txt and exit-codes.txt are FROZEN from here on. The ENTIRE inner-manifest pipeline (find|sort|xargs sha256sum) runs as ONE bounded
  # operation: `timeout -k 1 <remaining>` WITHOUT --foreground, so the timeout owns the pipeline's process group and TERM/KILL reaches every helper.
  # An exhausted deadline gets NO minimum allowance: hashing is skipped and the receipt is FAILED(deadline). Layout stays acyclic:
  # SHA256SUMS (inner) ← RECEIPT.txt ← SHA256SUMS.outer; PUBLICATION.txt is written last and hashed by nothing (records publication status + actual exit).
  local hrc=0 hb pub=ok; hb=$(remaining)
  if [ "$hb" -le 0 ]; then hrc=deadline; DEADLINE_EXCEEDED=yes; stamp_stdout "HASH SKIPPED: cleanup deadline exhausted before the inner manifest (no minimum allowance)"
  else   # A02: exclude EVERY publication temporary/output (SHA256SUMS*, RECEIPT.txt, PUBLICATION.txt) and re-verify the COMPLETED inner manifest inside the same bound
    timeout -k 1 "$hb" bash -c 'cd "$1" && find . -type f ! -name "SHA256SUMS*" ! -name RECEIPT.txt ! -name PUBLICATION.txt -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS.tmp && mv -f SHA256SUMS.tmp SHA256SUMS && sha256sum -c --quiet SHA256SUMS' _ "$OUT" 9>&- || hrc=$?; rm -f "$OUT/SHA256SUMS.tmp"; fi
  deadline_check; dur=$(awk -v a="$CLEANUP_T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}')
  local receipt=ok; [ "$hrc" = 0 ] && [ -s "$OUT/SHA256SUMS" ] || receipt="FAILED(hash_rc=$hrc)"; [ "$DEADLINE_EXCEEDED" = yes ] && receipt="${receipt};deadline_exceeded"   # B R-3: no 'after_hash' claim
  if [ "$receipt" != ok ] && [ "$CLEANUP_EXIT" = 0 ]; then CLEANUP_EXIT=71; fi     # a missing/failed/over-deadline receipt is never cleanup_exit=0
  if [ "$FIRST_EXIT" != 0 ]; then FINAL=$FIRST_EXIT; else FINAL=$CLEANUP_EXIT; fi
  # A05: the WHOLE publication tail (RECEIPT write + content check, outer manifest write + verification) is ONE bounded operation; a deadline already
  # exhausted here still gets a 2 s failure-reporting reserve so the failure itself is written. Distinct rcs name the failed stage.
  local pb tail_rc=0; pb=$(remaining); [ "$pb" -gt 10 ] && pb=10; [ "$pb" -lt 2 ] && { pb=2; [ "$(now_s)" -ge "${CLEANUP_DEADLINE:-0}" ] && DEADLINE_EXCEEDED=yes; }
  timeout -k 1 "$pb" bash -c '
    cd "$1" || exit 10
    { echo "receipt_status=$2"; echo "final_exit=$3 first_exit=$4 cleanup_exit=$5"; echo "cleanup_seconds_total=$6 deadline_exceeded=$7 hash_rc=$8 inner_manifest_sha256=$(sha256sum SHA256SUMS 2>/dev/null | cut -c1-64)"; echo "utc=$(date -u +%FT%TZ)"; } > RECEIPT.txt || exit 11
    grep -q "^final_exit=$3 first_exit=$4 cleanup_exit=$5\$" RECEIPT.txt || exit 12
    [ -s SHA256SUMS ] || exit 13
    sha256sum SHA256SUMS RECEIPT.txt > SHA256SUMS.outer.tmp && mv -f SHA256SUMS.outer.tmp SHA256SUMS.outer || exit 14
    sha256sum -c --quiet SHA256SUMS.outer || exit 15
    exit 0' _ "$OUT" "$receipt" "$FINAL" "$FIRST_EXIT" "$CLEANUP_EXIT" "$dur" "$DEADLINE_EXCEEDED" "$hrc" 9>&- 2>/dev/null || tail_rc=$?
  rm -f "$OUT/SHA256SUMS.outer.tmp"
  case $tail_rc in 0) pub=ok;; 10) pub=outdir_unreachable;; 11) pub=receipt_write_failed;; 12) pub=receipt_content_mismatch;; 13) pub=inner_manifest_missing;; 14) pub=outer_manifest_write_failed;; 15) pub=outer_manifest_verify_failed;; 124|137) pub="publication_timeout(rc=$tail_rc)";; *) pub="publication_failed(rc=$tail_rc)";; esac
  local dl_pub=no; [ -n "$CLEANUP_DEADLINE" ] && [ "$(now_s)" -ge "$CLEANUP_DEADLINE" ] && dl_pub=yes
  local receipt_final=$FINAL
  if [ "$FINAL" = 0 ] && { [ "$pub" != ok ] || [ "$dl_pub" = yes ]; }; then FINAL=71; fi   # F05: the ACTUAL exit is classified after publication/deadline outcomes; a failed publication is never accepted 0
  # A05: the final required write is CHECKED under its own small bound; PUBLICATION.txt is hashed by nothing. Its failure is a publication failure (0 → 71).
  local prc=0
  timeout -k 1 2 bash -c '{ echo "publication_status=$2 deadline_exceeded_at_publication=$3"; echo "process_exit=$4 receipt_final_exit=$5"; echo "rule: process exit == RECEIPT.txt final_exit unless publication_status!=ok or deadline_exceeded_at_publication=yes or this file could not be written, in which case a 0 becomes 71"; echo "utc=$(date -u +%FT%TZ)"; } > "$1/PUBLICATION.txt" && grep -q "^process_exit=$4 receipt_final_exit=$5\$" "$1/PUBLICATION.txt"' _ "$OUT" "$pub" "$dl_pub" "$FINAL" "$receipt_final" 9>&- 2>/dev/null || prc=$?
  local pubfile=ok; [ "$prc" = 0 ] || { pubfile="FAILED(rc=$prc)"; [ "$FINAL" = 0 ] && FINAL=71; }
  echo "RECEIPT: $(head -2 "$OUT/RECEIPT.txt" 2>/dev/null | tr '\n' ' ') PUBLICATION: status=$pub publication_file=$pubfile deadline_at_publication=$dl_pub process_exit=$FINAL"
  exit "$FINAL"
}
stamp_stdout(){ echo "$*"; }   # F05: post-freeze notes go to stdout (launcher log) only — stamp.txt is hashed and must never be appended after the freeze
trap cleanup EXIT
trap 'on_signal TERM' TERM; trap 'on_signal INT' INT; trap 'on_signal HUP' HUP   # registered after the EXIT trap so a signal always reaches cleanup

# ---- 0) lock FIRST (nonblocking), then identity/precondition refusals
exec 9>"$LOCK"
flock -n 9 || { stamp "lock busy: $LOCK (exit 75)"; finish 75; }
stamp "lock acquired pid=$$ fd9=$(readlink /proc/$$/fd/9) $(date -u +%FT%TZ) purpose=s2-composition-proof out=$OUT"
export PATH=/home/user/pg17/dist/bin:/usr/lib/postgresql/18/bin:$PATH
cd "$WT" || finish 70
HEAD=$(git rev-parse HEAD 9>&-); TREE=$(git rev-parse HEAD^{tree} 9>&-); DIRTY=$(git status --porcelain --untracked-files=all 9>&- | wc -l)
stamp "start_utc=$(date -u +%FT%TZ) runner=$0 runner_sha256=$(sha256sum "$0" | cut -c1-64) head=$HEAD tree=$TREE dirty_lines=$DIRTY branch=$(git rev-parse --abbrev-ref HEAD 9>&-)"
stamp "expect_head=$EXPECT_HEAD lock_sha256=$(sha256sum package-lock.json | cut -c1-64) expect_lock=$EXPECT_LOCK_SHA"
stamp "cleanup_budget: reap_term=${REAP_TERM_WAIT}s reap_kill=${REAP_KILL_WAIT}s stop=${STOP_BUDGET}+${STOP_KILL}s status=${STATUS_BUDGET}+${STATUS_KILL}s scan_hash=${SCAN_HASH_ALLOW}s worst=${WORST}s outer_grace=${OUTER_GRACE}s margin=${MARGIN}s"
stamp "harness_sha256=$(sha256sum test/release/s1s2-composition.sh | cut -c1-64) release_sh_sha256=$(sha256sum scripts/release.sh | cut -c1-64)"
stamp "toolchain: timeout=$(timeout --version 2>&1 | head -1) flock=$(flock --version 2>&1 | head -1) setsid=$(setsid --version 2>&1 | head -1) pgrep=$(pgrep --version 2>&1 | head -1) bash=$BASH_VERSION lane_identity: NS=$NS DB=$DB PORT=$PORT"
stamp "nproc=$(nproc) mem_free_mb=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo) disk_free=$(df -h /home/user | awk 'NR==2{print $4}')"
[ "$HEAD" = "$EXPECT_HEAD" ] || { stamp "REFUSED: head $HEAD != expected $EXPECT_HEAD"; finish 70; }
[ "$TREE" = "$EXPECT_TREE" ] || { stamp "REFUSED: tree $TREE != expected $EXPECT_TREE"; finish 70; }   # S3-1 (NEW)
[ "$DIRTY" = 0 ] || { stamp "REFUSED: worktree dirty ($DIRTY lines)"; git status --porcelain --untracked-files=all 9>&- | tee "$OUT/dirty.txt"; finish 70; }
[ "$(sha256sum package-lock.json | cut -c1-64)" = "$EXPECT_LOCK_SHA" ] || { stamp "REFUSED: lockfile hash mismatch"; finish 70; }
# dependency-closure admissibility: package-lock.json, package.json, prisma/schema.prisma must be byte-identical to the closure's install head
git diff --quiet "$CLOSURE_REF" HEAD -- package-lock.json package.json prisma/schema.prisma 9>&- || { stamp "REFUSED: closure files differ from $CLOSURE_REF; reused install not admissible"; finish 70; }
stamp "closure files identical to $CLOSURE_REF (package-lock.json package.json prisma/schema.prisma)"
if [ -z "$STUBS" ]; then
  stamp "node=$(node --version 2>&1) npm=$(npm --version 2>&1) psql=$(psql --version 2>&1) postgres=$(/home/user/pg17/dist/bin/postgres --version 2>&1)"
  # F06 (A-06): installed CLI existence + exact byte pin are checked BEFORE the first CLI execution (--version below); unbound client bytes never run
  [ -f node_modules/prisma/build/index.js ] || { stamp "REFUSED: node_modules/prisma missing (setup-30 not done in this sandbox)"; finish 70; }
  [ "$(sha256sum node_modules/prisma/build/index.js | cut -c1-64)" = "$EXPECT_PRISMA_CLI_SHA" ] || { stamp "REFUSED: installed prisma CLI bytes != $EXPECT_PRISMA_CLI_SHA (checkpoint analysis not bound; CLI NOT executed)"; finish 70; }   # P1/F06
  stamp "prisma_cli_sha256=$(sha256sum node_modules/prisma/build/index.js 2>/dev/null | cut -c1-64) (pinned, verified before first execution) fixture_sha256=$(sha256sum "$LANE/infra/s3-fixture-be0b.sh" 2>/dev/null | cut -c1-64) expect_fixture=$EXPECT_FIXTURE_SHA"
  stamp "prisma=$(node node_modules/prisma/build/index.js --version 2>/dev/null 9>&- | tr -s ' ' | tr '\n' ';')"   # first CLI execution: after the pin
  [ -f node_modules/.s2-composition-install-stamp ] && sed 's/^/install_stamp: /' node_modules/.s2-composition-install-stamp | tee -a "$S"
  NM_TARGET=$(readlink -f node_modules); stamp "node_modules -> $NM_TARGET"
  # S3-2: install binding to the receipted S3 installation (replaces the v5.7 .s2-composition-install-stamp refusal; S3 legitimately has no such stamp)
  INSTALLED_LOCK_SHA=$(sha256sum node_modules/.package-lock.json 2>/dev/null | cut -c1-64); stamp "installed_graph: node_modules/.package-lock.json sha256=${INSTALLED_LOCK_SHA:-absent} expect=$EXPECT_INSTALLED_LOCK_SHA receipts=execution/6c2a68ac/s3-integration-result(steps 02 npm ci raw0, 03 prisma generate raw0)"
  [ "$INSTALLED_LOCK_SHA" = "$EXPECT_INSTALLED_LOCK_SHA" ] || { stamp "REFUSED: installed graph node_modules/.package-lock.json != receipted S3 install $EXPECT_INSTALLED_LOCK_SHA"; finish 70; }
  [ -f node_modules/.prisma/client/index.js ] && [ -d node_modules/@prisma/client ] || { stamp "REFUSED: generated Prisma client missing (S3 step 03 generate not present in this node_modules)"; finish 70; }
  stamp "installed_versions: prisma=$(node -p "require('./node_modules/prisma/package.json').version" 2>/dev/null 9>&-) client=$(node -p "require('./node_modules/@prisma/client/package.json').version" 2>/dev/null 9>&-) deepmerge_ts=$(node -p "JSON.parse(require('fs').readFileSync('node_modules/deepmerge-ts/package.json','utf8')).version" 2>/dev/null 9>&-) (S2 accepted run: 6.19.3 / 6.19.3 / 7.1.5)"
  stamp "client_boundary: CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset} exported before all steps (env -i steps carry it explicitly); prisma CLI bytes bound; scoped claim: optional Prisma checkpoint worker (detached fork) excluded — arbitrary future setsid escapes are OUTSIDE this claim"
  command -v psql >/dev/null || { stamp "REFUSED: psql missing (setup-10 not done)"; finish 70; }
  [ -x /home/user/pg17/dist/bin/postgres ] || { stamp "REFUSED: PG17 dist missing (setup-20 not done)"; finish 70; }
  [ "$(sha256sum "$LANE/infra/s3-fixture-be0b.sh" 2>/dev/null | cut -c1-64)" = "$EXPECT_FIXTURE_SHA" ] || { stamp "REFUSED: fixture $LANE/infra/s3-fixture-be0b.sh absent or != pinned $EXPECT_FIXTURE_SHA"; finish 70; }
  grep -q "^PORT=$PORT;" "$LANE/infra/s3-fixture-be0b.sh" && grep -q "^NS=$NS$" "$LANE/infra/s3-fixture-be0b.sh" || { stamp "REFUSED: fixture PORT/NS literals do not match runner PORT=$PORT NS=$NS"; finish 70; }
else
  stamp "STUB MODE: toolchain/node_modules/PG17/fixture-hash prechecks SKIPPED (not evidence); head/dirty/lockfile/closure checks above were REAL"
  stamp "client_boundary: CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset} exported (stubs echo what they inherit)"
fi

# ---- 1) S1 offline guard spec at the composed head (no DB)
run_step 10-guard-spec 120 "$OUT/10-guard-spec.log" -- $GUARD_SPEC; RC_GUARD=$?
stamp "10 guard-spec exit=$RC_GUARD $(tail -1 "$OUT/10-guard-spec.log")"
[ "$RC_GUARD" -eq 0 ] || finish "$RC_GUARD"

# ---- 2) harness-level offline refusals BEFORE any server exists on the port (must exit 64, no DB contact)
run_step 20-refusal-hosted 120 "$OUT/20-refusal-hosted.log" -- env -i PATH="$PATH" HOME="$HOME" CHECKPOINT_DISABLE=1 S1_PG_SUPER_URL='postgresql://postgres:pw@db.example.supabase.co:5432/postgres' S1_PG_PORT=5432 \
  S1_PG_DISPOSABLE_CONFIRM="DESTROY-db.example.supabase.co:5432/$DB,${DB}_lock" $REFUSAL_HARNESS "$DB"; RC_R20=$?
stamp "20 refusal-hosted exit=$RC_R20 (expect 64) $(tail -1 "$OUT/20-refusal-hosted.log")"; [ "$RC_R20" -eq 64 ] || finish 70
run_step 21-refusal-noconfirm 120 "$OUT/21-refusal-noconfirm.log" -- env -i PATH="$PATH" HOME="$HOME" CHECKPOINT_DISABLE=1 S1_PG_SUPER_URL="postgresql://s1_super:s1_local_synthetic@127.0.0.1:$PORT/postgres" S1_PG_PORT=$PORT \
  $REFUSAL_HARNESS "$DB"; RC_R21=$?
stamp "21 refusal-noconfirm exit=$RC_R21 (expect 64) $(tail -1 "$OUT/21-refusal-noconfirm.log")"; [ "$RC_R21" -eq 64 ] || finish 70

# ---- 3) disposable fixture under THIS lock hold: init inherits fd 9 (fixture verifies via /proc); start/stop never take it
if [ -z "$STUBS" ]; then
  if [ -e /home/user/pg17/clusters/$NS ]; then stamp "30 REFUSED: /home/user/pg17/clusters/$NS already exists (unexpected state; not adopting, not deleting)"; finish 70; fi
  if ss -ltnH 2>/dev/null | grep -qE ":${PORT}\b"; then stamp "30 REFUSED: something already listens on $PORT: $(ss -ltnpH 2>/dev/null | grep -E ":${PORT}\b" | head -1)"; finish 70; fi
  if pgrep -f "^/home/user/pg17/dist/bin/postgres" >/dev/null; then stamp "30 REFUSED: a pg17 fixture postgres is already running: $(pgrep -af '^/home/user/pg17/dist/bin/postgres' | head -1)"; finish 70; fi
  stamp "30 precheck: clusters/$NS absent, no $PORT listener, no fixture postgres"
  PRE=$(ls -1 /tmp/prisma_migrate.log /tmp/prisma_status.log /tmp/prisma_verify.log /tmp/prisma_verifier.log /tmp/release_verifiers_discovered.txt 2>/dev/null)
  if [ -n "$PRE" ]; then ls -l --time-style=+%FT%TZ $PRE > "$OUT/preexisting-tmp-LISTING.txt"; stamp "30 precheck REFUSED: pre-existing release.sh /tmp scratch files (not touched): $(echo $PRE | tr '\n' ' ')"; finish 70; fi
  stamp "30 precheck: no pre-existing release.sh /tmp scratch files"
fi
run_step 30-fixture-init 120 "$OUT/30-fixture-init.log" --inherit-fd9 -- $FIXTURE init; RC_FIXTURE=$?
stamp "30 fixture-init exit=$RC_FIXTURE $(head -1 "$OUT/30-fixture-init.log")"; [ "$RC_FIXTURE" -eq 0 ] || finish "$RC_FIXTURE"
FIXTURE_STARTED=attempted
run_step 31-fixture-start 120 "$OUT/31-fixture-start.log" -- $FIXTURE start; RC_FIXTURE=$?
stamp "31 fixture-start exit=$RC_FIXTURE $(tail -1 "$OUT/31-fixture-start.log")"; [ "$RC_FIXTURE" -eq 0 ] || finish "$RC_FIXTURE"
FIXTURE_STARTED=1
run_step 32-fixture-status 30 "$OUT/32-fixture-status.log" -- $FIXTURE status; stamp "32 fixture-status: $(head -1 "$OUT/32-fixture-status.log")"
stamp "lock still held by runner: $(lock_probe) fd9=$(readlink /proc/$$/fd/9)"

# ---- 4) the real composition proof (guard preflight is the first thing the harness does)
export S1_PG_SUPER_URL="postgresql://s1_super:s1_local_synthetic@127.0.0.1:$PORT/postgres" S1_PG_PORT=$PORT
export S1_PG_DISPOSABLE_CONFIRM="DESTROY-127.0.0.1:$PORT/$DB,${DB}_lock" S2_COMP_OUT="$OUT/harness"
BOUND40=1500; [ -n "$STUBS" ] && [ -n "${STUB_STEP40_BOUND-}" ] && BOUND40=$STUB_STEP40_BOUND   # O3: stub mode only
run_step 40-composition "$BOUND40" "$OUT/40-composition.log" -- $HARNESS "$DB"; RC_COMP=$?
stamp "40 composition exit=$RC_COMP end_utc=$(date -u +%FT%TZ) $(grep -E '^== [0-9]+ passed' "$OUT/40-composition.log" | tail -1)"
[ "$RC_COMP" -eq 0 ] || finish "$RC_COMP"

# ---- 5) S1 R4 discriminator (S1-owned, frozen) on the PROTECTED database the harness leaves behind, under the same hold.
mkdir -p "$OUT/s1-r4"
export S1_PRISMA_CLI="$WT/node_modules/prisma/build/index.js" S1_PROOF_LOG="$OUT/s1-r4/s1-r4-discriminator.detail.log" S1_R4_LOCK_HOLDER="run-composition-s3-v5.8 pid=$$ fd9=$LOCK"
run_step 45-s1-r4-discriminator 300 "$OUT/s1-r4/s1-r4-discriminator.log" -- $DISC "$DB"; RC_DISC=$?
stamp "45 s1-r4-discriminator exit=$RC_DISC $(grep -E 'passed|FAIL' "$OUT/s1-r4/s1-r4-discriminator.log" | tail -1)"
stamp "lock still held by runner after discriminator: $(lock_probe)"
stamp "post_tree_dirty_lines=$(git status --porcelain --untracked-files=all 9>&- | wc -l)"
[ "$RC_DISC" -eq 0 ] || finish "$RC_DISC"
finish 0
