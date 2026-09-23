#!/usr/bin/env bash
# Static identity check (no execution of candidates): the OWN-BLOCK v10.1 embedded in launcher v3.2 and runner v101y must be byte-identical to inputs/own-block-v101.sh.
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 2; rc=0
for f in launch-s5-setup-exclusion.v32.sh run-s5-setup-npm-ci.v101y.sh; do
  if diff -q <(sed -n '/^# >>> OWN-BLOCK v10.1/,/^# <<< OWN-BLOCK v10.1/p' "$f") inputs/own-block-v101.sh >/dev/null; then echo "IDENTICAL $f"; else echo "DIFFERS $f"; rc=1; fi; done
echo "block sha256 $(sha256sum inputs/own-block-v101.sh | cut -c1-64)"; exit $rc
