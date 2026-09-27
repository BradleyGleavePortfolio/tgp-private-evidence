# X1 (T4) extension origin authorization — handoff status

- Repo: BradleyGleavePortfolio/tgp-importer-extension. Branch `x1/origin-authorization`, base `a889f4ad`.
- Pushed head: `7ac1fe9abf67d0ae65afaaa2f66506471882541e` (PR #35, open, NOT merged; CI/CodeQL/secrets green). Reviewed by review A → NO-GO (`northstar/X1_REVIEW_A.md`).
- WIP (review-A closures) is NOT pushed: pre-commit hook blocked the commit (check-banned: net-new empty `catch {}` in `test/helpers/background-mock.js` startGesture; type-check: `test/capture-run-scope.spec.js:129` `release` possibly undefined). Full diff vs 7ac1fe9: `handoff-wip/x1-origin-authorization.patch` (14 files, +669/−85). Worktree `/home/user/workspace/worktrees/x1-origin` (will be lost).

## DONE and verified (in the patch)
- A1: `shared/capture.js` run generation + `retireCaptureSessions()`; events/body reads/stop refused for obsolete or de-authorized sessions; `permissions.onRemoved` ends sessions. `background.js settleRun` retires captures first.
- A2: capture re-checks live tab after attach, tears down on `tabs.onUpdated` to another origin and on foreign `documentURL`; `collectSourceToken(tabId, origin)` re-checks the tab around every await, refuses a reply whose `origin` ≠ authorized (`source_tab_navigated: <origin>`); `content/main.js` reply now `{ok, token, origin: location.origin}`.
- A3: `legacy/truecoach/net.js` fetch has `redirect: "error"`.
- B1: `background.js` records `permissions.onAdded` origins (`freshGrants`), consumes one per run, revokes grant at settle (`revokeGrant`), merely-held grant → revoked + `start_not_authorized: <origin>`; `start_ingest` takes its token via `collectSourceToken`, refuses `sourceToken` (`source_token_not_accepted: <origin>`).
- B2: `unregisterSourceCollector` verifies via `getRegisteredContentScripts`; failed cleanup → `pendingCleanup`, router replies `cleanup_pending`, `retryPendingCleanup` on next Start.
- Popup: `origin_request_failed` code; `prestart_source_tab_changed` copy; outcome mapping for new codes.
- Tests passing on the patch (file-by-file): capture-run-scope (new, 9, A1/A2), capture*, origin-authorization, start-import, start-import-hardening, ingest-auth, ingest-settlement, ingest-acknowledgement, ingest-complete-contract, router-principal-gate, popup-*, transfer-outcome-*, session-*, content-collector, content-entrypoint, replay-truecoach-e2e, package-integrity. Mocks: stateful grants/scripting, `fresh`/`failRevoke`/`failUnregister` knobs, `navigateTab`, `grant/revoke`.

## NOT done
- Fix the two hook blockers (replace empty catch with a guarded `URL.canParse`/comment-bearing catch per R75 convention; add `if (!release) throw` in the test). Then commit + single push.
- Regression specs still missing: B1 (stale grant → `start_not_authorized` + revoke; `fresh:false` mock), B2 (`failUnregister`/`failRevoke` → `cleanup_pending`, retry admits), A3 (redirect via real legacy net path), A2 token race (tab navigates during `executeScript` → `source_tab_navigated`), `start_ingest` sourceToken refusal. Prove each fails on 7ac1fe9.
- `test/ingest-legacy-settlement.spec.js` still dispatches `start_ingest` with `sourceToken` → now `source_token_not_accepted`; convert to `tabId` + tab mock with token.
- Full `npm test`, lint/type-check/format gates, CI.
- Rebase onto origin/main `30e78a29` (N1 landed). Shrink `.vendor-name-guard.json`: remove entries for manifest.json, background.js, shared/*, extractors/detect.js, extractors/truecoach*, _locales, extractors/_interface.js if emptied; add `legacy/**`. Guard fails on stale entries.
- Update `northstar/X1_BUILD.md` (currently describes 7ac1fe9 only); prod LOC cap retired per parent (flag only if >~1000).

## Next step for a new operator
`git checkout x1/origin-authorization && git apply --index handoff-wip/x1-origin-authorization.patch`, fix the two hook blockers above, run `npm run gates`, commit as Bradley Gleave (no AI co-author), single non-force push, then finish the NOT-done list and reply to review A.
