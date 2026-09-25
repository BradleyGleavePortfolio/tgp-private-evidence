
## Addendum A (S9-B, 2026-09-25): review closures and facts-collection rules

Recorded by the S9-B lane (EXEC-1910A060) against the landed text at `1c5fbb04`. Nothing above
this heading changes; each item names the line it amends. Sources: `S9_0_REVIEW.md` §8 RC-1..RC-3
and §6 C-5..C-10 (deferred to "the doc's next opening"); `S9_A_SOURCE_READY.md` deviations 2, 3
and 5; `S9_A_REVIEW_A.md` B-2.

### A.1 S9-0 review closures

- **RC-1 (D-S9-7 meaning of `coverage_basis_unknown`).** The meaning cell also covers the two
  D-S9-2 triggers where `required_families` is `null` (undeterminable: zero staged rows, or a
  staged platform without a registered spec) or empty. D-S9-2 stays the binding definition.
- **RC-2 (D-S9-5 "pre-S9 terminals").** "Pre-S9 terminals" excludes only
  `reason_code = reconciliation_not_performed`. A `mode='server'` run fenced before S9-C landed
  (`cancelled`, `timed_out`) therefore receives a recomputed report on read. That is a truthful
  account under an unchanged terminal; it is stated here so nobody reads it as a gap.
- **RC-3 (D-S9-2 declared families).** Own paragraph, moved out of the "cannot be determined"
  bullet: _A declared family with no staged row gets a report entry with `staged_unique: 0`
  (`mapped: true`, no tokens). It still needs a known basis before `complete`. Such report-only
  entries never create a `families[]` projection entry, because there is no staged token for
  them._
- **C-5 (E-R2 notation, L140).** Read `#ord:<ordinal>`: the child's `order` equals the ordinal
  (the 0-based source position, S8-DOC L178), not the length prefix `n` of S8-DOC L176-178. When
  source ordinals are not positions this yields a false `unverified` (safe direction). For the
  `#id:<identifier>` form only existence and `workout_plan_id` are compared.
- **C-6 (qualifier domains).** `unresolved_family:<token>` carries the staged token, which ingest
  accepts as any 1-128 character string; the token already projects as `families[].family`
  under the accepted S7-L contract, so no new exposure exists, but R14's PII guarantee does not
  extend to tokens. The accepted S9-A parser recognises reason codes by their catalogue prefix
  and does not validate qualifier domains; validating the qualifier against the spec's family,
  field and model names before anything reaches a DTO is an S9-C obligation, recorded here, not
  a property of the landed reconciler.
- **C-7, second half (`qualifiers` enum).** `qualifiers[]` is a closed OpenAPI enum
  (`roster_bridge_pending` only in v1; append-only), never `string[]`. The 32-family R15 fixture
  and the CONSUMER_FREEZE L78 note stand as recorded in §3.
- **C-9 (recompute-on-read).** The S9-B facts service opens no transaction and issues only
  reads; the caller supplies one `Prisma.TransactionClient` and is responsible for running it
  at `REPEATABLE READ` so classification sees one snapshot across staging, ledger, provenance
  and native tables. On the settle path that transaction is S8-G's (which also writes the
  terminal); on the status path S9-C opens one for the read. S9-C adds a spec that asserts
  S9-A's copy of the §3.7 catalogue equals S8-C's runtime `UNRESOLVED_CODE`.
- **C-10 (wording).** `relationship_closure: 'not_applicable'` means "no bucket-j identity of the
  family carries a declared edge" (see A.2 deviation 5), never "not checked". R12's "`null` only
  for D-S9-3/D-S9-4 fields" also lists `media_policy`, `pagination_terminal_evidence` and
  `date_window`. A token that resolves to different families across platforms in one intent
  projects one `families[]` entry whose counts are the sum over all of that token's rows;
  `canonical_family` is `null` unless every row resolves to the same family.

### A.2 S9-A deviations accepted into the text

- **Deviation 2 (D-S9-3).** `CoverageFact.known: true` carries `basis_kind: string` and
  `completeness_basis` is that string (`'none'` ⇔ `known: false`). `COMPLETENESS_BASIS_KINDS` is
  S10's append-only enum; v1 has only `none` because `coverage` is `null`.
- **Deviation 3 (D-S9-3).** `observed_unique: number | null` — a number whenever a `CoverageFact`
  carries one, `null` when there is no fact. v1 is always `null`.
- **Deviation 5 (D-S9-2 L145).** Edges from identities outside bucket j are ignored, never
  double-counted; `not_applicable` is emitted when no bucket-j identity of the family carries a
  declared edge.

### A.3 B-2: one edge per declared relationship (facts-collection rule)

For every staged identity whose canonical family declares E-R1, E-R2 or E-R3, S9-B emits exactly
one `RelationshipFacts` edge per declared relationship instance. When the parent cannot be
resolved through provenance or native rows, the edge is still emitted, with the parent's own
identity as `to_identity` (unresolvable to S9-A because it is not bucket j) and
`consistent: false`, so that it fails closure. Concretely:

- **E-R1** is declared iff the accepted S8-A/S8-C interpreter (read-only, `mode: 'native'`)
  derives a `programSourceId` for the staged `workouts` row; the edge targets the `programs`
  identity `(source_platform, programSourceId)` whether or not that identity was staged, and is
  `consistent` only when the run's own unarchived plan has `program_id` equal to the parent's
  verified native id and `(week_index, day_index)` equal to the interpreter's derivation.
- **E-R2** emits one edge per created or already-present child provenance row under a `workouts`
  parent (`from_identity = to_identity =` the parent), `consistent` iff the exercise row exists
  unarchived on the parent's plan and, for `#ord:<ordinal>`, `order` equals the ordinal.
- **E-R3** emits one edge per staged identity with an interpreted `clientSourceId` (families other
  than `clients`), `consistent: null`; S9-A closes it only against a bucket-j `clients` identity.

### A.4 S9-B facts rules the text left implicit

- **Grouping.** `resolveStagedFamily` first; a token equal to a canonical family the platform's
  spec declares maps to that family (S8-C `dispatch` precedent). Anything else is an unmapped
  entry keyed by the raw token. `resolution_reason` prefers `unresolved_family:<token>` over
  `unsupported_platform:<platform>` when both occur for the same token.
- **Ledger without staged (R05).** Counted run-wide over `(entity_type, source_platform,
  source_id)`; attributed to the mapped entry the pair resolves to (creating a zero-identity mapped
  entry when necessary); never dropped when it resolves to nothing.
- **Native existence.** Looked up by id without a coach filter, then compared: missing or archived
  → `removed`; another coach → `foreign_owner`; provenance kind ≠ ledger kind → `kind_mismatch`;
  provenance id ≠ ledger target → `provenance_mismatch`. `Person` has no `archived_at`; a row
  that exists is present. No fabricated zero: an identity with no ledger row has `ledger: null`.
- **Coverage and split.** `coverage` is `null` in v1 (D-S9-3); the created/already-present split
  is unknown (D-S9-4); the report is never persisted (D-S9-5, no table).
- **Provenance read.** Coach-wide by `(coach_id, source_namespace ∈ staged platforms, entity_type
  ∈ mapped families ∪ {'workouts.exercise'})`; children attach to parents through the S8-DOC
  L174-181 length-prefixed `source_id`.
- **Claim.** `ScoutImportCompletion.terminal_status` filtered to `success | partial | failed`; any
  other value is `null`.
