#!/usr/bin/env bash
echo "stub harness db=$1 fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed)"; echo "== 40 passed, 0 failed (stub)"; exit ${STUB_HARNESS_RC:-0}
