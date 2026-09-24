# UX-03b independent review A — preliminary note (Phase 1, frozen source)

Reviewer A, T4, read-only. Written 2026-09-24 ~16:15Z against the STAGED source in
`worktrees/ux03b-correlation` (HEAD `9ff749c35f64068e156400d2ed37c0b144c2d56d`, index write-tree
`4b92827dde7ce72a0ed8c470b71c2e1fe4898bee`). No tsc/lint/Jest run by this reviewer. Scope: fixture-derived
mocked consumer coverage only; no live backend, device, E2E, deployment or G3-AUTH claim.

## Identity re-verified by reviewer A

| check | result |
|---|---|
| `git write-tree` of staged index | `4b92827dde7ce72a0ed8c470b71c2e1fe4898bee` (matches SOURCE_READY) |
| `git diff --cached 9ff749c \| sha256sum` | `abbef6d7820e41dc22e2682d010035c0d9de651ce95dae025f22831e0b52de9d` == published patch |
| staged name-list sha | `eea926cf…` matches; 9 paths, all grant-owned |
| worktree == index | clean (`git diff --stat` empty) |

## Fixture derivation — independently re-derived (PASS)

- `git -C worktrees/s7-b-drain show a0ea1bea92ba…:docs/contracts/importer-openapi.json` → sha256
  `bdb022dd6c4fb64cdf291fdde3796b99e4b23004f676b7cb46a58460526ba4e5`; byte-equal (`cmp`) to the published
  copy `ux03-handoff-prep/c1-a0ea1bea-importer-openapi.json`. Saved as `artifact-from-git-a0ea1bea.json` here.
