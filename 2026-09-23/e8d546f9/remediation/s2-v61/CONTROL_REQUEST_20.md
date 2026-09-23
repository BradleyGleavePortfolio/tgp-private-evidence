# CONTROL_REQUEST_20 — bounded CONTINUATION of the V59 eight-set sequence with driver v61 (NOT executed; requires a grant)

Scope: stub mode only (`S2_RUNNER_STUBS` set by the driver). No DB, network, install, product/client execution, canonical lock, commits. Supersedes CONTROL_REQUEST_16 (executed, STOP at k=1) and CONTROL_REQUEST_18 (V60, K3-only, frozen, NOT to be executed: its predicted K4 failure is known) for exactly the actual V59 failure S2-V59-K3-PLACEMENT and its two same-class NOT-RUN sites K4 and N4b confirmed by both frozen result reviews (Result-A 96e4d876…, Result-B 41b5b5e0…): driver v61 places the TERM at K3/K4/N4b by the runner's own step-40 evidence through one driver-only helper pair, not by an elapsed-time bound (FINDINGS_MAP_V61.md). Continuation, not a repeat: the V59 results for `probe`, `wdtest`, `wdcancel` (raw 0/0/3, frozen in `execution/e8d546f9/s2-v59-control-result`, manifest d749a4b1…) are RETAINED as evidence and NOT re-run; the sequence resumes at set `k` and runs `k new1 new2 neg neg2`. Everything else (write set except the lane path, ENV01, set map, codes, dual-lane RLANE, `GIT_OPTIONAL_LOCKS=0`) is unchanged from CONTROL_REQUEST_16.

**K1/K2 repetition — minimal inseparability (explicit):** the driver's only selector is `CTL_SET`; set `k` is one invocation running K1→K6 in order under ONE-STRIKE and the set-level watchdog/budget/publication. There is no per-control start selector, and adding one would be a new seam in the reviewed budget/strike/publication path — NOT done. Therefore K1 (≈3 s, predecessor mechanism counterexample) and K2 (≈5 s, stub success) are re-executed inside the new `k` set before the corrected K3; their V59 PASS evidence (`k-20260923T013657Z-9623/CONTROLS_RESULT.txt` L7–L41, runner output `20260923T013700Z`) remains frozen and is not overwritten (new result directories are timestamped). The nested negative controls N2/N3 (set `neg`) invoke a child `CTL_SET=k` driver that stops before/at K1–K2 by design and never reaches K3.

## Candidate bytes (must match before any run)
```
cd /home/user/workspace/execution/e8d546f9/s2-v61 && sha256sum -c --quiet SHA256SUMS.outer && echo LANE-OK
```
Driver `controls-proposed/run-controls-v61.sh`; runner `run-composition-r57-v5.7-when-granted.sh` BYTE-IDENTICAL to V57/V58/V59 (efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c); all four stubs, `SHA256SUMS.stubs` and `k1-predecessor-mechanism.sh` byte-identical to V58/V59. Hashes in SHA256SUMS.outer / REPORT.md.

## Path arrangement (dual-lane; ACCEPTED by the parent 2026-09-23 to preserve the runner hash)
The runner is unchanged, so it keeps ITS pinned lane `execution/op88/s2-v57` (runner L97): in stub mode it writes `execution/op88/s2-v57/runtime/test-validation.lock` (L115) and `execution/op88/s2-v57/runner-selftest-r57/<utc>/`. The v61 driver reads/probes exactly those paths (`RLANE`, `LANE_LOCK`, `OUT57`) and keeps its own lane `execution/e8d546f9/s2-v61` for stubs, K1, and `controls-proposed/results/`. The V59 run left additive runner outputs `runner-selftest-r57/20260923T013700Z` and `…013705Z` there (retained evidence). The restored V57 lane's 15 manifested files are NOT modified by this (additive directories only; `sha256sum -c` of its SHA256SUMS.outer stays valid). No single-lane runner change is authorized or made.

