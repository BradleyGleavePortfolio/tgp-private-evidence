# S9-A independent review A (T4, non-builder) — pure reconciler

- Reviewer: `S9-A review A`. Read-only apart from this file. No git writes, no lock, no repo tests
  or gates run. `S9_A_REVIEW_B.md` not read.
- Written 2026-09-25 (PDT morning; Phase 1 on untracked source). Phase 2 section is appended
  after the parent pins the committed head.

## Subject and verification

| Item | Value |
| --- | --- |
| Worktree / branch / HEAD | `/home/user/workspace/worktrees/daceddc8-s9a`, `exec-dace/s9-a`, `df713fd9` (`git status --short` = exactly `?? src/scout/reconciliation/`, `?? test/scout/reconciliation/`; no tracked file touched; no `node_modules`) |
| `types.ts` | `eff1479c…dbfa` (386 lines) — matches SOURCE_READY |
| `coverage.ts` | `c6b224fa…6701` (77) — matches |
| `reconcile.ts` | `efb8f799…3263` (420) — matches |
| `reconcile.spec.ts` | `5b015fae…1fe85` (1207) — matches |
| Frozen S9-0 doc | `cda68d82…7bab1` at `worktrees/64e33dc7-s7l/docs/decisions/2026-09-25-s9-reconciliation.md` — verified by `sha256sum` |
| Also read | `S9_0_REVIEW.md` (R-A1/R-B1 closures, C-1..C-10, RC-1..3), `SCOPE.md` "Parent S9 decisions" and "S9-0 review NO-GO", `arbiter.ts`, `reason-codes.ts`, `scout-reconstruct.dto.ts` (`RECONSTRUCT_FAMILY`, `RECONSTRUCT_MAX_ROWS`), `mapping-spec.ts` (`CanonicalFamily`), S8-DOC §3.2/§3.7/§3.8, migration `20270122000000_scout_native_provenance_expand` (CHECKs), `.github/r75-policy.json`, `lefthook.yml`, `eslint.config.js`, `tsconfig.json`, `jest.config.js` |

### Reviewer-side pre-checks (in `/tmp`, on byte-identical copies; NOT gate receipts)

To avoid the worktree and the slot, I copied the four files plus `src/scout/lifecycle/{arbiter,reason-codes}.ts` and `src/scout/scout.dto.ts` to `/tmp/s9a-review-tc`, symlinked the S7-L donor `node_modules`, and ran read-only checks. Nothing in the workspace was written.

- `tsc --noEmit` (repo `tsconfig.json`, strict; `--listFiles` confirms all four files and `@types/jest` were compiled): **rc 0**.
- `eslint --no-warn-ignored --max-warnings 0` with the repo `eslint.config.js` on both directories: **rc 0**.
- Prettier 3.9.9 (`execution/64e33dc7/recovery-reset/s7l/tools/prettier-3.9.9`, repo `.prettierrc.json`) `--check`: warns on all four files, as SOURCE_READY predicts. I formatted the copies and verified the diffs are layout-only (whitespace, trailing commas, parentheses, one leading `|`): token streams are identical, so the gate's `--write` cannot change semantics. **Predicted post-format sha256** (Phase 2 must match these if the gate uses the same prettier build and config):
  - `types.ts` → `211b474ac29e6fb04c5dadbf5bca9bf3cb86e8da7fb0256bd111d57f68c77114`
  - `coverage.ts` → `eca66f334b73ce3eb3c5902a8392829104e38b3cdef49e9a5c00f35e46eaa8e7`
  - `reconcile.ts` → `63abdee75b246d4de23065d74abb6945c97637aabf8fb04b72d216cf8bfa021a`
  - `reconcile.spec.ts` → `60e79044154cf97fcc7b8a812fa3eb0be25aa19565b4b28877388dd0e0595bae`
