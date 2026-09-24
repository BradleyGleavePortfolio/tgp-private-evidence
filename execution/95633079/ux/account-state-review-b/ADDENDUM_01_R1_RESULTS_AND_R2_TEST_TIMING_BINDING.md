# Review B addendum 01 — r1 actual commit/results and r2 test-timing minimum-closure binding

Same-review continuation of `UX01_ACCOUNT_STATE_T4_REVIEW_B.md` (frozen, unchanged). Additive only. Observation time 2026-09-24T06:54Z (2026-09-23 23:54 PDT). Read-only: git plumbing and file reads; no `write-tree`, install, runtime, lint, typecheck, product write, commit, or checkout by this reviewer. `execution/95633079/ux/account-state-review-a/` exists at this time and was not opened.

Inputs read (SHA-256): `COMMIT_AND_VALIDATION_ATTESTATION.md` `73ce1930…961c`; `validation-receipts/04-jest-new-files.log` `3e2d284b…cd5b`; `04-jest-new-files-status.txt` `51927fea…5606`; `01-preflight.txt`, `02-commit-object.txt`, `03-env-reuse.txt`, `00-lock-status.txt`; `TEST_TIMING_R2_FREEZE.md` `28e00481…b0e9`; `UX01_TEST_TIMING_r1_to_r2.patch` `975515f4…7a1d`; parent disposition `checkpoint-private/execution/95633079/ux/UX01_TEST_TIMING_DISPOSITION.md` `e5f7080b…5f85`.

## 1. r1 actual head: binds to the granted tree

