# C1 remaining-stage continuation proposal (frozen for A's narrow binding phase)

| Item | Value |
|---|---|
| Proposal script | `/home/user/workspace/execution/95633079/c1-execution/10-validate-continue.sh` |
| SHA-256 | `47c27fb9c700c797c55e7216378581d193dd8de63ec9f85aff08534f5d81bb1c` |
| Exact diff vs frozen launcher | `/home/user/workspace/execution/95633079/c1-execution/10-diff-vs-frozen.txt` |
| Frozen launcher | UNCHANGED at `a57c224c6e8e9364393318efaa99c33f4a90877287d7e1a7e370b1c75b220448`, not called |
| Preserved failed receipt | `logs/09-validate.sentinel` RC=71 STAGE=hooks-missing, `logs/09-validate.log`, `logs/09-launcher.out` — untouched; continuation writes only new `10-*` paths |
| Launch line | `setsid nohup bash /home/user/workspace/execution/95633079/c1-execution/10-validate-continue.sh > /home/user/workspace/execution/e7d2385c/s7-c1-formatted/logs/10-launcher.out 2>&1 &` |
| Sentinel | `/home/user/workspace/execution/e7d2385c/s7-c1-formatted/logs/10-validate-continue.sentinel` (RC= STAGE= END= HEAD=) |
| Receipts | `logs/10-validate-continue.log`, `logs/10-jest.log`, `COMMIT_RESULT.txt` (path unchanged from frozen line 61) |
| bash -n | OK |

## What is identical to the frozen launcher

- `set -u`, same `P`/`L`/`W` absolute paths, same exported env line (including `npm_config_offline=true`, `CI=1`, `LEFTHOOK_VERBOSE=1`, 4096 MB Node option), same `cd`-failure rc 74, same `stop()` sentinel/status function.
- All 19 rc-70 preconditions verbatim (HEAD, MERGE_HEAD, index tree, clean, staged 18, message hash, formatted manifest hash + its 24 contents, original packet manifest, author/committer identity, hooksPath, lefthook.yml/package.json/lock blobs, installed record, Prisma client, contract artifact, executable bins).
- Frozen lines 46–47 (`core.hooksPath` unset; tree `87798e74` and clean working state) — these were never reached by the first launch and now run unchanged.
- Stage 2 verbatim: `timeout -k 30 600 git commit -F "$P/07-merge-message.r2.txt"`, raw status captured then checked, no `--no-verify`, no hook disabling, no remote write; then committed-tree, exactly-two-parents-in-order, both Bradley identities, message-bytes note, trailer rejection, cleared merge state and clean status, then the same `COMMIT_RESULT.txt` content.
- Stage 3 verbatim: `timeout -k 30 600 ./node_modules/.bin/jest --ci --runInBand test/contracts/importer-contract.spec.ts src/extension-pair/__tests__`, raw status captured before summary extraction, post-Jest head/clean guard (`jest-changed-tree` rc 71 precedence retained), first-failure stop, no retry, no `--passWithNoTests`, no suite expansion, no PG lane.

## What changed, and only this

1. **Stage 1 install is not repeated.** `lefthook install` already completed with raw rc 0; the continuation performs no install, no hook rewrite, no `.bin/lefthook` creation.
2. **Frozen line 45's third predicate is re-bound to the actual installed route.** Retained: both hooks executable. Added in its place: exact byte hashes of both installed hooks (`a868b3a9…`, `a46fa398…`), both hooks referencing the absolute native target `$W/node_modules/lefthook-linux-x64/bin/lefthook`, the `call_lefthook run "pre-commit"` / `"commit-msg"` invocations, that native binary executable with byte hash `974486e9…` and reporting version `2.1.9`, plus no-bypass context (`LEFTHOOK`/`LEFTHOOK_BIN` unset, no `lefthook` on PATH ahead of the fallback, no `lefthook-local.yml`/`.lefthook-local.yml`). The genuine-hook boundary is strengthened in specificity, not weakened.
3. **Two added rc-70 preconditions protect the prior evidence:** the frozen launcher still hashes to `a57c224c…`, and `09-validate.sentinel` still records `RC=71 STAGE=hooks-missing`.
4. **New log/sentinel/jest-log names** (`10-*`) so no `09-*` receipt is overwritten.

No new test, harness, supervisor, diagnostic framework, control cycle, source change, formatter run, contract regeneration, fixture, database or remote operation is introduced.
