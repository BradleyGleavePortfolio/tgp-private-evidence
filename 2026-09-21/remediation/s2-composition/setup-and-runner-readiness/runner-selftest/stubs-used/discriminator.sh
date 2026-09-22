#!/usr/bin/env bash
echo "stub discriminator db=$1 holder=$S1_R4_LOCK_HOLDER fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed)"; [ "${STUB_DISC_RC:-0}" = 0 ] && echo "44 passed" || echo "FAIL stub"; exit ${STUB_DISC_RC:-0}
