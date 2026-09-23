# OP88-S5-SETUP-EXCLUSION — independent nonbuilder review B (T4, setup-exclusion only)

Reviewer: B (passive, read-only; did not implement; did not read review A, current-state or takeover material; frozen V10 primitive read for interfaces only).
Date: 2026-09-23T00:56Z. Nothing executed: no `bash -n`, no probes, no processes, no locks, no network, no install, no candidate edits. Text comparisons only (`sha256sum -c`, `diff`, `sed`, `cmp`).

## 1. Exact input (frozen)

Packet `/home/user/workspace/tgp-private-evidence/2026-09-22/op88/remediation/s5-setup-exclusion`, `SHA256SUMS.s5-setup-exclusion` sha256 `0a69011150799ecdb31f46452ff92cede7075190906b851e39d6b5ebcb0758a7` (matches task), 9 files, all `OK`. Full list in `INPUT_MANIFEST.txt`.

Independent read-only confirmations of the builder's identity claims:
- `diff -u inputs/run-s5-setup-npm-ci.v10.sh run-s5-setup-npm-ci.v10x.sh` body is byte-identical to the shipped `setup-v10-to-v10x.diff` body (+11/−1: header comment + inherited-lease branch at v10x lines 188–193). Claim "everything else is V10 bytes" holds.
- OWN-BLOCK v10 (`# >>> OWN-BLOCK v10` … `# <<< OWN-BLOCK v10`, 93 lines) extracted from `launch-s5-setup-exclusion.v1.sh` (lines 25–117) and from `run-s5-setup-npm-ci.v10x.sh` is byte-identical to `inputs/own-block-v10.sh` (whole-file sha `df200b52…`). No new primitive applicability is introduced by this packet; the primitive is reused, not changed.
- Canonical paths agree across launcher (line 17) and runner (lines 46, 48): `LOCK=/home/user/workspace/execution/test-validation.lock`, `EX=/home/user/workspace/execution/s5-r4`.
- Launcher pins `PIN_RUNNER=3a7b57d1…` (line 24) = manifest hash of `run-s5-setup-npm-ci.v10x.sh`; control pins `PIN_L=1773ac7d…` (ctl line 9) = manifest hash of the launcher.

Ruling basis (S5_V10_REVIEW_AND_SETUP_RULING.md): option (a) outer owned launcher; acceptance requires "no free exclusion with live or unknown ownership" and "checked recovery handoff or an observable retained SELF-HOLD"; reviewers must establish genuine applicability of any private subset. Rules basis: G06/G10 (T4, two independent auditors), G07 (fail closed; skipped/empty checks are not success), G09 (bind claims to real evidence), G11 (material findings block regardless of label).

## 2. Verdict summary

| Question | Determination |
|---|---|
| Bounded private control run (X1–X4, private lock/EX, fake children) | NOT grantable as written. X1–X3 are safe and bounded; X4 as written cannot complete (B-02) and leaves an unbounded orphan launcher holding the private lock with a 2 s heartbeat log. Grantable after a one-line harness correction, but even 6 PASS would not evidence the canonical A-04 correction (B-01, B-06). |
| Actual install/setup applicability (canonical launcher + v10x runner) | NOT grantable. The launcher's release census is scoped to the runner's session only; the real install runs in a *different* session created by the primitive's `setsid`, so the exact V10 A-04 outcome (lock freed with unresolved install survivors) is reproduced, now recorded as `cleanup=verified-empty` (B-01, High). |
| Record/status/exclusion retention | Documented in §4. Exclusion is retained exactly as long as the launcher process lives; every unexpected exit frees it with no RELEASE record (observer then correctly reports `HOLDER_GONE_NO_RELEASE`). One documented path frees the lock while logging "entering SELF-HOLD" (B-03). |

Severity rule used: High = requested policy (ruling acceptance / request text) not met on a concrete, statically traceable path; not an observed runtime.

## 3. Material findings (concrete, line-bound)

