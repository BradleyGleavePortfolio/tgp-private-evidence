# L2-2 disposition: S8-G (820ce85b) composed onto M2 (9497ca52)

Tier T3, nonproduction. Prepared 2026-09-25 for LAND-PREP-S8G. The analysis uses source only: no lock, no Jest, no push.

## Inputs (real bytes)
- **M2** = `9497ca5275938c9228c6ec6fa0dfa8c34f39f724`, tree `737c34a3b50cb823c9317d13e1b23797127338b9`. This is integration/importer after the S9-A landing (PR #543). Its parents are M 62471b11 and S9-A be88909f.
- **S8-G** = `820ce85be2ebf994112afbb90739eb9469ad628e`, tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`.
  - Its only parent is M `62471b116267fdec6746073c4b4c80a154d09834`.
  - Author and committer are both Bradley; the message is clean and has no trailers.
  - The candidate came from the evidence bundle `landing/bundles/s8g-820ce85be2eb.bundle` (sha256 `3013bae3500a6ab121945580ed2b979881ce0515e2be7bad4ab9d7ef44bf9826`). It was created read-only from clone `1910a060-s8g`, branch `exec1910/s8g`, covering the range `62471b11..exec1910/s8g`, and it verifies okay.
  - All 14 S8-G blobs equal the `blob` lines of `s8g/gate/attempt-4/HEAD-820ce85be2eb.txt` (sha256 `6beeee55…`). The name-status equals `attempt-4/MANIFEST-name-status-62471b116267-to-820ce85be2eb.txt`.
  - `diff --raw --no-abbrev M S8-G` has sha256 `d904d40c…`.
- **merge-base(M2, S8-G)** = M.
- **Predicted tree T** = `60214a647a0a28270deaa85ba7e65da4cb9e3556`:
  - `git merge-tree --write-tree` returned rc 0 in both orders.
  - `diff --raw M2 T` == `diff --raw M 820ce85b`: the 14 S8-G paths, byte-identical.
  - `diff --raw 820ce85b T` == `diff --raw M M2`: the 4 S9-A paths, byte-identical.
  - No path appears on both sides, and the contract blob is unchanged (`8ebf936a`).
- **The two sides:**
  - Side X (tip side) is S9-A, listed in `s8g-side-m2-paths.txt` (4 paths, all in `src|test/scout/reconciliation/`).
  - Side Y is S8-G, listed in `s8g-side-s8g-paths.txt` (14 paths): 2 changed files (`src/scout/lifecycle/lifecycle.service.ts` and `src/scout/scout-reconstruct.service.ts`), plus 12 new files under `src/scout/reconstruct/orchestration/`, `test/scout/orchestration/`, `test/utils/g2-s8g-*` and `test/rls-g2-s8g.spec.ts`.
  - S8-G touches none of `prisma/`, `docs/`, `package.json` or `package-lock.json`.

## Mechanical selection
I ran `select_suites.py <T> X Y` on the extracted real tree T, then again with X and Y reversed. The outputs are `s8g-selection-onto-M2-real.txt` and `s8g-selection-onto-M2-real-reversed.txt`.

Both directions select the same **41** default-config specs. That is the same 41-spec set as the S9-A composition. The script's read-only `classify` run reproduces it (`run/s8g-classify-20260925T224716Z/selection-conservative.txt`, 41 / 41).

## Import-closure check (both directions)
- **What S9-A imports.** `src/scout/reconciliation/*` and its spec import only:
  - `./coverage` and `./types`;
  - `../lifecycle/arbiter` and `../lifecycle/reason-codes`.

  `arbiter` imports only `../scout.dto`, `./reason-codes` and `@nestjs/common`. S8-G changes none of these files.
- **What S8-G imports.** The orchestration sources and specs, `lifecycle.service.ts` and `scout-reconstruct.service.ts` import only:
  - analytics, prisma.service and scout DTOs;
  - `reconstruct/{families,mapping-spec,source-mapper-registry}`;
  - `lifecycle/{arbiter,lifecycle.dto,reason-codes}`;
  - scout-platform and the orchestration modules.

  None of these is an S9-A path. Nothing outside `src|test/scout/reconciliation/` imports `src/scout/reconciliation/*`.
- **Result:** the import closures are disjoint. S9-A bytes and S8-G bytes meet only in suites that read the file system.

## Manual disposition of the 41 hits

### MUST-RUN: real-repo walkers whose inputs include both sides' bytes
Each of these reads the real `src/` tree of the composed checkout. On T that tree contains both the new `src/scout/reconciliation/*.ts` (S9-A) and the changed `lifecycle.service.ts`, `scout-reconstruct.service.ts` and new `reconstruct/orchestration/*.ts` (S8-G).

| Spec | Why its input set changes |
|---|---|
| `test/deploy-readiness.spec.ts` | `scanAllStubRoots(REPO_ROOT)` walks `src/`, and the provider import scan runs over it. |
| `test/prod-readiness/env-discovery.spec.ts` | Its test "round-trips the REAL src/ tree" (`discoverEnvVars` over the repo). |
| `test/prod-readiness/operator-keys-artifact.spec.ts` | `assembleOperatorKeysInput({repoRoot})` calls `scanProvidersFromProcess`, which walks `src` imports, and then does the drift check. |
| `test/route-doc-drift.spec.ts` | Walks `src` and `scripts`, reading every `.ts` file. |
| `test/scout/reconstruct/mapping-spec.third-source.spec.ts` | Walks all of `src`, reading every `.ts` file. It also imports S8-G's changed modules (closure-Y). |

### CONSERVATIVE ADDS: cheap, same Jest invocation
| Spec | Reason |
|---|---|
| `test/scout/reconciliation/reconcile.spec.ts` | S9-A's own suite. Its closure is disjoint from S8-G, but it takes about 1 s. |
| `test/dunning-v2-lockout-allowlist-route-table.spec.ts` | A controller-only walker. Neither side adds a controller. Kept for continuity with S8-F and S9-A. |
| `test/scout/orchestration/family-plan.spec.ts` | S8-G's own default-config suite. Its closure is disjoint from S9-A. |
| `test/scout/orchestration/reconstruct-run.spec.ts` | Same as `family-plan.spec.ts`. |
| `test/scout/orchestration/settle-hook.spec.ts` | Same as `family-plan.spec.ts`. |
| `test/scout/g2-s8g-db-guard.spec.ts` | S8-G's pure guard suite. It reads named S8-G files, `lifecycle.service.ts` and the migrations directory, which neither side changes. Its candidate-head checks are parameterised, so they do not depend on the checked-out HEAD. |

`test/rls-g2-s8g.spec.ts` is an `rls-*` PG suite and is excluded from the default config. Its PG proof is pending and is out of scope here.

### EXCLUDED: inputs unchanged by the composition
These are the other 35 of the 41 hits (41 minus the 5 must-run walkers and `dunning-v2-lockout-allowlist-route-table`, which is itself one of the 41), with the same reasons as in `L2-2-DISPOSITION-S9A.md` § EXCLUDED. None of them reads `src/scout/reconciliation/*`. The groups are:
- specs that read fixed named files;
- specs that use mkdtemp repos, fixtures or mocks;
- specs that read named directories neither side changes: `mapping-spec.spec` reads `SOURCE_SPECS_DIR` and a non-recursive `readdirSync` of `src/scout/reconstruct/*.ts`, and `native-families` reads `reconstruct/native`;
- PG/live helpers that read one migration SQL file, and no migration changes.

For every excluded spec, the S9-A side contributes no input bytes, so its input set is the same on T as on M+S8-G. That tree already passed S8-G's full default-config Jest.

## Prior evidence
- **S8-G gate, attempt 4, full default-config Jest on M+S8-G** (`s8g/gate/attempt-4/jest-full.raw.log`): 577 suites passed and 12 skipped, out of 589; 9111 tests passed. That includes all 4 S8-G default-config specs and `deploy-readiness`.
- **The S9-A composition run** (`run/s9a-compose-20260925T222804Z`): the 7 S9-A-era suites passed on M2 (385 passed, 1 skipped).
- **Not yet observed:** the must-run set on T, where both sides are present. Compose runs that set once.

## Must-run list
The list is `s8g-must-run-suites.txt`, 11 files, identical to `SUITES` in `../land-s8g-1910.sh`. Compose runs it once, under the lock, after the merge is staged (tree == T) and before the hooked commit. It uses the default config, no PG and no retry:

```
./node_modules/.bin/jest --ci --runInBand --runTestsByPath <11 files>
```
