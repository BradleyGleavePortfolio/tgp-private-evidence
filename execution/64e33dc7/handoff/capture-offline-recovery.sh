#!/usr/bin/env bash
set -euo pipefail

# Owner-authorized handoff capture only. No database, gate, lock or product write.
W=/home/user/workspace
R="$W/execution/64e33dc7/recovery-reset"
OUT="$W/tgp-private-evidence/execution/64e33dc7/handoff/offline-recovery"
test ! -e "$OUT" || { echo "refuse: output already exists" >&2; exit 70; }
if ps -eo comm= | awk '$1 == "postgres" || $1 == "postmaster" {found=1} END {exit !found}'; then
  echo "refuse: PostgreSQL process present" >&2
  exit 71
fi
if lslocks -n -o PATH | rg -q '/execution/test-validation\.lock$'; then
  echo "refuse: canonical lock held" >&2
  exit 72
fi
for lane in clusters/s7l clusters/s8-c proof-v3/clusters/s7l; do
  test -f "$R/$lane/pg-data/PG_VERSION"
  test ! -e "$R/$lane/pg-data/postmaster.pid"
done
mkdir -p "$OUT"
{
  date -u '+captured_at=%Y-%m-%dT%H:%M:%SZ'
  stat -c 'canonical_lock_inode=%i' "$W/execution/test-validation.lock"
  printf 'method=offline tar only; no PostgreSQL execution; originals unchanged\n'
  for lane in clusters/s7l clusters/s8-c proof-v3/clusters/s7l; do
    printf '\nlane=%s\n' "$lane"
    sha256sum "$R/$lane/pg-data/postgresql.conf" "$R/$lane/pg-data/global/pg_control"
  done
} > "$OUT/CAPTURE_RECEIPT.txt"

tar -C "$R" -czf "$OUT/s7l-failed-v2-lane.tar.gz" clusters/s7l
tar -C "$R" -czf "$OUT/s8c-failed-v3-lane.tar.gz" clusters/s8-c
tar -C "$R" -czf "$OUT/s7l-failed-v3-lane.tar.gz" proof-v3/clusters/s7l
tar -C "$R" -czf "$OUT/s7l-old-clients.tar.gz" \
  s7l/old-root/.g2-s7l-old-client proof-v3/s7l/old-root/.g2-s7l-old-client

# Preserve exact class-identity provenance without copying dependency trees.
cp -p "$W/worktrees/64e33dc7-s7l/node_modules/@prisma/client/runtime/library.js" \
  "$OUT/package-runtime-library.js"
cp -p "$R/clusters/s7l/pg.log" "$OUT/s7l-failed-v2.pg.log"
cp -p "$R/clusters/s8-c/pg.log" "$OUT/s8c-failed-v3.pg.log"
cp -p "$R/proof-v3/clusters/s7l/pg.log" "$OUT/s7l-failed-v3.pg.log"

for archive in "$OUT"/*.tar.gz; do
  tar -tzf "$archive" > "$archive.members.txt"
done
(
  cd "$OUT"
  sha256sum CAPTURE_RECEIPT.txt *.tar.gz *.members.txt *.js *.log > MANIFEST.sha256
  sha256sum -c MANIFEST.sha256
)
du -h "$OUT"/*.tar.gz
