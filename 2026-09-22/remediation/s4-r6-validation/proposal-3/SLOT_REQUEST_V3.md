# S4 R6 — native validation V3 (execution-only successor of V2; prepared, NOT executed; no grant assumed)

Slice **S4-R6-VALIDATION-V3-PREP**. Product head unchanged and frozen: `91990ae9aec72f47a67591892ac09fa1f59d2f16`
(tree `840fb2855953d5363fbd144e11b3f81763d9cef7`, parent `88287cff…`, base `0111be66…`); historical hooks **0/6**;
narrow dual source acceptance neither widened nor withdrawn. No product/source edit. V1 (`../`) and V2 (`../v2/`) stay
immutable; V3 lives only under `execution/s4-r6-validation/v3/`. Frozen inputs read: both V2 reviews
(`audits/s4-r6-validation/v2/{a,b}`), the V3-PREP register entry (`EXECUTION_REPAIR_WAVE_2.md`). Original source
audit packets not read or written.

Only `bash -n`, `node --check`, `py_compile`, and a static undefined-name walk over every embedded Python block
(the defect class that `ast.parse` missed in V2: 0 unquoted heredocs, 0 undefined names) were run. No launcher,
control, timeout target, install, test, browser, lock, worktree or network action. `runs/`, `tooling/`,
`v3/control-runs/` do not exist.

## V3 packet (hashes in `v3/SHA256SUMS`, non-self-including)

| file | role | sha256 |
|---|---|---|
| `launcher/s4-r6-launch-v3.sh` | exact bounded detached launcher/supervisor (sole entry point; VALIDATION or CONTROL kind) | `1113fde0e0d8204fcfe99372eb2446ee385de5831f392e30a282b9985bb55208` |
| `runner/s4-r6-validate-v3.sh` | validation runner (refuses direct invocation and `kind≠VALIDATION`) | `9ac2195eb9d2d1d0755afd822159928dd5b4bba3a112c638efa751780c670e02` |
| `runner/s4-r6-lib-v3.sh` | **shared** step wrapper / session census / reap / latch / expect_exit / record writer, sourced by runner and control stub | `4b3573641f84ff9bfa28bd1e427796aac6d806cff045ca55f293b52f3dbdf718` |
| `runner/chrome-pipe-discriminator-v3.mjs` | byte-identical to V2 helper (`c261ffb4…`), path renamed only | `c261ffb408dc5a724a17c5ad0889b500918fde5d1aa29420b39ced4c4d04531b` |
| `controls/s4-r6-control-stub-v3.sh` | control runner: same launcher contract, same library, scenarios via `S4R6_SCENARIO`; never opens the lock | `7e306209be6e5fb2971ccb0abefb8e1ff1f9a41eb26d7c208cbb18d91d7a3d47` |
| `controls/control-predicates-v3.py` | field-level acceptance per scenario (records, not exit codes) | `e9d01d45d30fa8d31c8989d8679dc2d59eaf774bbac226c58b1c5202ad61b8ee` |
| `controls/run-controls-v3.sh` | bounded sequential control driver, explicit total budget, stop at first mismatch | `fe0de076441e7aa686444a5325622a0078b0daae5e507a8ae5baeac1e589bb06` |
| `V2_TO_V3.diff` | exact `diff -u` V2→V3 for runner and launcher (+151/+239 changed lines), new/retired file list | `67ae964cdfae94cb1a09366132393e58ce120133c54e2d322d16ea8abdb83035` |

V2 controls C1–C4 are retired (they bypassed `step()`); nothing from them is reused.

## Finding → change map (A = S4-V2-A-0n, F = S4-R6-VPB-F0n)

