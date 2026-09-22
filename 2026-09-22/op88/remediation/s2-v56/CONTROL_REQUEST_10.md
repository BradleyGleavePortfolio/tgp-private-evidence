# CONTROL_REQUEST_10 — stub-only, safe controls for runner v5.6 / driver v56 (NOT executed; requires a grant)

Scope: stub mode only (`S2_RUNNER_STUBS` set by the driver). No DB, no network, no package install, no product/client execution beyond the real harness's offline refusal path (steps 20/21, exit 64), no destroy, no canonical lock (`execution/test-validation.lock` is never opened; the driver reports existence only). Two independent exact-successor reviews of the frozen candidate precede this grant.

## Candidate bytes (must match before any run)
```
cd /home/user/workspace/execution/op88/s2-v56 && sha256sum -c --quiet SHA256SUMS.outer && echo LANE-OK
```
Runner `run-composition-r56-v5.6-when-granted.sh` and driver `controls-proposed/run-controls-v56.sh` hashes: see SHA256SUMS.outer / REPORT.md.

## Environment prerequisites (absent in the preparing sandbox; verify, do not create silently)
1. `/home/user/workspace/worktrees/s2-runner53` at HEAD d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c, tree c0ab87d4dc584b2a7ccad53db16fa551b93fe359, `git status --porcelain --untracked-files=all | wc -l` = 0 (runner pin `WT`, unchanged from v5.5).
2. `/home/user/workspace/execution/s2-setup-prep/` restored from the frozen proposal: predecessor runner `run-composition-r53-v5.3.1-when-granted.sh` sha256 fb0d7ce4… and its 37-file manifest verifying from ITS OWN directory:
   `cd /home/user/workspace/execution/s2-setup-prep && sha256sum -c --quiet SHA256SUMS.outer && echo PRE-OK` (37 OK lines expected; verification from any other cwd is invalid).
3. Tools: bash ≥5, coreutils or uutils `timeout` with `-k`/`--foreground` (parent observed uutils 0.8.0 — the driver stamps `timeout_impl=` on line 1 of each result), `flock`, `pgrep`, `setsid`, `sha256sum`, `awk`. Record versions in the grant receipt.
4. No pre-existing pattern matches: the driver aborts (exit 2) if `pgrep -f` finds runner/stub patterns before start.

Optional path amendment (PROPOSED, not applied): if the worktree is restored elsewhere (e.g. `worktrees/op88-s2`), amend runner `WT=`/`LANE=` and driver `PRE_RUNNER=` pins in a v5.6.1 with its own review; do not edit the frozen v5.6 bytes in place.

## Execution order (sequential; STOP at the first nonzero aggregate exit; one invocation = one set)
```
D=/home/user/workspace/execution/op88/s2-v56/controls-proposed/run-controls-v56.sh
CTL_SET=probe  CTL_BUDGET=20  bash "$D"; echo "probe=$?"     # 1 control,  ≤20 s
CTL_SET=wdtest CTL_BUDGET=20  bash "$D"; echo "wdtest=$?"    # watchdog self-test, ≈13 s, exit 0 expected
CTL_SET=k      CTL_BUDGET=60  bash "$D"; echo "k=$?"         # K1–K4, K7, K10 (6)
CTL_SET=new1   CTL_BUDGET=60  bash "$D"; echo "new1=$?"      # 5
CTL_SET=new2   CTL_BUDGET=60  bash "$D"; echo "new2=$?"      # K7pre on the frozen v5.3.1 (1)
CTL_SET=neg    CTL_BUDGET=90  bash "$D"; echo "neg=$?"       # N1–N3 nested drivers (3)
CTL_SET=neg2   CTL_BUDGET=120 bash "$D"; echo "neg2=$?"      # N4, N5a, N5b, N6, N7 (5)
```
Expected: every aggregate exit 0. Any 1 (assertion miss), 2 (precondition), 3 (budget/cancellation), 4 (handoff failure) stops the sequence; the results directory (`controls-proposed/results/<set>-<utc>-<pid>/`, with `CONTROLS_RESULT.txt`, `CONTROLS_RECEIPT.txt`, `SHA256SUMS`, child logs, `owned-history.txt`) is returned unmodified. Wall-clock upper bound for the whole sequence ≈ 7 min.

## Limits granted by this request
- Signals: only to processes the driver/runner published and recorded (self-published groups, recorded pids) plus the driver's own decoy/controllers; N4 proves the caller group is never hit.
- Writes: only under `execution/op88/s2-v56/controls-proposed/results/`, `execution/op88/s2-v56/runner-selftest-r56/`, and (new2 only) `execution/s2-setup-prep/runner-selftest-r531/` (additive; the 37 frozen files untouched — re-run PRE-OK afterwards).
- Not granted: real fixture/DB, node/prisma/psql execution, installs, network, destroy, canonical lock, commits.

## Return
Aggregate exits, the seven results directories (frozen, hashed), PRE-OK/LANE-OK outputs, `timeout_impl` line, and any deviation. No product-clearance claim follows from a green stub sequence: it discriminates the runner's ownership/cleanup/publication mechanics only (see PROOF_REQUEST_11 for real proof).
