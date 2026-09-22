#!/usr/bin/env bash
# Static check (read-only): the OWN-BLOCK v9 embedded in both successors is byte-identical to own-block-v9.sh.
set -u; cd "$(dirname "${BASH_SOURCE[0]}")"; rc=0
for f in controls-v9-t0/ctl-t0-only.v9.sh controls-v9-t0/run-s5-setup-npm-ci.v9.sh; do
  if diff <(sed -n '/^# >>> OWN-BLOCK v9/,/^# <<< OWN-BLOCK v9/p' "$f") own-block-v9.sh >/dev/null; then echo "IDENTICAL $f"; else echo "DIFFERS $f"; rc=1; fi; done
exit $rc
