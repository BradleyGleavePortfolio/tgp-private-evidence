# S9-A independent review B (T4, non-builder) — pure reconciler

Reviewer B. Read-only: no git writes, no lock, no tests/gates, no evidence-repo commit. This file is
the only file written. `S9_A_REVIEW_A.md` was not read.

## Phase 1 (source, pre-gate) — 2026-09-25

### Subject verified

- Worktree `/home/user/workspace/worktrees/daceddc8-s9a`, branch `exec-dace/s9-a`, HEAD
  `df713fd9` (= `integration/importer`). `git status --short` = exactly `?? src/scout/reconciliation/`
  and `?? test/scout/reconciliation/`. No tracked file touched.
- sha256 of the four untracked files match `S9_A_SOURCE_READY.md` byte for byte:
  `types.ts eff1479c…`, `coverage.ts c6b224fa…`, `reconcile.ts efb8f799…`,
  `reconcile.spec.ts 5b015fae…`.
- Binding spec `docs/decisions/2026-09-25-s9-reconciliation.md` at
  `worktrees/64e33dc7-s7l` re-hashed: `cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1` ✓.
- Also read: `S9_0_REVIEW.md` (incl. re-review), `SCOPE.md` L150-301 (F1/F2, R-A1/R-B1
  dispositions, S9-A-1 grant), `lifecycle/{arbiter,reason-codes}.ts` at `df713fd9`, S8-C
  `src/scout/reconstruct/native/{native-contract,persist-outcome,native-writers,native-provenance}.ts`
  and `scout-reconstruct.service.ts`, `families.ts` at `f428db9a`, migrations `20270120…` (platform
  CHECK) and `20270122…` (provenance CHECKs), `lefthook.yml`, `eslint.config.js`, `.prettierrc`,
  `.github/r75-policy.json`.
- Static checks I ran (no gate, no write): TypeScript 5.9.3 `createSourceFile` parse of all four
  files → 0 parse diagnostics; an in-process regex scan of the four files against every R75 policy
  token → 0 hits. I did **not** run tsc/eslint/prettier/jest (slot discipline); type-level
  reasoning below is by eye.

### 1. Can any fact combination yield `complete` wrongly?

`complete` ⇔ `conditions()` returns `[]`. I traced every disjunct and constructed inputs against each.

| # | Attack input (constructed) | Path in code | Result |
|---|---|---|---|
| 1 | Zero staged rows, `coverage: {}` / populated, `spec_families` set, claim `success` | `requiredFamilies`: `staged === 0 → null` → `coverageConditionHolds → true` | partial / `coverage_basis_unknown` (R18, R18b) |
| 2 | Staged rows only in an unmapped entry (`notes` on a registered platform), full coverage | `families.some(!mapped)` | partial / `unresolved_family` |
| 3 | Unregistered platform (`spec_families: null`) with coverage vouching for every token | required `null` and unmapped entry | partial / `unresolved_family` + `coverage_basis_unknown` |
| 4 | Mapped family, all identities bucket j, `ledger_without_staged` only run-wide (`facts.ledger_without_staged: 1`, family 0) | C-ID first disjunct | partial / `unresolved_identities` (C-2 folded correctly) |
| 5 | All j, `unresolved_children: {'unresolved:exercise_reference': 1}` on an `already_present` parent | counted under bucket-j parent only → `unresolved_children > 0` | partial / `unresolved_identities` (R19) |
| 6 | All j, coverage `known:true` but `covers_staged_identities:false`; or claim `partial`/`null` | `familyCoverage → known:false` | partial / `coverage_basis_unknown` |
| 7 | All staged families covered, `spec_families` names an unstaged family absent from the map | `declaredOnly` zero-row entry, `coverageOf → UNKNOWN` | partial / `coverage_basis_unknown` (R01d) |
| 8 | `reconstructed` + native kind + provenance `created` + `native: 'present_owned'` but `client_linked: true` and no edge supplied | bucket j; E-R3 only via `relationships` | `complete` possible — **S9-B obligation** to supply the E-R3 edge (doc: E-R3 reached only by a future client-owned writer). Not an S9-A defect. |
| 9 | Edge from a bucket-j identity with `consistent: null` on `program_parent`/`child_order` | `edgeVerified → false` | partial / `relationship_unverified` (never assumed) |
| 10 | Edge whose `from_family`/`from_identity` does not match any bucket-j identity | skipped | Edge not counted — correct per doc (only bucket-j identities count) but a wrong `from_family` from S9-B hides a real failure. S9-B obligation. |
| 11 | `target_kind: 'scout_entity'` with provenance `created`/`present_owned` | `!isNativeKind → bucket f` | unresolved (`evidence_only`) — evidence never counts (R07) |
| 12 | Ledger `skipped` with `unresolved:no_native_destination:exercises` in a mapped family | verbatim (qualified) → C-FAM prefix match | partial / `unresolved_family` + `unresolved_identities` |
| 13 | Negative / NaN counts (`ledger_without_staged: -1`, child count `NaN`) | `> 0` false | Ignored (would hide a contradiction) — only reachable with corrupt facts; SQL counts cannot be negative. Class C note. |
| 14 | `coverage` key `'__proto__'` / `'constructor'`, or a staged token so named (ingest accepts any 1-128 char `entity_type`) | `facts.coverage[family]` → prototype object → `.known` undefined → `UNKNOWN`; `UNRESOLVED_CATALOGUE['__proto__']` → not `'bare'|'qualified'` → `reason_unrecognised` | No throw, no false `known`. Maps used for all counting. |

