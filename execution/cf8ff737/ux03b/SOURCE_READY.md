# UX-03b — C1 setup-correlation consumer build — SOURCE_READY

Status: **SOURCE FROZEN, NO RUNTIME GATES RUN.** Awaiting parent slot relay for
`execution/test-validation.lock` before tsc / lint / Jest. Not self-accepted.

## Identity

| item | value |
|---|---|
| repo worktree | `/home/user/workspace/worktrees/ux03b-correlation` |
| branch | `ux03b-c1-setup-correlation` |
| base commit (HEAD, unchanged) | `9ff749c35f64068e156400d2ed37c0b144c2d56d` |
| index `git write-tree` (staged owned paths) | `4b92827dde7ce72a0ed8c470b71c2e1fe4898bee` |
| frozen patch | `execution/cf8ff737/ux03b/ux03b-source-frozen.patch` (`git diff --cached 9ff749c`) |
| frozen patch sha256 | `abbef6d7820e41dc22e2682d010035c0d9de651ce95dae025f22831e0b52de9d` (119,391 bytes) |
| staged name-list sha256 | `eea926cf67ef144acafc924778f465490356a1b30f5c5eb143dc7937cc2729c3` |
| commit | none yet (step 5, after relay) |

## Diff stat (`git diff --cached --stat 9ff749c`)

```
 src/api/__tests__/extensionPairApi.test.ts         | 137 +++-
 src/api/extensionPairApi.ts                        |  72 +-
 src/hooks/__tests__/useExtensionPairing.test.tsx   | 357 ++++++++-
 src/hooks/useExtensionPairing.ts                   | 233 +++++-
 src/storage/__tests__/importPairingMirror.test.ts  |  63 +-
 src/storage/importPairingMirror.ts                 |  69 +-
 src/types/__fixtures__/c1PairSurface.a0ea1bea.json | 862 +++++++++++++++++++++
 .../__tests__/extensionImport.contract.test.ts     | 310 ++++++++
 src/types/extensionImport.ts                       | 117 ++-
 9 files changed, 2123 insertions(+), 97 deletions(-)
```

All nine paths are grant-owned. Nothing outside the grant was touched:
`src/hooks/__tests__/useExtensionPairing.identityWait.test.tsx` was reviewed and
needs no change (it pins no mirror shape and no init arity). No panel, screen,
primitive, backend, or extension file changed. `worktrees/ux03-j3` and
`worktrees/ux03a-paired` untouched (the latter does not exist locally).

## Environment facts

| item | value |
|---|---|
| `package-lock.json` sha256 (ux03-j3 == ux03b-correlation) | `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69` |
| node_modules provisioning | `cp -a` from `worktrees/ux03-j3` (699 top-level entries match); no install, no hardlink/symlink |
| disk free before copy | 7,423,127,552 B; node_modules 607,674,962 B |
| disk free after copy / now | ~5.4 GiB / 5,001,715,712 B |
| contract source sha256 (verified before extraction) | `bdb022dd6c4fb64cdf291fdde3796b99e4b23004f676b7cb46a58460526ba4e5` |
| contract version / backend commit | `2.0.0-c1-s1.1` / `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |

## Fixture extraction (mechanical)

- Script: `execution/cf8ff737/ux03b/extract_pair_surface_fixture.py` (deterministic; verifies the
  source sha256 before any extraction and embeds it under `$fixture.source.sha256`).
- Method: exact copy of the five pair path items (`/api/extension/pair/{init,status,current,session,redeem}`);
  transitive closure of every `#/components/schemas/*` `$ref` reachable from them
  (ErrorEnvelope, PairCurrentDto, PairInitDto, PairInitResult, PairRedeemDto, PairRedeemResult,
  PairSessionDto, PairSessionResult, PairStatusDto, PairStatusResult, RateLimitError);
  security schemes named by their `security` requirements (`bearer`); `info`, `openapi` copied;
  re-serialised with sorted keys, 2-space indent, trailing newline.
- Output: `src/types/__fixtures__/c1PairSurface.a0ea1bea.json`
  sha256 `618007f4ae6d6d9eca922b3f117703fd2b21ce49f0058f0f594af91a541d4878` (28,932 bytes),
  re-run twice → byte-identical.

## What was built (per grant)

**Types (`src/types/extensionImport.ts`)** — additive: `PairInitRequest.setup_nonce?`,
`PairInitResponse.import_intent_id?`, `PairStatusResponse.import_intent_id?`; new
`PairCurrentRequest`, `PairSessionRequest`, `PairCurrentResponse` (+ alias `PairSessionResponse`),
`DecodedPairCurrent`, `UNKNOWN_PAIR_CURRENT`, `decodePairCurrentResponse` (fails closed to
`'unknown'` for unrecognised enum AND non-contract shape: non-object, array, missing/empty required
field, non-string status), `decodeImportIntentId`, `PAIR_INIT_ERROR_CODES`
(`code_mint_failed | setup_nonce_conflict | setup_challenge_unavailable`), `decodePairInitErrorCode`.
`PairingStatus` union unchanged.

**API (`src/api/extensionPairApi.ts`)** — `init(chosenPlatform, idempotencyKey, setupNonce)` sends
`{ chosen_platform, setup_nonce }` body + `Idempotency-Key` header; `status(code)` unchanged;
new `current(setupNonce?)` → POST `/extension/pair/current` body `{}` or `{ setup_nonce }`.
Surface is exactly `{ current, init, status }` — no redeem.

