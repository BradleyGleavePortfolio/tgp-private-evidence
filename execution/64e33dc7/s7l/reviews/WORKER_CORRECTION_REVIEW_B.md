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

Written 2026-09-25 ~16:58Z after the parent's final pins (HEAD `df713fd9…`, TREE `796f437f…`, worker blob `155ffdcc…`,
driver `8b03f4c2…`, fixture `74aed261…`, `BINDING.sha256` `6c912b96…`). Read-only: `git rev-parse`/`diff`/`sha256sum -c`
only; nothing under `proof-v4/clusters/s8-c` (sibling S8-C proof running under the lock) was opened.

### 2.1 Committed head (worktree `worktrees/64e33dc7-s7l`)

- `HEAD` = `df713fd9217df524915348ef8a42c797f288dde1`, `HEAD^{tree}` = `796f437fea80550a379b5f54dc485bc5dbba67e1`,
  `HEAD^` = `a68cdac70d81aea384fdc99c01c9c983a08e80eb`; `git status --porcelain` → 0 lines. Branch `exec64/s7l-replacement`.
- `git cat-file -p HEAD`: exactly one parent; `author` and `committer` both `Bradley Gleave <bradley@bradleytgpcoaching.com>`,
  same timestamp 1790354654 (+0000 = 2026-09-25T16:44:14Z). `git interpret-trailers --parse --only-trailers` on the
  message → 0 bytes (no Co-authored-by/Signed-off-by/AI trailers). Subject `test(scout): S7-L PG proof worker — resolve
  @prisma/client/runtime/library to the custom-output client runtime`; body describes exactly the Phase-1 delta and states
  "no assertion changed" — consistent with what the diff shows.
- One-path delta: `git diff --name-only HEAD^ HEAD` = `test/utils/g2-s7l-worker.cjs`; `--stat` = 1 file, +14/−3;
  `git ls-tree HEAD test/utils/g2-s7l-worker.cjs` = blob `155ffdcc…` (identical to the Phase-1 pre-format blob: prettier
  changed nothing). **`git diff HEAD^ HEAD` is byte-identical to `p1-source-delta-preformat.patch`** (`diff` empty), so the
  committed bytes are exactly the bytes reviewed in Phase 1 (1.1–1.7 carry over unchanged).
- Lineage `git log`: df713fd9 → a68cdac7 → 54970cd9 → 839b54c5 → 93389265 (merge of S8-B). Reflog: one `commit:` entry at
  16:44:14Z; no amend/reset after it. The only other reflog entry (`reset: moving to HEAD`, 16:16:20Z) predates the
  builder's SOURCE_READY (16:25Z) and belongs to worktree provisioning; it moved nothing (same commit).
- Genuine hooks: `commit-attempt-1.raw.log` (sha `3d438d20…`, matches `RECEIPTS.sha256`) shows lefthook v2.1.9
  `pre-commit` (prod-readiness-quick ✔, banned-cast-tokens R75 `--cached` ✔ "no positive token change", tsc 44.98 s ✔;
  eslint/prettier "skip, no files for inspection" because the hook globs exclude `.cjs`) and `commit-msg` (no-ai-tokens ✔),
  then `[exec64/s7l-replacement df713fd9] … 1 file changed, 14 insertions(+), 3 deletions(-)`. The hooks in the shared git
  dir are the SCOPE-pinned ones: `pre-commit` `3b741de3…`, `commit-msg` `71029ce8…`. `s7l-worker-gate.sh` (`32683a5e…`)
  contains no `--no-verify`, `LEFTHOOK`, `hooksPath`, `amend`, `push` or `--force`; commit is `git commit -F commit-message.txt`
  after `git add -- test/utils/g2-s7l-worker.cjs` and a staged-set equality check.
- Scoped lint receipts: `prettier-check-1.log` "All matched files use Prettier code style!" (rc0, no write);
  `eslint.raw.log` empty (sha `e3b0c442…` = empty file, rc0); `gate.log` `PREFIX_VERIFY rc=0 ok_lines=56`,
  `NPX_PRETTIER_VERSION=3.9.9`, `NM_HIDDEN_LOCK=05bc530a…`, `NM_CLIENT_INDEX_DTS=9042e713…`, lock `ACQUIRED 16:44:10Z`
  inode 674373 → `RELEASING … rc=0` 16:45:01Z, `STAGED_TREE=796f437f… WORKER_BLOB=155ffdcc…`. No Jest/PG in the gate.

