# UX-03b — FINAL FINDING, independent T4 reviewer A

Date: 2026-09-24 16:26Z (09:26 PDT). Reviewer A worked read-only on product; never read `ux03b-review-b/`.
Route requested: Claude Fable 5 / High. No telemetry is available to reviewer A; no claim is made that this route
was actually used (G-doctrine: never claim a model/effort without telemetry).

## VERDICT: **ACCEPT** — commit `519b01227f2855fc7968994d389094008f222e20` on `ux03b-c1-setup-correlation`

Scope of this acceptance (honest boundary): static adversarial review of the committed source plus binding of the
builder's mocked, fixture-derived gate receipts. It is **local proof only**. It is NOT: a live-backend run, a device
run, an E2E, a deployment, a customer acceptance, or any G3-AUTH (locator / revocation / disconnect / capability)
claim. Nothing is pushed; nothing is deployed.

No open A. No open B. C items recorded below create no new work.

---

## 1. Head binding (all verified by reviewer A with `git cat-file -p HEAD`, `git rev-parse`, `git diff`)

| item | required | actual | ✓ |
|---|---|---|---|
| HEAD | single commit on branch | `519b01227f2855fc7968994d389094008f222e20`, branch `ux03b-c1-setup-correlation` | ✓ |
| tree | closure-2 frozen write-tree per `ux03b/CLOSURE_2_READY.md` | `3979c681dc6b93604a3cd45d2d6b6a54c01d3d68` | ✓ |
| parent | exactly one, `9ff749c3…` | `parent 9ff749c35f64068e156400d2ed37c0b144c2d56d` (1 parent line) | ✓ |
| author | Bradley Gleave <bradley@bradleytgpcoaching.com> | same, ts 1790267101 +0000 | ✓ |
| committer | same | same, same timestamp | ✓ |
| trailers | none / no AI markers | message body only; no `Co-authored-by`, `Signed-off-by`, or AI/tool names | ✓ |
| `git diff 9ff749c HEAD \| sha256` | == closure-2 frozen patch | `7e9fed70ad5e2a90d20b04d10626cd20c36b626eaf5858eb0f07a43f7d70d612` (== `ux03b-source-frozen-closure2.patch`) | ✓ |
| worktree | clean, HEAD == receipt tree | `git status --short` empty; `git diff --stat 3979c681 HEAD` empty | ✓ |
| pushed | no | no remote ref for the branch | ✓ |
| hooks | none configured | no `core.hooksPath`; only `.sample` files | ✓ |
| exports | bundle + format-patch + sha list | `git bundle verify` ok, head `519b0122…`; `0001-…patch` `From 519b0122…`; `RECEIPTS_SHA256.txt` all OK via `sha256sum -c` | ✓ |

## 2. Delta discipline: 4b92827d (original freeze) → 3979c681 (committed) is exactly the granted lines

`git diff --stat 4b92827d 3979c681`: 4 files, +4 / −3.

| grant | file:line | exact change |
|---|---|---|
| TSC closure 1 (`UX03B_TSC_CLOSURE_GRANT.md`) | `src/types/__tests__/extensionImport.contract.test.ts:493` | `const example = {…}` → `const example: Record<string, unknown> = {…}` |
| Closure 2 B1 | `src/hooks/__tests__/useExtensionPairing.test.tsx:1327` | `expect(await readImportPairingMirror('coach-1')).toBeNull()` → `expect((await readImportPairingMirror('coach-1'))?.code ?? null).toBeNull()` |
| Closure 2 B2 (path extension) | `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx:87` | `+ setupNonce: 'seeded-nonce-0001',` (pure insertion in `seedMirror`) |
| Closure 2 B3 | `src/hooks/__tests__/useExtensionPairing.identityWait.test.tsx:119` | `unmount();` → `await unmount();` |

No other line differs. No product (non-test) file was touched by either closure. No guard was relaxed. Test counts
unchanged by the closures (identityWait 7, restore 5; hook test 88 `it` both before and after closure 2).
Intermediate freeze `3d621d60…` (closure 1) verified earlier: delta from `4b92827d` was exactly the L493 annotation.

## 3. Gate receipts (read-only from `execution/cf8ff737/ux03b/receipts/`)

