# S12-B3 independent T3 review — commit a4d0b85c

**Verdict: NO-GO pending B1–B3.** Scope is the mobile diff `a876268c..a4d0b85c` in `/home/user/workspace/worktrees/fa72-s12b3`, with read-only comparison to the scout status/roster backend in `/home/user/workspace/worktrees/fa72-s11d2`. HEAD `a4d0b85c5ab39e27727ebc343062fbe2621ac934`, tree `3352e0f6ce9a9ef48e6783b722332a89a4ecee5a`; mobile worktree remained clean. No product edit, commit, push, remote action, or real-PG test.

## A/B findings (required five fields)

**A: none.**

### B1 — New roster accounting field is silently discarded and the displayed total can say zero

1. **CLASS:** B — customer-facing accounting/truth, impending additive backend field.
2. **CONCRETE HARM:** `src/types/importRunStatus.ts:166-193,223-232` admits the accounting object with extra fields but keeps only `staged/reconstructed/skipped/failed`; `ImportRunVerdictCard.tsx:248-251` calls `staged` “Found” and shows the four old counts. The in-progress S11-E backend `src/scout/scout-roster.dto.ts:96-128` and `scout-roster.service.ts:203-211` explicitly add `unclassified`, *excluded* from family `staged`. For a settled import with five unclassifiable rows and zero roster-classified rows, the mobile card says “Found 0: 0 imported, 0 skipped, 0 couldn’t be imported,” even though the server says `unclassified: 5`. This is exactly the silent-zero case the new field exists to prevent. The backend worktree's S11-E files are currently uncommitted; this finding is conditional on that announced field shipping, not a claim that the pinned `54be96f1` contract already contains it.
3. **EXACT DECISION BLOCKED:** Acceptance of the flag-gated roster accounting as an honest pilot-coach explanation, and S12-B3 landing ahead of the S11-E additive response.
4. **MINIMUM CLOSURE:** Decode the optional added `unclassified` as an individually unknown-safe nonnegative integer, present it as its own explicitly scoped count (or “not known yet” when absent), and qualify `staged` as roster-classified rather than all people/rows. Test `{staged:0,reconstructed:0,skipped:0,failed:0,unclassified:5}`, absent and malformed `unclassified`, and extra fields. Do not require the new field from older servers.
5. **EXECUTION UNLOCKED:** S11-E rollout and flag-gated coach roster can coexist without presenting known unclassified rows as zero.

### B2 — Unknown phase/reason enums become “Not known yet” rather than an explicit unrecognised value

1. **CLASS:** B — fail-closed display contract for future server enum values.
2. **CONCRETE HARM:** `decodeRunStatus` correctly distinguishes null from `'unknown'` (`src/types/importRunStatus.ts:101-104,141-143`), but `verdictLines` immediately coalesces both to `NOT_KNOWN_YET` (`ImportRunVerdictCard.tsx:109-121`). For an open run with a new phase, “Current step: Not known yet” conceals that the server supplied an unrecognised step; for a stopped run with a new reason, “Reason: Not known yet” conceals that it supplied an unrecognised reason. The tests at `ImportRunVerdictCard.test.tsx:173-177,219-224` explicitly lock this conflation in. Unknown *status* already gets explicit not-recognised copy.
3. **EXACT DECISION BLOCKED:** Acceptance of the grant's “unknown enum/extra fields → explicit unrecognised state” requirement for the run's phase and reason.
4. **MINIMUM CLOSURE:** Render a distinct “Step not recognised” / “Reason not recognised” (or equivalent) when these decoded fields are `'unknown'`; keep null/absent as “Not known yet.” Adjust the tests for both branches, including a server `complete` with a new reason code.
5. **EXECUTION UNLOCKED:** Forward-compatible server enum additions remain visibly different from fields the server has not provided.

### B3 — Empty current roster page is reported as an empty entire import

