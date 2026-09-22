#!/usr/bin/env bash
# S2 composition proof runner (v2) — ONLY under a parent-granted, named slot.
# ONE canonical nonblocking lock (fd 9) is held by this process from before fixture init through guard preflight and
# every mutation until cleanup; fixture init inherits fd 9 (verified via /proc inside the fixture), all other children
# get fd 9 CLOSED (9>&-) so no daemon/child can retain the lease. Every child exit is preserved; the runner's own exit is
# the first failing step's code (75 lock busy, 70 refused precondition, 124 timeout, harness/discriminator code otherwise).
# Cleanup (fixture stop, exit-codes.txt, SHA256SUMS) always runs via the EXIT trap, after the last stamp write.
#
# Offline self-test: S2_RUNNER_STUBS=<dir> swaps guard-spec/fixture/harness/discriminator for stub scripts from <dir>,
# uses a private lock file and writes under runner-selftest/ with a "STUB MODE — NOT EVIDENCE" banner. Never for proof.
set -u
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s2-composition
LANE=$ROOT/execution/s2-composition
EXPECT_HEAD=${S2_EXPECT_HEAD:-9742037b153221de565e651ad8ba3b721bc0fb31}   # override ONLY with the parent-named frozen head
EXPECT_LOCK_SHA=62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390
DB=${S2_COMP_DB:-s1_rls_s2comp}
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
STUBS=${S2_RUNNER_STUBS-}
if [ -n "$STUBS" ]; then
  LOCK=$STUBS/test-validation.lock; OUT=$LANE/runner-selftest/$STAMP
  GUARD_SPEC="bash $STUBS/guard-spec.sh"; FIXTURE="bash $STUBS/fixture.sh"; HARNESS="bash $STUBS/harness.sh"; DISC="bash $STUBS/discriminator.sh"
  REFUSAL_HARNESS="bash $WT/test/release/s1s2-composition.sh"   # real offline refusal path is cheap and DB-free
else
  LOCK=$ROOT/execution/test-validation.lock; OUT=$LANE/composition/$STAMP
  GUARD_SPEC="bash test/db/s1-harness-guard.spec.sh"; FIXTURE="bash $LANE/infra/s2-fixture.sh"
  HARNESS="bash test/release/s1s2-composition.sh"; DISC="bash test/db/s1-r4-truncate-discriminator.sh"; REFUSAL_HARNESS=$HARNESS
fi
mkdir -p "$OUT"
S="$OUT/stamp.txt"
stamp(){ echo "$*" | tee -a "$S"; }
[ -n "$STUBS" ] && stamp "STUB MODE — NOT EVIDENCE (stubs=$STUBS, private lock=$LOCK)"

# ---- cleanup always runs; the runner exits with FINAL (first failing step) — never an unconditional 0
FINAL=1; RC_GUARD=notrun; RC_FIXTURE=notrun; RC_COMP=notrun; RC_DISC=notrun; FIXTURE_STARTED=0
finish(){ FINAL=$1; exit "$FINAL"; }
cleanup(){
  trap - EXIT
  if [ "$FIXTURE_STARTED" = 1 ] && [ "${S2_KEEP_FIXTURE:-0}" != 1 ]; then $FIXTURE stop >"$OUT/50-fixture-stop.log" 2>&1 9>&-; stamp "50 fixture-stop exit=$?"; fi
  stamp "end_utc=$(date -u +%FT%TZ) final_exit=$FINAL guard_spec=$RC_GUARD fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC"
  echo "final=$FINAL guard_spec=$RC_GUARD fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC" > "$OUT/exit-codes.txt"
  ( cd "$OUT" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS )
  exit "$FINAL"
}
trap cleanup EXIT

