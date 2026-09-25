# S9-0 independent review (T3, non-builder)

**Verdict: NO-GO.** There is one class A finding (R-A1) and one class B finding (R-B1). Both close with text-only amendments to the draft, with no redesign. A delta re-review of the amended hunks is enough. The rest of the document is faithful and accurate. I found 10 class C items; they can be recorded and do not block.

## Subject and verification

- Worktree `worktrees/64e33dc7-s7l`, branch `exec-dace/s9-0`. HEAD is `df713fd9217df524915348ef8a42c797f288dde1`, which is `integration/importer`.
- `git status --porcelain --untracked-files=all` shows exactly `?? docs/decisions/2026-09-25-s9-reconciliation.md`.
- sha256 `53c15c686dd330d33595ed2048cb2fd20710d2f0a383d6e54fceca4a397ec521`, which matches. The file has 463 lines.
- S7L-DOC blob `2a159920…` and S8-DOC blob `e177069f…` are identical at `93389265`, at `df713fd9` and in the worktree, so the doc's "byte-identical" claim holds.
- Read-only review. I made no git writes, took no lock, ran no tests and did no PG work. The evidence repo is not committed. This file is the only file I wrote.

## 1. Faithfulness to the parent S9 decisions (SCOPE.md L168-173)

| Parent decision | Doc | Result |
|---|---|---|
| F1: `complete` needs a recorded per-family basis, otherwise `partial` + additive code; S10 adds the basis with no core change | D-S9-3, C-COV, `coverage_basis_unknown`, `CoverageFact`, `COMPLETENESS_BASIS_KINDS=['none']`, S9-B passes `coverage: null` | Faithful for v1. **The predicate can be met vacuously on the S10 branch; see R-A1.** |
| F2: verified union only, split `null` (never 0, never guessed) until N3-FILL | D-S9-4, report `created_native: null`, `already_present_verified: null`, projection keeps both null, additive `native_present_verified` | Faithful |
| Report recomputed; any table must be justified | D-S9-5, `basis: 'recomputed'`, 4-point justification, re-decision trigger at S10 | Faithful. The justification holds, because `complete` is unreachable in v1 and so no stored `complete` can be contradicted. |
| Ceiling → `partial` | D-S9-6, bucket b `unresolved:pass_ceiling_exceeded`, `partial/unresolved_identities` | Faithful. S8-C `scout-reconstruct.service.ts` L157-167 enforces the ceiling per `entity_type` pass, which matches "per-family ceiling fact". |
| `blocked` only for `revoked` | D-S9-1 outcome set `{complete, partial}`; D-S9-6 | Faithful. It matches `arbiter.ts` L54-59 and L72-77. |

## 2. Citation audit (every S7L-DOC / S8-DOC / code line checked at `df713fd9`)

**S7L-DOC: all accurate.**

| Cited lines | Content found there |
|---|---|
| L61-63 | D-S7L-2 |
| L67-69, L67-74 | Precedence |
| L68 | `revoked`→`blocked` |
| L70, L71-72, L74 | |
| L107-109 | Six outcome codes |
| L108-109 | `revoked` reserved |
| L139-142 | CAS |
| L180 | Invariant 1 |
| L190 | Invariant 5, reader gate |
| L207-210, L207-212, L210-211, L211-212 | `families[]` shape, null-never-0, `observed_unique` |
| L228-230 | Legacy byte-identity |
| L246-249 | Generator |
| L257-263 | L8 |
| L268 | S10 |
| L284-286 | Release boundary |

**S8-DOC: all accurate.**

| Cited lines | Content found there |
|---|---|
| L72-74 | D-S8-2 interim |
| L84-89 | Option (a) |
| L93-98, L96-98 | D-S8-3 key |
| L99-101 | E30 limitation |
| L146-149 | Native-kind counting |
| L150-151 | Children not ledger |
| L152-155, L152-157 | Family-complete |
| L161-162 | `import_intent_id` nullable |
| L166-170 | Child unresolved provenance |
| L174-181 | Child encoding |
| L194-197 | Replay children |
| L198-201 | No late child |
| L206-208 | Value drift |
| L210-221 | §3.5 |
| L215 | `native_target_removed` |
| L216 | `identity_conflict` |
| L280-310, L282-305, L286-305 | §3.7 catalogue |
| L288-289 | Rejections |
| L292 | `no_native_destination` |
| L307-308 | `defaulted:` |
| L309 | No PII |
| L310 | S9 adopts the list |
| L316-317, L316-319, L318-319, L320-323 | §3.8 |
| L338 | `prescription:time` |
| L352-354 | Ordering |
| L372-374 | `roster_bridge_pending` |
| L435-438 | Children |
| L472-473 | Ceiling |
| L481-482 | Intent binding |
| L483-485 | Generator |

