#!/bin/bash
# Stage 2: authentic cold-cache Android release exports (flag ON, then flags unset), residue checks, stub-absence proof.
# Cold cache: Expo's Metro FileStore lives at $TMPDIR/metro-cache; a private, empty TMPDIR guarantees cold state
# without clearing the shared /tmp cache another lane may rely on. --clear is passed as well.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true EXPO_NO_TELEMETRY=1
cd /home/user/workspace/worktrees/s6-export
LOG=/home/user/workspace/execution/s6-export-r2/logs
OUTDIR=/home/user/workspace/execution/s6-export-r2
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "LOCK_HELD $(date -u +%FT%TZ)" | tee -a $LOG/summary.txt; exit 3; }
echo "stage2 lock acquired $(date -u +%FT%TZ) pid $$ (s6-export fixer)" >> $LOG/lock-holder.txt
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
{
  echo "HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree}) BRANCH=$(git rev-parse --abbrev-ref HEAD)"
  echo "status_short_lines=$(git status --short | wc -l)"; git status --short
  echo "node=$(node --version) npm=$(npm --version)"
  echo "node_modules -> $(readlink -f node_modules)"
  echo "react-native-mmkv in node_modules: $([ -e node_modules/react-native-mmkv ] && echo PRESENT || echo ABSENT)"
  echo "react-native-mmkv anywhere under node_modules (find -maxdepth 3): $(find -L node_modules -maxdepth 3 -type d -name 'react-native-mmkv' 2>/dev/null | wc -l) dirs"
  echo "declared in package.json: $(grep -c '"react-native-mmkv"' package.json) ; in lockfile: $(grep -c 'node_modules/react-native-mmkv"' package-lock.json)"
} > $LOG/10-export-preconditions.log 2>&1
residue() { # $1 = export dir, $2 = log name
  {
    echo "bundle files:"; find "$1" -type f -name '*.js' -o -type f -name '*.hbc' | sort
    for f in $(find "$1" -type f -name '*.js'); do
      echo "--- $f"; ls -l "$f"; sha256sum "$f"
      echo "process.env[ (computed) occurrences: $(grep -o 'process\.env\[' "$f" | wc -l)"
      echo "process.env.EXPO_PUBLIC occurrences: $(grep -o 'process\.env\.EXPO_PUBLIC[A-Z_]*' "$f" | sort | uniq -c)"
      echo "EXPO_PUBLIC_FF_EXTENSION_IMPORT literal occurrences: $(grep -o 'EXPO_PUBLIC_FF_EXTENSION_IMPORT' "$f" | wc -l)"
      echo "EXPO_PUBLIC_FF_IMPORT_REVIEW literal occurrences: $(grep -o 'EXPO_PUBLIC_FF_IMPORT_REVIEW' "$f" | wc -l)"
      echo "extensionImport contexts:"; grep -o '.\{60\}extensionImport.\{80\}' "$f" | head -5
      echo "react-native-mmkv string occurrences: $(grep -o 'react-native-mmkv' "$f" | wc -l)"
      echo "react-native-mmkv contexts:"; grep -o '.\{120\}react-native-mmkv.\{60\}' "$f" | head -5
      echo "tgp-mmkv-enc occurrences: $(grep -o 'tgp-mmkv-enc' "$f" | wc -l)"
    done
  } > $LOG/$2.log 2>&1
}
# A) flag ON
rm -rf "$OUTDIR/export-android-flag-on" /home/user/workspace/execution/s6-export-r2/tmp/metro-cache
EXPO_PUBLIC_FF_EXTENSION_IMPORT=true NODE_ENV=production TMPDIR=/home/user/workspace/execution/s6-export-r2/tmp \
  run 11-expo-export-android-flag-on npx expo export --platform android --no-bytecode --clear --output-dir "$OUTDIR/export-android-flag-on"
residue "$OUTDIR/export-android-flag-on" 12-residue-flag-on
# B) flags unset, cold again
rm -rf "$OUTDIR/export-android-flags-unset" /home/user/workspace/execution/s6-export-r2/tmp/metro-cache
env -u EXPO_PUBLIC_FF_EXTENSION_IMPORT -u EXPO_PUBLIC_FF_IMPORT_REVIEW NODE_ENV=production TMPDIR=/home/user/workspace/execution/s6-export-r2/tmp \
  run 13-expo-export-android-flags-unset npx expo export --platform android --no-bytecode --clear --output-dir "$OUTDIR/export-android-flags-unset"
residue "$OUTDIR/export-android-flags-unset" 14-residue-flags-unset
{ echo "post-export status_short_lines=$(git status --short | wc -l)"; git status --short; echo "stub present after export: $([ -e node_modules/react-native-mmkv ] && echo yes || echo no)"; } > $LOG/15-post-export-state.log 2>&1
echo "stage2 released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