- R75 lexical scan of the four files for every policy token (`as any`, `as unknown as`, `as never`, `@ts-ignore`, `@ts-expect-error`, placeholder strings, swallowed-catch forms): none present. The only `as` casts are `as const` and `(X as readonly string[])` widenings, which the policy does not ban.
- Adversarial probe (my own script, not the spec, not jest): 200 000 random `ReconciliationFacts` (50 % near-clean with one random perturbation, 50 % fully random including out-of-type `status`/`native`/`outcome` values parsed from JSON, prototype-named codes such as `unresolved:__proto__`, duplicate coverage keys, `claim` in all four values). 11 985 runs settled `complete`, 188 015 `partial`. For **every** `complete`, an independent re-derivation of D-S9-2 held: staged > 0, `spec_families !== null`, required set (independently recomputed as staged-mapped ∪ coverage keys ∪ spec, sorted) non-empty and equal to both `requiredFamilies(facts)` and `report.required_families`; every member `known:true && covers_staged_identities`; claim `success`; run-wide and attributed `ledger_without_staged` = 0; no unmapped entry; every staged identity `reconstructed` + native kind + provenance `created|already_present` + `present_owned`; no unresolved children; every declared edge from a staged identity targets a staged identity and passes (`true`, or `null` for `client_link` only). Also for all 200 000: outcome ∈ {`complete`,`partial`}; `conditions === []` ⇔ `complete`; `reason_code === conditions[0]`; partition invariant per entry; split fields `null`; `JSON.stringify(reconcile(f))` identical across two calls; input byte-identical after the call; no identity string, `weird*`, `oops`, `__proto__` or `constructor` echoed into the report. **Zero violations.**

## 1. `complete` reachability — proof

`reconcile` (`reconcile.ts` L364-419) emits `{outcome:'complete', reason_code:null}` iff `conditions(facts, families)` returns `[]` (L406-410); the only other literal is `'partial'`. `conditions` (L320-350) pushes a code for each of C-FAM, C-ID, C-REL, C-COV and filters through `S9_REASON_CODES` (so order is pinned to the exported D-S9-2 order). Therefore `complete` ⇒ all four are false:

1. **C-FAM false** (L327-331) ⇒ no report entry has `mapped:false` and no mapped entry's histogram has a key starting `unresolved:no_native_destination:`. Since every `facts.families` entry becomes a report entry (L367, L377), there is no unmapped entry.
2. **C-ID false** (L332-342) ⇒ `facts.ledger_without_staged === 0`, and for every mapped entry `unresolved + rejected + failed === 0`, `unresolved_children === 0`, attributed `ledger_without_staged === 0`. In `reconcileFamily` (L215-226) every identity increments exactly one of the four tallies (`token[cls.bucket] += 1`), so `staged_unique = j + rejected + unresolved + failed` by construction and zero non-j buckets means **every staged identity is bucket j**: `reconstructed`, native `target_kind`, non-null provenance with `outcome !== 'unresolved'`, `native === 'present_owned'` (L136-162). `unresolved_children` sums only under bucket-j parents (L227-240), so no child under any parent is unresolved.
3. **C-REL false** (L343-345) ⇒ no family has a bucket-j identity with a failing edge. With (2) all staged identities are j, so every edge whose `from_identity` is a staged identity is checked (L297) and passes `edgeVerified` (L266-273): target is j in `to_family` and `consistent === true`, or `null` for `client_link` only.
4. **C-COV false** (`coverage.ts` L73-77) ⇒ `requiredFamilies(facts)` is non-null (staged identities > 0 and `spec_families !== null`, L60-61) and non-empty, and for every member `coverageOf(...).known` — which (L35-46) needs `coverage !== null`, `coverage[f]` present, `known:true`, `covers_staged_identities`, **and** `claim === 'success'`. Every mapped staged family is a member (L63), so every family with identities needs a basis. Unmapped staged families are excluded from the set but already trip C-FAM.

