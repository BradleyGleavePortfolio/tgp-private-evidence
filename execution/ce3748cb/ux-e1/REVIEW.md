# E1 — Independent T2 Review

Reviewer: independent T2 (not the builder). Candidate branch `ux-e1` @ `8901d5f5` (`/home/user/workspace/worktrees/ux-e1`), base `aa0abd83` (`land/s4-r6`). Grant: `UX_M1_E1_GRANT.md` §E1. Brief: `ux-readiness/UX04_06_BRIEF.md` §3/§6. Builder report: `ux-e1/SOURCE_READY.md`.

## Verdict: **ACCEPT**

## Method

Read the diff (`git diff aa0abd83 8901d5f`), read the pre-existing `background.js`/`popup.js`/`popup.html` at `aa0abd83` directly (not via the report), independently re-ran the full suite once the shared heavy-slot lock (`execution/test-validation.lock`) became free, and ran `npm run gates`. Worktree was not modified (`git status` clean before and after; diff of excluded paths is empty).

## A — Scope confined to owned paths

Diff touches exactly the four granted files, nothing else:
```
_locales/en/messages.json | 28 ++++
popup/outcome.js          | 27 ++++
popup/popup.js            |  9 ++--
test/popup-prestart-copy.spec.js | 217 ++++
```
`git diff aa0abd83 8901d5f -- background.js shared/ content/ manifest.json popup/pair.html popup/popup.html` is empty — no excluded path touched. `popup.js` only edits the L115-120 error-render branch and the `outcome.js` import line, exactly as granted. `outcome.js` only adds the new `preStartIssue` export beside the untouched existing `outcomeView`/catalog. `messages.json` change is purely additive (7 new `prestart_*` keys after the existing last entry; no existing key edited). **PASS.**

## B — Correctness of the mapping and honesty of copy

**Family enumeration verified against live `aa0abd83` source, not the report's claims.** Traced every `broadcastStatus({...emptySnapshot(), lastError: ...})` / `broadcastAuthRequired(...)` call site in `background.js` (7 sites: L210, L493/L504-509, L565/L792, L617, L801, L810-812) plus confirmed the render guard is `snapshot.lastError && !snapshot.intent` (`popup.js` L114) — i.e. exactly this no-run condition is what routes through `preStartIssue`, and run-present errors continue through the unmodified `outcomeView` path. There are exactly seven no-run families in the base and the candidate maps exactly these seven, with no eighth family and no case silently omitted:

| Worker string (verbatim from `aa0abd83`) | Mapper condition | Key |
|---|---|---|
| `"import stopped — your TGP session changed during the import. Start the import again."` (`SESSION_REPLACED_DETAIL`) | `.includes("your TGP session changed")` | `prestart_session_changed` |
| `"login required to import"`, `"session expired — please sign in again"` (only call-site strings actually passed to `broadcastAuthRequired`) | `.includes("auth_required")\|\|"login required to import"\|\|"session expired"` | `prestart_pairing_needed` |
| `` unsupported site: ${describedOrigin(url)} `` | `.startsWith("unsupported site")` | `prestart_page_unsupported` |
| `` unsafe import origin: ${describedOrigin(url)} `` | `.startsWith("unsafe import origin")` | `prestart_unsafe_origin` |
| `` no extractor for ${platform} `` | `.startsWith("no extractor for")` | `prestart_no_reader` |
| `` no blueprint for ${platform} `` / `"blueprint resolve failed"` | `.startsWith("no blueprint for")\|\|===...` | `prestart_site_setup_unavailable` |
| anything else | `else` | `prestart_unknown` |

The literal default `"auth_required"` fallback inside `broadcastAuthRequired` (used only when `message` is `undefined`) is dead in the current codebase — every actual call site passes an explicit string — but the mapper's `.includes("auth_required")` still covers it defensively, so no gap even in that theoretical case. **Robust keying confirmed: no family silently falls to generic.**

**Honesty:** none of the seven approved lines, nor the generic fallback, claims that an import happened, that records were transferred, or that anything succeeded. Two lines (`prestart_no_reader`, `prestart_site_setup_unavailable`) explicitly state "No records were read or sent." The others are pure fact+remedy without any completion claim; this is an acceptable stylistic inconsistency (not all seven restate "nothing happened"), noted as a **C** — no coach-facing falsehood exists in any line.

**No vendor/source names or raw text:** grepped `_locales/en/messages.json` — the string `truecoach` appears only in a pre-existing unrelated key's `example` field and in two `description` (developer-only, non-shown) annotations that document the no-slug policy; it never appears inside a `prestart_*` `message`. Confirmed `preStartIssue` never returns the raw `lastError` string unchanged for any of the 7 families (tested and manually re-derived from source). The origin (`describedOrigin(url)`) embedded in `unsupported site:`/`unsafe import origin:` strings is discarded by the mapper (matched via `.startsWith`, not echoed).

**Unknown → single generic line:** confirmed — any string that fails all six branches (including `null`/`undefined`/empty string, tested explicitly) returns `prestart_unknown`, one line, with no worker detail. **PASS.**

## C — Tests, accessibility, identity

**Tests are meaningful, not just coverage padding.** `test/popup-prestart-copy.spec.js` (29 tests) exercises: all 7 exact worker-string→key mappings; the generic fallback across 7 inputs including `null`/`undefined`/empty string; explicit non-containment assertions for the vendor slug and origin URL; an explicit "never echoes raw text unchanged" loop over all 7 families; and — critically — an **integration** layer that boots the real `popup.js` module (not a reimplementation) and asserts the rendered `#error.textContent`, including that the pre-start error box is hidden once `intent` is present (proving the run-path/no-run-path boundary is respected, not merely asserted by the unit layer).

I independently re-ran the full suite under the shared lock (not trusting the report's numbers): **66 files / 1772 tests passed, 0 failed** — matches the builder's claim exactly, including `transfer-outcome-popup.spec.js` (33 tests), `popup-start-import.spec.js` (12 tests), and the new `popup-prestart-copy.spec.js` (29 tests). `git diff aa0abd83 8901d5f -- test/transfer-outcome-popup.spec.js test/popup-start-import.spec.js` is empty — both pre-existing suites are byte-identical to base, so "existing tests unchanged" is verified, not just asserted. `npm run gates` independently re-run: rc0 (lint, type-check, format:check, flag/fixture/hook/preflight checks all OK).

**Accessibility:** `popup/popup.html` is untouched (`git diff` empty for that file) and at `aa0abd83` already carries `<div id="error" role="alert" hidden>`. Since no HTML changed, `role="alert"` on the error region is unconditionally preserved. **PASS.**

**Identity:** `git log -1 --format='%an <%ae> / %cn <%ce>'` → `Bradley Gleave <bradley@bradleytgpcoaching.com> / Bradley Gleave <bradley@bradleytgpcoaching.com>` for both author and committer. Commit body (`git log -1 --format=%B`) contains no `Co-Authored-By`, `Generated`, or model-name trailer — plain prose only. **PASS.**

## Findings

None at A or B severity. One **C** (evidence hygiene, non-blocking): copy consistency across the 7 approved lines could uniformly restate "no records were read or sent" (currently only 2 of 7 do); this is a wording-polish nit, not a truthfulness defect, and does not block acceptance per doctrine (C must not create a fixer/rerun).

## Scope note

`origin/land/ux-e1` already exists as a remote branch — outside this review's scope (push/landing is the parent's job per the grant, not reviewed here).
