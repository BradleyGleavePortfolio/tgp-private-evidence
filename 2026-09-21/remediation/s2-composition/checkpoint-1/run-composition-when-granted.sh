#!/usr/bin/env bash
# S2 composition proof runner — ONLY under a parent-granted, named slot (SLOT REQUEST 02).
# Holds the canonical nonblocking lock for the whole run (fixture start → guard preflight → all mutations),
# stamps identity, runs the S1 offline guard spec, the harness's own offline refusal control, then the real
# composition harness under `timeout --foreground`; every child exit is preserved (75 = lock busy, 124 = timeout).
# Never pushes, never touches anything but 127.0.0.1:54321 databases matching ^s1_rls_.
set -u
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s2-composition
LANE=$ROOT/execution/s2-composition
LOCK=$ROOT/execution/test-validation.lock
EXPECT_HEAD=${S2_EXPECT_HEAD:-9742037b153221de565e651ad8ba3b721bc0fb31}   # override ONLY with the parent-named frozen head
EXPECT_LOCK_SHA=62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390
DB=${S2_COMP_DB:-s1_rls_s2comp}
STAMP=$(date -u +%Y%m%dT%H%M%SZ); OUT=$LANE/composition/$STAMP; mkdir -p "$OUT"
exec 9>"$LOCK"
flock -n 9 || { echo "lock busy: $LOCK (exit 75)" | tee "$OUT/REFUSED-lock-busy.txt"; exit 75; }
echo "lock acquired pid=$$ $(date -u +%FT%TZ) purpose=s2-composition-proof out=$OUT" | tee "$OUT/lock.txt"
export PATH=/home/user/pg17/dist/bin:/usr/lib/postgresql/18/bin:/usr/lib/postgresql/17/bin:$PATH
cd "$WT" || exit 1
HEAD=$(git rev-parse HEAD); TREE=$(git rev-parse HEAD^{tree}); DIRTY=$(git status --porcelain --untracked-files=all | wc -l)
{
  echo "start_utc=$(date -u +%FT%TZ) runner=$0 head=$HEAD tree=$TREE dirty_lines=$DIRTY branch=$(git rev-parse --abbrev-ref HEAD)"
  echo "expect_head=$EXPECT_HEAD lock_sha256=$(sha256sum package-lock.json | cut -c1-64) expect_lock=$EXPECT_LOCK_SHA"
  echo "node=$(node --version) npm=$(npm --version) psql=$(psql --version 2>&1) postgres=$(/home/user/pg17/dist/bin/postgres --version 2>&1)"
  echo "prisma=$(node node_modules/prisma/build/index.js --version 2>/dev/null | tr -s ' ' | tr '\n' ';')"
  echo "prisma_cli_sha256=$(sha256sum node_modules/prisma/build/index.js | cut -c1-64)"
  [ -f node_modules/.s2-composition-install-stamp ] && sed 's/^/install_stamp: /' node_modules/.s2-composition-install-stamp
  echo "nproc=$(nproc) mem_free_mb=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo) disk_free=$(df -h /home/user | awk 'NR==2{print $4}')"
} | tee "$OUT/stamp.txt"
[ "$HEAD" = "$EXPECT_HEAD" ] || { echo "REFUSED: head $HEAD != expected $EXPECT_HEAD" | tee -a "$OUT/stamp.txt"; exit 70; }
[ "$DIRTY" = 0 ] || { echo "REFUSED: worktree dirty ($DIRTY lines)" | tee -a "$OUT/stamp.txt"; git status --porcelain --untracked-files=all | tee "$OUT/dirty.txt"; exit 70; }
[ "$(sha256sum package-lock.json | cut -c1-64)" = "$EXPECT_LOCK_SHA" ] || { echo "REFUSED: lockfile hash mismatch"; exit 70; }
[ -f node_modules/prisma/build/index.js ] || { echo "REFUSED: node_modules/prisma missing (setup-30 not done)"; exit 70; }
command -v psql >/dev/null || { echo "REFUSED: psql missing (setup-10 not done)"; exit 70; }

