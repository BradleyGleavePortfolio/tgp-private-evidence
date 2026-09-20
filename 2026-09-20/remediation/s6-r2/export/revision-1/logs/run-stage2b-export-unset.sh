#!/bin/bash
# Stage 2b: flags-unset cold-cache export (re-run; attempt 1 in run-stage2-export.sh failed to start because `env -u` cannot exec a shell function).
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true EXPO_NO_TELEMETRY=1
unset EXPO_PUBLIC_FF_EXTENSION_IMPORT EXPO_PUBLIC_FF_IMPORT_REVIEW
cd /home/user/workspace/worktrees/s6-export
LOG=/home/user/workspace/execution/s6-export-r2/logs
OUTDIR=/home/user/workspace/execution/s6-export-r2
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "LOCK_HELD $(date -u +%FT%TZ)" | tee -a $LOG/summary.txt; exit 3; }
echo "stage2b lock acquired $(date -u +%FT%TZ) pid $$ (s6-export fixer)" >> $LOG/lock-holder.txt
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
echo "env check: EXPO_PUBLIC_FF_EXTENSION_IMPORT=${EXPO_PUBLIC_FF_EXTENSION_IMPORT-<unset>} EXPO_PUBLIC_FF_IMPORT_REVIEW=${EXPO_PUBLIC_FF_IMPORT_REVIEW-<unset>}; env | grep -c '^EXPO_PUBLIC_FF' || true" > $LOG/13a-flags-unset-env-check.log
rm -rf "$OUTDIR/export-android-flags-unset" /home/user/workspace/execution/s6-export-r2/tmp/metro-cache
NODE_ENV=production TMPDIR=/home/user/workspace/execution/s6-export-r2/tmp \
  run 13-expo-export-android-flags-unset npx expo export --platform android --no-bytecode --clear --output-dir "$OUTDIR/export-android-flags-unset"
{
  for f in $(find "$OUTDIR/export-android-flags-unset" -type f -name '*.js'); do
    echo "--- $f"; ls -l "$f"; sha256sum "$f"
    echo "process.env[ (computed) occurrences: $(grep -o 'process\.env\[' "$f" | wc -l)"
    echo "process.env.EXPO_PUBLIC occurrences: $(grep -o 'process\.env\.EXPO_PUBLIC[A-Z_]*' "$f" | sort | uniq -c)"
    echo "EXPO_PUBLIC_FF_EXTENSION_IMPORT literal occurrences: $(grep -o 'EXPO_PUBLIC_FF_EXTENSION_IMPORT' "$f" | wc -l)"
    echo "flag table contexts:"; grep -o '.\{60\}EXPO_PUBLIC_FF_EXTENSION_IMPORT.\{50\}' "$f"
    echo "react-native-mmkv string occurrences: $(grep -o 'react-native-mmkv' "$f" | wc -l)"
    echo "react-native-mmkv contexts:"; grep -o '.\{120\}react-native-mmkv.\{60\}' "$f" | head -5
    echo "tgp-mmkv-enc occurrences: $(grep -o 'tgp-mmkv-enc' "$f" | wc -l)"
  done
} > $LOG/14-residue-flags-unset.log 2>&1
{ echo "post-export status_short_lines=$(git status --short | wc -l)"; git status --short; echo "stub present after export: $([ -e node_modules/react-native-mmkv ] && echo yes || echo no)"; } > $LOG/15-post-export-state.log 2>&1
echo "stage2b released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
