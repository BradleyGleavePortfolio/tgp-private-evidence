# S11-B r2 — raw-query serialization retry fix (T4 builder report) — EXEC-FA72EFB2

Grant: s11b/S11B_R2_FIX_GRANT.md. Finding: s11b/PROOF_A_V1_FINDING.md (class B). Rules: WORKER_RULES.md.
Clone: /home/user/workspace/worktrees/fa72-s11b, branch fa72/s11b-r1. No push, no PG, no amend, no node_modules writes.
Preserved run evidence (binding/s11-lane-v1/run, post-teardown) untouched.

## Result

| | value |
|---|---|
| Parent (unchanged) | 4d31616f9288402c0cdd6a74fb30b4b15d0658d3 (tree 366efa9f807cf8c1550bfc8a3394b6840f90287b) |
| **New HEAD** | **9149f82381c38cdee8caf9b2b7ff47b2d358ac21** |
| **New tree** | **6a0bc5aa082484805f86457ca2619ef5e4769182** |
| Subject | `fix(scout): retry raw-query serialization failures in the settle tail (S11-B r2)` |
| Author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com> (both); no trailers (checked) |
| refs/remotes/origin/land/s11b | still 4d31616f (nothing pushed) |
| Working tree after commit | clean |

Delta = 2 paths (product 1, test 1); 93 insertions, 10 deletions.

| path | old blob | new blob | sha256 (working tree) | LOC |
|---|---|---|---|---|
| src/scout/lifecycle/lifecycle.service.ts | 974e2c831c1c963c4bf1b68381af48136cf78266 | **a4a79648b911a6099972f80a13f24837e630cbd7** | 8e7db85ccc09f9a8d8ebcb18fe3ce97c0cbcc4b3e936024a08bb2c3fcd931eaf | 1071 |
| test/scout/lifecycle/lifecycle.service.spec.ts | ddc4d2b40c4f7d30c0dcda83dc5b4a22dbd37e1a | **9e8036d753a6cef53e1b4f6d4029279205929338** | cbb0d0b2dd0007f290423ce6709fc85de879ea1423155a6a4c87ae026733ffc8 | 1711 |

The other three S11-B delta paths (scout.service.ts, test/rls-g2-s10c.spec.ts, test/scout/lifecycle/s11b-settle-redrive.spec.ts,
test/scout/s11/settle-redrive.pg.spec.ts) are byte-identical to 4d31616f — binding pins for them stay valid; only the two blobs
above need re-pinning in the new binding version.

## 1. Evidence: how a raw-statement 40001 surfaces in the installed Prisma 6.19.3

Installed runtime (read-only): node_modules/@prisma/client 6.19.3, generated client `.prisma/client/index.js`
"Query Engine version: c2990dca591cba766e3b7ef5d9e8a84796e47ab7", native lib `.prisma/client/libquery_engine-debian-openssl-3.0.x.so.node`
(17,547,808 B). The classification happens in the compiled Rust engine, so the struct shape was confirmed from the engine
source at that exact commit (prisma/prisma-engines @ c2990dca…) and cross-checked against strings in the installed binary.

Chain (engine source @ c2990dca, file:line):
1. `quaint/src/connector/postgres/error.rs` L162-168: SQLSTATE `"40001"` → `ErrorKind::TransactionWriteConflict`, with
   `set_original_code(value.code)` = "40001" and `set_original_message(value.message)`. No `40P01` arm exists in the
   PostgreSQL mapping (grep: 0 hits); 40P01 falls to the default arm L234-242 (`QueryError`, original_code/message still set).
2. `query-engine/connectors/sql-query-connector/src/query_ext.rs` L41-58 `raw_json` (`$queryRaw`) and L60-75 `raw_count`
   (`$executeRaw`) return `Result<_, crate::error::RawError>`; the `??` on `query_raw_typed`/`execute_raw_typed` converts the
   quaint error through `From<quaint::error::Error> for RawError`.
3. `query-engine/connectors/sql-query-connector/src/error.rs` L64-93: that `From` builds
   `RawError::Database { code: e.original_code(), message: e.original_message() }` and only special-cases
   ConnectionClosed / IncorrectNumberOfParameters / UnsupportedColumnType / QueryInvalidInput / ExternalError —
   `TransactionWriteConflict` is NOT special-cased (`_ => default_value`, L91). So the raw path never becomes P2034.
4. Same file L54-57: `RawError::Database` → `SqlError::RawError { code (or "N/A"), message (or "N/A") }`; L289-291 →
   `ConnectorError::from_kind(ErrorKind::RawDatabaseError { code, message })`.