### 2.2 `worker-correction/CORRECTION_RECEIPT.md` and `RECEIPTS.sha256`

`sha256sum -c RECEIPTS.sha256` → 13/13 OK (SOURCE_READY, CORRECTION_RECEIPT, commit-message, gate script, gate.log,
gate.stdout, commit raw log, eslint/prettier logs, p1/p2 patches — both `da8ecfb2…`, prepare-binding-v4.py). Every
identity claim in the receipt (§1 lineage and trees, §2 blob/sha/patch equality, §3 hook/lint results, §4 bundle hashes,
§5 pins and fresh paths) was re-derived above or in 2.3–2.4 and matches. It correctly states NOT accepted / no PG run.

### 2.3 `bundle/v4`

`sha256sum -c SHA256SUMS` → 6/6 OK; `SHA256SUMS` itself `29dcc469…` (parent pin). From the worktree (the evidence repo
lacks the prerequisite commit, which is expected for a thin bundle): thin `s7l-v4-df713fd9217d.bundle` (`f81254c3…`)
"is okay", contains `df713fd9… HEAD`, requires `93389265…`; full-history bundle (`4c56330f…`) "is okay", records a complete
history with HEAD and `refs/heads/exec64/s7l-replacement` at df713fd9. `s7l-v4-followup-…patch` is byte-identical to the
Phase-1 patch; `s7l-v4-cumulative-93389265a846-to-df713fd9217d.patch` equals `git diff 93389265 df713fd9` byte-for-byte
(30 files, +5623/−35). `MANIFEST-name-status` = `M test/utils/g2-s7l-worker.cjs`; `HEAD-df713fd9217d.txt` fields match.

### 2.4 `binding/v4`

- `sha256sum -c BINDING.sha256` → 9/9 OK; file sha `6c912b96…` (parent pin). `SUPPLEMENT.sha256` → 3/3 OK
  (`driver-v3-to-v4.filled.diff`, `BINDING.sha256`, `freeze-v4.log`). `bash -n` on driver, fixture and freeze-v4 OK.
- **Driver diff v3→v4, computed independently (`diff v3/s7l-pg-proof.sh v4/s7l-pg-proof.sh`) and equal to the recorded
  `driver-v3-to-v4.filled.diff`** (the pre-fill `driver-v3-to-v4.diff` differs only in `EXPECT_FIXTURE_SHA=__FILLED_BY_FREEZE__`).
  Every hunk falls in the granted categories: (a) header comment L2–11; (b) paths — usage line, `D=…/binding/v4`,
  `LANE/SOCK=…/proof-v4/…`, `OLDROOT=…/proof-v4/s7l/old-root` (`OLDCLIENT` derived); (c) pins — `EXPECT_PARENT` a68cdac7,
  `EXPECT_HEAD` df713fd9, `EXPECT_TREE` 796f437f, `EXPECT_WORKER_BLOB` 155ffdcc, `EXPECT_FIXTURE_SHA` 74aed261;
  (d) lineage shifted one level — HEAD^ = a68cdac7 with tree 6c00e248, ^^ = 54970cd9 tree 513c71d7, ^^^ = 839b54c5 tree
  f02205c6, ^^^^ = base; (e) one-path delta string `test/utils/g2-s7l-worker.cjs`; (f) the two other-lane loops (preflight
  L165, post L215) enumerate `"$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/`,
  keep `[ -d ]`, exclude own `$LANE` by path (`"${d%/}" != "$LANE"`), and name lanes `RUNTIME_ROOT`-relative (so retained
  v2 `clusters/s7l`, failed v3 `proof-v3/clusters/s7l` and sibling `proof-v4/clusters/s8-c` are distinct names). The
  sibling S8-C v4 lane is only hashed/`postmaster.pid`-checked, never started; a live sibling makes preflight refuse
  (rc 71), and the lock serializes anyway. (g) The not-frozen placeholder `case` now scans `EXPECT_WORKER_BLOB` instead
  of `EXPECT_SPEC_BLOB` (both are filled; see C-7). No other line changed: lock handling, fixture calls, bootstrap,
  identity, single Jest invocation, stop/post logic and bounds are byte-identical to v3.
