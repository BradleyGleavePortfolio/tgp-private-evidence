# UX-03b reviewer A — gate run 2 analysis (independent, written before reading any closure-2 tree)

Time: 2026-09-24 ~16:20Z. Source: `ux03b/receipts/10-lock.txt`, `11-tsc.log`, `12-lint.log`, `13-jest.log`
(read-only). Lock line binds the run to write-tree `3d621d600880b481375055e9d980196b23b263ff` (closure 1).

| Gate | Receipt | Result |
|---|---|---|
| tsc | 11-tsc.log | `tsc exit=0` |
| eslint | 12-lint.log | `eslint exit=0` |
| Jest | 13-jest.log | `jest exit=1` — Test Suites 3 failed / 8 passed / 11; Tests 7 failed / 389 passed / 396 |

Passing suites: contract test, API test, mirror test, `ExtensionPairingPanel{,.reconstruct,.a11y,.copy}`,
`ImportDataScreen.test.tsx`. All four owned unit suites' NEW UX-03b blocks passed; the 7 failures are all in
pre-existing tests that were not updated to the schema-v2/pre-init behaviour, or a harness leak.

## Failure 1 — `useExtensionPairing.test.tsx:1327` (1 test) — matches nothing predicted in PRELIM; reviewer A missed it

Test "same coach cancel→retry: … late settle is inert" asserts `readImportPairingMirror('coach-1')` is null after the
cancelled attempt's late resolve. Received: `{version:2, code:null, expiresAt:null, idempotencyKey:e32d…,
setupNonce:952b…, userId:'coach-1', platformId:'truecoach'}` — i.e. the LIVE retry attempt's pre-init record, which
the grant mandates be on disk before `/pair/init` answers. `code: null` proves the stale attempt's `'111111'` was
NOT mirrored (the product property the test exists to prove). Hook logic is correct; the assertion is stale.
Classification: **B (proof only)**. Minimum closure: assert the mirrored `code` is null (not `'111111'`) instead of
the record being null. Owned file, but frozen → needs parent closure grant. Reviewer A's own miss: PRELIM checked
only unchanged NON-owned consumers for stale seeds; it did not re-scan the pre-existing blocks of the owned hook test
for `toBeNull()` mirror assertions during `minting`.

## Failure 2 — `ImportDataScreen.restore.test.tsx` (2 tests) — exactly PRELIM finding UX03B-A-01

`seedMirror()` v2 seed lacks `setupNonce`; the fail-closed guard discards it; both restore tests fail as predicted.
**B (proof only)**; closure = one seed line; requires the path extension already identified in PRELIM.

## Failure 3 — `useExtensionPairing.identityWait.test.tsx` (4 tests, all in "transitions") — not predicted

Symptom: `TypeError: Cannot read properties of null (reading 'start')` at `result.current.start()` immediately after
`await renderHook(...)`, plus two `console.error` "overlapping act() calls". Static analysis (read-only; reviewer A
may not run Jest):

- RNTL 14.0.0 (`package-lock.json`, same version pinned when the suite was authored at d51a191) makes `act` always
  async (`_act(async () => await callback())`) and `unmount`/`rerender` async (`await act(() => renderer.unmount())`).
- `renderHook` sets `result.current` inside a passive `useEffect`; if an outer act scope is still open, React defers
  passive effects → `result.current` is null.
- The test immediately preceding the first failure ("does not fire after unmount (timer torn down)", L119) calls
  `unmount();` WITHOUT `await`, then enters `await act(async …)` → overlapping act scope → this is the most plausible
  leak source. The transitions tests `await` all their `rerender`/`act` calls.
- The UX-03b hook diff changes nothing on the identity-null/mount/unmount path (teardown effect unchanged; `emit`
  replaces `setState` only inside guarded branches).

Reviewer A's honest position: the leak hypothesis is consistent with every symptom but is **not established** by a
base-commit run, and no receipt in `execution/cf8ff737/` ever ran this suite (J3 gate 3 = screen suites only, 50
tests; UX-03a = panel suites only, 137 tests). Classification: **B (proof only)** — no product code implicated by
any evidence. Minimum closure: `await unmount();` at L119. If the rerun's transitions tests pass with only that change,
the hypothesis is empirically confirmed; if they still fail, the cause is elsewhere and must be re-examined before
any ACCEPT.

## Masked-assertion scan of gate run 2

None found in the passing owned suites (the new blocks assert captured random uuids, exact copy strings, exact
surface key sets, and fixture-derived enum sets). The `console.warn` noise in 13-jest.log (mirror discards, `disk
full`) is from tests that deliberately exercise those branches.

## Position at this point

NOT ACCEPT on the closure-1 tree (Jest rc1). Three B closures (3 files, 3 lines) are the minimum; none relaxes a
guard, none touches product code. Awaiting parent closure-2 grant / `CLOSURE_2_READY.md`.
