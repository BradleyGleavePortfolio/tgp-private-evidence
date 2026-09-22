#!/usr/bin/env bash
# stub fixture: mimics the real fixture's fd-9 inheritance report for init; start/stop/status trivial
case $1 in
  init) if [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "$STUB_LOCK" ]; then echo "lock: $STUB_LOCK inherited fd9 from caller pid=$PPID"; else echo "lock: NOT inherited (fd9=$(readlink /proc/$$/fd/9 2>/dev/null))"; fi; exit ${STUB_INIT_RC:-0};;
  start) echo "stub started"; exit ${STUB_START_RC:-0};;
  status) echo "stub status: running";;
  stop) echo "stub stopped";;
esac
