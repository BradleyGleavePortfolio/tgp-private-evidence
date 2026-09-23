#!/usr/bin/env bash
# S2 real composition proof caller — EXEC-6c2a68ac, sole executor restore_s2_substrate_mue9eidh.
# Grant: tgp-private-evidence/execution/6c2a68ac/S2_REAL_COMPOSITION_GRANT.md (sha256 7d856374…8daf2); activation e8dcfc61…be7f.
# Transport: accepted detached setsid/nohup caller (tool call cannot block 2100+60 s). No supervisor, no extra timeout, no signals.
export CHECKPOINT_DISABLE=1
unset S2_RUNNER_STUBS
echo "caller_start_utc=$(date -u +%FT%TZ) pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') sid=$(ps -o sid= -p $$ | tr -d ' ') CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE} S2_RUNNER_STUBS=${S2_RUNNER_STUBS-unset} timeout=$(timeout --version | head -1)"
# ---- BEGIN GRANT BLOCK (verbatim) ----
export GIT_OPTIONAL_LOCKS=0
cd /home/user/workspace/execution/e8d546f9/s2-v61 && sha256sum -c --quiet SHA256SUMS.outer \
 && timeout --foreground -k 60 2100 bash run-composition-r57-v5.7-when-granted.sh; echo "runner=$?"
# ---- END GRANT BLOCK ----
echo "caller_end_utc=$(date -u +%FT%TZ) GIT_OPTIONAL_LOCKS=${GIT_OPTIONAL_LOCKS}"
