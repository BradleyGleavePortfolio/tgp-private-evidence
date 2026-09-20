#!/usr/bin/env bash
# S5 R3 G2 E->T/Q0 proof runner (validation harness only; synthetic disposable fixture on S1's isolated PG17.6 lane s5).
# Holds execution/test-validation.lock NON-BLOCKING (flock -n) only while node/jest/prisma/psql run; if the
# lock is busy the runner exits 75 immediately and must be re-invoked from the parent's slot — it never queues.
# FAIL-FAST: each stage stops the run on its first non-zero exit; a live proof never starts after a failed
# guard/oldroot/bootstrap. Child exit codes are preserved through every pipe (PIPESTATUS). Every stage stamps
# head/tree/status/env into execution/s5-r3/logs; failed runs are preserved, never deleted.
# Usage: G2_PG17_PASSWORD=<fixture pw> bash execution/s5-r3/run-proof.sh [oldroot|guard|bootstrap|live|all|reset]
#   oldroot   offline: create/verify the detached O checkout (git only; no DB, no deps, no lock needed)
#   reset     drops ONLY the disposable database g2_s5_etq0_disposable (as s5_super) on lane s5
#   all       guard -> oldroot -> bootstrap -> live
set -uo pipefail
W=/home/user/workspace/worktrees/s5-r3
X=/home/user/workspace/execution
L=$X/s5-r3/logs
mkdir -p "$L"
export G2_PG17_DATABASE_URL='postgresql://s5_super@127.0.0.1:54325/g2_s5_etq0_disposable?schema=public&connection_limit=2'
export G2_PG17_CONFIRM='g2_s5_etq0_disposable:54325'
export G2_PG17_PSQL="${G2_PG17_PSQL:-/usr/bin/psql}"
export G2_PG17_OLD_ROOT=$X/s5-r3/old-root-925780e0
export G2_PG17_OLD_CLIENT=$X/s5-r3/old-client-925780e0
export G2_PG17_DATA_DIRECTORY="${G2_PG17_DATA_DIRECTORY:-/home/user/pg17/clusters/s5}"
export G2_PG17_SERVER_VERSION="${G2_PG17_SERVER_VERSION:-170006}"
# Same heap as .github/workflows/ci.yml rls-live-tests; ts-jest OOMs (exit 137) at the 2 GB default (observed 2026-09-20).
export NODE_OPTIONS=--max-old-space-size=4096
STAGE="${1:-all}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
case "$STAGE" in oldroot|guard|bootstrap|live|all|reset) ;; *) echo "unknown stage $STAGE" >&2; exit 2;; esac

stamp() {
  cd "$W" || return 1
  { echo "TS=$TS STAGE=$STAGE RUNNER=s5-r3"; echo "HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree})"
    git status --short; echo "node $(node -v 2>/dev/null) npm $(npm -v 2>/dev/null) psql: $("$G2_PG17_PSQL" --version 2>/dev/null || echo absent)"
    env | grep -E '^(G2_PG17_(DATABASE_URL|CONFIRM|PSQL|OLD_ROOT|OLD_CLIENT|DATA_DIRECTORY|SERVER_VERSION)|NODE_OPTIONS)=' | sort
    echo "G2_PG17_PASSWORD=<from environment, not logged>"; nproc; free -m | head -2
  } | tee "$L/env-$STAGE-$TS.log"
}

if [ "$STAGE" = oldroot ]; then
  # Offline; no fixture password, DB or lock required.
  stamp || exit 1
  echo "CMD: G2_PG17_OLD_ROOT=$G2_PG17_OLD_ROOT bash test/utils/g2-pg17-old-root.sh create" | tee "$L/oldroot-$TS.log"
  bash test/utils/g2-pg17-old-root.sh create 2>&1 | tee -a "$L/oldroot-$TS.log"; rc=${PIPESTATUS[0]}
  echo "PROOF_EXIT=$rc STAGE=$STAGE TS=$TS" | tee "$L/exit-$STAGE-$TS.log"; exit "$rc"
fi

