# UX-01 test-timing minimum closure (B-UX01-TEST-TIMING) — r2 source freeze

Disposition applied exactly: ONLY the failing test body changed. No hook/product change. No amend, no rebase, no commit, no runtime. Heavy slot not held.

## Pins

| Item | Value |
|---|---|
| r1 committed candidate (HEAD, unchanged) | commit `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`, tree `a33cb8919495ed24e30623188dbb9f59c67df8bd` |
| **r2 candidate tree (staged index on top of 327731d4, `git write-tree`, no commit)** | **`17a6ce1acea7e4d6e926113faeb6a57eafa684f3`** |
| Changed path (the only one; `git diff-tree` r1→r2 = 1 path) | `src/hooks/__tests__/useImportOfferDecision.test.tsx` |
| Test blob r1 → r2 | `99cd6e184f7847fa336672544a83e34de7ff558a` → `9c10f1132d72b5e3f3e0247e506bbc59b600c253` (+12/−0) |
| r1→r2 patch | `UX01_TEST_TIMING_r1_to_r2.patch`, 26 lines, sha256 `975515f4bec0af5e5c26dcfdaf000975f398d6d6f9fc0c72bec7bb8dcda7da1d` |

## Unchanged in r2 (bit-identical to the A/B-granted tree)

| Path | Blob |
|---|---|
| `src/storage/importOfferDecision.ts` (product) | `83118fff2c7d611b956483f0a7471e5811d024ac` |
| `src/hooks/useImportOfferDecision.ts` (product) | `ddede7266e3146ecfb5507b75983f565722966ee` |
| `src/services/authActions.ts` (product) | `ceb33c45685ce49e98205abf8e268d65aa0a0333` |
| `src/storage/__tests__/importOfferDecision.test.ts` | `004e520eb24c73fb75ebaadcd1b893d012a2d059` |
| `src/services/__tests__/authActions.test.ts` | `fb3ac27c1e4f0e1a541b9f682767451364f305c8` |

## The delta (verbatim)

```diff
@@ -117,9 +117,21 @@ describe('useImportOfferDecision — inert and unresolved states', () => {
 describe('useImportOfferDecision — reading the persisted answer', () => {
   it('is loading (render nothing) until the read settles, then ready with null when unanswered', async () => {
+    // Hold the read open: RNTL's async renderHook flushes an unheld in-memory
+    // read inside its own act, so the intermediate state is only observable
+    // while getItem is still pending.
+    const held = deferred<string | null>();
+    const getSpy = jest.spyOn(AsyncStorage, 'getItem').mockImplementationOnce(() => held.promise);
+    spies.push(getSpy);
+
     const { result } = await renderHook(() => useImportOfferDecision(true));
     expect(result.current.status).toBe('loading');
     expect(result.current.decision).toBeNull();
+
+    await act(async () => {
+      held.resolve(null);
+      await flush();
+    });
     await waitFor(() => expect(result.current.status).toBe('ready'));
     expect(result.current.decision).toBeNull();
   });
```

Conformance to the disposition: uses the file's existing `deferred<string | null>()` helper and the existing `jest.spyOn(AsyncStorage, 'getItem').mockImplementationOnce(() => held.promise)` + `spies.push` pattern (identical to lines 211–212 / 323–324 of r1); all four original assertions preserved in order; `null` resolved under the existing `await act(async () => …)` + `flush()` idiom; title unchanged; case population unchanged (17 `it`/`it.each` declarations before and after; 56 cases). Spy restored by the existing `afterEach`.

## Original failed-run receipts (retained, not rewritten)

`validation-receipts/04-jest-new-files.log` / `04-jest-new-files-status.txt`: RC 1, 55 passed / 1 failed / 56, on r1 commit `327731d4`. `COMMIT_AND_VALIDATION_ATTESTATION.md` unchanged.

## Proposed follow-up ordinary commit (not made; awaits A+B delta review and grant)

```
test(import): control offer-decision read timing

Hold the AsyncStorage read open in the loading-state case so the
intermediate `loading` state is asserted while the read is pending;
RNTL's async renderHook otherwise flushes an unheld in-memory read
before the assertion. Test body only; hook and storage unchanged.
```

Author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, parent `327731d4`, tree `17a6ce1a…`.

## Execution plan once granted (not started)

On the r2 commit, under a fresh nonblocking slot, per disposition (no restart from the top, no rerun of the 55 passing cases):
1. `./node_modules/.bin/jest --ci --runInBand src/hooks/__tests__/useImportOfferDecision.test.tsx -t 'is loading \(render nothing\) until the read settles'` (single named case)
2. `./node_modules/.bin/jest --ci --runInBand src/services/__tests__/authActions.test.ts -t 'import_offer_decision'`
3. `./node_modules/.bin/tsc --noEmit`
4. `./node_modules/.bin/eslint` on exactly the six changed paths

Environment already present: isolated `worktrees/ux01-state/node_modules` copy (receipt `validation-receipts/03-env-reuse.txt`).

## State

HEAD `327731d4` unchanged; index holds r2 (`M  src/hooks/__tests__/useImportOfferDecision.test.tsx`); working tree otherwise clean; `node_modules/` ignored. Lock not held.
