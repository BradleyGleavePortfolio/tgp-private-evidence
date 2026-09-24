# UX-03b — Independent Review B, preliminary note (Phase 1, source-level)

Reviewer: T4 independent reviewer B. Read-only on product. Requested route: Claude Fable 5 / High — **requested setting only; no telemetry claimed**.
Written: 2026-09-24 ~16:15Z. Never read `ux03b-review-a/`.

## Identity bound (read-only)

| item | value | verified how |
|---|---|---|
| worktree / branch | `worktrees/ux03b-correlation` / `ux03b-c1-setup-correlation` | `git branch --show-current` |
| base HEAD | `9ff749c35f64068e156400d2ed37c0b144c2d56d` (Bradley author+committer) | `git log -1` |
| frozen write-tree (SOURCE_READY) | `4b92827dde7ce72a0ed8c470b71c2e1fe4898bee` | `git write-tree` at 16:05Z |
| frozen patch sha | `abbef6d7…52de9d9d` == sha of `git diff --cached 9ff749c` | recomputed |
| closure-1 write-tree (CLOSURE_1_READY) | `3d621d600880b481375055e9d980196b23b263ff` | `git write-tree` at 16:11Z |
| closure-1 patch sha | `5d0032f0093254c89db856e80931653bd9ab02ee11cb8bf84abc7cd077ee0337` == sha of `git diff --cached 9ff749c` | recomputed |
| delta 4b92827d → 3d621d60 | 1 file, +1/−1: contract test line 493 gains `: Record<string, unknown>` and nothing else | `git diff 4b92827d 3d621d60` |
| staged paths | 9, all inside the grant's owned set | `git status --short` |
| contract copy | `c1-a0ea1bea-importer-openapi.json` sha `bdb022dd…26ba4e5`, identical to backend git object `a0ea1bea:docs/contracts/importer-openapi.json` | `git show` in `worktrees/s7-b-drain` |
| fixture | regenerated independently with `extract_pair_surface_fixture.py` → sha `618007f4…41d4878`, byte-identical to staged `c1PairSurface.a0ea1bea.json` | `regen_fixture.json` in this dir |

The closure-1 delta is exactly the parent-granted one-line annotation; `git diff 4b92827d 3d621d60` contains no other hunk.

## Adversarial source pass — findings by area

**Nonce lifecycle.** Generated once alongside the idempotency key (separate CSPRNG uuid via `generateIdempotencyKey`), stored only in refs and the user-scoped mirror; pre-init record `{code:null, expiresAt:null, idempotencyKey, setupNonce}` awaited before `init`; replayed on same-intent retry (refs kept on transient `failed`) and on cold hydration (restored pre-init record → `start()` reuses key+nonce, no RESTORED event); nulled on every codeless terminal, on 409 (`conflict`) and on owner change; a fresh pair is minted for every new intent. No cross-owner reuse path found.

**Mirror v2.** `version: 2`; v1 records discarded by the version rule (warn log, then remove); `setupNonce` required non-empty; `importIntentId` optional but non-empty if present; `code`/`expiresAt` nullable and coherent (code ⇒ expiresAt string); cross-user record discard retained.

**State machine.** Double-press guarded synchronously before the first await; 409 with code → refs nulled, `failed/conflict`, mirror cleared; 410 with code → `expired/challengeUnavailable`, setup (key+nonce) retained; 409/410 without code, 400, 429, transport → generic `failed` on the same intent; stale-epoch settle after cancel/owner change never shown or mirrored under the new owner; unmount tears timers down.

**Secrets.** API surface exactly `{current, init, status}`, all POST body-only, no redeem; `importIntentId` never enters a branch decision; analytics payloads are `{platform, reason}` only; the hook test serialises every `track` call and asserts absence of code/nonce/key.

**Decoders.** `decodePairCurrentResponse` fails closed to frozen `UNKNOWN_PAIR_CURRENT`; `decodePairInitErrorCode` is a closed set. Contract test bottom block derives examples from fixture schemas and pins required/optional/enum/security.

**No G3-AUTH claim found** in staged source or docs.

## Predicted gate outcome (static, before receipts)

One base assertion is stale against the intended new behaviour and was predicted to fail:
`useExtensionPairing.test.tsx:1327` — "same coach cancel→retry": after the retry's pre-init write, the mirror legitimately holds the retry's `{code:null, setupNonce}` record, so `expect(await readImportPairingMirror('coach-1')).toBeNull()` cannot hold. Intent of the assertion (cancelled attempt's code not mirrored) is preserved by asserting `?.code` is null.

(Confirmed by receipt `13-jest.log` — see final finding.)

## Class C (recorded only; no new work)

C1 transient `failed` clears the mirror while the nonce stays in memory (kill-after-transient-fail loses the nonce; server single-active-code supersedes).
C2 pre-init write failure uses fire-and-forget `void clearImportPairingMirror` before `init` (pre-existing pattern).
C3 mirror logs the `JSON.parse` error object (pre-existing v1 behaviour).
C4 API `current` tests use non-contract `{result:…}` mock payloads (passthrough only).
C5 `state.importIntentId` lags the ref until the next emit (documented).
C6 restored pre-init nonce reused if the platform slug changes → 409 path handles truthfully.
C7 legacy top half of the contract test has tautological assertions (pre-existing).
C8 `current` wired but unused by the hook (design note 1).
C9 stale-attempt **rejection** path (owner changed, init rejects) does not clear the old owner's pre-init record — only the success path does. Bounded: user-scoped key, no code on disk, sign-out sweep normally removes it; SOURCE_READY's "stale paths remove the pre-init record" is slightly over-stated.
