# E1 — extension UX-05 no-run error copy — SOURCE READY

Parent: EXEC-CE3748CB. Grant: `UX_M1_E1_GRANT.md` §E1. Brief: `ux-readiness/UX04_06_BRIEF.md` §3/§6 (E1 slice; approved-copy sources cited there). T2, sole writer.

## Head

- Repo: `/home/user/workspace/repos/tgp-importer-extension`
- Worktree: `/home/user/workspace/worktrees/ux-e1`, branch `ux-e1`
- Base: `origin/land/s4-r6` `aa0abd8310af7b5a5d45fe844611efbc3977d74c`
- New head: `8901d5f50eaadd6bad19e933c9e76b6539299669` (one ordinary commit ahead of base)
- Author/committer: Bradley Gleave `<bradley@bradleytgpcoaching.com>` (both fields; verified via `git log -1 --format='%an <%ae> / %cn <%ce>'`)
- No AI trailers (verified: no `Co-Authored-By`/`Generated`/model-name lines in the commit body)
- Not pushed.

## Tree (owned paths touched — exactly as granted)

```
 _locales/en/messages.json        |  28 +++++
 popup/outcome.js                 |  27 +++++
 popup/popup.js                   |   9 +-
 test/popup-prestart-copy.spec.js | 217 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 279 insertions(+), 2 deletions(-)
```

No changes to `popup/*.html`, `background.js`, `shared/**`, `content/**`, or `manifest.json`. No worker/shared/HTML changes were necessary — the mapping is pure presentation over the existing `snapshot.lastError` string already delivered to the popup.

## Diffstat (`git diff --stat aa0abd83 HEAD`)

Same as tree above (only file in the repo that changed).

## What changed

- **`popup/outcome.js`**: added `preStartIssue(lastError, message)`, a pure mapper next to the existing L78-91 issue-key catalog, using the same prefix/substring-match idiom. Maps the seven known no-run `lastError` families read from `background.js` at `aa0abd83` to approved keys:
  1. Session changed → `prestart_session_changed` (matches the `SESSION_REPLACED_DETAIL` text, background.js L146-147, used at L210/660/931)
  2. Pairing/sign-in needed → `prestart_pairing_needed` (matches `"auth_required"`, `"login required to import"` L214, `"session expired — please sign in again"` L594/841)
  3. Page can't be imported → `prestart_page_unsupported` (matches `"unsupported site: ..."` L565/793; origin is never echoed in the shown copy)
  4. Unsafe origin → `prestart_unsafe_origin` (matches `"unsafe import origin: ..."` L801)
  5. No reader for this site → `prestart_no_reader` (matches `"no extractor for ${platform}"` L617; no vendor/platform slug shown, per X6)
  6. Site setup unavailable → `prestart_site_setup_unavailable` (matches `"no blueprint for ${platform}"` / `"blueprint resolve failed"` L809-812)
  7. Unknown → `prestart_unknown`, one generic line for anything not in the catalog (e.g. `ingest_ack_invalid`, `complete:*`, `skipped`, or any other worker-internal detail that should never reach the coach)
- **`popup/popup.js`**: the L115-120 error-render branch now calls `preStartIssue(snapshot.lastError, chrome.i18n.getMessage)` instead of assigning `snapshot.lastError` to `errorBox.textContent` directly. Added `preStartIssue` to the existing `outcome.js` import. The run path and Start locking are unchanged; only the no-run error box text changed.
- **`_locales/en/messages.json`**: purely additive `prestart_*` keys (7 keys, 28 lines) appended after the existing `replay_partial_summary` entry. No existing key touched.
- **`test/popup-prestart-copy.spec.js`** (new, 217 lines / 29 tests): unit coverage of `preStartIssue` for all seven families plus the generic fallback (including empty/null/undefined), asserts no platform slug or origin ever appears in the mapped text, and asserts the raw string is never returned unchanged; integration coverage through the real popup module (`popup.js` render path) confirming `#error.textContent` shows only approved copy, is hidden when there's no error, and is hidden once a run/intent is present (that state is owned by the existing outcome-view copy, unchanged here).

