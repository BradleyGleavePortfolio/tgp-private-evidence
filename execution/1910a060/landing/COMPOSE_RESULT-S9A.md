# COMPOSE_RESULT-S9A: grant LAND-S9A-COMPOSE, STOPPED at runtime preflight (rc 71). No commit was made.

Tier T3, nonproduction. The run used `land-s9a-1910.sh` with sha256 `bbcdef58c2fc6da971f50143e6bb54ad1ff592ccf8202fab129d7d93c61c4b6e`, verified before the run.

## Sequence
1. **Pre-checks.** At about 22:04Z, `lslocks` showed no holder of `test-validation.lock` (inode 667698), a non-blocking `flock -n` probe succeeded, and no heavy processes were running.
2. **Predict** (`run/s9a-predict-20260925T220434Z`): `PREDICT_OK`, rc 0.
   - integration/importer = land/s8-f = M `62471b11`; main = `1c10e2a1`.
   - merge-tree in both orders gave `737c34a3b50cb823c9317d13e1b23797127338b9` with 0 overlapping paths.
3. **Compose** (`run/s9a-compose-20260925T220504Z`, launched 22:05:04Z). The console is in `run/s9a-compose-console.out`; `run/s9a-compose-terminal.txt` reads `RC=71 2026-09-25T22:05:22Z`.
   - The lock was acquired on fd 9 (inode 667698).
   - The remote check passed: tip = M, main = 1c10e2a1, and `land/s9-a*` were absent.
   - S9-A was fetched exactly: `be88909f`, tree `54349476`, parent `1c5fbb04`, with blobs equal to the gate's post-format receipts.
   - Hygiene passed for `1c5fbb04..be88909f`.
   - **First failure:** `git -C $DONOR_REPO diff --quiet e1ec2fec 62471b11 -- prisma package.json package-lock.json` printed `fatal: bad object 62471b11…`. The script refused with rc 71: "donor schema/package inputs differ from tip". Per the stop rule, there was no retry.

## Root cause (script defect, not a product or frontier issue)
- Line 238 was inherited from `land-s8f-1910.sh`. In S8-F the tip was 1c5fbb04, and the donor clone had that object. Here the tip is M, which exists only on origin and in the composition clone.
- The read-only donor clone `1910a060-s8f` (HEAD e1ec2fec, 0 tracked changes, still unchanged) has never fetched M, so the comparison could not run.
- The pinned inputs themselves are identical: in the composition clone, `git diff --quiet e1ec2fec 62471b11 -- prisma package.json package-lock.json` exits 0, and that clone holds both objects. My predict mode didn't exercise the donor path, so the defect was missed during preparation.

## State preserved (nothing deleted, nothing pushed)
- **Composition clone** `/home/user/workspace/worktrees/1910a060-land-s9a`:
  - branch `land1910/s9a` = M `62471b11`, clean;
  - `refs/heads/s9a-accepted` = be88909f;
  - `refs/remotes/origin/integration/importer` = M;
  - no node_modules and no non-sample hooks.
  
  No merge was attempted and no commit was made.
- **Not written:** there is no `state/compose-s9a.env`, and no remote ref was written. main and integration/importer are unchanged.
- **Lock:** released when the run exited at 22:05:22Z; the lock file is preserved. At 22:05:29Z another holder took it: pid 13522 `bash ./s8g-gate-1910-a2.sh` (the S8-G gate). I did not interfere with it.
- **Jest:** not reached, so none of the 7 suites ran.
- **Hooks:** not installed and not run.
- **M2:** none.

## Proposed CORRECTION-S9A-1 (NOT applied; needs a parent grant)
The diff is in `analysis/CORRECTION-S9A-1.proposed.diff`. The full proposed script is `analysis/land-s9a-1910.CORRECTION-S9A-1.proposed.sh`, sha256 `21f1ed8cc04b23bd0fa18e0a1f849676aaf1476548a88a2ccccd86187384eb2b`, and passes `bash -n`.

It makes two changes:
1. **Line 238:** run the check as `git -C "$W" diff --quiet "$DONOR_HEAD" "$TIP" -- prisma package.json package-lock.json`, against the composition clone, which holds both e1ec2fec (M's second parent) and M. The donor clone stays read-only. Its HEAD check (line 237) and its node_modules pin checks are unchanged.
2. **`W`:** change it to `/home/user/workspace/worktrees/1910a060-land-s9a-2`. The script's one-shot guard refuses an existing `$W`, and the first clone is preserved rather than deleted. The alternative is for the parent to disposition or rename the first clone and keep the path.

Everything else is byte-identical: the pins, the must-run suites, the hook normalization, the commit message, and the stage and ff modes. After adopting the correction, a fresh grant would run:

```
predict
COMPOSE_GRANT=1 DONOR_*=… timeout -k 30 3600 bash land-s9a-1910.sh compose
```

The lock must be free at that point; S8-G currently holds it.

## Audit of other donor/reference git operations in compose
- `git -C "$DONOR_REPO" rev-parse HEAD` (line 237) needs only the donor's own HEAD, so it is fine.
- The `HOOK_REF_ROOT` hook files are only read with `sha` and `sed`, with no object access, so they are fine.
- No other step in compose reads git objects from a clone other than `$W`.
