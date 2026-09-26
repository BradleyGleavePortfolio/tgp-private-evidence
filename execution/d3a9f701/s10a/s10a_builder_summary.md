# S10-A builder summary: pure induction contract and evaluator

Worktree: `/home/user/workspace/worktrees/d3a9-s10a` (branch `exec-d3a9/s10a`, base `a4af8e33`).
Nothing is committed. I ran no tsc, jest, eslint, prettier or npm. The only commands I ran were
reads, `rg`, `git status` and two one-off `node -e` crypto calls: one to generate the test keypairs
and one to check that each fixture private key derives its fixture public key (both did).

`git status`: untracked only, and only in the owned paths: `src/scout/induction/`, `test/scout/induction/`, `test/fixtures/scout/s10_pure/`.

## Files (sha256)

| File | Lines | sha256 |
| --- | --- | --- |
| src/scout/induction/contract.ts | 173 | acd5495f81526481cc71bdeaba2cb0af1a2e57a91f0697ff69c496e314a44e89 |
| src/scout/induction/digest.ts | 115 | 7da8c7d7241528890511641b4c0453c9d8d2b47fbe58829db24b1fd2333f745a |
| src/scout/induction/parse.ts | 419 | 21276047939827bdd77ddb6b0a39a3bb0c51dd6c4a7f9e5470dcec0476e80f08 |
| src/scout/induction/manifest-registry.ts | 152 | 206591ae4a2acdc024f8bd282a41f1155d65afbee9db0a29a0d396f613ed3667 |
| src/scout/induction/verify.ts | 361 | 01e7e5ae58d0d84ad55ddf6bda3f0a8c7f00ba9e26984acf76d732b9fdffc3b3 |
| test/scout/induction/contract.spec.ts | 79 | bb3c0b08bbc463380633bde39489788dd4ee920bf5abf7a055a1e8cf15986776 |
| test/scout/induction/digest.spec.ts | 95 | 95abc21c10d375d7832cc4b11e68b023f63315317806101c7fe30e411dd1508c |
| test/scout/induction/parse.spec.ts | 269 | 6b8c36ad1aba68691c5c6048e1037156d2a4cc844105aaf5b9b1fc53a142be6d |
| test/scout/induction/manifest-registry.spec.ts | 251 | 7ca7ea48fa3e2049c121d5e16a53da5c15f51c3fecc99c3462da5e777e64aa05 |
| test/scout/induction/verify.spec.ts | 573 | e4b577217e212277fa2f96165c7a90f8dd28176c3ef840c4143d885039627054 |
| test/fixtures/scout/s10_pure/s10-pure-signer.ts | 90 | a744a021c641f5ad8646d244d15391df7ccdbd2f0ca3ccfd8e9f1c4aaef73e99 |
| test/fixtures/scout/s10_pure/signer-test-key.json | – | 5cf66cca595edad5329c5598871cc83506831358d13cf5546bf10fade4b0890f |
| test/fixtures/scout/s10_pure/induction/s10_unseen.json | – | 4cb13a629f98a3625d5208afd96abc028e7c47508b41841ebe19fd96cd93733a |
| test/fixtures/scout/s10_pure/mapping/s10_unseen.json | – | bb25f51ee01ea264d50c75603d8b63c1ba4fbe35d378d8d6bbcb41c41fb60a0a |

**Size:** about 1,220 lines of src and about 1,360 lines of tests and fixtures, 2,577 in total. This is over the ~1,500 target. Most of the overage is the per-case tests: every R24(a–k) case, and each V1–V6 rule, has its own non-vacuous assertion. The src is dense and has no dead code. If you want it smaller, the easiest cut is `parseObservationUpload` (about 45 lines plus tests) in parse.ts. It exists only for R21's "body > 32 KiB" case and could move to S10-B's DTO.

**Key material:** both keys are synthetic and test-only, and live only in `test/fixtures/scout/s10_pure/signer-test-key.json`.
- `source`: the stand-in for the synthetic `s10_unseen` source signer, and the only verifier in the fixture manifest.
- `observer`: a stand-in for a key that the extension or a client holds. It is never a verifier.

There is no real platform manifest, no real key and no `src/**/sources/*.json`.

## Clause → file:line