**Code and schema: all accurate.**

- `arbiter.ts`:
  - L4-6: pure
  - L22-25: `ReconciliationVerdict`
  - L54-59: `FENCE_TERMINALS`
  - L81-86: verbatim step 3
- `lifecycle.service.ts`:
  - L324: `reconciliation: null`
  - L392: `unmapped_families`
  - L557-562: null buckets
  - L574-575: reason narrowing
- `reason-codes.ts` L46-53: `RUN_REASON_CODES`, six entries.
- `source-mapper-registry.ts` L101-109: `resolveStagedFamily`. `mapping-spec.ts` L249-255: `resolveStep`.
- `schema.prisma`:
  - L6996: ledger wide identity
  - L7012: provenance `import_intent_id String?`
  - L7023: provenance D-S8-3 unique
- `scout-reconstruct.dto.ts` L98-107: `RECONSTRUCT_MAX_ROWS`.
- Migration `20270123000000…/migration.sql` L126-128: `reason_code` is opaque TEXT "so an S9 verdict reason needs no schema change".
- `scout.service.ts`:
  - L455: `readLedger` in the `Promise.all`
  - L497: `families: projectFamilies(grouped, ledger)`
- `scout.dto.ts` L219-262: `ScoutImportFamilyDto`.

**PLAN and MISSION** (local `repos/tgp-agent-context` at `1ebbed7`): L29, L97, L248 ("“Sent” is not “stored”"), L307, L309, L319, L321 and L323, and MISSION L91 and L93, all match the quoted text.

## 3. Verdict predicate: can it emit `complete` without a basis, or vacuously?

- **v1 production path.** No. S9-B always passes `coverage: null`, and `coverageKnown` requires `coverage !== null`. C-COV therefore holds for every run, and `complete` cannot be reached.
- **Empty run with `coverage: null`.** `partial/coverage_basis_unknown`, tested by R18.
- **Unsupported platform.** Bucket a gives `rejected`, and C-FAM fires on any unmapped entry, so the run is at most `partial/unresolved_family`. There is no explicit R case (C-3).
- **Rejected rows** (`missing_source_id`, or `unsupported_platform` with a ledger row). Bucket d, then C-ID. There is no explicit R case (C-3).
- **Unmapped entry with a ledger row** (for example `skipped` with `unresolved_family:<token>` or `unsupported_platform:<p>`). It falls to d or e, and C-FAM still fires.
- **Fenced runs and step-2 `failed`.** The arbiter ignores the verdict (R09).
- **The S10 branch the predicate is designed for (`known: true`).** It **can** be met vacuously. See R-A1.

## 4. Reason codes

- **Additive:** three codes are appended after the existing six, which keep their order (`reason-codes.ts` L46-53).
- **Low cardinality:** `unresolved_family` is reused, and `S9_REASON_CODES ⊆ RunReasonCode` is enforced at compile time in S9-C.
- **No schema change:** the column is TEXT.
- **Landing order:** the projection narrows unknown codes to null, so the doc correctly requires the codes to land with the wiring.
- **Run-level codes** are PII-free.
- **Histogram:** failed rows never echo text; an unrecognised reason becomes `unresolved:reason_unrecognised`. The only client-controlled string that can appear is the staged token in `unresolved_family:<token>` (C-6).

## 5. E2 consumer-freeze compatibility

`execution/daceddc8/e2/CONSUMER_FREEZE.md` L66-67 marks `reason_code` and `families[]` as not consumed. Rule 1 (L78) tolerates unconsumed fields. `families[]` keeps its per-token key and its existing fields, and every S9 field is additive. **The change is compatible.**

