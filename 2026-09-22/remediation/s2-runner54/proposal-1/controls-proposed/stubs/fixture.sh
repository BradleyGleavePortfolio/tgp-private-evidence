#!/usr/bin/env bash
# stub fixture (STUB — NOT EVIDENCE): reports fd-9 inheritance for init; start may spawn a fake daemon; stop rc configurable
case $1 in
  init) echo "stub init fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed) caller=$PPID"; exit ${STUB_INIT_RC:-0};;
  start) echo "stub started"; exit ${STUB_START_RC:-0};;
  status) echo "stub status";;
  stop) echo "stub stop rc=${STUB_STOP_RC:-0} hang=${STUB_STOP_HANG:-0}s $(date -u +%FT%TZ)"; [ "${STUB_STOP_HANG:-0}" -gt 0 ] && sleep "$STUB_STOP_HANG"; exit ${STUB_STOP_RC:-0};;   # r54: hanging-stop counterexample
esac
