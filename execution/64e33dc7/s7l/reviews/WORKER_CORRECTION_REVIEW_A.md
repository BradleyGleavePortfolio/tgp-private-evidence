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

Written 2026-09-25 ~17:00Z against the parent's final pins (mail 16:5xZ). Every check below was performed by me,
read-only, from the worktree and the evidence tree; the parent's and builder's numbers were compared, not copied.
The sibling S8-C v4 lane `proof-v4/clusters/s8-c` was only `ls`-ed (no file inside it opened, nothing touched).

### 2.1 Committed head

- `git rev-parse HEAD` = `df713fd9217df524915348ef8a42c797f288dde1`; `HEAD^{tree}` = `796f437fea80550a379b5f54dc485bc5dbba67e1`;
  `HEAD^` = `a68cdac70d81aea384fdc99c01c9c983a08e80eb` (single parent); `HEAD^^`/`HEAD^^^`/`HEAD^^^^` = 54970cd9 / 839b54c5 /
  93389265 with trees 513c71d7 / f02205c6 / a315dd65 (preserved lineage intact). Branch `exec64/s7l-replacement`; porcelain 0.
- `git cat-file commit HEAD`: author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 1790354654 +0000
  (16:44:14Z). Body: subject + two bullets + one closing paragraph; `git interpret-trailers --parse --only-trailers` → 0 bytes;
  no Co-authored-by / Signed-off-by / generated-by text.
- `git diff --name-only HEAD^ HEAD` = exactly `test/utils/g2-s7l-worker.cjs`, +14/−3; `HEAD:test/utils/g2-s7l-worker.cjs` =
  blob `155ffdccd3d4e472cede84e7b11523d18201b450` — the Phase-1 pre-format blob. `git diff HEAD^ HEAD` equals
  `p1-source-delta-preformat.patch` byte-for-byte apart from nothing (index line included), so prettier changed no byte and
  every Phase-1 conclusion (§1.3-1.5) applies verbatim to the committed head. C4 is closed.

### 2.2 Gate receipts (`s7l/worker-correction/`)

- `sha256sum -c RECEIPTS.sha256`: 13/13 OK (SOURCE_READY, CORRECTION_RECEIPT, commit-message, gate script 32683a5e…,
  gate.log 5e5c3131…, gate.stdout, commit raw log, eslint/prettier logs, both patches, prepare-binding-v4.py cf040987…).
- `s7l-worker-gate.sh`: `flock -n 9` on the canonical lock (L26, refuses a live holder); Bradley identity exported (L31);
  isolated prettier prefix verified against the 56-file manifest before use (L44-46), `npx --no-install prettier --version`
  must equal 3.9.9 (L48), no prettier inside the product tree (L49); `prettier --check` (L52) then `eslint --no-warn-ignored
  --max-warnings 0` (L65) on the one file; `git commit -F commit-message.txt` (L71). `rg` for `no-verify|amend|force|bypass|
  LEFTHOOK=0|HUSKY=0|reset --hard` in the script: no hits.
- `gate.log`: ACQUIRED 16:44:10Z inode 674373 → NM hidden lock 05bc530a… and client `index.d.ts` 9042e713… re-verified →
  PREFIX_VERIFY rc0 56/56 → PRETTIER_CHECK_1 rc0 ("All matched files use Prettier code style!", no write pass) → ESLINT rc0
  (`eslint.raw.log` 0 bytes) → STAGED_TREE 796f437f WORKER_BLOB 155ffdcc → GIT_COMMIT rc0 16:44:59Z → HEAD/TREE/parent/gp/
  ggp/base line matches §2.1 → thin and full bundle verify rc0 → DONE 16:45:01Z, RELEASING rc0.
- `commit-attempt-1.raw.log`: genuine lefthook v2.1.9 pre-commit (`eslint (skip)` and `prettier (skip)` — the hook's globs
  exclude `.cjs`, hence the scoped lint above is the only lint of this file; `prod-readiness-quick` ✔, `banned-cast-tokens`
  R75 --cached "OK — no positive token change" ✔, `tsc` 44.98 s ✔) and commit-msg (`no-ai-tokens` ✔), then
  `[exec64/s7l-replacement df713fd9] … 1 file changed, 14 insertions(+), 3 deletions(-)`. Consistent with the hook blobs
  pinned in SCOPE (pre-commit 3b741de3…, commit-msg 71029ce8… — hashes re-read from `growth-project-backend/.git/hooks`).
