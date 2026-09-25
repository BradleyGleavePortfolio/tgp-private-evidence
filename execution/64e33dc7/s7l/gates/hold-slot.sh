#!/usr/bin/env bash
exec 9>>/home/user/workspace/execution/test-validation.lock
if flock -n 9; then echo "ACQUIRED pid=$$ $(date -u +%FT%TZ)"; while [ -e /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/gates/.hold ]; do sleep 1; done; echo "RELEASED pid=$$ $(date -u +%FT%TZ)"; else echo "BUSY $(date -u +%FT%TZ)"; exit 75; fi
