#!/usr/bin/env bash
# PROPOSED, NOT EXECUTED under S2-SETUP-FIXTURE-PREP (2026-09-22). Fixture fd-9 guard controls F1–F4 for infra/s2-fixture-r53.sh,
# mirroring READINESS_FIX_01's four lockcheck cases for the 08987e4c fixture. `lockcheck` is the ONLY subcommand that honours
# S2_FIXTURE_LOCK, so these run on a TEMP lock: no PostgreSQL, no canonical lock, no network, no data dir. Expected total < 3 s.
# One-strike: stop at the first expectation miss. Nothing is left running (flock holders are foreground subshells that exit).
set -u
LANE=/home/user/workspace/execution/s2-setup-prep; FIX=$LANE/infra/s2-fixture-r53.sh
CTL=$LANE/controls-proposed/results/fixture-$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$CTL"; R=$CTL/FIXTURE_CONTROLS_RESULT.txt
T=$(mktemp -d); L=$T/private.lock; OTHER=$T/other.file
say(){ echo "$*" | tee -a "$R"; }
say "fixture controls start $(date -u +%FT%TZ) fixture_sha256=$(sha256sum "$FIX" | cut -c1-64) temp_lock=$L"
STRIKE=0
chk(){ [ "$1" = "$2" ] && say "  PASS: $3 (exit $1)" || { say "  FAIL: $3 (exit $1, expected $2)"; STRIKE=1; }; }

say "== F1 standalone lockcheck on a free temp lock — expect 'acquired here', exit 0"
out=$(S2_FIXTURE_LOCK=$L bash "$FIX" lockcheck 2>&1); rc=$?; say "  $out"; chk $rc 0 "F1 acquired standalone"; echo "$out" | grep -q "acquired here" || { say "  FAIL: mode text"; STRIKE=1; }
[ $STRIKE = 0 ] || { say "ONE-STRIKE STOP"; exit 1; }

say "== F2 caller holds fd 9 on the temp lock and passes it — expect 'inherited fd9 from caller', exit 0 (same lease)"
out=$( exec 9>"$L"; flock -n 9 || echo "driver could not take temp lock"; S2_FIXTURE_LOCK=$L bash "$FIX" lockcheck 2>&1 ); rc=$?; say "  $out"; chk $rc 0 "F2 inherited fd9"; echo "$out" | grep -q "inherited fd9" || { say "  FAIL: mode text"; STRIKE=1; }
[ $STRIKE = 0 ] || { say "ONE-STRIKE STOP"; exit 1; }

say "== F3 another holder owns the temp lock, fd 9 NOT passed — expect 'validation lock busy', exit 75"
out=$( exec 8>"$L"; flock -n 8 || echo "driver could not take temp lock"; S2_FIXTURE_LOCK=$L bash "$FIX" lockcheck 2>&1 9>&- ); rc=$?; say "  $out"; chk $rc 75 "F3 busy, not waiting"
[ $STRIKE = 0 ] || { say "ONE-STRIKE STOP"; exit 1; }

say "== F4 caller's fd 9 is open on a DIFFERENT file — expect NOT mistaken for the lock: 'acquired here', exit 0"
out=$( exec 9>"$OTHER"; S2_FIXTURE_LOCK=$L bash "$FIX" lockcheck 2>&1 ); rc=$?; say "  $out"; chk $rc 0 "F4 different fd9 target not mistaken"; echo "$out" | grep -q "acquired here" || { say "  FAIL: mode text"; STRIKE=1; }

say "== F5 (negative, no lock, no pg) 'url' prints the pinned loopback URL with PORT 54353 — expect exit 0 and 127.0.0.1:54353"
out=$(bash "$FIX" url 2>&1); rc=$?; say "  $out"; chk $rc 0 "F5 url"; echo "$out" | grep -q '@127.0.0.1:54353/postgres$' || { say "  FAIL: url shape"; STRIKE=1; }

say "end $(date -u +%FT%TZ) strike=$STRIKE; canonical lock file exists: $([ -e /home/user/workspace/execution/test-validation.lock ] && echo yes || echo no) (never touched); temp dir $T removed"
rm -rf "$T"; ( cd "$CTL" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS ); exit $STRIKE
