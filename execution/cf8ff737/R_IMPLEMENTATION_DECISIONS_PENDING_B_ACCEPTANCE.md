# R implementation decisions, pending B acceptance

Parent EXEC-CF8FF737. This freezes routine technical choices from `r-prep/R_SLICE_BRIEF.md`; **it is not an activation or runtime grant**. No R worktree, source write, dependency copy/generation or proof begins before parent records B's exact final acceptance.

## Frozen choices

- **D1, transitional Prisma declaration:** Keep ledger `source_platform String?` at R while the database becomes NOT NULL. Add both named wide unique declarations and retain both narrow declarations. The accepted T writer and its null-claim branch stay unchanged until N. Record the temporary schema-parity qualification explicitly; do not claim schema equivalence or use this as permission for a schema push.
- **D2, input truthfulness:** Include the minimal DTO validation and its existing validation-spec coverage so noncanonical source platforms are rejected at the API boundary, not surfaced as a database 500 after R's staging CHECK. `isCanonicalPlatform` is the semantic authority. Ensure exact acceptance parity, including malformed input and trailing line terminators; a superficially similar regex is not itself proof. Use existing validation infrastructure and field-level errors, not a new subsystem. Any exported contract change is conditional on the existing generator actually encoding the changed input rule; inspect before requesting necessary generation.
- **D3, retain B fence:** Leave the accepted B fence intact. R adds required canonical identity and wide uniqueness, while narrow keys continue to arbitrate. No N/Q1/C semantics or cleanup travel with R.
- **D4, accepted base only:** Use the eventually accepted B v5 head, not failed `75a2863b`, and copy the corrected cardinality predicate where the R guard reuses fence identity. Old blob references in the preparation brief are historical and do not authorize reintroducing the defect.

Proposed migration identifier remains `20270120000000_scout_identity_ready`, subject only to checking collision/order on the actual accepted base.

## Environment and assurance for the later activation

R will have its own isolated worktree and sole writer. Reuse B dependencies through an independent physical copy, **not shared mutable hard links**, because R's own Prisma generation changes generated files. No reinstall or graph change is presently needed. Reuse verified external formatter and PG binaries; generate only the R client required by its changed schema, recording its new hash and unchanged engine provenance.

Acceptance remains the bounded R01–R12 behaviors in the brief, existing DB-free guard coverage, the necessary input-validation behavior, genuine affected hooks/gates and two independent exact-head T4 reviews. Do not turn the enumerated behavior groups into a test-count quota. Existing E/T/B/C1 proof transfers at unchanged boundaries; R proves the new transition and compatibility.

CI migration dry-run on its configured PostgreSQL version and local PG17 proof are distinct. Remote product push/merge is reserved and no CI result is claimed without an actual run. The later activation must state which local boundary is achievable before that reserved action, rather than blocking routine local implementation or pretending local PG17 is PG15 CI.

No new spending, production data, deployment, customer enablement, security/governance mandate change or product-scope expansion is approved here.
