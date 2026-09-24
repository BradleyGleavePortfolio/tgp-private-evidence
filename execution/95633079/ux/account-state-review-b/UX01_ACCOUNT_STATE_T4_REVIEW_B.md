# UX-01 account-scoped offer-decision state — independent T4 source review B

**Reviewer disposition: SOURCE_GRANTABLE** for candidate tree `a33cb8919495ed24e30623188dbb9f59c67df8bd` on base `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` (patch `d695f8d8216847b2df1aa1b837821c05d3e1e35d474316ed335a459c9b7e0085`).

Class A findings: none. Class B findings: none. Class C: eleven records in `FINDINGS.md`, none of which changes product behavior, customer risk, or the validity of the next decision. No fixer, no new control, no retest, no minimum A/B delta is requested.

**Review boundary.** Independent T4 reviewer B, nonbuilder. Requested route Claude Fable 5 / High: a requested setting, not observed runtime identity. Read-only against `worktrees/ux01-state`: git plumbing (`rev-parse`, `cat-file`, `diff-index --cached`, `diff-tree`, `diff --cached`, `ls-tree`, `status`, `log`, `worktree list`) and static file reads only. No `write-tree`, install, typecheck, test, lint, hook, browser, process probe, commit, product write, or private checkout. Sole writes: `execution/95633079/ux/account-state-review-b/**`. No peer-A report existed or was read before this freeze. The accepted S6 audit was not repeated; the base is taken as accepted at `bc7b4e96`.

This report is immutable at freeze. Later same-review results (actual head, targeted run outcomes) are to be **appended** in a separate addendum file in this area, not used to reopen the review.

## 1. Exact tree and scope attestation

All pins in `SOURCE_PINS.md` were re-derived, not re-quoted. Summary:

- HEAD is still `bc7b4e96…` (tree `acb41c2b…`, parent `d51a1910…`, Bradley Gleave author and committer). No commit was made by the builder; none by this reviewer.
- The staged index is byte-identical to the candidate tree `a33cb891…` (`git diff-index --cached a33cb891…` empty). The worktree has no unstaged or untracked changes; hooks are `*.sample` only; no `node_modules` exists in this worktree.
- Base → candidate: exactly 6 paths, +1039/−0, blobs as tabled in the freeze receipt. Both modified files' old blobs equal the base tree's blobs; `authActions.ts` gains 9 lines (1 import, 1 array element with comment) and removes none.
- `git diff --cached HEAD | sha256sum` = `d695f8d8…7e0085` = SHA-256 of both packet patch files.
- No package, lockfile, flag, config, navigation, screen, controller, backend, or type-contract path is touched. The new modules import only `@react-native-async-storage/async-storage`, `../utils/logger`, `react`, `../config/featureFlags`, `./useCurrentUser`, and each other. No `fetch`/API import, no `Date.now`, no timers, no SecureStore, no token, no navigation in code (the strings `Date.now`/`token` appear only in comments stating their absence).
- Disjoint from the accepted presentation `df0ad112` (tree `377e4b7a`, 12 paths all under `src/screens/coach/**`): intersection 0. Neither presentation object exists in this worktree's object store.

Scope matches the dispatch statement: CQ-02 canonical mobile default only; new storage module + hook; `authActions` import/prefix entry; targeted tests.

## 2. Spec conformance (UX-01 J0/J1/J13, X1, matrix Section E, CQ-02, CQ-16)