**Mirror (`src/storage/importPairingMirror.ts`)** — `IMPORT_PAIRING_MIRROR_VERSION = 2`.
Record gains required `setupNonce` and optional `importIntentId` (key omitted when absent; empty
string invalid). `code: string | null`, `expiresAt: string | null` — null only on a pre-init record;
a record WITH a code must carry the verbatim `expiresAt` string exactly as v1. v1 payloads are
discarded by the existing version rule (no migration).

**Hook (`src/hooks/useExtensionPairing.ts`)**
- Nonce minted with the Rule 19 key (separate uuid), persisted as a pre-init record (`code: null`)
  BEFORE `/pair/init`, replayed on same-intent retry (transient failure) and after an E01 process
  death (pre-init record hydration sets key/nonce/intent refs and replays the pending start; no
  RESTORED event because no code was restored).
- 409 + `setup_nonce_conflict` → nonce AND key discarded, `status: 'failed'`, `reason: 'conflict'`,
  analytics `IMPORT_PAIRING_FAILED { reason: 'conflict' }`; `PAIRING_REASON_COPY.conflict.remedy`
  = "Get a new code".
- 410 + `setup_challenge_unavailable` → `status: 'expired'`, `reason: 'challengeUnavailable'`,
  `IMPORT_PAIRING_EXPIRED` tracked; copy "Your code is no longer valid; your setup is kept",
  remedy "Get a new code". `go('expired')` retires key + nonce (retry mints a fresh challenge).
- 409/410 WITHOUT the contracted code, 400, 429, transport → generic `failed` (intent kept).
- `import_intent_id` from init/status replies captured into `importIntentId` (state + mirror),
  correlation only; reset on a new intent; never read in any branch decision.
- `PairingState` gains optional `importIntentId?`, `reason?`. `PairingReason`,
  `PAIRING_REASON_COPY` exported. Public return shape backward-compatible: the panel's
  `{ status, code, supportReference, start, retry, cancel }` destructure is unchanged.
- `go(next, supportReference, reason)` no longer clears the mirror on the `'minting'` transition
  (the pre-init write overwrites it immediately); every other codeless transition clears as before.
- Stale-attempt paths (owner changed) remove the pre-init record this attempt wrote, matching the
  existing post-write rule ("nothing this attempt put on disk survives an owner change").

## Design notes for reviewers

1. **`current` is wired in the API but deliberately NOT called from the hook.** The grant's hook
   bullets (persist/replay nonce, 409/410 mapping, capture `import_intent_id`) do not require a
   `pair/current` read; adding one would add a network round-trip and a second, possibly stale,
   status source next to the authoritative `/pair/status` poll. The decoder (`decodePairCurrentResponse`)
   and wire test exist so a later slice can consume it without touching the contract layer.
2. **Pre-init record shape.** Nullable `code`/`expiresAt` (rather than a separate key) keeps one
   user-scoped key swept by signOut and the existing version/shape/user guards; the guard requires
   `expiresAt` to be a string whenever `code` is present, so v1 semantics for "real" records are
   unchanged.
3. **Transient `failed` still clears the mirror** (pre-existing behaviour) while key + nonce stay in
   memory; a retry rewrites the pre-init record. E01 (kill between request and reply) is the durable
   case and is covered.
4. **Invariants held:** code/nonce/key never in a URL, log, or analytics payload (tests assert the
   nonce and key from every init call are absent from all tracked payloads); mobile has no redeem
   method (test pins the API surface); no revocation/disconnect claim anywhere; `importIntentId`
   never drives status.
5. **Class-C notes (record/continue):** a repo-wide test that enumerates `src/**` JSON files (if any)
   is outside the owned regression set and was not run; `react-hooks/exhaustive-deps` is warn-level
   in this repo (`--max-warnings=99999`), and all new callbacks list their deps anyway.

## Runtime gates

**None run.** No `tsc`, `eslint`, or `jest` process has been started in this worktree. Static review
of TS narrowing (`key`/`nonce` are `string` at the init call via the `if (!key || !nonce)` block
whose catch returns), JSON module import (precedent: `import en from './en.json'` in this repo with
`resolveJsonModule` + `esModuleInterop` from `expo/tsconfig.base`), and test/mock arity was done by
reading only.

Planned under the slot (step 5, `flock -n execution/test-validation.lock`):
1. `npx tsc --noEmit`
2. `npx eslint <the 8 changed .ts/.tsx paths> --max-warnings=99999`
3. `npx jest src/types/__tests__/extensionImport.contract.test.ts src/api/__tests__/extensionPairApi.test.ts src/storage/__tests__/importPairingMirror.test.ts src/hooks/__tests__/useExtensionPairing.test.tsx src/hooks/__tests__/useExtensionPairing.identityWait.test.tsx src/components/coach/__tests__/ExtensionPairingPanel src/screens/coach/__tests__/ImportDataScreen`
4. First nonzero exit stops (preserve, no retry). On green: ordinary commit (Bradley Gleave
   <bradley@bradleytgpcoaching.com> author + committer, no AI trailers, no amend, no hooks claimed),
   `git bundle` + `git format-patch` into `execution/cf8ff737/ux03b/`, receipts, report head/tree.
   Never push.

## Stop point

STOPPED here per grant step 4. Waiting for the parent's slot relay. `execution/test-validation.lock`
has not been touched.
