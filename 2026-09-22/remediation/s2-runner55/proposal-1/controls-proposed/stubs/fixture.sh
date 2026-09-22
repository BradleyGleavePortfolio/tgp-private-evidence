#!/usr/bin/env bash
# stub fixture (STUB — NOT EVIDENCE): reports fd-9 inheritance for init; start may spawn a fake daemon; stop rc configurable
case $1 in
  init) echo "stub init fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed) caller=$PPID"; exit ${STUB_INIT_RC:-0};;
  start) echo "stub started"; exit ${STUB_START_RC:-0};;
  status) echo "stub status pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ')";;
  stop) echo "stub stop rc=${STUB_STOP_RC:-0} hang=${STUB_STOP_HANG:-0}s pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset} $(date -u +%FT%TZ)"
        if [ "${STUB_STOP_HANG:-0}" -gt 0 ]; then sleep "$STUB_STOP_HANG" & echo "spawned pid=$! (hanging stop child, same group, cmd 'sleep')"; wait $!; fi; exit ${STUB_STOP_RC:-0};;   # r55: hanging child identity is published (R54-A-02)
esac