**Result: no fact combination with well-typed input reaches `complete` without every D-S9-2/D-S9-3
conjunct holding.** The only ways to `complete` are legitimately the R01a shape: non-null, non-empty
`required_families`, every member `known:true && covers_staged_identities`, claim `success`, every
identity bucket j, no children, no `ledger_without_staged`, no failing bucket-j edge. I confirm the
builder's claim that **`complete` is unreachable in v1**: with `coverage: null`, `coverageOf` returns
`UNKNOWN` for every family, so C-COV holds whenever `required_families` is non-null, and it also holds
when `required_families` is null.

Type-level guarantee: `ReconciliationVerdictV1.outcome` is `Extract<ServerTerminalStatus, 'complete' |
'partial'>`, so `blocked|failed|cancelled|timed_out` cannot be emitted (D-S9-1, D-S9-6). The verdict
literal is constructed at exactly one site (`reconcile.ts` L407-410).

### 2. Throws / nondeterminism

- **Typed input:** no throw path. `switch` defaults return `UNRECOGNISED`; `parseLedgerReason` handles
  `null`; optional chaining on `provenance`; prototype-key lookups fall through safely (row 14).
- **Untyped input** (only via `JSON.parse`-style data): `Object.entries(row.provenance.unresolved_children)`
  and `[...o.facts.qualifiers]` throw `TypeError` on `null`. The type forbids it; S9-B compiles against
  the type. Recorded as C-9.
- **Determinism:** no `Date`/`Math.random`/`localeCompare`; every emitted array is sorted with a
  code-point comparator (`.sort()` default and `byString` agree on UTF-16 order); `Object.entries`/
  `Object.keys` order is neutralised by Map + sort; input is copied before `sort` (`[...facts.families]`)
  so no mutation. Report object keys are constructed in a fixed literal order → byte-identical JSON.
  The one order-dependence is **duplicate `family` names across entries** (stable sort keeps input
  order) — see C-4; S9-B must not produce them, and the verdict is unaffected when it does.

### 3. Raw / PII text in the report

Strings that reach the report: `family`, `tokens[].token`, `reasons[].code`, `child_reasons[].code`,
`qualifiers[]`, `completeness_basis`, `required_families[]`, `conditions[]`.

- `family`/`token` for an **unmapped entry is the raw staged token** (client-controlled, 1-128 chars).
  This is what D-S9-5 mandates (`family: string; // … the staged token for an unmapped entry`) and
  S9-0 review C-6 accepted, because S7-L's `families[].family` already projects the same token. Not a
  new exposure. Verified by construction, not by a report-level spec (the sentinel test uses tokens
  without the sentinel).
