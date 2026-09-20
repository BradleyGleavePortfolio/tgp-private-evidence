#!/bin/bash
# Stage 3: bind proof to the committed head d7079265: focused jest + cold flag-ON export on the exact commit, then env stamp.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true EXPO_NO_TELEMETRY=1
unset EXPO_PUBLIC_FF_IMPORT_REVIEW
cd /home/user/workspace/worktrees/s6-export
LOG=/home/user/workspace/execution/s6-export-r2/logs
OUTDIR=/home/user/workspace/execution/s6-export-r2
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "LOCK_HELD $(date -u +%FT%TZ)" | tee -a $LOG/summary.txt; exit 3; }
echo "stage3 lock acquired $(date -u +%FT%TZ) pid $$ (s6-export fixer)" >> $LOG/lock-holder.txt
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
echo "committed HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree}) diff-vs-HEAD-lines=$(git diff HEAD --stat | wc -l)" | tee -a $LOG/summary.txt
run 20-jest-focused-committed-head npx jest --ci src/storage src/config src/services/__tests__/authActions.test.ts src/services/__tests__/authActions.signOut.test.ts src/services/__tests__/queryClient.signout.test.ts src/lib src/navigation src/__tests__/biometricLockService.test.ts src/screens/coach/ed/__tests__/firstPaymentGate.test.ts src/screens/client/__tests__/MessagesScreenCache.test.ts
rm -rf "$OUTDIR/export-android-flag-on-committed-head" /home/user/workspace/execution/s6-export-r2/tmp/metro-cache
EXPO_PUBLIC_FF_EXTENSION_IMPORT=true NODE_ENV=production TMPDIR=/home/user/workspace/execution/s6-export-r2/tmp \
  run 21-expo-export-android-flag-on-committed-head npx expo export --platform android --no-bytecode --clear --output-dir "$OUTDIR/export-android-flag-on-committed-head"
f=$(find "$OUTDIR/export-android-flag-on-committed-head" -type f -name '*.js' | head -1)
{ echo "bundle: $f"; sha256sum "$f"; echo "EXTENSION_IMPORT table: $(grep -o 'EXPO_PUBLIC_FF_EXTENSION_IMPORT:[^,]*' "$f")"; echo "react-native-mmkv occurrences: $(grep -o 'react-native-mmkv' "$f" | wc -l)"; grep -o '.\{40\}r(d\[2\],"react-native-mmkv").\{30\}' "$f"; } > $LOG/22-residue-flag-on-committed-head.log 2>&1
{
  echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"; echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"; echo "PARENT=$(git rev-parse HEAD^)"
  echo "STATUS_SHORT_BEFORE_SYMLINK_REMOVAL:"; git status --short
  echo "NODE=$(node --version) NPM=$(npm --version) NODE_BIN=$(command -v node)"
  echo "JEST=$(npx jest --version 2>/dev/null)"; echo "EXPO_CLI=$(npx expo --version 2>/dev/null)"
  echo "node_modules symlink target: $(readlink node_modules)"
  echo "MMKV_STUB_PRESENT=$([ -e node_modules/react-native-mmkv ] && echo yes || echo no)"
  echo "MMKV_DECLARED_package.json=$(grep -c '"react-native-mmkv"' package.json) MMKV_IN_LOCKFILE=$(grep -c 'node_modules/react-native-mmkv"' package-lock.json)"
  echo "shared s6 worktree status lines: $(git -C /home/user/workspace/worktrees/s6 status --short | wc -l) (0 = untouched)"
  echo "END=$(date -u +%FT%TZ)"
} > $LOG/23-final-env-stamp.log 2>&1
echo "stage3 released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
