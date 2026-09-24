# UX-01 review A — same-review continuation: commit 327731d4 results + B-UX01-TEST-TIMING r2 delta binding

Additive to `UX01_STATE_REVIEW_A_REPORT.md` / `SOURCE_PINS.md` / `FINDINGS.md` (unchanged, see `MANIFEST.sha256`). Reviewer A, independent T4 nonbuilder, requested Claude Fable 5 / High (requested setting, not observed). Read-only against `worktrees/ux01-state`; no runtime, no product write, no lock, peer B not read, no full source re-audit, no accepted-S6 or production re-audit. Observation 2026-09-24T06:55Z.

## Binding verdict

**SOURCE_GRANTABLE for the r2 minimum correction (tree `17a6ce1acea7e4d6e926113faeb6a57eafa684f3`). Class A: none. Class B: none new. The parent's B-UX01-TEST-TIMING is closed at source by this delta; its runtime closure is the narrowed run in §5.** The 55 passing cases from RC1 transfer to r2 (§4). Proposed run: only the corrected named case, the never-run filtered `authActions` sign-out case, `tsc --noEmit`, six-path ESLint. No 56-case replay, no S6/C6/fixture reruns, no new tests.

## 1. Original commit `327731d4` — independently attested (unamended)

| Check | Observed |
|---|---|
| HEAD | `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`, parent `bc7b4e96…`, tree **`a33cb8919495ed24e30623188dbb9f59c67df8bd`** = the tree I granted (`UX01_STATE_REVIEW_A_REPORT.md` §4) ✔ |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com> 1790232336 +0000` for both ✔ |
| Trailers | `git interpret-trailers --parse` → 0 lines; no co-author ✔ |
| Message | `git log -1 --format=%B` vs `validation-receipts/COMMIT_MESSAGE.txt` (sha `d5e08a01…`): differs by one trailing blank line only (git's appended `\n`) ✔; text matches the handoff §7 message I had read |
| Hooks / bypass | `core.hooksPath` unset; `.git/hooks` non-sample count 0; no bypass flag evident in the runner ✔ |
| Durability exports | bundle sha `aa9c155e…` verifies (`git bundle verify` ok, sole head `refs/heads/ux01-account-state` = `327731d4`); `0001-…-327731d4.patch` sha `55b510c2…` ✔ as attested |
| Environment | `03-env-reuse.txt`: node v20.20.1 / npm 10.8.2; `package.json` + lock byte-identical to accepted sibling (lock sha `840be0b8…`); `node_modules` isolated copy of the accepted install (installed-record sha `c4d7824b…` identical both sides); no `npm ci`, no network. Matches "env reused matching accepted mobile installation". |
| Slot | `00-lock-status.txt`: acquired 06:45:35Z, released 06:48:30Z; lock file present and empty (free) ✔ |

## 2. RC1 raw result — read from `04-jest-new-files.log` / `-status.txt`, not from the summary

`jest --ci --runInBand` on the two new test files: exit 1, 5 s; **Suites 1 failed (hook) / 1 passed (storage); Tests 1 failed / 55 passed / 56.** The single failure is `useImportOfferDecision — reading the persisted answer › is loading (render nothing) until the read settles…` at test L121: `Expected "loading", Received "ready"`. No other failure, no timeout, no console error in the log. Stages 2–4 not run (first-nonzero stop) — correct behaviour under the granted runner.

Independent classification of RC1: **B (proof), not A.** The assertion at L121 demanded an intermediate `loading` state after `await renderHook`, whose internal `act` flushes the unheld in-memory mock read to completion. The hook's final state (`ready`, `null`) is exactly the correct product answer for an unanswered coach; the hook moved through `loading` (it initialises to `loading` when enabled with a resolved identity, L104–106) but the test observed after the flush. The hook's `loading` state *was* observed and passed in the two held-read cases (`a recorded answer supersedes a read still in flight`, L215; `account switch (A→B) resets BEFORE reading B`, L330), both among the 55 passes. This is precisely the static-only assurance risk the builder recorded as C3(a) and I confirmed as RA-C8 without executing; the confirmation from typings was correct about API shape and wrong about nothing in the product — it could not predict microtask timing without a run, which is why a runtime gate exists. Nothing in RC1 shows a coach-facing misbehaviour, a foreign-account read, a false "saved", or a sign-out leak. Concur with the parent disposition: CLASS B, affected proof = this one case; blocked decision = UX-01 local candidate acceptance only.

## 3. r2 delta — independently re-derived and bound

| Check | Observed |
|---|---|
| `git write-tree` (index on `327731d4`) | `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` ✔ |
| `git diff-tree -r a33cb891 17a6ce1a` | exactly 1 path: `src/hooks/__tests__/useImportOfferDecision.test.tsx`, blob `99cd6e18…` → `9c10f113…`, mode 100644 ✔ |
| `git diff --cached HEAD \| sha256sum` | `975515f4bec0af5e5c26dcfdaf000975f398d6d6f9fc0c72bec7bb8dcda7da1d` = `UX01_TEST_TIMING_r1_to_r2.patch` sha ✔; `--stat` 1 file, +12/−0 ✔ |
| Five other paths in r2 | `83118fff…` (storage), `ddede726…` (hook), `ceb33c45…` (authActions), `004e520e…` (storage test), `fb3ac27c…` (authActions test) — all bit-identical to the granted tree ✔. Paths differing r2 vs base `acb41c2b…`: still 6 ✔ |
| Working tree | `git status --short` = `M  src/hooks/__tests__/useImportOfferDecision.test.tsx` only; no unstaged, no untracked ✔ |
| Case population | `it`/`it.each` declarations 17 → 17; 461 → 473 lines; title unchanged; 56 cases ✔ |
| Assertions | all four original expects preserved verbatim and in order (L127–128 `loading`/`null`; L134–135 `ready`/`null`) ✔ — no deletion, no loosening |
| Product edit | none ✔ (no artificial delay in the hook, as the disposition forbids) |

Correctness of the correction (static, adversarial): the inserted lines are byte-for-byte the idiom of the passing L209–215 case (`deferred<string|null>()`, `jest.spyOn(AsyncStorage,'getItem').mockImplementationOnce(() => held.promise)`, `spies.push`, `await renderHook`, `expect(...).toBe('loading')`). The first `getItem` in the case is the hook's (`beforeEach` calls `clear()`, not `getItem`; `useCurrentUser` is mocked; `featureFlags`/`logger` touch no storage — grep clean). With the read held, `renderHook`'s act cannot advance the view past `loading`, so L127–128 hold for the same reason L215 held in RC1. `held.resolve(null)` under `act` + `flush()` → `readImportOfferDecision` returns `null` (raw `== null` branch, storage L123) → epoch unchanged, mounted → `setView({status:'ready', decision:null})` → L134–135 hold. `mockImplementationOnce` falls back to the spy's original after one call and `afterEach` restores via `spies` ✔. No leakage into other cases. Comment text is accurate about the mechanism. Scope: test body only; matches the disposition's "minimum closure" clause exactly, and matches the closure option (i-b) I would have proposed.

## 4. Applicability of the 55 unchanged passing RC1 cases to r2

The 55 cases' inputs are: the three product blobs (unchanged), the storage test blob (unchanged, 34 cases all passed), the hook test file (changed inside one `it` body only), the mock environment (unchanged: same `node_modules` copy, same `jest.setup.js`), and per-case isolation (`beforeEach` clears AsyncStorage and resets identity; `afterEach` restores spies). The edit adds a spy that is restored before the next case and a promise that is resolved within the case; it cannot alter another case's inputs or order. Under G09 the file is a changed input, so I record the transfer as a reasoned inference rather than a byte-identical replay: **applicable, Class C residual** (if the parent ever wants zero inference, the whole hook file is 17 cases / ~4 s, but the disposition rules out a replay and I do not request one).

## 5. Narrowed runtime I bind to (execution unlocked only after the ordinary additive commit of tree `17a6ce1a…`)

Ordinary commit: parent `327731d4`, tree `17a6ce1a…`, author/committer Bradley Gleave, no trailers, message as in `TEST_TIMING_R2_FREEZE.md` ("test(import): control offer-decision read timing …") — accurate to the delta. Original `327731d4`, RC1 logs and earlier packets stay immutable.

Then, on that exact head, under a fresh nonblocking slot, first-nonzero stop, no restart from the top:
1. `./node_modules/.bin/jest --ci --runInBand src/hooks/__tests__/useImportOfferDecision.test.tsx -t 'is loading \(render nothing\) until the read settles'` — the corrected named case only (expect 1 passed, 16 skipped).
2. `./node_modules/.bin/jest --ci --runInBand src/services/__tests__/authActions.test.ts -t 'import_offer_decision'` — never-run sign-out case (expect 1 passed, rest skipped).
3. `./node_modules/.bin/tsc --noEmit` (whole project by nature; no narrower typecheck exists).
4. `./node_modules/.bin/eslint` on exactly the six changed paths.

Not proposed: any S6/C6/coach-suite rerun, full 56 replay, new tests, product change, gate expansion.

## 6. Findings added to the register (all C; none blocks)

| ID | Record | Consequence | Class |
|---|---|---|---|
| RA-C9 | RC1 failure was a test-observation timing artefact (unheld mock read flushed inside async `renderHook`); r2 holds the read. | None for any coach; one proof re-run. My RA-C8 static confirmation was correct on API shape and could not see timing — recorded as the expected limit of static-only assurance, not a review error to re-audit. | C (closed at source by r2) |
| RA-C10 | 55-case transfer to r2 is inference-based (file blob changed; per-case isolation makes cross-case influence impossible by construction). | None. | C |
| RA-C11 | `tsc`/ESLint cleanliness of the six files remains unproven until §5 stages 3–4 run; RA-C8's lint reasoning stands but is static. | None yet; would be a B on the proof if red. | C (pending runtime) |

## 7. Boundaries

Source and log reading only. Not a claim that the corrected case, the sign-out case, `tsc` or ESLint pass. Not an approval of UX-02 binding, S7 intent, or a server copy. Final actual-head/results attestation for the r2 commit remains required and will follow when the parent provides the results.