- `reasons[].code`: bucket c never echoes (`'failed'`); `skipped` reasons echo only when they parse in
  the closed grammar with a `[A-Za-z0-9_.-]{1,64}` qualifier; anything else → `reason_unrecognised`.
  `unresolved_family:<token>` is echoed only when the token passes the same regex (an email or a
  space fails). Good.
- `child_reasons[].code`: **echoed verbatim without a catalogue check** (`bump(childReasons, code, count)`,
  `reconcile.ts` L234-238). See C-1.
- `identity` (opaque S9-B string) is never copied anywhere; the spec asserts the sentinel and the
  `truecoach:` prefix are absent from the JSON. ✓
- `ProvenanceFacts.reason` is compared only (`=== no_native_client_principal`), never emitted. ✓

### 4. Can S9-B supply the fact types truthfully from S8-C's landed grammar (`f428db9a`)?

| S9-A fact | S8-C / schema source | Supplyable? |
|---|---|---|
| `LedgerRowFacts.status` `reconstructed|skipped|failed` | `RECONSTRUCT_STATUS`; `scout-reconstruct.service.ts` L190-270 writes exactly these | ✓ |
| `target_kind` `person|scout_entity|workout_program|workout_plan|null` | `LEDGER_TARGET_KIND` (`persist-outcome.ts` L15-20) + NULL for legacy `string` results (e.g. `clients` at `f428db9a` returns `person.id` untyped → NULL) | ✓ byte-identical set. Note: at `f428db9a` every `clients` row is bucket f (`evidence_only`) because the person writer still returns the legacy shape; truthful `partial`. |
| `skipped.reason` grammar | `unsupported_platform:<p>`, `missing_source_id`, `unresolved_family:<token>`, `unresolved:<code>[:<qualifier>]` (`native-contract.ts` `unresolved()`, `mapping-spec.ts` L135/140/198) | ✓ all four shapes handled. `failed` reasons are `error:Prisma.<code>|error:Error|error:unknown` — never echoed by S9-A. ✓ |
| `UNRESOLVED_CATALOGUE` vs `UNRESOLVED_CODE` | S8-C: 12 codes; `QUALIFIED` set = {missing_required_field, invalid_value, enum_unmapped, prescription_not_integral, relationship_pending, relationship_missing, native_uniqueness}; bare = {exercise_reference, no_native_client_principal, native_target_removed, identity_conflict, source_archived} | ✓ S9-A agrees on all 12 shapes. S9-A adds 3 S8-DOC codes S8-C does not emit (`no_native_destination`, `unit_unknown`, `date_zone_unknown`) — superset, safe. S8-C's qualifier regex `[a-z_.A-Z]+` (no length cap) is within S9-A's `{1,64}` for every real native name I found (longest: `WorkoutPlanExercise.reps_or_duration_seconds`-scale ≈ 41). |
| `ProvenanceFacts.outcome` | `PROVENANCE_OUTCOME` + CHECK (`created|already_present|unresolved`) | ✓ |
| `ProvenanceFacts.native` (5 checks) | Derived by S9-B: `provenance_mismatch` = provenance `native_kind/native_id` ≠ ledger `target_kind/target_id`; `removed` = target row null or `archived_at` set; `foreign_owner` = `coach_id` ≠; `kind_mismatch` collapses into `removed` unless S9-B probes other tables. Mirrors S8-C's own `verifyTarget` (`native-writers.ts` L66-89). | ✓ (all non-`present_owned` values are unresolved, so the collapse is harmless) |
| `ProvenanceFacts.reason` | Provenance `reason` column. **On `created` rows S8-C writes tags** (`defaulted:<field>`, `prescription:time`, comma-joined — `CREATED_TAG`/`joinTags`), not `null` | ✓ supplyable; the S9-A type comment ("else null") is wrong but the code only equality-compares. C-7. |
| `unresolved_children` histogram | Provenance rows `entity_type='workouts.exercise'`, `native_kind='workout_plan_exercise'`, `outcome='unresolved'`, `source_id LIKE '<len>:<parent>#%'` GROUP BY `reason` (`native-provenance.ts` L115-126, `childSourceIdPrefix`) | ✓ every child reason is an `unresolved(...)`-built string today (`native-writers.ts` L285-305), so all keys are in-catalogue. |
| `client_linked` | `ScoutReconstructedEntity.client_source_id` (evidence row, `native-writers.ts` L389-404) or the S8-A interpreter over the staged payload | ✓ |
| `client_owned`, `qualifiers`, `ceiling_exceeded`, `resolution_reason`, `spec_families` | D-S8-2 interim list; `roster_bridge_pending` for `clients`; per-`entity_type` pass ceiling (`RECONSTRUCT_MAX_ROWS`); `resolveStagedFamily`; registry spec `families` keys | ✓ |
| `RelationshipFacts.consistent` | E-R1/E-R2 need S9-B to compare native `program_id`, `(week_index, day_index)`, `workout_plan_id`, `order` against interpreter derivations; `null` = not compared | ✓ abstraction is right; the comparison burden is S9-B's (R16). |
| `claim` | `ScoutImport.claimed_status` (`ScoutTerminalStatus | null`) — `ClaimStatus = ArbiterInput['claim']` | ✓ |

