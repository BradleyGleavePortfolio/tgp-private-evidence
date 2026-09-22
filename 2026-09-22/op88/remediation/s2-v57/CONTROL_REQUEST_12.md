# CONTROL_REQUEST_12 — stub-only controls for runner v5.7 / driver v57 (NOT executed; requires a grant)

Scope: stub mode only (`S2_RUNNER_STUBS` set by the driver). No DB, network, install, product/client execution, canonical lock, commits. Supersedes CONTROL_REQUEST_10 (A07/D-05 corrections: raw status, actual set map, enumerated write set).

## Candidate bytes (must match before any run)
```
cd /home/user/workspace/execution/op88/s2-v57 && sha256sum -c --quiet SHA256SUMS.outer && echo LANE-OK
```
Runner `run-composition-r57-v5.7-when-granted.sh`, driver `controls-proposed/run-controls-v57.sh` — hashes in SHA256SUMS.outer / REPORT.md.

## Environment prerequisites (verify; do not create silently)
1. `worktrees/s2-runner53` at d5cd9b8b…, clean (restored per upstream-prereqs-2; `git status --porcelain` empty).
2. `execution/s2-setup-prep/`: `sha256sum -c --quiet SHA256SUMS.outer && echo PRE-OK` (37 OK; v5.3.1 fb0d7ce4…).
3. ENV01: `execution/s2-setup-prep` is mode 0555 and `runner-selftest-r531/` is absent. Sets `new1`/`new2` (K7pre/K8pre/K10 run the frozen v5.3.1 predecessor) write `execution/s2-setup-prep/runner-selftest-r531/<utc>/`. **At grant time** the granting party makes exactly that one directory writable (e.g. create `runner-selftest-r531/` owned by the executor, or `chmod u+w execution/s2-setup-prep` for the slot); nothing has been chmod'd by the builder. Without it, `new1`/`new2` fail at the predecessor's `mkdir` → runner exit ≠ 0 → aggregate 1 (attributable, not a defect).
4. Tools: bash ≥ 5, `timeout` with `-k`/`--foreground` (uutils 0.8.0 observed; driver stamps `timeout_impl=`), util-linux `flock`/`setsid`, procps `pgrep`/`ps`, `/proc` readable, `getconf CLK_TCK`.
5. No pre-existing pattern matches (driver aborts 2 otherwise).

## Execution (sequential, raw status, STOP at first ≠ 0)
```
D=/home/user/workspace/execution/op88/s2-v57/controls-proposed/run-controls-v57.sh
declare -A B=([probe]=20 [wdtest]=20 [wdcancel]=20 [k]=60 [new1]=60 [new2]=60 [neg]=90 [neg2]=150)
for s in probe wdtest wdcancel k new1 new2 neg neg2; do
  CTL_SET=$s CTL_BUDGET=${B[$s]} bash "$D"; rc=$?; echo "$s=$rc"
  [ "$rc" -eq 0 ] || { echo "STOP at $s (aggregate $rc)"; break; }
done
```
Actual set → workload map (from the driver's `need` lines): probe = P1 (1); wdtest = W1 watchdog TERM→KILL escalation self-test (1, ≈16 s); wdcancel = C1 driver cancellation self-test (1, ≈18 s, **expected aggregate 3 when run nested by N8; standalone it also exits 3 — its standalone status is informational and must not stop the sequence if 3**); k = K1–K6 (6); new1 = K7pre, K8pre, K7, K8, K9 (5); new2 = K10 (1); neg = N1–N3 nested drivers (3); neg2 = N4, N5a, N5b, N6, N7, N8 (6).
Correction to the loop above for that one known case: treat `wdcancel=3` as pass (`[ "$rc" -eq 0 ] || { [ "$s" = wdcancel ] && [ "$rc" -eq 3 ]; }`).

Expected: aggregate 0 for all sets except wdcancel (3). Codes: 1 assertion miss, 2 precondition, 3 budget/cancellation, 4 handoff failure (survivors, held lane lock, watchdog/controller/finish-alarm residue).

## Limits granted by this request
- Signals: only to identity-validated recorded processes (self-published groups validated by session id; pids validated by start time), the driver's own controllers (decoy, holder session, seam controller, cancel sleeper), the driver's own watchdog/finish-alarm shells and sleepers, and — by the watchdog — the driver itself.
- Writes: `execution/op88/s2-v57/runtime/` (lane lock `test-validation.lock`), `execution/op88/s2-v57/runner-selftest-r57/`, `execution/op88/s2-v57/controls-proposed/results/`, and (new1/new2 only) `execution/s2-setup-prep/runner-selftest-r531/` (see 3). Nothing else. The canonical lock `execution/test-validation.lock` is never opened (driver reports exists/absent only).
- Not granted: real fixture/DB, node/prisma/psql, installs, network, destroy, canonical lock, commits, product edits.

## Return
Per-set raw exits, all results directories frozen (each has SHA256SUMS + CONTROLS_RECEIPT.txt), LANE-OK/PRE-OK output, `timeout_impl` line, ENV01 action taken, any deviation. No product-clearance claim follows from these controls.
