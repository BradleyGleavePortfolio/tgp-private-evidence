#!/usr/bin/env bash
# S7-L private draft checkpoint: exact changed/untracked bytes + manifest. Idempotent; overwrites the lane's current snapshot.
set -euo pipefail
WT=/home/user/workspace/worktrees/64e33dc7-s7l
LANE=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l
TAG=${1:-draft}
OUT=$LANE/checkpoints/$TAG
mkdir -p "$OUT/files"
cd "$WT"
git -c core.quotepath=off diff --binary HEAD > "$OUT/tracked-changes.patch"
git status --porcelain=v1 --untracked-files=all > "$OUT/git-status.txt"
git rev-parse HEAD > "$OUT/base-head.txt"
git rev-parse --abbrev-ref HEAD > "$OUT/branch.txt"
: > "$OUT/MANIFEST.sha256"
while IFS= read -r line; do
  f=${line:3}
  [ -f "$f" ] || continue
  mkdir -p "$OUT/files/$(dirname "$f")"
  cp -p "$f" "$OUT/files/$f"
  sha256sum "$f" >> "$OUT/MANIFEST.sha256"
done < "$OUT/git-status.txt"
sha256sum "$OUT/tracked-changes.patch" | sed "s#$OUT/##" >> "$OUT/MANIFEST.sha256"
date -u +%Y-%m-%dT%H:%M:%SZ > "$OUT/captured-at-utc.txt"
echo "checkpoint $TAG: $(wc -l < "$OUT/MANIFEST.sha256") entries, base $(cat "$OUT/base-head.txt")"