| Item | Independently observed | Matches grant? |
|---|---|---|
| HEAD | `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580` | new ordinary commit, as attested |
| HEAD tree | `a33cb8919495ed24e30623188dbb9f59c67df8bd` | **= SOURCE_GRANTABLE tree**, bit-identical |
| Parent | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` | accepted base |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both, `1790232336 +0000` | G05 met on the landed object |
| Trailers | `git interpret-trailers --parse` → 0 lines | no co-author |
| Subject | `feat(import): account-scoped offer-decision mirror and hook (UX-01)` | handoff §7 text |
| Hooks | `core.hooksPath` unset; `.git/hooks` sample-only | no bypass possible or used |
| Untracked | 0 (`node_modules` present, `git check-ignore` confirms ignored) | environment copy did not enter the tree |

The commit is the reviewed source, landed locally, nothing more: not pushed, not merged, not accepted.

## 2. r1 first-nonzero result: read from the raw log, not the summary

`04-jest-new-files.log`: `Test Suites: 1 failed, 1 passed, 2 total`; `Tests: 1 failed, 55 passed, 56 total`; storage suite PASS; hook suite FAIL on exactly one case: `is loading (render nothing) until the read settles, then ready with null when unanswered`, `Expected: "loading" Received: "ready"` at `useImportOfferDecision.test.tsx:121:35`. Status file: `exit_status=1 duration_s=5`. Stages 2–4 not run (first-nonzero stop honoured). Lock acquired 06:45:35Z, released 06:48:30Z.

Independent reading of the cause from the r1 source (blob `99cd6e18…`, lines 119–125) and the installed RNTL 14.0.0 declaration (`renderHook(): Promise<…>`, wraps `act`): the case does not hold `getItem` open, so the in-memory AsyncStorage mock resolves the hook's read inside `renderHook`'s own `act` flush, and the hook has legitimately reached `ready`/`null` (its final asserted state, lines 123–124) before line 121 runs. The hook did what its contract says (`loading` while the read is pending, then `ready`); the assertion demanded an intermediate state at a moment when nothing was pending. The same intermediate state is asserted and **passed** in r1 by the two cases that hold the read open (`a recorded answer supersedes a read still in flight`, r1 line 215; `account switch (A→B) resets BEFORE reading B`, r1 line 330). No product behaviour failure is evidenced. Concur with the parent: **Class B, affected proof only** (a red case falsely rejects unchanged product behaviour and blocks a trustworthy passing proof); not A.

Honest note on my frozen RB-C08: I confirmed the builder's C3(a) statically at the level of "async RNTL 14 calls are awaited". That reading did not predict that an unheld in-memory read settles within `renderHook`'s act; the run did. The limitation is recorded here; it changes no conclusion in the frozen report (RB-C08 already stated that the actual run result was the remaining unknown).

## 3. r2 minimum correction: independent binding

| Item | Independently observed |
|---|---|
| r2 tree object | `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` exists (`cat-file -t` → tree) |
| Staged index vs r2 tree | `git diff-index --cached 17a6ce1a…` → empty (index is bit-identical to r2) |
| r1 tree → r2 tree | exactly 1 path: `src/hooks/__tests__/useImportOfferDecision.test.tsx`, blob `99cd6e18…` → `9c10f113…`, +12/−0 |
| Five other paths in r2 | `83118fff…` (storage), `ddede726…` (hook), `ceb33c45…` (authActions), `004e520e…` (storage test), `fb3ac27c…` (authActions test): **all bit-identical to the granted tree** |
| `git diff --cached HEAD` SHA-256 | `975515f4bec0af5e5c26dcfdaf000975f398d6d6f9fc0c72bec7bb8dcda7da1d` = packet `UX01_TEST_TIMING_r1_to_r2.patch` |
| HEAD after staging | still `327731d4` (r1 commit unamended); unstaged 0; untracked 0 |

Content of the 12 added lines (read from blob `9c10f113…`, lines 120–133), checked against the parent's minimum-closure text:

- Holds the read with `deferred<string | null>()` and `jest.spyOn(AsyncStorage, 'getItem').mockImplementationOnce(() => held.promise)` + `spies.push(getSpy)`: byte-for-byte the idiom of the already-passing r1 case at lines 210–212. Helpers `deferred` (line 51), `flush` (line 62), `spies` (line 64), `act`/`AsyncStorage` imports (lines 22–23) are all in scope in this file; nothing new is introduced. — **conforms**
- The four original assertions (`loading`, `null`, `waitFor ready`, `null`) are preserved verbatim and in order; none deleted. — **conforms**
- `held.resolve(null)` under `await act(async () => { …; await flush(); })`: the file's existing idiom (r1 lines 224–227). — **conforms**
- Title unchanged; `it`/`it.each` declarations 17 → 17; case population 56 → 56. — **conforms**
- No product blob changed; no artificial delay added to the hook; no new test system; no scope expansion. — **conforms**
- First `getItem` call in this case is the hook's read (`beforeEach` uses `clear`, not `getItem`; `useCurrentUser` is mocked), so `mockImplementationOnce` intercepts the intended call; the spy is restored by the existing `afterEach`, and the held promise is resolved before the case ends, so no dangling read leaks into later cases. — **no side effect on the other 16 declarations**

Expected behaviour of the corrected case: `renderHook` resolves while `getItem` is pending → hook `loading`/`null` (asserted); resolve `null` → `readImportOfferDecision` returns `null`; epoch unchanged and mounted → `setView({status:'ready', decision:null})` → `waitFor ready` and `null` (asserted). This is the identical mechanism the passing r1 case at line 215 already exercised on the same product blob.

## 4. Applicability of the unchanged 55 passing cases

The 55 passing cases ran on r1 commit `327731d4` against product blobs identical to r2's, in the same environment (Node v20.20.1, npm 10.8.2, `package-lock.json` `840be0b8…` byte-identical to the accepted sibling, isolated `node_modules` copy with installed record `c4d7824b…` equal to the sibling's `npm ci` exit 0 receipt). r2 changes one test body only; that body's spy is scoped by `mockImplementationOnce` + `afterEach` restore and its promise is resolved within the case; Jest `beforeEach` clears AsyncStorage per case. No shared fixture, module, or helper changed. Under G09 the relevant inputs of the 55 results are unchanged, so those results **transfer**; replaying them would rebuy owned evidence. Class C, concur with the parent.

## 5. Proposed narrowed run: adequate, no gap

1. `jest --ci --runInBand src/hooks/__tests__/useImportOfferDecision.test.tsx -t 'is loading \(render nothing\) until the read settles'` — the corrected named case (the regex uniquely matches its title; the file still loads in full, other cases are skipped, not run).
2. `jest --ci --runInBand src/services/__tests__/authActions.test.ts -t 'import_offer_decision'` — never run; the one added sign-out case.
3. `tsc --noEmit` — never run.
4. `eslint` on exactly the six changed paths — never run.

Together with the transferred 55, this covers every new case once and every never-run stage once. No S6/C6/fixture/full-suite replay; no new tests. This matches my frozen §9 targets except that stage 1 is now narrowed to the corrected case, which is the correct proportion after the 55 transfer.

## 6. Classification and verdict for this continuation

- Class A: none. Product blobs unchanged; the failure was a test-expectation artefact; no customer, data, tenancy, or runtime consequence.
- Class B: the parent's `B-UX01-TEST-TIMING` is correctly scoped to the one proof and is **closed at source** by r2 (execution of the corrected case remains the closure proof).
- Class C (record, continue): RB-C12 — static harness confirmation (RB-C08) did not anticipate the act-flush settle; resolved by the run, no further review layer requested. RB-C13 — the r1 commit `327731d4` carries a red test case; it stays as immutable history under the additive r2 commit (no amend), which is the correct G04/G09 posture; the branch is acceptable only at the r2 head once the narrowed run is green.

**Binding verdict: SOURCE_GRANTABLE for the r1→r2 delta**, exactly tree `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` on parent `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`, single blob `9c10f113…`, patch `975515f4…7a1d`. Unlocked on grant: one ordinary additive test-fix commit (author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, proposed message as in `TEST_TIMING_R2_FREEZE.md`), then the four narrowed stages in §5 on that exact r2 head under a fresh nonblocking slot, then same-review actual-head/results attestation appended here as addendum 02. Any tree other than `17a6ce1a…` requires a new applicability decision. No fresh full audit, no S6/production re-audit, no new tests.

Bradley decision required: NO.
