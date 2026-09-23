#!/usr/bin/env bash
# Detached caller phase 2: literal invocation of 07 (continuation copy), 08 (continuation copy), 09 (original), 10 (original) in order; first nonzero stops. No retry.
O=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-continuation; W=/home/user/workspace/worktrees/s5-r4; P=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-prep
unset PRISMA_ENGINES_MIRROR LEFTHOOK LEFTHOOK_EXCLUDE LEFTHOOK_VERBOSE LEFTHOOK_QUIET S5_LEASE_INHERITED; for v in $(env | grep -oE '^S5X_[A-Za-z0-9_]+'); do unset "$v"; done
export GIT_OPTIONAL_LOCKS=0
R=$O/caller-phase2.receipt
echo "CALLER2_START pid=$$ sid=$(ps -o sid= -p $$ | tr -d ' ') utc=$(date -u +%FT%TZ) frozen=$(sha256sum $O/steps/FROZEN_BEFORE_07.sha256 | cut -c1-64)" > $R
run() { NN=$1; label=$2; T=$3; cmd=$4
  echo "STEP $NN $label start=$(date -u +%FT%TZ) cmd: bash $O/steps/step.sh $NN $label $T 1 $W $cmd" >> $R
  bash $O/steps/step.sh "$NN" "$label" "$T" 1 "$W" "$cmd"; rc=$?
  echo "STEP $NN $label raw_step_status=$rc end=$(date -u +%FT%TZ)" >> $R
  [ "$rc" -eq 0 ] || { echo "STOP at step $NN ($label) status=$rc utc=$(date -u +%FT%TZ)" >> $R; echo "CALLER2_END final=$rc utc=$(date -u +%FT%TZ)" >> $R; exit "$rc"; }
}
run 07 identity-and-hooked-commit 1200 $O/steps/07-identity-and-hooked-commit.cmd
run 08 post-commit-identity 30 $O/steps/08-post-commit-identity.cmd
run 09 bundle 60 $P/steps/09-bundle.cmd
run 10 check-r75-range 60 $P/steps/10-check-r75-range.cmd
echo "CALLER2_END final=0 utc=$(date -u +%FT%TZ)" >> $R
