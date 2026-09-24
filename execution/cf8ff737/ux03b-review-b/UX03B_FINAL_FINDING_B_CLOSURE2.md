# UX-03b — Independent Review B, FINAL FINDING (closure-2 head)

**Verdict: ACCEPT** commit `519b01227f2855fc7968994d389094008f222e20` on `ux03b-c1-setup-correlation`, within the honest scope below. No A or B findings remain open. Class C recorded only.

Reviewer: T4 independent reviewer B. Read-only on product (no edits, no lock, no tsc/lint/Jest/installs, no push). Never read `ux03b-review-a/`.
Requested route: Claude Fable 5 / High — **requested setting only; no telemetry claimed**.
Written 2026-09-24 ~16:30Z. Supersedes the verdict of `UX03B_FINAL_FINDING_B.md` (left unchanged as the record of the run-2 failure); source-level conclusions there and in `UX03B_PRELIMINARY_NOTE_B.md` are carried forward, not re-audited — only the three closure-2 lines changed.

## Scope, honestly

Fixture-derived, **mocked consumer coverage only**: `extensionPairApi` is mocked in every hook/screen suite; the fixture is a byte-derived slice of frozen contract `a0ea1bea` (`2.0.0-c1-s1.1`). No live backend, device, extension, deployment, or customer acceptance is implied or claimed. Gate results are read from the builder's receipts; I ran none of them.

## Head binding — actual commit (all re-verified by me)

| check | result |
|---|---|
| branch head | `ux03b-c1-setup-correlation` == `HEAD` == `519b01227f2855fc7968994d389094008f222e20`; worktree clean (0 status lines) |
| tree | `3979c681dc6b93604a3cd45d2d6b6a54c01d3d68` == CLOSURE_2_READY frozen write-tree == write-tree recorded in `receipts/20-lock.txt` |
| parent | single parent `9ff749c35f64068e156400d2ed37c0b144c2d56d` (J3 base, Bradley) |
| author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 2026-09-24 16:25:01 +0000 |
| trailers | none; message scanned for Co-authored/Signed-off/Generated/AI vendor names — none |
| closure-2 patch | `ux03b-source-frozen-closure2.patch` sha `7e9fed70ad5e2a90d20b04d10626cd20c36b626eaf5858eb0f07a43f7d70d612` == sha of `git diff 9ff749c 519b0122` (recomputed) |
| exported commit patch | `0001-UX-03b-…corre.patch` `git patch-id --stable` == that of `git format-patch -1 519b0122` (`0652048b…`) |
| bundle | `ux03b-c1-setup-correlation.bundle` verifies; prerequisite `9ff749c3…`; single head `519b0122… refs/heads/ux03b-c1-setup-correlation` |
| files | 11 changed (+2126/−99): the 9 grant-owned paths + `useExtensionPairing.identityWait.test.tsx` (owned, grant line 66) + `ImportDataScreen.restore.test.tsx` (parent-granted single-line path extension, `UX03B_CLOSURE_2_GRANT.md`) |

### Delta from closure-1 tree `3d621d60` → `3979c681` is exactly the granted three lines

```
identityWait.test.tsx:119   -    unmount();                      +    await unmount();
useExtensionPairing.test.tsx:1327
  -    expect(await readImportPairingMirror('coach-1')).toBeNull();
  +    expect((await readImportPairingMirror('coach-1'))?.code ?? null).toBeNull();
ImportDataScreen.restore.test.tsx:87   +      setupNonce: 'seeded-nonce-0001',
```
3 files, 3 insertions, 2 deletions; no other hunk. Each matches the closure I specified in B1–B3 and the parent's grant wording (`?.code ?? null` for B1). B1's rewritten assertion still pins the intent (the cancelled attempt's late code `111111` must not be mirrored) and the following assertions in that test still pin `222222` as the live mirrored code — not weakened.

Chain: `4b92827d` (SOURCE_READY) → `3d621d60` (closure-1: one annotation, verified earlier) → `3979c681` (closure-2: three lines, verified here) → committed as `519b0122`. No product source line changed after the original freeze.

## Gate run 3 receipts (tree `3979c681`, lock held 16:23:35Z–16:24:19Z)

| gate | receipt | result |
|---|---|---|
| tsc | `21-tsc.log` | rc=0 |
| eslint (8 owned files) | `22-lint.log` | rc=0 |
| Jest (11 slot suites) | `23-jest.log` | rc=0 — **Test Suites 11/11, Tests 396/396**, 6.9 s |

Test count is identical to run 2 (396), as the grant required; the 7 previous failures became passes with no test removed or skipped (no `skipped`/`todo` in the summary). The remaining `[importPairingMirror] shape or version drift discarded` console warnings in the hook suite come from the v1-discard / malformed-record tests and are expected output, not failures. Prior receipts (`0*`, `1*`, `STEP5_STOP_REPORT_01.md`) are preserved unchanged (sha-listed in `MANIFEST.sha256`).

Ordering note: run 3 executed on the staged tree before the commit was created (16:24 vs 16:25); the commit's tree equals the gated tree, so the receipts bind to this head.

## Masked-assertion check on the 7 recovered tests

Read the bodies after their former failure points: B1 continues to exact `toBe`/`?.code` assertions and init call counts; B2's restore tests assert `pairing-waiting`, the same code text, `mockInit` not called and `mockStatus` called with the code; B3's four transition tests assert status strings, init counts and a `?.code` read of a fully-minted record. None uses substring/`toHaveTextContent` masking or a vacuous matcher. Consistent with the builder's static check in CLOSURE_2_READY.md.

## Findings

- **A:** none.
- **B:** none open. B1–B3 (run-2) closed by the granted three lines; verified above.
- **C (recorded only, no new work):** C1–C9 from the preliminary note stand unchanged. Add **C10** (grant-mandated qualification, parent already recorded): a pre-change mirror record has no nonce and is discarded on upgrade, so a coach mid-session gets a new code rather than resuming — correct under the version rule; nothing is deployed, no customer affected.

## What ACCEPT means here

The candidate at `519b0122` satisfies the UX-03b grant at the fixture-derived, mocked consumer level: additive types with fail-closed decoders; `init` carries `setup_nonce` body-only; no redeem from mobile; mirror v2 with v1 discard and pre-init record; nonce generated once, persisted before network, replayed on same-intent retry and cold hydration, discarded on 409/owner change/codeless terminals; 410 → `expired/challengeUnavailable` with setup kept; grant copy present; secrets absent from URL/log/analytics; no G3-AUTH claims. It is **not** deployment, integration, or customer acceptance — S11/S12 evidence must be produced separately.

## Files in this directory

- `UX03B_FINAL_FINDING_B_CLOSURE2.md` — this file (governing verdict)
- `UX03B_FINAL_FINDING_B.md` — run-2 NOT ACCEPT record, unchanged
- `UX03B_PRELIMINARY_NOTE_B.md` — Phase 1 source pass, C1–C9
- `13-jest.plain.log`, `23-jest.plain.log` — ANSI-stripped copies of runs 2 and 3
- `regen_fixture.json` — independently regenerated fixture (byte-identical to committed)
- `MANIFEST.sha256` — regenerated to cover all outputs and inputs
