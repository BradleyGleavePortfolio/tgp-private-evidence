# S6 export blocker fixer — REPORT (execution/s6-export-r2)

Status: **implemented, locally tested, frozen.** NOT audited, NOT merged, NOT pushed, NOT deployed, NOT enabled. No self-audit or merge clearance is claimed. Independent R2 audit and parent composition pending.

## Identity (honest)
- Runtime worker: Claude Fable 5 via catalog id `claude_fable_5` (brief asked "Fable5 High"; the catalog exposes no "5.1"). Same identity the prior S6 worker reported.
- Git identity used: author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` (from `repos/mobile/.git/config`; no `GIT_*` identity env; no trailers, no signoff, no template). Verified in `FINAL-HEAD.STAMP`.

## Exact head
| | value |
|---|---|
| Lane | `/home/user/workspace/worktrees/s6-export`, branch `execute/20260920-s6-export-r2` |
| Base (unchanged) | `60975b51bd617bbfaa091ce76e57d16945298f82` (tree `901f0f4f…`) |
| **New head** | **`d7079265ea1263a1af6cd9cd132fc18dcb1793d9`** |
| **Tree** | **`402a7425862639863b951ffb7da7ed2872ff70f5`** |
| Commits added | exactly 1 (`storage: make react-native-mmkv a bundle-safe optional dependency`) |
| Public main ancestor | `a5933fd6de5616493de75f0db907098b149b955c` (yes) |
| Final clean state | `git status --short --untracked-files=all` = 0 lines after removing the read-only `node_modules` symlink (`FINAL-HEAD.STAMP`, 22:27:41Z) |
| Bundle | `s6-export-r2.bundle` (`a5933fd6..execute/20260920-s6-export-r2`, verified OK against `repos/mobile`; requires only public main). Also `s6-export-r2-d7079265.patch`. |
| Other lanes | `/worktrees/s6` untouched (status 0 lines; its head moved to `eaccaba98` by the pairing fixer, not by this lane). No pushes/PRs/hosted/EAS/deploy/store/activation. |

Files changed (3, +362/−19):
- `src/storage/mmkv.ts` (+85/−19) — the fix.
- `src/config/__tests__/declaredDependencies.test.ts` (+175) — guard hardening + truthful comment.
- `src/storage/__tests__/mmkv.test.ts` (+121, new).
No changes to `package.json`, `package-lock.json`, `metro.config.js`, babel, flags, C1 consumers, Roman, auth/logout code, or any native config.

## Root cause (verified in installed Metro / @expo/metro-config sources under `/worktrees/s6/node_modules`)
1. `@expo/metro-config/build/ExpoMetroConfig.js:310` enables `transformer.allowOptionalDependencies: true`.
2. `collect-dependencies.js` `isOptionalDependency` (~525): a `require()` is optional only when it is a statement directly inside a `TryStatement.block` (walk ≤3 statements up).
3. `collect-dependencies.js` `DependencyRegistry.registerDependency` (~742): an already-optional dependency is **demoted to required** when another occurrence of the same specifier is non-optional.
4. `src/storage/mmkv.ts` at `60975b5` required `react-native-mmkv` twice: the guarded probe (line 34) and an **unguarded** `const { MMKV } = require('react-native-mmkv')` in the `MmkvStorage` constructor (line 103). The constructor's require demoted the dependency; Metro reported the *first* location (line 34), which is why the try/catch looked sufficient. Reproduced independently by the negative-guard run (`logs/04`, old file shape flagged at line 103).
5. Unresolved optional deps get a `null` module id in the dependency map (`Serializers/helpers/js.js`) and metro-runtime's `require(null)` throws → the `catch` selects the AsyncStorage shim. No `metro.config.js` change required.

## Design (smallest bundle-safe change; no security/native behaviour change)
- Exactly one `require('react-native-mmkv')`, a plain statement directly inside a `try` in `loadOptionalMmkv()`; the `Platform.OS === 'web'` / `NODE_ENV === 'test'` early returns are kept.
- Result is shape-checked by exported `asMmkvModule(candidate)`: only a module exposing an `MMKV` constructor counts (so a Metro `empty` stub `{}` is *unavailable* instead of crashing on `new MMKV`).
- `MmkvStorage` constructor takes the loaded module; it no longer requires anything. `makeStorage` uses the module resolved once at load. `isMmkvAvailable()` is now exported and reads that value (never inferred).
- `AsyncStorageShim`, namespaces `prefs:`/`cache:`/`secure:`, `clearAllStorage` (sign-out wipe), export names, and the MMKV path's config (including its encryption key line) are unchanged. `@typescript-eslint/no-explicit-any` escape removed (typed `MmkvInstance`).
- Guard test: the stale comment claiming try/catch alone protects Metro is replaced with the truthful Metro condition; new suite `optional undeclared packages are required in the shape Metro treats as optional` parses shipped source with the TypeScript parser mirroring Metro's walk (fixture-validated: guarded lines 4/12, unguarded 19/24; static import / re-export / dynamic import → unguarded), asserts zero unguarded occurrences, exactly one require site, and that the package remains absent from `package.json` and the lockfile.

Scope note: no security-behaviour change was made, so none needed pre-reporting. The false "random Keychain key" comment on the MMKV path was deliberately **not** edited and the path was **not** activated (see residuals).

## Proof table
| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | `npm run lint` | exit 0; 0 errors, 75 pre-existing warnings, none in touched files | `logs/01-lint.log` |
| 2 | `npx tsc --noEmit` | exit 0, no output | `logs/02-tsc.log` |
| 3 | Focused Jest (storage, config guards, authActions, signOut, queryClient.signout, lib, navigation, biometricLock, firstPaymentGate, MessagesScreenCache) — dirty tree | 32 suites / 424 tests pass | `logs/03-jest-focused.log` |
| 4 | Negative guard: old `mmkv.ts` shape dropped into `src/storage/` temporarily | guard FAILS as intended (unguarded site line 103; 3 sites ≠ 1); file removed, tree restored | `logs/04-negative-guard-old-shape-EXPECTED-FAIL.log` |
| 5 | Preconditions: no stub, undeclared, absent from lockfile, node_modules symlink target | `MMKV_STUB_PRESENT=no`, declared 0, lockfile 0 | `logs/10-export-preconditions.log` |
| 6 | Authentic cold-cache Android export, `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true NODE_ENV=production`, private `TMPDIR` + `--clear` | **exit 0**, 3019 modules, 83.9 s, "Bundler cache is empty" | `logs/11-expo-export-android-flag-on.log` |
| 7 | Residue (flag ON) | `process.env[` 0; only `process.env.EXPO_PUBLIC_USE_RN_FETCH` (2, pre-existing); flag table `EXPO_PUBLIC_FF_EXTENSION_IMPORT:"true"`, `IMPORT_REVIEW:void 0`; `react-native-mmkv` appears once, inside `try{e=r(d[2],"react-native-mmkv")}catch{return null}`; module 1120 dependency map `[716,3,null]` | `logs/12-residue-flag-on.log`, `logs/16-…extracted.js` |
| 8 | Authentic cold-cache export, flags unset | **exit 0**; table `EXPO_PUBLIC_FF_EXTENSION_IMPORT:void 0`; same single guarded require | `logs/13-…`, `logs/13a-…env-check.log`, `logs/14-residue-flags-unset.log` |
| 9 | Serialized module 1120 executed with `require(null)` throwing (hand-rolled) | `isMmkvAvailable()` false, sync `getString` undefined, writes `prefs:user`/`secure:pin`, `clearAllStorage` removes 3 namespaces and leaves `other` — PASS | `logs/17-bundle-runtime-fallback-smoke.{cjs,log}` |
| 10 | Same module under the **real** `metro-runtime/src/polyfills/require.js` (production mode) | module initialises without throwing; `isMmkvAvailable()` false; shim + logout wipe correct — PASS | `logs/18-bundle-metro-runtime-probe.{cjs,log}` |
| 11 | Committed head `d7079265` (diff vs HEAD = 0): focused Jest | 32 / 424 pass | `logs/20-jest-focused-committed-head.log` |
| 12 | Committed head: cold flag-ON export | exit 0; bundle SHA256 `5c852891…` **identical** to the dirty-tree flag-ON bundle → tracked content identical | `logs/21-…`, `logs/22-…` |
| 13 | Env stamp + s6 lane untouched | Node v22.13.1, npm 10.9.2, Jest 29.7.0, expo CLI 56.1.16; s6 status 0 lines | `logs/23-final-env-stamp.log`, `FINAL-HEAD.STAMP` |
| 14 | Post-export: no stub created, tree clean | `stub present after export: no`; final status 0 lines | `logs/15-post-export-state.log`, `FINAL-HEAD.STAMP` |

Dirty-tree vs committed-head evidence is kept distinct: logs 01–18 ran on the uncommitted working tree (content later committed unchanged, bundle hash equality in #12 proves identity); logs 20–23 ran on the committed head. The flags-unset export (#8) ran only on the dirty tree; given identical tracked content and identical flag-ON bundle bytes, no transfer beyond that is claimed.

Failed/aborted runs preserved: `logs/04-…EXPECTED-FAIL.log` (intended failure); `logs/14-residue-flags-unset.ATTEMPT1-script-bug-env-u-function.log` + `logs/run-stage2-export.out` (`env -u … run` cannot exec a shell function — my script bug, export B never started in attempt 1); one `LOCK_HELD 22:21:47Z` from another lane in `logs/summary.txt` (retried 22 s later).

Lock discipline: all heavy/moderate runs used `flock -n` on `execution/test-validation.lock`; acquisitions/releases in `logs/lock-holder.txt` (stage1 22:14:43–22:15:59, stage2 22:16:45–22:18:11, stage2b 22:22:09–22:23:28, stage3 22:24:34–22:26:19). Lock is released.

Dependency reuse: gitignored read-only symlink `node_modules → /worktrees/s6/node_modules` (package.json + lockfile byte-identical to that worktree); never written to; removed at freeze. `repos/mobile/.git/info/exclude` already contained `/node_modules` (line 7) — not added by this lane.

## Limitations (explicit)
- **Jest cannot exercise the production `require` catch**: `loadOptionalMmkv()` short-circuits on `NODE_ENV === 'test'`, so the Jest storage tests prove shape detection and the shim/logout contracts, not the runtime catch. That path is covered instead by #9/#10, which run the *actual serialized module from the export* under metro-runtime's real `require` with the null dependency id. This is a Node-side probe of the bundle, not a device.
- Export success + bundle probes are **not native startup proof** (no emulator/device run, no Hermes bytecode run; `--no-bytecode` as in prior evidence).
- No full Jest suite was run in this lane (parent directed: composition runner will run cumulative full suite + authentic exports).
- Web export not exercised (unchanged `Platform.OS === 'web'` early return).

## Residuals (reported, not fixed — out of narrow scope)
1. `src/storage/mmkv.ts` MMKV path still uses the deterministic `encryptionKey: \`tgp-mmkv-enc-${namespace}\`` while the file header claims a random Keychain key. Unchanged, NOT activated, and dead in every current build because the package is undeclared/absent (guard now pins this). A future decision to enable MMKV must fix the key derivation first — security-authority item, not implementation.
2. `AsyncStorageShim.getString` (sync) returns `undefined` by design; `userCache.ts` relies on it (pre-existing). `isMmkvAvailable()` is now exported should callers want to branch truthfully.
3. NEW-2 (full `jest --ci` slow/non-exit) pre-existing; not touched. A3 hosted env: unknown.
4. `process.env.EXPO_PUBLIC_USE_RN_FETCH` remains a dynamic read in the bundle (pre-existing, outside scope).
5. `isMmkvAvailable` became a named export (additive API surface).

## Packet contents
`REPORT.md`, `CHECKPOINT-1.md`, `FINAL-HEAD.STAMP`, `SHA256SUMS` (37 entries), `s6-export-r2.bundle`, `s6-export-r2-d7079265.patch`, `logs/` (all runs, scripts, probes), `export-android-flag-on/`, `export-android-flags-unset/`, `export-android-flag-on-committed-head/` (23 MB each, authentic output dirs).