| finding | V3 closure | where |
|---|---|---|
| **A-01 / F-01** nested `timeout` group escapes the PGID boundary; deadline reaches only the runner bash; lock released while step children run; false "verified empty" | Owned boundary is the **session** created by the launcher's `setsid`. Census `pgrep -s SID` (direct child, self excluded); `timeout`'s per-step groups, reparented orphans, npm/Vitest workers, node probes and Chrome are all inside it. Signalling: for every listed member `kill -SIG -- -pgid` (each foreign group in the session) then `kill -SIG pid`, TERM→≤10 s→KILL→≤5 s→re-census, in the existing loops. Launcher deadline/interrupt uses the same session-wide route, so the live step group ends and the runner's deferred trap runs while the runner still holds the lock; only after grace is the whole session KILLed (recorded). Recorded limitation: a workload that calls `setsid()` itself would escape (no native consumer or probe spawns detached). `timeout` semantics unchanged. | lib `census`, `signal_listed`, `reap_owned`; launcher `session_members`, `signal_session`, deadline block |
| **A-02 / F-02** shell `true`/`false` interpolated into Python → `NameError`, record never written, exit 7 everywhere | All values reach Python via argv and are coerced there (`b=lambda x: x=="true"`, `num()`); heredocs are quoted. Supervisor record written on **every** exit path incl. refusals (`publish_and_exit`), `.tmp`→parse→rename; `publication_ok` is a separate fact from `overall`; a publication failure only downgrades a SUCCESS path to 7, never relabels other outcomes. Static undefined-name scan: 0. | launcher `publish_and_exit`; lib `publish_exit_record` |
| **A-03 / F-03** `sleep 0.2` ownership discovery loses fast exits; refusal 73 without census; `wait` unbounded | No sleep. The launcher refuses (73, before spawning anything) if it is itself a process-group leader; otherwise util-linux `setsid` execs the runner in place, so `SID = PGID = RPID` by construction at spawn time. Runner/stub write `$$` to `RUNNER_PID` as a handshake; mismatch or absence on a success path → `FAILED_OWNERSHIP_HANDSHAKE` (9). Runner exit is confirmed by bounded polling (`CONFIRM_S=10`); if the pid is still alive after KILL the launcher publishes `QUARANTINED_SURVIVORS` (5) without waiting. Census + reap run after every runner exit including refusals (`RUNNER_REFUSED` with the runner's actual 71/73/75). | launcher §0, §2, §3, §4, §5 |
| **A-04** cleanup/source blocks latched before the observed command failure; violated expected-negative with rc 0 fell through to `exit 0` | `step()` latches the required-command failure **first**, then cleanup (96), then source (98). `block` carries `validation_exit` and `observed_exit` separately and never latches 0 (forced to 89). `expect_exit <step> <observed> <wanted>` records `PREDICATE_OK/VIOLATED`; a violation blocks with validation exit 89 while `first_failure.observed_exit` keeps the raw 0. `result_exit` never returns 0 for FAILED. S45 uses `expect_exit … 1`. | lib `block`, `expect_exit`, `step`, `result_exit`; runner S45 |
| **A-05** control allowance not enforced; grace inherited; no aggregate bound | Driver with explicit per-control `outer/grace/worst_case` and an explicit `TOTAL_BUDGET_S=185` that includes failure cleanup (confirm 10 s + reap/publish 7 s + driver 3 s per control); refuses to start a control whose worst case would exceed the remaining budget; stops at the first mismatch or leftover; typical duration is not claimed as the bound. | `controls/run-controls-v3.sh` |
| **F-03** controls bypass `step()`, race the launcher, C3 indistinguishable from F-02 | Controls run the **actual** launcher → stub → shared library → `step()` (nested `timeout`), `reap_owned`, `expect_exit`, `publish_exit_record`; each has field-level predicates (below). Race removed by construction (A-03). C3's successor is discriminated by `runner.exit==0 ∧ exit_record_result==SUCCESS ∧ sentinel==false` in a **parsed** supervisor record. | `controls/*` |
| VPA-04 joins / VPA-05 latch (narrow source closures) | **Preserved unchanged**: fresh exclusive output, single inventory/ZIP pair, actual ZIP hash/size, HEAD blob equality, receipt joins to the same ZIP hash, probe/predecessor pins, blocking prerequisite steps and NOTRUN. Only the S45 predicate call and the record writer call changed (see diff). | runner S00, S50b, S62b, S63b |

Non-material observations retained, not fixed (scope): N-01 S00 is not a bounded `step` (bounded only by the launcher
deadline); N-03 launcher records but does not pin the runner hash; N-05 `99` NOTRUN sentinel; N-06 runner has no
deadline of its own; N-07 `pgrep -f tgp-…` may over-match (fail-closed). N-04 was fixed because the control predicate
needs `owned_orphans_found` (inseparable). A's "cold/warm" labelling was already dropped in V2.

## Exact commands and output paths (no grant assumed)

**Stage 1 — safety controls (separate grant; must precede any validation slot):**
```
cd /home/user/workspace/execution/s4-r6-validation/v3
bash controls/run-controls-v3.sh ; echo "driver exit=$?"
```
Do **not** wrap the launcher or driver in `timeout` without `--foreground` (a non-foreground `timeout` makes its child a
group leader and the launcher refuses with 73 by design). The driver is the bound: `TOTAL_BUDGET_S=185` worst case,
typical ≈ 25 s. Outputs: `v3/control-runs/DRIVER-<utc>-<pid>.log`, one `v3/control-runs/CONTROL-V3-<utc>-<pid>-<rand>/`
per control (`console.log`, `LAUNCH_TOKEN`, `OWNED_SID`, `RUNNER_PID`, `steps/*.json|*.log`, `reaps.log`, `blocks.log`,
`predicates.log`, `EXIT_RECORD.json`, `RUN_COMPLETE.sentinel` where expected, `SUPERVISOR_RECORD.json`,
`PREDICATES.txt`), `v3/control-runs/DIRECT-REFUSAL-<utc>.txt`. Driver exit 0 = all six controls matched; 92 budget stop;
93 output-dir anomaly; 94 first mismatch/leftover. No lock, worktree, network or install is touched by any control.

| # | scenario (via actual launcher+stub+lib) | outer/grace | required record facts (see `control-predicates-v3.py`) |
|---|---|---|---|
| 1 | `nested-orphan-after-exit` — `step` runs `bash -c '( trap "" TERM; sleep 300 & ); exit 0'` | 25/3 s | `overall=SUCCESS`, exit 0; `steps[0].owned_orphans_found=1`, `orphans_reaped_verified=true`; `reaps.log` shows found=1 and session verified empty (TERM-immune ⇒ KILL path); `reaped_by_supervisor=[]`; `handshake_ok=true`; sentinel present |
| 2 | `live-step-interrupt` — `step` runs `sleep 300` while launcher deadline 4 s fires | 4/6 s | `overall=TIMEOUT`, exit 124; `timed_out=true`; `signalled∈{TERM,TERM+KILL}`; `members_at_deadline` ≥2; `survivors_after_kill=[]`; runner exit confirmed ∈{124,137,143}; runner record present with `first_failure.step=C-live-step` and a later `SIGNAL_TERM` block |
| 3 | `predicate-rc0` — `step` (required=0) runs `true`, `expect_exit … 1` | 10/3 s | `overall=RUNNER_NONZERO`, exit 89; record `first_failure.validation_exit=89`, `observed_exit=0`, `steps[0].status=EXIT_0` |
| 4 | `record-without-sentinel` — parsed SUCCESS record, sentinel withheld | 10/3 s | `overall=FAILED_PUBLICATION`, exit 7; `runner.exit=0`, `exit_record_result=SUCCESS`, `sentinel=false`, `handshake_ok=true` |
| 5 | `refuse` — stub exits 71 before handshake | 10/3 s | `overall=RUNNER_REFUSED`, exit 71; `exit_confirmed=true`; `runner_pid_handshake=null`; `refusal` recorded; `orphans_after_runner_exit=[]` |
| 6 | direct invocation of the real runner without launcher | 5 s | exit 71 with the exact refusal message; `runs/` unchanged |

Every control also requires `survivors_after_kill=[]`, `launcher_exit` recorded equal to the observed exit, and an empty
independent `pgrep -s <OWNED_SID>` scan by the driver. Any single miss stops the driver (no retry, no re-run without a
new version).

**Stage 2 — validation (later, separate grant, after S2 releases the heavy slot):**
```
cd /home/user/workspace/execution/s4-r6-validation/v3
bash launcher/s4-r6-launch-v3.sh ; echo "launcher exit=$?"      # S4R6_OUTER_S=3300 S4R6_GRACE_S=45 defaults
```
Outputs under `execution/s4-r6-validation/runs/VALIDATION-V3-<utc>-<pid>-<rand>/` (same file set as V2 plus `OWNED_SID`,
`RUNNER_PID`, `predicates.log`). Bound: 3300 s outer + 45 s grace + 10 s confirm + ≤22 s reap/publish (recorded as
`bounds.worst_case_s`); typical ≈ 15 min. Launcher exits: 0 SUCCESS · 124 TIMEOUT · 143 INTERRUPTED · 5 QUARANTINED ·
6 runner left orphans · 7 FAILED_PUBLICATION · 9 ownership handshake · 71/73/75 runner refused · 70–73 launcher refusal ·
otherwise the runner's validation exit. Steps, budgets, pins and criteria are those of V2 (`../v2/SLOT_REQUEST_V2.md`)
with S45 now via `expect_exit`.

## Exact next request

1. Two independent reviewers assess the V3 files above (exact diff `V2_TO_V3.diff`) — not the product, not V1/V2.
2. Parent grants Stage 1 (six controls, ≤185 s worst case, no network/lock/worktree). Any mismatch stops V3 → V4.
3. Then Stage 2, one validation run, when the heavy slot is free.
4. Runner `SUCCESS` is builder evidence only; two independent final evidence attestations remain required; hooks stay 0/6.

Nothing executed; no grant assumed; V3 frozen at the hashes above (any byte change = V4 + new request).
