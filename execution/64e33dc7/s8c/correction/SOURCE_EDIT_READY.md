# S8-C mapping-expectation correction — SOURCE EDIT READY (no gates run, no lock touched)

Grant: `S8C_MAPPING_EXPECTATION_CORRECTION_GRANT.md`. Frozen candidate `527fe2bc` / tree `d87a9626`, original binding (`binding/BINDING.sha256` re-verified), `checkpoints/v3` (manifest re-verified) and `SOURCE_RECEIPT.md` untouched.

## Working-tree delta from 527fe2bc (uncommitted, exactly one file)
`test/scout/reconstruct/mapping-spec.spec.ts`, one repository-spec case, +9/-1 (`correction/mapping-spec.spec.ts.delta-from-527fe2bc.patch`, sha `a79caec2…`):
- title `TrueCoach \`notes\` (emitted by the live blueprint) is explicitly unresolved` → `TrueCoach \`notes\` and the undeclared canonical \`programs\` family are unresolved` (descriptive; kept ≤ printWidth 100).
- `notes` unresolved assertion retained verbatim.
- canonical-family iteration retained; new explicit branch: for `RECONSTRUCT_FAMILY.programs` expect `{ ok:false, reason:'unresolved_family:programs' }` then `continue`; the three supported families (`clients`, `workouts`, `client_history`) still assert `{ ok:true, family }`.
- No skip, no deletion, no source/`truecoach.json`/parser/artifact/dependency change.

## Prepared for after parent relay (refuse-by-default, verified: rc 70 without `S8C_CORRECTION_RELAY=1`)
`correction/s8c-correction-gate.sh` (sha `7703b0d6…`): flock -n on the canonical lock (refuse live holder, never delete) → verify HEAD=527fe2bc and delta is exactly the one file → prettier 3.9.9 prefix `--check` on the file → eslint on the file → Jest `--runTestsByPath` on the changed file only → `git add` that file → genuine hooked ordinary commit as Bradley Gleave (author+committer, message `correction/commit-message.txt` "S8-C: assert TrueCoach programs family unresolved", no trailers, no `--no-verify`, no amend), `NODE_OPTIONS=--max-old-space-size=4096` for the hook's tsc → log HEAD/tree/parent → release at exit. No native/mapper-suite, generator or R75 replay (hook supplies R75/prettier/eslint/tsc). Failures preserved under `correction/run/`.

Then lock-free: `correction/prepare-binding-v2.sh` (sha `6a722d74…`, verified refuses while HEAD is 527fe2bc): copies the original filled binding to `binding/v2/`, changes only `EXPECT_HEAD`, `EXPECT_TREE` and the mechanical `D=…/binding/v2` receipts path (asserts exactly 3 changed runner lines), verifies the six proof blobs are identical between 527fe2bc and the new head, fixture byte-identical to its pin, records `s8c-pg-proof.sh.diff-v1-to-v2`, `PINS.txt.diff-v1-to-v2`, `BINDING.sha256`. Export to `checkpoints/v4/` (bundle/patch/HEAD.txt/CHANGED_PATHS/manifest) and a separate `correction/CORRECTION_RECEIPT.md` follow.

Awaiting explicit relay before any heavy step. No PG.