1. **CLASS:** B — false empty-list claim under legitimate pagination.
2. **CONCRETE HARM:** `ImportRunVerdictCard.tsx:253-255` prints “The server has no imported people to show for this import” whenever the *loaded* `persons` array is empty, even if `roster.hasMore` is true or `roster.incomplete` is true. The backend paginates by reconstructed **ledger rows**, then filters Deleted/missing Person targets (`scout-roster.service.ts:154-171,181-183,221-224`); hence a page can have zero visible people and a next cursor to a page with a visible person. The hook preserves that cursor (`useImportRunStatus.ts:156-158,166-176,206-207`) but the card still tells the coach there are none.
3. **EXACT DECISION BLOCKED:** Acceptance of a truthful imported-people list and empty-state copy with the review flag enabled.
4. **MINIMUM CLOSURE:** Treat an empty loaded page with `hasMore` as “No people on this page; show more,” and an incomplete read as unknown/incomplete; reserve the whole-import empty claim for a complete, exhausted pagination result (or use a deliberately page-scoped empty statement). Cover a backend-shaped first page `persons:[]`, `has_more:true`, nonnull cursor, followed by a nonempty page.
5. **EXECUTION UNLOCKED:** Coaches no longer see a false “no imported people” message merely because the first ledger page has filtered records.

## C list — record, qualify, continue

- **C1 / open handle:** The five new scoped suites passed 120/120 with `--detectOpenHandles` and exited RC 0. This does not identify the builder's full-suite post-summary hang; it provides no evidence that these five suites leak a Jest handle. No full-suite rerun.
- **C2 / 404 copy:** API maps Axios 404 to `notFound` rather than zero (`importRunStatusApi.ts:32-37`), and the card does not assert the intent is absent; however “The server has nothing to show … Once the import starts …” (`ImportRunVerdictCard.tsx:164-170`) sounds more specific than a uniform dark/unknown/cross-tenant/no-evidence 404 permits. Prefer “Status not known yet; check again later” without implying a run has not started. This is a copy qualification, not an independent block.
- **C3 / count and shape:** Old `54be96f1` fixture and contract pin genuinely match the source artifact; the extractor copies the two path items, recursively follows schema refs, and embeds the source SHA. Its test does not assert any new S11-E `unclassified` field, because the pin predates that field. The decoder tolerates added fields structurally; B1 is about the silent *display* omission.
- **C4 / polling and gating:** Status polling is 20 seconds while open/unknown, disabled for recognised terminals; React Query's default interval does not run in background; `AppState` subscription is removed on cleanup; roster requires both `extensionImport` and default-off `importReview` and a recognised terminal. The API uses 15-second abort timeouts. No independent block observed.
- **C5 / row state copy:** Recognised `Invited`, `Claimed`, `Suspended`, and `Deleted` states are all displayed as “joining status not known yet” (`ImportRunVerdictCard.tsx:79-80`). It is conservative rather than fabricated success, but loses server distinctions; assess later UX scope, especially if backend starts emitting non-InvitePending rows.

## Source pin, files, and LOC

Backend source artifact at `worktrees/fa72-s11d2/docs/contracts/importer-openapi.json` and `git show 54be96f1:docs/contracts/importer-openapi.json` both SHA-256 `889d25c6a529512596b01ba6554bbf4038ca7f33fdc66f6c9c14118b44dc53f4`. Extractor at `repos/tgp-private-evidence/execution/fa72efb2/s12b3/tooling/extract_s12b3_status_surface_fixture.py` SHA-256 `351c7cc5cb7d4f98810bc82e3cfa01f8552cf255410fd78ad0b7daba1eb6e3bb`. The path table below is relative to `/home/user/workspace/worktrees/fa72-s12b3`; LOC is diff additions/deletions, **not** file size.

