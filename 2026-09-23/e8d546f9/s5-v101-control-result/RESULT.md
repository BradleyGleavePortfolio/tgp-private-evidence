# S5-V101-CONTROL — executor result (T4; executor only, not source writer or auditor)

Grant: `tgp-private-evidence/execution/e8d546f9/S5_V101_CONTROL_GRANT.md` (sha256 222a8d453d696bd955198f26717de740acd1cae91fae8442e85aac1d8f22ddad; parent-published, activated by mail 2026-09-23). Request: `execution/e8d546f9/s5-v101/CONTROL_REQUEST_V101.md`. Reviews A/B manifests verified: `audits/s5-v101-a/SHA256SUMS` a05b466f91c314b5fbeef81e91ba49a268a8f8d07d5d0638e9797123531ba3ca, `audits/s5-v101-b/SHA256SUMS` f7965a774998fde888adb8f8fd1b42c5393bb62eba440584609e1752aacc3832 (both entries verified). Sole writes: this directory. Executed exactly once. No retry, no code change, no install/network/T0/setup/DB/S6, no lock acquisition, no ad hoc process action.

## Outcome: PASS (per the grant's criteria) — raw final rc 0
| Criterion | Observed |
|---|---|
| raw final status | **0** (`caller-rc.txt`; `ctl-own-launch.v101 rc=0` line in `caller-stdout-stderr.txt`) |
| checks | **25 PASS / 0 FAIL** (`ALL_CASES_DONE pass=25 fail=0`): C0.precondition C0.budget C0.finish_subshell_named CW.pins CW.t0_traps_before_spawn CW.setup_traps_before_spawn CW.no_subshell_finish CW.identity_before_adopt CW.stamp_after_start C1.adopted_and_ran C2.observed_exit C3.no_workload C4.stale_refused C5.publication_failure C5b.identity_pub_failure C5c.post_release_cancel C6.caller_decoy C7.acknowledged_decoy C8.pending_fork_reaped C9.registered_reaped C10.no_stale_signal C11.descendants C12.kill_path C13.retired_refused C14.budget_term  |
| SUMMARY | `pass=25 fail=0 primary_rc=0 enclosure_reap_rc=0 unresolved=0 publication_failures=0 aggregate_elapsed=23s` |
| exit_record | `exit_record=ok` on all 16 launched cases; 16 enclosure attempts each with IDENTITY, ADOPT, EXIT |
| per-case raw evidence | 16 case dirs with `sup.out`, `sup.stdout`, `sup.pid_pgid`, `child.pid`, `child.stdout`; `trap.out` in C8/C9/C10; attempts/WORKLOAD_RAN where the workload was released (C1 C2 C5c C7 C10 C11 C12 C13 C14); `post/START` where applicable; C5b's blocked IDENTITY (directory with a leftover `.tmp`) preserved as produced |
| raw child statuses (never rewritten) | `fixture-exit primary_rc=0 cleanup_rc=0` ×7, `primary_rc=2 cleanup_rc=0` ×6; `raw=observed` 0 ×2, 75 ×2, 137 ×2, 143 ×9 (in `sup.out`/`trap.out`); EXIT records: observed 0 ×7, 2 ×6, 143 ×3, all `group_rc=1` |

