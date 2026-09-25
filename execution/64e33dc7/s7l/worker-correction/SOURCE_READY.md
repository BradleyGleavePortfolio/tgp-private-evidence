# S7-L worker runtime-identity correction — SOURCE_READY (phase 1)

Builder: `s7l_worker_correction_builder` (T4, sole writer of `worktrees/64e33dc7-s7l`), grant S7L-WC-1
(`daceddc8/SCOPE.md`). Parent: executive operator session `daceddc8`. Written 2026-09-25T16:25Z.

## State

- Worktree `/home/user/workspace/worktrees/64e33dc7-s7l`, branch `exec64/s7l-replacement`.
- HEAD unchanged: `a68cdac70d81aea384fdc99c01c9c983a08e80eb` (tree `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb`).
- Exactly one modified path, uncommitted: `test/utils/g2-s7l-worker.cjs` (+14/−3).
  - blob (pre-format) `155ffdccd3d4e472cede84e7b11523d18201b450` (was `a8fed545`).
  - sha256 (pre-format) `41bb197579ce39c4d91ded65da2c6a165c7de4d66ba07371e83511f3b49ec5ee`.
- `node --check test/utils/g2-s7l-worker.cjs` → OK.
- Delta: `p1-source-delta-preformat.patch` (sha256 `da8ecfb25dfdadd221fc72436439137460812b60af989c119df60aa370ae383c`).

## Change (the minimum closure both runtime reviews agree on)

The `Module._resolveFilename` hook in the worker additionally redirects `'@prisma/client/runtime/library'` and
`'@prisma/client/runtime/library.js'` to `join(input.client, 'runtime/library.js')` when that file exists
(`fs.existsSync`), otherwise falls through to the original resolver. `'@prisma/client'` → `join(input.client, 'index.js')`
is unchanged. A custom-output OLD client carries its own runtime copy, so the services' error-class import and the
client's thrown error now share one module instance (`instanceof PrismaClientKnownRequestError` holds for P2002);
the default-output candidate client has no `runtime/` copy, so nothing changes for it.

No spec, harness, bootstrap, migration, `src/**` or pin change. No assertion weakened.

## Not done (by grant)

No lock, no gates, no install/generate/test, no commit. `node_modules` and the prettier prefix are parent-provisioned and
were not touched. Phase 2 (scoped prettier/eslint + one genuine hooked commit) waits for the parent's explicit slot relay.