| Clause | Where |
| --- | --- |
| D-S10-1 `InductionManifestV1` shape | contract.ts:57-87 |
| V1 strict keys, version 1, canonical slug | parse.ts:352-362 (`parseInductionManifest`); strict keys via `assertKeys` parse.ts:316 |
| V1 file named `<sourcePlatform>.json` | manifest-registry.ts:46-50 |
| expectedFamilies sorted, unique, non-empty | parse.ts:364-376 |
| V2 exactly one spec; expectedFamilies = spec `families` keys; manifest without spec throws | manifest-registry.ts:96-100, 122-131 |
| V3 `declared` ⇔ rule set loaded; rule-set families ⊆ expected; rule set without spec throws | manifest-registry.ts:102-110, 132-145 |
| V4 basisKinds keys = expectedFamilies; values unique, never `none`; empty list = never provable | parse.ts:378-394 |
| V5 verifiers valid (strict keys, key_id grammar, `ed25519`, canonical b64, 32-byte importable key), unique key_id, non-empty basisKinds needs ≥ 1 verifier | parse.ts:330-345, 396-401 |
| V6 duplicates throw; absent dir → []; present-but-empty throws; invalid JSON names the file | manifest-registry.ts:28-57, 98, 105, 121 |
| Verifier custody rule | Doc comment at contract.ts:62-67. The manifest holds only the approved `verifiers` and the evaluator trusts nothing else (verify.ts:216-221). The custody fact itself is outside code (see ambiguity 7). |
| D-S10-2 `COMPLETENESS_BASIS_KINDS = ['none','source_signed_enumeration']` | contract.ts:16-21 |
| `OBSERVATION_CONFLICT_CODES` (D-S10-4) | contract.ts:24-32 |
| Statement and evidence shapes and bounds | contract.ts:39-146 |
| Strict RFC 4648 base64 (decode→re-encode identity) | parse.ts:69-80 |
| Strict canonical JSON (≤ 1024 bytes, no BOM, fatal UTF-8, exact keys, byte-identical re-serialisation, so no duplicates, whitespace, unsorted keys, non-integers or non-minimal escapes) | parse.ts:132-150; serialiser digest.ts:36-62 |
| Field grammar: hex64 digests, challenge exactly 32 bytes, `snapshot_ref_digest` 64 hex, `date_window` null, `terminal`, count in [0, 2^31-1], `issued_at` RFC 3339 UTC ≤ 32 bytes | parse.ts:152-168; issued_at parse.ts:94-111 |
| Evidence parse: key_id grammar, signature exactly 64 bytes, statement bounded before decode | parse.ts:197-237 |
| Body ≤ 32 KiB, ≤ 4 families × declared scopes, one entry per unit | parse.ts:253-289 |
| Ed25519 over the decoded bytes (node:crypto only) | Key import parse.ts:293-308; verify verify.ts:70-76, 216-219 |
| Identity digest (`<len>:<id>`, bytewise sort, distinct; empty set = sha256("")) | digest.ts:77-93 |
| Staged side from S9-B's own grouping (no re-derivation) | digest.ts:100-110 |
| `mapping_spec_digest` = sha256 of the spec's canonical JSON | digest.ts:112-115; bound at manifest-registry.ts:146-148 |
| D-S10-3 emitted families | verify.ts:266-270 (declared platforms), 317-326 (undeclared staged platforms) |
| E1 declaration | verify.ts:111-127 (a malformed declaration counts as none), 278-279, 317-326 |
| E2 presence and grammar | verify.ts:141-161, 175-178 |
| E3 binding (coach, intent, epoch, manifest, family, basisKinds, spec digest) | verify.ts:181-187 |
| E4 source verification | verify.ts:207-232 |
| E5 | verify.ts:233-234 |
| Dispatch on `basis_kind` only | verify.ts:189-203 |
| Family fact (all units proven, sum, AND of covers across platforms) | verify.ts:311-314, 329-344 |
| E6 partition agreement; multi-scope → unknown; digest and count rules | verify.ts:272-279, 292-310 |
| Total / never throws | verify.ts:351-361 (any unexpected exception → every canonical family `{known:false}`) |
| D-S10-8 no source literal in src | Enforced by contract.spec.ts:53-79 |

## Acceptance cases (all "A" cases: R20–R28)

