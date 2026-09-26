# S10: unseen-source induction, observation evidence and settle-time coverage

- **Status:** T0 cross-slice contract for S10-A (pure contract and evaluator), S10-B (observation
  persistence and route), S10-C (facts/settle wiring) and S10-D (synthetic source and core-diff
  gate). Local draft, uncommitted. Changes no code, schema or API; claims nothing has run; grants
  no builder, PG slot or review.
- **Date:** 2026-09-26. **Decision owner:** Bradley Gleave. The executing parent makes D-S10-1 to
  D-S10-8; they follow from the accepted documents and are not owner-reserved (§6 lists what is).
- **Base:** `integration/importer` `771db62aa10dd0065f30d7d8a155d89fd1cfcfc8` (S8-G landed; S9-A
  landed at `9497ca52`). Every `path Lx` citation is at this base unless prefixed `S9B:` (the S9-B
  candidate worktree `worktrees/1910a060-s9b`, not landed).
- **Sources:** "S7L-DOC" `docs/decisions/2026-09-24-s7l-run-lifecycle.md`; "S8-DOC"
  `docs/decisions/2026-09-24-s8-native-contract.md`; "S9-DOC"
  `docs/decisions/2026-09-25-s9-reconciliation.md` (landed, 533 lines); "S9-ADD-A" the candidate
  Addendum A (`S9B:docs/decisions/2026-09-25-s9-reconciliation.md` L535-633), binding only where
  restated here. S9-B and S9-C (reason codes, settle wiring, DTO fields) are not landed
  (`s9c_builder_summary.md` L1-6); S10-C/D bind to them **as landed**, never to a candidate.

## 1. Why this exists

S9 left `complete` unreachable until S10 supplies a per-family basis (S9-DOC L190-192). The seam
is fixed: `CoverageFact {known, basis_kind, observed_unique, covers_staged_identities}`
(`src/scout/reconciliation/types.ts` L207-220), read only by `coverage.ts` L35-82; S9-B passes
`coverage: null` (`S9B:src/scout/reconciliation/facts.service.ts` L478); S10 is the persistence
re-decision trigger (S9-DOC L344-346). Admission and mapping already need no per-source
TypeScript (`src/scout/scout-platform.ts` L1-9; `src/scout/reconstruct/source-mapper-registry.ts`
L16-26, L50-66). The readiness gaps closed here: **G1** no verifiable per-family observation
contract; **G2** no asset entry for native rule JSON (`nest-cli.json` L8-11 vs
`src/scout/reconstruct/native/native-rule-registry.ts` L9-12); **G3** persistence before
`complete`; **G4** no induction gate or synthetic unseen-source proof. A new canonical family,
transformation or native destination is product-family expansion, out of scope.

## 2. Decisions

### D-S10-1 (G1, G2, G4): the induction package and load-time validation

An induction package for one source is exactly three data artifacts keyed by one canonical slug
`<p>` (`isCanonicalPlatform(p)`, never normalised; `scout-platform.ts` L1-9):

| Artifact | Path | Required | Grammar |
| --- | --- | --- | --- |
| Mapping spec | `src/scout/reconstruct/sources/<p>.json` | yes | `SourceMappingSpec` v1, unchanged (`mapping-spec.ts` L114-125, L328-375) |
| Native rules | `src/scout/reconstruct/native/sources/<p>.json` | no | `NativeRuleSet` v1, unchanged (`native-rules.ts` L92-100) |
| Induction manifest | `src/scout/induction/sources/<p>.json` | no | `InductionManifestV1` (below), new |

```ts
interface InductionManifestV1 {
  manifestVersion: 1;
  sourcePlatform: string;              // === <p>, === mapping spec sourcePlatform
  expectedFamilies: CanonicalFamily[]; // sorted, unique, non-empty
  observerVersions: string[];          // [a-z0-9._-]{1,64}, sorted, unique, non-empty
  basisKinds: Record<CanonicalFamily, BasisKind[]>; // keys === expectedFamilies; values ⊆ D-S10-2 minus 'none'
  nativeRules: 'declared' | 'absent';
}
```

