# R prep — acknowledgement of frozen parent decisions

Worker `r_slice_source_only_preparation_mufnlmx0`, 2026-09-24 15:30Z. Read `execution/cf8ff737/R_IMPLEMENTATION_DECISIONS_PENDING_B_ACCEPTANCE.md`. R remains NOT activated; no worktree, copy, generation, runtime or source write started. Brief `R_SLICE_BRIEF.md` retained unchanged as historical preparation; the following amendments govern the later build:

- **D1** keep `String?` at R; both wide `@@unique` added, both narrow retained; record the temporary schema-parity qualification (one informational `DROP NOT NULL` drift), no equivalence claim.
- **D2** minimal DTO validation with `isCanonicalPlatform` as the semantic authority. Build must prove parity, not assume a regex: cover empty string, length 257, leading `-`/`.`/`:`/`_`, uppercase, whitespace, `\u0000`, and trailing `\n`/`\r\n` (JS `$` without `m` and PostgreSQL ARE `$` both reject a trailing line terminator, but the spec asserts it rather than relying on that). Prefer validating through the existing function (custom class-validator decorator or `@Matches` proven equivalent by a table test against `isCanonicalPlatform`) with a field-level message. Inspect `scripts/export-importer-contract.ts` first; regenerate the exported contract only if the generator actually encodes the input rule.
- **D3** fence retained; R guard copies the **corrected v5 cardinality predicate** for fence identity, not the blob `91e646dd` text cited in the brief (historical, failed `75a2863b` lineage).
- **D4** base = accepted B v5 head only; migration id `20270120000000_scout_identity_ready` subject to order/collision check on that base.
- **Environment:** R dependencies as an independent physical copy of B's verified tree (no hard links); generate only R's client; record new `index.d.ts` hash and unchanged engine provenance; reuse verified formatter/PG binaries.
- **Assurance:** R01–R12 behaviors (not a count quota), DB-free guard, DTO validation behavior, genuine hooks/gates, two independent exact-head T4 reviews. Local PG17 proof and CI PG15 dry-run are distinct; no CI or push claim without an actual run.

Awaiting requeue as sole R builder with exact head and path grant. No further prep output.
