#!/usr/bin/env bash
# v5 binding fill: sealed template (sha 25eb6837…) -> five placeholder substitutions (HEAD/TREE new; SPEC/BOOTSTRAP/FIXTURE
# unchanged) PLUS exactly ONE disclosed mechanical line: RT= (receipt/old-root root) moved from runtime/ to runtime-v5/ so
# the first proof's run/, old-root/ and PINS stay byte-identical and the template's own once-only refusals (SENT exists,
# old-root exists) do not fire. Nothing else changes (D=, BDIR, PORT, DBNAME, bounds, stages). Preview mode writes under
# $A/binding/preview/ when PREVIEW=1. Usage: fill-v5-binding.sh <head> <tree>
set -u
A=/home/user/workspace/execution/cf8ff737/b-drain/v5; CAN=/home/user/workspace/execution/95633079/s7-b-drain
H=$1; T=$2; SRC=$CAN/fixture-proposal-v3/binding/b-pg-proof.sh
if [ "${PREVIEW:-0}" = 1 ]; then OUT=$A/binding/preview; else OUT=$CAN/runtime-v5/binding; fi
mkdir -p "$OUT"; DST=$OUT/b-pg-proof.sh
[ "$(sha256sum "$SRC" | cut -c1-64)" = 25eb683770192de5037143e3d042106890578e9ee0f013a0f90d411174e21c3c ] || { echo "template sha mismatch"; exit 77; }
[ "$(sha256sum "$CAN/fixture-proposal-v3/binding/b-fixture.sh" | cut -c1-64)" = 4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9 ] || { echo "fixture sha mismatch"; exit 77; }
SUB=$OUT/b-pg-proof.sh.substitution-only
sed -e "s/__V3_COMMIT__/$H/" -e "s/__V3_TREE__/$T/" -e "s/__V3_SPEC_BLOB__/9b31fd1813d25a1624ab04666e0b1be4743277ab/" -e "s/__V3_BOOTSTRAP_BLOB__/b4503eef525baa531eedb148f47828db3a4ade6f/" -e "s/__B_FIXTURE_SHA256__/4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9/" "$SRC" > "$SUB"
diff -u "$SRC" "$SUB" > "$OUT/b-pg-proof.sh.substitution-only.diff"; [ "$(grep -c '^[-+][^-+]' "$OUT/b-pg-proof.sh.substitution-only.diff")" = 10 ] || { echo "substitution diff shape != 10"; exit 77; }
grep -qE '__V3_|__B_FIXTURE' "$SUB" && { echo "placeholder left"; exit 77; }
sed -e 's|^RT=/home/user/workspace/execution/95633079/s7-b-drain/runtime          # ALL runtime artefacts of the B lane live here$|RT=/home/user/workspace/execution/95633079/s7-b-drain/runtime-v5       # v5 proof: separate receipt/old-root root (first proof runtime/ preserved)|' "$SUB" > "$DST"
diff -u "$SUB" "$DST" > "$OUT/b-pg-proof.sh.mechanical-RT-only.diff"; [ "$(grep -c '^[-+][^-+]' "$OUT/b-pg-proof.sh.mechanical-RT-only.diff")" = 2 ] || { echo "mechanical diff shape != 2 (RT line not matched)"; exit 77; }
grep -q '^RT=/home/user/workspace/execution/95633079/s7-b-drain/runtime-v5 ' "$DST" || { echo "RT not rewritten"; exit 77; }
bash -n "$DST" || exit 77
{ echo "template_sha=$(sha256sum "$SRC" | cut -c1-64)"; echo "substitution_only_sha=$(sha256sum "$SUB" | cut -c1-64)"; echo "filled_v5_sha=$(sha256sum "$DST" | cut -c1-64)"; echo "HEAD=$H TREE=$T SPEC=9b31fd1813d25a1624ab04666e0b1be4743277ab BOOTSTRAP=b4503eef525baa531eedb148f47828db3a4ade6f FIXTURE=4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9"; grep -n '^EXPECT_\|^D=\|^RT=\|BDIR=\|^PORT=' "$DST"; } > "$OUT/PINS.txt"
echo "filled $DST"; cat "$OUT/PINS.txt"
