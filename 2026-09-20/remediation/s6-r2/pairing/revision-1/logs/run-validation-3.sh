#!/bin/bash
# Stage 3: release export with the import flag ON, then residue/inlining check.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true
cd /home/user/workspace/worktrees/s6
LOG=/home/user/workspace/execution/s6-mobile-r2/logs
OUT=/home/user/workspace/execution/s6-mobile-r2/export-android
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
exec 9>/home/user/workspace/execution/test-validation.lock
flock -w 1800 9 || { echo "LOCK_HELD $(date -u)" | tee -a $LOG/summary.txt; exit 3; }
echo "stage3 lock acquired $(date -u +%FT%TZ) pid $$" >> $LOG/lock-holder.txt
rm -rf "$OUT"
EXPO_PUBLIC_FF_EXTENSION_IMPORT=true NODE_ENV=production EXPO_NO_TELEMETRY=1 CI=1 \
  run 06b-expo-export-with-mmkv-stub npx expo export --platform android --no-bytecode --output-dir "$OUT"
{
  echo "bundle files:"; find "$OUT" -type f -name '*.hbc' -o -type f -name '*.js' | head
  for f in $(find "$OUT" -type f -name '*.js'); do
    echo "--- $f"; ls -l "$f"
    echo "process.env[ (computed) occurrences: $(grep -o 'process\.env\[' "$f" | wc -l)"
    echo "process.env.EXPO_PUBLIC occurrences: $(grep -o 'process\.env\.EXPO_PUBLIC[A-Z_]*' "$f" | wc -l)"
    echo "EXPO_PUBLIC_FF_EXTENSION_IMPORT literal occurrences: $(grep -o 'EXPO_PUBLIC_FF_EXTENSION_IMPORT' "$f" | wc -l)"
    echo "EXPO_PUBLIC_FF_IMPORT_REVIEW literal occurrences: $(grep -o 'EXPO_PUBLIC_FF_IMPORT_REVIEW' "$f" | wc -l)"
    echo "extensionImport: contexts:"; grep -o '.\{60\}extensionImport.\{80\}' "$f" | head -5
  done
} > $LOG/07b-export-residue.log 2>&1
echo "== 07b-export-residue: see 07b-export-residue.log" | tee -a $LOG/summary.txt
echo "stage3 released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