## Environment prerequisites (verify; do not create silently)
1. `worktrees/s2-runner53` at d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c, clean (`git status --porcelain` empty).
2. `execution/s2-setup-prep/`: `sha256sum -c --quiet SHA256SUMS.outer && echo PRE-OK` (37 OK; predecessor v5.3.1 fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925 at `execution/s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh`).
3. `execution/op88/s2-v57/`: `sha256sum -c --quiet SHA256SUMS.outer` (15 OK, manifest 72b9cfb5…) and the directory writable by the executor (runner-pinned lane, see above).
4. ENV01: ALREADY APPLIED under the V59 grant (`s2-v59-control-result/ENV01_RECEIPT.txt`): `execution/s2-setup-prep` is back at 0555 (PRE-OK 37/37) and `runner-selftest-r531/` EXISTS, executor-owned (755) and EMPTY (V59 stopped before `new1`). No further permission action is needed; verify PRE-OK and that the directory is writable by the executor. Set `new1` ONLY writes `execution/s2-setup-prep/runner-selftest-r531/<utc>/`; `new2` (K10) needs no predecessor-directory permission.
5. Tools: bash ≥ 5, `timeout` with `-k`/`--foreground` (driver stamps `timeout_impl=`), util-linux `flock`/`setsid`, procps `pgrep`/`ps`, `/proc` readable, `getconf CLK_TCK`.
6. No pre-existing pattern matches (driver aborts 2 otherwise).

