# S6 R2 fixer — Checkpoint 2 (source edits complete, validation starting)

Time: 2026-09-20 ~21:32Z. Tool identity: Claude Fable 5 (catalog id `claude_fable_5`), not "5.1".
Worktree `/home/user/workspace/worktrees/s6`, branch `execute/20260920-s6-r2`, still at
frozen R1 base `27b48f64` with UNCOMMITTED edits (no commit yet; commits follow green validation).
Mobile main `a5933fd6`, #289–#294 untouched.

## Edits made (uncommitted)
| Finding | File | Change |
|---|---|---|
| S6-A2 / S6-B-3 (restore unreachable) | `src/hooks/useExtensionPairing.ts` | Hydration effect gated on a RESOLVED `userId` (deps `[enabled, doPoll, userId]`); `start()` while identity unknown is deferred via `pendingStartRef`, never minted blind; restore only when `platformId` matches the mounted slug, otherwise the record is cleared (slug non-null) or left alone (slug null); header + `hydratedRef` comments rewritten. No new C1 consumer. |
| S6-A2 / S6-B-3 (panel unmounted after restart) | `src/screens/coach/ImportDataScreen.tsx` | Screen peeks the user-scoped mirror once identity resolves and flag ON; if pending, `intro → awaitingExtension(platformId)` (never overrides a phase already moved to); `key={platformId}` on the panel so platform switches remount/re-hydrate; awaiting copy no longer claims a page "was just opened" (also reached after relaunch) and names the platform. |
| S6-A1 / S6-B-1 (regex comment false-positive) | `src/config/__tests__/featureFlagsReleaseInlining.test.ts` | Source-text `/process\.env\[/` replaced by a Babel AST guard (`parseSync` + `traverse`, TypeScript syntax) counting computed `process.env[...]` member reads; control test proves comments are ignored and a real read is counted. Comments in `featureFlags.ts`/`aiGatewayFlags.ts` unchanged. |
| S6-B-2 (`@babel/core` undeclared) | `package.json`, `package-lock.json` | `"@babel/core": "^7.29.0"` added to devDependencies and to lockfile root `packages[""].devDependencies` (lockfile already resolves `node_modules/@babel/core` 7.29.0). `npm ci` sync check pending. |
| tests | `src/hooks/__tests__/useExtensionPairing.test.tsx` | Old "writes nothing when no coach is signed in" (which asserted a blind mint) intentionally rewritten to "never mints blind while identity unknown"; added: deferred start mints once identity resolves; async-identity restore (null first render → user) with no `/pair/init`; other-platform record discarded and re-minted; null-slug leaves record untouched. |
| tests | `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` (new) | Real screen+panel+hook+storage: restart resume shows same code with no init; no-session → intro; in-flight peek never overrides coach action; flag OFF → zero storage reads; custom-platform copy. |

## S6-A3 decision (EAS activation) — NOT pinned in eas.json, here is why
Expo's own guidance states the merge order for EAS Build is **eas.json → .env files → EAS environment variables**, and "if the same value was defined in all three, the EAS environment variables one would get applied" ([Expo blog](https://expo.dev/blog/what-are-environment-variables)); the same order is quoted in [eas-cli#1982](https://github.com/expo/eas-cli/issues/1982). A `"false"` pin in `eas.json` therefore CANNOT prevent a hosted `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true` from activating the flag, and adding it would create a false sense of a control. Disposition: S6-A3 remains a release precondition (hosted EAS env inventory for the production profile/environment) that this fixer cannot perform (no hosted access, per brief) — UNKNOWN. Note the existing `EXPO_PUBLIC_USE_MOCK_COMMAND_CENTER` / `EXPO_PUBLIC_NOTIFICATIONS_MOCK` eas.json pins carry the same limitation (observation only, not changed). Optional future hardening (not implemented, parent decision): an `eas-build-pre-install` script that fails a production build if any `EXPO_PUBLIC_FF_*` is truthy in the merged build env.

## 4dcc164 recovery
`git fetch origin 4dcc16496b67792f45cd428d4770c405e707319b` → `upload-pack: not our ref`. UNRECOVERED; the fixes above were implemented from the audit descriptions, not from that commit.

## Validation (in progress)
Lock `/home/user/workspace/execution/test-validation.lock` acquired by `logs/run-validation.sh` (see `logs/lock-holder.txt`).
Toolchain: Node v22.13.1 / npm 10.9.2 from verified tarball (sha256 `0d2a5af3…33b3b` matches nodejs.org SHASUMS256). `npm ci` running → `logs/00-npm-ci.log`.
Planned next: validate:config, lint, tsc, focused jest, full jest, `expo export --platform android --no-bytecode` with `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true` + residue grep. All logs under `execution/s6-mobile-r2/logs/`.
