#!/usr/bin/env bash
# Static check (read-only): the OWN-BLOCK v10 embedded in both successors is byte-identical to own-block-v10.sh.
set -u; cd "$(dirname "${BASH_SOURCE[0]}")"; rc=0
for f in controls-v10-t0/ctl-t0-only.v10.sh controls-v10-t0/run-s5-setup-npm-ci.v10.sh; do
  if diff <(sed -n '/^# >>> OWN-BLOCK v10/,/^# <<< OWN-BLOCK v10/p' "$f") own-block-v10.sh >/dev/null; then echo "IDENTICAL $f"; else echo "DIFFERS $f"; rc=1; fi; done
exit $rc