## Execution (sequential, raw status, STOP at first ≠ 0 — with the ONE documented exception)
```
export GIT_OPTIONAL_LOCKS=0   # B57-06 (parent-allowed): the runner's read-only git status calls must not refresh the worktree index cache; inherited through env
D=/home/user/workspace/execution/e8d546f9/s2-v61/controls-proposed/run-controls-v61.sh
declare -A B=([probe]=20 [wdtest]=20 [wdcancel]=20 [k]=60 [new1]=60 [new2]=60 [neg]=90 [neg2]=150)
for s in k new1 new2 neg neg2; do   # CONTINUATION: probe/wdtest/wdcancel evidence retained from the V59 run (0/0/3), not repeated
  CTL_SET=$s CTL_BUDGET=${B[$s]} bash "$D"; rc=$?; echo "$s=$rc"
  if [ "$rc" -eq 0 ] || { [ "$s" = wdcancel ] && [ "$rc" -eq 3 ]; }; then continue; fi
  echo "STOP at $s (aggregate $rc)"; break
done
```
Raw exits are printed for every set; nothing is piped or `|| true`d; the caller shell must not run with ambient `set -e` (rc is captured on the line after the driver). Actual set → workload map (from the driver's `need` lines): probe = P1 (1); wdtest = W1 watchdog TERM→KILL escalation self-test (1, ≈16 s); wdcancel = C1 driver cancellation self-test (1, ≈18 s; **standalone exit 3 is by design — the driver cancels itself and reports aggregate 3 — and is the only accepted nonzero; when nested by N8 the same 3 is asserted**); k = K1–K6 (6); new1 = K7pre, K8pre, K7, K8, K9 (5); new2 = K10 (1); neg = N1–N3 nested drivers (3); neg2 = N4, N5a, N5b, N6, N7, N8 (6).

Expected: aggregate 0 for all five continued sets (the standalone `wdcancel=3` exception is retained in the loop text for identity with CONTROL_REQUEST_16 but no `wdcancel` set is in this list; N8 still asserts the nested 3). Codes: 1 assertion miss, 2 precondition, 3 budget/cancellation, 4 handoff failure (survivors, held lane or predecessor lock, watchdog/controller/finish-alarm residue).

## Applicability of retained V59 evidence to v61 bytes (explicit; decided by the exact review, not asserted as inheritance)
The ONLY shared input whose bytes differ between the executed V59 sequence and this request is the driver file (v59 924768a2… → v61). Runner, four stubs, `SHA256SUMS.stubs`, K1 mechanism, RLANE, LANE_LOCK, OUT57, worktree pin, budgets, set selectors, ONE-STRIKE/publication/watchdog paths: byte-identical / unchanged. The v61 driver delta (`diffs/controls-driver-v59-to-v61.diff`) touches: header comments; the lane constant `R59`→`R61` (results dir, stubs dir, K1 script path); the set banner string; two new top-level function DEFINITIONS `step40_arm`/`step40_wait` (defined for every set, INVOKED only at K3/K4/N4b); the K3, K4 and N4b control bodies; the `need` declared maxima of K3/K4/N4.

| Set / control | Executed on V59 bytes | Code path changed by v59→v61? | Concrete reason a prior PASS would be invalidated? | Disposition in this request |
|---|---|---|---|---|
| probe P1 | PASS (0) | No: P1 body unchanged; only lane path constants (result dir location) and banner differ; the new function definitions are parsed but not invoked | None known | RETAIN V59 evidence; not re-run |
| wdtest W1 | PASS (0) | No (same as P1) | None known | RETAIN; not re-run |
| wdcancel C1 | 3 (documented exception) | No (same as P1) | None known | RETAIN; not re-run |
| k K1 | PASS | No: K1 body unchanged; `$K1` path prefix R59→R61 (same bytes at the K1 script) | None known | Re-executed ONLY because set `k` is inseparable (no per-control selector; NOT built) — ≈3 s |
| k K2 | PASS | No: K2 body unchanged | None known | Re-executed for the same inseparability — ≈5 s |
| k K3 | FAIL (placement) | YES — corrected | n/a | Run (corrected) |
| k K4 | NOT RUN | YES — same-class correction | n/a | Run (first execution) |
| k K5, K6 | NOT RUN | No | n/a | Run (first execution) |
| new1 K7pre,K8pre,K7,K8,K9; new2 K10 | NOT RUN | No (K8pre keeps its informational 4 s delay; no assertion depends on it) | n/a | Run (first execution) |
| neg N1–N3 | NOT RUN | No (N2/N3 child `CTL_SET=k` drivers stop at K1–K2 by design and never reach the changed K3) | n/a | Run (first execution) |
| neg2 N4a | NOT RUN | No (N4 shared declared max 34→40 only) | n/a | Run (first execution) |
| neg2 N4b | NOT RUN | YES — same-class correction | n/a | Run (first execution) |
| neg2 N5a, N5b, N6, N7, N8 | NOT RUN | No | n/a | Run (first execution) |

If the exact review finds a concrete reason the P1/W1/C1 passes are invalidated by the lane-path/banner/function-definition delta, the granting party may prepend `probe wdtest wdcancel` to the loop below (≈36 s); the builder does not ask for that by default (parent disposition: no automatic full rerun merely because the driver hash changed).

## Limits granted by this request
- Signals (v61 addition, same class as N5b): the step-40 controller armed at K3, K4 and N4b (`step40_arm`, a controller-listed `p<pid>:<start>` child of the driver) sends ONE `kill -TERM` to the runner pid read from the runner's own `lock acquired pid=` stamp, only after the runner's adoption ack `.pgid/40-composition.pgid.ack` and the harness workload line (K4: plus the harness `escapee pid=` line) exist and only after validating that pid's pgid equals the CURRENT enclosure authority; a timed-out wait (8 s) sends nothing and STRIKEs. Never a group, never the caller's group. Otherwise: only to identity-validated recorded processes (self-published groups validated by session id; pids validated by start identity — log-imported numbers ONLY when the producing stub published `start=<ticks>` and the live process still has it), the driver's own controllers (N1/N4 decoys, N5b seam controller, C1 sleeper as `p<pid>:<start>`; the N6 holder as `p<pid>:<start>` of the direct child PLUS `g<pid>` of its session once established — booked before any readiness wait, or listed by the pending-controller resolver on cancellation; the caller's own group is never a target), the driver's own watchdog/finish-alarm shells and sleepers, and — by the watchdog — the driver itself.
- Writes (complete): `execution/e8d546f9/s2-v61/controls-proposed/results/`; `execution/op88/s2-v57/runtime/` (runner/driver lane lock `test-validation.lock`); `execution/op88/s2-v57/runner-selftest-r57/`; and for `new1` ONLY: `execution/s2-setup-prep/runner-selftest-r531/` (see 4) and **`execution/e8d546f9/s2-v61/controls-proposed/stubs/test-validation.lock`** — the frozen v5.3.1 predecessor opens ITS private lock at `$S2_RUNNER_STUBS/test-validation.lock` (predecessor L52/L164; A03). The driver asserts that path from the predecessor stamp (`lock acquired pid=… fd9=<that path>`) and probes it FREE at handoff (HELD → 4; absent is fine). After `new1`, that lock file exists beside the four stub scripts; `SHA256SUMS.stubs`/`SHA256SUMS.outer` verification is unaffected (they list files, not directories). Nothing else. The canonical lock `execution/test-validation.lock` is never opened (driver reports exists/absent only).
- Not granted: real fixture/DB, node/prisma/psql, installs, network, destroy, canonical lock, commits, product edits, edits to `execution/op88/s2-v57` manifested files or to `execution/s2-setup-prep` manifested files.

## Return
Per-set raw exits, all results directories frozen (each has SHA256SUMS + CONTROLS_RECEIPT.txt), LANE-OK/PRE-OK output, `timeout_impl` line, ENV01 action taken, the `owned-history.txt` files (A04 `skip-*` lines are expected evidence, not failures), any deviation. No product-clearance claim follows from these controls.
