#!/usr/bin/env bash
echo "stub guard spec (STUB — NOT EVIDENCE) fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed)"; exit ${STUB_GUARD_RC:-0}
