# UX-03b single-line type closure grant

Parent EXEC-CF8FF737, September 24, 2026.

## Failure recorded

**Gate run:** the first gate run on frozen write-tree `4b92827dde7ce72a0ed8c470b71c2e1fe4898bee` stopped at tsc with exit code 2.

**Diagnostic:** there was one diagnostic, at `src/types/__tests__/extensionImport.contract.test.ts(496,51)`, TS2339 `import_intent_id`.

**Other gates:** lint and Jest did not run.

**Receipts:** `ux03b/receipts/00-lock.txt`, `01-tsc.log` and `STEP5_STOP_REPORT_01.md` are preserved unchanged.

## Classification

**B, proof-invalidating on the UX-03b gate only.**

- **Harm:** the test file does not type-check, so the proof cannot proceed.
- **Product impact:** no product or runtime defect has been shown.
- **Decision blocked:** the UX-03b commit and its acceptance.

## Minimum closure

- **The change:** annotate the line-493 local as `const example: Record<string, unknown> = { ...exampleOf(...), status: 'bound' };` in the same owned test file.
- **Must not change:** any other line, the assertion semantics, or the test count.
- **Completeness:** tsc reports all diagnostics in one pass, so this closes tsc completely.

## Execution unlocked

1. Refreeze and record the new write-tree and patch sha in `ux03b/CLOSURE_1_READY.md`.
2. Take the lock with flock -n.
3. Rerun step 5 once from gate 1 into new receipt files: tsc, then lint, then Jest.
   - The first nonzero result stops the run.
   - If Jest fails, list every failing assertion and every masked assertion.
4. If all gates pass, commit, bundle, release the lock and report.
