# S7-2′ pair-surface consumer freeze and UX-03b C1 setup-correlation consumer grant

Parent EXEC-CF8FF737, September 24, 2026. This grant is disposed from `ux03-handoff-prep/UX03_HANDOFF_READINESS_BRIEF.md` §3 row 3 and §5. It is a local, dark build only. It does not authorize remote push or merge, deployment, C1 activation, flag enablement or customer claims.

## Freeze disposition (technical, parent-owned; not a security or owner decision)

The **pair surface** of the accepted C1 contract is declared consumer-frozen at contract version `2.0.0-c1-s1.1`. Its source is backend commit `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, artifact `docs/contracts/importer-openapi.json`, with SHA-256 `bdb022dd6c4fb64cdf291fdde3796b99e4b23004f676b7cb46a58460526ba4e5`. The parent re-verified that SHA against the git object and confirmed the file is unchanged through B v5 at `0d69c7ba`.

### What the freeze covers

- Scope is exactly the five paths:
  - `/api/extension/pair/init`
  - `/api/extension/pair/status`
  - `/api/extension/pair/current`
  - `/api/extension/pair/session`
  - `/api/extension/pair/redeem`
- The freeze includes their transitively referenced component schemas.
- It excludes ingest, reconstruct and any other surface. R's pending ingest-DTO decision (D2) may regenerate other parts of the artifact, and the pair surface does not depend on it.

### Evidence required (G14)

The freeze is not declared by assertion. The UX-03b writer must:

1. Derive the consumer fixtures mechanically from the committed artifact. Use `execution/cf8ff737/ux03-handoff-prep/c1-a0ea1bea-importer-openapi.json` and record its sha before use.
2. Write the extracted pair-surface subset, with that recorded source sha, into a mobile `__fixtures__` path owned by this writer. This answers brief Q5.
3. Add a consumer contract test that decodes the fixture examples and schema through the mobile decoders.
4. Keep the backend byte-equal drift test, `test/contracts/importer-contract.spec.ts`, as the backend-side guard. It is not rerun here, because its accepted C1 evidence is unchanged.

### When the freeze must reopen

Any later backend change to the pair-surface subset reopens this freeze. R, N and C writers do not own pair DTOs.

### Decisions this grant does not make

This grant decides no locator, revocation, disconnect, account-mismatch, capability or retention question. Those remain G3-AUTH and owner matters.

## UX-03b tier and route

**T4:** credential-adjacent storage and a contract consumer.

Requested route: Claude Fable 5 / High. This is the requested setting only, not claimed telemetry.

After the build, two independent exact-head reviews run as a separate step.

## Sole writer and owned areas

### Worktree and dependencies

- Builder: this dispatch's single worker.
- Create a new worktree `worktrees/ux03b-correlation` on a new branch `ux03b-c1-setup-correlation`.
  - Base it on accepted J3 head `9ff749c35f64068e156400d2ed37c0b144c2d56d`.
  - Create it with `git worktree add` from the `worktrees/ux03-j3` repository.
- Do not touch `worktrees/ux03-j3` or `worktrees/ux03a-paired`.
- Copy dependencies physically with `cp -a` from `worktrees/ux03-j3/node_modules`.
  - First record that the lock sha is identical.
  - Do not hardlink, symlink or install.
  - Stop if less than 3 GiB of disk would remain.

### Product paths

These are the only product paths this writer may change:

- `src/types/extensionImport.ts` and `src/types/__tests__/extensionImport.contract.test.ts`
- `src/api/extensionPairApi.ts` and `src/api/__tests__/extensionPairApi.test.ts`
- `src/storage/importPairingMirror.ts` and `src/storage/__tests__/importPairingMirror.test.ts`
- `src/hooks/useExtensionPairing.ts` and `src/hooks/__tests__/useExtensionPairing{,.identityWait}.test.tsx`
- one new fixture file under `src/types/__fixtures__/`

### Evidence path

`execution/cf8ff737/ux03b/**`.

### Not owned

`ExtensionPairingPanel.tsx` and its tests are UX-03a's. The screens, presentation primitives, backend and extension are also not owned.

## Behavior

Follow brief §5 exactly.

### Types

Add optional `import_intent_id` and `setup_nonce` as additive fields. Add a `PairCurrentResponse` decode that fails closed to `'unknown'`. The `PairingStatus` union stays unchanged. `PairingState` gains an optional `importIntentId`, which is never used as UI truth.

### API

Send `setup_nonce`, and add a `current` call.

### Mirror

Move to v2 by adding `setupNonce` and an optional `importIntentId`. Discard v1 payloads under the existing version rule. This answers brief Q4.

### Hook

- Persist the nonce before init, and replay it on a same-intent retry.
- Map 409 `setup_nonce_conflict` as follows: discard the nonce and surface `failed` with reason `conflict` and the remedy "Get a new code".
- Map 410 `setup_challenge_unavailable` to expired-class state, with the copy "Your code is no longer valid; your setup is kept".
- Capture `import_intent_id` as correlation only.

### Invariants

- The code and nonce never enter a URL, log, analytics or telemetry.
- `redeem` stays extension-only, and mobile never calls it.
- No revocation or disconnect claims.
- The hook's public return shape stays backward-compatible for the panel.

## Gates

1. Author the source and fixtures, then report the frozen diff/tree to the parent. Then **wait for a heavy-slot relay**, queued after B v5 and UX-03a.
2. Under the slot, with nonblocking flock, run:
   - `tsc --noEmit`
   - lint on the changed paths
   - Jest on the owned test files, plus `ExtensionPairingPanel*` and `ImportDataScreen*` as unchanged-consumer regression
3. Make an ordinary commit with Bradley Gleave as author and committer. No AI trailers and no amend. No hooks are configured, so none are claimed.
4. Export a bundle and a patch.

The first nonzero result stops the run. Do not retry automatically.

## Out of scope

- J4 locator
- J5 account-mismatch and retired-challenge states
- J13 disconnect
- Capability lines
- Any extension behavior
- Composition with UX-03a, which the parent sequences after both are accepted
