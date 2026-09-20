#!/bin/bash
# S6 final composition + cumulative validation. Run ONLY after the export lane is frozen.
# Exit codes: 0 all stages passed; 1 one or more stages failed (all stages still run, all stamped);
#             3 lock held; 4 precondition failed; 5 merge failed.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true EXPO_NO_TELEMETRY=1
E=/home/user/workspace/execution/s6-final-r2; LOG=$E/logs; W=/home/user/workspace/worktrees/s6-final
NPMCI_SRC=/home/user/workspace/worktrees/s6            # where node_modules was produced by `npm ci`
EXPORT_HEAD=d7079265ea1263a1af6cd9cd132fc18dcb1793d9
PAIRING_HEAD=eaccaba98bc4400a0341bcd80409ab317bc85856
EXPECT_IDENT="Bradley Gleave <bradley@bradleytgpcoaching.com>"
FAILURES=0
cd $W || exit 4
log() { echo "$*" | tee -a $LOG/summary.txt; }
fail() { FAILURES=$((FAILURES+1)); log "   FAIL: $*"; }
stamp() { # name cmd
  local S=$LOG/$1.STAMP
  { echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"; echo "PARENTS=$(git log -1 --format=%P)"; echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
    echo "STATUS_SHORT_LINES=$(git status --short | wc -l) (0 = clean)"
    echo "NODE=$(node --version) NPM=$(npm --version) NODE_BIN=$(command -v node) NODE_OPTIONS=${NODE_OPTIONS-<unset>}"
    echo "NODE_MODULES=$(readlink -f node_modules) (read-only symlink; excluded via .git/info/exclude)"
    echo "MMKV_STUB_PRESENT=$([ -e node_modules/react-native-mmkv ] && echo yes || echo no)"
    echo "PACKAGE_JSON_SHA256=$(sha256sum < package.json | cut -c1-64) PACKAGE_LOCK_SHA256=$(sha256sum < package-lock.json | cut -c1-64)"
    echo "ENV: CI=$CI NODE_ENV=${NODE_ENV-<unset>} EXPO_PUBLIC_FF_EXTENSION_IMPORT=${EXPO_PUBLIC_FF_EXTENSION_IMPORT-<unset>} EXPO_PUBLIC_FF_IMPORT_REVIEW=${EXPO_PUBLIC_FF_IMPORT_REVIEW-<unset>} TMPDIR=${TMPDIR-<unset>}"
    echo "CMD=$2"; echo "START=$(date -u +%FT%TZ)"; } > $S
}
stamp_end() { echo "END=$(date -u +%FT%TZ)" >> $LOG/$1.STAMP; echo "CHILD_EXIT=$2" >> $LOG/$1.STAMP; }
run() { # name cmd...
  local N=$1; shift
  stamp $N "$*"; log "== $N: $* ($(date -u +%FT%TZ))"
  "$@" > $LOG/$N.log 2>&1; local RC=$?
  stamp_end $N $RC; log "   exit=$RC ($(date -u +%FT%TZ))"
  [ $RC = 0 ] || fail "$N exit=$RC"
  return $RC
}

exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { log "LOCK_HELD at $(date -u +%FT%TZ) — aborting, nothing run"; exit 3; }
log "== S6 FINAL run start $(date -u +%FT%TZ)"

# ── Preconditions ──────────────────────────────────────────────────────────
PRE_OK=1
IDENT_A="$(git var GIT_AUTHOR_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')"; IDENT_C="$(git var GIT_COMMITTER_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')"
[ "$IDENT_A" = "$EXPECT_IDENT" ] && [ "$IDENT_C" = "$EXPECT_IDENT" ] || { log "PRECOND identity mismatch: author=[$IDENT_A] committer=[$IDENT_C]"; PRE_OK=0; }
[ -e node_modules/react-native-mmkv ] && { log "PRECOND react-native-mmkv stub present"; PRE_OK=0; }
[ "$(readlink -f node_modules)" = "$NPMCI_SRC/node_modules" ] || { log "PRECOND node_modules not the npm-ci tree"; PRE_OK=0; }
[ "${NODE_OPTIONS-}" = "" ] || { log "PRECOND NODE_OPTIONS set: $NODE_OPTIONS"; PRE_OK=0; }
[ "$(git status --short | wc -l)" = "0" ] || { log "PRECOND worktree not clean"; PRE_OK=0; }
HEAD_NOW=$(git rev-parse HEAD)
if [ "$HEAD_NOW" = "$PAIRING_HEAD" ]; then
  NEED_MERGE=1
  [ "$(git -C /home/user/workspace/worktrees/s6-export rev-parse HEAD)" = "$EXPORT_HEAD" ] || { log "PRECOND export lane HEAD != $EXPORT_HEAD (not frozen)"; PRE_OK=0; }
