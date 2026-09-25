# S8-C composition (LAND-2): CI is red, fast-forward NOT performed

- **Status: STOPPED.** A red check other than class C appeared, so the grant says stop and report.
- **Executor:** `landing_composition_prep`, under grant LAND-2 (`daceddc8/SCOPE.md`, 17:41Z).
- **`integration/importer`:** unchanged at `df713fd9217df524915348ef8a42c797f288dde1` (ls-remote, 17:5xZ).
- **`main`:** unchanged at `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`.

## What completed

| Step | Result |
|---|---|
| Lineage, S8-C `f428db9a` | Anchor `87018a42`, and must-contain `e0cee7e0`, are both ancestors. Post-anchor paths are `test/rls-g2-s8c.spec.ts`, `test/utils/g2-s8c-bootstrap.sh` and `test/utils/g2-s8c-harness.ts`. All three are lane-private and **outside** the import closure of the 27 composition suites (975 files). There are no merges. All 7 commits have Bradley as author and committer, no trailers, and pass the R3 token check. |
| Slot | `flock -n` on inode 674373 was acquired at 17:42:29Z by pid 8985. It was released when the script exited at 17:46:25Z, and the lock file was preserved. |
| Predicted merge | `git merge-tree` of `df713fd9` and `f428db9a` returned rc 0 and tree `36e44e2d4c0acaa5131087973043638909a3e20c`. The only differences from the plan's tree `bb5436dd` are the four lane-private harness paths. The contract blob is `f9109c06`. |
| Merge | Fresh worktree `worktrees/daceddc8-land-s8-c` on branch `land/s8-c` from `df713fd9`. `git merge --no-ff --no-commit f428db9a` produced a staged tree equal to the prediction. Schema sha `0eb41f9a…` matches. |
| Contract | Regenerated with `npm run contract:importer`, S7-L's unchanged generator. The result is **byte-identical** to the textual merge: sha256 `77d5ffd1…`, version `2.0.0-c1-s2.0`. A second cold process with `IMPORTER_CONTRACT_OUT` gave identical output. |
| Affected Jest | 27 of 27 suites passed; 564 tests passed, 1 skipped (`jest --ci --runTestsByPath`, heap 4096). |
| Hooked commit | Genuine lefthook pre-commit passed: prod-readiness-quick, banned-cast-tokens (R75, "no positive token change"), prettier 3.9.9, eslint, and tsc (51 s). The commit-msg hook's no-ai-tokens check passed. |
| Merge commit | **`2542af44ab5b4d296f84e9f5f311632f7f5aeb25`**, tree `36e44e2d…`, parents (`df713fd9`, `f428db9a`). Bradley is author and committer, with no trailers. |
| Export | The script's step 8 refused with rc 80 on `fatal: Refusing to create empty bundle`, because `git bundle create` was given a raw sha rather than a ref tip. This is a script defect (class C). I completed the export by hand with the ref `refs/heads/land/s8-c`; the bundle verified, with head `2542af44 refs/heads/land/s8-c`. I wrote the receipt, `SHA256SUMS` and `state/compose-s8c.env`, and fixed the script. No repository bytes changed. |
| Stage | `land-second.sh stage` pushed `land/s8-c` = `2542af44` (ls-remote verified) and opened PR **#540**, which is **not a draft**. Only `land/s8-c` was pushed; the `-accepted` ref is now opt-in. |