### B-01 (High) — Release census excludes the install session; A-04 is not corrected for the canonical runner
- Runner (V10 bytes, unchanged in v10x) launches the only real work with `setsid bash -c "$OWN_GATE" … npm ci … 9>&- &` (`run-s5-setup-npm-ci.v10x.sh` line 221). `setsid` creates a new session: every npm process has `sid == CUR_PID` (the npm gate pid), not the runner's session.
- Launcher sets `SESSION=$PID` (the gate/timeout pid of the runner, line 161) and releases when `own_group_current "$SESSION"` returns observed-empty (lines 172–174). `own_group_current`/`own_session_members`/`own_census` (block lines 78–104) enumerate only processes with `pgid`/`sid == $SESSION`. Processes in the npm session are structurally invisible to every launcher census, escalation (`own_reap_all`, line 151) and heartbeat (`census_state`, line 134).
- Launcher never reads the runner's own truth (`$EX/logs/setup-v1/setup.EXIT_RECORD`, `FINAL rc=90`, `EXCLUSION_UNPRESERVED`, `CLEANUP_FAILURES`) nor the runner's published child identity (`$EX/logs/setup-v1/attempts/*/IDENTITY`, `pid=<npm sid>`, runner line 225). grep confirms no reference to these in the launcher.
- npm child is started `9>&-` (runner line 221), so no npm survivor keeps the lock's open file description alive; the lock is free the moment the launcher exits.
- Exact V10 A-04 trace under this packet: runner reap fails → no marker → `HOLD_BOUND 60` → `EXCLUSION_UNPRESERVED` → `FINAL rc=90` → runner exits 90 → `timeout` (pid P) exits 90 → launcher `own_finish` → `RAW=observed 90` → `own_group_current P` = empty (only timeout/runner were in it) → `release "normal" 90` → `LEASE_RELEASE … cleanup=verified-empty final_rc=90` → exit → lock free while npm survivors run. Same consequence as V10 A-04, plus a false "verified-empty" claim.
- Second trigger with the same root cause: inner `timeout -k 30 1290` (no `--foreground`) signals the runner's process group at expiry; the runner's TERM trap (runner line 178) does `own_reap_all 20` + `quarantine` (up to `HOLD_BOUND 60` s) but is SIGKILLed after 30 s, mid-quarantine → runner gone, npm session possibly live → launcher census empty → release with `raw=observed 124/137`.
- Consequence: ruling acceptance "no free exclusion with live or unknown ownership" is not met for the actual install; the builder's justification "the concrete V10 A-04 defect only" is not achieved. Blocks canonical use. Not a primitive defect; it is a launcher scope defect (the launcher must include the runner's published child sid(s) and/or the runner's FINAL/EXCLUSION_UNPRESERVED truth in its release gate).

### B-02 (High for the control grant) — X4 handoff step cannot complete as written; guaranteed orphan private-lock holder
- Harness makes `$EXD/LEASE_RELEASE`, `$EXD/SELF_HOLD`, `$EXD/logs/setup-exclusion/SELF_HOLD` directories (ctl line 28) so `own_record` fails. `own_record` does `mv -f "$1.tmp.$$" "$1"` (block line 100); with `$1` an existing directory, GNU `mv` moves the tmp file INTO the directory (rc 0), then readback fails (rc 3). Publication correctly fails, but the directory is now non-empty (`LEASE_RELEASE/LEASE_RELEASE.tmp.<pid>`).
- Launcher's first release attempt (after the ~30 s TERM→KILL escalation of the TERM-ignoring descendant, `exceptional` line 153 → `release` line 138) deposits that tmp file. Harness then runs `rmdir "$EXD/LEASE_RELEASE"` (ctl line 34) → fails (directory not empty); `set -uo pipefail` without `-e` continues. Correct-token `RECOVERY_ACCEPT` is written → launcher `handoff_accepted` → `release "handoff" 90` → `LEASE_RELEASE` still a directory → publication fails → `return 1` → loop continues every `HEARTBEAT` (2 s) forever (lines 143–147). The launcher never exits; `wait "$LPID"` (ctl line 34) blocks until the outer `timeout --foreground -k 10 200` ends the harness; the `setsid` launcher survives in its own session, holding `$OUT/X4/private.lock`, appending a heartbeat line every 2 s indefinitely.
- Result: `X4.handoff_release` is never evaluated; "expected 6 PASS (static expectation)" is unattainable as written (at most 5 PASS then UNRESOLVED); the ≤ ~150 s bound and "fake children only" are honoured but an unbounded orphan process is a real side effect on the shared sandbox until a human removes the directory (a valid handoff alone cannot free it). Fix is harness-only (`rm -rf` instead of `rmdir`); the launcher behaviour here is fail-closed and correct.