else
  NEED_MERGE=0
  [ "$(git log -1 --format=%P)" = "$PAIRING_HEAD $EXPORT_HEAD" ] || { log "PRECOND HEAD $HEAD_NOW is neither the pairing head nor the exact merge of $PAIRING_HEAD + $EXPORT_HEAD"; PRE_OK=0; }
fi
[ $PRE_OK = 1 ] || { log "PRECONDITIONS FAILED — aborting before any stage"; exit 4; }
log "preconditions ok: identity=[$IDENT_A]; node_modules=$(readlink -f node_modules); no stub; NODE_OPTIONS unset"

# ── 0. compose ─────────────────────────────────────────────────────────────
if [ $NEED_MERGE = 1 ]; then
  git merge --no-ff --no-edit -m "Merge execute/20260920-s6-export-r2 (bundle-safe optional react-native-mmkv) into S6 final candidate

Composes the pairing lane head ${PAIRING_HEAD} (hydration gating,
owner guard, mint attempt epoch) with the export lane head
${EXPORT_HEAD} (single Metro-optional require of
react-native-mmkv, shape-checked availability, guard + storage tests).
Both lanes branch from 60975b51 and touch disjoint files." $EXPORT_HEAD > $LOG/00-merge.log 2>&1
  RC=$?; log "== 00-merge exit=$RC HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree})"
  [ $RC = 0 ] || { log "MERGE FAILED — aborting"; exit 5; }
  git log -1 --format='%H%n%an <%ae>%n%cn <%ce>%nparents=%P%ntrailers=[%(trailers)]' | tee -a $LOG/00-merge.log
  [ "$(git log -1 --format='%an <%ae>')" = "$EXPECT_IDENT" ] && [ "$(git log -1 --format='%cn <%ce>')" = "$EXPECT_IDENT" ] || { log "MERGE identity wrong — aborting"; exit 5; }
  [ "$(git log -1 --format=%P)" = "$PAIRING_HEAD $EXPORT_HEAD" ] || { log "MERGE parents wrong — aborting"; exit 5; }
fi
[ "$(git status --short | wc -l)" = "0" ] || { log "worktree not clean after merge — aborting"; exit 5; }
# package.json / lockfile must be byte-identical to the tree node_modules was installed from
for f in package.json package-lock.json; do
  [ "$(sha256sum < $f)" = "$(sha256sum < $NPMCI_SRC/$f)" ] || { log "PRECOND $f differs from npm-ci source tree $NPMCI_SRC — node_modules not applicable, aborting"; exit 4; }
done
log "package.json/package-lock.json byte-identical to npm-ci source ($NPMCI_SRC @ $(git -C $NPMCI_SRC rev-parse HEAD))"

# ── 1–4. static + tests ────────────────────────────────────────────────────
run 01-validate-config npm run validate:config
run 02-lint npm run lint
run 03-tsc npx tsc --noEmit
run 04-jest-full timeout 660 npx jest --ci

