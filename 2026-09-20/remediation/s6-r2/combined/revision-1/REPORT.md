# S6 final candidate — composition and cumulative validation packet

Scope of this packet: composition of the two S6 R2 lane heads into one candidate and the cumulative validation evidence for that exact head. **Tested, not audited. No merge, deployment, enablement, acceptance or clearance is claimed.** Audit findings are not part of this packet; the parent publishes dispositions separately.

Operator: T4 fixer/validator (requested routing: Claude Fable 5 High; the tool identity is not independently verifiable from inside the session). No source changes were made beyond the merge itself.

## Exact binding

| Item | Value |
|---|---|
| Repo | `https://github.com/BradleyGleavePortfolio/growth-project-mobile.git` |
| Branch / worktree | `execute/20260920-s6-final-r2` in `/home/user/workspace/worktrees/s6-final` |
| **Combined head** | **`55db31a0696ebd07d0cb9abb18ffd31dce29457d`** |
| **Tree** | **`130ef9bfdcdbc038b87466529f5980e759f3451a`** |
| Merge parents (exact, `--no-ff`) | `eaccaba98bc4400a0341bcd80409ab317bc85856` (pairing lane: `execute/20260920-s6-r2`) + `d7079265ea1263a1af6cd9cd132fc18dcb1793d9` (export lane: `execute/20260920-s6-export-r2`) |
| Common ancestor of the two lanes | `60975b51bd617bbfaa091ce76e57d16945298f82` |
| Public main (untouched) | `a5933fd6de5616493de75f0db907098b149b955c` |
| Merge commit identity | author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; trailers empty (`git var` checked before the merge, `git log` after) |
| Merge content | 3 files from the export lane only (`src/storage/mmkv.ts`, `src/storage/__tests__/mmkv.test.ts`, `src/config/__tests__/declaredDependencies.test.ts`, +362/−19); no conflicts; lanes touched disjoint files |
| Lineage `a5933fd6..55db31a` | 14 commits: 7 authored/committed `Bradley Gleave`, 7 preserved PR commits authored `BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com>` (pre-existing lineage, unchanged) |
| Working tree | clean before and after every stage (`STATUS_SHORT_LINES=0` in each `.STAMP`) |
| Push / PR / merge to main / hosted / native / activation | none |
| Source bundle | `s6-final-r2.bundle` = `a5933fd6..execute/20260920-s6-final-r2`; `git bundle verify` okay against the local clone and against a bare clone of `main` (requires only public main) |

## Environment (identical for every stage; see each `.STAMP`)

- Node `v22.13.1`, npm `10.9.2` from the sha256-verified tarball in `execution/s6-mobile-r2/toolchain` (CI uses Node 22.13); jest 29.7.0; `NODE_OPTIONS` unset; `CI=true`.
- `node_modules` is a read-only symlink to the `npm ci` tree produced in `/home/user/workspace/worktrees/s6` (`logs/00-npm-ci.log` of the pairing packet, exit 0, 1099 packages). Applicability asserted: `package.json` and `package-lock.json` at `55db31a` are byte-identical to that source tree (sha256 `63e2e2e2…30d5f` / `840be0b8…e6b69`, recorded in every stamp). No dependency mutation. **No `react-native-mmkv` stub** (`MMKV_STUB_PRESENT=no` in every stamp); the package is absent, as intended by the source.
- The symlink is excluded from status via `repos/mobile/.git/info/exclude` (`/node_modules`), a local uncommitted exclude, so that "clean" is honest and not a suppression of a tracked change.
- Sandbox 2 CPU / 8 GB; all stages serialized under `/home/user/workspace/execution/test-validation.lock` (acquired non-blocking after the export lane released it at 22:26:19Z; released at run end).

## Results at `55db31a` / tree `130ef9bf` (harness `run-final.sh`, exit 0, `FAILURES=0`)