- `CORRECTION_RECEIPT.md` §1-§5 statements (lineage, blob, sha, patch equality, gate timings, bundle hashes, binding hashes,
  fresh paths, loop enumeration) all agree with my independent observations below; nothing claimed there is unsupported.

### 2.3 Bundle v4 (`s7l/bundle/v4/`)

- `sha256sum SHA256SUMS` = `29dcc469dc462453cb581451f25404bd927bdcee6c2cc39f489506eb187495c7`; `sha256sum -c SHA256SUMS` 6/6 OK.
- Thin `s7l-v4-df713fd9217d.bundle`: `git bundle verify` from the worktree → okay, contains `df713fd9 HEAD`, requires
  93389265 (my first verify from the evidence repo reported the missing prerequisite, which is the expected thin-bundle
  behaviour there, not a defect). Full `…-full-history.bundle`: okay, complete history, heads `HEAD` and
  `refs/heads/exec64/s7l-replacement` both df713fd9.
- `s7l-v4-followup-a68cdac70d81-to-df713fd9217d.patch` == `git diff a68cdac7 df713fd9`; cumulative
  `s7l-v4-cumulative-93389265a846-to-df713fd9217d.patch` == `git diff 93389265 df713fd9` (both compared modulo nothing but the
  `index` line normalisation I applied to both sides). `MANIFEST-name-status` = `M\ttest/utils/g2-s7l-worker.cjs`;
  `HEAD-df713fd9217d.txt` fields match §2.1.

### 2.4 Binding v4 (`s7l/binding/v4/`)

