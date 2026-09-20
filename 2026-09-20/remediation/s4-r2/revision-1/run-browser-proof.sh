#!/bin/bash
# usage: run-browser-proof.sh <tag>   — builds nothing; runs positive then negative-control proof under the test lock
cd /home/user/workspace/worktrees/s4-importer || exit 1
TAG=$1
E=/home/user/workspace/execution/s4-importer
LOCK=/home/user/workspace/execution/test-validation.lock
exec 9>>"$LOCK"
flock -w 2400 9 || { echo "lock timeout" > "$E/logs/browser-proof.$TAG.log"; exit 1; }
echo "S4 browser-load-proof $TAG pid=$$ since $(date -u +%FT%TZ)" >> "$LOCK.holders"
ZIP=dist/tgp-importer-extension-0.3.0-rc.1.zip
{
  echo "head=$(git rev-parse HEAD) tree=$(git rev-parse HEAD^{tree}) dirty=$(git status --porcelain | wc -l) node=$(node -v) zip_sha256=$(sha256sum $ZIP | cut -d' ' -f1) start=$(date -u +%FT%TZ)"
  echo "== positive =="
  timeout 240 node scripts/browser-load-proof.mjs --zip $ZIP --out "$E/logs/browser-load-proof.$TAG.positive.json"; echo "positive exit=$?"
  echo "== negative control =="
  timeout 240 node scripts/browser-load-proof.mjs --negative-control --zip $ZIP --out "$E/logs/browser-load-proof.$TAG.negative-control.json"; echo "negative-control exit=$?"
  echo "end=$(date -u +%FT%TZ)"
} > "$E/logs/browser-proof.$TAG.log" 2>&1
echo "released by S4 $TAG at $(date -u +%FT%TZ)" >> "$LOCK.holders"
flock -u 9
