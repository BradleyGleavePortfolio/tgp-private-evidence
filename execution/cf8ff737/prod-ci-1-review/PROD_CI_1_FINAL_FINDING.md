# PROD-CI-1 independent T3 review: final finding

**Verdict: NOT ACCEPT (one B, proof-only).** The code review passes on every source item. The only unmet item is the required real-PG15 parity proof. PR #531's "New migrations are reversible" check is green, but it is vacuous: the step under test was **skipped**, because a PR into `integration/importer` adds no migration directories. No source change is needed. One proof run of the unchanged commit converts this finding to ACCEPT, as described in the closure section below.

- Reviewer: independent T3 subagent, read-only. The requested route was Claude Opus 5.5 / XHigh, because Opus 5 was unavailable. **No telemetry is claimed** for the model or effort actually used.
- Written 2026-09-24 ~17:35Z.
- No worktree, source, commit or push was touched. No PostgreSQL was started. The heavy-slot lock was not taken.
- Writes are confined to this directory, including `tmp/`.

## Binding

| Field | Value |
|---|---|
| Repo | `BradleyGleavePortfolio/growth-project-backend` |
| Head | `c7a5fe8dd0b82fb2c81847d875e0e03912faff26` |
| Tree | `74b9706497d995bf4bf07744a63793b423e88983` |
| Parent | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8`, which is `integration/importer` and the #530 head |
| PR #531 | `land/prod-ci-1` → `integration/importer`. The remote head is `c7a5fe8d` and the base is `7d2895e1`, both verified through gh. |
| Worktree | `/home/user/workspace/worktrees/prod-ci-1`, branch `prod-ci-1`. Read with `git -C` only, and its status is clean. |

## (1) Identity and scope: PASS

**Identity**

- Author and committer are both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, at 17:21:22Z.
- The commit is unsigned (`%G?`=N), which G05 does not require.
- There is 1 commit on the parent.
- `git interpret-trailers --parse` returns empty, so there are no trailers and no AI attribution.

**Files changed.** Only two files changed:

- `.github/workflows/migration-dry-run.yml`, blob `ee17ac1`→`7599edf`.
- `scripts/release.sh`, blob `c86b3ab`→`9cdf29f`, with mode 100755 kept.

The reviewer's `git diff 7d2895e1 c7a5fe8d` is byte-identical to the builder's `PROD_CI_1.diff` (sha256 `2b0c4d89…`, 116 lines). It is saved as `review_diff.txt`.

**`release.sh` (L5).**

- Removing the one added directive line from HEAD gives exactly the base file.
- The line occurs once, at top level, outside the single-quoted JavaScript. The executed bytes are identical, and `bash -n` passes.
- The directive's scope is the `if`…`fi` compound. The only other single-quoted string in that compound is the `sed` expression `'s/^/[release]   /'`, which contains no `$`, so nothing else is masked.

**Workflow (L6).**

- The workflow YAML was parsed with only the target step's `run:` masked. HEAD equals BASE.
- `migrations-apply`, `migrations-schema-parity`, the top-level keys, the triggers, permissions and concurrency are all equal.
- In `reversibility-check`, the target step's `name`, `if`, and `env` (`NEW_DIRS`) are unchanged, as are all other steps, including the `new_dirs` detection.

**Deploy configuration.** No deploy config was touched. `fly.toml`, `fly-deploy.yml` and the Dockerfile are not in the diff. `release.sh`, which is the Fly `release_command`, changes only by a comment.

## (2) Harness semantics: PASS, apart from the proof gap in (4)

The reviewer read the HEAD step (the `run:` block of workflow lines 532–676) directly, and also ran the extracted step bytes against a stub written by the reviewer, independent of the builder's (`REVIEW_STUB_RUNS.txt`).

**Ordering**

- `ALL_DIRS` comes from `find prisma/migrations -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort`.
- Prisma 6.19.3's `sc()` / listMigrations reads the directory, keeps directories only, and sorts with `path.localeCompare`. The reviewer read this in `s7-r-ready/node_modules/prisma/build/index.js` without modifying it.
- Node 20 `localeCompare` order equals `LC_ALL=C sort` for all 169 directories under `LANG` = `C`, `C.UTF-8`, `en_US.UTF-8` and unset (locale `und`).
- Every name matches `^[0-9]{14}_[a-z0-9_]*$`, and every directory has `migration.sql`.
- The string forms match `NEW_DIRS` exactly (`prisma/migrations/<name>`).

**Downs run newest-first; ups run oldest-first**

- The down loop is `for (( i=${#CHAIN[@]}-1; i>=0; i-- ))`, where `CHAIN[0]` is X. It runs newest first, down to X.
- The up loop is `for mig in "${CHAIN[@]}"`, which runs from X up to the newest, in ascending order.
- The stub run T1 shows R→B→E→17→1224 downs followed by 1224→17→E→B→R ups for the chain of 5, and R→B→E downs followed by E→B→R ups for E.

**Fails closed on every required case**

| Case | Result | Evidence |
|---|---|---|
| Missing later `down.sql` | Explicit FAIL naming each missing directory; the IRREVERSIBLE directory itself still reports OK | T3 |
| Refusing down (any position) | FAIL | T4 |
| Failed re-apply | FAIL | T5 |
| Dump diff (over-drop) | FAIL for every chain containing it | T6 |
| X not in the listing, or an empty listing | FAIL | the `idx=-1` path |
| `find` failure | The process-substitution failure produces an empty `ALL_DIRS`, so FAIL | |

**IRREVERSIBLE and "neither" paths.** Both are unchanged in the bytes. T3 shows the IRREVERSIBLE path OK and the "neither" path FAIL.

**`set -euo pipefail`**

- Every psql call sits in an `if !` condition.
- The arithmetic `for` loop is not subject to errexit.
- `"${CHAIN[@]:1}"` on a 1-element array, and `"${!ALL_DIRS[@]}"` on an empty array, are safe under `-u` in bash 4.4 and later. The runner has bash 5.x.
- Each `continue` or `break` targets the intended loop. `continue` acts on the outer `while`, and `break` exits only the inner `for`.
- `dump_normalized` and reset failures abort non-zero. This is pre-existing and fails closed.
- The stub ran under `bash -e -o pipefail`.

**Empty `NEW_DIRS`.** The step is gated by `if: new_dirs != ''`, which is unchanged. Blank-line input exits 0 (T8), which is the same as before.

**At least as strict (argued)**

- For the newest X, the procedure is identical to the old one.
- For an older X, every assertion the old step made is kept: X.down applies, X.migration re-applies, and the whole-schema dump is byte-identical. The new step adds three assertions: later downs exist, later downs apply, and later ups re-apply.
- So on every input the old gate passed, the new gate either passes or fails more.
- The only relaxation is on inputs the old gate **failed** purely because X.down ran out of order at the tip. That set includes the designed G2 refusals, which are the target of this change, and theoretical out-of-order cascade damage (see C-2).

**Real PG15 behaviour is plausible from reading the SQL, but not proven**

- In chain order:
  - R.down removes NOT NULL, the CHECKs and the wide indexes;
  - B.down's `NOT attnotnull` prerequisite then holds;
  - E.down's no-constraint prerequisite then holds.
- `ExtensionPairCode.import_intent_id` and `ScoutReconstructionLedger.source_platform` have no later columns on their tables, so column order is preserved.
- The old gate already passed 1224, 17 and R at the tip with psql re-apply.

This is reasoning only; the proof is item (4).

## (3) Lint: PASS (local, with tools verified against official releases)

**Tool provenance**

- shellcheck 0.9.0: the reviewer downloaded the official `koalaman/shellcheck` v0.9.0 asset, and its sha256 is `700324c6…`, equal to the tarball in `/tmp/prod-ci-1-tools`. The binary was extracted fresh.
- actionlint 1.7.7: the tarball's sha256 `023070a2…` equals the official `actionlint_1.7.7_checksums.txt` entry. 1.7.7 is the version the CI pins.
- CI's shellcheck is 0.9.0, per `ci_530_shellcheck_job.log`.

The runs were made on `git archive` exports of HEAD and BASE, not on the worktree. Receipts are in `REVIEW_LINT_RECEIPTS.txt`.

| # | Check | Result |
|---|---|---|
| L1 | CI replica: shellcheck 0.9.0 on all 10 `scripts/*.sh` at HEAD | rc=0 |
| L2 | Same on BASE | rc=1, SC2016 at `release.sh:326`. This reproduces #530. |
| L3 | actionlint 1.7.7 on the whole repo at HEAD, with shellcheck 0.9.0 first on PATH | rc=0 |
| L4 | Same at BASE | rc=0 |
| L7 | Extracted step: `bash -n`, and shellcheck 0.9.0 `-s bash` | rc=0 |
| L8 | Negative control on a reviewer copy: unquoting `${CHAIN[@]:1}` | actionlint reports SC2068 at `migration-dry-run.yml:532`, rc=1. The edited step really does pass through shellcheck. |

## (4) Remote CI on PR #531

These results were read at 17:33Z. Evidence is in `ci_531_checks.txt` and `ci_531_reversibility_job.log`.

- **"New migrations are reversible"**: run `36034106107`, job `107750237649`, head `c7a5fe8d`, event `pull_request`. Its conclusion is **success**, but the step "Enforce reversibility + prove schema parity on each NEW migration" is **completed/skipped**.
  - The log line reads: `No new migration directories in this PR. Skipping.`
  - There are **zero per-migration OK lines**.
- Every other #531 check passed: Forward migrations apply, Schema parity (informational), build-and-test, rls-live-tests, mwb-3-live-tests, rls-floor-guard, npm audit, test-deploy-readiness, comment-deploy-readiness and size-label. `deploy-readiness-gate` was skipped.
- `infra-lint` (shellcheck and actionlint) **did not run** on #531, because it triggers only on PRs to `main`.
- The job completed at 17:26:41Z. There was no reason to poll further, because no other run will exercise the step on #531 without a new push.

## Findings

### PROD-CI-1-F1: B (proof-invalidating). The remote real-PG15 gate for the new harness never executed.

**Concrete harm**

- The acceptance gate named in the grant is "remote CI green on that PR". On #531 that green is produced by a skipped step. `github.event.pull_request.base.sha` is `7d2895e1`, which already contains all five new migrations, so `NEW_DIRS` is empty and the changed code never ran against PostgreSQL.
- Under G07, a skipped check is not success.
- Under the owner's autonomous-landing amendment, landing requires that "its real database or runtime proof has passed".
- Accepting on this evidence would certify an untested harness. The first real execution would then be the production-decision PR #530.
- There is no false-green risk to production, because #530 would fail closed.

**Decision blocked:** PROD-CI-1 acceptance and its landing on `integration/importer`. Nothing else is blocked: not #530's other checks, and not any importer or UX lane.

**Minimum closure.** Run the unchanged commit once on real PG15 against the #530 migration set. No source change and no new bytes are needed.

1. Open a **draft, proof-only PR** from `land/prod-ci-1` into `main`, titled "PROOF ONLY — DO NOT MERGE".
   - GitHub allows a second PR from the same head to a different base.
   - The `gh api compare main...c7a5fe8d` call shows merge base `c23b9d9f` (the `main` tip) and exactly the five added `migration.sql` files: 20261224, 20270117, 20270118, 20270119 and 20270120. That is the same set as #530.
   - This is not a production action. `fly-deploy.yml` is `workflow_dispatch`-only, and PR events on `main` only run CI, Danger comments and labels.
   - The same PR also runs `infra-lint`, which gives the remote shellcheck 0.9.0 and actionlint proof as a bonus.
2. Require all of the following:
   - "New migrations are reversible" concludes **success**;
   - the Enforce step actually **executed** (not skipped) and prints `Found 5 new migration directories`;
   - there are exactly five lines `OK: schema is byte-identical after forward → down chain → forward.`, one per directory;
   - there are no `FAIL` lines.
3. Close the proof PR without merging.

**Execution unlocked:** once the proof is green, this review converts to **ACCEPT with no re-review**, because the bytes are unchanged. After that:

- #531 lands on `integration/importer`, and #530 re-runs;
- if `integration/importer` fast-forwards to `c7a5fe8d`, #530's head and base equal the proof PR's, so that evidence is directly reusable.

If the proof run fails, that failure is new product evidence about the G2 down chain on PG15. Classify it then; do not reclassify this finding.

### C findings: record, qualify and continue

**C-1: the builder's "masking gap" is independently confirmed as C.**

The gap is this: byte parity is observed only after the later ups re-apply. So an over-drop by X.down of an object older than the chain, which a later *idempotent* `migration.sql` re-creates, would be missed. The stub run T7 reproduces this model. It has no concrete harm to the production decision, for four reasons:

1. The class is pre-existing. The old gate had the same blind spot through X's own up. The widened set of maskers only adds ups that are newer than X.
2. For #530's actual chains, no later `migration.sql` contains an idempotent construct aimed at an object outside the chain.
   - The 17, E, B and R ups use non-idempotent CREATE and ADD statements.
   - E, B and R actively RAISE when the pre-existing RLS, narrow index or column shape is wrong, so an over-drop would fail loudly rather than be masked.
   - 20261224's up is idempotent, but it is the oldest new directory, so it can only mask inside its own check. That is the same as the old gate.
3. Every new directory still gets its own check, in which only its own up and later ups can mask.
4. Production has a secondary net: `release.sh` step 4 runs the `verify.sql` catalog verifiers after any rollback (deploy runbook §5).

The optional closure (an intermediate dump at X's own position) is **not** required.

**C-2: relaxation for out-of-order downs.**

- The new gate no longer detects damage that appears only when X.down runs at the tip while later migrations are still applied, such as a CASCADE into later objects.
- That is not a valid rollback order. The staged downs refuse it by design, and the runbook re-applies forward after a hand reversal.
- This relaxation is exactly the change the grant specifies.

**C-3: remote infra-lint absent on #531.**

- The local proof with official-hash-verified, CI-pinned binaries is clean (L1, L3).
- The remote run happens on the proof PR from F1 and on #530.

**C-4: stale header comment (the builder's C-2).** File-header item 4 still describes the single-directory procedure. Agreed as C.

**C-5: future sort divergence.** The order is identical today. Only names outside `[0-9_a-z]` could diverge between `LC_ALL=C sort` and `localeCompare`. A divergence would move a directory into or out of a chain, which gives either a conservative FAIL or the old single-directory check.

**C-6: builder notes recorded, not reopened.** These are the builder's C-3 (a later IRREVERSIBLE directory now always FAILs, which is conservative), C-4 (hook exclusions) and C-5 (the Lefthook shim sync in the common git dir).

## Artifacts (this directory)

| File | Contents |
|---|---|
| `review_diff.txt` | Reviewer-generated diff, byte-identical to the builder's |
| `REVIEW_LINT_RECEIPTS.txt` | L1–L8 |
| `REVIEW_STUB_RUNS.txt` | T1–T9, plus the call-order traces |
| `ci_531_checks.txt` | PR #531 checks and step conclusions |
| `ci_531_reversibility_job.log` | The #531 reversibility job log |
| `tmp/` | Exports, verified tool binaries, the stub (`stubrun/bin/stubdb.py`), extracted step scripts and order files |