One bound is worth recording: E2 accepts a 200 only within 64 KiB (L78), and the additive `reasons[]` arrays grow the body (C-7).

## 6. Author-flagged choices

1. **S9-C hunks in `scout.service.ts` (L455/L497) and `scout.dto.ts` (L219-262).** These are needed; `families[]` is composed only at `scout.service.ts` L497. Disjointness:
   - They are disjoint from the S8-F composition (15 paths, `s8f/composition/CHANGED_PATHS.txt`: `scout-entities.*`, `scout-roster.*`, `test/scout/{entities,roster}/**`, `g2-s8f-*`).
   - They are disjoint from S8-G `PATHS.md`. S8-G's "Explicitly not owned" list names `src/scout/scout.service.ts`, `src/scout/scout.service.spec.ts` and `test/scout/lifecycle/**`, and `scout.dto.ts` is not claimed at all.
   - They are disjoint from the S8-C candidate (`git -C worktrees/64e33dc7-s8c diff --name-only 93389265 HEAD` at `f428db9a`, 25 paths).

   The only shared paths are ones the doc already sequences:

   | S9 slice | Other slice | Shared path |
   |---|---|---|
   | S9-C | S8-G | `lifecycle.service.ts` (the `onTransferSettled` body) |
   | S9-C | S8-G | `scout.module.ts` (S8-G expects no change there) |
   | Gen | S8-C | `docs/contracts/importer-openapi.json` |

   **Disjointness holds.** The hunk list itself is incomplete (C-1), and it conflicts with the accepted legacy assertions (R-B1).
2. **Rejected rows block `complete` (C-ID).** This is faithful to S8-DOC L152-155 and PLAN L97 ("or a non-success outcome"). Accepted.
3. **`unsupported_platform` rows fall under C-FAM → `unresolved_family`.** This is a mild semantic stretch, but it keeps cardinality low and the histogram keeps the distinction. Accepted.
4. **A non-`success` claim keeps coverage unknown.** The extra conjunct only makes `complete` harder to reach, so it is safe. Accepted.
5. **E2 freeze.** Confirmed compatible (§5).

## 7. Acceptance cases R01-R19

- R01-R12, R14, R17, R18 and R19 are concrete and testable. The tier assignments are sensible.
- R13 and R15 as written contradict D-S9-5 against the accepted spec assertions (R-B1).
- R16's "S8-G proof's deadline window" has no number (C-8).
- Missing cases: a vacuous-coverage case (R-A1), plus unsupported-platform and rejected-row cases (C-3).

## 8. Findings (Safety-ROI)

### R-A1 (class A): the C-COV domain can be empty or incomplete, so `complete` can be emitted vacuously on the S10 branch

- **Where:** D-S9-2 C-COV (doc L154-155), D-S9-3 `coverageKnown` (L183-189), and the claim at L160-161 that an empty run is never vacuously complete. That claim holds only for `coverage: null`.
- **Defect:** C-COV checks coverage "for every family in (entries ∪ coverage families)", and the predicate "reads only `known`, `covers_staged_identities` and the claim". Two cases follow:
  - Zero staged rows, `coverage = {}` (non-null, empty) and claim `success`. The universal quantifier ranges over the empty set, every other condition is empty too, and the result is `complete`.
  - A coverage map that simply omits a family the source has but the run never touched. The only families required are staged ones or ones the map names. PLAN L29 says "no run says complete while a *required* family … is unknown", but the doc never defines the required-family set independently of what S10 chooses to put in the map.
- **Concrete harm:** S9-A (T4, the only code path that can emit `complete`) freezes to this text. D-S9-3 says S10 plugs in "without a core change", so the core predicate will not be revisited. Once S10 supplies coverage, three runs would settle `complete`, a false completion that violates MISSION L93 and PLAN L29:
  - a run where the extension observed nothing and the evaluator returns `{}`;
  - an evaluator that omits a family by construction;
  - a zero-staged run whose basis names no family.