| Path | LOC +/− | SHA-256 |
|---|---:|---|
| `src/api/__tests__/importRunStatusApi.test.ts` | 74/0 | `54ef3c6cecd875b3be08ee9a5beb62843eef7cbfd7ee99bc0bc75a27f3525509` |
| `src/api/importRunStatusApi.ts` | 60/0 | `d91703a106694d4f88f4f36e40790a0686984d984e68d6e4159ad8756ad123f4` |
| `src/components/coach/ExtensionPairingPanel.tsx` | 12/1 | `b2e15208590e77da5136201ae085a9767b9123b54ca58e4e246cd62d5fdbde4e` |
| `src/components/coach/ImportRunVerdictCard.tsx` | 344/0 | `3a4d0715c3d297d490d4f0f416eedb6a50cb9ab6629bdac45d4e5f97b8a1ee29` |
| `src/components/coach/__tests__/ExtensionPairingPanel.verdict.test.tsx` | 71/0 | `5403d5f6496734dee9746c3ba8b9a0d7088d511f2527507771af34a7d6568bd6` |
| `src/components/coach/__tests__/ImportRunVerdictCard.test.tsx` | 354/0 | `c4e626ccb7b10553f5444346c8e65c72b4951d017bc7cb1efab45b873e68054f` |
| `src/hooks/__tests__/useImportRunStatus.test.tsx` | 279/0 | `c1c4c5ae4c165794ea4d0dbf26fd30e1e180d59c48271eac5ada4668610ce044` |
| `src/hooks/useImportRunStatus.ts` | 212/0 | `c1b30df791b17d88fa35693c17f18f6f921644320269ec977e84719a4cf85167` |
| `src/types/__fixtures__/s12b3ScoutStatusSurface.54be96f1.json` | 799/0 | `ce2ca6a3e3937e31026da2a01723c97b2af76f548bbccb9be514abfad7c73c7a` |
| `src/types/__tests__/importRunStatus.contract.test.ts` | 231/0 | `603c38ab90fa8f63916feeac3de48df53ecfc3c6f25158a90094f687d7e4b947` |
| `src/types/importRunStatus.ts` | 233/0 | `2a6817fc484c24711293bddc62171f0013dc45997b381` |

**Total:** 2669 added / 1 removed, 11 files. The backend worktree was read only; its S11-E edits were already present and uncommitted when inspected.

## Commands and RC

The review used read-only `sed`, `nl`, `rg`, `rg --files`, `git status/show/log/rev-parse/diff`, `sha256sum`, `wc`, and `test -e` to inspect the rule/grant/build/readiness files, 11 mobile diff files, relevant backend DTO/service/controller, extractor, fixture, flags, and tests; these inspection `bash` invocations all exited **RC 0** (the nested `test -e /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE` reported **RC 0**). Initial mobile `git status --short` was empty; final `git status --porcelain` empty. Exact heavyweight invocation:

```sh
flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c 'cd /home/user/workspace/worktrees/fa72-s12b3 && NODE_OPTIONS=--max-old-space-size=3072 ./node_modules/.bin/jest --runInBand --detectOpenHandles --runTestsByPath src/api/__tests__/importRunStatusApi.test.ts src/components/coach/__tests__/ExtensionPairingPanel.verdict.test.tsx src/components/coach/__tests__/ImportRunVerdictCard.test.tsx src/hooks/__tests__/useImportRunStatus.test.tsx src/types/__tests__/importRunStatus.contract.test.ts'
```

**RC 0**, five suites/120 tests passed, 12.971 s, no open-handle diagnostic, process exited. No typecheck/lint/full jest rerun by this auditor; the builder's reported runs are not claimed as auditor runs.

---

## Round 2 — delta audit of `77b9a2ad` against B1–B3

**Verdict: GO for this S12-B3 delta.** This supersedes the NO-GO at the top **only for HEAD `77b9a2ad857ad78597c51095dd0a95da3c761cc3`**, tree `3c7fe24d69c66c330ab7a103fffe2706c3e25149`, parent `a4d0b85c`. There are **no open A/B findings in the requested B1–B3 delta**. The mobile worktree remained clean; I did not edit product files or commit/push.

### Closure decisions