## Exact command, start, end
Caller `caller.sh` (retained; sha in manifest): verified `cd` to `/home/user/workspace/execution/e8d546f9/s5-v101`, manifest `sha256sum -c --quiet SHA256SUMS.s5-v101` OK and hash 45accac9… asserted, EUID≠0, fresh empty `data/`; then the granted block verbatim:
```
S5_V10_OUT=/home/user/workspace/execution/e8d546f9/s5-v101-control-result/data S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-v101-t0/ctl-own-launch.v101.sh
rc=$?
echo "ctl-own-launch.v101 rc=$rc"
exit "$rc"
```
Executor additions: START/END timestamp lines and `caller-rc.txt` (capture only; no relabeling, no pipe on the driver, errexit off, monitor off — both printed on the START line). Launched detached (`setsid -f nohup bash caller.sh > caller-stdout-stderr.txt 2>&1 < /dev/null`) because this executor's tool environment kills non-detached background processes at each tool-call boundary (checked beforehand with a plain `sleep`; not with any target process). The driver itself ran in the caller's session/group (`timeout --foreground`), as in the request.
- LAUNCH 2026-09-23T01:29:32.475Z; START 01:29:32.489Z (caller pid 32281, pgid=sid=32281); driver start line 01:29:32Z; END 01:29:55.440Z rc=0. Wall ≈ 23 s, inside the 190 s admission and 230+10 s allowance; the allowance was never approached.
- Driver log `data/own-launch-20260923T012932Z.log` (61 lines) is line-identical to the timestamped lines of the captured stdout (`diff` empty); case dir `data/20260923T012932Z/`; whole `data/` tree retained (170 files) including the log one level above the timestamped case dir.

## Pre/post candidate and environment verification
- PRE: `SHA256SUMS.s5-v101` → 45accac93e91e7d46fe9a75c4460687fcb6d698336c57d61428b62f192cd5b89, 24/24 verified (also re-verified inside the caller before launch). POST: same hash, 24/24 verified; no file or directory under the packet newer than the launch stamp; no `control-results/` created in the packet (`S5_V10_OUT` honoured).
- Driver self-hash logged `control_sha256=a7b44cf806a0c746649207ac62394ebbc57d019e5eb5f4263ab844c6abba32da` = current `controls-v101-t0/ctl-own-launch.v101.sh`; pins own=4aebf96f…, sup=6b7088a8… accepted by the driver; CW.pins PASS for the T0/setup consumers (hashed/grepped only, never executed).
- Canonical lock path `/home/user/workspace/execution/test-validation.lock`: stat only, before and after: exists, size 0, mtime 2026-09-23 00:57:42.385 — unchanged, never opened.
- Environment stamp (driver line 1): monitor=off, bash 5.3.9(1), setsid util-linux 2.41.3, **timeout = uutils coreutils 0.8.0** (not GNU), EUID 2000 (`user`). Observation only; the grant lists "required tools present", which held.

## Process / ownership accounting (cleanup slot closure)
- Before launch: no pre-existing `sup-under-test`/`ctl-own-launch`/`own-gate`/`sleep` processes.
- Driver EXIT path: `ENCLOSURE_CENSUS RETIRED id=…` for all 16 enclosure ids (evidence only); `enclosure_reap_rc=0 unresolved=0`; no `FIXTURE_SURVIVOR`, `SIGNAL`, `AGGREGATE_BOUND_HIT`, `FIXTURE_OVERRAN` or `UNCONFIRMED` line.
- After exit (checked 01:30Z): zero caller/driver/timeout/fixture/gate/sleep processes; zero zombies system-wide; all 16 recorded fixture child pids absent from `/proc`. No process was signalled by the executor at any time.
- Slot: released with attributable clean accounting (this run only); nothing left running.

## Observations (not failures; reported, not repaired)
- 13 stderr lines `ctl-own-launch.v101.sh: line 54: …/<case>/trap.out: No such file or directory` — bash's redirection error for `tr … < "$REC/trap.out" 2>/dev/null` in the per-case log line when the case wrote no `trap.out` (all cases except C8/C9/C10). Cosmetic stderr only: it does not affect any check, the status, or the log file (the log line prints `trap.out=[]`). Left for the source owner/reviewers.
- The grant's PASS definition is met on every listed criterion; this proves only the reviewed synthetic-child diagnostic on this host (primitive/fixture/driver behaviour), not T0/setup/S6, install, DB, product or customer acceptance. No clearance inherited from or extended to old V10 B.

## Truth
Executed: the one granted invocation. Verified: pre/post manifests, review manifests, grant hash, process/lock accounting, evidence tree completeness. Not done: any re-run, any edit of packet/candidate/prior artifacts, any auditing judgement on the sources. My S2 V59 source lane stays frozen (4341ce30…), untouched by this assignment.
