#!/usr/bin/env bash
# Static check (read-only): the OWN-BLOCK v10.1 embedded in both V10.1 consumers is byte-identical to own-block-v101.sh.
set -u; cd "$(dirname "${BASH_SOURCE[0]}")"; rc=0
for f in controls-v101-t0/ctl-t0-only.v101.sh controls-v101-t0/run-s5-setup-npm-ci.v101.sh; do
  if diff <(sed -n '/^# >>> OWN-BLOCK v10\.1/,/^# <<< OWN-BLOCK v10\.1/p' "$f") own-block-v101.sh >/dev/null; then echo "IDENTICAL $f"; else echo "DIFFERS $f"; rc=1; fi; done
exit $rc
