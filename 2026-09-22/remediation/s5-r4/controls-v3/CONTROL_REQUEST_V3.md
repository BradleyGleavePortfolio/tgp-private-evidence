# S5 R4 control-driver successor v3 (Tier 1 re-grant candidate) — v1/v2 packets and wave-1 evidence untouched

Scope granted: (1) fake jest argv-aware live sleep, (2) L2 current-run NEW live-log + postmaster.pid precondition before TERM, (3) causal deadline targeting for L3. Nothing else changed; L2.exit expectation unchanged; runner `19ab936a`, fixture `3a7d57bf`, patch `c36258b3` unchanged. Not executed; `bash -n`/`node --check` only.

- `controls-v3/` = v2 + `controls-v2-to-v3.diff` (82 lines) sha256 `f1fc46ee1180995a0749e30c9a7a20d18a23194594f77d8c5b3603c5c70e7ce7`. Manifest `SHA256SUMS.controls-v3` (non-self-including; covers all v3 files + the diff).
- `lib.sh` fake jest: scenario sleep/exit only when argv contains `rls-g2-pg17-etq0.spec.ts`; guard-unit invocations exit 0 after 0.2 s (`FAKE_JEST_GUARD_UNIT`).
- `ctl-lifecycle.sh` L2: waits <= 20 s for THIS run's new `live-etq0-*` log carrying `FAKE_JEST_GRANDCHILD`, `postmaster.pid` present and runner alive; new `L2.pre` check fails (and stops the driver) if the live phase is not reached, so a mis-targeted signal is a precondition failure, never a runner finding. TERM is sent only after L2.pre passes.
- L3: `WORK_BUDGET=12` (wave-1 measured pre-live overhead ~4 s); new `L3.pre` asserts the live CMD line precedes `OWNED_WORK_DEADLINE` in the same run log; wall budget 30 s.
- Driver budget header: <= 100 s (accounts for guard/preflight overhead, reap and stop); 1.1 s spacing between runs retained (second-resolution TS collision avoidance); first failure stops the driver with owned cleanup (`S5_CTL_KEEP=1` retains the root).

Ready request (sequential, one wave, first failure/timeout stops the wave; outer bound per driver = budget + 20 s cleanup):
```
cd /home/user/workspace/execution/s5-r4 && mkdir -p control-results
S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20 120 bash controls-v3/ctl-lifecycle.sh   # <= 100 s
S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20  50 bash controls-v3/ctl-destroy.sh     # <= 30 s
S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20  40 bash controls-v3/ctl-genctl.sh      # <= 20 s
node controls-v3/probe-spec-wiring.cjs /home/user/workspace/worktrees/s5-r4                                       # <= 5 s
```
Outputs: `control-results/` (driver logs, new control roots `/tmp/s5-r4-ctl-*` retained). Wave-1 files (`WAVE1_FIRST_FAILURE.md`, `wave1-lifecycle-evidence/`, `SHA256SUMS.wave1`) remain as they are. Evidence collection only; not clearance.
