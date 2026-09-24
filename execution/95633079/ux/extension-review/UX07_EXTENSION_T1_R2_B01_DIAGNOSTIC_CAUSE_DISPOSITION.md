# UX-07 extension presentation — B-01 diagnostic cause disposition

**Scope:** additive actual-result analysis only. No source re-audit, execution, test, runtime, install, fixer, dependency change, or configuration change was performed by this reviewer.

**Candidate remains unchanged:** base `0111be661922234d670bbf23e23d270eec1b4a4e`; R2 tree `3750a2ea9f6e57b7de96c0102aab66d761776189`; pair blob `01f6839b0b7657520167556fc9ae71c56ea80474`; popup blob `f003a81804d15e5fc34fefbeaab228f371a14a7d`.

## Actual diagnostic result

The retained `npm run type-check` diagnostic exited `2` before the second configured project could run. Every reported error is in:

```text
/home/user/node_modules/string_decoder/lib/string_decoder.js
```

The diagnostics are duplicate identifiers and inferred-instance-property errors in that external package's legacy JavaScript. The diagnostic contains no path in the candidate's tracked extension source, tests, scripts, or configuration.

## Cause classification

**B-01 remains proof-invalidating only.** The evidence identifies an **unlocked ancestor-environment JavaScript package being inferred by TypeScript**, not R2 product code and not a dependency locked by this extension repository:

- The extension lockfile has no `string_decoder` entry, and the extension's own `node_modules` has no `string_decoder` package.
- The failing package is an ancestor installation at `/home/user/node_modules/string_decoder`, version `1.1.1`, outside the candidate checkout and its committed lockfile.
- Neither tracked source nor the R2 delta imports `string_decoder`.
- The active TypeScript setup includes Node declarations (explicitly in `jsconfig.scripts.json`, and available to the primary configuration). Installed `@types/node` declares `process.getBuiltinModule` entries through `typeof import("string_decoder")`; NodeNext resolution can therefore discover the ancestor package and infer its JavaScript despite `exclude: ["node_modules"]`. Exclude controls root-file selection, not an imported/resolved module outside the checkout.
- R2 changes only popup CSS; its JavaScript, TypeScript configurations, hook configuration/checker, package manifest, and lockfile are identical to the stated base.

This is not a candidate product-code error. It is also not grounds to mark the semantic check passed: the existing genuine check correctly failed closed when its compiler was contaminated by an external package.

## Minimum affected-proof closure

**No source, hook, tsconfig, import, or dependency delta is presently justified.** The immediate closure is one clean-ancestry execution of the existing unchanged command:

```text
npm ci
npm run type-check
```

Run it on the exact R2 tree in an environment whose module-resolution ancestry does not expose the unrelated `/home/user/node_modules/string_decoder` package (or an equivalent isolated executor), and retain the raw output/status. This is a replacement proof for B-01 only; it does not repeat the passed 2-file/9-test result or request a full gates rerun.

If that clean-ancestry command passes, the correct disposition is to close B-01 as environment-contaminated evidence and inspect `check:hooks` only for the same clean environment before any decision about configuration. The already-passing gate prefix remains reusable. The only remaining deterministic work then is the previously unexecuted suffix, scheduled proportionally rather than by automatically rerunning all gates.

If it fails with a tracked extension path, classify the actual diagnostic then and assign the smallest owner/fix. If it fails only because the same external module is still resolved, correct the execution isolation first; do not mutate source to suppress external diagnostics.

## No proposed repository delta or grade

There is no concrete need yet for a repository change. In particular, do not update dependencies/lockfiles, disable `checkJs` or the type check, add `skip`/ignore patterns, weaken the hook checker, or install a shim solely to hide the ancestor package. Such a change would alter a trusted enforcement boundary and requires an independent necessity decision and scoped grade; neither is established by the current actual diagnostic.

This preserves a genuine ordinary pre-commit check: semantic checking remains required, and the immediate repair target is the contaminated proof environment rather than the check's rigor.