- **Declared expected family set** = the mapping spec's `families` keys, which S9 already treats
  as the declaration independent of rows seen (S9-DOC L163-177; `types.ts` L228-235), restated
  as `expectedFamilies` and required equal. `SourceMappingSpec` has strict keys
  (`mapping-spec.ts` L129-130, L337), so no key is added and `mapping-spec.ts` is untouched.
- **Load-time validation (S10-A `parse.ts` and `manifest-registry.ts`; fail closed and loud, like
  `source-mapper-registry.ts` L50-66 and `native-rule-registry.ts` L23-52):**
  V1 strict keys, `manifestVersion === 1`, canonical slug, file named `<sourcePlatform>.json`;
  V2 exactly one mapping spec for the slug and `expectedFamilies` = its `families` keys as a set
  (manifest without spec throws); V3 `nativeRules: 'declared'` ⇔ a rule set for the slug is
  loaded, its families ⊆ `expectedFamilies` (rule set without spec throws); V4 `basisKinds` keys =
  `expectedFamilies`, values unique D-S10-2 kinds other than `none` (an empty list means "never
  provable": always `known: false`); V5 any duplicate manifest, spec or rule set for one slug
  throws naming the file; V6 an absent `src/scout/induction/sources/` directory is an empty
  registry, the truthful "no basis declared" state (precedent `native-rule-registry.ts` L14-24),
  a present-but-empty one throws, and a mapping without a manifest reconstructs as today with
  every family `known: false`.
- **Destinations.** Every canonical family already has a reconstructor (`families.ts` L174-179);
  `workouts` without native rules stays evidence and client-owned rows stay bucket f (S9-DOC L110;
  S8-DOC L72-74). A package cannot declare a destination; a source that fits neither grammar is
  inducted as a truthful `partial`, never with a source branch.
- **G2 packaging.** S10-D D1 adds two generic `nest-cli.json` asset entries,
  `scout/reconstruct/native/sources/*.json` and `scout/induction/sources/*.json` — one-time,
  in the baseline (D-S10-5), never per source.
- **No live source.** S10 ships no manifest for `truecoach`, `conformance_alpha` or
  `conformance_beta` (their families stay `known: false`); its only manifest is the synthetic
  `s10_unseen` (D-S10-5). A real-platform manifest is owner-reserved (§6 Q1).

### D-S10-2: per-run, per-declared-family observation evidence and `basis_kind`

**Closed, append-only vocabulary.** `COMPLETENESS_BASIS_KINDS` (S9-DOC L217-218; S9-ADD-A A.2)
becomes:

| `basis_kind` | Meaning | Extra proof required |
| --- | --- | --- |
| `none` | No basis; ⇔ `known: false` (existing) | none |
| `source_snapshot_enumeration` | One source-issued snapshot or cursor identity held across the whole enumeration of the scope, ending in a source end-of-list marker | `snapshot_ref_digest` non-null, `passes ≥ 1` |
| `verified_page_chain` | No snapshot. A contiguous page chain to a source end-of-list, enumerated twice with identical identity digests (detects mutation during enumeration) | `passes === 2`, both `pass_digests` equal `id_set_digest` |

Appending a kind needs an addendum, an evaluator rule and a negative case; none is removed or
renamed; none names a source. Page counts, a source total, equal counts or a `/complete` `success`
never suffice alone (S9-DOC L186-189, L224-225; PLAN L321 via S9-DOC L26-30).

**Evidence schema.** One object per `(run, source_platform, declared family)`, zero-row families
included. The client supplies:

```ts
interface ObservationEvidenceV1 {
  evidence_version: 1;
  source_platform: string;      // canonical slug
  family: CanonicalFamily;
  observer_version: string;     // ∈ manifest.observerVersions
  mapping_spec_digest: string;  // sha256 hex of the canonical JSON of the loaded spec
  basis_kind: Exclude<BasisKind, 'none'>;
  scope: {
    account_scope_digest: string;  // sha256 hex of the source account/workspace scope; never the raw id
    date_window: null | { from: string; to: string }; // ISO dates; null = unbounded
    exclusions: ExclusionCode[];   // closed: permission_denied | history_inaccessible |
                                   // date_window_limited | archived_excluded | rate_limited
  };
  enumeration: {
    terminal: 'end_of_list' | 'none';
    pages: number;                 // ≥ 1
    unrecovered_errors: number;    // ≥ 0; retried-and-succeeded pages are not errors
    retries: number;               // ≥ 0, informational
    snapshot_ref_digest: string | null;
    passes: 1 | 2;
    pass_digests: string[];        // length === passes
  };
  identities: { observed_unique: number; id_set_digest: string };
  observed_at: string;             // ISO; informational, never used for ordering
}
```

- **Server-bound fields, never client-supplied:** `coach_id` from the bearer, `intent_id`,
  `execution_epoch` read under the run row lock, `received_at` from the server clock and
  `evidence_digest` (sha256 of the canonical JSON of the validated object).
- **Identity digest.** `id_set_digest` = sha256 over the bytewise-sorted distinct `source_id`s,
  each encoded `<utf8-byte-length>:<id>` and concatenated (the length-prefix idea of S8-DOC
  L174-181); the empty set digests the empty string. The server computes it over staged
  `ScoutIngestEntity` rows of `(coach_id, intent_id, source_platform)` whose step resolves to
  `family` (`source-mapper-registry.ts` L101-109); steps union only under a declared
  `sharedIdSpaces` (`mapping-spec.ts` L109-112).
- **Privacy and bounds.** Digests, counts, closed codes and dates only — no source id, name,
  email, label or free text (S9-DOC L398-399). At most 4 families (`scout-reconstruct.dto.ts`
  L13-21) × ≤ 2 KiB; body ≤ 8 KiB.
- **Trust statement.** Evidence uses the same authenticated paired-intent channel as staged rows.
  The server proves consistency, binding and identity equality, not the source's honesty beyond
  that channel. Relying on it for a customer-visible production `complete` is owner-reserved
  (§6 Q2); locally it is the mechanism.

### D-S10-3: the server evaluator (pure; S10-A `verify.ts`)

`evaluateCoverage(input) → Record<CanonicalFamily, CoverageFact>`. It is pure: no I/O, no clock
and no exceptions, like `arbiter.ts` L4-6. Its input is the run binding, the loaded registries,
the stored evidence for the settle epoch, and the server-computed staged digest and unique count
per `(platform, family)`. It dispatches on `basis_kind` only, never on a slug. For each family in
S9's `required_families` (`coverage.ts` L64-71), and for each staged or declared platform
contributing to it, it applies the rules below in order. The first failure gives `{known: false}`.

- **E1 (presence).** Exactly one evidence row for `(coach, intent, epoch, platform, family)`;
  absent → `known: false`, never `observed_unique: 0`.
- **E2 (grammar).** Parses as v1; `basis_kind` in the vocabulary and not `none`.
- **E3 (binding).** Coach, intent and epoch equal the settling run (`lifecycle.service.ts`
  L335-338); a manifest exists; `family ∈ expectedFamilies`; `basis_kind ∈ basisKinds[family]`;
  `observer_version` declared; `mapping_spec_digest` = the loaded spec's digest.
- **E4 (scope).** `exclusions` is empty and `date_window` is `null`; every evidence object of the
  run carries one `account_scope_digest`. Any limit leaves the family unproven (PLAN L29 via
  S9-DOC L26-27).
- **E5 (enumeration).** `terminal === 'end_of_list'` and `unrecovered_errors === 0`, plus the
  kind-specific proof in D-S10-2.
- **E6 (source completeness proven).** E1-E5 hold. The family is `known: true` with
  `basis_kind` and `observed_unique` = the evidence count (a counted source fact, possibly 0).
- **E7 (staged-identity coverage).** `covers_staged_identities` holds iff `id_set_digest` equals
  the server staged digest **and** `observed_unique` equals the staged distinct count.
  Digest equal but counts differ → forged/inconsistent → `known: false`. Digest unequal →
  `known: true, covers_staged_identities: false`; S9 shows the count with
  `completeness_basis: 'none'` and C-COV holds (`coverage.ts` L37-45).
- **E8 (multi-platform family).** The family fact is `known: true` only if every contributing
  platform passes E1-E6. `observed_unique` is the sum (identities are platform-qualified), and
  `covers_staged_identities` is the conjunction.
- **E9 (totality).** Every required family gets a fact; one that cannot be evaluated gets
  `{known: false}`. With no staged platform, `coverage` stays `null` as in v1.

S9 keeps the claim rule (`coverage.ts` L37: a non-`success` claim is never covered) and the empty
and undeterminable rules (L64-66, L78-82). S10 does not duplicate them and does not edit
`coverage.ts` or `reconcile.ts`. Unknown is always `known: false` or `null`, and never 0 (S9-DOC
L288-289; S7L-DOC L208-212).

### D-S10-4 (G3): persistence — two insert-only tables, marked S10-B T4

S9's no-table justification rested on `complete` being unreachable (S9-DOC L329-343); S10 makes
it reachable, firing the re-decision trigger (S9-DOC L344-346). Evidence must also survive,
across instances, from its POST to the `/complete` settle. **Decision: two additive tables, built
only by S10-B as a T4 expand; this document creates neither.**

- **`ScoutRunObservation`** (evidence): `id uuid`, `coach_id`, `intent_id`, `execution_epoch`,
  `source_platform`, `family`, `evidence_version`, `basis_kind`, `evidence jsonb` (the validated
  D-S10-2 object), `evidence_digest char(64)`, `received_at`. Unique `(coach_id, intent_id,
  execution_epoch, source_platform, family)`.
- **`ScoutRunSettledBasis`** (settle-time verdict basis): PK `(coach_id, intent_id)`,
  `execution_epoch`, `report_version`, `report jsonb` (the settle-time `ReconciliationReport`,
  which already carries the coverage fields; S9-DOC L247-289), `observation_digests text[]` (the
  `evidence_digest`s consumed), `settled_at`.
- **Tenant, FK, immutability.** Both have composite FK `(coach_id, intent_id)` →
  `ScoutImport(coach_id, intent_id)` (`prisma/schema.prisma` L6894) `ON DELETE CASCADE`, so a row
  for another coach's intent is unrepresentable and evidence never outlives its run. A `BEFORE
  UPDATE` trigger raises on both; DELETE happens only through the cascade. S10 sets no retention
  period; run-record retention and erasure are L8, owner-reserved (S7L-DOC L257-263; §6 Q3).
- **RLS.** Copy the ImportNativeProvenance set exactly: ENABLE + FORCE RLS, REVOKE from anon and
  authenticated, one service_role policy, RESTRICTIVE deny-all for anon and authenticated
  (`prisma/migrations/20270122000000_scout_native_provenance_expand/migration.sql` L168-182).
  Every read and write filters on the bearer's `coach_id`. The down migration refuses while any
  row exists (S7-L L03 precedent, S7L-DOC L273).
- **Settle write (S10-C).** Inside the S8-G settle transaction, after `writeTerminal` returns true
  (`lifecycle.service.ts` L334-347), so facts, evaluator and CAS share one locked snapshot and
  epoch. CAS miss → nothing written; insert failure → the terminal rolls back. Written for every
  verdict the tail writes, fenced ones included. The `fence` path (L274-298) writes none.
- **Status semantics.** With a settled basis the report and `families[]` come from it, report
  `basis: 'settled'` (one additive literal in the `basis` union of `types.ts`, owned by S10-C).
  Without one (legacy rows, pre-S10 and `fence`-path terminals) S9's recompute-on-read stays,
  `'recomputed'`, byte-identical to S9-C. A stored `complete` never meets a later recomputed
  contradiction; the settled report is the verdict as of `completed_at`.
  `families[].observed_unique` (S7L-DOC L207-212) is filled only from a settled basis.
- **Rejected.** Evidence in `ScoutImportCompletion.final_counts`: it is the claim (S7L-DOC L212),
  open-shaped (`scout.dto.ts` L143-150) and not epoch-bound. Columns on `ScoutImport`: widens the
  hot CAS row and its S7-L CHECKs (`schema.prisma` L6857-6895; `lifecycle.service.ts` L370-384).
  No persistence: violates the re-decision trigger.

**Entry point (S10-B).** `POST /api/scout/runs/observation`, body `{intent_id, observations:
ObservationEvidenceV1[]}`, in new `src/scout/induction/observation.controller.ts` with the
`run.controller.ts` posture: bearer coach is `req.user.id`, R-DARK-1 uniform 404 when
`FEATURE_SCOUT_INGEST` is off, `@Roles('coach','owner')`, same throttle (L22-27, L88-91). The
write runs under `FOR NO KEY UPDATE` on the run row (`lifecycle.service.ts` L357-363), only for
an open `mode='server'` run with no stored claim, binding the current epoch. Refusals reuse
`RUN_CONFLICT_CODES` unedited (`reason-codes.ts` L35-42) plus a closed
`OBSERVATION_CONFLICT_CODES = ['observation_conflict', 'observation_after_claim',
'observation_not_declared']` in `src/scout/induction/contract.ts`. An identical replay is 200 with
no new row; a different digest for an existing key is `observation_conflict`.

### D-S10-5 (G4): CORE DIFF = 0, baseline and the synthetic unseen-source test

- **Baseline B** = the `integration/importer` commit that lands S10-A, S10-B, S10-C (with its
  generator-owner regeneration) and S10-D part 1 (D1: the two `nest-cli.json` asset entries and
  `scripts/s10-core-diff-gate.sh`). B is **not** `771db62a`; the one-time generic S10 code is
  excluded from the per-source comparison by being in B, not by being hidden.
- **Per-source data allowed to differ (only these):** `src/scout/reconstruct/sources/<p>.json`,
  `src/scout/reconstruct/native/sources/<p>.json`, `src/scout/induction/sources/<p>.json`,
  `test/fixtures/scout/<p>/**`, `test/scout/s10/**`.
- **Core path set (byte-identical to B):** every other path under `src/`, plus `prisma/**`,
  `scripts/**`, `docs/contracts/**`, `nest-cli.json`, `package.json`, `package-lock.json` —
  by name including `src/scout/scout-platform.ts`,
  `src/scout/reconstruct/{mapping-spec,source-mapper-registry,families}.ts`,
  `src/scout/reconstruct/native/*.ts`, `src/scout/lifecycle/**`, `src/scout/reconciliation/**`,
  `src/scout/induction/*.ts`, `src/scout/*.dto.ts`, `src/scout/scout.module.ts`.
- **Gate (D2, parent-run), all must hold:** (1) `git diff --name-only B..HEAD` ⊆ allowed paths;
  (2) `git diff --exit-code B HEAD -- src prisma scripts docs/contracts nest-cli.json package.json
  package-lock.json ':!src/scout/reconstruct/sources/<p>.json'
  ':!src/scout/reconstruct/native/sources/<p>.json' ':!src/scout/induction/sources/<p>.json'`;
  (3) `rg -F -c '<p>' src --type ts` = 0; (4) `RUN_REASON_CODES`, `COMPLETENESS_BASIS_KINDS`,
  `OBSERVATION_CONFLICT_CODES` and `docs/contracts/importer-openapi.json` unchanged.
- **Synthetic unseen source `s10_unseen`**, absent from B's `src/` (`rg -F s10_unseen src` = 0).
  D2 adds the three artifacts only; the spec declares `clients`, `programs`, `workouts` (two steps
  into `workouts` under `sharedIdSpaces`), not `client_history`. Registration is dispatch, not
  authorization (`source-mapper-registry.ts` L84-86; precedent `conformance_alpha.json`). Real-PG
  end-to-end: staging → S8-G pass → native/evidence → observation POST → evaluator → S9 verdict
  → settled basis → status, with synthetic identities and snapshots only.

### D-S10-6: invariants (asserted by S10 specs; S7-L, S8 and S9 invariants unchanged)

1. **No false Complete.** S9's full predicate (no C-FAM/C-ID/C-REL, claim `success`; S9-DOC
   L147-161) **and** a `known: true`, `covers_staged_identities` fact (E6-E8) for every required
   family; an empty or undeterminable set is never vacuous (S9-DOC L182-184).
2. **Unknown is never zero.** Absent, invalid or unproven → `known: false` or `coverage: null`,
   `observed_unique: null`; `0` is only a counted, proven observation.
3. **No duplicate native identity.** Ledger identity (`schema.prisma` L6996) and provenance key
   (L7023) unchanged; id spaces merge only via declared `sharedIdSpaces`; S10 adds no writer.
4. **No cross-tenant reads or writes.** Evidence and basis rows are keyed and FK-bound by the
   bearer's `coach_id`; the staged digest reads only the run's own coach/intent rows.
5. **No customer-facing side effects in historical reconstruction.** S8 create-only and §3.6
   suppression unchanged (S8-DOC L104-112, L223-242); the induction module imports no
   notifications, drip, email, messaging, workout-builder, AI or billing module (R38).
6. **The S9 arbiter stays the sole terminal writer.** Precedence unchanged (`arbiter.ts`
   L64-88); one CAS terminal write (`lifecycle.service.ts` L370-384); S10 writes no
   `terminal_status`, `reason_code` or `completed_at`; the basis row is a record after the CAS in
   the same transaction, never a second verdict.
7. **Evidence is immutable and epoch-bound;** another epoch's, intent's or coach's is inert.

### D-S10-7: slices, owned paths, tiers and dependencies (one writer per path)

Tiers: T0 decision only; T1 pure data and parser; T2 synthetic composition; T3 API and packaging
contract; T4 terminal truth, schema, tenant and real PG, with independent review.

| Slice | Tier | Owned paths | Depends on | Not owned |
| --- | --- | --- | --- | --- |
| S10-0 | T0 | `docs/decisions/2026-09-26-s10-induction.md` | none | any code |
| S10-A | T1/T2 | `src/scout/induction/{contract,parse,digest,verify,manifest-registry}.ts`; `test/scout/induction/{contract,parse,digest,verify,manifest-registry}.spec.ts`; `test/fixtures/scout/s10_pure/**` (in-memory and temp-dir fixtures) | **may start now.** It imports only landed types (`types.ts` L207-243; `mapping-spec.ts` L63-69, L114-125; `native-rules.ts` L92-100; `reason-codes.ts` L35-42) | routes, `prisma/**`, `lifecycle/**`, `reconciliation/**`, `src/**/sources/*.json`, `nest-cli.json` |
| S10-B | T3/T4 | `src/scout/induction/{observation.service,observation.controller,observation.dto,observation.module}.ts`; `prisma/schema.prisma` (two additive models only); `prisma/migrations/<ts>_scout_run_observation_expand/{migration,down}.sql`; `test/scout/induction/observation.{service,controller}.spec.ts`; `test/rls-g2-s10b.spec.ts`; `test/utils/g2-s10b-*` | S10-A landed. The PG proof runs only in the canonical slot. It merges after S9-C lands | `scout.module.ts` registration, the settle path, OpenAPI bytes |
| S10-C | T4 | `S9B:src/scout/reconciliation/facts.service.ts` as landed (the coverage fetch and evaluator call replace `coverage: null`); `src/scout/lifecycle/lifecycle.service.ts` (the settled-basis insert after `writeTerminal`; `readReport` prefers the settled basis); `src/scout/reconciliation/types.ts` (the `'settled'` basis literal only); `src/scout/scout.module.ts` (the ObservationModule import only); added cases in `test/scout/{reconciliation,lifecycle,induction}/**`; `test/rls-g2-s10c.spec.ts`. Gen in the same change via the **generator owner only** (`scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, `test/contracts/importer-contract.spec.ts`), because registering the route makes the byte-compared artifact stale | **after S9-B and S9-C land** (S9-C owns these hunks until then; `s9c_builder_summary.md` L31-36, L64-72), plus S10-A and S10-B | `reconcile.ts`, `coverage.ts`, `arbiter.ts`, `reason-codes.ts` |
| S10-D | D1 T3; D2 T2/T4 | D1: `nest-cli.json` (two asset entries), `scripts/s10-core-diff-gate.sh`. D2: `src/scout/reconstruct/sources/s10_unseen.json`, `src/scout/reconstruct/native/sources/s10_unseen.json`, `src/scout/induction/sources/s10_unseen.json`, `test/scout/s10/**` | D1 after S10-C; B = D1 landed. D2 after B | every core path in D-S10-5 |

S10-A/B are disjoint from S9-C's 18 paths (`s9c_builder_summary.md` L10-29); S10-C takes S9-C's
files only after they land (sequential ownership). S10-A freezes to this text once it lands.

### D-S10-8: what stays generic and closed

S10 adds no run reason code (an unproven run stays `partial/coverage_basis_unknown`, S9-DOC
L362-366) and no report catalogue key (S9-DOC L381-400); evaluator failures show only as
`completeness_basis: 'none'` with `observed_unique` a count or `null`. No source-name literal
enters `src/**/*.ts` in any S10 slice; `src/scout/induction/sources/*.json` is data.

## 3. Acceptance cases (fixed; numbering continues S9's R01-R19)

Tiers: "A" pure S10-A spec; "B" S10-B real-PG proof; "C" S10-C composed settle/status on PG;
"D" S10-D synthetic end-to-end and gate. No accepted suite is rerun; S9 R01-R19 still pass.

- **R20 (A)** A valid synthetic package loads. One throwing case each for V1-V5: bad key/version;
  filename ≠ slug; `expectedFamilies` ≠ spec `families`; manifest without spec; `declared` without
  rule set or rule family outside `expectedFamilies`; `none`/unknown kind in `basisKinds`;
  duplicate slug. Absent directory → empty registry; present-but-empty directory throws (V6).
- **R21 (A)** Evidence grammar rejects: unknown key/version; non-hex or wrong-length digest;
  negative/non-integer count; `pass_digests.length ≠ passes`; unknown exclusion; body > 8 KiB.
- **R22 (A)** Snapshot kind, `end_of_list`, no errors/exclusions, digest and count equal to staged
  → `{known: true, basis_kind: 'source_snapshot_enumeration', observed_unique: n,
  covers_staged_identities: true}`.
- **R23 (A)** Digest ≠ staged → `known: true, covers_staged_identities: false`; through S9-A →
  `partial/coverage_basis_unknown` with `observed_unique` shown.
- **R24 (A)** Each alone → `known: false`, report `observed_unique: null` (never 0): no evidence;
  an exclusion or non-null `date_window`; mixed `account_scope_digest`s; `terminal: 'none'`;
  `unrecovered_errors > 0`; snapshot kind without `snapshot_ref_digest`; page-chain kind with
  `passes = 1` or unequal `pass_digests`; spec-digest mismatch; undeclared observer; no manifest;
  undeclared family; kind not in `basisKinds[family]`. **R25 (A)** digest equal, count unequal.
- **R26 (A)** Declared family, zero staged rows: evidence with `observed_unique: 0` and the
  empty-set digest → known and covered; no evidence → `known: false` →
  `partial/coverage_basis_unknown` (S9-DOC L174-176).
- **R27 (A)** Evidence bound to another coach, intent or epoch is inert; a two-platform family is
  known only when both pass (E8). **R28 (A)** Metamorphic: a renamed slug gives identical facts;
  no slug literal in `src/scout/induction/*.ts`.
- **R29 (B)** Route: accepted before the claim; identical replay → 200, no new row; different
  digest → 409 `observation_conflict`; after claim → `observation_after_claim`; fenced →
  `run_fenced`; terminal → `run_terminal`; legacy → `legacy_run`; no manifest →
  `observation_not_declared`; another coach's intent or flag off → uniform 404. **R30 (B)** The
  stored epoch is the one read under the lock; a settle at e' ≠ e ignores the row.
- **R31 (B)** Both tables: anon/authenticated refused; service_role rollback persists nothing;
  coach B cannot read or write A's rows and the FK refuses A's intent under B's `coach_id`;
  UPDATE refused by trigger; down refuses with any row present; policy and unique catalog
  exactness.
- **R32 (B)** An observation POST racing `/complete` serialises on the row lock: it commits before
  the claim (used) or is refused `observation_after_claim`; never partial, never 40P01.
- **R33 (C)** Native-clean run, every required family known and covered, claim `success` →
  `complete`, `reason_code` null, exactly one terminal write and one `ScoutRunSettledBasis` row in
  the same transaction with basis `'settled'`.
- **R34 (C)** Full coverage plus any of C-FAM/C-ID/C-REL → that S9 code, never `complete`; claim
  `partial`/`failed` with staged rows → `coverage_basis_unknown`; a fence wins (S9 R09).
- **R35 (C)** After R33, archive a native row and replay the identity in a later intent: status
  still `complete`, settled report byte-identical to settle time; no recompute for this run.
- **R36 (C)** CAS miss, or an injected basis-insert failure → no terminal from this tail and no
  basis row; the run is left for the lazy deadline as in S8-G.
- **R37 (C)** Legacy rows and pre-S10 server terminals project exactly as under S9-C with
  `'recomputed'` (S9 R13, R15); the 64 KiB body bound holds with `observed_unique` filled.
- **R38 (C)** Notification, drip, email and messaging spies record zero calls across import,
  replay and observation POSTs.
- **R39 (D)** `s10_unseen` on real PG: (a) all declared families observed → `complete`; (b)
  `nativeRules: 'absent'` variant → workouts evidence-only → `partial/unresolved_identities`; (c)
  client-linked row → bucket f → `partial`; (d) staged undeclared `client_history` →
  `unresolved_family`; (e) one declared family unobserved → `coverage_basis_unknown`.
- **R40 (D)** The D-S10-5 gate passes on D2 against B; a planted slug literal in a core file makes
  it fail (negative control on a scratch branch, never landed).
- **R41 (D)** Replaying an intent creates no second native row and provenance stays unique; two
  steps into one family without `sharedIdSpaces` fail at load, not at run time.

## 4. Owner-reserved boundary (S10 needs none; none decided here)

Per `private-evidence/execution/daceddc8/SCOPE.md` L5: live source-account login, extraction or
customer-account writes (S10 uses synthetic, disposable snapshots and identities only);
production deployment, `FEATURE_SCOUT_*` flag or customer enablement, destructive production
mutation; `integration/importer` → `main` (PR #530); extension approval/publishing (PR #27, #30)
and the Chrome Web Store (the extension is read-only interface context, not operated); S8-D/S8-E
client-principal policy (D-S8-2, S8-DOC L84-89) and G3-AUTH (S8-DOC L96-101;
`source_namespace = source_platform` stays); security governance and branch protection.

## 5. What is NOT decided (deferred, not owner-reserved unless §6)

Real-platform observation capability (unknown and stays unknown); per-family "why unknown"
diagnostic codes; current-native-drift display beside a settled verdict; a third basis kind (for
example a source-signed export manifest); N3-FILL intent attribution and the created/already-
present split (S9-DOC L227-239); canonical-family expansion; value-drift fingerprints (S9-D);
coach-facing copy (UX-05); a `CONTRACT_VERSION` bump (treated as additive per the S8-F
precedent, `s9c_builder_summary.md` L72; generator owner confirms).

## 6. Questions believed genuinely owner-reserved (recorded, not decided)

- **Q1.** Whether/when any real platform gets a manifest and basis kind (needs live accounts).
- **Q2.** Whether extension-attested, server-verified evidence (D-S10-2 trust statement) may back a
  customer-visible `complete` in production, or a server-side/source-signed basis is required first.
- **Q3.** L8 retention period and erasure semantics for `ScoutRunObservation` and
  `ScoutRunSettledBasis`; S10 fixes only "cascade with the run row" (S7L-DOC L257-263).
- **Q4.** Any extension change to emit `ObservationEvidenceV1` (PR #27, #30, CWS).
- **Q5.** D-S8-2 end state and G3-AUTH; until then client-owned families block `complete`.

## 7. Release boundary

A local contract for S10-A to S10-D; passing R20-R41 proves local candidate behaviour only.
Builder grants, the PG slot and reviews are separate parent decisions; deployment, customer
acceptance, flags and any `main` merge stay owner-reserved (S7L-DOC L284-286).
