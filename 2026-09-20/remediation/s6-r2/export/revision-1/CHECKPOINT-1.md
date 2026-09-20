# S6 export fixer — checkpoint 1 (22:14 UTC)

Worker identity (honest): Claude Fable 5 via catalog id `claude_fable_5`; the brief's "Fable5 High" maps to this catalog model, "5.1" is not exposed.

Lane: `/home/user/workspace/worktrees/s6-export`, branch `execute/20260920-s6-export-r2`, base `60975b51bd617bbfaa091ce76e57d16945298f82` (tree `901f0f4f…`). Sole writer. `/worktrees/s6` untouched (read-only reuse of its `node_modules` via a gitignored symlink; package.json/package-lock.json byte-identical).

## Root cause (verified against installed Metro / @expo/metro-config sources)
- Expo sets `transformer.allowOptionalDependencies: true` (`@expo/metro-config/build/ExpoMetroConfig.js:310`).
- `isOptionalDependency` (`collect-dependencies.js:525`) marks a require optional only when it is a statement directly inside a `try` block.
- `DependencyRegistry.registerDependency` (`collect-dependencies.js:742`) demotes an optional dependency to required if ANY other occurrence of the same specifier is non-optional.
- `src/storage/mmkv.ts` had TWO `require('react-native-mmkv')`: the guarded probe (line 34) and an UNGUARDED one in the `MmkvStorage` constructor (line ~105). The constructor's require demoted the dependency; Metro reported the first location (line 34), which is why the try/catch looked like it should have worked.
- Unresolved optional deps serialize a `null` module id (`Serializers/helpers/js.js:63`) and `require(null)` throws `Requiring unknown module` at runtime → the catch takes the AsyncStorage fallback. No metro.config change needed.

## Design chosen (smallest, no security/native change)
- Single guarded require, result captured and passed to `MmkvStorage` (constructor no longer requires).
- Truthful shape check `asMmkvModule()` — only a module with an `MMKV` constructor is "available"; `{}` (Metro empty stub) is unavailable.
- `isMmkvAvailable()` exported (reads the resolved module, never inferred).
- MMKV encryption path left exactly as-is (deterministic key string, NOT activated, NOT fixed here — reported as residual). No dependency added, lockfile untouched, flags untouched, no C1/Roman files touched.
- Guard test updated: comment now states try/catch alone does not protect Metro; new suite pins Metro's optional shape (exactly one guarded require site, no static import, package still undeclared + absent from lockfile).
- New `src/storage/__tests__/mmkv.test.ts`: shape detection, shim fallback, namespace layout/isolation, logout wipe.

Stage 1 (lint/tsc/focused jest) running under `execution/test-validation.lock`.