- Independent Python (not the builder's script): all five pair path items deep-equal the git artifact; my own
  transitive `$ref` closure = exactly the 11 schemas in the fixture and each is deep-equal to source;
  `securitySchemes` = `{bearer}` deep-equal; `info`/`openapi` equal; `info.version` `2.0.0-c1-s1.1`.
- Builder's `extract_pair_surface_fixture.py` re-run on the git-derived artifact → byte-identical to the staged
  fixture (`618007f4ae6d6d9eca922b3f117703fd2b21ce49f0058f0f594af91a541d4878`, 28,932 B).
- Contract facts used below: `pair/init` 409 and 410 envelopes have `code` **required** with single-member
  enums; 400 `code` optional; `pair/redeem` has **no security**; `PairSessionResult` requires
  `import_intent_id`, `status`, `chosen_platform`.

## PREDICTED GATE-3 FAILURE (B, proof-invalidating) — UX03B-A-01

**Observation (static, deterministic).** `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx`
(unchanged, J3-owned, in the grant's Jest regression list `src/screens/coach/__tests__/ImportDataScreen`)
seeds a mirror record directly into AsyncStorage:

```ts
JSON.stringify({ version: IMPORT_PAIRING_MIRROR_VERSION, userId, platformId, code,
                 expiresAt: '2026-07-27T10:15:00.000Z', idempotencyKey: 'seeded-key-0001' })
```

It imports the real `IMPORT_PAIRING_MIRROR_VERSION` (now 2) and the real `readImportPairingMirror` path
(only `extensionPairApi` is mocked). The v2 guard `isMirroredPairingSession` requires
`isNonEmptyString(v.setupNonce)`; the seeded record has none → discarded and key deleted. The screen peek
(`ImportDataScreen.tsx` L76-90) then finds no pending record and stays on `intro`.

**Predicted failing assertions (2 of 5 in that file):**
1. "re-enters the awaiting state for the mirrored platform and shows the SAME code, minting nothing" —
   `getByTestId('import-status')` throws (no panel mounted).
2. "names the platform honestly for a custom-URL session too" — `getByText(/Log in to your platform…/)` throws.
The other three cases (no session / peek race / flag OFF) still pass.

**Classification: B.** Concrete harm: the UX-03b Jest gate cannot go green; **no product defect** — the
product behaviour (discard a malformed v2 record lacking its nonce) is the designed rule. Exact decision
blocked: UX-03b commit and acceptance. **Minimum closure:** add one field
`setupNonce: 'seeded-nonce-0001',` to `seedMirror()` in `ImportDataScreen.restore.test.tsx` (one line; no
assertion change; test count unchanged). That file is outside the grant's owned paths, so the parent must
extend the writer's path grant for that single line (J3 is accepted at `9ff749c`, so no live writer is
displaced). Execution unlocked: rerun step 5 from gate 1 into new receipts.

**Not acceptable closures:** relaxing the v2 guard to make `setupNonce` optional (weakens the designed
shape rule and re-opens the v1-discard question).

Builder's SOURCE_READY claim "identityWait needs no change (pins no mirror shape)" is true for that file but
the same check was not applied to the `ImportDataScreen*` regression set.

## Phase-1 review of the frozen source (continuing; findings so far)

### Types / decoders — PASS
- `decodePairCurrentResponse(raw: unknown)`: non-object/array/null → `UNKNOWN_PAIR_CURRENT`; missing/empty
  `import_intent_id` or `chosen_platform`, non-string `status` → `UNKNOWN_PAIR_CURRENT`; unrecognised enum →
  `status: 'unknown'`. Never yields `paired` from a malformed payload. Matches the contract's three required
  fields.
- `decodePairInitErrorCode(unknown)`: closed list of the three contracted codes; anything else `'unknown'`.
- `decodeImportIntentId`: non-string/empty → null. No coercion.
- `PairingStatus` union unchanged (verified diff). `PairingState.importIntentId?` and `reason?` optional.

### API — PASS
- `init(chosenPlatform, idempotencyKey, setupNonce)`: `setup_nonce` in POST **body** only; header carries only
  the Rule-19 idempotency uuid (pre-existing). `status(code)` body-only. `current(setupNonce?)` body
  `{}`/`{setup_nonce}`. Module exports exactly `{ current, init, status }` — **no redeem**. Paths are
  relative constants; no interpolation of code or nonce into any path/query.
- Nonce and key are distinct uuids from `generateIdempotencyKey()` (v4 via `crypto.getRandomValues`, throws
  without CSPRNG — start() fails visibly on that path).

### Mirror v2 — PASS
- `IMPORT_PAIRING_MIRROR_VERSION = 2`; v1 (`version: 1`) fails the version check → discarded and key deleted on
  read (pre-existing designed mechanism). Prose says "coach simply re-mints"; no data-restoration claim.
- Guard: `code` null|non-empty; `expiresAt` null|string; a record WITH a code must have string `expiresAt`;
  `setupNonce` required non-empty; `importIntentId` absent or non-empty string.
- C (record only): `logger.warn('… corrupt JSON discarded', err)` is pre-existing; V8 `JSON.parse` SyntaxError
  messages can embed a fragment of the raw string. Not introduced by UX-03b; not a UX-03b blocker.

### Hook — PASS on the grant's behaviours (static)
- Nonce persisted BEFORE `/pair/init` as a pre-init record (`code: null`, `expiresAt: null`); write failure
  logged (values not logged) and stale record cleared.
- Same-intent retry: `go('failed')` keeps key+nonce in memory; `go('minting')` no longer clears the mirror and
  keeps key/nonce; retry replays the same `setup_nonce`. Every other terminal (`paired/expired/cancelled/
  authExpired/unavailable/identityUnavailable`) retires key+nonce.
- E01 hydration: pre-init record restores key/nonce/intent into refs, sets `hydratedRef`, replays a pending
  start (no RESTORED event); record with a code → `waiting` + immediate poll as before.
- 409 + `setup_nonce_conflict` → nonce AND key nulled, `go('failed', ref, 'conflict')`, analytics reason
  `'conflict'` (string only). 410 + `setup_challenge_unavailable` → `go('expired', ref,
  'challengeUnavailable')`, `IMPORT_PAIRING_EXPIRED` tracked. 409/410 without the contracted code, 400, 429,
  transport → generic `failed`. Copy constants exact: "Your code is no longer valid; your setup is kept" /
  remedy "Get a new code"; conflict remedy "Get a new code".
- `import_intent_id` captured from init and status replies into a ref + state + mirror; grep of all branch
  conditions: never read in any `if`. Reset on `minting`.
- Analytics payloads: `{ platform }`, `{ platform, reason }` only. No code/nonce/key in any `track`/`logger`
  call argument (grep of hook, api, mirror).
- Owner-change stale attempt: both the post-pre-init-write and post-init-reply stale checks remove the
  pre-init record this attempt wrote when `userIdRef.current !== owner`; user-scoped key means only the old
  owner's key is touched.
- Public return `{ ...state, start, retry, cancel }`; panel destructures `{ status, code, supportReference,
  start, retry, cancel }` unchanged; new members optional. Panel tests mock the hook module wholesale.
- No revocation/disconnect/locator/mismatch/capability claim in any added prose or copy (grep).

### C notes (record only, no new work)
- C-1: `PAIRING_REASON_COPY` is exported but the panel (UX-03a-owned) does not render `reason` yet;
  composition is explicitly sequenced after both acceptances. Truthful copy exists at the hook boundary only.
- C-2: 410 copy "Your code is no longer valid" can surface after an E01 replay where the coach never saw a
  code. Grant-mandated copy; remedy path is correct; cosmetic.
- C-3: transient `failed` clears the mirror while key+nonce stay in memory (pre-existing behaviour); a kill in
  that window starts a genuinely new intent. Server single-active-code invariant bounds it. Design note 3.

Owned-test adequacy review follows in the FINAL finding.

## Closure-1 binding (added ~16:20Z after parent mail)

- `UX03B_TSC_CLOSURE_GRANT.md` read. `ux03b/CLOSURE_1_READY.md` records new write-tree
  `3d621d600880b481375055e9d980196b23b263ff`, patch `ux03b-source-frozen-closure1.patch` sha
  `5d0032f0093254c89db856e80931653bd9ab02ee11cb8bf84abc7cd077ee0337`.
- Reviewer A re-verified: current index `git write-tree` = `3d621d60…`; `git diff --cached 9ff749c | sha256sum` =
  `5d0032f0…` (matches); `git diff 4b92827d 3d621d60` = 1 file, 1 insertion, 1 deletion, exactly
  `-      const example = {…}` → `+      const example: Record<string, unknown> = {…}` at contract test L493.
  No other change. Closure is exactly as granted. First-run receipts `00-lock.txt`, `01-tsc.log`,
  `STEP5_STOP_REPORT_01.md` present and consistent (one TS2339 at 496:51).
- `run_step5_gates.sh` read: flock -n on the shared lock; tsc → eslint (8 owned .ts/.tsx) → Jest on the 5 owned
  files + `ExtensionPairingPanel` + `ImportDataScreen` patterns; first nonzero stops. The Jest pattern DOES include
  `ImportDataScreen.restore.test.tsx`, so UX03B-A-01 above is expected to stop gate 3.

## Owned-test adequacy (Phase 1, read-only)

Counts (staged): contract test 41 `it` + 8 `it.each`; API test 27 + 1; mirror test 19 + 4; hook test 88 + 2.

- **Contract test** is genuinely fixture-driven: provenance pins (sha/commit/artifact/version), exact five paths,
  self-contained `$ref` closure equals `$fixture.extraction.schemas`, bearer on the four coach routes, redeem
  `security` undefined + `access_token`/`refresh_token` required (mobile-must-never-call), no coach success
  payload carries a token, 409/410 `code` REQUIRED single-member enums and 400 optional read FROM the fixture,
  `PAIR_INIT_ERROR_CODES` equals the fixture's pinned union, `PairInitRequest` keys equal the DTO property set,
  `PairSessionResult` required triple + no `pairing_code`, decoder examples derived by `exampleOf(schema)`, and
  10 fail-closed shapes for `decodePairCurrentResponse` asserted `toEqual(UNKNOWN_PAIR_CURRENT)`. Not vacuous.
- **API test**: body-only for nonce/code (path, `?`, and serialized config asserted), `Idempotency-Key` header only,
  409/410 propagate untouched, surface exactly `['current','init','status']`, `redeem` undefined, GET/DELETE unused.
- **Mirror test**: v1 record discard (version rule) with key deletion asserted; `setupNonce` empty/missing
  discard; code-without-expiry discard; pre-init round-trip; optional `importIntentId` round-trip and key
  absence.
- **Hook test**: nonce is uuid-v4 and ≠ key; pre-init record on disk while init is unanswered (deferred promise);
  same nonce+key on transient retry; fresh nonce after cancel; E01 replay of a seeded pre-init record with no
  RESTORED event; other-platform pre-init discard; 409 with code → `failed`/`conflict`, mirror null, retry uses new
  nonce AND key; 409 without code → generic, same nonce kept; 410 with code → `expired`/`challengeUnavailable`,
  EXPIRED tracked, FAILED not tracked, retry fresh nonce; 410 without code → generic; intent id captured from init
  and status, malformed dropped, reset on new intent, never promotes to paired; whole-flow telemetry scan for
  key/nonce/code/intent; return-shape destructure. Existing v1 hydration case updated to `version: 1` discard.
- Masked-assertion scan: no `expect.anything()`-only or always-true assertions found in the added blocks; the
  telemetry negatives use random uuids captured from actual `mockInit` calls, so they cannot pass trivially.
- Observation (C): `importIntentId` captured from a `/status` reply reaches state only on the next transition
  (ref updated immediately; the test acknowledges this). Correlation-only; no product consequence.
