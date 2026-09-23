# S5 V32 private controls — actual result (one granted run)

Executor: `repair_s5_binding_mue9vjso` (builder, not an independent auditor). Grant: `S5_V32_PRIVATE_CONTROLS_GRANT.md` sha256 `ef8ae46849395520d148ca4d39658790765402b3dcfcf02e3e2bd41c34f65877`; queue record `9cf29435b249edd585008aa1b7055e156759d38fed28c6d57ea628c3de8de72c`. Activation: parent mail 2026-09-23 09:28 PDT (S2 released runtime 16:25:02Z). Run root `/home/user/workspace/execution/6c2a68ac/s5-v32-control-run/20260923T162922Z`. Runtime released 16:31:09Z (`RUNTIME_RELEASE.txt`).

## Raw outcome

| item | actual |
|---|---|
| command | exact grant command, once (`COMMAND.txt`; launched 16:29:2xZ via `setsid nohup bash -c` detachment — mechanics only, no deadline/assertion/launcher change) |
| raw exit status of `timeout --foreground -k 10 180 bash ctl-v32.sh` | **0** (`ctl.raw_status`) |
| driver summary | `ALL_CASES_DONE pass=11 fail=0`, `SUMMARY pass=11 fail=0` |
| checks executed | **11/11**, all PASS, in order P1×5, P2×3, P3a, P3c, P3b (`ctl.stdout` == run-root `ctl.log`, byte-identical) |
| stderr | empty (0 bytes) |
| wall time | 16:29:22Z → 16:30:01Z (39 s; well inside 180 s) |
| FAIL diagnostics | none produced (0 `FAIL.*.diag`) — the O-B-01 path was not exercised |
| provenance logged by driver | driver `4323dc41…`, launcher `55acc00f…`, fake `045d5284…`, real setsid `/usr/bin/setsid` |
| candidate inputs after run | builder top seal `1f23abdc…` re-verified unchanged (`POST_RUN_INPUTS_UNCHANGED.txt`) |

## Per-case raw status and ownership (from each case's `LEASE_RELEASE`)

| case | how | raw | final_rc | runner note | session census | lock now |
|---|---|---|---|---|---|---|
| P1 | self-hold-then-empty | observed 90 | 90 | released=1 final=90 unpreserved=1 cleanup_failures=1 | 18110:empty 18178:empty | free |
| P2 | self-hold-then-empty | observed 0 (kept separate) | 90 | publication=holder-update-failed+release-record-rewrite-failed+release-record-failed | 19567:empty | free |
| P3a | runner-not-released(never-released)-then-empty | observed 143 | 90 | exit_record=not-this-attempt | 20505:empty | free |
| **P3c** (new negative) | runner-not-released(never-released)-then-empty | observed 143 | 90 | **exit_record=not-this-attempt** | 21165:empty | free |
| P3b (LAST) | normal | observed 75 | 75 | released=0 final=75 unpreserved=0 cleanup_failures=none | 21891:empty | free |

Ownership: launcher pids 18033/19503/20442/21102/21828 all gone; `pgrep -af s5-v32-control-run` → none; every case `private.lock` acquirable (`OWNERSHIP.txt`). P1/P2 `SELF_HOLD` records remain as historical hold records of released holders (expected; their `LEASE_RELEASE` says `self-hold-then-empty`). No retained/detached holder; nothing was signalled by the executor.

## What the run actually showed for the closed class-B findings
* **S5-V31-A-01 (P3c)**: the stale record carried `pgid=21165` = this attempt's exact `SESSION`, stamp `2026-09-23T16:29:58Z` **equal** to the holder's `LEASE_HELD` stamp (the equal-second class of the finding), token `STALE-TOKEN-P3c`. Launcher v3.2 classified it `exit_record=not-this-attempt`, produced no `released-but-no-IDENTITY`, no `SELF_HOLD`, released 90; the record's sha256 equalled the shim's seed (untouched). v3.1's pgid+stamp-floor fallback would have bound and imported it.
* **P3b** on the actual platform (uutils timeout 0.8.0, util-linux setsid 2.41.3, procps 4.0.4): the adopted fake's START `pgid=21891` == outer SESSION and `token=` == holder token; bound by START alone (died before INHERITED line), `raw=observed 75`, `final_rc=75` — confirms child-status propagation and no pgid move under the actual `timeout`.
* **V31-B-01 (P1)**: the acknowledged HEARTBEAT line was present before `P1.inner_live_hold` evaluated (no "P1 note" logged); check passed.

## Actual tool identities (PRECONDITIONS.txt)
uid 2000 (non-root), job control off, `timeout (uutils coreutils) 0.8.0`, `setsid from util-linux 2.41.3`, `ps from procps-ng 4.0.4`, bash 5.3.9; output parent resolved non-symlink; `S5X_OUT` absent before run; all three frozen manifests verified immediately before the run.

## Writes performed by the executor (grant §authority)
`execution/6c2a68ac/s5-v32-control-run/**` (by the driver/launchers only) and `execution/6c2a68ac/s5-v32-control-result/**` (this packet: command, preconditions, stdout/stderr/status, ownership, runtime release, immutable `evidence-copy.s5-v32-control-run/` == run root by `SHA256SUMS.run-root.s5-v32-control-run`, 56 files). No canonical lock operation, product/network/install/Git/source change, private-checkout write, or manual signal.

## Nonclaims
This is a private control proof of launcher v3.2 + fake v32 semantics; it is not product clearance, canonical setup, T0, S6 runtime, integration or customer proof (grant). Historical V2 result (raw1 / 8 PASS 1 FAIL, unknown failed operand) is not rewritten. Executor runtime identity is unasserted telemetry. The O-B-01 diagnostic path was not exercised (no FAIL). Token collision residual and wall-clock step-back false-FAIL class remain the recorded C qualifications.

## Files
`COMMAND.txt`, `PRECONDITIONS.txt`, `ctl.stdout`, `ctl.stderr`, `ctl.raw_status`, `OWNERSHIP.txt`, `RUNTIME_RELEASE.txt`, `POST_RUN_INPUTS_UNCHANGED.txt`, `SHA256SUMS.run-root.s5-v32-control-run`, `evidence-copy.s5-v32-control-run/**`, `RESULT.md`, manifest `SHA256SUMS.s5-v32-control-result` (non-self-including).