- **Decision blocked:** landing the S9-0 text that S9-A freezes to, specifically the C-COV and `coverageKnown` definitions and R18.
- **Minimum closure (text only):**
  - In D-S9-2 C-COV and D-S9-3, define the **required-family set** as entries ∪ coverage families ∪ every canonical family that the resolved platform's mapping spec declares.
  - State that C-COV holds when that set is empty or cannot be determined, for example when there are zero staged rows and no platform is known.
  - State that C-COV holds when any required family lacks `known: true` with `covers_staged_identities`.
  - Add **R18b (A):** zero staged rows, `coverage = {}` and claim `success` → `partial/coverage_basis_unknown`.
  - Add **R01d (A):** every staged family is covered, but a spec-declared family is missing from the map → `partial/coverage_basis_unknown`.

  v1 behaviour does not change.
- **Execution unlocked:** S9-0 commit and S9-A source against a non-vacuous predicate.

### R-B1 (class B): D-S9-5 and R13/R15 conflict with accepted S7-L2 assertions that S9-C may not edit

- **Where:**
  - D-S9-5 says "Legacy rows keep all of these null or empty" (L274), and "Before a terminal … additive fields stay null" (R15).
  - R13 says `scout.service.spec.ts` legacy cases "stay byte-identical".
  - D-S9-8 says S9-C may add "added cases only" in `test/scout/lifecycle/lifecycle.service.spec.ts` and `src/scout/scout.service.spec.ts`.
- **Defect:** two accepted assertions pin the exact `families[]` entry shape with `toEqual`:
  - `src/scout/scout.service.spec.ts` L766-787, a legacy row;
  - `test/scout/lifecycle/lifecycle.service.spec.ts` L464-492, `projectFamilies(staged, ledger)` with two arguments.

  Jest `toEqual` ignores only `undefined`-valued properties. Adding the six additive keys as `null` or `[]` (`canonical_family`, `native_present_verified`, `completeness_basis`, `relationship_closure`, `reasons`, `qualifiers`), as D-S9-5 requires, makes both assertions fail. S7L-DOC L229-230 made "existing `scout.service.spec.ts` cases must pass unchanged" an S7-L2 acceptance condition.
- **Concrete harm:** S9-C (T4) cannot satisfy D-S9-5 and R13/its grant at the same time. It would have to do one of three things:
  - edit accepted legacy-compat assertions outside "added cases only", weakening a proof the S7-L landing rested on;
  - ship a failing accepted suite;
  - silently deviate from the binding text.
- **Decision blocked:** the S9-C path and grant text, and the wording of R13 and R15. S9-A and S9-B are not blocked.
- **Minimum closure (pick one in the doc):**
  - **(i), recommended.** The additive fields are **absent** (optional DTO properties, `required: false`) whenever no report applies: legacy rows, open server runs, and any `projectFamilies` call without a report argument (optional third parameter). Existing assertions then stay byte-identical. Change D-S9-5 L274 and R15 from "null" to "absent".
  - **(ii)** Explicitly grant S9-C the minimum additive extension of exactly those two `toEqual` literals (new keys only, with the existing keys and values unchanged). Restate R13 as "legacy cases pass with only that additive key extension".
- **Execution unlocked:** a consistent S9-C grant.

### Class C (record and continue; none blocks)

