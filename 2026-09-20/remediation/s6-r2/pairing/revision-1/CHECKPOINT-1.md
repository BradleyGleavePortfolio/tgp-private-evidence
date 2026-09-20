# S6 mobile R2 fixer — checkpoint 1 (orientation complete, no source changes yet)

Time: 2026-09-20 ~14:30 PDT
Worker: subagent "S6 mobile fixer". Requested routing: T4 → Claude Fable 5 High (ROUTING.txt table says "Fable 5.1"; the model catalog exposes only `claude_fable_5`). Actual tool identity: the model running this subagent is not exposed to me by the platform; I record the requested identity only and do not claim a version.

## Verified state
- Worktree `/home/user/workspace/worktrees/s6`, branch `execute/20260920-s6-r2`, HEAD `27b48f64b1dc8df139310941e6a6d7676ce587e6` (= frozen R1 base), clean tree. Mobile main `a5933fd6de5616493de75f0db907098b149b955c` (repos/mobile). Only `repos/mobile` (main) and `worktrees/s6` worktrees exist.
- Identity: `27b48f6`, `3e9249f` author = committer = Bradley Gleave <bradley@bradleytgpcoaching.com>; no repo-local or global user.name/email configured yet (will set repo-local only before committing).
- Held pre-fix commit `4dcc16496b67792f45cd428d4770c405e707319b`: NOT in local object store; one bounded `git fetch origin <sha>` attempt → `upload-pack: not our ref`. **UNRECOVERED.** Will implement the minimum necessary independently; not claiming recovery.
- Toolchain: sandbox has Node v20.20.1 / npm 10.8.2 only; CI pins Node 22.13. No `node_modules` in any worktree (builder's `worktrees/s6-mobile` no longer exists). Plan: fetch Node 22.13.1 binary into `execution/s6-mobile-r2/toolchain` and `npm ci` in the worktree under the test-validation flock.
- Roman #293/#294 untouched (not in this worktree's lineage; will not touch).

## Findings to remediate (from both R1 reports)
| ID | Disposition plan |
|---|---|
| S6-A1 / S6-B-1 | Replace source-text regex `/process\.env\[/` in `featureFlagsReleaseInlining.test.ts` with an AST check (Babel parse → no computed MemberExpression on `process.env`) so comments cannot false-positive; keep comments as-is. |
| S6-B-2 | Declare `@babel/core` as devDependency in `package.json` + lockfile root entry (deterministic `npm ci`). Do not weaken the #289 guard. |
| S6-A2 / S6-B-3 | Hook: hydrate only once a non-null `userId` is known (effect deps include `userId`); `start()` keeps deferring via `pendingStartRef` until hydrated; discard/clear a restored record whose `platformId` ≠ current slug. Screen: on mount, once user known and flag ON, peek the mirror and enter `awaitingExtension` for the persisted platform so the panel actually mounts after a process restart. Tests: null-then-user restore test (no `/pair/init` call); screen-level restore test. No new C1 consumers. |
| S6-A3 | Repo-local, build-time: pin `EXPO_PUBLIC_FF_EXTENSION_IMPORT` and `EXPO_PUBLIC_FF_IMPORT_REVIEW` to `"false"` in `eas.json` `production.env` (same pattern as existing mock pins) + deterministic test. Hosted EAS inventory remains UNKNOWN (inaccessible; not attempted). |
| S6-A4 / S6-B-6 | Run `expo export --platform android --no-bytecode` with flag ON and grep bundle, if feasible in sandbox. |
| S6-A5 | Parent landing decision (identity on preserved PR commits); no action by fixer. |
| S6-A6 / B-7 nonmaterial | Record; no code change unless trivially in touched files. |

Next: read remaining tests/mirror, install toolchain under lock, implement, validate, commit as Bradley Gleave.