# 1) S1's offline guard specification at the composed head (no DB; stubs only)
timeout --foreground 120 bash test/db/s1-harness-guard.spec.sh >"$OUT/10-guard-spec.log" 2>&1; rc=$?
echo "10 guard-spec exit=$rc $(tail -1 "$OUT/10-guard-spec.log")" | tee -a "$OUT/stamp.txt"
[ $rc -eq 0 ] || [ $rc -eq 0 ] && [ "$DISC_RC" = 0 ] || exit ${rc/#0/1}
exit 0

# 2) harness-level offline refusal control BEFORE any server exists on the port: hostile URL must exit 64
env -i PATH="$PATH" HOME="$HOME" S1_PG_SUPER_URL='postgresql://postgres:pw@db.example.supabase.co:5432/postgres' S1_PG_PORT=5432 \
  S1_PG_DISPOSABLE_CONFIRM="DESTROY-db.example.supabase.co:5432/$DB,${DB}_lock" bash test/release/s1s2-composition.sh "$DB" >"$OUT/20-refusal-hosted.log" 2>&1; rc=$?
echo "20 refusal-hosted exit=$rc (expect 64) $(tail -1 "$OUT/20-refusal-hosted.log")" | tee -a "$OUT/stamp.txt"
[ $rc -eq 64 ] || exit 70
env -i PATH="$PATH" HOME="$HOME" S1_PG_SUPER_URL='postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres' S1_PG_PORT=54321 \
  bash test/release/s1s2-composition.sh "$DB" >"$OUT/21-refusal-noconfirm.log" 2>&1; rc=$?
echo "21 refusal-noconfirm exit=$rc (expect 64) $(tail -1 "$OUT/21-refusal-noconfirm.log")" | tee -a "$OUT/stamp.txt"
[ $rc -eq 64 ] || exit 70

# 3) disposable fixture (init once, start; loopback 127.0.0.1:54321; marker cluster_name=s1-disposable-pg17)
[ -d /home/user/pg17/clusters/s2comp ] || { bash "$LANE/infra/s2-fixture.sh" init >"$OUT/30-fixture-init.log" 2>&1 || { echo "fixture init failed"; exit 1; }; }
bash "$LANE/infra/s2-fixture.sh" start >"$OUT/31-fixture-start.log" 2>&1; rc=$?
echo "31 fixture-start exit=$rc" | tee -a "$OUT/stamp.txt"; [ $rc -eq 0 ] || [ $rc -eq 0 ] && [ "$DISC_RC" = 0 ] || exit ${rc/#0/1}
exit 0
bash "$LANE/infra/s2-fixture.sh" status >"$OUT/32-fixture-status.log" 2>&1; cat "$OUT/32-fixture-status.log" | tee -a "$OUT/stamp.txt"

# 4) the real composition proof (guard preflight is the first thing the harness does)
export S1_PG_SUPER_URL='postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres' S1_PG_PORT=54321
export S1_PG_DISPOSABLE_CONFIRM="DESTROY-127.0.0.1:54321/$DB,${DB}_lock" S2_COMP_OUT="$OUT/harness"
timeout --foreground 1500 bash test/release/s1s2-composition.sh "$DB" >"$OUT/40-composition.log" 2>&1; rc=$?
echo "40 composition exit=$rc end_utc=$(date -u +%FT%TZ) $(grep -E '^== [0-9]+ passed' "$OUT/40-composition.log" | tail -1)" | tee -a "$OUT/stamp.txt"

# 4b) S1 R4 discriminator (S1-owned, frozen 41f4d6a9) on the PROTECTED database the harness leaves behind,
#     sharing this wrapper's lock hold (S1_R4_LOCK_HOLDER is attribution; the flock fd 9 above is the actual hold).
#     Only when the composition passed: the discriminator requires the released, verifier-green state on <db>.
DISC_RC=skipped
if [ $rc -eq 0 ]; then
  mkdir -p "$OUT/s1-r4"
  S1_PRISMA_CLI="$WT/node_modules/prisma/build/index.js" S1_PROOF_LOG="$OUT/s1-r4/s1-r4-discriminator.detail.log" \
  S1_R4_LOCK_HOLDER="run-composition-when-granted.sh pid=$$ flock fd9 $LOCK" \
    timeout --foreground 300 bash test/db/s1-r4-truncate-discriminator.sh "$DB" >"$OUT/s1-r4/s1-r4-discriminator.log" 2>&1; DISC_RC=$?
  echo "45 s1-r4-discriminator exit=$DISC_RC $(grep -E 'passed|FAIL' "$OUT/s1-r4/s1-r4-discriminator.log" | tail -1)" | tee -a "$OUT/stamp.txt"
fi
echo "exit-codes: composition=$rc s1_r4_discriminator=$DISC_RC" | tee "$OUT/exit-codes.txt"

# 5) leave the fixture running only if the parent asked (S2_KEEP_FIXTURE=1); default stop, never delete data dir here
[ "${S2_KEEP_FIXTURE:-0}" = 1 ] || bash "$LANE/infra/s2-fixture.sh" stop >"$OUT/50-fixture-stop.log" 2>&1
( cd "$OUT" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS )
echo "post_tree_dirty_lines=$(git status --porcelain --untracked-files=all | wc -l)" | tee -a "$OUT/stamp.txt"
[ $rc -eq 0 ] && [ "$DISC_RC" = 0 ] || exit ${rc/#0/1}
exit 0