# ── 5–8. authentic cold exports + asserted residue ─────────────────────────
residue() { # name outdir expect_ext expect_rev
  local N=$1 OUT=$2 EXP_EXT=$3 EXP_REV=$4 RC=0
  stamp $N "residue-assert $OUT ext=$EXP_EXT rev=$EXP_REV"
  {
    local NB; NB=$(find $OUT -name 'index-*.js' 2>/dev/null | wc -l); echo "bundle_count=$NB"
    [ "$NB" = "1" ] || { echo "ASSERT FAIL: expected exactly one bundle"; RC=1; }
    local F; F=$(find $OUT -name 'index-*.js' 2>/dev/null | head -1); echo "bundle=$F"
    if [ -n "$F" ]; then
      ls -l $F; sha256sum $F
      [ -s "$F" ] || { echo "ASSERT FAIL: empty bundle"; RC=1; }
      local NC; NC=$(grep -o 'process\.env\[' $F | wc -l); echo "computed process.env[ count=$NC"
      [ "$NC" = "0" ] || { echo "ASSERT FAIL: computed process.env[ reader present"; RC=1; }
      local VE; VE=$(grep -o 'EXPO_PUBLIC_FF_EXTENSION_IMPORT:[^,}]*' $F | sort -u | tr '\n' ' '); echo "EXTENSION_IMPORT table value(s)=[$VE]"
      [ "$VE" = "EXPO_PUBLIC_FF_EXTENSION_IMPORT:$EXP_EXT " ] || { echo "ASSERT FAIL: expected EXPO_PUBLIC_FF_EXTENSION_IMPORT:$EXP_EXT"; RC=1; }
      local VR; VR=$(grep -o 'EXPO_PUBLIC_FF_IMPORT_REVIEW:[^,}]*' $F | sort -u | tr '\n' ' '); echo "IMPORT_REVIEW table value(s)=[$VR]"
      [ "$VR" = "EXPO_PUBLIC_FF_IMPORT_REVIEW:$EXP_REV " ] || { echo "ASSERT FAIL: expected EXPO_PUBLIC_FF_IMPORT_REVIEW:$EXP_REV"; RC=1; }
      echo "process.env.EXPO_PUBLIC* residue contexts (informational; app flag readers must not appear):"
      grep -o '.\{40\}process\.env\.EXPO_PUBLIC[A-Z_]*' $F | sort | uniq -c
      local NF; NF=$(grep -o 'process\.env\.EXPO_PUBLIC_FF_' $F | wc -l); echo "process.env.EXPO_PUBLIC_FF_* source-reader residue count=$NF"
      [ "$NF" = "0" ] || { echo "ASSERT FAIL: un-inlined flag reader residue"; RC=1; }
      echo "react-native-mmkv mentions=$(grep -o 'react-native-mmkv' $F | wc -l)"
      echo "metadata.json present=$([ -s $OUT/metadata.json ] && echo yes || echo no)"
      [ -s $OUT/metadata.json ] || { echo "ASSERT FAIL: metadata.json missing/empty"; RC=1; }
    fi
    echo "RESIDUE_RC=$RC"
  } > $LOG/$N.log 2>&1
  stamp_end $N $RC; log "== $N exit=$RC"
  [ $RC = 0 ] || fail "$N exit=$RC"
}
rm -rf $E/export-flag-on $E/tmp-flag-on; mkdir -p $E/tmp-flag-on
( export TMPDIR=$E/tmp-flag-on NODE_ENV=production EXPO_PUBLIC_FF_EXTENSION_IMPORT=true; unset EXPO_PUBLIC_FF_IMPORT_REVIEW
  run 05-export-flag-on npx expo export --platform android --no-bytecode --clear --output-dir $E/export-flag-on ) || FAILURES=$((FAILURES+1))
residue 06-residue-flag-on $E/export-flag-on '"true"' 'void 0'

rm -rf $E/export-flags-unset $E/tmp-flags-unset; mkdir -p $E/tmp-flags-unset
( export TMPDIR=$E/tmp-flags-unset NODE_ENV=production; unset EXPO_PUBLIC_FF_EXTENSION_IMPORT EXPO_PUBLIC_FF_IMPORT_REVIEW
  run 07-export-flags-unset npx expo export --platform android --no-bytecode --clear --output-dir $E/export-flags-unset ) || FAILURES=$((FAILURES+1))
residue 08-residue-flags-unset $E/export-flags-unset 'void 0' 'void 0'

log "== S6 FINAL run end $(date -u +%FT%TZ) HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree}) clean=$(git status --short | wc -l) FAILURES=$FAILURES"
[ $FAILURES = 0 ] && exit 0 || exit 1
