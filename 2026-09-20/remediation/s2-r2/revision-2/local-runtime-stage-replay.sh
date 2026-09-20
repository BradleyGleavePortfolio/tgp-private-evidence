#!/usr/bin/env bash
# Isolated replay of the Dockerfile runtime stage on the sandbox host (NOT a Docker build).
set -uo pipefail
WT=/home/user/workspace/worktrees/s2-delivery
P=/tmp/s2-runtime-proof
LOG=/tmp/s2-runtime-proof.log
exec >"$LOG" 2>&1
echo "start $(date -u +%FT%TZ) head=$(git -C "$WT" rev-parse HEAD)"
rm -rf "$P"; mkdir -p "$P/scripts"
cp "$WT"/package.json "$WT"/package-lock.json "$P"/
cp -r "$WT"/prisma "$P"/prisma
cp "$WT"/scripts/release.sh "$P"/scripts/release.sh
HL=/home/user/workspace/execution/heavy-validation.lock
exec 8>>"$HL"; flock -w 3600 8 || { echo "heavy lock timeout"; exit 90; }
echo "S2-delivery runtime-proof npm ci --omit=dev (lifecycle on) pid=$$ since $(date -u +%FT%TZ)" > "$HL"
cd "$P" && npm pkg delete scripts.prepare && SCARF_ANALYTICS=false npm ci --omit=dev --no-audit --no-fund; echo "install exit=$?"
echo "released by S2-delivery at $(date -u +%FT%TZ)" > "$HL"; flock -u 8
TL=/home/user/workspace/execution/test-validation.lock
exec 9>>"$TL"; flock -w 3600 9 || { echo "test lock timeout"; exit 91; }
echo "S2-delivery runtime-proof nest build pid=$$ since $(date -u +%FT%TZ)" > "$TL"
(cd "$WT" && rm -rf dist && npx prisma generate >/dev/null 2>&1; npm run build); echo "build exit=$?"
echo "released by S2-delivery at $(date -u +%FT%TZ)" > "$TL"; flock -u 9
rm -rf "$P/dist"; cp -r "$WT/dist" "$P/dist"
cd "$P"
node -e "['prisma/package.json','@prisma/client/package.json','@nestjs/core/package.json'].forEach(p => require.resolve(p))" \
    && for p in jest ts-jest ts-node @nestjs/cli @nestjs/testing eslint lefthook danger supertest; do \
         if [ -e "node_modules/$p" ]; then echo "artifact check failed: dev tool $p present in runtime image" >&2; exit 1; fi; \
       done \
    && test -f dist/main.js \
    && test -f prisma/schema.prisma \
    && test -f prisma/seed-diagnostic.json \
    && test -f scripts/release.sh \
    && echo "artifact check OK"
echo "assertion exit=$?"
ls node_modules/.prisma/client 2>/dev/null | head -5; ls node_modules/@prisma/engines/ 2>/dev/null | rg -i "engine|query" | head -3
echo "end $(date -u +%FT%TZ)"
