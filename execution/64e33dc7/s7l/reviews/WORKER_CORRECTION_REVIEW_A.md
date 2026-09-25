# S7-L worker runtime-identity correction — independent reviewer A (changed question only)

Reviewer: independent nonbuilder T4 reviewer A, grant REV-2 (`daceddc8/SCOPE.md`). Read-only everywhere; this is the
only file written. No lock, gates, Jest, PG, Git writes, evidence-repo commit or peer read (`WORKER_CORRECTION_REVIEW_B.md`
not opened). Scope is the changed bytes, lineage, gate receipts and the exact v4 binding; the accepted source of
`a68cdac7` is not re-audited.

Phase 1 written 2026-09-25 ~16:45Z against the uncommitted worktree delta. Phase 2 (committed head, receipt, bundle v4,
binding v4) is appended below once the parent pins them.

## Phase 1 — does the delta close the observed v3 failure causally?

### 1.1 Delta identity

- Worktree `/home/user/workspace/worktrees/64e33dc7-s7l`, HEAD `a68cdac70d81aea384fdc99c01c9c983a08e80eb`,
  `git status --short` = exactly ` M test/utils/g2-s7l-worker.cjs`; `git diff --stat` = 1 file, +14/−3.
- `git diff` is byte-identical to `s7l/worker-correction/p1-source-delta-preformat.patch`
  (sha256 `da8ecfb25dfdadd221fc72436439137460812b60af989c119df60aa370ae383c`); working blob
  `155ffdccd3d4e472cede84e7b11523d18201b450`, sha256 `41bb1975…3f49ec5ee` — all three equal to `SOURCE_READY.md`.
  `node --check` OK.
- Changed bytes (worktree `test/utils/g2-s7l-worker.cjs`): L16 `const { existsSync } = require('fs');`; L20-22 comment;
  L23 `const clientRuntime = join(input.client, 'runtime/library.js');`; L24-34 the hook:
  bare `'@prisma/client'` → `join(input.client,'index.js')` (unchanged semantics, L25);
  `'@prisma/client/runtime/library'` or `'…/library.js'` **and** `existsSync(clientRuntime)` → `clientRuntime` (L26-32);
  else `resolveFilename.call(this, request, ...args)` (L33). Nothing else in the file changed (L35-185 identical to
  `a68cdac7`). No spec, harness, bootstrap, old-root, migration, `src/**` or pin byte is touched.

### 1.2 Failure mechanism being closed (from the frozen v3 evidence, not re-derived)

`binding/v3/run/PROOF_RUN_RECEIPT.md`: `g2l_49` (OLD image, replay `complete`) returned
`failure {status:500, code:'P2002'}` with 3 queries → spec L986 `expect(replay.result).toEqual(ack(oldIntent))` received
`undefined`. Both runtime reviews (A §3, B §2) locate the cause at the OLD writer's
`err instanceof PrismaClientKnownRequestError && err.code === 'P2002'` (`git show 93389265:src/scout/scout.service.ts`
L296) with the class imported from `'@prisma/client/runtime/library'` (L4), while the OLD custom-output client's
`index.js` L30/L3430 `require('./runtime/library.js')` loads its own runtime copy — two module instances.

### 1.3 Composition facts verified in this review (file:line)

- Harness `test/utils/g2-s7l-pg-harness.ts` L123-124: `root: old ? oldRoot : root`,
  `client: old ? oldClient : resolve(root, 'node_modules/.prisma/client')`; L131-133: the child is always the
  **candidate's** `test/utils/g2-s7l-worker.cjs`, `cwd: root`, `execArgv ['-r','ts-node/register/transpile-only']`.
  So the candidate worker drives the OLD image, and changing the worker in the candidate is the right lever.
- `tsconfig.json` L3 `"module": "commonjs"`: `import … from '@prisma/client/runtime/library'` is emitted as
  `require('@prisma/client/runtime/library')` — exactly the bare deep specifier the hook matches.
- OLD root composition: `test/utils/g2-s7l-old-root.sh` L62/L64 creates a real `git clone --no-checkout` +
  `checkout --detach 93389265` (real directory, not an archive or symlink); L96-100 only reports/refuses a
  `node_modules` link. `test/utils/g2-s7l-bootstrap.sh` L153 links `<old-root>/node_modules → $ROOT/node_modules`
  (so an unredirected `@prisma/client/runtime/library` resolves to the pinned package runtime), L205 `mkdir -p
  "$G2_S7L_OLD_CLIENT"` (real dir), L213-215 generates the OLD client into it, L220-228 verifies
  `<client>/runtime/library.js` ends with the pinned runtime bytes (header-tolerant; refusal otherwise).
- OLD client snapshot (`handoff/offline-recovery/s7l-old-clients.tar.gz`, member
  `proof-v3/s7l/old-root/.g2-s7l-old-client`, extracted read-only to `/tmp/revA`): `index.js` L30 and L3430
  `require('./runtime/library.js')` are its only runtime requires; `default.js`/`client.js` re-export `.`; the copied
  `runtime/library.js` requires only `node:*` builtins (no `@prisma/*`, no `.prisma/client`). Its tail is byte-identical
  to `node_modules/@prisma/client/runtime/library.js` (`cmp` of the last 202499 B OK; sha `abdeb84c…` pinned vs
  `5a72b6f6…` copy = 130-byte generator header, as bootstrap L220-228 and B §2 state).
- NEW default-output client `worktrees/64e33dc7-s7l/node_modules/.prisma/client/`: directory listing has **no
  `runtime/`**; `index.js` L30 and L3439 `require('@prisma/client/runtime/library.js')`.