| Requirement | Where satisfied | Verdict |
|---|---|---|
| Decision persisted per account; values `yes / later / starting_fresh` (PLAN §Entry; CQ-02 default = account-keyed user-scoped mirror following #291) | `importOfferDecision.ts`: key `import_offer_decision:<userId>`, closed enum `IMPORT_OFFER_DECISIONS`, versioned payload `{version, userId, decision}`; module is a near-verbatim adaptation of the accepted `importPairingMirror.ts` | Met |
| Another account on the same device must not inherit the card or the intent (J1; E10; B5) | Key is per user; read for user X only opens key X; payload `userId !== key userId` is discarded and deleted; hook resets in-memory view to `loading`/`unresolved` before the new identity's read; stale reads/writes for the old identity are epoch-discarded or removed | Met |
| Sign-out clears account-scoped local state and makes no claim about extension revocation (J13; B5 "Signed out on phone") | Exact-key removal via `PER_USER_KEY_PREFIXES`; comment at the edit site and hook doc say sign-out clears local answer only; nothing in the delta mentions revocation to a user | Met |
| Persist only non-secret correlation / offer decision cache; never phase, counts, terminal, client-clock decisions (X1; Section E; R16) | No timestamp field (test pins the exact key set `decision,userId,version`); no `Date.now`; no phase or terminal vocabulary | Met |
| Corrupt / version-drifted / unknown-value payloads never half-trusted (#291 posture; E35 spirit) | Unparseable JSON, non-object, wrong `version` (0, +1, string), empty `userId`, unknown or wrongly-cased decision, non-string decision, missing field → discard + delete; unknown value never coerced | Met |
| No eligibility inference; account state is a local UX decision, not setup/run/server eligibility authority (CQ-01 server-side; E38) | Module and hook only remember WHAT was answered; hook doc and handoff state that `ready && null` is not eligibility; no role, onboarding, or rollout read | Met; boundary reminder recorded as RB-C06 for the host |
| No new endpoint, flag, credential store (map "no new governance"; CQ-02 "not a mandatory new endpoint") | Default `enabled = featureFlags.extensionImport` (existing kill switch, OFF by default, same as `useExtensionPairing`); no network; AsyncStorage only | Met |
| `starting_fresh` hides Home promo, Settings remains (CQ-16 default) | Stored as a value; rendering is the host's; nothing here removes Settings | Not in scope of this delta; nothing contradicts it |
| NEW SOURCE → CORE DIFF = 0 (X6) | No platform id anywhere | Met |

## 3. Persistent identity, read/write, sign-out safety

Identity source is `useCurrentUser()` (the accepted S6 R3 epoch-guarded cache reader), the same source the accepted `useExtensionPairing` uses; no second identity path is introduced. Every read and write binds to the id captured at start (`owner`), and results settling after an identity/enable change are discarded (`epochRef`) or, for a landed write, removed (`clearImportOfferDecision(owner)`) and reported `false`.

The `authActions.ts` edit is one element appended to `PER_USER_KEY_PREFIXES`, which `signOut()` maps to the exact key `import_offer_decision:<signingOutUserId>` and removes inside the existing `AsyncStorage.removeMany([...])` step. The S6 ordering (retire → drain → clear; cache gate; `ASYNC_SIGN_OUT_PREFIXES` sweep; per-user exact keys; `settleAndClearQueryCache`; `'logout'`) is untouched. `SIGN_OUT_PREFIXES` (the re-export) has no non-test consumers in `src/`.

Design choice exact-key (chosen) versus whole-prefix sweep (alternative): the record is non-secret and readable only under its owner's key, so the exact-key treatment (same as `macro_targets:`) is the correct proportion. The whole-prefix treatment used for the pairing mirror exists because that mirror carries a live pairing code (a credential); this record carries none. Residuals of the chosen option (unresolved sign-out id; late writes) are same-owner, non-secret, and self-limiting: recorded as RB-C02/RB-C03, no fix.

Consequence check against the doctrine list: wrong customer's data — impossible by key + payload check; corrupted records — discarded, never returned; unauthorized writes — none (local only); writes after sign-out — bounded, same-owner, non-secret, removed when detectable; unintended side effects — none (no network, no navigation, no timers); runtime unusable — `recordDecision` never rejects, `readImportOfferDecision` never rejects, the effect's async IIFE cannot produce an unhandled rejection.

## 4. Cross-account, late async, re-entry, disabled states

- **A→B on a live mount:** effect bumps epoch, sets `loading` with `decision: null` synchronously before B's read; A's answer cannot render under B for a frame; a stale A read settling later is discarded. (In the shipped tree `RootNavigator` swaps the coach tree on logout/login, so a mounted hook normally only sees A→null; the A→B guard is defense in depth, as the accepted pairing hook also notes.)
- **A→null (sign-out) on a live mount:** view resets to `unresolved`; the hook does not write during sign-out; a write already in flight that lands afterwards is removed and reported `false`.
- **Re-entry / overlapping taps:** writes are serialized through `writeChainRef` (`then(run, run)` so a failed write does not stall the chain); the latest in-memory answer is the last one on disk; a tap supersedes an in-flight read.
- **Disabled:** `enabled === false` → `disabled`, no storage read, `recordDecision` → `false` without touching state; toggling `enabled` re-runs the effect under a new epoch.
- **Unmount:** `mountedRef` guards `setView`; a write continues to completion (correct: the tap is a fact) and the same-owner post-check applies.
- **Multiple mounted instances:** in-memory views are per instance (RB-C04); disk is consistent.

## 5. Error contract for `onYes` / `onLater` / `onStartingFresh`

`recordDecision(d): Promise<boolean>`; in-memory `decision` reflects the tap immediately when identity is resolved and the hook is enabled. Resolves `true` only when the write landed on this device for the still-signed-in owner; `false` when disabled, unresolved (nothing recorded), identity changed during the write (record removed), or the write failed (memory keeps the answer; next mount reads `null` and the offer may be asked again). It never rejects and never claims a server or extension state. This matches J1's negative state ("never claim saved"; re-offer next entry) and R18. Host guidance recorded in RB-C05/RB-C06.

## 6. Corruption and schema handling

Read path: storage I/O failure → `null`, key untouched (truthful "no answer", not a fabricated one; re-offer). Unparseable JSON → warn, delete, `null`. Shape/version failure (including `version` 0, 2, `"1"`, missing fields, empty `userId`, unknown/miscased/non-string `decision`) → warn, delete, `null`. Key/payload owner mismatch → warn, delete, `null`. `clear` never throws. A future `IMPORT_OFFER_DECISION_VERSION` bump discards v1 records on read (one re-offer), identical to the accepted #291 policy. Deletion always targets the key that was read (the requesting user's), never another user's.

## 7. Builder claims, treated as unproven judgments

| Builder claim | Reviewer assessment |
|---|---|
| "Class A/B: none" | Agreed on independent grounds (§3–§6). |
| C1 A→null→A late-write window | Agreed as C; two adjacent windows added (RB-C02 ii, iii), same consequence class. |
| C2 identity source follows `useCurrentUser` | Confirmed by import; no second path. |
| C3 (a)–(d) static test-harness assumptions | Confirmed by reading installed RNTL 14.0.0 type declarations and `wait-for.js`, and AsyncStorage 3.1.1 mock source, in the sibling's read-only `node_modules` (RB-C08). Not executed. |
| Exact-key vs prefix-sweep rationale | Agreed; proportionate to a non-secret record (§3). |
| "Guarantees a reviewer can check against the tests" (five bullets) | Each bullet has a corresponding test in the hook or storage file and a matching code path; the tests assert on real AsyncStorage-mock contents, not on stubs of the module under test. This is one proof layer; no test-of-the-test is requested. |

## 8. Workflow grade and size applicability

The map's T4 label applies as dispatched (sign-out list edit + per-account persisted state). The delta's intrinsic blast radius is bounded (non-secret enum + opaque user id; no credential; no server; no new flag or endpoint; one array element in the sign-out path). Proportionate assurance = the two dispatched independent source reviews + the ordinary targeted runtime gate. No additional gate, second runtime, browser proof, or fixture is warranted; no downgrade is proposed (RB-C09).

## 9. Minimal runtime targets for this delta only (no S6/C6/fixture repeats)

```
npx jest src/storage/__tests__/importOfferDecision.test.ts \
         src/hooks/__tests__/useImportOfferDecision.test.tsx \
         src/services/__tests__/authActions.test.ts -t "import_offer_decision"
npx tsc --noEmit
npx eslint src/storage/importOfferDecision.ts src/hooks/useImportOfferDecision.ts \
           src/services/authActions.ts src/storage/__tests__/importOfferDecision.test.ts \
           src/hooks/__tests__/useImportOfferDecision.test.tsx src/services/__tests__/authActions.test.ts
```

The `-t "import_offer_decision"` filter on the third file restricts execution to the one added test; it applies only to that file's named tests (the two new files have no such substring in every title, so if a single filtered invocation is preferred, run the first two files unfiltered in one command and the third with the filter, or accept the builder's unfiltered form in which the pre-existing S6 tests in `authActions.test.ts` run as a side effect, not as a new S6 cycle). Expected: 0 failures; `tsc` clean; ESLint no errors (repo baseline tolerates warnings).

## 10. Verdict

**SOURCE_GRANTABLE** for exactly tree `a33cb8919495ed24e30623188dbb9f59c67df8bd` on `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9`. Execution unlocked by this grant: the targeted runtime gate in §9 on this exact tree, then the ordinary no-bypass commit with author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, followed by same-review actual-head attestation appended to this area. Any tree other than `a33cb891…` requires a new applicability decision (G09).

Bradley decision required: NO.
