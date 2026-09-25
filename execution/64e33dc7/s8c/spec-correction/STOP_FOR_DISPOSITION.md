# S8C-BC-4 — stopped for disposition after diagnostic (b) re-run (17:15Z)

## Done under S8C-BC-4
- Three assertion sites changed in `test/rls-g2-s8c.spec.ts` exactly as granted (F1 `json`→`jsonAdmin` for the identity
  observation, values unchanged; F2 `toBeCloseTo(toPounds(100,'kg'), 9)` on `weight_lbs` only, other fields still exact;
  F3 `count('User', "id <> 'b5-system-coach-tgp'")`), plus the now-unused `json` import removed (strictly required by F1: the
  eslint hook fails on `no-unused-vars` at `--max-warnings 0`). `spec.patch` `98f0d9b3…` (+9/−4). No harness/product/bootstrap change.
- Gate `s8c-spec-gate.sh` (`73bd8f48…`): first launch STOPPED at its own pre-commit eslint step (unused `json` import) —
  no commit attempted, no hook run, slot held 17:11:56–17:11:59Z; logs preserved in `run-attempt1-lint-stop/`. Import removed;
  second launch (`run/`) slot 17:12:37–17:13:28Z: prettier ✔ eslint ✔, hooked commit ✔ (prod-readiness, banned-casts,
  prettier, eslint, tsc 47.19 s, no-ai-tokens), Bradley author/committer, no trailers.
- **HEAD `4d7d4b4ebdb7df2af593bbd809f7df23775fdf29`**, parent `9cc76401…`, **TREE `c1949c5b976b669b6c10874e7d00eb5494e487a9`**,
  spec blob → **`84410b5c4a1e84750c038ed73c2fbc361eeaae90`**; porcelain 0.
- Diagnostic (b) re-run `harness-correction/diagnostic/diag-b2-suite.sh` (`93ecff01…`) on the same scratch lane 55644, slot
  17:14:02–17:14:52Z, clean head 4d7d4b4e: **11 passed / 2 failed** (`b2/jest.log` `96c92de2…`). F1 and F2 are closed.
  (An initial launch was refused by the script itself at its env-name check before any lock/PG action: `diag-b2.stderr.attempt0-envname-refusal`.)

## New findings (not 13/13 → stopped; no further edit, no commit, nothing rerun)
- **F4 (new, same class as F3, previously masked):** `spec.ts:290` `expect(count('User')).toBe(1)` inside the standalone-plan
  test — a fourth `count('User')` site. In run (b) this test threw earlier at the F2 float assertion (L218), so L290 never
  executed; it is now reached and fails against the accepted seed system coach. On a fresh proof lane it would read 2.
  Closure candidate: same as F3 (exclude the seed id, or pre-writer baseline). This is outside the "exactly three sites" grant.
- **Diagnostic-lane contamination (not a spec defect on a fresh lane):** the scratch DB persisted from run (b), and `User` is
  never reset by `resetData()` (FK target; the seed coach cannot be deleted). Run (b) inserted `coach-b` (two-coach test), so
  in b2 `count('User')` = 3 (seed, coach, coach-b) at L290 and the F3-scoped count = 2 at L429. Within a single fresh-lane run
  both sites execute before the two-coach test (file order), so the F3 form is correct for the accepting proof, but the
  diagnostic re-run needs a **fresh scratch lane** (e.g. `scratch/s8c-diag2`, fresh initdb + bootstrap at the clean head) to be
  meaningful — or the assertions take the parent's "pre-writer baseline" form, which is immune to any prior rows.

## Recommendation for disposition
1. Grant one more assertion-site change (L290) in the F3 form. Preferred robust form for BOTH User sites: capture
   `const usersBefore = count('User')` before `run(...)` and assert `expect(count('User')).toBe(usersBefore)` (still proves
   the writer minted no User; independent of seeds and lane history). Same class, one file, one more hooked commit
   (child of 4d7d4b4e).
2. Diagnostic (b3) on a **fresh** scratch lane `scratch/s8c-diag2` (new initdb, unchanged bootstrap at the clean final head),
   must be 13/13, then v7/v5/run-prep v5 from that head.
