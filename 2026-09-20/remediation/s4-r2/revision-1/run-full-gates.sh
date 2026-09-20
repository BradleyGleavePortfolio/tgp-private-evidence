#!/bin/bash
cd /home/user/workspace/worktrees/s4-importer || exit 1
TAG=$1; E=/home/user/workspace/execution/s4-importer; LOCK=/home/user/workspace/execution/test-validation.lock
exec 9>>"$LOCK"; flock -w 2400 9 || { echo "lock timeout" > "$E/logs/full-gates.$TAG.log"; exit 1; }
echo "S4 full-gates $TAG pid=$$ since $(date -u +%FT%TZ)" >> "$LOCK.holders"
H=$(git rev-parse HEAD)
{
  echo "head=$H tree=$(git rev-parse HEAD^{tree}) dirty=$(git status --porcelain | wc -l) node=$(node -v) start=$(date -u +%FT%TZ)"
  echo "== vitest =="; timeout 1500 npx vitest run --passWithNoTests=false > "$E/logs/vitest.$TAG.log" 2>&1; echo "vitest exit=$?"; tail -6 "$E/logs/vitest.$TAG.log"
  echo "== lint =="; timeout 600 npm run lint > "$E/logs/lint.$TAG.log" 2>&1; echo "lint exit=$?"
  echo "== type-check =="; timeout 600 npm run type-check > "$E/logs/type-check.$TAG.log" 2>&1; echo "type-check exit=$?"
  echo "== format:check =="; timeout 600 npm run format:check > "$E/logs/format-check.$TAG.log" 2>&1; echo "format:check exit=$?"
  echo "== gates =="; timeout 600 npm run gates > "$E/logs/gates.$TAG.log" 2>&1; echo "gates exit=$?"
  echo "== package reproduce =="; node scripts/package-extension.mjs 2>&1 | tail -2; sha256sum dist/tgp-importer-extension-0.3.0-rc.1.zip
  echo "end=$(date -u +%FT%TZ)"
} > "$E/logs/full-gates.$TAG.log" 2>&1
echo "released by S4 full-gates $TAG at $(date -u +%FT%TZ)" >> "$LOCK.holders"; flock -u 9