- Deep specifiers in the OLD root's source (`git grep '@prisma/client/' 93389265 -- src`): every hit is
  `'@prisma/client/runtime/library'` (scout.service.ts L4, notifications.service.ts L3, nudge-engine.service.ts L25,
  coach-first-payment.service.ts L3, fasting.service.ts L2, plus spec files). No `runtime/client`, `runtime/binary`,
  `runtime/edge`, `.prisma/client`, `@prisma/extension` or `@prisma/adapter` request exists at 93389265 or at HEAD
  (`git grep` empty for all). `src/prisma.service.ts` L2 imports only the bare `@prisma/client`. Therefore the two
  specifiers the hook redirects are the complete set of runtime entry points any OLD-root module can request; there is
  no residual split path.
- Production topology: `prisma/schema.prisma` L4-6 at both 93389265 and HEAD is `generator client { provider =
  "prisma-client-js" }` with **no** `output` — production runs the default-output client, i.e. one runtime instance.
  The custom-output OLD client is a proof-harness artefact (bootstrap §6) only.

### 1.4 Empirical module-identity check (read-only, in /tmp; not a project test, gate or PG action)

A 25-line Node script in `/tmp/revA/identity-check.cjs` installs the worktree hook verbatim (same three branches, same
`existsSync(clientRuntime)` guard), then from an emulated service module (`Module.createRequire(<worktree>/src/scout/
scout.service.ts)`) requires `'@prisma/client/runtime/library'` and `'@prisma/client'`, compares
`client.Prisma.PrismaClientKnownRequestError === lib.PrismaClientKnownRequestError`, constructs a P2002 error through
the client's class and tests `instanceof` against the service-side class, and lists every `runtime/library.js` in
`require.cache`. No database, no `PrismaClient` instantiation, no write to any repository.

| Case | `clientRuntime` exists | `@prisma/client/runtime/library` resolves to | same class / `instanceof` | runtime modules in cache |
|---|---|---|---|---|
| OLD custom-output client (v3 snapshot), **corrected hook** | true | `<client>/runtime/library.js` | **true / true** | 1 (`<client>/runtime/library.js`) |
| NEW default-output client (worktree `node_modules/.prisma/client`), corrected hook | false | `node_modules/@prisma/client/runtime/library.js` | **true / true** | 1 (pinned package runtime) |
| OLD client, **v3 hook** (bare specifier only; counterfactual) | — | `node_modules/@prisma/client/runtime/library.js` | **false / false** | 2 (package runtime + client copy) |

The counterfactual reproduces the v3 split exactly as the runtime reviews described; the corrected hook collapses it to
one instance for the OLD image and is a no-op for the NEW image (fall-through path taken, same pinned runtime as before).

### 1.5 Could the delta mask a real product defect?

No. The only behavioural difference is *which file* satisfies the two `runtime/library[.js]` specifiers in the OLD-image
worker process, and only when the client directory carries a bootstrap-verified byte-identical copy. The delta does not
touch the error code test (`err.code === 'P2002'`), the spec's expectations (L986-1003 unchanged), the writer, the
migration or the DB. A non-P2002 error on the L12 "crossed" path (server row, CHECK refusal) is still rethrown → 500
(spec L1000 unchanged) because the code test, not the class identity, decides it. For the NEW candidate every P2002
path still runs through the real package runtime exactly as in v3 (L09 duplicate no-op ack was already observed passing
there). The corrected harness now mirrors production's single-runtime topology (schema has no custom `output`), so a pass
at L986 would be evidence about the product, not about the harness.

### 1.6 Phase 1 findings (Safety-ROI)

| # | Class | Concrete harm | Decision blocked | Minimum closure | Execution unlocked |
|---|---|---|---|---|---|
| — | none A/B | — | — | — | — |

Class C (record only; no action requested, nothing blocks):

- C1 (path-identity assumption): the hook returns `join(input.client,'runtime/library.js')` un-realpath'd, while the
  client's own relative `require('./runtime/library.js')` is realpath'd by Node. If `input.client` ever traversed a
  symlink component, two cache keys would reappear (reproduced in `/tmp/revA` with a symlinked client path: 2 modules,
  `instanceof` false). This is **not** live for the bound lanes: `readlink -f` of every prefix of
  `/home/user/workspace/execution/64e33dc7/recovery-reset` is itself; the v4 OLD root is a real `git clone` directory
  (old-root.sh L62-64) and `.g2-s7l-old-client` is `mkdir -p` (bootstrap L205); the v3 driver L28/L61 and (to be
  verified in Phase 2) the v4 driver use those absolute paths. A `realpathSync` on `clientRuntime` would remove the
  assumption but is not needed for this proof and would widen the delta. Same assumption already exists for the accepted
  `index.js` redirect.
- C2: `existsSync` runs on each matching request; two or three requests per worker process. Negligible.
- C3: the accepted sibling workers (`g2-tq0-worker.cjs` and the other g2 lanes) keep the bare-specifier-only hook; they
  are outside this grant and were not re-audited.
- C4: the pre-format blob `155ffdcc` already appears prettier-shaped for `.prettierrc` (printWidth 100, singleQuote,
  trailingComma all). If the scoped prettier pass changes bytes, the committed blob will differ from the patch — Phase 2
  compares the committed diff to this patch semantically.

**Phase 1 verdict-so-far: the delta is the agreed minimum closure, is causally sufficient for the observed L05/L12 failure
(OLD image collapses to one runtime instance; NEW image falls through unchanged; no other deep runtime path exists in the
OLD root), and cannot mask a product defect. GO-so-far, pending Phase 2 pins.**

## Phase 2 — committed head, receipt, bundle v4, binding v4

(To be appended after the parent messages final pins.)