| Case | Test location |
| --- | --- |
| R20 | manifest-registry.spec.ts: valid package, absent/empty dir, spec without manifest, V1–V6 throw cases, basisKinds without a verifier |
| R21 | parse.spec.ts (statement, base64, evidence, upload body); signature over the base64 text in verify.spec.ts:333 |
| R22 | verify.spec.ts:194 |
| R23 | verify.spec.ts:206 (composed with S9 `familyCoverage` → `'none'` plus the count) |
| R24 a–k, plus E2 duplicate/absent | verify.spec.ts:226-331. Each case changes exactly one thing from the proven baseline and asserts that only that family becomes `{known:false}`, with no `observed_unique`, and projects to `observed_unique: null`. |
| R25 | verify.spec.ts:393-472, including `requiredFamilies` and `coverageConditionHolds` composition for a declared, unstaged platform |
| R26 | verify.spec.ts:474 |
| R27 | verify.spec.ts:492 |
| R28 | Metamorphic rename in verify.spec.ts:532; literal scan in contract.spec.ts |

## Ambiguities resolved (all resolved conservatively, failing closed)

1. **Where `COMPLETENESS_BASIS_KINDS` lives.** `reconciliation/**` is not owned, so the list is defined in `contract.ts`. `types.ts`'s `COMPLETENESS_BASIS_NONE` is unchanged, and a test asserts it equals `KINDS[0]`.
2. **Loader imports.** The doc restricts S10-A to landed types, so `buildInductionRegistry` takes `{manifests, specs, nativeRuleSets}` as arguments instead of calling `loadSourceMappingSpecs` or `loadNativeRuleSets`. S10-B/C wire those loaders in. Two runtime imports go beyond the doc's type list, and both are already used by mapping-spec: `isCanonicalPlatform` (which the doc names) and `CANONICAL_FAMILIES` from mapping-spec.ts L69.
3. **"Rule set without spec throws"** applies to every loaded rule set, whether or not its platform has a manifest.
4. **E2 with rows of another binding.** Rows are grouped by the evidence's `(platform, scope, family)` before the binding check. A unit with two rows (for example, one stale-epoch and one current) is unproven rather than having the stale row skipped. This is stricter than "inert"; S10-C is expected to pass settle-epoch rows only.
5. **Stored evidence that fails to parse.** It poisons its own unit if it still names a platform, scope and family. If it names nothing, it poisons every unit (corrupt storage).
6. **Declared platform with no spec and no manifest.** All `CANONICAL_FAMILIES` are emitted as `{known:false}`, so the platform cannot disappear and `complete` stays unreachable.
7. **Custody.** It is an external governance fact, so no code tries to infer it. The fixture manifest lists only the source key. The observer-key cases are R24(a).
8. **`date_window` and `terminal`.** They are enforced at parse and again in E4, so R24(h) fails either way.
9. **`issued_at` window.** Fractions of up to 9 digits are allowed, and the window check uses conservative millisecond bounds (floor ≥ start, ceil ≤ received). Leap seconds (`:60`) are refused, and so are years that don't round-trip.
10. **Lone surrogates.** An identity id with a lone surrogate makes `identitySetDigest` return `null`, so the family fails rather than two ids colliding in bytes. Canonical JSON refuses lone surrogates too.
11. **E6 family-set disagreement.** This is modelled as `StagedPlatformFacts.grouped_families` (the family set S9-B grouped against), which must equal `expectedFamilies`. Any staged family key outside it, a platform supplied twice, or a family grouped twice (`null` digest) fails closed.
12. **Upload body cap.** "4 families × declared scopes" is taken as `CANONICAL_FAMILIES.length × declaredScopeCount`, passed by the caller (S10-B).
13. **Parse rejection reasons.** `ArtifactRejection` is a diagnostic union for tests and S10-B's 400 path. It is not a report or catalogue code (D-S10-8), and the evaluator never emits it.

## Not implementable purely, or intentionally left to later slices

- Evaluator failures carry no "why unknown" detail (per §5).
- The staged-side digests come from S10-C's `resolveFamily` grouping. R27 is tested here with a data model of that fallback, not the real `facts.service.ts`.
- There is no `src/scout/induction/sources/` directory, so the default loader returns `[]` (tested). The `nest-cli.json` asset entry is S10-D D1.
- The repo has no `test/fixtures/scout/s10_unseen/` yet; that is S10-D's allowed delta.

## For the parent's dev loop

- **Formatting:** prettier has not been run. I hand-wrapped the src code lines to 100 columns (only comments and template strings are longer, which prettier leaves alone). Several test lines are over 100 columns, so expect a formatting-only `prettier --write` on `test/scout/induction/*.spec.ts`.
- **Banned tokens:** none of the R75 tokens appear in these files. The only casts are `as readonly string[]` and `as Record<string, unknown>`, which already occur in mapping-spec.ts.
- **ES2021 target:** no `Object.hasOwn` is used. The regex lookbehind in digest.ts:13 is ES2018.