5. `query-engine/connectors/query-connector/src/error.rs` L103-108: `RawDatabaseError` →
   `KnownError::new(user_facing_errors::query_engine::RawQueryFailed { code, message })`.
6. `libs/user-facing-errors/src/query_engine/mod.rs` L133-137: `#[user_facing(code = "P2010", message = "Raw query failed.
   Code: `{code}`. Message: `{message}`")] pub struct RawQueryFailed { pub code: String, pub message: String }` — the
   struct is the serialized `meta`. (P2034 `TransactionWriteConflict {}` is L314-317, empty meta.)
7. JS side, node_modules/@prisma/client/runtime/library.js (minified, one statement per long line):
   L21 col 1220 `class PrismaClientKnownRequestError { code; meta; ... constructor(r,{code,clientVersion,meta,batchRequestIdx}) }`;
   L29 col 16251 `function $r({error:e,user_facing_error:r},t,n){ return r.error_code ? new z(um(r,n),{code:r.error_code,
   clientVersion:t, meta:r.meta, batchRequestIdx:r.batch_request_idx}) : new V(...) }` — meta passed through verbatim;
   L113 col 812 `buildQueryError` calls `$r` for every non-panic engine error; L121 (request handler, itx path) rethrows as
   `new z(l,{code:r.code,...,meta:u})` with `u = r.meta` when no modelName (raw queries have none).
8. Installed binary strings (strings -n 5 on the .so.node): contains the template "Raw query failed. Code: ``. Message: `",
   the variant names `RawQueryFailed`, `RawDatabaseError`, `TransactionWriteConflict`, and the engine hash c2990dca… —
   consistent with the source above.

