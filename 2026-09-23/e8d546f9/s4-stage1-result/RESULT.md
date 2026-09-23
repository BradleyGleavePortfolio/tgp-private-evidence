# S4 V6.1 Stage 1 — single control run, frozen result and slot closure

Executor `s4_v6_1_narrow_repair_muddwjaa` (requested Claude Fable 5 / High; runtime telemetry not observable, not asserted). Grant: `tgp-private-evidence/execution/e8d546f9/S4_STAGE1_GRANT.md` sha256 `102683cb209d0489953f669dd6bb07f648b4fb2d7efa9b1f2af94314d5baacee` (parent readback commit `60d807e3…`), activated by parent mail 01:12 UTC. Executed **once**. No re-run, no ad hoc signal, no cleanup outside the reviewed driver's own mechanisms.

## Outcome: PASS under the grant's criteria (wrapper/private-control evidence only)

| grant criterion | observed |
|---|---|
| raw driver exit 0 | caller line `driver exit=0` (`stage1.log` line 408); observer receipt `stage1.exit` = `0` — the receipt is the **unchanged inner caller's** exit propagated by the transport wrapper, recorded separately from the driver's own `EXIT code=0` |
| every expected `PREDICATES.txt` present, no MISS | 11/11 present (one per launched control; control 12 is the direct-runner refusal, which has no predicate file by design), **0 MISS**, 363/363 OK (37,42,44,32,30,34,29,23,31,31,30) |
| `DRIVER-TERMINAL` | `DRIVER-TERMINAL-20260923T011533Z-13667.txt`: `EXIT code=0 why=all controls passed run=…CONTROL-V6-20260923T011522Z-17254-7e3d3051 identity=BOUND leftovers_first='' (state=EMPTY) leftovers_final='' (state=EMPTY) private_lease_free=true live_quarantine_holder='' cancelled='' elapsed=87s budget=1500s` |
| direct-runner refusal | `DIRECT-REFUSAL-20260923T011533Z.txt`: exit 71 (expected 71), `runs_before=0 runs_after=0` |

**Start/end:** transport launch 01:14:06Z (wrapper pid 13653, pgid 13653, sid 13653 — own session); driver start 01:14:06Z (`driver_pid=13667 driver_start=205017`); driver EXIT 01:15:33Z; wrapper `end_utc=2026-09-23T01:15:33Z exit=0`. Elapsed 87 s of the 1500 s allowance (reserve 115 s). Tool ceiling (900 s) never approached; no observer-side timeout was involved.

