# Review B addendum 02 — FINAL same-review actual-head/results attestation

**Disposition: ACCEPTED** — UX-01 account-scoped offer-decision state, local UX-01 state boundary only, at exact head `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` (tree `17a6ce1acea7e4d6e926113faeb6a57eafa684f3`) on branch `ux01-account-state`.

`B-UX01-TEST-TIMING` closed: the minimum closure was executed as specified and the corrected case passed on the committed r2 tree.

Additive to `UX01_ACCOUNT_STATE_T4_REVIEW_B.md` (frozen) and `ADDENDUM_01…` (frozen); neither is edited. Observation time 2026-09-24T07:02Z. Read-only: git plumbing, `git bundle verify`/`list-heads`, and file reads; no execution, retest, product write, commit, or checkout by this reviewer. `account-state-review-a/` not opened. This is not a new source audit; the source verdicts of the frozen report and addendum 01 stand unchanged and are the basis of the acceptance.

Inputs read (SHA-256): `R2_COMMIT_AND_VALIDATION_ATTESTATION.md` `7a965222…3b3f`; `validation-receipts-r2/` all 18 files, in particular `03-jest-hook-named-loading-case.log` `6e1c60d6…e900`, `04-jest-authActions-filtered.log` `200a3824…b410`, `07-postrun.txt` `7f65e211…bafe1`, `08-summary.txt` `9fd53d7a…0b34`, runner `ux01-r2-commit-validate.sh` `8cf40ece…3106` (matches `RUNNER_SHA256.txt`).

## 1. Exact objects — independently observed, all match the grant

