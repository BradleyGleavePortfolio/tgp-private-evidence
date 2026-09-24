# UX-07 extension presentation — R2 actual validation disposition

**Scope:** same T1 review, actual-result disposition only. This is not a source re-audit.

**Candidate:** base `0111be661922234d670bbf23e23d270eec1b4a4e`; granted R2 tree `3750a2ea9f6e57b7de96c0102aab66d761776189`; pair blob `01f6839b0b7657520167556fc9ae71c56ea80474`; popup blob `f003a81804d15e5fc34fefbeaab228f371a14a7d`.

## Actual evidence disposition

- `npm ci` completed successfully from the committed lockfile.
- `npm test -- test/popup-start-import.spec.js test/pair-ui-catch.spec.js` passed: 2 files, 9 tests.
- `npm run gates` stopped at its first nonzero step, `check:hooks`, after its preceding static checks passed. The unexecuted suffix is `lint`, the standalone `type-check` script, and `format:check`.
- No commit, source change, retry, hook bypass, browser/runtime/package validation, deployment, or remote action followed.

The passed 2-file/9-test result remains valid for this unchanged R2 candidate and must not be rerun merely because the later gate failed.

## B-01 — semantic type-check proof is unavailable

**Classification:** B — proof-invalidating; not an A product finding on the present evidence.

**Observed fact:** `check:hooks` reported `semantic type-check execution`. Its source first validates the required `lefthook.yml` command strings, then invokes TypeScript with the configured `jsconfig.json` to show effective configuration, list checked files, and perform a no-emit semantic check. The checker suppresses the underlying compiler stderr and combines any failure in that sequence into the one reported label.

**Not an absent hook-install/environment issue:** The authorized `npm ci` output records `sync hooks: ✔️(pre-commit)`. Independent inspection found the installed pre-commit wrapper and a tracked `lefthook.yml` whose required banned, deploy-readiness, lint, type-check, and format commands exactly match the checker. Therefore no hook installation, bypass, or configuration-text absence is evidenced.

**Not a detector C result:** The configured check is intentionally semantic, not a presence-only detector; it must fail closed if its compiler invocation cannot execute successfully. With its diagnostics hidden, this result cannot yet distinguish an actual JavaScript/type error from a checker/configuration invocation fault. Either case leaves the claimed semantic-type-check proof unavailable.

**Candidate causation boundary:** R2 changes only CSS in the two popup HTML files. No JavaScript, TypeScript configuration, hook configuration, hook checker, package metadata, or lockfile differs from the stated base. The current failure is therefore not introduced by the R2 presentation delta, but it blocks crediting the repository-wide gate result for this candidate.

**Harm:** Treating the gate as passed would misrepresent whether the configured pre-commit semantic check can validate the repository's JavaScript surface, allowing an unobserved type/configuration failure to be masked.

**Blocked decision:** no green `npm run gates` claim, no completed deterministic-gate proof, and no ordinary commit/merge eligibility claim relying on that proof.

**Minimum closure:** Run exactly the already-configured `npm run type-check` once against the unchanged R2 candidate and post-`npm ci` dependency set, retaining its unmasked stdout/stderr and exit status. This is diagnostic execution for the failed proof only; it is not a whole-gates rerun and does not repeat the passed 2-file/9-test command.

**Decision after that one command:**

1. If the configured type check reports a tracked-source semantic failure, assign the minimal fix to the owner of that source. No hook bypass is permitted. Any resulting source/configuration change needs risk-scoped review and its own applicable validation.
2. If the configured type check passes, assign the minimal fix to the hook-check/config owner so `check:hooks` truthfully performs and records the required semantic proof; preserve genuine pre-commit execution rather than weakening or bypassing it. Review that narrow gate change, then rerun only `npm run check:hooks`.
3. Once the actual `type-check` and `check:hooks` proofs pass on the relevant exact source, run only the previously unexecuted gate suffix: `npm run lint`, `npm run type-check` if it was not the retained closure run for the same unchanged head, and `npm run format:check`. Reuse the already-passing gate-prefix evidence unless a closure changes one of its inputs. Do not rerun the full gate chain by default.

**Unlock:** a truthful semantic-type-check result plus a passing genuine hook check and the remaining unexecuted deterministic commands unlocks a completed local gate record for the applicable exact candidate. It does not itself establish package, browser/runtime, deployment, or customer readiness.

## C qualification

The checker's generic output prefix, `pre-commit hook missing/alignment error`, is imprecise for this run because the hook was installed and the tracked command configuration is aligned. This is a reporting-quality C issue only; do not create a separate cleanup or audit loop for its wording. The specific `semantic type-check execution` failure remains B-01 until the one-command diagnostic closure distinguishes its cause.