### B-03 (Medium) — Normal-path RELEASE publication failure frees the lock while logging "entering SELF-HOLD"
- `release()` (line 138) on `own_record` failure sets `PUBLICATION=release-record-failed`, logs `RELEASE_RECORD_FAILED: entering SELF-HOLD instead of releasing`, and returns 1. Callers `exceptional` (line 153) and the `self_hold` loop do fall through to SELF-HOLD. The normal path does not: `1) …; release "normal" "${RAW_RC:-70}" ;;` (line 174) is the last statement of the script; on failure the script ends, the process exits (status 1), fd 9 closes, the lock is freed, `LEASE_HOLDER` still says `state=RUNNING`, no `LEASE_RELEASE`, no `SELF_HOLD`. Request item 6 ("SELF-HOLD on … failed RELEASE/SELF_HOLD publication") is not met on this path and the log claim is false. Ownership was verified empty (of the runner's session) at that point, so the exposure is record/status truth plus B-01; observer correctly reports `HOLDER_GONE_NO_RELEASE`.
- Same fall-through at lines 156–157: `release "nothing-launched" 74` on failure returns and execution continues to launch the runner (Low probability: requires `$EX` writable for `LEASE_HOLDER` but `LEASE_RELEASE`/`OWN_ROOT` failing).

### B-06 (Medium, control adequacy) — Fake children do not model the primitive's session boundary
- `fake-runner.sh` leaves a same-session descendant (`( … ) 9>&- &`, no `setsid`) and never exits 90; X2/X3/X4 therefore exercise only the same-session census. No control models the canonical shape (runner-created `setsid` sub-session survivor + runner exit 90/124/137). A 6-PASS result would be evidence about the launcher's same-session logic only and must not be read as A-04 closure (G09). The builder disclosed census-error/foreign-number gaps but not this one.
- Vacuous assertions: `! pgrep -f "$EXD/DESC_READY"` (ctl line 24) and `pkill -KILL -f "$OUT/X4/DESC_READY"` (line 36) match nothing — the descendant `exec sleep 60` has cmdline `sleep 60`. The X2 check still carries via rc 90 + `GROUP_REAPED|KILL` + `lock_free`.

## 4. Record / status / exclusion retention (as designed, from the bytes)

- Exclusion: `flock -n` on fd 9 held by the launcher process only (line 123–124); inherited by the runner chain (gate → env → timeout → runner) which verifies and never re-acquires or unlocks (v10x lines 188–193; no `flock -u` anywhere; npm gets `9>&-`). Retained exactly as long as the launcher lives; freed on any launcher exit (planned `release`, B-03 fall-through, or any unexpected bash abort — there is no EXIT trap, so unexpected exits leave no record).
- `$EX/LEASE_HOLDER`: single latest-state record, replaced in place by `publish_state` at HELD → LAUNCHING → RUNNING → SELF-HOLD (each heartbeat) → `RELEASED(<how>)`; earlier `since=` values survive only in the append-only `$EX/logs/setup-exclusion/launcher.EXIT_RECORD`.
- `$EX/LEASE_RELEASE`: written once; carries `how`, `raw=observed <rc>|unobserved`, `cleanup`, `publication`, `recovery`, `session`, `final_rc`. Does NOT carry the runner's own FINAL/CLEANUP_FAILURES/EXCLUSION_UNPRESERVED truth (B-01).
- `$EX/SELF_HOLD` (fallback `$LOGS/SELF_HOLD`, last resort stderr): reason + census at entry; line 146 overwrites it with `retry token=… empty_at=…` if the primary later becomes writable, losing the entry reason in `$EX` (log retains it). Low.
- `$EX/RECOVERY_ACCEPT`: parent-written, exact `token`/`holder_pid`/`start_time` match required (line 136); mismatch ignored; file retained untouched.
- Attempts: `$EX/logs/setup-exclusion/attempts/attempt-*/{IDENTITY,ADOPT}` retained; `runner.out` retained.
- Observer: read-only, never opens lock, never signals; four states as requested; start-time match via `/proc/<pid>/stat` field 22 (safe while comm has no spaces — `bash`). Cannot detect B-01 (it reports the launcher's state, which is "released cleanly").

## 5. Non-findings (checked, no issue)
- Lease acquired once, holder published before any child (lines 123–127); publication failure → exit 74 nothing launched.
- Raw result via in-shell `own_finish` in the launching shell (line 171), separate fields in every record.
- Escalation never targets the holder (`own_group_signal` refuses `OWN_SELF_PGID`/`OWN_SELF_SID`, block line 86); one escalation then verify (line 151–153).
- Private mode refuses canonical paths (line 20); canonical mode enforces runner hash pin (line 24).
- v10x inherited branch fails closed on missing fd, token mismatch, or dead holder (exit 75); without `S5_LEASE_INHERITED` and with a stray inherited fd 9, `exec 9>` + `flock -n` fails busy → exit 75.

## 6. Smallest next proof

Zero-execution proof already sufficient for B-01: runner line 221 (`setsid … npm ci … 9>&-`) versus launcher lines 161/172–174 and block lines 78–84 (census keyed on `$SESSION` only). No run is needed to decide non-grantability of canonical use.

If the parent wants an executable demonstration before the builder's fix, the smallest is one private control (≈15 s, fake child only, private lock/EX, no network/install), requested but not run by B:
- X5 `subsession-90`: fake runner does `( setsid sleep 60 ) 9>&- &`, waits until the child is visible, then `exit 90`.
- Expected against the current launcher (demonstrating B-01): `LEASE_RELEASE` contains `how=normal raw=observed 90 cleanup=verified-empty final_rc=90`, private lock free, `pgrep -x sleep` in that sid still live.
- Expected after a correct launcher fix: `state=SELF-HOLD` or `how=…-then-empty` only after that sid is observed empty.

Before any control grant: change ctl line 34 `rmdir` → `rm -rf` (B-02). Before canonical use: launcher release gate must include the runner-published child sid(s) (`$EX/logs/setup-v1/attempts/*/IDENTITY` `pid=`) and treat runner `FINAL rc=90`/`EXCLUSION_UNPRESERVED` as unresolved ownership (B-01); normal-path `release` failure must fall through to `self_hold` (B-03). Any such launcher change is a new hash and a new dual exact review; the primitive bytes need not change.
