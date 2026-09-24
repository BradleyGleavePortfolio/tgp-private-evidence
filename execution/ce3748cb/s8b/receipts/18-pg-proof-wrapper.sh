#!/usr/bin/env bash
# S8-B single PG proof wrapper (receipt 18). Self-check the sealed binding, wait politely for the canonical lock,
# launch the bound runner exactly once, record the outer rc. No retry.
B=/home/user/workspace/execution/ce3748cb/s8b/binding
LOCK=/home/user/workspace/execution/test-validation.lock
echo "WRAPPER_START $(date -u +%FT%TZ) pid=$$"
( cd "$B" && sha256sum -c BINDING.sha256 ) | grep -E '^(s8b-pg-proof.sh|s8b-fixture.sh|derive-s8b-pg-proof.py):'
( cd "$B" && sha256sum -c --quiet BINDING.sha256 ) || { echo BINDING_MISMATCH; exit 90; }
[ "$(sha256sum "$B/s8b-pg-proof.sh" | cut -c1-64)" = be7981ebea205195e0aeecf4438a32f390be8167a29b8462bf21c5054f8ab3b9 ] || { echo RUNNER_SHA_MISMATCH; exit 90; }
[ ! -e /home/user/pg17/clusters/s8-b ] || { echo "STOP: clusters/s8-b exists"; exit 91; }
[ ! -e /home/user/workspace/execution/ce3748cb/s8b/runtime ] || { echo "STOP: s8b/runtime exists"; exit 91; }
polls=0
until flock -n "$LOCK" true; do polls=$((polls+1)); [ $polls -le 240 ] || { echo "LOCK_BUSY_AFTER_240_POLLS $(date -u +%FT%TZ); runner NOT launched"; exit 92; }; sleep 5; done
echo "LOCK_FREE_AFTER_POLLS=$polls $(date -u +%FT%TZ)"
echo "LAUNCH $(date -u +%FT%TZ): timeout -k 30 3600 bash execution/ce3748cb/s8b/binding/s8b-pg-proof.sh"
timeout -k 30 3600 bash "$B/s8b-pg-proof.sh"; rc=$?
echo "OUTER_RC=$rc $(date -u +%FT%TZ)"
echo "WRAPPER_END pgrep_postgres=$(pgrep -cx postgres || true) listeners_55511=$(ss -ltn 2>/dev/null | grep -c ':55511 ' || true)"
