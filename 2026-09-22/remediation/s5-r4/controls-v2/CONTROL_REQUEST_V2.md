# S5 R4 control-driver successor v2 (Tier 1 grant candidate) — original 17-file packet untouched

Original packet (`SHA256SUMS`, 17 files, sha256 of manifest `1737068c…`) is immutable; `controls/` = v1, retained. v2 lives only in `controls-v2/`; manifest `SHA256SUMS.controls-v2` (non-self-including, covers all v2 files + the v1→v2 diff). Diff `controls-v1-to-v2.diff` (59 lines) sha256 `ab83c7d9d823a303839751ea2168891fa4296a01c1cf801eb61f2d6fc6b1882b`. Not executed; `bash -n`/`node --check` only. No app/schema/deps/runner change; runner rev 7 / fixture rev 2 hashes unchanged.

v2 changes (driver only):
1. `lib.sh control_preconditions`: no open/create/flock probe of the canonical lock; read-only `stat` of the path recorded instead.
2. `lib.sh check`: first failed check logs `STOP_ON_FIRST_FAILURE`, sets `S5_CTL_KEEP=1` (control root + logs retained) and exits 1; the EXIT trap performs owned cleanup of recorded pids only. Later scenarios do not run over an unexplained failure.
3. `ctl-genctl.sh`: no `/tmp/s5-genctl-*` glob/mtime removal; exact scratch dirs are parsed from the derived runner's own `CMD (cwd=…)` lines, recorded to `control-results/genctl-scratch-dirs-<ts>.txt` and RETAINED as evidence.

Tier 1 commands (sequential, one at a time, ≈2.5 min total; no DB/network/install/canonical lock):
```
cd /home/user/workspace/execution/s5-r4
S5_CTL_GRANT=granted-by-parent bash controls-v2/ctl-lifecycle.sh      # <= 75 s
S5_CTL_GRANT=granted-by-parent bash controls-v2/ctl-destroy.sh        # <= 30 s
S5_CTL_GRANT=granted-by-parent bash controls-v2/ctl-genctl.sh         # <= 20 s
node controls-v2/probe-spec-wiring.cjs /home/user/workspace/worktrees/s5-r4   # <= 5 s
```
Criteria, budgets, expected-failing scenarios and outputs are as in `CONTROL_REQUEST.md` (unchanged for v2 except the three items above). Tier 2 (`controls-v2/teardown-gate/ctl-teardown-gate.sh`) still requires a separately granted `npm-ci.sh`.