| Item | Observed | Match |
|---|---|---|
| HEAD | `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` | as attested |
| HEAD tree | `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` | **= addendum-01 SOURCE_GRANTABLE r2 tree**, bit-identical |
| Parent | `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580` (r1, unamended: same hash, same tree `a33cb891…`) | additive, not rewritten |
| Grandparent | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` | accepted base |
| Author / committer (r2 and r1) | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both; r2 `1790233082 +0000` | G05 met on both landed objects |
| Trailers | 0 (`interpret-trailers --parse`) | no co-author |
| Message | `test(import): control offer-decision read timing` + approved body; `%B` differs from `COMMIT_MESSAGE_R2.txt` only by git's trailing newline (`diff` = one appended blank line) | approved text |
| Hooks | `core.hooksPath` unset; `.git/hooks` sample-only; runner uses `git commit -q -F` with no `--no-verify`, `--amend`, `push`, `reset`, `checkout`, `npm`, or `install` (grep of the runner script) | ordinary commit |
| r1→r2 committed diff | exactly 1 path, `src/hooks/__tests__/useImportOfferDecision.test.tsx`, +12/−0 | equals bound delta |
| Six blobs at HEAD | `83118fff…` storage, `ddede726…` hook, `ceb33c45…` authActions, `004e520e…` storage test, `9c10f113…` hook test, `fb3ac27c…` authActions test | product blobs identical to the original SOURCE_GRANTABLE tree; only the bound test blob differs |
| Base→HEAD paths | exactly the same 6 paths as the original scope | no scope creep across r1+r2 |
| Worktree | `status --short` 0 lines; untracked 0; `node_modules` present and git-ignored | clean |
| Bundle `ux01-account-state-8fd4cf75.bundle` | sha256 `c8e8faae…55cb`; `bundle verify` → "records a complete history"; single head `8fd4cf75` = `refs/heads/ux01-account-state` | durable |
| Patches | `ux01-account-state-r1r2-0001-0002.patch` `47c1f671…b771`; `0002-ux01-test-timing-8fd4cf75.patch` `9ae493a6…6c99`; earlier `aa9c155e…`/`55b510c2…` retained | pins match report |

## 2. Raw results — read from the logs, not the summary

| Stage | Raw evidence | Independent reading |
|---|---|---|
| 03 corrected named case | `PASS`; `✓ is loading (render nothing) until the read settles, then ready with null when unanswered (24 ms)`; `Tests: 18 skipped, 1 passed, 19 total`; `exit_status=0 duration_s=1`; filter regex printed verbatim | The previously red case is green on the committed r2 tree. The 18 shown are `○ skipped` (filtered, not run) — correctly not claimed. 19 total = 16 plain `it` + one `it.each` of 3 decisions (my earlier "17" and the builder's "17" were declaration counts; case count was always 19; wording only, no evidence change). |
| 04 new sign-out case | `PASS`; `✓ removes only the signing-out coach's import_offer_decision:<userId> on sign-out (5 ms)`; `7 skipped, 1 passed, 8 total`; `exit_status=0` | First-ever execution of the one added S6-list case; the 7 pre-existing S6 cases were filtered out, not rerun, as the disposition required. |
| 05 `tsc --noEmit` | `exit_status=0 duration_s=27`; log 0 bytes | Typecheck clean for the whole project including the six paths. |
| 06 eslint six paths | `exit_status=0 duration_s=2`; log 0 bytes; command lists exactly the six changed paths | No errors and no warnings (ESLint prints warnings even at RC 0; the log is empty). |
| Post-run | `07-postrun.txt`: HEAD `8fd4cf75`, tree `17a6ce1a`, status empty; `08-summary.txt`: `ALL_STAGES_PASSED commit=8fd4cf75… tree=17a6ce1a…` | Tree unchanged by the run. |
| Slot | lock acquired 06:58:01Z, released 06:58:38Z (builder's report says 06:58:02Z; the receipt says 06:58:01Z — one-second wording difference, no consequence); pre-flight reconfirmed Node v20.20.1 / npm 10.8.2 / lock `840be0b8…` / installed record `c4d7824b…` with a hard STOP on drift | Same environment as the r1 run and the accepted sibling install. |

## 3. Test-evidence accounting (honest, never "57 run together")

- 55 inherited passes from r1 commit `327731d4` (RC 1 log, retained unmodified): storage suite 37 (independently recounted from blob `004e520e…`: 14 plain cases + `it.each` rows 8 + 12 + 3) and hook file 18 of 19. Applicable to r2 per addendum 01 §4 (product and storage-test blobs bit-identical; one isolated test body changed; spy scoped and restored; AsyncStorage cleared per case). 37 + 19 = 56 reconciles with the r1 log total.
- 1 corrected case: passed on r2 (stage 03).
- 1 new sign-out case: passed on r2 (stage 04), never previously executed.
- Never-run stages `tsc` and six-path ESLint: passed on r2.
- Not run, not claimed: the 55 inherited cases on r2 specifically; S6/C6/full coach suite; any browser, device, or UI composition.

Every new case has therefore been executed once against the product blobs that are now at HEAD, and every granted stage has RC 0 on the exact head. No gap remains in the granted proof set.

## 4. Classification

- Class A: none. Product blobs unchanged since the original SOURCE_GRANTABLE tree; no customer, data, tenancy, credential, network, or runtime consequence introduced by r2 or by the run.
- Class B: `B-UX01-TEST-TIMING` **closed** — minimum closure executed exactly (test body only, in-file idiom, all assertions preserved), corrected case green on the committed tree, no product delay, no assertion deletion, no new test system, 55 transfer honoured.
- Class C, record and continue (no fixer, no control, no retest): RB-C14 declaration-vs-case count wording (17 vs 19) in the builder's freeze and my addendum 01 — evidence unaffected. RB-C15 one-second lock-acquire timestamp wording (06:58:01Z receipt vs 06:58:02Z report). RB-C16 r1 commit `327731d4` remains in history with its red case; correct additive posture; the branch is acceptable only at or after `8fd4cf75`. Frozen RB-C01…RB-C13 stand as recorded; none upgraded.

## 5. Acceptance boundary

Accepted: the UX-01 local account-state delta as source (frozen report + addendum 01) and as landed and proved at head `8fd4cf75` — persisted per-account offer decision, cross-account isolation, corruption/schema discard, sign-out exact-key removal, late-write removal, error contract for `onYes`/`onLater`/`onStartingFresh`, kill-switch default OFF.

Not claimed by this acceptance: any UI binding of the hook into the Home card or Settings; any eligibility inference (`ready && null` is not eligibility; CQ-01 remains server-side); any intent binding; consumer completion of UX-01/UX-02; merge, push, deploy, or release; behaviour under the flag ON in a real device or browser. The RB-C06 host boundary and RB-C10 two-read latency remain items for the UX-02 host at composition time, not conditions on this acceptance.

Any tree other than `17a6ce1a…` at a head other than `8fd4cf75…` requires a new applicability decision (G09). No further same-review step is outstanding for reviewer B.

Bradley decision required: NO.
