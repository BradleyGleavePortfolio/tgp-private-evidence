#!/usr/bin/env bash
# Static identity check (no runtime of the consumers): the OWN-BLOCK embedded in each S6 consumer is byte-identical to own-block-v101.sh (4aebf96f…).
set -u; cd "$(dirname "$0")" || exit 2
want=4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5; rc=0
[ "$(sha256sum inputs/own-block-v101.sh | cut -c1-64)" = "$want" ] || { echo "FAIL inputs/own-block-v101.sh hash != $want"; rc=1; }
for f in run-c5-setup-npm-ci.v101.sh run-c6-hazard-v5-conly.v101.sh; do
  if diff -q <(sed -n '/^# >>> OWN-BLOCK v10.1/,/^# <<< OWN-BLOCK v10.1/p' "$f") inputs/own-block-v101.sh >/dev/null; then echo "OK   $f embeds own-block-v101.sh byte-identically"; else echo "FAIL $f embedded block differs"; rc=1; fi
  [ "$(grep -c '^# >>> OWN-BLOCK v10.1' "$f")" = 1 ] && [ "$(grep -c '^# <<< OWN-BLOCK v10.1' "$f")" = 1 ] || { echo "FAIL $f marker count"; rc=1; }
done; exit $rc