- File hashes: `s7l-pg-proof.sh` `8b03f4c247362bc3a255f8490c90e0e8ae546e6c08f89cfb0e3bcbdee0f1fa8f`, `s7l-fixture.sh`
  `74aed2611c9abb507b65697fa1b88834d5e8afe876e12c7d19f1068873e8e751`, `BINDING.sha256` file
  `6c912b961e3df418008e60f61f47566019ffd7f79c6ae1aa29dc6a79d527f52c` — all equal to the parent's pins. `sha256sum -c
  BINDING.sha256` 9/9 OK; `sha256sum -c SUPPLEMENT.sha256` 3/3 OK. `bash -n` on driver and fixture OK. `binding/v4/run/`
  does not exist (no run, no sentinel).
- **My own `diff v3/s7l-pg-proof.sh v4/s7l-pg-proof.sh`** — every hunk classified:
  1. L2-11 header comment (purpose, lineage, sibling-lane note) — comment only.
  2. L27 usage path, L29 `D=…/binding/v4` — versioned paths.
  3. L37-39 `EXPECT_PARENT` 54970cd9→a68cdac7, `EXPECT_HEAD` a68cdac7→df713fd9, `EXPECT_TREE` 6c00e248→796f437f;
     L46 `EXPECT_WORKER_BLOB` a8fed545→155ffdcc; L50 `EXPECT_FIXTURE_SHA` 721468ac→74aed261 — the five pins that must change.
  4. L62-63 `LANE`/`SOCK`/`OLDROOT` proof-v3→proof-v4 — fresh paths (`OLDCLIENT` derived).
  5. L96 placeholder guard now on `EXPECT_WORKER_BLOB` instead of `EXPECT_SPEC_BLOB` (the pin that changed; spec blob is
     unchanged and non-placeholder either way); L97 refusal wording v3→v4.
  6. L102-110 lineage shifted one level: `HEAD^ == EXPECT_PARENT`, `EXPECT_PARENT^{tree} == 6c00e248`, `EXPECT_PARENT^ ==
     54970cd9`, `^^{tree} == 513c71d7`, `^^ == 839b54c5`, `^^^{tree} == f02205c6`, `^^^ == BASE_HEAD` — every literal
     re-derived by me from the worktree and correct.
  7. L112-114 one-path delta `test/utils/g2-s7l-worker.cjs` (was `test/rls-g2-s7l.spec.ts`).
  8. L165 and L215 other-lane loops: `for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/
     clusters/*/`, `[ -d ]` skip (an unmatched glob stays literal and fails `-d`), own lane excluded by `"${d%/}" != "$LANE"`
     (`proof-v4/clusters/s7l/` → equals `$LANE` → skipped; `clusters/s7l`, `proof-v3/clusters/s7l`, `proof-v4/clusters/s8-c`
     → checked), lane label `n=${d#$RUNTIME_ROOT/}` used only inside log strings (slashes harmless). Body of both loops
     (postmaster.pid refusal, conf/pg_control hash capture and equality) unchanged.
  No other line differs: lock handling, fixture calls, bootstrap/identity stages, the single Jest command, stop/post, bounds,
  sentinel and exit codes are byte-identical to v3.
- **`diff v3/s7l-fixture.sh v4/s7l-fixture.sh`**: exactly 3 lines — L12 comment, L27 `LANE=…/proof-v4/clusters/s7l`, L28
  `SOCK=…/proof-v4/run/s7l` (DATA/LOG derive from LANE). Guard regex, port, identities, marker and init/start/stop/destroy
  logic unchanged.
- **Pins re-derived independently** (worktree at df713fd9, runtime root, system): EXPECT_HEAD, EXPECT_TREE, EXPECT_PARENT,
  BASE_HEAD, BASE_TREE (`93389265^{tree}` = a315dd65), all ten `EXPECT_*_BLOB`/`EXPECT_MIGRATION_TREE` (`git rev-parse
  HEAD:<path>`), EXPECT_FIXTURE_SHA, and all ten tool pins (postgres 23cd1748…, initdb b7db9bc2…, pg_ctl af53d826…, psql
  a200e38c…, node a03953a7…, nm lock 05bc530a…, nm client 9042e713…, schema 0eb41f9a…, package-lock b7fed5ed…,
  jest.rls.config 99c9f4f1…) — 26/26 equal. Diff of the `EXPECT_*/BASE_*/PORT/CLUSTER_MARKER/FIX` assignment set v3→v4 shows
  only the five expected pins changed; `EXPECT_SPEC_BLOB` 94e7fac4 and everything else identical. `freeze-v4.log` records
  the same HEAD_PIN_OK ×14 / TOOL_PIN_OK ×10 and FROZEN_V4 line.
- Fresh paths: `recovery-reset/proof-v4/clusters/s7l`, `proof-v4/run/s7l`, `proof-v4/s7l/` are absent (only the sibling
  `proof-v4/clusters/s8-c` and the empty `proof-v4/run` exist). The v4 lane path prefix has no symlink component
  (Phase-1 C1 stays record-only for the bound run).
- Immutability of consumed evidence: `v3/BINDING.sha256 -c` and `v3/run/RUN_FREEZE.sha256 -c` all OK (0 non-OK lines);
  `binding/`, `v2/` not re-checked beyond freeze-v4.log's record (out of the changed question).

### 2.5 Findings (Safety-ROI)

| # | Class | Concrete harm | Exact decision blocked | Minimum closure | Execution unlocked |
|---|---|---|---|---|---|
| — | none A/B | — | — | — | — |

Class C (record only; nothing blocks, no action requested):

- C1 (from Phase 1) un-realpath'd `clientRuntime`: not live for the bound v4 paths; recorded for the harness design history.
- C2/C3 unchanged from Phase 1. C4 closed (prettier changed no byte; committed blob == Phase-1 blob).
- C5: the v4 driver's preflight refuses on any live postgres (`pgrep -cx postgres` = 0) and on any other lane's
  `postmaster.pid`; the sibling S8-C v4 lane exists now, so the S7-L v4 proof must be launched only after S8-C's driver has
  reached its bound stop — which is exactly what PG-4 serialization on the canonical lock provides. No change needed.
- C6: the driver's `finish()` still hashes the log before appending END (known since v1; `RECEIPTS.sha256` log entry =
  file minus last line). Unchanged behaviour, record-only as in the v3 reviews.
- C7: thin bundle verifies only from a repository holding 93389265 (by construction); the full-history bundle is
  self-contained. Both provided; adequate.

### 2.6 Final verdict

**GO.** Head `df713fd9217df524915348ef8a42c797f288dde1` is an ordinary, genuinely hooked, trailer-free Bradley commit whose
only delta from the preserved `a68cdac7` is the agreed minimum closure in `test/utils/g2-s7l-worker.cjs` (blob 155ffdcc),
shown in Phase 1 to be causally sufficient for the v3 L05/L12 failure and inert for the NEW image. Binding v4 (driver
8b03f4c2…, fixture 74aed261…, BINDING.sha256 6c912b96…) differs from the consumed v3 binding only in versioned paths,
the five required pins, the one-level lineage shift, the one-path delta, and the three-glob other-lane enumeration with
own-lane path exclusion; all other pins are byte-identical and re-verified against the live tree and tools. No class A or B
finding. This is a changed-question attestation only: it grants nothing; a single `timeout -k 30 3900 bash
binding/v4/s7l-pg-proof.sh` on the fresh v4 lane remains the parent's separate PG-4 decision after Review B, and a pass
would accept exactly `df713fd9`, nothing else.
