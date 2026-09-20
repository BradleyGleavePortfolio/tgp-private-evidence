#!/usr/bin/env bash
# S5 G2 E->T/Q0 proof runner (validation harness only; synthetic disposable fixture on S1's isolated PG17.6 lane).
# Holds execution/test-validation.lock (parent 09:45 PDT: single validation job) ONLY while node/jest/prisma/psql run.
# FAIL-FAST: each stage stops the run on its first non-zero exit; a live proof never starts after a failed bootstrap.
# Usage: G2_PG17_PASSWORD=<fixture pw> bash run-proof.sh [guard|bootstrap|live|all|reset]
#   reset  drops ONLY the disposable database g2_s5_etq0_disposable (as s5_super) so bootstrap can run again.
set -uo pipefail
cd /home/user/workspace/execution || exit 1
W=/home/user/workspace/worktrees/s5-g2
L=/home/user/workspace/execution/s5-g2/logs
mkdir -p "$L"
: "${G2_PG17_PASSWORD:?fixture password must come from the environment, never from this file}"
export G2_PG17_PASSWORD
export G2_PG17_DATABASE_URL='postgresql://s5_super@127.0.0.1:54325/g2_s5_etq0_disposable?schema=public&connection_limit=2'
export G2_PG17_CONFIRM='g2_s5_etq0_disposable:54325'
export G2_PG17_PSQL=/usr/bin/psql
export G2_PG17_OLD_ROOT=/home/user/workspace/execution/s5-g2/old-root-925780e0
export G2_PG17_OLD_CLIENT=/home/user/workspace/execution/s5-g2/old-client-925780e0
export G2_PG17_DATA_DIRECTORY=/home/user/pg17/clusters/s5
export G2_PG17_SERVER_VERSION=170006
# Same heap as .github/workflows/ci.yml rls-live-tests; ts-jest OOMs (exit 137) at the 2GB default (observed 2026-09-20).
export NODE_OPTIONS=--max-old-space-size=4096
STAGE="${1:-all}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
(
  flock -w 1800 9 || { echo "lock timeout"; exit 2; }
  echo "$(date -u +%FT%TZ) HOLDER=s5-g2 PURPOSE=g2-pg17-proof-$STAGE" >> test-validation.lock.log
  echo "S5 g2-pg17-proof-$STAGE $(date -u +%FT%TZ)" >> test-validation.lock.holders
  release() { cd /home/user/workspace/execution; echo "$(date -u +%FT%TZ) RELEASE=s5-g2 rc=$1" >> test-validation.lock.log
    echo "S5 g2-pg17-proof-$STAGE released $(date -u +%FT%TZ)" >> test-validation.lock.holders
    echo "PROOF_EXIT=$1 STAGE=$STAGE TS=$TS" | tee "$L/exit-$STAGE-$TS.log"; exit "$1"; }
  /home/user/pg17/lane-pg.sh s5 status 2>&1 | tee "$L/pg-status-$TS.log"
  cd "$W" || release 1
  {
    echo "TS=$TS STAGE=$STAGE"; echo "HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree})"; git status --short
    echo "node $(node -v) npm $(npm -v) psql: $($G2_PG17_PSQL --version)"
    env | grep -E '^(G2_PG17_(DATABASE_URL|CONFIRM|PSQL|OLD_ROOT|OLD_CLIENT|DATA_DIRECTORY|SERVER_VERSION)|NODE_OPTIONS)=' | sort
    echo "G2_PG17_PASSWORD=<from environment, not logged>"; nproc; free -m | head -2
  } | tee "$L/env-$STAGE-$TS.log"
  if [ "$STAGE" = reset ]; then
    PGPASSWORD="$G2_PG17_PASSWORD" "$G2_PG17_PSQL" -X -w -qAt -v ON_ERROR_STOP=1 'postgresql://s5_super@127.0.0.1:54325/postgres' \
      -c 'DROP DATABASE IF EXISTS g2_s5_etq0_disposable' 2>&1 | tee "$L/reset-$TS.log"; release "${PIPESTATUS[0]}"
  fi
  if [ "$STAGE" = all ] || [ "$STAGE" = guard ]; then
    echo "CMD: npx jest test/scout/g2-pg17-db-guard.spec.ts" | tee "$L/guard-unit-$TS.log"
    npx jest test/scout/g2-pg17-db-guard.spec.ts 2>&1 | tee -a "$L/guard-unit-$TS.log"; rc=${PIPESTATUS[0]}
    [ "$rc" = 0 ] || { echo "guard stage failed rc=$rc; stopping" | tee -a "$L/guard-unit-$TS.log"; release "$rc"; }
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
