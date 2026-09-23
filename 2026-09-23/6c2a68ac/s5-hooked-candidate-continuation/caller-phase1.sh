#!/usr/bin/env bash
# Detached caller phase 1: single literal invocation of frozen 06F (grant 2686f427). No retry.
O=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-continuation; W=/home/user/workspace/worktrees/s5-r4
unset PRISMA_ENGINES_MIRROR LEFTHOOK LEFTHOOK_EXCLUDE LEFTHOOK_VERBOSE LEFTHOOK_QUIET S5_LEASE_INHERITED; for v in $(env | grep -oE '^S5X_[A-Za-z0-9_]+'); do unset "$v"; done
export GIT_OPTIONAL_LOCKS=0
echo "CALLER1_START pid=$$ sid=$(ps -o sid= -p $$ | tr -d ' ') utc=$(date -u +%FT%TZ) step_sh=$(sha256sum $O/steps/step.sh | cut -c1-64) cmd=$(sha256sum $O/steps/06F-format-spec.cmd | cut -c1-64)" > $O/caller-phase1.receipt
echo "STEP 06F format-spec start=$(date -u +%FT%TZ) cmd: bash $O/steps/step.sh 06F format-spec 60 1 $W $O/steps/06F-format-spec.cmd" >> $O/caller-phase1.receipt
bash $O/steps/step.sh 06F format-spec 60 1 $W $O/steps/06F-format-spec.cmd; rc=$?
echo "STEP 06F format-spec raw_step_status=$rc end=$(date -u +%FT%TZ)" >> $O/caller-phase1.receipt
echo "CALLER1_END final=$rc utc=$(date -u +%FT%TZ)" >> $O/caller-phase1.receipt