# ---- 0) lock FIRST (nonblocking), then identity/precondition refusals
exec 9>"$LOCK"
flock -n 9 || { stamp "lock busy: $LOCK (exit 75)"; finish 75; }
stamp "lock acquired pid=$$ fd9=$(readlink /proc/$$/fd/9) $(date -u +%FT%TZ) purpose=s2-composition-proof out=$OUT"
export PATH=/home/user/pg17/dist/bin:/usr/lib/postgresql/18/bin:$PATH
cd "$WT" || finish 70
HEAD=$(git rev-parse HEAD 9>&-); TREE=$(git rev-parse HEAD^{tree} 9>&-); DIRTY=$(git status --porcelain --untracked-files=all 9>&- | wc -l)
stamp "start_utc=$(date -u +%FT%TZ) runner=$0 runner_sha256=$(sha256sum "$0" | cut -c1-64) head=$HEAD tree=$TREE dirty_lines=$DIRTY branch=$(git rev-parse --abbrev-ref HEAD 9>&-)"
stamp "expect_head=$EXPECT_HEAD lock_sha256=$(sha256sum package-lock.json | cut -c1-64) expect_lock=$EXPECT_LOCK_SHA"
stamp "node=$(node --version) npm=$(npm --version) psql=$(psql --version 2>&1) postgres=$(/home/user/pg17/dist/bin/postgres --version 2>&1)"
stamp "prisma=$(node node_modules/prisma/build/index.js --version 2>/dev/null 9>&- | tr -s ' ' | tr '\n' ';')"
stamp "prisma_cli_sha256=$(sha256sum node_modules/prisma/build/index.js | cut -c1-64) harness_sha256=$(sha256sum test/release/s1s2-composition.sh | cut -c1-64) fixture_sha256=$(sha256sum "$LANE/infra/s2-fixture.sh" | cut -c1-64)"
[ -f node_modules/.s2-composition-install-stamp ] && sed 's/^/install_stamp: /' node_modules/.s2-composition-install-stamp | tee -a "$S"
stamp "nproc=$(nproc) mem_free_mb=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo) disk_free=$(df -h /home/user | awk 'NR==2{print $4}')"
[ "$HEAD" = "$EXPECT_HEAD" ] || { stamp "REFUSED: head $HEAD != expected $EXPECT_HEAD"; finish 70; }
[ "$DIRTY" = 0 ] || { stamp "REFUSED: worktree dirty ($DIRTY lines)"; git status --porcelain --untracked-files=all 9>&- | tee "$OUT/dirty.txt"; finish 70; }
[ "$(sha256sum package-lock.json | cut -c1-64)" = "$EXPECT_LOCK_SHA" ] || { stamp "REFUSED: lockfile hash mismatch"; finish 70; }
[ -f node_modules/prisma/build/index.js ] || { stamp "REFUSED: node_modules/prisma missing (setup-30 not done)"; finish 70; }
command -v psql >/dev/null || { stamp "REFUSED: psql missing (setup-10 not done)"; finish 70; }
[ -x /home/user/pg17/dist/bin/postgres ] || { stamp "REFUSED: PG17 dist missing (setup-20 not done)"; finish 70; }

# ---- 1) S1 offline guard spec at the composed head (no DB; stubs only)
timeout --foreground 120 $GUARD_SPEC >"$OUT/10-guard-spec.log" 2>&1 9>&-; RC_GUARD=$?
stamp "10 guard-spec exit=$RC_GUARD $(tail -1 "$OUT/10-guard-spec.log")"
[ "$RC_GUARD" -eq 0 ] || finish "$RC_GUARD"

# ---- 2) harness-level offline refusals BEFORE any server exists on the port (must exit 64, no DB contact)
env -i PATH="$PATH" HOME="$HOME" S1_PG_SUPER_URL='postgresql://postgres:pw@db.example.supabase.co:5432/postgres' S1_PG_PORT=5432 \
  S1_PG_DISPOSABLE_CONFIRM="DESTROY-db.example.supabase.co:5432/$DB,${DB}_lock" $REFUSAL_HARNESS "$DB" >"$OUT/20-refusal-hosted.log" 2>&1 9>&-; rc=$?