Hence `complete` is unreachable except when every D-S9-2 / D-S9-3 condition holds, over the **typed** input domain where `family` is unique per mapped entry (see B-1 for the one type-valid input outside D-S9-2's grouping definition that breaks step 3). In v1 (`coverage: null`, D-S9-3 L222) step 4 makes `complete` unreachable outright; R01b, R18, R18b and the "complete only with non-null coverage and claim success" sweep (spec L1048-1057) pin this.

Confirmed against the S7-L seam: `arbitrate` (`arbiter.ts` L81-86) takes the verdict verbatim at step 3 only; the spec's R09 block (L1137-1194) shows fence and step-2 precedence beating a `complete` verdict, and `revoked → blocked` coming from `FENCE_TERMINALS`, not S9.

## 2. Totality of buckets a–k

`classifyIdentity` (L93-126) returns on every path: unmapped → (a) via `parseLedgerReason(resolution_reason)` then a synthesised `unresolved_family:<token>` or `reason_unrecognised` (token outside `[A-Za-z0-9_.-]{1,64}`); `ledger === null` → (b) ceiling/not_reconstructed; `switch(status)` with `failed` (c), `skipped` (d/e via the closed-catalogue parser), `reconstructed` (f–j in `classifyReconstructed`), `default` (k). Inside `classifyReconstructed`: non-native kind → (f) per-row keyed; `provenance === null || outcome === 'unresolved'` → (g); `switch(native)` h/h/h, i, j, `default` → (k). `parseLedgerReason` (L67-90) returns on every path and never echoes: rejection reasons verbatim only with a token-shaped qualifier; `unresolved_family:<token>` only token-shaped; `unresolved:<code>[:<q>]` only when `code` is in `UNRESOLVED_CATALOGUE` with the matching bare/qualified shape (prototype names such as `__proto__`/`constructor` fail the strict `=== 'qualified'|'bare'` comparison and degrade safely — verified by probe). `UNRESOLVED_CATALOGUE` (`types.ts` L363-379) equals S8-DOC §3.7 (15 codes, shapes correct).

One totality gap on the **out-of-type** domain (C-3 below): a provenance `outcome` outside `created|already_present|unresolved` with `native:'present_owned'` reaches bucket j (L150 only excludes `'unresolved'`). PG forbids it (`20270122000000…/migration.sql` L143 `CHECK ("outcome" IN (...))`) and the TS type forbids it, so no reachable harm, but it is inconsistent with the builder's own stated k-principle ("total without DB CHECKs") and the spec's (k) case (L371-385) probes `status` and `native` only.

## 3. Determinism and purity

No `Date`, `Math.random`, `console`, `localeCompare`, I/O, or `throw` in `src/scout/reconciliation/**` (grep). Comparators are code-unit (`byString`, default `.sort()` on strings). All `Map`/`Set` outputs are sorted before emission (`toReasonCounts`, tokens, `requiredFamilies`, family order) or consumed by key. Input is never mutated: `entries` is a spread copy (L367) before `sort`, `qualifiers` is copied (L397). The spec asserts byte identity, permutation invariance and a no-mutation snapshot (L1104-1132); my probe confirms on 200 000 inputs. Within the declared types nothing can throw; `Object.entries(unresolved_children)` (L234) would throw only on an `undefined` field the type forbids.

## 4. F2, outcome set, seam

- `CREATED_NATIVE_SPLIT: null` fills both split fields (L42, L386-387); types pin them to `null` (`types.ts` L280-281). ✓
- `ReconciliationOutcome = Extract<ServerTerminalStatus,'complete'|'partial'>` (`types.ts` L60); no `blocked|failed|cancelled|timed_out` literal exists in the source. ✓
- Imports: `types.ts` imports **types only** from `lifecycle/{arbiter,reason-codes}`; nothing from `reconstruct/**`, `native/**` or DTOs. D-S9-8 permits `reconstruct/mapping-spec` types too; importing fewer is within "only". ✓
- `ReconciliationVerdictV1.reason_code: S9ReasonCode|null` is intentionally not yet assignable to `ReconciliationVerdict` (three codes missing from `RUN_REASON_CODES` at `df713fd9`); the spec narrows via `isRunReasonCode` and throws if a code is missing (L1139-1143), which is correct until S9-C appends (D-S9-7). ✓

## 5. The seven deviations vs the frozen text

| # | Deviation | Verdict | Doc amendment? |
| --- | --- | --- | --- |
| 1 | `family`/`spec_families`/coverage keys typed `string`, not `CanonicalFamily` | **Acceptable.** Premise verified: `RECONSTRUCT_FAMILY` at `df713fd9` = `clients|workouts|client_history` (`scout-reconstruct.dto.ts` L11-15), yet R06/E-R1 needs `programs`. Widening only adds required families (safe direction) and keeps the reconciler total over tokens. | Optional note at D-S9-3 L194 (`Record<CanonicalFamily,…>` → `Record<string,…>` until `programs` lands). Class C. |
| 2 | `CoverageFact.known:true` carries `basis_kind: string`; `completeness_basis: string` (`'none'` ⇔ predicate false) | **Acceptable in behaviour, deviates in typing.** The doc's `COMPLETENESS_BASIS_KINDS = ['none']` cannot name a `known:true` row, so the kind must come from the fact; v1 output is always `'none'`. But the doc says the manifest field is drawn from a **closed enum** and S9-A exports no `COMPLETENESS_BASIS_KINDS`, which S9-C's DTO/OpenAPI enum will need. | Yes, one line at D-S9-3 L217-218: "the report carries the fact's `basis_kind`; the closed enum `COMPLETENESS_BASIS_KINDS` (`['none']` in v1, appended by S10) is enforced at the DTO". Recommend S9-A also export the constant (C-5). Class C. |
| 3 | `observed_unique` numeric whenever a fact carries one, even under `'none'` | **Acceptable for v1** (always `null` with `coverage:null`). On the S10 branch it reports a counted fact beside a `'none'` basis; R12's "a number is always a counted fact" holds, but D-S9-5 L280 types the field `null`. | Yes, D-S9-5 L280 `observed_unique: null` → `number \| null` (S10 branch). Class C. |
| 4 | `outcome:'unresolved'` on a native-kind row → g; `provenance_mismatch` → h | `provenance_mismatch` → h **is** the doc's h (L112 "Provenance native_kind/native_id differ from ledger"), not a deviation. `unresolved`-provenance → g is a defensible reading of "no provenance of a native row"; verdict identical (unresolved). Note the out-of-type gap C-3. | No. Class C. |
| 5 | Edges from non-j identities ignored; `not_applicable` when no j identity in the family had an edge | Verdict-neutral (the non-j identity already trips C-ID). But `not_applicable` now also covers "edges existed, none was on a j identity" — the "not checked" reading S9-0 review C-10 said the value must never carry. S9-A cannot tell "contract declares no edge" without a fact. See also **B-2**: S9-A can only check edges S9-B emits. | Yes, D-S9-2 L145 wording: "`not_applicable` when no bucket-j identity of the family carries a declared edge". Class C. |
| 6 | New fact fields `ProvenanceFacts.reason`, `IdentityFacts.client_linked`; new report fields `required_families`, `ledger_without_staged` | **Acceptable, additive.** The fact fields implement the folded C-4 per-row bucket-f rule (doc L110). Report fields are outside the D-S9-5 sketch but internal; S9-C may omit them from the DTO. `required_families` on the report is useful evidence for the `complete` bar. | Optional: add the two fields to the D-S9-5 sketch when the doc is next opened. Class C. |
| 7 | All report fields always present; optionality is a DTO property | **Not a deviation** — this is exactly R-B1 option (i) (D-S9-5 L306-313). | No. |

**Unlisted deviation (C-6):** for an unmapped entry the ledger row is ignored (L94-104); the doc's bucket a is "unmapped entry **with no ledger row**", so an unmapped identity that does have a ledger row would fall to c/d/e under the doc. S8-A writes `skipped`/`unresolved_family:<token>` rows for unmapped tokens, so the doc route (e) and the code route (a) produce the same key; only a `failed` ledger row under an unmapped token differs (`failed` vs `unresolved_family:<token>`). Verdict identical (C-FAM). Record as a doc clarification.

## 6. Spec coverage R01–R19 (A tier) — no vacuous rows

44 verdict-table rows each assert `verdict` with `toEqual`, run `expectWellFormed` (outcome set, `conditions` order/uniqueness and `[0] === reason_code`, `required_families` sorted and ⊆ reported families, run-wide ≥ attributed `ledger_without_staged`, no sentinel/`truecoach:` in the JSON, family sort, split `null`, partition invariant per entry and per token, histogram sums, every key `inCatalogue`, D-S9-3/S10 fields `null`), and most add a row-level `check`. I hand-verified the expected values of R03, R-A1, C-FAM no-destination, R17 (all four), R06 parent-unresolved, R12, the histogram-order case and `requiredFamilies` (`client_history` < `clients` by code unit); all agree with the code.

| Case | Rows | Meaningful? |
| --- | --- | --- |
| R01a/b/c/d | L439-580 (a: full-row `toEqual`; b ×2; c ×2 incl. `claim:null`; d ×2 incl. the zero-row declared entry) | Yes |
| R02, R02b | L603, L866 | Yes (bucket + key + partial/unresolved_identities) |
| R03, R03b | L616 (full row), L651 | Yes; R03 also asserts C-ID does **not** fire for the unmapped entry |
| R04 | L676 (i), L690 (h ×3) | Yes |
| R05 | L704, L723 | Yes (equal counts ≠ reconciliation; attributed-only) |
| R06 | L730-824: E-R1 false / null / parent-unresolved; E-R2; bucket-f not double-counted; E-R3 target not j; two edges count once; full closure → `complete` | Yes; `(week_index, day_index)` mismatch is necessarily folded into `consistent:false` |
| R07 | L826, L850 | Yes (client-owned family; per-row link) |
| R08 | L915 (10 000 + 250 rows, `ceiling_exceeded`) | Yes, plus L1041 never-`blocked` sweep |
| R09 | L1137-1194 (steps 1-3 with a real S9 `complete`) | Yes, at unit level (C tier is S9-C) |
| R10 | L1091-1132 | Yes (bytes, permutation, replay, no mutation) |
| R12 | L954 + partition invariant in every case | Yes |
| R14 | L247-281 parser table (16 rows + catalogue round-trip), `inCatalogue` on every emitted key, sentinel sweep, L1196 enum shape | Yes |
| R17 | L1001, L1015, L1022 | Yes |
| R18, R18b | L533, L540, L547 (+ `requiredFamilies` null table L415-423) | Yes |
| R19 | L893 | Yes (`already_present` parent, `child_reasons`, count 7) |
| R11/R13/R15/R16 | correctly excluded (B/C tiers) | — |

Gaps (all class C): no row for duplicate mapped `family` entries (B-1), out-of-type provenance `outcome` (C-3), an unmapped token colliding with a mapped family name (C-2), or a `failed` ledger row under an unmapped token (C-6).

## 7. Findings (Safety-ROI)

### B-1 (class B): duplicate mapped entries with the same `family` collapse the bucket-j map, so a failing edge can be skipped and `complete` emitted

- **Where:** `reconcile.ts` L291-292 — `for (const o of outcomes) verifiedByFamily.set(o.facts.family, o.verified);` (last writer wins); L308-315 keys closures by family the same way.
- **Defect:** if `facts.families` contains two `mapped:true` entries named e.g. `workouts`, the first entry's bucket-j set is overwritten. An edge whose `from_identity` is in the first entry is then not found at L297 and is **skipped** (treated as "from a non-j identity"), never counted as failing. Reproduced with a type-valid input: two `workouts` entries, one `programs`, one `program_parent` edge from the first `workouts` identity with `consistent:false`, coverage known for all, claim `success` → `{outcome:'complete', reason_code:null}`; report shows both `workouts` rows `not_applicable`.
- **Concrete harm:** a false `complete` terminal (MISSION L93, PLAN L29) on the single code path allowed to emit it — conditional on S9-B emitting more than one mapped entry per canonical family, which D-S9-2 "Grouping" forbids but the `ReconciliationFacts` type does not. Unreachable in v1 (`coverage:null`), reachable after S10.
- **Decision blocked:** none of the S9-A gate steps as such; it blocks accepting the "unreachable except when every D-S9-2 condition holds" claim over the full typed input domain.
- **Minimum closure (pick one; (a) recommended because the files are uncommitted):**
  - (a) S9-A, ~3 lines at L291-292: union per family instead of overwrite — `const prev = verifiedByFamily.get(o.facts.family); verifiedByFamily.set(o.facts.family, prev === undefined ? o.verified : new Set([...prev, ...o.verified]));` — plus one verdict-table row (two same-named mapped entries, failing edge from the first → `partial/relationship_unverified`). This also removes the C-2 spurious `unverified` for an unmapped token that shadows a mapped family.
  - (b) S9-B grant clause: "`family` is unique among `mapped:true` entries and `(mapped,family)` is unique overall", with a `facts.service.spec.ts` assertion; S9-A unchanged.
- **Execution unlocked:** S9-A gate and commit with the reachability claim holding over the typed domain; otherwise the S9-B grant carries the invariant.

### B-2 (class B, cross-slice contract): S9-A verifies only the edges it is given; S9-B must emit an edge for every identity the contract declares one for, including unresolvable parents

- **Where:** `reconcile.ts` L287-317; `types.ts` L197-209 (`RelationshipFacts` doc says "One declared edge" but not that S9-B must emit one per declared relationship).
- **Defect/gap:** a family whose bucket-j identities carry no edge in `facts.relationships` reports `verified`/`not_applicable` and never trips C-REL. If S9-B emits E-R1/E-R2 edges only when it *finds* a parent (e.g., `program_id` NULL or pointing outside this run's provenance → no edge), a program-day plan with a missing parent passes closure.
- **Concrete harm:** false `complete` after S10 for a run with a missing parent link (PLAN L29 "relationship … unknown"). Not reachable in v1.
- **Decision blocked:** the S9-B grant text, not the S9-A commit.
- **Minimum closure:** one sentence in the S9-B grant (and, optionally, in the `RelationshipFacts` doc comment when the file is next touched): "For every staged identity whose canonical family declares E-R1/E-R2/E-R3, S9-B emits exactly one edge; when the parent cannot be resolved through provenance the edge is emitted with an unresolvable `to_identity` (or `consistent:false`) so that it fails closure."
- **Execution unlocked:** S9-B design that cannot silently drop a declared edge.

### Class C (record; none blocks)

- **C-1. Deviation 2 typing.** Export `COMPLETENESS_BASIS_KINDS = ['none'] as const` from `types.ts` for S9-C's DTO enum; doc line D-S9-3 L217-218 to say the report carries the fact's `basis_kind`. (See table §5.)
- **C-2. Name collision between an unmapped token and a mapped family** (`reconcile.ts` L366 builds `staged` from all entries, mapped or not; L291-292 overwrite). With a mapped `clients` and an unmapped entry whose token is `clients` (possible in a two-platform run: unmapped entries are keyed by raw token), (i) the zero-row declared entry is not synthesised (C-COV still evaluates the family through `required`, so the verdict is right), and (ii) the unmapped entry's empty j-set shadows the mapped one, producing a spurious `relationship_unverified` (safe direction; C-FAM already fires). Fix: `filter((f) => f.mapped)` at L366 and the B-1(a) union.
- **C-3. Out-of-type provenance `outcome` reaches bucket j** (`reconcile.ts` L150). Tighten to `provenance.outcome !== 'created' && provenance.outcome !== 'already_present'` → g (or k), and add the JSON-parsed case to the (k) test at L371. Unreachable from PG (CHECK at migration L143) and from TS; contradicts the stated k-principle only.
- **C-4. Doc-comment misplacement** (`types.ts` L18-25): the JSDoc written for `S9_REASON_CODE` attaches to `ClaimStatus`. Swap the two blocks.
- **C-5. `spec_families` comment vs doc rule** (`types.ts` L232-239): says `null` when "no staged row names a registered platform"; D-S9-2 L170-174 says `null` when **any** staged platform lacks a spec. Verdict-neutral (an unregistered platform's rows are unmapped → C-FAM), but S9-B reads this comment. Reword.
- **C-6. Unmapped entries ignore the ledger row** (doc bucket a says "with no ledger row"). Verdict-neutral; doc clarification.
- **C-7. `not_applicable` broadening** (deviation 5) vs S9-0 review C-10; doc L145 wording.
- **C-8. Builder's own B notes are correct and stay C at S9-A:** `client_linked` sourcing (S9-B, S8-DOC L320-323), catalogue drift (S9-C equality spec), ceiling keyed per family (histogram-only, safe direction).
- **C-9. Prettier will rewrap** the spec's long `it.each` rows and four `src` sites; layout-only (verified). Post-format hashes predicted above.

## 8. What this review does not claim

- I did not run the repo's jest suite, the pre-commit hooks, whole-repo `tsc`, or anything under the slot; the tsc/eslint/prettier results above are read-only reviewer pre-checks on copies and do not replace the gate receipts.
- R11, R13, R15, R16 are S9-B/S9-C tiers and are not assessed here.
- Correctness of S9-B's facts (joins, grouping, `client_linked`, edge emission) is assumed as the doc defines it; B-1/B-2 record where S9-A relies on that.

---

**PHASE1 DONE.** Verdict-so-far: **GO for source, conditional.** `complete` is provably unreachable unless every D-S9-2/D-S9-3 condition holds over the doc-conformant input domain (and outright unreachable in v1); buckets a–k are total on the typed domain (one out-of-type gap, C-3); pure and deterministic (proved by reading and by a 200 000-input probe); F2 split `null`; `blocked` cannot be emitted; the seven deviations are each acceptable (2, 3, 5 need one-line doc amendments when the doc is next opened; none needs redesign); R01–R19 A-tier rows are all meaningful. Two class B findings, neither a product-code defect in v1: **B-1** should be closed in source before the gate via the 3-line union at `reconcile.ts` L291-292 plus one spec row (or, at the parent's option, moved into the S9-B grant as a facts invariant — in which case S9-A is GO as-is); **B-2** is an S9-B grant sentence. Phase 2 will check: committed bytes = reviewed bytes post-prettier (expected hashes listed above, unless B-1(a) is applied, in which case I re-diff the changed hunk), genuine gate/hook receipts, author identity, and issue the final GO/NO-GO.
