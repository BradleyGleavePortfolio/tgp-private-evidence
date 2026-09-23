# S5 setup-exclusion V2 private fake diagnostic (fake11) — result: STOPPED at X6 (check 9 of 11), holder RETAINED (executor evidence, frozen snapshot; not clearance)

Executor `restore_upstream_proof_inputs_muddwjad`. Grant `S5_SETUP_V2_CONTROL_GRANT.md` sha256 `a30e1602…83b7` @ private `08b17cf77dbaf7fdca93ec09edd27759e1117f11`; parent conditional ACTIVATE after the S4 npm-log addendum seal (`699a554a…`). **One run only; no rerun, no follow-on, no signal, no kill, no canonical lock touch.**

## Preflight (`PREFLIGHT.txt`) — ALL_PASS 17/17
Packet `b96dc732…` 33/33; A `fa876aa6…` OK; B `8b1b53a7…` OK; launcher pin `b32cc20d…`; driver **v2** `62a7233f…` (v3/v31 present in the tree, NOT used); fake runner v2 `5c18e3b3…`; EUID 2000; 0 `S5X_*`, `S5_CTL_GRANT` unset; errexit/monitor off; fresh `data/` absent; canonical `execution/s5-r4` absent; S4 freezes intact.

## Invocation (`exact-command.sh` `ee49b886…`, byte-identical to the grant code block; `T1-activate-utc.txt`, `ctl.log`, `ctl.exit`, `ctl.pid`)
Accepted detached raw-status wrapper (`setsid -f bash -c`, pid 14098, sid 14098) running the grant block unchanged — `timeout --foreground -k 10 230 bash controls-exclusion/ctl-exclusion.v2.sh` with `S5X_OUT=…/s5-setup-v2-control-result/data S5_CTL_GRANT=granted-by-parent`. Launch 02:04:59Z, driver end 02:06:39Z (100 s of 230). **Raw status: driver `ctl-exclusion.v2 rc=1`; `ctl.exit` = 1** (driver exit, not a timeout; outer 230/10 never fired).

## Actual checks (driver `ctl.log`; first-failure stop)
| # | check | result | raw child facts (LEASE_RELEASE / EXIT_RECORD) |
|---|---|---|---|
| 1 | X1.normal_release | PASS | lpid 14131 exit 0; `how=normal raw=observed 0 cleanup=verified-empty publication=ok` |
| 2 | X2.descendant_escalated | PASS | lpid 14318 exit 90; descendant 14432 escalated once; `raw=observed 0 cleanup=escalated(rc=0)` |
| 3 | X3.inner_timeout | PASS | lpid 19249; `raw=observed 124`, `final_rc=124`, released |
| 4 | X4.self_hold_observable | PASS | lpid 19801 alive in SELF-HOLD with busy private lock, `SELF_HOLD PUBLICATION FAILED` |
| 5 | X4.hold_persists_no_handoff | PASS | heartbeats in SELF-HOLD, no handoff |
| 6 | X4.release_after_exact_repair | PASS | three `REPAIRED … (removed only <name>.tmp.19801)`; exit 90; `how=self-hold-then-empty raw=observed 0` |
| 7 | X5.inner_session_holds | PASS | lpid 25424; runner exit 90 EXCLUSION_UNPRESERVED; inner sid 25553 bound |
| 8 | X5.release_only_after_inner_empty | PASS | released 02:06:34Z after inner sid empty; `raw=observed 90` |
| 9 | **X6.normal_release_failure_holds** | **FAIL** → `STOP_ON_FIRST_FAILURE` | see below |
| 10–11 | X6.release_after_exact_repair, X7.term_during_running | **NOT RUN** (stop) | — |
`SUMMARY pass=8 fail=1`; **`UNRESOLVED launcher pid=26214 … still holding`** line present. Expected `pass=11 fail=0` **not** met.

## X6 — what was observed (`STOP_STATE.txt`; read-only, X6 records only)
Launcher 26214 (scenario `normal-slow`): `LEASE_HELD` 02:06:34Z; runner 26278 raw 0 at 02:06:39Z; session census empty; `LEASE_RELEASE` was a directory obstacle (installed by the driver as designed) → `RELEASE_RECORD_FAILED: holding (SELF-HOLD) instead of releasing`; `SELF_HOLD` published (`reason=[release publication failed (normal; session empty)] raw=observed 0 cleanup=verified-empty publication=release-record-failed session=26278 inner=[none] census=[26278:empty]`); then heartbeats every 2 s with `state=SELF-HOLD`.
The driver's check ran at 02:06:39Z, the same second as the first `RELEASE_RECORD_FAILED` line it waited for, and requires simultaneously: launcher alive ∧ private lock busy ∧ `LEASE_HOLDER` contains `state=SELF-HOLD` ∧ `SELF_HOLD` contains the reason. Launcher sequencing in its own records: `RELEASE_RECORD_FAILED` (launcher L185) → `SELF_HOLD published` → first `HEARTBEAT` line → `publish_state SELF-HOLD` (L193, updates `LEASE_HOLDER`). At 02:07:07Z `LEASE_HOLDER` shows `state=SELF-HOLD since=02:07:05Z` (rewritten every heartbeat) and `SELF_HOLD` has the required reason — i.e. the behaviour the check describes is present after the fact, while the check's conjunction evaluated false at its instant. **This is reported as observed sequencing, not diagnosed, not repaired, not retried.** Which sub-condition was false at 02:06:39Z is not recorded by the driver (it logs only the conjunction's result).

## Retained holder — identity facts (no signal sent; parent boundary)
`pid=26214` `starttime=519891` `sid=26214` `pgid=26214` `ppid=1` cmdline `bash /home/user/workspace/execution/e8d546f9/s5-setup-exclusion-v2/launch-s5-setup-exclusion.v2.sh`; **fd 9 → `…/data/20260923T020459Z/X6/private.lock`** (PRIVATE lock, not canonical); token `20260923T020634Z-26214-18852`; session members at 02:07:07Z: 26214 + transient heartbeat `sleep 2` child (pid 27207 at that instant, also carrying inherited fd 9). Census of its owned work: `[26278:empty]`. X1–X5 launchers all gone. X6 `LEASE_RELEASE/` still a directory containing only `LEASE_RELEASE.tmp.26214` (the exact repair the driver would have performed at check 10 was **not** performed — stop policy). Canonical `execution/test-validation.lock`: 0 fd links in readable processes; `execution/s5-r4` absent; `worktrees/s5-r4` unchanged (` M` two test files).

## Source pre/post (`PREFLIGHT.txt`, `POST_ACCOUNTING.txt`)
Packet 33/33 `b96dc732…` before and after; S4 result `02df9f60…` and addendum `699a554a…` intact; no npm/install/network; no canonical action. Writes: `data/**` (driver/launchers/fake runner), this directory's records.

## Freeze note
`SHA256SUMS.s5-setup-v2-control-result` is a **point-in-time snapshot** (02:08Z): the live holder 26214 keeps appending heartbeat lines to `data/…/X6/logs/setup-exclusion/launcher.EXIT_RECORD` and rewriting `X6/LEASE_HOLDER`; those two files will diverge from the manifest while the hold persists. Everything else is static. Recovery of pid 26214 is a separate parent disposition (identity above; owned work positively empty per the launcher's own census; UNKNOWN never authorizes release). No follow-on runtime started.