- **B1 CLOSED.** `src/types/importRunStatus.ts:166-209` now decodes additive `accounting.unclassified` independently as a nonnegative integer or `null` when absent/malformed; extra fields remain tolerated and the four old counts still decode. `ImportRunVerdictCard.tsx:260-271` scopes those counts to client/roster-classified records and renders a separate unclassified count, with “not known yet” when no valid number was supplied. Tests cover `{staged:0,reconstructed:0,skipped:0,failed:0,unclassified:5}`, absent/malformed cases, extra fields, and propagation through the hook. **Qualification:** `unclassified` is specified in the *uncommitted* S11-E backend working tree (`fa72-s11d2/src/scout/scout-roster.dto.ts:96-128`, `scout-roster.service.ts:203-211`), not in the pinned 54be96f1 fixture; the optional mobile decode is therefore appropriate until that backend contract lands. The wording “sorted into your roster” is slightly loose for skipped/failed records, but “client records only” and the explicit outcome breakdown prevent the prior all-import zero claim; this is C copy polish, not a blocker.
- **B2 CLOSED.** `ImportRunVerdictCard.tsx:118-136` keeps `phase` and `reason_code` null/absent as “Not known yet” but maps decoded `'unknown'` to “Not recognised by this app version.” Tests cover both branches, including server `complete` with an unrecognised reason. It does not echo an unknown raw reason code or create a success state.
- **B3 CLOSED.** `ImportRunVerdictCard.tsx:272-292` uses the page-scoped “No people on the pages loaded so far” if the visible list is empty while `hasMore` or `incomplete`; the whole-import empty statement is reserved for an exhausted, complete read. Hook and card tests cover an empty first ledger page with a cursor followed by a person, and an incomplete empty list.

### C list (round-2 delta)

- **C6 / source pin:** Once S11-E lands, regenerate/pin a contract fixture for its required `unclassified` field. At this HEAD, optional decoding supports both older and upcoming server shapes without inventing zero.
- **C7 / copy:** New row-state distinctions and softened 404 copy are consistent with the delta's goal; “sorted into your roster” could be tightened to “classified as client records” to avoid implying skipped/failed records became roster people. No new A/B harm found.
- **C8 / test scope:** The builder reports final tsc RC 0, lint RC 0 and 18 scoped suites/659 tests RC 0 in `s12b3_build.md` Round 2. Independently, I ran only the five new suites: 141/141 passed with `--detectOpenHandles`, process exited normally. The original full-jest post-summary hang was not revisited.

### Delta paths, sha256, LOC, commands

Relative paths below are in `/home/user/workspace/worktrees/fa72-s12b3`. LOC is `git diff a4d0b85c 77b9a2ad --numstat`; all six other first-round files retain the earlier hashes.

| Changed path | Added/removed LOC | SHA-256 at 77b9a2ad |
|---|---:|---|
| `src/components/coach/ImportRunVerdictCard.tsx` | 34/7 | `8626a77d4d84a188305f962cd73dbbbdec2e4a636ed8afdd582d4f27bc6e549c` |
| `src/components/coach/__tests__/ImportRunVerdictCard.test.tsx` | 109/9 | `6ae94e9d89083fba11fb50d1fd5fa3268ca8c0b61d63c30161966e4689e1c735` |
| `src/hooks/__tests__/useImportRunStatus.test.tsx` | 36/0 | `33403beaae4d3f99b8fdf721c60988df4ff25e928ac50ee612d4b8a06fc1e95e` |
| `src/types/__tests__/importRunStatus.contract.test.ts` | 31/1 | `0f452705be1109abc98b3887aa679bbc7678009b41b9b5a4b6cb878080139bdd` |
| `src/types/importRunStatus.ts` | 18/2 | `c13388614d5e165349af5ecef7fd322c7976c475d8d6a535d8d6e7fe0bb7b4cc` |

**Delta total: 228 additions, 19 removals, five files.** Read-only `git status/log/show/diff/rev-parse`, `sed`, `rg`, `nl`, `tail`, `sha256sum`, and `test -e /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE` inspection commands exited RC 0 (the nested proof-slot test reported RC 0). Independently run heavyweight command:

```sh
flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c 'cd /home/user/workspace/worktrees/fa72-s12b3 && NODE_OPTIONS=--max-old-space-size=3072 ./node_modules/.bin/jest --runInBand --detectOpenHandles --runTestsByPath src/api/__tests__/importRunStatusApi.test.ts src/components/coach/__tests__/ExtensionPairingPanel.verdict.test.tsx src/components/coach/__tests__/ImportRunVerdictCard.test.tsx src/hooks/__tests__/useImportRunStatus.test.tsx src/types/__tests__/importRunStatus.contract.test.ts'
```

**RC 0; 5/5 suites, 141/141 tests; 3.676 s; no open-handle diagnostic.** No new full-suite, real-PG, typecheck, or lint run by this auditor.