stamp "20 refusal-hosted exit=$rc (expect 64) $(tail -1 "$OUT/20-refusal-hosted.log")"; [ $rc -eq 64 ] || finish 70
env -i PATH="$PATH" HOME="$HOME" S1_PG_SUPER_URL='postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres' S1_PG_PORT=54321 \
  $REFUSAL_HARNESS "$DB" >"$OUT/21-refusal-noconfirm.log" 2>&1 9>&-; rc=$?
stamp "21 refusal-noconfirm exit=$rc (expect 64) $(tail -1 "$OUT/21-refusal-noconfirm.log")"; [ $rc -eq 64 ] || finish 70

# ---- 3) disposable fixture under THIS lock hold: init inherits fd 9 (fixture verifies via /proc); start/stop never take it
if [ ! -d /home/user/pg17/clusters/s2comp ] || [ -n "$STUBS" ]; then
  $FIXTURE init >"$OUT/30-fixture-init.log" 2>&1; RC_FIXTURE=$?
  stamp "30 fixture-init exit=$RC_FIXTURE $(head -1 "$OUT/30-fixture-init.log")"; [ "$RC_FIXTURE" -eq 0 ] || finish "$RC_FIXTURE"
fi
$FIXTURE start >"$OUT/31-fixture-start.log" 2>&1 9>&-; RC_FIXTURE=$?
stamp "31 fixture-start exit=$RC_FIXTURE $(tail -1 "$OUT/31-fixture-start.log")"; [ "$RC_FIXTURE" -eq 0 ] || finish "$RC_FIXTURE"
FIXTURE_STARTED=1
$FIXTURE status >"$OUT/32-fixture-status.log" 2>&1 9>&-; stamp "32 fixture-status: $(head -1 "$OUT/32-fixture-status.log")"
stamp "lock still held by runner: $(flock -n "$LOCK" true 2>/dev/null && echo NO-FREE || echo yes) fd9=$(readlink /proc/$$/fd/9)"

# ---- 4) the real composition proof (guard preflight is the first thing the harness does)
export S1_PG_SUPER_URL='postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres' S1_PG_PORT=54321
export S1_PG_DISPOSABLE_CONFIRM="DESTROY-127.0.0.1:54321/$DB,${DB}_lock" S2_COMP_OUT="$OUT/harness"
timeout --foreground 1500 $HARNESS "$DB" >"$OUT/40-composition.log" 2>&1 9>&-; RC_COMP=$?
stamp "40 composition exit=$RC_COMP end_utc=$(date -u +%FT%TZ) $(grep -E '^== [0-9]+ passed' "$OUT/40-composition.log" | tail -1)"
[ "$RC_COMP" -eq 0 ] || finish "$RC_COMP"

# ---- 5) S1 R4 discriminator (S1-owned, frozen) on the PROTECTED database the harness leaves behind, under the same hold.
#         S1_R4_LOCK_HOLDER is attribution text only; the actual hold is this process's fd 9 (stamped above and below).
mkdir -p "$OUT/s1-r4"
S1_PRISMA_CLI="$WT/node_modules/prisma/build/index.js" S1_PROOF_LOG="$OUT/s1-r4/s1-r4-discriminator.detail.log" \
S1_R4_LOCK_HOLDER="run-composition-when-granted.sh pid=$$ fd9=$LOCK" \
  timeout --foreground 300 $DISC "$DB" >"$OUT/s1-r4/s1-r4-discriminator.log" 2>&1 9>&-; RC_DISC=$?
stamp "45 s1-r4-discriminator exit=$RC_DISC $(grep -E 'passed|FAIL' "$OUT/s1-r4/s1-r4-discriminator.log" | tail -1)"
stamp "lock still held by runner after discriminator: $(flock -n "$LOCK" true 2>/dev/null && echo NO-FREE || echo yes)"
stamp "post_tree_dirty_lines=$(git status --porcelain --untracked-files=all 9>&- | wc -l)"
[ "$RC_DISC" -eq 0 ] || finish "$RC_DISC"
finish 0
