# PROOF_REQUEST_15 — real S2 composition proof with runner v5.7 (NOT executed; separate grant AFTER CONTROL_REQUEST_14 is green and reviewed)

Carry-forward of PROOF_REQUEST_13 (83d3586d…): the runner is BYTE-IDENTICAL to V57 (efa273c7…), so only the candidate-check path and the runner invocation path change (V58 lane); every precondition, bound and exclusion is unchanged. The runner's real-mode output stays under its pinned lane `execution/op88/s2-v57/composition-r57/<utc>/` (runner L97/L120) and its lock is the canonical `execution/test-validation.lock`.

Executes the real PG17 fixture, real harness `test/release/s1s2-composition.sh`, pinned Prisma CLI inside `worktrees/s2-runner53` (d5cd, unchanged). Supersedes PROOF_REQUEST_13 only by path (see above); P-01/P-02/P-03 corrections retained.

## Preconditions (runner refuses 70 on any failure; verify and stamp before start)
1. CONTROL_REQUEST_14 green (all sets 0; wdcancel 3), results frozen and reviewed by two independent auditors.
2. Fresh setup grant executed and receipted in this environment (no reuse of any earlier setup positive): PG17 binaries at the fixture's expected path; `npm ci` from the pinned lockfile (sha 62b05b90… == `EXPECT_LOCK_SHA`) with Prisma CLI `node_modules/prisma/build/index.js` sha c2a77456… == `EXPECT_PRISMA_CLI_SHA`; **the setup MUST write `worktrees/s2-runner53/node_modules/.s2-composition-install-stamp` containing the line `lock=62b05b90…` (full EXPECT_LOCK_SHA)** — runner L409–L411 refuses 70 without it (P-02).
3. Worktree at d5cd9b8b…, `git status --porcelain` empty; fixture **`execution/s2-setup-prep/infra/s2-fixture-r53.sh`** sha 9fcc3696… == `EXPECT_FIXTURE_SHA` with `^PORT=…;` and `^NS=…` pins (runner L101, L121, L415–L416) (P-03); product unchanged.
4. Canonical lane lock `/home/user/workspace/execution/test-validation.lock`: one explicitly granted slot (a free lock is not permission); runner holds fd 9 through cleanup.
5. `S2_RUNNER_STUBS` unset; `CHECKPOINT_DISABLE=1`, `env -i` behaviour as in v5.5/v5.6 (unchanged).

## Invocation (one slot; outer bound reconciled with the runner header, P-01)
```
cd /home/user/workspace/execution/e8d546f9/s2-v58 && sha256sum -c --quiet SHA256SUMS.outer \
 && timeout --foreground -k 60 2100 bash run-composition-r57-v5.7-when-granted.sh; echo "runner=$?"
```
Bound derivation: runner header L108 `timeout --foreground -k 60 2100`; step-40 bound `BOUND40=1500` (L457) + steps 10–45 bounds + `CLEANUP_BUDGET=50` + `OUTER_GRACE=60` < 2100. A 900 s outer bound (PROOF_REQUEST_11) would have cut a legitimate long composition — withdrawn.
Output: `execution/op88/s2-v57/composition-r57/<utc>/` (runner-pinned lane) with stamp.txt, step logs, exit-codes.txt, SHA256SUMS, RECEIPT.txt, SHA256SUMS.outer, PUBLICATION.txt. Expected `final=0`, `receipt_status=ok`, `publication_status=ok deadline_exceeded_at_publication=no`, `survivors=none`. Stdout last line: `RECEIPT: … PUBLICATION: status=ok publication_file=ok deadline_at_publication=no process_exit=0`.

## Exclusions
No destroy beyond the runner's own bounded `fixture stop` of the fixture it started; nothing erased on refused/quarantined paths (70/72). No network, commits, canonical publication, product/fixture/schema/lockfile changes. No retries: return the frozen output directory and stop. 75 (lock busy)/70 (refusal) are valid non-failing stops; 71/72 require parent inspection of QUARANTINE.txt before any other slot.