**Confirmed shape**: `PrismaClientKnownRequestError` with `code === 'P2010'`, `meta === { code: '40001', message: 'could not
serialize access due to concurrent update' }` (message string is PG's primary message via `value.message`), `err.message`
= "Raw query failed. Code: `40001`. Message: `could not serialize access due to concurrent update`". A raw 40P01 arrives the
same way with `meta.code === '40P01'`. This matches the live evidence (HTTP 500 body `{"code":"P2010"}` at spec L353,
pg.log L31-37 `could not serialize access due to concurrent update` on the `FOR NO KEY UPDATE` SELECT) and the existing
in-repo precedent src/workout-builder/workout-builder-autosave.service.ts L838-857 (raw `FOR UPDATE` → P2010, coerced by
SQLSTATE; that code matches the message, this fix keys on `meta.code`, which is the structured field).

Interactive-transaction note: inside `$transaction(fn)` the failed statement's error propagates out of `fn`, Prisma rolls the
itx back, and `settleWithSnapshot`'s catch sees the P2010 — exactly the path J13's loser took.

## 2. Product change (src/scout/lifecycle/lifecycle.service.ts, +23/-10, all in the S9-C settle block)

```ts
  static isSerializationFailure(err: unknown): boolean {
    if (!(err instanceof PrismaClientKnownRequestError)) return false;
    if (err.code === 'P2034') return true;
    if (err.code !== 'P2010') return false;
    const sqlstate = err.meta?.code;
    return sqlstate === '40001' || sqlstate === '40P01';
  }
```
- P2034 behaviour unchanged. P2010 is retryable only when `meta.code` is exactly the string `'40001'` or `'40P01'`
  (`meta?: Record<string, unknown>` per library.d.ts L2628; strict string comparison, so a numeric or missing code is false).
- Doc comments made truthful: the `isSerializationFailure` comment now names both shapes and that the lock and CAS are raw;
  the `settleWithSnapshot` comment no longer says "Prisma P2034" flatly and lists "a second replayed completion settling the
  same run" among the concurrent writers (the S11-B-reachable case). Comment-only rewrap L484-489. No other product change;
  `SETTLE_ATTEMPTS`, `S9_SNAPSHOT_TX_OPTIONS`, lock/CAS SQL untouched. No casts added (R75 hook: "no positive token change").

Full diff: s11b/s11b_r2_fix.diff (sha256 12c020baec5297f0ae9e34d06f48db2680828d0bbfb6b6b6d3d415774fcb7e9a).

## 3. Tests (test/scout/lifecycle/lifecycle.service.spec.ts, +70, inserted after the "non-serialization errors are NOT retried" case, new L872-940)

Helpers `rawFailure(meta)` (P2010, clientVersion 6.19.3, Prisma-shaped message) and `rawSerialization()` (meta.code 40001).
- `S11-B r2: a raw-query serialization failure (P2010, meta.code 40001) IS a serialization failure; other P2010s are not`:
  raw 40001 → true; raw 40P01 → true; raw 23505 / 42501 / 'N/A' → false; P2010 with `meta` undefined → false; `meta: {}` →
  false; `meta.code` numeric 40001 → false; P2002 carrying `meta.code '40001'` → false.
- `S11-B r2: a raw 40001 on the lock (attempt 1) is retried like P2034 — attempt 2 re-locks and its result is returned`:
  `$queryRaw` rejects with the raw 40001 once then returns the open row; asserts 2 `$transaction` calls both with
  `S9_SNAPSHOT_TX_OPTIONS`, 2 lock reads, 1 facts collection, exactly 1 terminal write, 1 settled-basis insert, 1
  SCOUT_RUN_SETTLED event with attempt 2's verdict (partial/unresolved_identities).
- `S11-B r2: a raw failure with another SQLSTATE is NOT retried — one attempt, the P2010 propagates unchanged`
  (regression guard for the "only those two SQLSTATEs" rule: rejects.toBe(same error), 1 transaction, no event).

Mutation check (tests bite): with the product file reverted to HEAD~1 and only the spec changed, `-t "S11-B r2"` → the two
positive cases FAIL, the negative guard passes (2 failed / 1 passed / 74 skipped, RC=1) — s11b_r2_jest_mutant.log. Product
file restored byte-identical (sha256 8e7db85c… before and after).

Existing C-9 P2034 tests were left as they are (still valid: the P2034 branch is unchanged). Note (C): the comment in the
existing case at spec L801-802 ("PG raises 40001 at the terminal UPDATE … Prisma surfaces it as P2034") describes the raw
`writeTerminal` UPDATE, which per §1 would actually arrive as P2010; the test's mechanics are correct for the typed-query
shape. Not edited (scope); the reviewer may want it reworded in a later pass.

## 4. Read-only P2034 scan of src/scout (report only — C)

`rg -n "P2034|P2010|40001|40P01" src/scout` (non-spec): exactly ONE other catch keys on P2034:

- **src/scout/scout-reconstruct.service.ts L671-674 `isContention`** (`['P2002','P2034'].includes(err.code)`), used by
  `retryContention` L653-667 around the per-row `$transaction`s at L474 (persist + ledger) and L549 (ledger-only). Raw
  statement inside: yes — the §3.1 gate `assertRunOpen` (lifecycle.service.ts L651-661, `tx.$queryRaw` UPDATE … RETURNING)
  runs first via `gateRun` L376-380. Can it raise 40001 there? Those transactions take no `isolationLevel`, so they run at
  PostgreSQL's default READ COMMITTED (the L599-602 comment relies on that: "Under ReadCommitted a waiting writer rechecks the
  predicate"). READ COMMITTED does not raise serialization_failure on row-lock contention, so a raw 40001 is not reachable
  there; a raw 40P01 deadlock is the only theoretical raw shape and would arrive as P2010 → not retried → propagates (the
  gate is deliberately an UPDATE lock so writers serialize instead of deadlocking, L645-647). Also, since quaint maps only
  40001 to TransactionWriteConflict for PostgreSQL (§1 step 1), the P2034 arm is effectively inert in a READ COMMITTED
  lane; the live arm is P2002. Classification C: the S9-C REPEATABLE-READ root cause does not apply; no change made.
- Other raw statements in src/scout, none behind a P2034 catch: scout.service.ts L395 `$executeRaw` phase flip (READ
  COMMITTED claim tx; caught only for P2002 at L409 — the S11-B re-drive branch); lifecycle.service.ts L386 fence CAS
  (`$executeRaw`, own short tx); L672 `isSettlePending` SELECT (no lock); induction/observation.service.ts L325 `FOR NO KEY
  UPDATE` lock (default isolation, catch at L342 is not P2034-keyed); scout-ledger-backfill.ts L140-166 (operator script,
  explicit LOCK TABLE, not a request path). None runs under REPEATABLE READ; none needs the r2 classification.
- Outside src/scout (context only, not audited): workout-builder-autosave.service.ts already handles the P2010+SQLSTATE
  shape (L856); live-create.shared.ts L71, workout-builder.service.ts L1232, sub-coach-reassign.service.ts L227 and
  scheduling-session-lifecycle.service.ts L151/L341 key on P2034 only — out of this grant's scope.

## 5. Commands run (all heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`, PROOF_SLOT_FREE present each time; never two at once; no `flock -n`)

| # | command (cwd worktrees/fa72-s11b) | RC |
|---|---|---|
| 1 | `prettier --check src/scout/lifecycle/lifecycle.service.ts test/scout/lifecycle/lifecycle.service.spec.ts` (prettier 3.9.9 from runtime/tools, under flock) | 0 |
| 2 | `NODE_OPTIONS=--max-old-space-size=3072 ./node_modules/.bin/eslint <2 files>` (under flock) — s11b_r2_eslint.log (empty = clean) | 0 |
| 3 | `NODE_OPTIONS=… ./node_modules/.bin/jest --runInBand --ci test/scout/lifecycle/lifecycle.service.spec.ts test/scout/lifecycle/s11b-settle-redrive.spec.ts` (under flock) — **2 suites passed, 88/88 tests** (lifecycle 11.4 s) — s11b_r2_jest.log | 0 |
| 4 | mutation check: product file at HEAD~1, `jest --runInBand --ci lifecycle.service.spec.ts -t "S11-B r2"` (under flock) — 2 failed / 1 passed as expected; file restored — s11b_r2_jest_mutant.log | 1 (expected) |
| 5 | `git add <2 files>; git commit -F s11b_r2_commit_msg.txt` under flock, through lefthook 2.1.9: pre-commit prod-readiness-quick ✔ 0.01 s, banned-cast-tokens ✔ 0.55 s (R75 "no positive token change"), eslint ✔ 4.12 s, prettier ✔ 5.21 s, **tsc ✔ 51.67 s**; commit-msg no-ai-tokens ✔ — s11b_r2_commit.log | 0 |
| — | first commit attempt (same command, backgrounded with `&` inside the tool call) was killed with the tool call before tsc finished: HEAD unchanged, index intact, lock released, no partial state; rerun detached with `setsid nohup` = row 5 | n/a |

Not run (parent-only): any `*.pg.spec.ts`, rls-g2-*, bootstrap, initdb/pg_ctl, npm install, prisma generate.
Read-only network reads: raw.githubusercontent.com prisma/prisma-engines @ c2990dca (5 source files) — evidence only.

## 6. Files written (evidence namespace, not git-committed — parent commits)

- s11b/s11b_r2_fix.md (this report)
- s11b/s11b_r2_fix.diff — 12c020baec5297f0ae9e34d06f48db2680828d0bbfb6b6b6d3d415774fcb7e9a
- s11b/s11b_r2_commit_msg.txt — 69e3eaf5b51382c5b452367943b7174241b53785a35f95753815a97fb7b485bb
- s11b/s11b_r2_commit.log (ANSI-stripped) — a5bba503f2335029072e295baf802ecc3e8d7a5041dc4fa24fb93a92251ee398
- s11b/s11b_r2_eslint.log — 3e080ca1fd6a655ea1924636ed9107ea3cdf9b3c1196729c805d82462d832797
- s11b/s11b_r2_jest.log — fa9be00ff90636a343060e24da2acef82592a77e61e7aee714a21733f2dff679
- s11b/s11b_r2_jest_mutant.log — e551662e929a4e069a3dd2adc626e197b4c763c2f241707411737072650c2934

## 7. Open risks / notes for the T4 delta review and the new binding

- (C) The fix is proven at unit level with a mocked `$queryRaw`; the real shape is established from engine source at the
  installed engine commit plus the live pg.log/HTTP evidence, not by running PG here (grant: no PG). The new S11-lane run
  on 9149f823 is the binding proof that J13 now retries (expected: loser re-locks, sees the winner's terminal, returns
  null, acks 200).
- (C) Retry budget: a raw 40001 on attempt 1 followed by a raw 40001 on attempt 2 and 3 still rethrows the P2010
  (bounded by `SETTLE_ATTEMPTS = 3`, unchanged); that is the documented exhaustion contract, now applied uniformly.
- (C) quaint maps only 40001 for PostgreSQL; a typed-query 40P01 would not be P2034 either (it would be a QueryError
  shape). Accepting raw `40P01` is therefore defensive and matches the grant; nothing in the settle tail is expected to
  deadlock (single-row lock, one writer order).
- (C) Binding update needed: re-pin the two changed blobs (a4a79648, 9e8036d7), HEAD 9149f823, tree 6a0bc5aa; the
  s11b-settle-redrive.spec.ts and settle-redrive.pg.spec.ts pins are unchanged; expected unit count for
  lifecycle.service.spec.ts grows by 3 (88 total across the two touched suites).
