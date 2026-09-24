# v2 freeze — format-only delta over v1

Grant: parent format-only slot (2026-09-24 ~07:10 UTC). Tool: existing approved external Prettier 3.9.6
`execution/e7d2385c/s5-continuation/tooling/prettier-3.9.6/node_modules/prettier/bin/prettier.cjs`,
sha256 verified `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e` before use.
Config: repo `.prettierrc` (singleQuote, trailingComma all, printWidth 100). Each invocation ran under
`flock -n execution/test-validation.lock` (acquired, released on exit). No install, no SQL formatting,
no tests/build/commit, no product semantic change.

| File | v1 blob | v2 blob | Delta |
|---|---|---|---|
| prisma/.../migration.sql | 55c85906… | 55c85906… | none (out of scope) |
| prisma/.../down.sql | 8c6710e7… | 8c6710e7… | none (out of scope) |
| src/scout/scout-ledger-backfill.ts | 8493f278… | 8493f278… | none (already conformant) |
| src/scout/scout-ledger-backfill.cli.ts | bcc06577… | bcc06577… | none (already conformant) |
| src/scout/scout-ledger-backfill.spec.ts | e64d8263… | e64d8263… | none (already conformant) |
| test/rls-g2-b-drain.spec.ts | beedb55e… | c970ab29… | 38 changed lines, line breaks only (`format-only.rls-g2-b-drain.spec.ts.diff`) |
| test/utils/g2-b-drain-harness.ts | 668427f7… | 09c677fa… | 8 changed lines, line breaks only (`format-only.g2-b-drain-harness.ts.diff`) |

Equivalence check: whitespace-stripped token streams (with Prettier's trailing commas normalised)
are identical for both reflowed files. `prettier --check` on all five TS files: pass.

Staged tree v1 `be80087c154ffca0d1d82713892913883c819d9a` → v2 `3739193a5badb104a0aa880a5242ff21e2a98fb0`
(temp index, no commit). Base unchanged: `a0ea1bea…` / tree `87798e74…`. Working tree: 7 untracked paths, index clean.
**v2 is the review candidate for the two independent T4 source reviews.**