- **C-1. The S9-C hunk list is incomplete.**
  - Calling the facts service inside `onTransferSettled`, and reading the report for `getImportStatus` "beside L455" through `this.lifecycle`, needs two more things in `lifecycle.service.ts`: an import plus a constructor hunk (constructor at L114-119; it should be `@Optional()` like S8-G's pattern, so that `new ScoutLifecycleService(prisma, analytics)` at `scout.service.ts` L96, `scout-ingest.service.ts` L50, `lifecycle.service.spec.ts` L67 and `g2-s7l-worker.cjs` L112 keep working); and a report-read method.
  - Neither is in the listed hunks, and "every other hunk of the files it touches" is Not owned.
  - Closure: list them when S9-C is granted.
- **C-2. Classification-table wording.**
  - Bucket j reads as "Otherwise:" plus positive conditions. State that an identity matching none of a-j is `unresolved` / `unresolved:reason_unrecognised`, so the partition stays total without relying on DB CHECKs.
  - Bucket e should read "any other `skipped`", because its key column already handles unparsable reasons.
  - `ledger_without_staged` is counted only inside mapped families. A ledger-only row whose token or platform does not resolve escapes C-ID. Count it run-wide.
- **C-3. Missing R cases:**
  - **R03b:** a staged row on an unregistered platform → bucket a `rejected`, `partial/unresolved_family`.
  - **R02b:** ledger `skipped` `missing_source_id` → bucket d `rejected`, `partial/unresolved_identities`.
- **C-4. The bucket f key is per family, but S8-DOC L148-149 is per row.**
  - A client-linked `workouts` evidence row is keyed `unresolved:evidence_only`, but S8-DOC L149 counts "a client-owned row written only as evidence" as `unresolved:no_native_client_principal`.
  - The S8-C candidate also writes a top-level unresolved provenance row with that reason (`native-writers.ts` L406-414). That conflicts with S8-DOC L169-170 and is S8-C's to resolve; S9-B binds to the landed text.
  - Closure: key bucket f per row, using the row's client link or its provenance reason. Only the histogram is affected; the verdict is not.
- **C-5. E-R2 notation.** `#ord:<n>` with "`order` equals `n`" reuses `n`, which S8-DOC L176-178 defines as the length prefix. Write `#ord:<ordinal>`.
  - The ordinal is the "0-based source position" (L178), while native `order` is the "source ordinal, 0-based" (L416). These can differ when source ordinals are not positions, which gives a false `relationship_unverified` (safe direction).
  - Deleted created children are not covered. They are moot today, because under the S8-C precondition every exercise is unresolved.
- **C-6. The `unresolved_family:<token>` qualifier carries the staged token.**
  - Ingest accepts any string of 1-128 characters as `entity_type` (S8-DOC L124-125), so this qualifier is client-controlled and bounded only per intent.
  - It creates no new exposure, because `families[].family` already projects the same token under the accepted S7-L contract. R14's "no name/email/label/payload" cannot be guaranteed for tokens; say so.
  - The parser that accepts §3.7 reasons "verbatim" should also validate qualifier domains (family, field and model names from the spec), not only the code prefix.
- **C-7. E2 64 KiB body bound** (CONSUMER_FREEZE L78). The additive `reasons[]`, `qualifiers[]` and 128-char token keys grow the status body. The realistic size (about 5 families) is a few KB, and the worst case (32 families with full histograms) comes close to 64 KiB.
  - Closure: an S9-C R15 fixture that asserts the body stays within the bound for 32 families.
  - Make `qualifiers` a closed enum in OpenAPI, not `string[]`.
- **C-8. The R16 deadline window is not quantified.** Name the number, for example the `SCOUT_RUN_DEADLINE_MS` default of 300 000 ms minus the S8-G reconstruct budget, or the S8-G proof's own constant.
- **C-9. Recompute-on-read consistency and catalogue drift.**
  - The status-path recompute runs outside a transaction. Classification across separate provenance and native queries can transiently land in g/i (safe direction). Recommend a single read-only REPEATABLE READ transaction in S9-B for the read path.
  - S9-A cannot import S8-C's runtime `UNRESOLVED_CODE`: it imports types only, and `native/**` is absent at `df713fd9`. Its copy of the §3.7 catalogue can therefore drift; an unknown code degrades safely to `reason_unrecognised`. Recommend an S9-C spec that asserts S9-A's catalogue equals S8-C's.
- **C-10. Minor wording.**
  - `relationship_closure: 'not_applicable'` must mean "the contract declares no edge for this family", never "not checked" (PLAN L319).
  - R12's "`null` only for D-S9-3/D-S9-4 fields" should also list `media_policy`.
  - A token that resolves differently across platforms in one intent (ingest takes `source_platform` per row) maps one `families[]` entry to several report rows. Define the projection as the sum over all of that token's rows, with `canonical_family` null unless every row resolves to the same family.

## 9. What this review does not claim

I ran no tests, hooks or PG work, and I made no product or git change. This review is not an acceptance of S7-L, S8-C, S8-F or S8-G. The closures above are text amendments for the S9-0 author. After they are made, a delta re-review of D-S9-2 C-COV, D-S9-3, D-S9-5 L274 and R13/R15/R18 is sufficient.

---

## Re-review (changed parts only), 2026-09-25

**Final verdict: GO.** R-A1 and R-B1 are closed. Every folded C item is correct, and I found no regression in the unchanged parts. The only new findings are class C.

### Subject

- Same worktree and branch. HEAD is still `df713fd9217df524915348ef8a42c797f288dde1`.
- `git status --porcelain --untracked-files=all` still shows only `?? docs/decisions/2026-09-25-s9-reconciliation.md`.
- sha256 `cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1`, which matches the parent mail. The file has 533 lines.
- Inputs:
  - the changed-sections list in `s9/S9_0_DRAFT_READY.md` ("Amendment");
  - the parent disposition in `SCOPE.md` L244-265.
- Read-only. I made no git writes, took no lock and ran no tests or PG work.

### R-A1: closed

- **Required-family set.** D-S9-2 (doc L163-177) defines `required_families` as the union of three sets:
  - the canonical families of the staged entries;
  - the families the coverage map names;
  - every family the mapping spec of each staged `source_platform` declares (`spec.families` keys; `mapping-spec.ts` L118 and L252 at `df713fd9`).
- **When the set is undeterminable.** It is undeterminable with zero staged rows, or when any staged platform has no spec.
- **C-COV** (L158-161) holds when any of these holds:
  - the set is empty or undeterminable;
  - any member lacks `coverageKnown`;
  - the claim is not `success`.
- **D-S9-3** (L206-215):
  - `coverageKnown` now requires `coverage[f]` to be present, so a family missing from the map counts as not known.
  - `complete` needs a non-empty, determinable set, `coverageKnown` for every member, and claim `success`.
  - S9-A's `coverage.ts` is bound to this text. This matches the parent's closure (SCOPE L248-252).
- **Vacuity cases, each checked:**
  - Zero rows, any map: undeterminable, so C-COV fires (L182-184).
  - Zero rows, `{}`, claim `success`: C-COV fires; R18b (L497-499) covers it.
  - Staged rows with an empty map: the staged families are required and absent from the map, so C-COV fires.
  - A family the spec declares but the map omits: C-COV fires; R01d (L436-437) covers it.
  - An unregistered platform: undeterminable, and C-FAM fires as well.
- **No residual vacuous path.** When the set is non-empty and determinable, every member must carry an explicit `known: true` with `covers_staged_identities`.
- **v1 behaviour is unchanged.** S9-B still passes `coverage: null`.
- S9-B now supplies the per-platform declared families (L408), so the S9-A input exists.

### R-B1: closed (option (i))

- **Additive fields are optional and omitted.** D-S9-5 (L294-322) makes the six fields optional DTO properties (`required: false`). They are omitted, never `null` or `[]`, whenever no report applies: legacy rows, open server runs, and `reconciliation_not_performed` terminals.
- **Two-argument calls are unchanged.** `projectFamilies` takes an optional third parameter, and with two arguments it returns today's objects.
- **Accepted assertions stay untouched.** The two accepted `toEqual` literals (`scout.service.spec.ts` L766-787, `lifecycle.service.spec.ts` L464-492) stay untouched and passing, and S7L-DOC L229-230 is cited correctly.
- **The null-or-empty wording is gone.** The line "Legacy rows keep all of these null or empty" is removed. R13 (L473-479) and R15 (L485-488) now say "absent" and "untouched and passing".
- **No other accepted unit case is affected.** Every `getImportStatus` case in `src/scout/scout.service.spec.ts` uses legacy `importRow(...)` fixtures, so none of them gets a report. `lifecycle.service.spec.ts` has no status-read case. `scout.controller.spec.ts` mocks `getImportStatus`. The accepted S7-L PG proof uses `objectContaining` for `families` (`rls-g2-s7l.spec.ts` L791-793) and is not rerun.

### Folded C items: all correct

- **C-1, constructor and read hunks.** S9-C's `lifecycle.service.ts` scope (L409) now lists:
  - the reconciliation import;
  - an `@Optional()` facts-service constructor parameter after `prisma, analytics`. The constructor is at L114-119, and the four two-argument construction sites are verified: `scout.service.ts` L96, `scout-ingest.service.ts` L50, `lifecycle.service.spec.ts` L67 and `g2-s7l-worker.cjs` L112;
  - one report-read method;
  - the optional `projectFamilies` parameter and optional `FamilyProjection` fields.
- **C-2, classification table.**
  - Bucket j is now positive: ledger `reconstructed` with a native kind.
  - Bucket e reads "any other ledger `skipped`".
  - New catch-all bucket k gives `unresolved:reason_unrecognised`.
  - The partition invariant states that buckets a-k are total.
  - `ledger_without_staged` is counted run-wide (L119-122), and C-ID uses the run-wide count (L153-154).
- **C-3, missing R cases.** R02b (`missing_source_id` → d/`rejected`) and R03b (unregistered platform → a/`rejected`, `unresolved_family`) are added. R03b is PG-testable: the staging CHECK accepts any canonical-form token (`20270120000000…/migration.sql` L130-132, regex), and only three specs are registered (`reconstruct/sources/*.json`).
- **C-4, per-row bucket f key.** Bucket f is now keyed per row, as S8-DOC L148-149 requires: a client-owned family, a resolved client link, or an existing `no_native_client_principal` reason. It also covers the S8-C candidate's unresolved provenance row.
- **C-7, E2 body bound.** A note in D-S9-5 cites CONSUMER_FREEZE L78, and R15 gains a 32-family fixture that keeps the status body within 64 KiB.
- **C-8, R16 deadline window.** R16 now reads "≤ 10 000 ms, one thirtieth of `SCOUT_RUN_DEADLINE_MS_DEFAULT` = 300 000 ms". The arithmetic is right, and the constant is at `lifecycle.service.ts` L29.
- **Minor edits.**
  - "Why no table" point 2 now reads "never `complete` in v1", which is correct now that fenced terminals get reports.
  - §5 lists the new R cases.

### Regression check

- **Lines 1-78** (status, sources and D-S9-1) are unchanged, and their citations are the ones already verified in §2.
- **Sections left unchanged:**
  - D-S9-4, D-S9-6 and D-S9-7 run codes;
  - D-S9-8 for S9-0, S9-A and Gen;
  - R01-R19;
  - §4.

  All of these match the reviewed version, apart from the items listed above.
- **Parent decisions F1, F2, recompute, ceiling and `blocked`** remain faithful.
- **Disjointness from S8-F, S8-G and the S8-C candidate** is unchanged. The added hunks are all inside S9-C's existing files.
- **E2 compatibility.** `families[]` is still additive, and omitting fields is more conservative than null-valued fields.

### New findings (class C only; record and continue)

- **RC-1. `coverage_basis_unknown` meaning.** The D-S9-7 meaning cell (L366) does not mention the empty or undeterminable `required_families` trigger. Wording only; D-S9-2 is the binding definition.
- **RC-2. "Pre-S9 terminals" wording.** "Pre-S9 terminals (the arbiter's step-4 default)" (L296) excludes only `reconciliation_not_performed`. Runs fenced before S9-C landed (`cancelled`, `timed_out`) will therefore get a recomputed report. That is a truthful account under an unchanged terminal, so there is no harm, but state it explicitly.
- **RC-3. Layout of the declared-family sentence.** The sentence "a declared family that has no staged row gets `staged_unique: 0`…" sits inside the second "cannot be determined" bullet (L173-177). Move it to its own paragraph, and say that such report-only entries never create a `families[]` projection entry, because there is no staged token for them.
- **Carried into the S9-B and S9-C grants, as the author recorded:**
  - C-5: E-R2 `#ord:<n>` notation (L140 is still unchanged);
  - C-6: qualifier-domain parsing and client-controlled tokens;
  - C-7 second half: a closed OpenAPI enum for `qualifiers`;
  - C-9: a REPEATABLE READ status-read transaction and a catalogue-equality spec;
  - C-10: `not_applicable` wording, `media_policy` in R12, and the sum rule for multi-platform tokens.

  None of these weakens the verdict predicate, so it is acceptable to carry them.

**Execution unlocked:** the S9-0 commit (genuine hooks) under the heavy-queue slot, and then S9-A source frozen to this text.
