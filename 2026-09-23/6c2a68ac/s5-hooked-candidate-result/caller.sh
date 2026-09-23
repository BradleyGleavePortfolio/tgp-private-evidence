#!/usr/bin/env bash
# Detached caller: literal invocation of frozen steps 00-10 (prep manifest e9f4a5d5.../21) in order; first nonzero stops. No retries.
P=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-prep
W=/home/user/workspace/worktrees/s5-r4
O=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-result
unset PRISMA_ENGINES_MIRROR LEFTHOOK LEFTHOOK_EXCLUDE LEFTHOOK_VERBOSE LEFTHOOK_QUIET S5_LEASE_INHERITED; for v in $(env | grep -oE '^S5X_[A-Za-z0-9_]+'); do unset "$v"; done
export GIT_OPTIONAL_LOCKS=0
echo "CALLER_START pid=$$ sid=$(ps -o sid= -p $$ | tr -d ' ') utc=$(date -u +%FT%TZ) prep_manifest=$(sha256sum $P/MANIFEST.sha256 | cut -c1-64)" > $O/caller.receipt
run() { NN=$1; label=$2; T=$3; post=${4:-}
  postarg=""; [ -n "$post" ] && postarg="$P/steps/$NN-$label.post"
  echo "STEP $NN $label start=$(date -u +%FT%TZ) cmd: bash $P/steps/step.sh $NN $label $T 1 $W $P/steps/$NN-$label.cmd $postarg" >> $O/caller.receipt
  bash "$P/steps/step.sh" "$NN" "$label" "$T" 1 "$W" "$P/steps/$NN-$label.cmd" $postarg; rc=$?
  echo "STEP $NN $label raw_step_status=$rc end=$(date -u +%FT%TZ)" >> $O/caller.receipt
  [ "$rc" -eq 0 ] || { echo "STOP at step $NN ($label) status=$rc utc=$(date -u +%FT%TZ)" >> $O/caller.receipt; echo "CALLER_END final=$rc utc=$(date -u +%FT%TZ)" >> $O/caller.receipt; exit "$rc"; }
}
run 00 pins 60
run 01 tool-reverify 30 post
run 02 prisma-generate-guarded 300 post
run 03 lefthook-install 60 post
run 04 link-formatter 10 post
run 05 stage-two-files 10 post
run 06 hook-resolution-offline-proof 60
run 07 identity-and-hooked-commit 1200
run 08 post-commit-identity 30
run 09 bundle 60
run 10 check-r75-range 60
echo "CALLER_END final=0 utc=$(date -u +%FT%TZ)" >> $O/caller.receipt
