#!/usr/bin/env bash
# EXEC-DACEDDC8 RT-2 step 3: builder-lane provisioning in a fresh sandbox (SCOPE.md grant RT-2). Environment only.
# Reproduces the recorded 64e33dc7 lane environments: real `cp -a` donor node_modules into each builder worktree
# (s7l/SOURCE_READY.md:19-21), S7-L in-lane `npx prisma generate` from its committed schema (must equal recorded
# 9042e713 / b8439203), isolated prettier prefix copies per runtime/formatter/FORMATTER_TOOLING_RECEIPT.md steps 1-3.
# Canonical lock nonblocking on fd9 IN THIS PROCESS until exit; lock file never deleted. Any mismatch refuses (no repin).
# NOT performed: initdb, cluster, bootstrap, jest, tsc, lint, formatting, commit, PG.
# Usage: timeout -k 30 1800 bash lane-provision.sh
set -uo pipefail
EVD=/home/user/workspace/tgp-private-evidence/execution/daceddc8/runtime; R=$EVD/raw
LOG=$R/lane-provision.log; SENT=$R/lane-provision.sentinel
ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LOCK=/home/user/workspace/execution/test-validation.lock
DONOR=/home/user/workspace/worktrees/64e33dc7-env
S7L=/home/user/workspace/worktrees/64e33dc7-s7l; S8C=/home/user/workspace/worktrees/64e33dc7-s8c
PFX=$ROOT/tools/prettier-3.9.9
PFX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
NM_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
DONOR_CLIENT=b6716a865a705ffc0efab30ed88cd163b461e5344ad64e5926a0dff078b49f44
S7L_SCHEMA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015
S7L_CLIENT=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6
S7L_CLIENT_SCHEMA=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e
S8C_SCHEMA=77f33bcdc36802f8e1d52553d011f546f56f757cacb391f23436ab266a148589
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists (do not loop)" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
procs(){ ps -eo pid,comm,args --no-headers | awk '$2 ~ /^(postgres|postmaster|pg_ctl|initdb|jest|tsc|npm|npx|prisma|prettier|lefthook)$/ || $0 ~ /(jest|tsc|prisma|pg_ctl|postgres|prettier)/' | grep -v -e awk -e lane-provision -e 'ps -eo' || true; }
STAGE=preflight
[ -e "$LOCK" ] || { log "REFUSED: lock file absent (RT-2 step 1 creates it)"; exit 75; }
P=$(procs); log "PRE $(ts) relevant_processes=[${P:-none}]"
[ -z "$P" ] || { log "REFUSED: relevant live process"; echo "RC=74 STAGE=preflight END=$(ts)" >"$SENT"; exit 74; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED: canonical lock busy ($LOCK)"; exit 75; }
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts)" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts) (fd9 released on exit)"; exit "$1"; }
log "START $(ts) pid=$$ lock=$LOCK held fd9 inode=$(stat -c %i "$LOCK") holders=[$(lslocks -n -o PID,PATH 2>/dev/null | grep test-validation | tr -s ' ')]"
[ -f "$R/rt-setup.sentinel" ] && grep -q '^RC=0 STAGE=done' "$R/rt-setup.sentinel" || { log "REFUSED: rt-setup not RC=0"; finish 70; }
grep -q '^RC=0 STAGE=done' "$EVD/formatter/raw/fmt-tool.sentinel" 2>/dev/null || { log "REFUSED: fmt-tool not RC=0"; finish 70; }
[ "$(sha "$DONOR/node_modules/.package-lock.json")" = "$NM_LOCK" ] && [ "$(sha "$DONOR/node_modules/.prisma/client/index.d.ts")" = "$DONOR_CLIENT" ] || { log "REFUSED: donor identity mismatch"; finish 70; }
DSIG_BEFORE=$(git -C "$DONOR" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
for W in "$S7L" "$S8C"; do
  STAGE="copy:$(basename "$W")"
  [ -e "$W/node_modules" ] && { log "REFUSED: $W/node_modules exists"; finish 70; }
  log "worktree=$W head=$(git -C "$W" rev-parse HEAD) status=[$(git -C "$W" status --porcelain --untracked-files=all | tr '\n' ' ')]"
  t0=$(date +%s); cp -a "$DONOR/node_modules" "$W/node_modules"; rc=$?; log "cp_a_exit=$rc secs=$(( $(date +%s)-t0 ))"; [ $rc = 0 ] || finish $rc
  [ ! -L "$W/node_modules" ] || { log "node_modules is a symlink"; finish 70; }
  [ "$(sha "$W/node_modules/.package-lock.json")" = "$NM_LOCK" ] || { log "hidden lock mismatch in $W"; finish 70; }
  log "copy_ok hidden_lock=$NM_LOCK top=$(ls -1 "$W/node_modules" | wc -l) client_index_d_ts=$(sha "$W/node_modules/.prisma/client/index.d.ts") schema=$(sha "$W/prisma/schema.prisma")"
done
STAGE=s7l_generate
[ "$(sha "$S7L/prisma/schema.prisma")" = "$S7L_SCHEMA" ] || { log "S7-L schema != $S7L_SCHEMA"; finish 70; }
( cd "$S7L" && export npm_config_offline=true && timeout --foreground 600 npx --no-install prisma generate ) >"$R/s7l-prisma-generate.out" 2>&1; rc=$?
cat "$R/s7l-prisma-generate.out" >>"$LOG"; log "s7l_prisma_generate_exit=$rc"; [ $rc = 0 ] || finish $rc
C=$(sha "$S7L/node_modules/.prisma/client/index.d.ts"); CS=$(sha "$S7L/node_modules/.prisma/client/schema.prisma")
log "s7l_client_index_d_ts=$C expect=$S7L_CLIENT client_schema=$CS expect=$S7L_CLIENT_SCHEMA"
[ "$C" = "$S7L_CLIENT" ] && [ "$CS" = "$S7L_CLIENT_SCHEMA" ] || { log "S7-L generated client != recorded; refusing (no repin)"; finish 70; }
STAGE=s8c_verify
[ "$(sha "$S8C/prisma/schema.prisma")" = "$S8C_SCHEMA" ] && [ "$(sha "$S8C/node_modules/.prisma/client/index.d.ts")" = "$DONOR_CLIENT" ] || { log "S8-C schema/client != record"; finish 70; }
log "s8c_client_index_d_ts=$DONOR_CLIENT (donor copy, no generate)"
STAGE=prettier
for L in s7l s8c; do B=$ROOT/$L/tools/prettier-3.9.9
  [ -e "$B" ] && { log "REFUSED: $B exists"; finish 70; }
  mkdir -p "$(dirname "$B")" && cp -a "$PFX" "$B" || finish 70
  ( cd "$B" && sha256sum -c --quiet "$PFX_MANIFEST" ) >>"$LOG" 2>&1 || { log "prefix manifest check failed for $B"; finish 70; }
  [ "$(readlink "$B/bin/prettier")" = ../lib/node_modules/prettier/bin/prettier.cjs ] || { log "bin symlink wrong in $B"; finish 70; }
  W=$S7L; [ $L = s8c ] && W=$S8C
  V=$(cd "$W" && npm_config_prefix="$B" npm_config_offline=true npx --no-install prettier --version 2>&1); log "prefix=$B files=$(wc -l <"$PFX_MANIFEST") npx_prettier_in_$L=$V"
  [ "$V" = 3.9.9 ] || finish 70
done
STAGE=verify
for W in "$S7L" "$S8C"; do log "post $(basename "$W") head=$(git -C "$W" rev-parse HEAD) status=[$(git -C "$W" status --porcelain --untracked-files=all | tr '\n' ' ')]"; done
[ "$(git -C "$DONOR" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$DSIG_BEFORE" ] && [ "$(sha "$DONOR/node_modules/.package-lock.json")" = "$NM_LOCK" ] || { log "donor changed"; finish 70; }
log "donor_unchanged=yes postgres_procs=$(pgrep -cx postgres || true)"; df -h / | tail -1 | tee -a "$LOG"
STAGE=done; finish 0
