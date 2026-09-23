# Smallest fixture-only repair for X6 — PROPOSED, NOT EXECUTED (awaits explicit parent recovery grant)

Facts it rests on (`RETAINED_OWNER_FACTS.txt`, 02:09:56Z): holder pid 26214 / starttime 519891 / sid 26214 / fd 9 → `X6/private.lock`, all matching `LEASE_HOLDER`; outer session = launcher + transient `sleep 2` heartbeat child; inner runner sid 26278 EMPTY (0 members, `/proc/26278` gone; launcher's own census `[26278:empty]`); the ONLY obstacle is `X6/LEASE_RELEASE` being a **directory** (driver fixture, installed by design at X6 L64) containing exactly one file, the launcher's own deposit `LEASE_RELEASE.tmp.26214` (302 B, re-written every 2 s heartbeat with a fresh `released_at=`). `SELF_HOLD` is a regular file (published OK); `logs/setup-exclusion/SELF_HOLD` does not exist. Canonical lock untouched (0 links).

## Exact payload (mirrors the frozen driver's own `repair_marker_dir` at `ctl-exclusion.v2.sh` L35–40, with LPID=26214 and the one directory X6 still has; nothing else)

```sh
X=/home/user/workspace/execution/e8d546f9/s5-setup-v2-control-result/data/20260923T020459Z/X6
d=$X/LEASE_RELEASE; t=$d/LEASE_RELEASE.tmp.26214; k=0
[ -d "$d" ] || { echo "REPAIR_SKIP not-a-directory $d"; exit 0; }
while :; do
  [ -e "$t" ] && { rm -f "$t" || { echo "REPAIR_FAILED rm $t"; exit 1; }; }
  rmdir "$d" 2>/dev/null && { echo "REPAIRED $d (removed only LEASE_RELEASE.tmp.26214)"; exit 0; }
  k=$((k+1)); [ $k -ge 5 ] && { echo "REPAIR_FAILED rmdir $d contents=[$(ls -A "$d" 2>/dev/null | tr '\n' ',')] (unexpected contents: not deleted)"; exit 1; }
  sleep 0.3
done
```

Scope: removes exactly one known file (`<name>.tmp.<launcher pid>`) and then the empty directory; no recursion, no other path, no signal, no lock open, no handoff. If the directory ever contains anything other than that one file, it stops without deleting.

## Expected launcher behaviour after repair (from the X4 precedent in this same run and launcher L185/L193)
Within ≤ 2 s (next heartbeat) `own_record` publishes `X6/LEASE_RELEASE` as a regular file (`how=self-hold-then-empty raw=observed 0 cleanup=verified-empty publication=release-record-failed recovery=none …`), the launcher logs `LEASE_RELEASED`, closes fd 9 and exits (X4 exited 90 on this path). Verification after that is read-only: `kill -0 26214` false, `LEASE_HOLDER` shows `state=RELEASED`, `flock`-free is NOT to be probed by the executor (the driver's `lock_free` probe was the stopped driver's step) — report fd-link census (0) instead.

## What this does NOT do
- Does not re-run or resume the stopped driver: checks 10 (`X6.release_after_exact_repair`) and 11 (X7) remain **NOT RUN**; `SUMMARY pass=8 fail=1` stands as the result of this execution regardless of recovery outcome.
- Does not touch the private lock, the holder, the canonical lock, `execution/s5-r4`, or any frozen packet/result.
- Executor will not run this until a parent message explicitly grants recovery quoting pid 26214 / starttime 519891 / token `20260923T020634Z-26214-18852`.