| run | tree | tsc | eslint | Jest | disposition |
|---|---|---|---|---|---|
| 1 (`00-`, `01-`) | 4b92827d | rc2 — one TS2339 at contract test 496:51 | not run | not run | stopped; closure 1 granted |
| 2 (`10-`…`13-`) | 3d621d60 | rc0 | rc0 | rc1 — 3/11 suites, **7/396** failed | stopped; closure 2 granted |
| 3 (`20-`…`23-`) | **3979c681** | **rc0** | **rc0** | **rc0 — 11/11 suites, 396/396 passed**, 0 skipped/todo | committed |

Run-3 lock line binds the run to write-tree `3979c681…` == committed tree. Total test count 396 is identical in
runs 2 and 3, so the closure added or removed no test. No `.only`/`.skip`/`xit` in any gated suite (grep). The
identityWait "transitions" tests passing with only the `await unmount()` change empirically confirms reviewer A's
static hypothesis (RNTL 14 async `act`; un-awaited async unmount leaked an act scope so `renderHook`'s passive
effect never set `result.current`). Earlier receipts are preserved unchanged (G: failures remain failures).

## 4. Adversarial checklist (from the grant) — static, against the committed tree

| check | result |
|---|---|
| Fixture byte-derived from frozen artifact `bdb022dd…` @ a0ea1bea | PASS — reviewer A re-ran the extractor on `git show a0ea1bea:docs/contracts/importer-openapi.json` (sha bdb022dd…) → byte-identical to `src/types/__fixtures__/c1PairSurface.a0ea1bea.json` (sha `618007f4…`, blob `7a588901…` in HEAD) |
| Types/decoders fail closed | PASS — `decodePairCurrentResponse` → `UNKNOWN_PAIR_CURRENT` for non-object / missing required / non-string status (10 shapes tested); `decodePairInitErrorCode` closed list from `PAIR_INIT_ERROR_CODES`, which the contract test pins equal to the fixture's 409/410 single-member enums; `decodeImportIntentId` non-string → null |
| `setup_nonce` body-only | PASS — `init` posts `{…, setup_nonce}`; `current` posts `{setup_nonce}`; tests assert path constant, no `?`, `JSON.stringify(config)` free of nonce; hook telemetry scan asserts nonce/key/code/intent absent from every `track` payload |
| Pairing code never in URL/log/analytics/new storage | PASS — status posts code in body; mirror schema unchanged in what it stores (code was already mirrored, v2 adds only nonce + optional intent id); no new log of code; C-4 pre-existing warn noted |
| Redeem not called from mobile | PASS — API surface exactly `['current','init','status']`, `redeem` undefined (tested); contract test pins redeem `security` undefined and token fields required (mobile must never call) |
| Mirror v2 version rule | PASS — v1 discarded via existing `version !== IMPORT_PAIRING_MIRROR_VERSION` rule, key removed, logged; no migration or restoration claim anywhere; grant's C qualification (upgrade → fresh mint) recorded by parent |
| Nonce persisted before init; replayed on retry and hydration | PASS — hook writes pre-init record (`code:null`) and awaits it before `extensionPairApi.init`; `go('minting')` no longer clears the mirror; transient `failed` keeps key+nonce; retry replays both; E01 test replays a seeded pre-init record on relaunch with no RESTORED claim |
| 409 `setup_nonce_conflict` | PASS — requires `AxiosError` 409 AND body `code === 'setup_nonce_conflict'`; nulls nonce+key, clears mirror, `go('failed', ref, 'conflict')`, analytics `{platform, reason:'conflict'}`; 409 without code → generic failure keeping the intent |
| 410 `setup_challenge_unavailable` | PASS — requires 410 AND code; `go('expired', ref, 'challengeUnavailable')`; EXPIRED tracked, FAILED not; copy exactly "Your code is no longer valid; your setup is kept" / "Get a new code"; 410 without code → generic |
| `import_intent_id` correlation-only | PASS — captured into a ref + mirrored; never appears in any branch condition; test "an import_intent_id alone never promotes to paired" |
| No locator/revocation/disconnect/mismatch/capability claims | PASS — none in source, copy constants, tests, or commit message |
| Panel return shape backward compatible | PASS — `{status, code, supportReference, start, retry, cancel}` preserved; `importIntentId`/`reason` optional additions; all four `ExtensionPairingPanel*` suites pass unchanged |
| Owner-change stale-attempt handling | PASS — `stale()` includes `userIdRef.current !== owner`; only the OLD owner's key is cleared, in both pre-init and post-init branches |
| Tests meaningful / not vacuous | PASS — see PRELIM_NOTE_A §"Owned-test adequacy"; negatives use captured random uuids; exact enum/key-set/copy pins; no masked assertions found in runs 2–3 |

