# UX-01 review A — FINAL actual-head / results attestation (same review, phase 3 of 3)

Additive to `UX01_STATE_REVIEW_A_REPORT.md`, `UX01_STATE_REVIEW_A_TEST_TIMING_R2.md`, `SOURCE_PINS.md`, `FINDINGS.md` (all unchanged; see manifests). Reviewer A, independent T4 nonbuilder; requested Claude Fable 5 / High (requested setting, not observed). Read-only against `worktrees/ux01-state` and the raw receipts; no execution, no retest, no product write, no lock, peer B not read, no new source audit. Observation 2026-09-24T07:02Z.

## Verdict

**ACCEPTED — local UX-01 account-scoped offer-decision state boundary, at actual head `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` (tree `17a6ce1acea7e4d6e926113faeb6a57eafa684f3`). Class A: none. Class B: none open — B-UX01-TEST-TIMING is CLOSED (source closure r2 + runtime closure stage 1 RC 0).** All Class C records (RA-C1..C11 plus the two below) remain recorded qualifications and create no further cycle.

Scope of acceptance: the storage module, hook, and sign-out exact-key entry as committed, with their tests, on this device-local boundary only. **Not** accepted or claimed: UI binding (UX-02 sole writer), eligibility (CQ-01/server), intent binding (S7), any server copy, consumer completion, or any coach-facing behaviour beyond what the six files define.

## 1. Exact objects — independently re-derived with git plumbing

| Check | Observed |
|---|---|
| HEAD | `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` |
| HEAD tree | **`17a6ce1acea7e4d6e926113faeb6a57eafa684f3`** = the r2 tree I bound in `UX01_STATE_REVIEW_A_TEST_TIMING_R2.md` §3 ✔ |
| Parent | `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580` (r1, tree `a33cb891…`, itself unamended: still the object I attested) ✔ |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com> 1790233082 +0000`, both ✔ |
| Trailers | `git interpret-trailers --parse` → 0; no co-author ✔ |
| Message | `%B` vs `validation-receipts-r2/COMMIT_MESSAGE_R2.txt`: differs by git's trailing `\n` only; text = the `TEST_TIMING_R2_FREEZE.md` follow-up message ("test(import): control offer-decision read timing …") ✔ accurate to the delta |
| `diff-tree HEAD^ HEAD` | exactly one path `src/hooks/__tests__/useImportOfferDecision.test.tsx`, `99cd6e18…` → `9c10f113…`, mode 100644 ✔ |
| `diff-tree base(acb41c2b…) HEAD` | the same 6 paths as the original grant, no more ✔ |
| Working tree / index | `git status --porcelain` empty; `git write-tree` = HEAD tree ✔ |
| Hooks / remotes | `core.hooksPath` unset; non-sample hooks 0; remotes 0 ✔ ("no hooks configured" is literally true; no bypass flag anywhere in the runner — grep for `--no-verify`, `npm ci/install`, `curl`, `wget`, `git push`, `--force`: none) |
| Durability | bundle `ux01-account-state-8fd4cf75.bundle` sha `c8e8faae82ef4a3616b7683fba101b0d789a2d3536b0e79f92b81dbff44c55cb`, `git bundle verify` ok, sole head `refs/heads/ux01-account-state` = `8fd4cf75` ✔; `ux01-account-state-r1r2-0001-0002.patch` sha `47c1f671…` ✔; `0002-ux01-test-timing-8fd4cf75.patch` sha `9ae493a6…` ✔; earlier `327731d4` bundle/patch retained ✔ |
| Runner | `ux01-r2-commit-validate.sh` sha `8cf40ece9f6b0ea6f3892c2347cc55685cb5260c2d1ea6f6dc2d6703b3237106` = `RUNNER_SHA256.txt` ✔; commit via `git commit -q -F`; first-nonzero-stop present (`STOP at 05` etc.) |

## 2. Raw results — read from the receipts, not the summary

| Stage | Raw file | Exit | Content actually in the log |
|---|---|---|---|
| Pre-flight | `01-preflight.txt` | — | HEAD `327731d4` (expected), staged tree `17a6ce1a` (expected), status exactly one `M`, hooksPath unset, no non-sample hooks, Bradley identities, node v20.20.1 / npm 10.8.2, lock sha `840be0b8…`, installed record `c4d7824b…` (unchanged from r1 env) |
| 1 hook named case | `03-jest-hook-named-loading-case.log` / `-status.txt` | **0**, 1 s | `PASS`; `✓ is loading (render nothing) until the read settles, then ready with null when unanswered (24 ms)`; **18 skipped, 1 passed, 19 total**; filter string echoed in the log matches the granted command |
| 2 sign-out filtered | `04-jest-authActions-filtered.log` / `-status.txt` | **0**, 5 s | `PASS`; `✓ removes only the signing-out coach's import_offer_decision:<userId> on sign-out (5 ms)`; **7 skipped, 1 passed, 8 total**; the 7 skipped are the pre-existing S6 cases, listed by name as `○ skipped`, not executed |
| 3 tsc | `05-tsc.log` (0 bytes) / `-status.txt` | **0**, 27 s | empty output |
| 4 eslint six paths | `06-eslint-six-files.log` (0 bytes) / `-status.txt` | **0**, 2 s | command in status names exactly the six changed paths; empty output (no errors, no warnings) |
| Post-run | `07-postrun.txt`, `08-summary.txt` | — | HEAD `8fd4cf75`, tree `17a6ce1a`, status empty; `ALL_STAGES_PASSED` |
| Slot | `00-lock-status.txt` | — | acquired 06:58:01Z, released 06:58:38Z (36 s; attestation says 06:58:02 start — 1 s rounding, immaterial); no survivors claimed and none owed to this reviewer to verify at runtime |

