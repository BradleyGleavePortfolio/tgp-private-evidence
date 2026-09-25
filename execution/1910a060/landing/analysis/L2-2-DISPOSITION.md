# L2-2 suite-selection disposition (LAND-PREP-1910, read-only, 2026-09-25 ~21:25Z)

Tool: `select_suites.py` (this dir). It emulates `jest.config.js` discovery (13 roots, `\.spec\.ts$`, ignores
`/node_modules/`, `/dist/`, `test/rls/`, `test/rls-*.spec.ts`). It selects a spec when its static relative-import
closure contains bytes from both sides, or when a file in its closure calls a fs/git reader API and its string literals
name a changed path or a directory prefix of one. That is the L2-2 repo-reader lesson from daceddc8/landing/PLAN.md. The
selection is conservative on purpose, so every hit below was dispositioned by reading the spec.

## Case A: S8-F e1ec2fec onto integration 1c5fbb04 (the recipe's case)

- Side X is the 17 S8-F paths (`side-s8f-paths.txt`). Side Y is the 1 S9-0 path (`side-s9-0-paths.txt`, `docs/decisions/2026-09-25-s9-reconciliation.md`).
- Raw output is in `selection-s8f-onto-1c5fbb04.txt`. It covers 585 default-config specs and flags 1 hit: `test/ci/delivery-artifact.spec.ts`.
- **That hit is a false positive.** Its `read()` targets are `.github/workflows/*.yml`, `scripts/setup-branch-protection.sh`,
  `scripts/ci/release-evidence-gate.sh`, `Dockerfile` and `.dockerignore`. Its git and release checks run in temp repos
  under `mkdtemp`. The literal `docs` is an expected `.dockerignore` entry, and the spec never reads `docs/`. It is
  also in the S8-F gated 33 and was green in PR #541 CI on the doc tree.
- Other checks came back empty:
  - No spec, helper or fixture reads `docs/decisions/**`.
  - Nothing walks `docs/` or enumerates `*.md` from the repo root.
  - The root-doc readers read only their named files: `route-doc-drift` reads `docs/deploy-runbook.md` and `docs/stripe-setup.md`, and the operator-keys specs read `OPERATOR_KEYS_NEEDED.md`.
  - The old `FS_PINNED_SPEC_RE` (`prisma/migrations|['"/]migrations['"]|docs/contracts|importer-openapi|EXPECTED_MIGRATIONS|BASE_HEAD`) is unaffected. Case A changes no migration, contract or pin.
- **Result: 0 composition-affected suites.** No local Jest run is needed.
- **No contract regeneration.** The generator's inputs (`src/**` DTOs and generator scripts) are byte-identical between the S8-F-gated tree `2fe0201f` and the predicted tree `23614f0b`, and the contract blob is `8ebf936a` in both.
- **No Migration Dry-Run is triggered**, because no path under `prisma/` changes.
- **CI runs once**, as the full `npm test` on the PR head. It is the whole-graph check.

## Case B (contingency only): S8-F composed onto a landed S9-A head

S9-A is not committed yet. The prediction overlays the four frozen pre-format files from `s9a/freeze/` on `23614f0b`,
at the paths they will have.

- Side Y is `side-s9a-paths.txt`.
- The conservative raw output (`selection-s8f-onto-s9a-preformat.txt`) flags 41 hits. Most of them match only because the literals `'src'` or `'test'` appear in the file.
- No import closure spans both sides.
  - `reconcile.spec.ts` imports `src/scout/reconciliation/*` and `src/scout/lifecycle/{arbiter,reason-codes}`. S8-F does not change any of these.
  - No S8-F file imports reconciliation.
- A spec genuinely spans both sides when it recursively walks `src/`. Such a walker reads the new
  `src/scout/reconciliation/*.ts` and the S8-F-changed `src/scout/scout-{entities,roster}.*.ts`. After reading each
  hit, the narrowed must-run set is:

```
test/deploy-readiness.spec.ts
test/prod-readiness/stub-scanner.spec.ts
test/prod-readiness/env-discovery.spec.ts
test/prod-readiness/provider-wiring-stripe-mux-sendgrid.spec.ts
test/prod-readiness/provider-wiring-twilio-aws-fly-sentry-supabase-openai-cf.spec.ts
test/prod-readiness/operator-keys-artifact.spec.ts
test/prod-readiness/operator-keys-generator.spec.ts
test/route-doc-drift.spec.ts
test/scout/reconstruct/mapping-spec.third-source.spec.ts
test/dunning-v2-lockout-allowlist-route-table.spec.ts
```

- `dunning-v2-lockout-allowlist-route-table` walks `src/` for controllers. S9-A adds no controller, so it is included only to stay conservative.
- The remaining conservative hits were excluded:
  - Named-file readers that do not walk `src/`, such as `ai-credits-stream1`, which reads only `src/ai-credits`.
  - Specs that match only on the `'test'` literal. These include the `r75-*` and `r100-pathspec` temp-repo checks, the community DB helper, `mapping-spec.spec`, which reads `src/scout/reconstruct` specs, and `native-families`, which reads the native dir.
- Whole-project type interaction is covered by the genuine pre-commit `tsc --noEmit`.
- **Status: prediction only.** It must be recomputed on the real committed S9-A head with `land-s8f-1910.sh classify e1ec2fec…` before any grant. The recipe does not compose Case B (see RECIPE.md §7).
- The same set applies in reverse, if S8-F lands first and S9-A must then be composed onto the S8-F merge.
