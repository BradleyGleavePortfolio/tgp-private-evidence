# S7-L worker runtime-identity correction — independent reviewer B (nonbuilder, changed question only)

Grant: REV-2 (`daceddc8/SCOPE.md`). Reviewer: independent T4 reviewer B. Read-only everywhere except this file. No lock,
gates, tests, PG, Git writes, evidence-repo commit, or peer read (`WORKER_CORRECTION_REVIEW_A.md` never opened). No
re-audit of accepted source: only the changed bytes, their causal relation to the v3 failure, lineage, gate receipts and
the v4 binding/fresh paths are examined.

Phase 1 written 2026-09-25 ~16:45Z (uncommitted delta). Phase 2 (committed head, receipt, bundle v4, binding v4) is
appended below once the parent pins it.

---

## PHASE 1 — does the delta close the observed failure causally, and only that?

### 1.1 The changed bytes (verified)

- Worktree `/home/user/workspace/worktrees/64e33dc7-s7l`, HEAD `a68cdac70d81aea384fdc99c01c9c983a08e80eb`
  (tree `6c00e248…`), exactly one modified path (`git status --short` → ` M test/utils/g2-s7l-worker.cjs`).
- `git diff` in the worktree is byte-identical to `s7l/worker-correction/p1-source-delta-preformat.patch`
  (checked with `diff`). Working blob `155ffdccd3d4e472cede84e7b11523d18201b450` (was `a8fed545…`), sha256
  `41bb1975…3f49ec5ee`, `node --check` OK — all equal to `SOURCE_READY.md`.
- Delta content (+14/−3, worker L16, L20–34): `const { existsSync } = require('fs')`; a 3-line comment;
  `const clientRuntime = join(input.client, 'runtime/library.js')`; the ternary `request === '@prisma/client' ? … : …`
  rewritten as `if … return join(input.client,'index.js')` (same behaviour); a new branch: when `request` is exactly
  `'@prisma/client/runtime/library'` or `'@prisma/client/runtime/library.js'` **and** `existsSync(clientRuntime)`,
  return `clientRuntime`; otherwise `resolveFilename.call(this, request, ...args)` (original resolver). Nothing else in
  the file changes: hook installation still precedes `require(input.client)` (L38) and every service require (L39–46);
  the query log, barriers, `$transaction` instrumentation and the `failure` mapping (L166–173) are untouched.
- No `src/**`, `prisma/**`, spec, harness, bootstrap, old-root, fixture or driver bytes are in the delta.

### 1.2 How the OLD image imports Prisma error classes (OLD root = 93389265, read at `worktrees/64e33dc7-env`)

- `src/scout/scout.service.ts:3` `import { Prisma } from '@prisma/client'`; **`:4`
  `import { PrismaClientKnownRequestError } from '@prisma/client/runtime/library'`**; `:296`
  `if (err instanceof PrismaClientKnownRequestError && err.code === 'P2002') { firstTime = false; } else { throw err; }`
  around the batch `$transaction([scoutImportCompletion.create, scoutImport.upsert])` (`:265–294`); ack returned at `:311`.
- Every Prisma specifier in the whole OLD `src/**` is one of exactly two strings: `'@prisma/client'` and
  `'@prisma/client/runtime/library'` (`rg` over `src`, 40+ files; no `/runtime/index`, `/runtime/client`, `/edge`,
  `/extension`, `/sql`, no `.js`-suffixed deep import). The other `runtime/library` importers are
  `notifications/notifications.service.ts:3`, `notifications/nudges/nudge-engine.service.ts:25`,
  `notifications/coach-first-payment.service.ts:3` (all pulled in transitively by `scout.service.ts:6`); the remaining
  services use `Prisma.PrismaClientKnownRequestError` via the `'@prisma/client'` namespace.
- OLD `tsconfig.json`: `module: commonjs`, `paths: {}`; the worker is forked with
  `-r ts-node/register/transpile-only` (`test/utils/g2-s7l-pg-harness.ts:131–137`), so the import compiles to
  `require('@prisma/client/runtime/library')` — the exact string the new branch matches. ts-node 10.9 installs its own
  `_resolveFilename` only under `experimentalResolver` (`node_modules/ts-node/dist/cjs-resolve-hooks.js:11`), which is
  not configured; the worker captures whatever is current at L19 and delegates to it anyway.

### 1.3 What the OLD custom-output client ships (generator 6.19.3 read in pinned `node_modules/@prisma/client/generator-build/index.js`)

