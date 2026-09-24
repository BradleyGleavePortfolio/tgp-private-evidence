# UX-01 account-scoped offer-decision STATE — independent T4 source review A

Status: **SOURCE_GRANTABLE** for the ordinary commit phase of tree `a33cb8919495ed24e30623188dbb9f59c67df8bd` on base `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9`. **Class A: none. Class B: none.** Eight Class C records (`FINDINGS.md`), none of which blocks a decision or asks for a fix, a control, or a retest. This is a source attestation only: nothing has been installed, typechecked, tested, committed or run; the same-review commit/results phase follows when the parent provides it.

Reviewer: independent T4 reviewer A, nonbuilder; requested route Claude Fable 5 / High (requested setting, not observed runtime identity). Read-only against `worktrees/ux01-state`; sole writes `execution/95633079/ux/account-state-review-a/**`. Peer B's area not opened; accepted-S6 audit not repeated; no install/typecheck/test/hooks/browser/process probes/commit/product writes/private checkout. Pins in `SOURCE_PINS.md`; findings in `FINDINGS.md`; hashes in `MANIFEST.sha256`.

## 1. What was attested independently

| Question | Result |
|---|---|
| Tree, blobs, patch | HEAD `bc7b4e96…` (tree `acb41c2b…`, parent `d51a1910…`, author and committer Bradley Gleave <bradley@bradleytgpcoaching.com>); `git write-tree` = `a33cb891…`; `git diff --cached HEAD` sha256 = `d695f8d8…7e0085` = both packet patch files; 6 rows in `diff-tree`, blob ids exactly as tabled in `FREEZE_RECEIPT.md`; both modified files' old blobs equal the base tree's; worktree clean, no untracked files, no active hooks, no remotes. |
| Scope | 6 paths, +1039/−0 (source +340, tests +699). Only `src/storage/**`, `src/hooks/**`, `src/services/authActions.ts` and three test files. No screen, navigator, controller, flag, config, package/lock, endpoint, token store, analytics, or copy path. Sibling presentation tree `377e4b7a…` (12 paths under `src/screens/coach/**`) intersects in 0 paths. |
| Canonical CQ-02 conformance | Account-keyed (`import_offer_decision:<userId>`), user-scoped, versioned, shape-guarded, cross-user payload purged on read, exact-key removal on sign-out, no server endpoint, no new flag, no mandatory server copy: the spec default (CQ-02, J1 truth source, matrix A1 row 3, Section E "offer decision cache"). Only the three canonical answers `yes/later/starting_fresh` are accepted; unknown values are discarded, never coerced (A2 decode posture). |
| Account isolation | Coach B cannot read, inherit or clear coach A's record (distinct keys; test coverage in storage L107–133 and hook L137–144). A payload whose `userId` disagrees with its key is discarded and the reader's key deleted (#291 pattern, storage L146–152). Matrix B5 rows "Signed out on phone" and "Different coach signs in" and E09/E10 satisfied for this store. |
| Async identity epochs / read-write / sign-out races | Monotonic `epochRef` bumped on identity or enable change and on every tap; stale reads discarded; reset to `unresolved`/`loading` applied before the new identity's read starts; writes serialized on `writeChainRef` so the last tap is the last on disk; a write landing after the identity flipped is removed and reported `false`. See `FINDINGS.md` RA-C1..C3 for the three bounded windows that remain (all C). |
| Flags-disabled behaviour | `enabled` defaults to `featureFlags.extensionImport` (OFF unless `EXPO_PUBLIC_FF_EXTENSION_IMPORT` is truthy; same kill switch as `useExtensionPairing`). Disabled ⇒ `status 'disabled'`, no `getItem`, `recordDecision` ⇒ `false`, nothing written. Sign-out key removal is flag-independent and deletion-only (safe). No new flag (UX map common rule). |
| Corruption purge | Unparseable JSON, primitive, null, array, empty object, past/future/string version, empty `userId`, unknown/wrong-case/non-string decision, and each missing field are discarded with the key deleted (storage L134–145; 15 table-driven cases). A failed read is `null` without deleting the record (L127–130; test L186–196). |
| Truthful boolean / error contract | `write` throws on failure (caller keeps memory truth); `read` never fabricates; `clear` logs and never throws. `recordDecision` resolves `true` only when durably written for the still-signed-in owner; `false` for disabled, unresolved, failed write, or owner change (with removal). Docblock and handoff forbid presenting the boolean as a server record ("saved to your account"), consistent with R18 and the mobile authority boundary. |
| Sign-out semantics claim | Comment at the edit site and in the added test state that sign-out clears this local answer only and makes no claim about the desktop extension connection (J13, B5). S6 retire → drain → clear ordering is untouched; only one array element is appended to `PER_USER_KEY_PREFIXES`. |
| Design choice (exact key vs prefix sweep) | Concur with the chosen exact-key option. Reason: the record is non-secret and readable only under its owner's key; a prefix sweep would re-ask bystander coaches on a shared device, contradicting J0 "shown once per account"; #291's prefix sweep exists because the pairing mirror holds a live credential, which is not the case here. The unresolved-id residual is C (owner's own key only). |
| Workflow grade/size constraints | Mobile CI (`.github/workflows/ci.yml`) runs `npm ci`, `validate:config`, lint (`--max-warnings=99999`), `tsc --noEmit`, `jest --ci`; no PR-size or test-ratio gate exists in this repository, and AGENT_RULES G08 forbids a universal LOC ratio. The +340/+699 split needs no exemption tag. Tier T4 matches the UX map row for UX-01 ("account isolation of persisted journey state"). ESLint config (`react-hooks` 4.6.2, TS-ESLint 7) has no rule the new code plausibly trips at error level (`no-explicit-any` is the only error-level custom rule; none used). |

## 2. Adversarial classification of the builder's Class C assertions

All four builder C records are confirmed as C on my own reading (table in `FINDINGS.md`). None is a disguised A or B. I add four C records the handoff does not state (RA-C1 timing window wider than the guard, RA-C2 one-frame theoretical flash on a live A→B mount that the shipped navigation never produces, RA-C3 fire-and-forget clear racing a same-owner write, RA-C4 J1 PROPOSED-wording deviation) and three documentation-precision notes (RA-C5..C7). The handoff overclaims in exactly two phrases: "A's answer never renders under B" (true for every path the app can take; one passive-effect frame short of absolute on a synthetic live remount) and "signOut()'s exact-key removal remains a completed boundary" (the hook completes it shortly after, not within, `await signOut()`, and a narrow window survives). Neither changes product behaviour for any coach, creates a foreign-data path, or invalidates the evidence. Record and continue.

## 3. Customer-backward test

What bad outcome does this delta prevent or create?
- Prevents: a second coach on a shared device inheriting the first coach's offer answer or resume card (wrong customer's state); an answer bound to a guessed owner; a "saved" claim with nothing on disk; re-asking the offer on every launch.
- Creates: none identified. Worst residual (RA-C1/C3): the signing-out coach's own enum answer persists under their own key, or is deleted, causing at most one extra or one fewer offer to the same coach. Not a tenancy, privacy, integrity, financial or availability outcome.

## 4. Decision state per the doctrine template

- A/B DEFECT: none.
- WHY IT BLOCKS: nothing blocks.
- MINIMUM FIX: none required.
- EXECUTION UNLOCKED: the ordinary no-bypass commit of tree `a33cb891…` on `bc7b4e96…` with author and committer Bradley Gleave <bradley@bradleytgpcoaching.com> and no co-author trailer (handoff §7 message is accurate to the delta), followed by the parent-granted runtime gate in §7 and the same-review final-head attestation. The UX-02 sole UI writer may bind `useImportOfferDecision` per handoff §2 as soon as that commit exists.

## 5. Test adequacy (challenged, not inherited)

The three test files assert the properties that matter: key isolation and cross-user purge; every malformed-payload class; failure truthfulness; disabled inertia; refusal without identity; loading → ready; per-coach read; tap supersedes in-flight read; serialized overlapping writes; failed write → `false` and re-offer; A→null and A→B reset before B's read; stale A read discarded; late write after sign-out / switch removed and `false`; sign-out removes exactly `import_offer_decision:user-A`, keeps `…:user-456` and the colon sentinel. Two wording gaps only (RA-C6 "leaves prior record" not seeded; RA-C2 frame claim), neither reducing what the tests actually prove. No additional test is requested: the remaining windows (RA-C1/C3) are hypothesis-level, bounded, same-account and already qualified.

## 6. Requirements checked against the canonical documents

Spec J0 truth rules (persist per account; storage is a design choice; no eligibility inference) ✔ (module never decides whether to ask). J1 (no inheritance across accounts; decline reversible only via Settings is host-level) ✔. J13/B5 (sign-out clears local state, no extension claim) ✔. X1 (persist only intent id, offer decision cache, pairing mirror; no phase/counts/terminal) ✔ (only the decision). R16 (no client clock; no timestamp field, verified by test L80–86) ✔. CQ-01 untouched (server-side eligibility remains unbuilt and un-inferred) ✔. CQ-16 default (`starting_fresh` vocabulary present; hiding is host-level) ✔. UX map UX-01 exit criteria "account switch cannot inherit decision" ✔; "sign-out clears app state without claiming extension revocation" ✔; "resume returns the same server-owned setup via pair/current" correctly deferred to S7-2′ (not claimed). No journey redesign, no new stored field, no mandatory server copy, no new governance.

## 7. Minimum runtime proposal for the results phase (touching this delta only; no S6/C6/fixture reruns)

```
npx jest src/storage/__tests__/importOfferDecision.test.ts \
         src/hooks/__tests__/useImportOfferDecision.test.tsx
npx jest src/services/__tests__/authActions.test.ts -t "import_offer_decision"
npx tsc --noEmit
npx eslint src/storage/importOfferDecision.ts src/hooks/useImportOfferDecision.ts \
           src/services/authActions.ts src/storage/__tests__/importOfferDecision.test.ts \
           src/hooks/__tests__/useImportOfferDecision.test.tsx src/services/__tests__/authActions.test.ts
```

The `-t "import_offer_decision"` filter runs only the one added sign-out test; if the parent prefers the builder's whole-file invocation, the pre-existing S6 tests in that file run as a side effect and are not a new S6 cycle. `tsc --noEmit` is whole-project by nature (the delta adds two imports to an accepted file; there is no narrower typecheck). Execute on the exact committed head whose tree equals `a33cb891…`; a different tree requires a new applicability decision (G09).

## 8. Boundaries of this attestation

Source-only. Not a claim that the tests pass, that `tsc` or ESLint are clean, that the hook behaves at runtime, or that any coach has seen the offer. Library facts (RNTL 14.0.0 async API, AsyncStorage 3.1.1 mock shape, React 19.2.3) were read from the sibling's read-only install, not executed. Nothing here approves UX-02 binding, S7 intent binding, or any server copy.