**Command (exact, unchanged; sha256 of `stage1-caller.cmd` `680a0161ae4290709286103e3b195c5fb916b50bce7f9fb9dee500c8292ac1cc`, checked equal to the grant's line before launch):**
```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash controls/run-controls-v6.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
```

**Transport used (exactly `s4-control-prep/TRANSPORT.md` T1/T2/T3):** `setsid -f bash -c '<wrapper>' _ stage1-caller.cmd stage1.exit </dev/null >stage1.log 2>&1`; wrapper logged `launch_utc/pid/pgid/sid/caller_sha256`, ran `bash stage1-caller.cmd` (spawning the accepted `bash -c` byte-identical), then wrote the raw exit atomically to `stage1.exit`. Three `bash`-tool poll calls (read-only `kill -0` liveness + log tail, no signals). Observer return and driver exit are distinct artefacts: `stage1.exit`/`end_utc=` (observer/transport), `driver exit=` (caller), `DRIVER-TERMINAL-*.txt` (driver). Topology as predicted: driver/launcher in the wrapper's process group (pgid 13653 ≠ launcher pids) — no topology refusal (73) occurred.

## Per-control outcomes (driver log `control-runs/DRIVER-20260923T011406Z-13667.log`)

| # | control | class | launcher exit | census after | private lease free | live holder after driver |
|---|---|---|---|---|---|---|
| 1 | nested-orphan-after-exit | normal | 0 | EMPTY | true | '' |
| 2 | live-step-interrupt | normal | 124 | EMPTY | true | '' |
| 3 | live-step-double-term | normal | 124 | EMPTY | true | '' |
| 4 | predicate-rc0 (runner nonzero 89) | normal | 89 | EMPTY | true | '' |
| 5 | record-without-sentinel | normal | 7 | EMPTY | true | '' |
| 6 | lease-held-by-supervisor | normal | 0 | EMPTY | true | '' |
| 7 | refuse | normal | 71 | EMPTY | true | '' |
| 8 | fault-holder-unverifiable | refusal | 8 | NO_SESSION | true | '' |
| 9 | fault-survivors-quarantine | quarantine | 5 | EMPTY | false → recovered | holder 15839/209327 identity-verified (starttime, token, fd 9 → private lease) and KILLed by the driver's `recover_holder` after injected survivors verified gone (log line 393) |
| 10 | fault-receipt-unwritable | quarantine | 11 | EMPTY | false → recovered | holder 16328/211007 identity-verified and recovered (line 442); holder record intentionally unwritable in this scenario, identity taken from console/pgrep as designed |
| 11 | fault-census-unknown | quarantine | 5 | EMPTY | false → recovered | holder 17287/212627 identity-verified and recovered (line 484); `census=UNKNOWN:124` recorded truthfully in `QUARANTINE_LEASE_HOLDER` |
| 12 | direct-runner-refusal | — | 71 | n/a | — | — |

Controls 1–8 released the standby holder at launcher exit (predicate `lease.standby_holder_released` OK). Controls 9–11 are the **intended** quarantine scenarios: the launcher retained ownership through the standby holder rather than exiting unowned; the driver recovered each holder only after the three-part identity check, on the **private** lease only. The two retained `QUARANTINE_LEASE_HOLDER` files (controls 9 and 11) are evidence of that path, not live ownership.

## Retention / cleanup accounting (state at 01:16Z, read-only checks)

* Live packet processes (`pgrep -af` launcher/driver/holder/stub/runner): **0**. Wrapper 13653 exited. No process holds `…/v6/control-runs/.private-control-lease.lock` (fd scan of `/proc/*/fd`); the lease file remains (79 bytes, last writer `17254 launcher CONTROL-V6-20260923T011522Z-17254-7e3d3051 2026-09-23T01:15:22Z`) — by design an unlocked marker, `private_lease_free=true`.
* No `DRIVER-UNRESOLVED-*` file. `execution/s4-r6-validation/runs/` still absent (Stage 2 only).
* Canonical `execution/test-validation.lock` untouched (mtime 00:57:42Z, before this run; Stage 1 never opens it).
* Staged packet after the run: `SHA256SUMS` `671d08c3…` **12/12 OK** (`packet-after-run.txt`); frozen source `s4-v61`, V6 predecessor and audits unchanged. Candidate runtime writes confined to `…/v6/control-runs/` (copied here whole as `control-runs/`).
* No re-run, no signal from the executor, no install/network/DB/browser/native.

## Stale-gate note (additive; earlier prep narrative left as written)

`s4-control-prep/REPORT.md` §4 listed B closure and the S2 setup slot as open gates at 01:07Z. Both closed before activation per the grant (B `94c5921e…`; S2 setup result `9c114363…`, 27/27, lock FREE 01:04:17Z). The `RESTORE LOG` observation "canonical lock path present" refers to the file's existence only, consistent with the grant's "FREE" (flock state), which Stage 1 never tests.

## Files

`stage1.log` (full caller/driver stdout+stderr, 409 lines), `stage1.exit`, `stage1.pid`, `T1-activate-utc.txt`, `terminal-receipt.txt`, `predicates-with-MISS.txt` (empty), `packet-after-run.txt`, `control-runs/` (11 control dirs, driver log, terminal receipt, direct refusal). Manifest `SHA256SUMS.stage1` (non-self-including).

Slot closure: attributable final outcome PASS + retention accounting above ⇒ this single-run slot is closed from the executor's side. Stage 2 / native remain HELD; this is not package, browser, product or customer acceptance.