## 3. Evidence accounting (honest, never "57 run together")

- **On r2 tree `17a6ce1a…` (this head):** 2 cases executed and passed — the corrected loading case and the first-ever run of the new sign-out case; `tsc --noEmit` clean; ESLint clean on the six paths.
- **Inherited from r1 tree `a33cb891…` (commit `327731d4`, receipts `validation-receipts/04-jest-new-files.log`, RC 1):** 55 passes = 37 storage cases + 18 hook cases. Applicability to r2 is the reasoned transfer I bound in `UX01_STATE_REVIEW_A_TEST_TIMING_R2.md` §4 (only the failing case's body changed; per-case isolation; product and storage-test blobs bit-identical). Retained as **Class C RA-C10**, not upgraded to a replay claim.
- The one r1 failure is superseded, not erased: its RC 1 receipts and `COMMIT_AND_VALIDATION_ATTESTATION.md` remain in place unchanged.
- No S6/C6/coach-suite run occurred or is claimed; the 7 S6 sign-out cases were filter-skipped, so this acceptance says nothing new about them (they remain covered by the accepted `bc7b4e96` evidence).

## 4. B-UX01-TEST-TIMING closure test

Disposition required: test body only, neighbouring `deferred`/`getItem` spy pattern, all four assertions preserved, null resolved under `act`, no product edit, no artificial delay, no assertion deletion, no scope expansion → verified at source (`…_TEST_TIMING_R2.md` §3). Runtime: the exact named case passed at RC 0 on the committed r2 tree with the hook and storage blobs unchanged. Concrete harm named in the disposition (a false rejection of unchanged product behaviour preventing a trustworthy proof) no longer exists. **Closed.**

## 5. Qualifications carried forward (Class C, all recorded, none blocking)

- RA-C1..C8 (source review), RA-C9..C11 (r2 phase) stand unchanged; RA-C11 (tsc/eslint unproven) is now discharged by stages 3–4.
- **RA-C12 (own count wording):** in `…_TEST_TIMING_R2.md` I wrote "17 `it`/`it.each` declarations" and "storage … 34 cases". Correct figures: 17 declarations expand to **19 hook cases** (one `it.each` has three rows), and the storage file is **37 cases** (56 − 19, RC1 arithmetic). The builder's earlier "17" had the same declaration-vs-case slip. Wording only; no proof or object changes.
- **RA-C13:** 36-second slot window and lock timestamps are consistent across `00-lock-status.txt` and the status files; the attestation's "06:58:02" acquisition differs from the raw "06:58:01" by one second. Cosmetic.
- Environment is the accepted sibling install copied, not a fresh `npm ci` in this worktree; parity is by identical `package.json`/lock/installed-record hashes. Acceptable for a local state module under the existing grant; recorded, not re-litigated.

## 6. Customer-backward statement

What this head now proves for a coach: their offer answer is stored under their own account key, cannot be read or inherited by another account on the same device, is discarded if corrupt or foreign, is removed for the signing-out coach, is never presented as a server record, and stays inert while the extension-import kill switch is off. What it does not yet give any coach: a visible card, an offer decision, or a resumed setup — those are UX-02/S7 work and are not accepted here.

## 7. Boundaries

Attestation of exact objects and raw results only. Nothing here was executed by this reviewer. No approval of push, merge, deploy, flag, UI composition, or any further stage.