Conclusion: every fact type is supplyable from the landed grammar without a cast or a lossy mapping.

### 5. The seven deviations vs the frozen text

| # | Deviation | Judgement |
|---|---|---|
| 1 | `family`/`spec_families` typed `string`, not `CanonicalFamily` | **Accepted, necessary.** `RECONSTRUCT_FAMILY` at `df713fd9` lacks `programs`; R06 needs it. S9-A never branches on a family name. D-S9-8's "imports … `reconstruct/mapping-spec`" becomes "imports nothing from reconstruct" — a strict subset, fine. S9-B narrows at collection. |
| 2 | `CoverageFact.known:true` carries `basis_kind: string`; `completeness_basis: string` | **Accepted as a D-S9-3 amendment for S10.** The doc's `none ⇔ known:false` cannot hold for a `known:true` row unless the kind comes from somewhere; the fact is the right place. v1 unchanged. Gap: no exported closed list (`COMPLETENESS_BASIS_KINDS`) for S9-C's DTO enum — C-6. |
| 3 | `observed_unique` numeric whenever a fact carries one, even under basis `'none'` | **Accepted.** D-S9-5's rule is "null only where the basis is absent" (null ⇒ absent), which this preserves; "stays null until an observation contract exists" holds in v1. The spec pins basis ≠ none ⇒ number. |
| 4 | Native kind + provenance `unresolved` → bucket g; `provenance_mismatch` → h | **Accepted; second half is not a deviation** (doc bucket h already says "Provenance native_kind/native_id differ from ledger target_kind/target_id"). The first half is a contradiction state the doc's k would key `reason_unrecognised`; g is more informative and equally unresolved. |
| 5 | Edges from non-j identities ignored; `not_applicable` when no j-edge checked | **Accepted for the verdict** (doc defines `relationship_unverified` over bucket-j identities only). The `not_applicable` semantics drift toward "not checked" that S9-0 C-10 warned about — C-5, verdict-neutral. |
| 6 | New fact fields (`ProvenanceFacts.reason`, `client_linked`) and report fields (`required_families`, `ledger_without_staged`) | **Accepted.** The two fact fields are exactly what the folded C-4 requires; the two report fields are additive and let a reader audit the `complete` bar (report is internal; S9-C projects a subset). |
| 7 | Report fields always present; optionality is a DTO property | **Correct** reading of R-B1 option (i). |

### 6. Conformance spot-checks against the frozen doc (all hold)

