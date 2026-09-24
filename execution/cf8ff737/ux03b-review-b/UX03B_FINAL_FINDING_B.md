# UX-03b — Independent Review B, FINAL FINDING

**Verdict: NOT ACCEPT (at closure-1 tree `3d621d60`; no commit exists).**
Blocking class: **B only** — three test-file defects make the Jest gate red (rc=1). No product/runtime defect (class A) was demonstrated by the source pass or by any failing assertion.

Reviewer: T4 independent reviewer B. Read-only on product (no edits, no lock, no tsc/lint/Jest/installs, no push). Never read `ux03b-review-a/`.
Requested route: Claude Fable 5 / High — **requested setting only; no telemetry claimed**.
Written 2026-09-24 ~16:20Z. Companion: `UX03B_PRELIMINARY_NOTE_B.md` (Phase 1 source pass) in this directory.

## Scope, honestly

- Coverage is **fixture-derived, mocked consumer coverage only**: `extensionPairApi` is mocked in every hook/screen suite; the fixture is a byte-derived slice of the frozen contract `a0ea1bea`. No live backend, device, extension, or customer acceptance is implied.
- This review did not re-audit accepted J3 / UX-03a evidence or the backend. Backend facts used: only the identity of `docs/contracts/importer-openapi.json` at `a0ea1bea` (sha `bdb022dd…26ba4e5`), read via `git show`.
- All gate results below are read from the builder's receipts; I ran none of them.

## Head binding

| item | value |
|---|---|
| branch / HEAD | `ux03b-c1-setup-correlation` / `9ff749c35f64068e156400d2ed37c0b144c2d56d` (base; Bradley Gleave author+committer) — **no UX-03b commit exists** |
| staged tree | `3d621d600880b481375055e9d980196b23b263ff` == CLOSURE_1_READY write-tree; patch sha `5d0032f0…7ee0337` recomputed and matched |
| closure-1 delta vs `4b92827d` | exactly 1 file, +1/−1: `extensionImport.contract.test.ts:493` gains `: Record<string, unknown>`; no other hunk — matches `UX03B_TSC_CLOSURE_GRANT.md` |
| gate run 1 (tree 4b92827d) | `00-lock.txt`, `01-tsc.log`: tsc rc=2, one TS2339 at 496:51 — preserved unchanged |
| gate run 2 (tree 3d621d60) | `10-lock.txt` records the write-tree; `11-tsc.log` rc=0; `12-lint.log` rc=0; `13-jest.log` **rc=1**: Suites 3 failed / 8 passed / 11; Tests **7 failed / 389 passed / 396** |

Counts are real (396 tests across the 11 slot suites), not vacuous; per-suite sizes by `it(`/`it.each(` grep: hook 90, contract 48, api 28, mirror 23 (plus identityWait, panel and screen suites).

## B findings (each: harm → blocked decision → minimum closure → unlocked)

### B1 — hook test `useExtensionPairing.test.tsx:1327` asserts a null mirror during a live pre-init attempt
- **Failing assertion (receipt):** "same coach cancel→retry …" — `expect(await readImportPairingMirror('coach-1')).toBeNull()` received the retry's record `{code:null, expiresAt:null, idempotencyKey, setupNonce, platformId:'truecoach', userId:'coach-1', version:2}`.
- **Root cause:** the grant's pre-init persistence (record written *before* `init`) is working exactly as specified; the base assertion predates it. I predicted this statically before reading the receipt (see preliminary note).
- **Harm:** proof red; the assertion's real intent (the cancelled attempt's code `111111` must not be mirrored) is still true.
- **Blocked decision:** UX-03b commit/acceptance.
- **Minimum closure (owned file, one line):** `expect((await readImportPairingMirror('coach-1'))?.code).toBeNull();` — preserves intent, does not weaken it (the record is still asserted to carry no code).
- **Unlocked:** hook suite green (it is the only failing test in that suite).