**PR:** [#540](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/540), "Land S8-C: native reconstruct writers, composed with S7-L (f428db9a)". Base `integration/importer`, head `land/s8-c` at `2542af44`. It is open and not merged.

## CI on #540 (head `2542af44`)

Raw data: `pr540-checks.json`, `check-runs-2542af44.json` and `workflow-runs.tsv`.

| Workflow | Check | Result |
|---|---|---|
| CI (run 36169368004) | **build-and-test** | **FAIL.** Lint, tsc and build passed. `npm test`: 571 passed and 1 failed of 572 suites (12 skipped); 8948 passed and **1 failed** of 9113 tests. Log: `build-and-test-108184866662.log`. |
| CI | rls-floor-guard / rls-live-tests / mwb-3-live-tests | pass / pass / pass |
| Dependency Audit | npm audit (high+critical, whole graph) | pass |
| H4 deploy readiness | test-deploy-readiness / comment-deploy-readiness / deploy-readiness-gate | pass / pass / skipping |
| pr-size-labeler | size-label | pass |

Migration Dry-Run did not trigger, which is correct because S8-C's diff against the base adds no migration. Danger and the other main-only checks do not run for this base.

**The failing test** is `test/scout/g2-s8c-db-guard.spec.ts`, case "pins the base head and migration count identically across bootstrap, harness and repository". The assertion at line 154 is `expect(migrations).toHaveLength(EXPECTED_MIGRATIONS)`: it expected 171 and received 172. The next assertion at line 156, `migrations.filter(n => n > S8B_MIGRATION)).toEqual([])`, would also fail.

**Cause.** The spec reads the `prisma/migrations` directory from disk. It asserts that the repository holds exactly the 171 migrations of S8-C's proof base `93389265`, and that none is newer than the S8-B migration. That was true on S8-C alone (`f428db9a`: 171, none after S8-B). On the composition it is false by construction: `df713fd9` and `2542af44` have 172, including S7-L's `20270123000000_scout_run_lifecycle_expand`. The current `integration/importer` tip `df713fd9` is not red, because it does not contain this S8-C spec.

**Why the local 27-suite gate missed it.** Suites were selected by static **import** closure. This spec touches S7-L's bytes through `readdirSync`, not through an import. A search of `M` for `prisma/migrations` and `EXPECTED_MIGRATIONS` pins in default-config specs finds only this spec as count-pinned. `test/ci/delivery-artifact.spec.ts`, `test/invariants/locked_defaults.spec.ts` and `test/wearables/metric-bucket.map.spec.ts` reference migrations but passed in CI.

## Safety-ROI

| # | Class | Harm | Decision blocked | Minimum closure | Unlocked |
|---|---|---|---|---|---|
| L2-1 | **B** (landing-blocking, test-only, no product defect) | Fast-forwarding `2542af44` would turn `integration/importer` CI red: one default-config test fails on every later PR. There is no runtime, schema, contract or data effect. The failing assertion is a lane-local pin of S8-C's proof base (171 migrations, none after S8-B), which composing with S7-L's accepted migration legitimately changes. | The LAND-2 fast-forward of `integration/importer` to the S8-C composition | A one-file, test-only change to `test/scout/g2-s8c-db-guard.spec.ts`, under a parent correction grant. Remove the three repository-scan assertions (lines 148–156), or make them composition-tolerant: the S8-B migration is present, the count is at least 171, and every migration after S8-B belongs to an already-landed lane. The bootstrap and harness pins, which the PG proof itself enforces at proof time, stay unchanged. **Where the change goes (parent's choice):** **(a)** as a hooked Bradley commit on top of `2542af44` on `land/s8-c`. That is a landing-created delta, classified alone under the owner amendment, and the S8-C acceptance of `f428db9a` stands. **Or (b)** as a new S8-C lane commit after `f428db9a`, then recompose. That changes the accepted head. Either way, rerun that spec plus the 27 suites, the hooks and CI. | FF of S8-C, then S9-0, S8-F and S8-G |
| L2-2 | C | The composition suite selection has a method gap: static import closure misses specs that read repository files. | None | For compositions from now on, add to the affected set every default-config spec that reads `prisma/migrations`, `docs/contracts` or `BASE_HEAD` / `EXPECTED_MIGRATIONS` pins. Remote full `npm test` stays the backstop, and it caught this. | Future compositions (S8-F, S8-G) |
| L2-3 | C | Script defect in the bundle step of `compose-second.sh`. | None | Fixed (`$BASE..refs/heads/$BR`). The export was completed by hand and recorded in `run/compose-second-s8c-20260925T174224Z/run.log`. | n/a |
| L2-4 | C | PR #540 is open and not a draft, with red CI, on an unprotected base, so a manual merge-button click is technically possible. | None | Leave it open for the corrected head. LAND-2 did not grant draft conversion, so the parent may convert it. | n/a |

## State preserved

- Worktree `/home/user/workspace/worktrees/daceddc8-land-s8-c` on local branch `land/s8-c` = `2542af44`, clean, with copied `node_modules`.
- Run directory `landing/run/compose-second-s8c-20260925T174224Z/`: `run.log`, merge, contract regeneration logs, Jest raw log, `commit.raw.log`, `export/` containing the bundle, `COMPOSE_RECEIPT.txt` and `SHA256SUMS`.
- Remote `land/s8-c` = `2542af44`.
- PR #540 is open.
- The `land-second.sh ff` step was not run.