- Bucket order a→k first-match, keys per D-S9-2/D-S9-7 (incl. per-row f keying, folded C-4). ✓
- Partition invariant `staged_unique = j + rejected + unresolved + failed` per entry and per token — enforced structurally (one bucket per identity, `token[cls.bucket] += 1`). ✓
- Conditions D-S9-2 order, `reason_code = held[0]`, `[]` iff `complete`; order pinned through `S9_REASON_CODES.filter`. ✓
- `required_families` = mapped staged ∪ coverage keys ∪ spec; `null` on zero rows or `spec_families === null`; zero-row mapped entry synthesised for required-but-unstaged families. ✓ (R-A1 closure implemented exactly.)
- `coverageKnown` = present ∧ `known` ∧ `covers_staged_identities` ∧ claim `success`. ✓
- F2: `created_native`/`already_present_verified` are the `null` literal constant; `native_present_verified` is the union. ✓
- Sorting (mapped desc, family), tokens by token, histograms by code. ✓
- Arbiter composition (R09 at unit level): `complete` verdict flows through step 3; fences and step 2 win; `revoked → blocked` only from the fence. ✓
- Imports: types only from `lifecycle/{arbiter,reason-codes}`; nothing from `native/**` or `reconstruct/**`. ✓ `S9ReasonCode ⊆ RunReasonCode` is deferred to S9-C exactly as D-S9-7 says; the spec narrows through `isRunReasonCode` so it cannot flip when the enum grows.

### 7. Findings (Safety-ROI). No class A. No class B (no concrete harm at this head).

**C-1. `child_reasons` keys are not run through the closed catalogue.** `reconcile.ts` L234-238 echoes
every `unresolved_children` key verbatim. R14 says "every histogram key is in the D-S9-7 catalogue" and
D-S9-7 says an out-of-grammar reason is "never echoed"; S9-A enforces this for `reasons` but not
`child_reasons`. No concrete harm today: every S8-C child reason is core-built via `unresolved()`
(§4 table). *Minimum closure:* pass each child key through the same `unresolved:` bare/qualified check
(`parseLedgerReason`-equivalent; bucket irrelevant) and fold non-parsing keys into
`unresolved:reason_unrecognised` with the count preserved; add one spec row with a free-text child key.
Cheapest in the gate phase if tsc/eslint already reopen a file; otherwise carry to the S9-B grant as a
must-filter and to the S9-C catalogue-equality spec (S9-0 C-9).

**C-2. `spec_families` null-rule comment is weaker than the doc.** `types.ts` L232-238 says `null`
when "no staged row names a registered platform"; D-S9-2 L170-174 says undeterminable when *any*
staged platform has no spec. Verdict unaffected (that platform's rows form an unmapped entry → C-FAM),
but `required_families` would be reported non-null where the doc says undeterminable. *Closure:* fix
the comment; state the "any" rule in the S9-B grant.

**C-3. `TOKEN` is narrower than the platform CHECK.** `^[A-Za-z0-9_.-]{1,64}$` vs the DB's
`^[a-z0-9][a-z0-9._:-]{0,255}$` (colon allowed, up to 256). A legal platform token containing `:` or
longer than 64 makes `unsupported_platform:<p>` degrade to `reason_unrecognised` (bucket d) and, for an
unmapped entry, flips bucket a from `rejected` to `unresolved` / `unresolved_family:<token>`. Verdict
unaffected (C-FAM/C-ID still fire). No registered platform today has a colon. *Closure:* widen the
platform-branch regex to the CHECK grammar, or accept the histogram imprecision.

**C-4. Duplicate `family` names across entries are not guarded.** A mapped canonical `clients` beside
an unmapped token `clients` (unregistered platform) is a realistic S9-B output. Then
`verifiedByFamily`/`closures`/`out` are keyed by name and the later entry overwrites: the mapped
family's bucket-j edges are skipped and its closure shows `not_applicable`; also the `declaredOnly`
zero-row entry is suppressed when an unmapped token equals a required family (`staged.has(family)`
includes unmapped names). Report order for identical `(mapped, family)` pairs follows input order.
Verdict unaffected (any unmapped entry ⇒ `partial`). *Closure:* key closure maps by
`${mapped ? 1 : 0}:${family}` or by entry index; S9-B invariant "one entry per (mapped, name)".

**C-5. `relationship_closure: 'not_applicable'` also means "no bucket-j identity to check".** A family
whose contract declares edges but whose identities are all non-j reports `not_applicable`, the
"not checked" reading S9-0 C-10 excluded. Verdict-neutral. *Closure:* carried C-10 wording in S9-B, or
a `declares_edges` family fact.

**C-6. No exported closed `COMPLETENESS_BASIS_KINDS`.** Only `COMPLETENESS_BASIS_NONE` exists;
`completeness_basis` is `string`. S9-C's DTO needs a closed enum (S9-0 C-7 asked the same for
`qualifiers`). *Closure:* `export const COMPLETENESS_BASIS_KINDS = ['none'] as const` in `types.ts`,
and record deviation 2 as a D-S9-3 amendment for the S10 grant.