### B2 — `ImportDataScreen.restore.test.tsx` seeds a mirror record without `setupNonce`
- **Failing assertions (receipt):** both restore tests — "shows the SAME code, minting nothing" (`getByTestId('import-status')` at :131) and "names the platform honestly for a custom-URL session" (:195). Console shows `[importPairingMirror] shape or version drift discarded` ×3.
- **Root cause:** `seedMirror()` (:78–89) writes `version: IMPORT_PAIRING_MIRROR_VERSION` (now 2) with `userId, platformId, code, expiresAt, idempotencyKey` but **no `setupNonce`**, so the v2 schema correctly discards it and the screen never restores. This suite **passed** at the UX-03a baseline (`ux03a/receipts/03-jest*.log`) and at J3 gate 3 (`j3-recovery-t3/run/receipts/07-gate3.txt`), so it is a diff-caused test drift in an owned slot file (`ImportDataScreen*`) that the builder did not update.
- **Harm:** proof red; product behaviour (v1-shaped record discarded) is grant-mandated and correct.
- **Blocked decision:** UX-03b commit/acceptance.
- **Minimum closure (owned file, one line):** add `setupNonce: 'seeded-nonce-0001',` to the seed object. All other seeded fields already satisfy the v2 schema (code present ⇒ `expiresAt` string).
- **Unlocked:** restore suite green; restores the only consumer-level proof that a mirrored session is resumed after a process restart — which is exactly the cold-hydration path UX-03b changes.

### B3 — `useExtensionPairing.identityWait.test.tsx:119` calls async `unmount()` without `await`
- **Failing assertions (receipt):** all 4 tests in "bounded identity wait — transitions" fail with `TypeError: Cannot read properties of null (reading 'start')` at `result.current.start()`, preceded by `console.error: You seem to have overlapping act() calls`.
- **Root cause:** installed `@testing-library/react-native` is 14.0.0 (React 19.2.3); `render.js:49` defines `unmount = async () => …`. Test 3 ("does not fire after unmount") calls `unmount();` un-awaited, leaving an open act scope; every later `renderHook` in the file then overlaps it and `result.current` stays null. The main hook suite uses `await unmount()` (:530) and is unaffected. The file is unchanged by the diff, but it is in the grant's owned set (grant line 66) and in the slot's Jest list. No receipt in `execution/cf8ff737/` shows this suite passing under this `node_modules`, so I do not claim it was green at base — only that the failure is not caused by the UX-03b hunks (nothing in the diff runs at render time for a null identity; see preliminary note).
- **Harm:** proof red; the 4 lost tests are precisely the deferred-intent / late-identity / sign-out-window transitions UX-03b touches (they would exercise pre-init write ordering under a late identity), so they are not dispensable.
- **Blocked decision:** UX-03b commit/acceptance.
- **Minimum closure (owned file, one token):** `await unmount();` at :119.
- **Unlocked:** identityWait suite runnable; the 4 transition tests then report real outcomes for the new behaviour (they may surface further drift — that would be a new, truthful result, not a masked one).

**Ordering note:** the three closures are independent, in three owned test files, and change no product code and no assertion semantics beyond B1's `?.code`. A single closure-2 grant covering all three, refreeze (new write-tree + patch sha in `ux03b/`), and one rerun of step 5 from gate 1 is the smallest path. If Jest then passes, the head to bind is a **single commit** on `9ff749c…` with tree == that refrozen write-tree, Bradley author+committer, no AI trailers; this finding should be re-issued against it (short delta: verify tree/parent/author and the three-hunk delta from `3d621d60`).

## Masked-assertion scan (UX-03a lesson)

Read every assertion in the three failing suites and the contract/mirror/api suites for masked forms: no `toHaveTextContent` substring assumptions in the failing tests; hook/mirror/contract suites use exact `toBe`/`toEqual`/`toMatchObject` on decoded values; secret-absence test serialises all `track` calls (`JSON.stringify`) and asserts `not.toContain` for code, key and nonce — not masked. Contract bottom block asserts required/optional/enum lists by value from the fixture. Nothing that passes for the wrong reason was found among the new tests. (C7: the legacy top half of the contract test remains tautological — pre-existing, not new.)

## What is acceptable in the candidate (for the record)

Source-level conclusions from the preliminary note stand: nonce generated once / persisted before network / replayed on same-intent retry and cold hydration / discarded on 409, owner change, and every codeless terminal; mirror v2 with v1 discard and pre-init `null`/`null` record; 410 → `expired/challengeUnavailable` with setup kept; decoders fail closed; no redeem from mobile; secrets absent from URL/query/log/analytics; fixture byte-derived from frozen `a0ea1bea`; grant copy strings present and tested; no G3-AUTH claims. Nothing in the failing receipts contradicts any of these.

## Class C (recorded only; no new work) — see preliminary note C1–C9

## Files in this directory

- `UX03B_PRELIMINARY_NOTE_B.md` — Phase 1 source pass
- `UX03B_FINAL_FINDING_B.md` — this file
- `regen_fixture.json` — independently regenerated fixture (sha `618007f4…41d4878`, byte-identical to staged)
- `13-jest.plain.log` — ANSI-stripped copy of the builder's `13-jest.log` used for the failure listing
- `MANIFEST.sha256` — sha256 of the above plus the key inputs read