## Test counts

- Baseline at `aa0abd83` (per S4-CQ record cited in the brief): 65 files / 1743 tests.
- At `HEAD` (`8901d5f`): **66 files / 1772 tests, all passing** — full `npm test` run, no `--` filters:
  ```
  Test Files  66 passed (66)
       Tests  1772 passed (1772)
  ```
  Delta is exactly the one new file (+1 file, +29 tests), consistent with an additive-only change.
- Existing suites cited as "must still pass unchanged" in the brief: `test/transfer-outcome-popup.spec.js` and `test/popup-start-import.spec.js` are **byte-identical** to the base (`git diff aa0abd83 HEAD -- <both files>` → 0 lines) and both pass in full at HEAD (33 and 12 tests respectively — the brief's cited baseline of "16 / 8" undercounts the current file; this run confirms no regression either way since the files are untouched).
- One transient full-suite flake was observed on an earlier concurrent run (`test/policy-gates.spec.js`'s "rejects a semantic error in test JavaScript through both entrypoints", a fixed 5000ms-timeout subprocess test) while a sibling worker's jest/prisma jobs were competing for CPU on the shared sandbox under the same heavy-slot lock. Re-run in isolation (`vitest run test/policy-gates.spec.js`, lock uncontended): 106/106 passed, including that case at 3707-3802ms. The subsequent full-suite run at HEAD (66/66 files, 1772/1772 tests) also passed it cleanly. Not a regression from this change; not touching any owned path of this slice.

## Gates

- `npm ci` (heavy slot, `execution/test-validation.lock` via non-blocking `flock` retry): succeeded, 133 packages, `prepare` ran `lefthook install` genuinely (hooks are live for this repo).
- `npm run gates` at HEAD: **rc0** — `check:banned`, `check:flags`, `check:fixtures`, `check:production-preflight`, `check:hooks`, `lint`, `type-check`, `format:check` all OK.
- Genuine pre-commit hook (lefthook v2.1.12, real run, not `--no-verify`): `secrets` (gitleaks 8.30.0, installed via the repo's pinned+checksummed `scripts/install-gitleaks.sh` into a local tools dir — none existed on the sandbox beforehand), `banned`, `deploy-readiness`, `lint`, `format`, `type-check` all passed on the actual commit. First attempt correctly blocked on gitleaks being absent and on `test/popup-prestart-copy.spec.js` not being Prettier-formatted; both were fixed (install gitleaks, run `npx prettier --write`) and the commit was made only after the real hook run was green.
- Full `npm test` (heavy slot): 66 files / 1772 tests passed, 0 failed, at HEAD (see above).
- Remote CI (`test` + `codeql` + `secrets-scan` on a pushed land branch): not run — task scope is "no push"; the parent pushes the CI branch per the grant.

## Scope discipline

- Owned paths only: `popup/popup.js` (render error branch only), `popup/outcome.js` (new pure mapper added, existing `outcomeView` untouched), `_locales/en/messages.json` (additive keys only), new test file. No edits to `popup/*.html` (UX-07's accepted style file), `background.js`, `shared/**`, `content/**`, or `manifest.json`.
- No worker, shared, or HTML changes were needed to complete this slice — the mapping operates entirely on the string already delivered to the popup via `chrome.runtime.onMessage`/`request_status`. Nothing to escalate; STOP condition not triggered.
- No vendor/platform names appear in any new user-facing string (verified by grep and by dedicated tests asserting `truecoach` never appears in mapped output).
- Raw `lastError` text is never assigned to `errorBox.textContent` for any input, including inputs outside the seven known families (falls through to the one generic `prestart_unknown` line).

## Not claimed

- Packaged-browser (EXT-PKG) or installed-source behaviour.
- Independent T2 review (acceptance criterion "one independent T2 review on the exact head" is a separate step, not part of this builder's task).
- Remote CI green (not run; no push performed).
