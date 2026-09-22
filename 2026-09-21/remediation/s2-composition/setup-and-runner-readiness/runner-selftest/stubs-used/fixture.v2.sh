#!/usr/bin/env bash
case $1 in
  init) if [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "$STUB_LOCK" ]; then echo "lock: $STUB_LOCK inherited fd9 from caller pid=$PPID"; else echo "lock: NOT inherited"; fi; exit ${STUB_INIT_RC:-0};;
  start) echo "stub started"; [ -n "${STUB_DAEMON:-}" ] && { setsid -f bash -c 'exec -a /home/user/pg17/dist/bin/postgres-STUB sleep 20' </dev/null >/dev/null 2>&1; }; exit ${STUB_START_RC:-0};;
  status) echo "stub status";;
  stop) echo "stub stop rc=${STUB_STOP_RC:-0}"; exit ${STUB_STOP_RC:-0};;
esac
