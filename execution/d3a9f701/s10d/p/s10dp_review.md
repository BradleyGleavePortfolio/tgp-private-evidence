# S10-D P independent source review

**Verdict: GO (source-only, conditional on running the four specs in both file layouts).** Reviewed the four-test-only delta in `private-evidence/execution/d3a9f701/s10d/p.diff` against the S10-C frozen layer and D-S10-5. I did not run Jest, package tooling, or the PG suite.

## Findings

**No A/B blocker found.**

- `native-families.spec.ts:236–309` compares the default registry to loaded JSON filenames and keys, binds every native rule set to an existing mapper and one of its families, and retains a `truecoach` no-guessed-rules guard. Its orphan and foreign-family counterexamples return explicit violation strings; the constructed `truecoach` rule set trips the positive guard. The absent-directory and present-empty fail-closed cases remain.
- `manifest-registry.spec.ts:73–113` builds a package from the *shipped* manifests/specs/rules (the production V2/V3/V6 checks), verifies manifest/package keys and mapping digests, and forbids a `truecoach` manifest. Its extra orphan manifest throws; a constructed `truecoach` package demonstrably trips the guard. The positive fixture R20 checks remain.
- `mapping-spec.spec.ts:164–222` checks that each shipped multi-step fan-in is declared with exactly its steps, while a 1:1 family declares none; it requires at least one shipped spec and keeps the `truecoach` 1:1/no-declaration check. Undeclared and partly/incorrectly declared synthetic examples produce violations, while the correct declaration is accepted. This permits D2's declared workouts fan-in without dropping the existing production guard.
- `facts.service.coverage.spec.ts:155–174,600–668` uses shipped native rules only for the default-registry branch, so D2's `nativeRules: declared` manifest has a matching rule set. The fixture source and observer public keys are expressly excluded from *all* shipped manifest verifiers. The same proven run yields `BASELINE` under the fixture-trusting registry, showing the default `UNKNOWN` result is not due merely to a broken evidence path. The foreign-rule test retains the D2 package if shipped while checking the unrelated rule is filtered.

## With and without D2

Without D2, the disk loaders can return empty manifests/rules, while the existing `truecoach` mapper keeps the mapping test nonempty; the revised expectations accept that layout. With D2, its `s10_unseen` mapping spec declares the two workouts steps, the native rules name only programs/workouts, and the manifest names the same three families with `nativeRules: declared`. D2's verifier public key differs from both S10-A pure-fixture keys, so the default coverage case remains UNKNOWN while its explicit fixture-trusting control remains BASELINE. The D2 manifest does **not** name the real production platform, preserving both positive guards.

**C — Execution still pending.** This is a static compatibility review; the parent should run the four specs on the frozen base and on the D2 layout before claiming a green suite. The diff changes only the four stated `test/**` files. The S10-C source changes visible in this worktree are its pre-existing frozen layer, not P edits; no P delta touches `src/**`, `prisma/**`, contract, package, or manifest paths.
