#!/usr/bin/env bash
# S3 composed proof caller — EXEC-6c2a68ac REACTIVATION_02. Executes the granted block exactly once (lines between the BLOCK markers are byte-identical to the grant).
# No timeout/enclosure/supervisor/signal beyond the block itself. Console captured raw by the detached transport (setsid -f nohup).
export GIT_OPTIONAL_LOCKS=0
echo "caller_start_utc=$(date -u +%FT%TZ) pid=$$ sid=$(ps -o sess= -p $$ | tr -d ' ') uid=$(id -u) GIT_OPTIONAL_LOCKS=$GIT_OPTIONAL_LOCKS S2_RUNNER_STUBS=${S2_RUNNER_STUBS-unset} CHECKPOINT_DISABLE_in_caller_env=${CHECKPOINT_DISABLE-unset}"
echo "runner_sha256=$(sha256sum /home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/candidates/run-composition-s3-v5.8-when-granted.sh | cut -c1-64) fixture_sha256=$(sha256sum /home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/candidates/infra/s3-fixture-be0b.sh | cut -c1-64)"
# ---- BLOCK START (byte-identical to S3_COMPOSED_PROOF_RUNTIME_GRANT.md) ----
cd /home/user/workspace && env -u S2_RUNNER_STUBS CHECKPOINT_DISABLE=1 timeout --foreground -k 60 2100 bash /home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/candidates/run-composition-s3-v5.8-when-granted.sh; echo "runner=$?"
# ---- BLOCK END ----
echo "caller_end_utc=$(date -u +%FT%TZ)"
echo CALLER_DONE
