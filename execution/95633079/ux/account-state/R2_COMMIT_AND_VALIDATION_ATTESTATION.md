# UX-01 account-state r2 — ordinary additive commit + frozen 4-stage remainder: actual results

Outcome: **r2 committed exactly as approved on top of r1; all four granted stages passed (RC 0/0/0/0). Lock released; zero owned survivors.** No install, no env copy, no source change, no new proof, no retry, no remote/deploy, no UI composition. This is a factual report, not an acceptance.

## Grant honoured
- Heavy slot: `execution/test-validation.lock` acquired nonblocking (`flock -n`) 2026-09-24T06:58:02Z, released 06:58:38Z (`validation-receipts-r2/00-lock-status.txt`). Probe afterwards: free.
- Runner `validation-receipts-r2/ux01-r2-commit-validate.sh` sha256 `8cf40ece9f6b0ea6f3892c2347cc55685cb5260c2d1ea6f6dc2d6703b3237106`; stdout `launcher-stdout.log`. First-nonzero-stop discipline in place; not triggered.
- Pre-flight verified (`01-preflight.txt`): HEAD `327731d4…` (r1), staged tree `17a6ce1a…` (r2), status exactly `M  src/hooks/__tests__/useImportOfferDecision.test.tsx`, no `core.hooksPath`, only `*.sample` hooks, `git var` author/committer Bradley Gleave, Node v20.20.1 / npm 10.8.2, `package-lock.json` sha `840be0b8…`, installed record `node_modules/.package-lock.json` sha `c4d7824b…` — all unchanged since the r1 run.

## 1. r2 ordinary additive commit
| Item | Value |
|---|---|
| **Commit** | **`8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820`** |
| **Tree** | **`17a6ce1acea7e4d6e926113faeb6a57eafa684f3`** = A/B-granted r2 tree |
| Parent | `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580` (r1, preserved, not amended) |
| Author / Committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` 1790233082 +0000 (both) |
| Message | verbatim `TEST_TIMING_R2_FREEZE.md` follow-up text (`COMMIT_MESSAGE_R2.txt` sha `11eac8a3…836d`; actual `%B` differs only by git's appended `\n`, verified by `diff`); trailers parsed: 0 |
| Hooks | none configured; no bypass flag; `git commit -q -F` |
| Raw object | `validation-receipts-r2/02-commit-object.txt` |
| `git status --porcelain` after commit and after all stages | empty |

History now: `bc7b4e96` (accepted base) → `327731d4` feat(import)… (r1) → `8fd4cf75` test(import)… (r2).

## 2. Frozen 4-stage remainder on committed tree `17a6ce1a…` (all local `./node_modules/.bin/*`, no network)
| # | Command | RC | Dur | Honest counts |
|---|---|---|---|---|
| 1 | `jest --ci --runInBand src/hooks/__tests__/useImportOfferDecision.test.tsx -t 'is loading \(render nothing\) until the read settles, then ready with null when unanswered'` | **0** | 1 s | 1 passed (the corrected case, 24 ms), **18 filter-skipped**, 19 total in file. The 18 skipped are the inherited cases, not executed in this run. |
| 2 | `jest --ci --runInBand src/services/__tests__/authActions.test.ts -t 'import_offer_decision'` | **0** | 5 s | 1 passed (`removes only the signing-out coach's import_offer_decision:<userId> on sign-out`, 5 ms — the never-before-run new sign-out case), **7 filter-skipped** (pre-existing S6 tests, not executed), 8 total in file. |
| 3 | `tsc --noEmit` | **0** | 27 s | empty output |
| 4 | `eslint` on exactly the six changed paths | **0** | 2 s | empty output (no errors, no warnings) |

Raw logs/status: `validation-receipts-r2/03-*.log/-status.txt`, `04-*`, `05-*`, `06-*`, `07-postrun.txt`, `08-summary.txt`.

### Test-evidence accounting (never run together as 57)
- **55 inherited passes**: from the r1 run on commit `327731d4` (tree `a33cb891…`), receipts `validation-receipts/04-jest-new-files.log` (RC 1: 55 passed / 1 failed / 56). Applicable to r2 because the only r1→r2 change is the body of the one failing case (test blob `99cd6e18…` → `9c10f113…`; storage test blob `004e520e…`, product blobs `83118fff…`, `ddede726…`, `ceb33c45…`, authActions test blob `fb3ac27c…` identical). Storage suite: 37 of those 55; hook file: 18 of those 55 (the 18 shown as skipped in stage 1).
- **1 corrected case**: passed in stage 1 on r2.
- **1 new sign-out case**: passed in stage 2 on r2 (first-ever execution).
- Original r1 RC 1 receipts preserved unchanged; `COMMIT_AND_VALIDATION_ATTESTATION.md` not rewritten.

## 3. Durability exports (committed candidate)
| File | sha256 |
|---|---|
| `ux01-account-state-8fd4cf75.bundle` (`git bundle verify`: okay; contains bc7b4e96→327731d4→8fd4cf75 on `ux01-account-state`) | `c8e8faae82ef4a3616b7683fba101b0d789a2d3536b0e79f92b81dbff44c55cb` |
| `ux01-account-state-r1r2-0001-0002.patch` (`git format-patch -2`, both commits) | `47c1f6710a3e3796ea5bb360b16e2aba58b7dd2e2fbcc78da0a546f9e424b771` |
| `0002-ux01-test-timing-8fd4cf75.patch` (`git format-patch -1`, r2 only) | `9ae493a6e8ce7e8972c2fec86dd6022c15807efc2df4fe2da3bad8309b046c99` |
Earlier: `ux01-account-state-327731d4.bundle` (`aa9c155e…`), `0001-ux01-account-state-327731d4.patch` (`55b510c2…`) retained.

## 4. State at report
HEAD `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820`, tree `17a6ce1a…`, clean; branch `ux01-account-state`; `node_modules/` (isolated copy) retained and ignored. Lock free. Owned survivors: 0. Sibling `worktrees/ux07-mobile` untouched. Class A/B: none new. Awaiting the same reviewers' final pass; no self-acceptance, no UI composition started.
