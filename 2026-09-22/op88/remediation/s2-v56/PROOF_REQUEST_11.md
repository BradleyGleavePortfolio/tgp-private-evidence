# PROOF_REQUEST_11 — real S2 composition proof with runner v5.6 (NOT executed; separate grant AFTER CONTROL_REQUEST_10 is green and reviewed)

Distinct from CONTROL_REQUEST_10: this request executes the real fixture (PG17), the real harness `test/release/s1s2-composition.sh` (c766a8d9…) and the pinned Prisma CLI inside the isolated worktree. It requires a **fresh setup grant**; the parent's environment observation (Bash 5.3.9, Node 20.20.1, npm 10.8.2, Python 3.14.3, uutils timeout 0.8.0; **no PG17, no browser, no application deps inherited**) means the earlier setup05 positive is NOT a current install and must not be reused as one.

## Preconditions (each verified and stamped before the runner starts; the runner itself refuses 70 on failure)
1. CONTROL_REQUEST_10: all seven sets aggregate 0, results frozen, reviewed.
2. Fresh setup grant executed and receipted: PG17 binaries present at the fixture's expected path; `node_modules` installed from the pinned `package-lock.json` (sha 62b05b90… == `EXPECT_LOCK_SHA`); installed Prisma CLI sha256 == `EXPECT_PRISMA_CLI_SHA` c2a77456… (runner F06 checks existence + pin BEFORE `--version`).
3. Worktree `worktrees/s2-runner53` at d5cd9b8b…, tree c0ab87d4…, dirty 0; fixture `test/db/_support/…` sha 9fcc3696…; closure ref 9742037b ancestor; product unchanged (d5cd).
4. Canonical lane lock `/home/user/workspace/execution/test-validation.lock`: acquisition granted explicitly for one slot (a free lock is not permission); the runner holds fd 9 through cleanup and the parent probes with `check-lock.sh` after exit.
5. No `S2_RUNNER_STUBS` in the environment; `CHECKPOINT_DISABLE=1` and `env -i` behaviour preserved as in v5.5 (unchanged).

## Invocation (one slot, bounded)
```
cd /home/user/workspace/execution/op88/s2-v56
sha256sum -c --quiet SHA256SUMS.outer && timeout --foreground -k 60 900 bash run-composition-r56-v5.6-when-granted.sh; echo "runner=$?"
```
Output: `composition-r56/<utc>/` with stamp.txt, step logs, exit-codes.txt, SHA256SUMS, RECEIPT.txt, SHA256SUMS.outer, PUBLICATION.txt. Expected `final=0`, `publication_status=ok`, `survivors=none`, lock released at exit.

## Exclusions (not granted)
- No destroy of any fixture/data directory other than the runner's own bounded `fixture stop` of the fixture it started (`FIXTURE_STARTED=1`); nothing erased on a refused/quarantined path (72).
- No network, no repository writes/commits, no canonical state publication, no changes to product/fixture/schema/lockfile.
- No retries on a nonzero exit: return the frozen output directory and stop.

## Known distinctions to keep in the result
- Stub-mode controls (CONTROL_REQUEST_10) prove ownership/cleanup/publication mechanics at the no-DB/client boundary; only this request produces real fixture proof.
- A 75 (lock busy) or 70 (precondition refusal) is a valid, non-failing stop; 71/72 are cleanup classes requiring parent inspection of QUARANTINE.txt before any other slot.