## Fix round 1 (response to s10a_review.md, NO-GO on findings 1–4)

Same rules as before: I ran no tsc, jest, eslint, prettier or npm, took no lock and made no commit. Every change is inside the owned paths.

1. **R27 (finding 1).** In verify.spec.ts, the R27 block is now titled "R27 (evaluator half) — evaluator family-set agreement given the caller-supplied grouped_families". Its comment says it proves only the evaluator side, using a hand-written model of S9-B `resolveFamily`. It adds that the production-grouping half of R27 is proved in S10-C. The disagreement case is retitled to "a family-set disagreement between the manifest and the caller-supplied grouped_families". No new mechanism was added.
2. **R25 (finding 2).** New test in verify.spec.ts, R25 block: "single scope: one declared unit without valid evidence → only that family unknown". There is one declared scope, and clients and workouts are fully proven. Two variants are tested:
   - `programs` has no row.
   - `programs` has a row with a zero signature.

   Both expect exactly `{clients: KNOWN(2), programs: UNKNOWN, workouts: KNOWN(3)}`, with no `observed_unique` on programs. The test is non-vacuous. If the `proven` gate (verify.ts ~L289-301) were removed, programs would be emitted `known: true` with `observed_unique: 0`, and the test would fail.
3. **R23 (finding 3).** The S9 verdict function `reconcile()` in `src/scout/reconciliation/reconcile.ts` is pure (no I/O, no DI). The new R23 test composes the evaluator's R23 output with native-clean facts through a new `cleanFacts` helper (verifiedRow-equivalent `present_owned` ledger rows for every baseline id).
   - **Positive control:** the same facts with the R22 output reconcile to `complete / null`.
   - **R23 case:** the result is `partial / coverage_basis_unknown`, and `report.conditions` is exactly `['coverage_basis_unknown']`.

   The arbiter `lifecycle/arbiter.ts` `arbitrate()` is also pure, but it passes the verdict through verbatim at step 3. Its landed `RunReasonCode` enum at a4af8e33 does not contain `coverage_basis_unknown`: S9-A's own spec narrows the verdict through `isRunReasonCode`, which would throw here. So the arbiter/terminal half of R23 is left to S10-C, with an allocation comment in the test.
4. **Upload parser (finding 4).** Removed:
   - `ParsedObservationUpload` and `parseObservationUpload` from parse.ts.
   - `OBSERVATION_BODY_MAX_BYTES` and the now-unused `ArtifactRejection` members `duplicate_unit` and `bad_intent` from contract.ts.
   - The upload tests from parse.spec.ts. The "never throws on hostile input" test is kept, now under "R21 — parser totality".

   `parseEvidence`, `unitKey` (used by verify.ts), all base64, canonical-JSON and Ed25519 code, and the statement or evidence size bounds are unchanged. The route envelope, the 32 KiB body cap and the ≤ 4 × scopes / one-per-unit checks now belong to S10-B. Earlier sections of this summary that mention the upload parser are superseded by this item.

### Changed files after fix round 1

| File | Lines | sha256 |
| --- | --- | --- |
| src/scout/induction/contract.ts | 169 | 80f3fea4d2daca887008140873b7e115c7383c37ae454000ee1d72cffcfd59f4 |
| src/scout/induction/parse.ts | 372 | f404f88fd639788c8db3175601345f4cef4ca0c2ffd9beddc14733c54431e543 |
| test/scout/induction/parse.spec.ts | 242 | 936618922ae572049a8cdc4ab02eb70b896c657560fa4dd6df26313512ac459a |
| test/scout/induction/verify.spec.ts | 647 | a10a3ea7461c405837f62786e14b2299b00406af802eb451cc5173da8b851940 |

The other files are unchanged; their hashes are in the table above.

**Size:** src/test/signer is now 2,573 lines (src 1,169). The JSON fixtures are not counted.

**Formatting:** the new blocks in verify.spec.ts (for example the `cleanFacts` body indentation and a few lines over 100 columns) still need `prettier --write`, formatting only.

## Fix round 2 (restore the R21 body bound in the pure tier)