| Stage | Command | Child exit | Result | Start → End (UTC) | Evidence |
|---|---|---|---|---|---|
| 00 | `git merge --no-ff … d7079265` | 0 | parents and identity asserted | 22:29:32 → 22:29:34 | `logs/00-merge.log` |
| 01 | `npm run validate:config` | 0 | OK (2 pre-existing warnings: null Play Store URL, assetlinks placeholder) | 22:29:34 → 22:29:34 | `logs/01-validate-config.log` + `.STAMP` |
| 02 | `npm run lint` | 0 | 0 errors, 75 pre-existing warnings | 22:29:34 → 22:29:49 | `logs/02-lint.log` + `.STAMP` |
| 03 | `npx tsc --noEmit` | 0 | no output | 22:29:50 → 22:30:15 | `logs/03-tsc.log` + `.STAMP` |
| 04 | `timeout 660 npx jest --ci` (no `--forceExit`) | **0** | **308/308 suites, 3839/3839 tests PASS** in 119.1 s; "Jest did not exit one second after the test run has completed" warning; process then **exited naturally** (timeout did not fire) | 22:30:15 → 22:37:07 | `logs/04-jest-full.log` + `.STAMP` |
| 05 | `NODE_ENV=production EXPO_PUBLIC_FF_EXTENSION_IMPORT=true npx expo export --platform android --no-bytecode --clear` (isolated `TMPDIR=tmp-flag-on`, "Bundler cache is empty") | 0 | Android bundled, 3019 modules, 81.7 s | 22:37:08 → 22:38:31 | `logs/05-export-flag-on.log` + `.STAMP`; `export-flag-on/` |
| 06 | residue assertions on 05 | 0 | exactly 1 bundle `index-90dbc33d85df2d559e3af4c7be91043b.js` (7,092,246 B, sha256 `43c981f2b9f611113359806775b8f278b57833f700ca45eb9837c9067ddb59d8`); computed `process.env[` = 0; `process.env.EXPO_PUBLIC_FF_*` reader residue = 0; flag table `EXPO_PUBLIC_FF_EXTENSION_IMPORT:"true"`, `EXPO_PUBLIC_FF_IMPORT_REVIEW:void 0`; `metadata.json` present | — | `logs/06-residue-flag-on.log` + `.STAMP` |
| 07 | `NODE_ENV=production` with both flags unset, `npx expo export --platform android --no-bytecode --clear` (separate isolated `TMPDIR=tmp-flags-unset`) | 0 | Android bundled | 22:38:32 → 22:39:54 | `logs/07-export-flags-unset.log` + `.STAMP`; `export-flags-unset/` |
| 08 | residue assertions on 07 | 0 | exactly 1 bundle `index-75c06ea77c8db96a23c22b882d45d1aa.js` (sha256 `0aa77c1f245b11bd52143e1e4a13b9ca53c6254df7f4746e0caf0a24e48f2dbe`); computed reads 0; reader residue 0; `EXPO_PUBLIC_FF_EXTENSION_IMPORT:void 0`, `EXPO_PUBLIC_FF_IMPORT_REVIEW:void 0` (defaults OFF) | — | `logs/08-residue-flags-unset.log` + `.STAMP` |

Notes on the bundles:
- Both exports are authentic: unmodified source at `55db31a`, no stub, no resolver override, cold isolated Metro caches. The `react-native-mmkv` specifier appears once in each bundle inside the Metro-optional `try { require(...) }` (`e=r(d[2],"react-native-mmkv")` → catch → `null`), matching the export lane's design; the AsyncStorage shim path is what the bundle takes at runtime. Runtime behaviour of the bundle is **not** exercised in this packet (bundle-time evidence only).
- The only `process.env.EXPO_PUBLIC*` text remaining in either bundle is Expo's own runtime check for `EXPO_PUBLIC_USE_RN_FETCH` inside `node_modules`; it is not an app flag reader and is listed informationally.
- The two bundles differ (different content hashes) solely by the inlined flag values, as expected.

## What this packet does and does not establish

- Establishes: at exactly `55db31a` / `130ef9bf`, with the stated toolchain, the repository's own static checks and full test suite pass, the process exits naturally, and authentic release-mode Android exports succeed with flags inlined as configured and defaulting OFF when unset.
- Does not establish: audit clearance, correctness of the product journeys on a device, EAS/hosted build behaviour or hosted environment-variable inventory (UNKNOWN, no hosted access), store readiness (the two `validate:config` warnings remain), or customer proof. Not merged, not pushed, not deployed, not enabled.
- Lane-level evidence (design rationale, dispositions, earlier failed runs) lives in the two lane packets and is not restated here.

## Files in this packet (checksums in `SHA256SUMS`)

`REPORT.md`, `PREP.md`, `run-final.sh`, `run-final.out`, `logs/*` (all `.log` and `.STAMP` files and `summary.txt`), `s6-final-r2.bundle`, `export-flag-on/_expo/static/js/android/index-90dbc33d85df2d559e3af4c7be91043b.js`, `export-flag-on/metadata.json`, `export-flags-unset/_expo/static/js/android/index-75c06ea77c8db96a23c22b882d45d1aa.js`, `export-flags-unset/metadata.json`. Excluded from the manifest: Metro cache directories (`tmp-flag-on/`, `tmp-flags-unset/`), exported font/image assets, `node_modules`.
