#!/usr/bin/env bash
# stub harness (STUB — NOT EVIDENCE). Modes: fast (default) | sleep <s> | escape <s>
echo "stub harness db=$1 pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed) mode=${STUB_HARNESS_MODE:-fast}"
case ${STUB_HARNESS_MODE:-fast} in
  sleep)  sleep "${STUB_HARNESS_SLEEP:-30}";;
  escape) setsid -f bash -c 'exec -a s2r53-stub-escapee sleep '"${STUB_HARNESS_SLEEP:-30}" </dev/null >/dev/null 2>&1; sleep 0.3; echo "escapee pid=$(pgrep -f '^s2r53-stub-escapee' | head -1)"; sleep "${STUB_HARNESS_SLEEP:-30}";;
esac
echo "== 0 passed, 0 failed (STUB — NOT EVIDENCE)"; exit ${STUB_HARNESS_RC:-0}