- **contract.ts:** `OBSERVATION_BODY_MAX_BYTES = 32 * 1024` is back (after `OBSERVED_UNIQUE_MAX`).
- **parse.ts:** new exported pure `checkObservationBodySize(byteLength: number): ParseResult<number>`. It never throws. Results:
  - a non-safe-integer or negative length → `bad_length`;
  - more than 32768 → `too_large` (the existing oversize code, the same one statements and evidence use);
  - otherwise `ok`.

  The envelope, intent, cardinality and duplicate-unit logic is not restored; S10-B keeps it.
- **parse.spec.ts:** new block "R21 — observation body size bound":
  - 32768 → `{ok:true, value:32768}`;
  - 32769 → `{ok:false, reason:'too_large'}`;
  - a multibyte UTF-8 body of 32770 bytes → `too_large`;
  - -1, 1.5, NaN and Infinity → `bad_length`.

  Removing the guard makes the 32769 assertion fail.

| File | Lines | sha256 |
| --- | --- | --- |
| src/scout/induction/contract.ts | 171 | d06980c175adbe0d5071fd2093cfec5f95832a09779a64b1a9fa6742ab9f88da |
| src/scout/induction/parse.ts | 383 | aafd8b28b06f1be18828a2304b4864a3b967034d6553cbb4a9142eecfab07127 |
| test/scout/induction/parse.spec.ts | 260 | a9fa265ea05cbdf79f0d8b6d64f8bd4f97cba6bb48cbe502104d8e7bbdde2262 |

`verify.spec.ts` is unchanged from fix round 1 (sha256 `a10a3ea7…1940`). As before, nothing was compiled or run.

## Fix round 3 (devloop-1 findings; edited on top of the prettier-reflowed bytes)

1. **verify.ts TS2367.** The staged index is now `Map<string, StagedIndexEntry>`, where `StagedIndexEntry` is either `{kind:'facts', facts}` or `{kind:'conflict'}`.
   - **Declared platforms:** a conflict entry has no facts, so the partition never agrees, and every family of that platform is `known:false`. The R27 `staged: [staged(), staged()]` case exercises this.
   - **Undeclared platforms:** a conflict entry fails `CANONICAL_FAMILIES` (E1 loop).
   - **Digest lookup:** the unreachable comparison `stagedEntry === 'conflict'` in the staged-digest lookup is gone; the lookup now reads `stagedFacts` directly.

   No casts and no R75 tokens.
2. **digest.spec.ts:97.** The changed spec keeps the fixture valid for `parseSourceMappingSpec`. It only swaps the clients `displayName` path `["name"]` for `["full_name"]`, and the test asserts the digest differs. `mapping-spec.ts` is unchanged.

| File | Lines | sha256 |
| --- | --- | --- |
| src/scout/induction/verify.ts | 370 | 6c93b34b4c38a0a744865cf9bc55483fe96edfe81928581bf4cec9700ca2adb5 |
| test/scout/induction/digest.spec.ts | 109 | ad1de53613779bf0515a2b0aa544c55d811aa92e18366a0349d6c9eec6cec1cc |

## Fix round 4 (devloop-2: R27 "poisoned" case; edited on top of the prettier-reflowed verify.ts)

- **verify.ts:** a family that is in `stagedFacts.grouped_families` but missing from `stagedFacts.families` now goes through `fail(family)`, so it is `known:false`. The EMPTY/0 default stays only for a family absent from both, meaning genuinely not staged: a declared platform with no staged entry (R25, R26). The doc comment on `StagedPlatformFacts.families` now says so, and S10-C must supply an entry (the empty-set digest) for every grouped family with zero rows. No casts and no R75 tokens.
- **verify.spec.ts:** the old poisoned case is split into two tests.
  - **(a)** programs is in `grouped_families` but has no digest entry, and it carries a valid empty-set statement. Expected: exactly `{...BASELINE, programs: UNKNOWN}`. Without the guard, programs would come out `KNOWN(0)`, so the test fails.
  - **(b)** duplicate `clients` on top of the full baseline map (programs and workouts entries kept). `stagedFamilyDigests` takes pairs, so a duplicate is representable: the test asserts `families.get('clients')` is `null` and the result is `{...BASELINE, clients: UNKNOWN}`.

| File | Lines | sha256 |
| --- | --- | --- |
| src/scout/induction/verify.ts | 381 | 3a1a41b2062b91ef1329806b1484f902df81328ce896ff5e0851dff813c25548 |
| test/scout/induction/verify.spec.ts | 808 | 45600c9e101ef793a39f083d1bec25c539a7a5172b6143c53683c200ca87980a |