- Custom output ⇒ `isCustomOutput === true` ⇒ `runtimeBase = './runtime'` (L13562–13564) and the generated `index.js`
  does `require('./runtime/library.js')` (template L11353; also the `warnEnvConflicts` require, L11326). The v3 review
  observed the same at `.g2-s7l-old-client/index.js` L30/L3430.
- `copyRuntimeFiles` (L13415–13423, L13639–13670) copies into `<output>/runtime/`: `library.js` (with the generated-code
  preamble — the 130-byte header the bootstrap tolerates), `library.d.ts`, `index-browser.js`, `index-browser.d.ts`,
  `edge.js`, `edge-esm.js`, `react-native.js`, `wasm-engine-edge.js`, `wasm-compiler-edge.js`. Only `library.js` is
  reachable from the worker (the worker requires `index.js`, which requires only `./runtime/library.js`); none of the
  other entry points is requested by OLD `src/**` (1.2), so the redirect's coverage of `library` only is complete for
  this harness.
- `runtime/library.js` itself requires only `node:*` built-ins (grep of the pinned copy), so redirecting to the copy
  cannot pull in a second runtime through the copy.
- The bootstrap makes the copy's presence and provenance fail-closed: `g2-s7l-bootstrap.sh:223–228` `hash_required` on
  `$G2_S7L_OLD_CLIENT/runtime/library.js` (exit 6 if missing) and `cmp` of its tail against the pinned runtime (exit 6
  on any byte difference). v3 log L541 recorded `runtime=…/proof-v3/s7l/old-root/.g2-s7l-old-client/runtime/library.js
  runtime_sha256=5a72b6f6… runtime_header_bytes=130 pinned_runtime_sha256=abdeb84c…`. Therefore in any run that reaches
  Jest, `existsSync(clientRuntime)` is **true** for every OLD-image worker.

### 1.4 Causal closure (single module instance)

- Before: OLD service → `'@prisma/client/runtime/library'` → default resolver → old-root `node_modules` symlink
  (`bootstrap:153`) → `<worktree>/node_modules/@prisma/client/runtime/library.js` (instance 1). OLD client →
  `./runtime/library.js` → `<old-client>/runtime/library.js` (instance 2). The P2002 thrown by instance 2 is not
  `instanceof` instance 1's class → rethrow → worker `failure {500, code:'P2002'}` → spec L986 `replay.result` undefined.
  This is exactly the v3 receipt (`jest.log` L715 g2l_49, `queries:3`).
- After: the hook returns `join(input.client,'runtime/library.js')` for the service's request; the client's
  `./runtime/library.js` resolves (default resolver, realpath) to the same absolute string; Node's module cache is keyed
  by that filename ⇒ one instance; `err instanceof PrismaClientKnownRequestError` is true; `firstTime = false`; the ack
  `{acknowledged:true,intent_id}` is returned; L986 then compares a real value.
- Read-only mechanism check (no files written; pinned runtime used as a stand-in directory that has
  `runtime/library.js`): installing the identical hook and requiring the runtime three ways
  (`'@prisma/client/runtime/library'`, `'…/library.js'`, and the absolute `runtime/library.js` path) gave one cache
  entry and `A===B===C` true, and `new B.PrismaClientKnownRequestError(…{code:'P2002'}) instanceof
  A.PrismaClientKnownRequestError` → **true**. Counterfactual with two byte-identical copies at different paths
  (`64e33dc7-s7l` and `64e33dc7-env` `node_modules`, both sha `abdeb84c…`): `A===B` false, `instanceof` **false**,
  `code` P2002 — the v3 failure mode reproduced in-memory.
- Path identity holds here: no component of `/home/user/workspace/execution/64e33dc7/recovery-reset/...` or of the
  worktree path is a symlink (`readlink -f` equals each path), `proof-v4/s7l/old-root` is produced by `git clone`
  (real directory) and `.g2-s7l-old-client` by `mkdir -p` (bootstrap L206); `path.join` yields the same normalized
  string the default resolver's realpath yields. See C-1 for the residual.

### 1.5 The NEW image falls through unchanged

- Candidate worker `client = <root>/node_modules/.prisma/client` (harness L124). That directory has **no `runtime/`**
  (listing: `client.js default.js edge.js index.js index-browser.js wasm.js query_engine_bg.* schema.prisma …`;
  `test -e node_modules/.prisma/client/runtime` → absent). Its `index.js:30` and `:3439` require
  `'@prisma/client/runtime/library.js'` — this is the `.js`-suffixed request the new branch names; with
  `existsSync(<root>/node_modules/.prisma/client/runtime/library.js)` false the branch is skipped and the original
  resolver runs, exactly as before the delta. The candidate's `schema.prisma` generator block has no `copyRuntime`, so
  no copy can appear; and even if one did, the client's own `.js` request would be redirected to the same copy, still one
  instance. Bootstrap L250–252 independently pins the candidate runtime to the package file.