## 5. Findings

### A — none.

### B — all closed inside this commit (recorded for history; none open)

| id | where | what | closure (verified exact) |
|---|---|---|---|
| UX03B-A-01 (predicted in PRELIM) | `ImportDataScreen.restore.test.tsx` seed | v2 seed lacked `setupNonce`; fail-closed reader discarded it → 2 restore tests failed in run 2 | closure-2 B2, one inserted line, parent path-extension granted |
| run-2 hook stale assertion (reviewer A missed in PRELIM; found in run-2 analysis) | `useExtensionPairing.test.tsx:1327` | pre-UX-03b `toBeNull()` on the mirror during the retry's `minting`; the live retry's grant-mandated pre-init record is legitimately present; received `code:null` proved the stale `'111111'` was NOT mirrored | closure-2 B1: assert mirrored `code` null |
| run-2 identityWait ×4 | `identityWait.test.tsx:119` | un-awaited async `unmount()` under RNTL 14 leaked an act scope → `result.current` null in the next four tests | closure-2 B3: `await unmount()`; confirmed by run 3 |
| run-1 TS2339 | contract test 493/496 | spread of a typed example lost the index signature | closure 1: local `Record<string, unknown>` annotation |

### C — recorded only; no new work

- C-1 `PAIRING_REASON_COPY` is exported and pinned by test but the UX-03a panel does not yet render `reason`;
  composition is sequenced later per grant. The hook is truthful today (status still `failed`/`expired`).
- C-2 After an E01 replay where the coach never saw a code, a 410 shows the "no longer valid" copy; grant-mandated.
- C-3 Transient `failed` clears the on-disk mirror while key+nonce stay in memory; pre-existing behaviour, not
  changed by UX-03b; same-intent retry still replays both.
- C-4 Pre-existing `logger.warn('corrupt JSON discarded', err)` in the mirror could include a raw fragment in DEV
  logs; not introduced by UX-03b.
- C-5 B1 closure asserts only `code` null; a stronger pin (record's `idempotencyKey === mockInit.mock.calls[1][1]`)
  would also prove WHICH attempt's record is present. Not needed for the property under test.
- C-6 `importIntentId` captured from a `/status` reply reaches published state only on the next transition (ref is
  immediate). Correlation-only; no product consequence.
- C-7 Pre-existing "not wrapped in act" `console.error` noise in the unchanged J3 `ImportDataScreen.test.tsx`
  (present in runs 2 and 3; suite passes). Not UX-03b's.
- C-8 Reviewer A process note: PRELIM scanned unchanged non-owned consumers for stale seeds but did not re-scan the
  pre-existing blocks of the OWNED hook test for `toBeNull()` mirror assertions during `minting`; run 2 caught it.

## 6. What this acceptance unlocks / does not

- Unlocks: parent may treat UX-03b local proof as accepted for merge sequencing and for UX-03 composition
  (panel rendering `reason`, sequenced separately).
- Does not: push, merge, deploy, or claim any device/E2E/live-backend/customer or G3-AUTH outcome. The commit
  remains unpushed local work on `ux03b-c1-setup-correlation`.

## 7. Reviewer A artifacts (all in `/home/user/workspace/execution/cf8ff737/ux03b-review-a/`)

- `PRELIM_NOTE_A.md` — Phase-1 static review + closure-1 binding + owned-test adequacy
- `GATE_RUN_2_ANALYSIS_A.md` — independent analysis of the 7 run-2 failures written before reading closure-2
- `UX03B_FINAL_FINDING_A.md` — this file
- `artifact-from-git-a0ea1bea.json`, `rederived-fixture.json` — independent fixture provenance
- `MANIFEST.sha256` — sha256 of reviewer-A files, the builder's receipts/patches/exports, and the fixture