- Fixture diff v3→v4 = exactly 3 lines (comment L12, `LANE`, `DATA/LOG/SOCK`) and equals the recorded `fixture-v3-to-v4.diff`.
- **All pins re-verified against the committed head** (`git rev-parse df713fd9:<path>`): spec 94e7fac4, bootstrap
  ebef51fc, old-root cb1137fe, db 384e1b74, pg-harness d8b71d68, harness f0860a8d, worker 155ffdcc, guard 27fcba5f,
  migration tree 4ce57646, schema blob 2e328bbc — 10/10 OK; `BASE_TREE` a315dd65 OK. Worktree shas: schema 0eb41f9a,
  package-lock b7fed5ed, jest.rls.config 99c9f4f1, hidden lock 05bc530a, `.prisma/client/index.d.ts` 9042e713 — OK.
  Tool shas: postgres 23cd1748, initdb b7db9bc2, pg_ctl af53d826, psql wrapper a200e38c, node a03953a7 — OK.
  **The full set of unchanged `EXPECT_*` pins is textually identical between v3 and v4** (diff of the extracted lines
  empty); `PORT/DBNAME/ADMIN/FIXPASS/CLUSTER_MARKER/DB_MARKER/BASE_HEAD/BASE_TREE/LOCK/W` identical.
- Fresh paths: `proof-v4/clusters/s7l`, `proof-v4/run/s7l`, `proof-v4/s7l/` and `binding/v4/run/` are all absent
  (only `proof-v4/clusters/s8-c` and `proof-v4/run/` exist — the sibling's, untouched). `freeze-v4.log`: HEAD_PIN_OK ×14,
  TOOL_PIN_OK ×10, FROZEN_V4 at 16:50:11Z.
- Immutability of consumed lanes: v3 `BINDING.sha256 -c` and `run/RUN_FREEZE.sha256 -c` all OK; v3 run receipts unchanged.

### 2.5 Final verdict — **GO**

Head `df713fd9` is an ordinary, genuinely hooked, trailer-free Bradley commit whose only delta from the preserved
`a68cdac7` is the exact Phase-1 worker resolver change (causal closure of the v3 L05/L12 failure, NEW image unchanged, no
vacuous assertion). Receipts, bundle v4 and binding v4 verify; the v4 driver/fixture differ from v3 only in the granted
categories with every other pin unchanged; the fresh v4 lane paths are absent. This GO covers the changed question only
and authorizes nothing by itself: the single PG-4 invocation `timeout -k 30 3900 bash binding/v4/s7l-pg-proof.sh` remains
the parent's separate grant, serialized on the canonical lock after the sibling S8-C proof ends, and a full pass would
accept exactly `df713fd9` and nothing else.

### 2.6 Phase-2 findings (Safety-ROI)

No class A or B. Phase-1 C-1…C-4 stand; C-5 is closed (post-format blob = pre-format blob `155ffdcc…`, pinned in v4).

| # | Class | Observation | Concrete harm | Decision blocked | Minimum closure | Execution unlocked |
|---|---|---|---|---|---|---|
| C-6 | C | Lefthook's pre-commit eslint/prettier globs skip `.cjs`; the only lint of the worker file is the gate's scoped pinned prettier/eslint (both rc0, receipts hashed). Same situation as the accepted `g2-tq0-worker.cjs`. | none | none | record only | n/a |
| C-7 | C | v4 driver L96 placeholder guard checks `EXPECT_WORKER_BLOB` for `__` where v3 checked `EXPECT_SPEC_BLOB`. Both pins are filled and both are separately enforced by the object-pin loop (L115–119), so the guard's coverage is equivalent; it is a one-token deviation from "all other lines unchanged" and is recorded for the delta ledger. | none | none | record only | n/a |
| C-8 | C | `binding/v4/run-prep/` (PREFLIGHT.md, supervisor.sh, RUN_PREP.sha256, ~16:55Z) appeared during this review, outside `BINDING.sha256` and outside the pins I was given; not audited here beyond noting its outer command string equals the frozen invocation. The parent's PG-4 grant should verify it separately. | none | none | parent read-only check before launch | n/a |
| C-9 | C | Reflog `reset: moving to HEAD` at 16:16:20Z (worktree provisioning, pre-builder) — no ref movement; recorded so it is not mistaken for a post-commit reset. | none | none | record only | n/a |