: "${G2_PG17_PASSWORD:?fixture password must come from the environment, never from this file}"
export G2_PG17_PASSWORD
cd "$X" || exit 1
(
  flock -n 9 || { echo "test-validation.lock busy; not queueing (rc 75)" | tee "$L/exit-$STAGE-$TS.log"; exit 75; }
  echo "$(date -u +%FT%TZ) HOLDER=s5-r3 PURPOSE=g2-pg17-proof-$STAGE" >> test-validation.lock.log
  echo "S5-R3 g2-pg17-proof-$STAGE $(date -u +%FT%TZ)" >> test-validation.lock.holders
  release() { cd "$X"; echo "$(date -u +%FT%TZ) RELEASE=s5-r3 rc=$1" >> test-validation.lock.log
    echo "S5-R3 g2-pg17-proof-$STAGE released $(date -u +%FT%TZ)" >> test-validation.lock.holders
    echo "PROOF_EXIT=$1 STAGE=$STAGE TS=$TS" | tee "$L/exit-$STAGE-$TS.log"; exit "$1"; }
  if [ -x /home/user/pg17/lane-pg.sh ]; then /home/user/pg17/lane-pg.sh s5 status 2>&1 | tee "$L/pg-status-$TS.log"; else echo "lane-pg.sh absent" | tee "$L/pg-status-$TS.log"; fi
  stamp || release 1
  if [ "$STAGE" = reset ]; then
    PGPASSWORD="$G2_PG17_PASSWORD" "$G2_PG17_PSQL" -X -w -qAt -v ON_ERROR_STOP=1 'postgresql://s5_super@127.0.0.1:54325/postgres' \
      -c 'DROP DATABASE IF EXISTS g2_s5_etq0_disposable' 2>&1 | tee "$L/reset-$TS.log"; release "${PIPESTATUS[0]}"
  fi
  if [ "$STAGE" = all ] || [ "$STAGE" = guard ]; then
    echo "CMD: npx jest test/scout/g2-pg17-db-guard.spec.ts" | tee "$L/guard-unit-$TS.log"
    npx jest test/scout/g2-pg17-db-guard.spec.ts 2>&1 | tee -a "$L/guard-unit-$TS.log"; rc=${PIPESTATUS[0]}
    [ "$rc" = 0 ] || { echo "guard stage failed rc=$rc; stopping" | tee -a "$L/guard-unit-$TS.log"; release "$rc"; }
  fi
  if [ "$STAGE" = all ]; then
    echo "CMD: bash test/utils/g2-pg17-old-root.sh create" | tee "$L/oldroot-$TS.log"
    bash test/utils/g2-pg17-old-root.sh create 2>&1 | tee -a "$L/oldroot-$TS.log"; rc=${PIPESTATUS[0]}
    [ "$rc" = 0 ] || { echo "old-root stage failed rc=$rc; bootstrap NOT started" | tee -a "$L/oldroot-$TS.log"; release "$rc"; }
  fi
  if [ "$STAGE" = all ] || [ "$STAGE" = bootstrap ]; then
    echo "CMD: bash test/utils/g2-pg17-bootstrap.sh" | tee "$L/bootstrap-$TS.log"
    bash test/utils/g2-pg17-bootstrap.sh 2>&1 | tee -a "$L/bootstrap-$TS.log"; rc=${PIPESTATUS[0]}
    [ "$rc" = 0 ] || { echo "bootstrap failed rc=$rc; live proof NOT started" | tee -a "$L/bootstrap-$TS.log"; release "$rc"; }
  fi
  if [ "$STAGE" = all ] || [ "$STAGE" = live ]; then
    echo "CMD: npx jest --config jest.rls.config.js test/rls-g2-pg17-etq0.spec.ts --runInBand --testTimeout=180000" | tee "$L/live-etq0-$TS.log"
    npx jest --config jest.rls.config.js test/rls-g2-pg17-etq0.spec.ts --runInBand --testTimeout=180000 2>&1 | tee -a "$L/live-etq0-$TS.log"; rc=${PIPESTATUS[0]}
    [ "$rc" = 0 ] || release "$rc"
  fi
  release 0
) 9>test-validation.lock