- Cost of the new branch on the NEW path: one string comparison pair plus one `existsSync` per Prisma runtime request;
  no behavioural change.

### 1.6 Could any assertion now pass vacuously?

OLD-image calls in the spec (blob `94e7fac4`): L224 (baseline first complete), L954 (first complete), **L982 (replay —
the failed one)**, L989 (status read), L997 (complete aimed at a server run), L1035 (first complete after down). Only L982
exercises the OLD P2002 branch; the delta changes only what that branch sees.

- L986 `expect(replay.result).toEqual(ack(oldIntent))` requires the service to return the ack, i.e. the catch to
  swallow a P2002 — or the transaction to succeed. L987 `expect(runRow(COACH, oldIntent)).toEqual(rowBefore)`
  discriminates the two: a successful upsert would flip `terminal_status`/`state` to `success` and move `completed_at`.
  So a "vacuous" ack (no duplicate raised) cannot pass the pair. Not vacuous.
- L989–991 status read and L997–1003 server-row protection are reached for the first time on real PG; they are
  independent of the redirect (status path throws nothing; the server-row path raises a CHECK violation, not P2002, so
  the OLD writer rethrows → 500 as expected, row unchanged, no completion row). Before the delta, L1001's 500 would have
  been satisfied by *any* error class; after it, 500 depends on the error genuinely not being a P2002 known error —
  the assertion becomes more, not less, discriminating. Not vacuous.
- No NEW-image assertion changes (1.5). No expectation in the spec was edited (spec blob unchanged).

### 1.7 Phase-1 verdict-so-far

The delta is the minimum closure both v3 runtime reviews specified, its only behavioural effect is on OLD-image
requests for `@prisma/client/runtime/library[.js]` when the custom client carries `runtime/library.js` (guaranteed by
bootstrap L223–228), it unifies the three class sources (`Prisma.*` namespace via the redirected `'@prisma/client'`,
the deep import, and the client's thrown error) into one module instance, the NEW image is provably unchanged, and no
spec assertion becomes vacuous. **Phase-1: GO on the source delta**, subject to Phase 2 (format, commit identity/hook
receipts, one-path lineage, receipt, bundle v4, binding v4).

### 1.8 Phase-1 findings (Safety-ROI)

No class A or B.

| # | Class | Observation | Concrete harm | Decision blocked | Minimum closure | Execution unlocked |
|---|---|---|---|---|---|---|
| C-1 | C | The redirected path is `path.join(input.client,…)`, not `fs.realpathSync(...)`; single-instance identity relies on `G2_S7L_OLD_CLIENT` containing no symlink component. True for the pinned `RUNTIME_ROOT` constant and for the `git clone`/`mkdir -p` produced old-root/client (verified with `readlink -f`). If ever violated the fix would silently not apply and L986 would fail again identically (fail-closed, never vacuous). | none now | none | record only (optional hardening later: realpath the redirect or add `--preserve-symlinks`-independent identity assertion) | n/a |
| C-2 | C | `existsSync` is evaluated on every matching request rather than once at start; if the copy were missing the hook falls through silently. Bootstrap `hash_required` (exit 6) already fails closed before Jest, so the silent path is unreachable in a proof. | none | none | record only | n/a |
| C-3 | C | Redirect matches the two exact specifiers only. Complete for this harness: OLD `src/**` uses exactly `'@prisma/client'` and `'@prisma/client/runtime/library'`; the OLD client uses `./runtime/library.js`. A future OLD image importing another runtime entry point would need extension. | none | none | record only | n/a |
| C-4 | C | Spec L1001 asserts `status: 500` without asserting the error code; the substantive protections are L1002–1003 (row unchanged, no completion row). Adequate; noted because the delta is what makes the 500 depend on "not P2002". | none | none | record only | n/a |
| C-5 | C | Pre-format blob `155ffdcc…` will change under pinned prettier only if formatting differs (the multi-line condition already fits printWidth 100/singleQuote). The post-format blob is what v4 must pin; checked in Phase 2. | none | none | Phase 2 | n/a |

---

## PHASE 2 — committed head, receipt, bundle v4, binding v4

_Pending the parent's final pins._