**C-7. `ProvenanceFacts.reason` comment says `null` unless `unresolved`.** S8-C writes created-row
tags (`defaulted:<field>`, `prescription:time`, comma-joined) into `reason`. Code is unaffected
(equality compare only). *Closure:* comment fix so S9-B passes the column verbatim.

**C-8. JSDoc misplacement.** The `S9_REASON_CODE` docblock (`types.ts` L18-23) is attached to
`ClaimStatus`. Cosmetic.

**C-9. "No exceptions" holds only for typed input.** `Object.entries(null)` / spread of `null`
`qualifiers` throw. Same posture as the arbiter; note in the S9-B grant that `unresolved_children` is
always `{}` and `qualifiers` always `[]`.

**C-10. Per-family ceiling keying** (builder's own B): every ledger-less identity in a
`ceiling_exceeded` family is keyed `pass_ceiling_exceeded`, including ones missing for other reasons.
Safe direction; histogram-only. Agree it is C.

**C-11. Bucket a accepts `missing_source_id` as a resolution reason** (→ `rejected`/`missing_source_id`
for every identity of the entry). Outside the doc's two named reasons; harmless; S9-B never produces it.

**C-12. Spec gap tied to C-1:** `expectWellFormed` asserts `inCatalogue` over `child_reasons`, but no
fixture supplies an out-of-grammar child key, so the missing filter is not caught.

### 8. Phase-2 checklist (what I will verify after the parent pins the commit)

1. Committed HEAD is a child of `df713fd9`; tree contains exactly the four paths; no other tracked
   change. Author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`.
2. Committed bytes = reviewed bytes modulo prettier: I will diff each committed file against the
   reviewed sha256'd bytes with whitespace/newline/trailing-comma/paren normalisation and confirm the
   token stream is unchanged; any semantic edit (e.g. a tsc fix under step 6) will be re-reviewed as a
   delta against this Phase 1.
3. Gate receipts: prettier 3.9.9 `--check` rc 0 on the four files after `--write`; eslint
   `--max-warnings 0` rc 0; whole-repo `tsc --noEmit` rc 0; jest on `reconcile.spec.ts` with counts
   consistent with the builder's tally (16 + 1 parse rows, 24 + 4 classify, 7 + 1 + 5 coverage,
   44 verdict rows + 3, 12 edge rows, 4 determinism, 4 arbiter); lefthook pre-commit (R75 staged,
   tsc, eslint, prettier, prod-readiness-quick) and commit-msg receipts genuine, no `--no-verify`.
4. Lock discipline receipts (fd 9 `flock -n`, holder refused rather than stolen, lock file preserved);
   `node_modules` copied from the donor and `npm_config_prefix` unset afterwards.
5. Post-format sha256s recorded in the gate log.

### Verdict so far (Phase 1)

**GO-so-far on the source, class C only.** No input combination I could construct yields `complete`
without every D-S9-2/D-S9-3 conjunct; `complete` is provably unreachable with `coverage: null`
(v1); the function is total, throw-free and byte-deterministic on typed input; no raw identity, ledger
reason, failed-reason or provenance reason reaches the report beyond the doc-sanctioned staged-token
echo; every fact type maps to the landed S8-C ledger/provenance grammar without loss; the seven
deviations are either necessary at `df713fd9` or additive and doc-compatible. C-1 is the one I would
most like closed before S9-C wires the report into the status body, but it has no concrete harm at
this head and needs no redesign. Final GO/NO-GO is withheld until the Phase-2 receipts.

PHASE1 DONE
