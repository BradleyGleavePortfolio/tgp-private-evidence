#!/usr/bin/env bash
# Static check (read-only): the OWN-BLOCK v8 embedded in both successors is byte-identical to own-block-v8.sh.
set -u; cd "$(dirname "${BASH_SOURCE[0]}")"; rc=0
for f in controls-v8-t0/ctl-t0-only.v8.sh controls-v8-t0/run-s5-setup-npm-ci.v8.sh; do
  if diff <(sed -n '/^# >>> OWN-BLOCK v8/,/^# <<< OWN-BLOCK v8/p' "$f") own-block-v8.sh >/dev/null; then echo "IDENTICAL $f"; else echo "DIFFERS $f"; rc=1; fi; done
exit $rc
