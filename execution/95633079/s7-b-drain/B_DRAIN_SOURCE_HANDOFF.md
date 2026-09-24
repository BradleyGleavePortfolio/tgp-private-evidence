# S7-3′ G2 B/drain — frozen source packet and handoff

Builder: S7 B/drain builder (separate G2 T4 builder) under parent EXEC-95633079. Grant: SOURCE-ONLY.
Nothing was installed, generated, built, tested, committed, run against PostgreSQL, or sent remotely.
Two independent reviews are expected before the parent grants the minimum runtime below.

## 1. Base and freeze

| Item | Value |
|---|---|
| Isolated repo | `/home/user/workspace/worktrees/s7-b-drain` (cloned from local accepted `worktrees/s7-c1`; no remote, no hooks, no `node_modules`; see `00-source-recovery-receipt.md`) |
| Base commit (C1 accepted) | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |
| Base tree | `87798e742c7b48f56b05e9b5c30efa877180a9b3` |
| Staged tree, **v1** (as authored, temp index, no commit) | `be80087c154ffca0d1d82713892913883c819d9a` — preserved under `frozen/` |
| Staged tree, **v2 = review candidate** (after parent-granted format-only pass) | `3739193a5badb104a0aa880a5242ff21e2a98fb0` — `frozen-v2/` (see `frozen-v2/FORMAT_FREEZE_NOTE.md`) |
| Diff | v1 `frozen/b-drain.diff` (1443 insertions); v2 `frozen-v2/b-drain.v2.diff` (1461 insertions; +18 lines are Prettier line breaks only) — 7 new files, 0 deletions, 0 modified accepted files |
| Blob sha1s / file sha256s | v1 `frozen/BLOBS.git-sha1`, `frozen/SOURCE.sha256`, copies `frozen/files/`; v2 `frozen-v2/BLOBS.git-sha1`, `frozen-v2/SOURCE.sha256`, copies `frozen-v2/files/`. Five blobs identical between v1 and v2; only `test/rls-g2-b-drain.spec.ts` and `test/utils/g2-b-drain-harness.ts` changed (format-only diffs in `frozen-v2/format-only.*.diff`) |
| Working tree after freeze | 7 untracked paths only; index restored (`git reset`) |

Files (all new; nothing under shared `prisma/schema.prisma`, generator, `package.json`, hooks or CI):

```
prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/migration.sql   (92 lines)
prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql        (64)
src/scout/scout-ledger-backfill.ts        bounded resumable backfill + drain verdict  (289)
src/scout/scout-ledger-backfill.cli.ts    operator entry, JSON report, exit codes      (58)
src/scout/scout-ledger-backfill.spec.ts   DB-free control-flow proof (default jest)   (312)
test/rls-g2-b-drain.spec.ts               real-PG17 proof, guarded lane only          (569 after format)
test/utils/g2-b-drain-harness.ts          B helpers layered on the accepted harness   (79 after format)
```

Untouched by construction: accepted E migration and its down, T writer (`scout-reconstruct.service.ts`),
readers, `scout-platform.ts` (only imported), `test/utils/g2-pg17-*`, both narrow unique indexes, RLS
policies, `_prisma_migrations` semantics. `git diff --stat` shows only additions.

## 2. What B does (bounded operational semantics)

**Fence (migration `20270119000000_scout_ledger_obsolete_writer_fence`)**

- One transaction; `lock_timeout 5s`, `statement_timeout 30s`; ACCESS EXCLUSIVE on both tables (same
  discipline as E). Guard DO block: both narrow unique indexes exactly as E requires (identical
  `pg_get_indexdef` match, RLS FORCE), E column present as nullable `text` with no default/constraint,
  fence trigger and function absent. Any deviation raises `G2-B …` and the whole file fails atomically.
- Creates `public.scout_ledger_platform_fence()` (plpgsql, `SET search_path = ''`, not SECURITY DEFINER,
  `REVOKE ALL … FROM PUBLIC`) and `BEFORE INSERT FOR EACH ROW` trigger
  `"ScoutReconstructionLedger_platform_fence"` that raises `check_violation`
  `G2-B obsolete writer fenced: ScoutReconstructionLedger.source_platform is required` when
  `NEW.source_platform IS NULL`. It refuses; it never derives, defaults or substitutes a platform.
- **Insert-only on purpose.** UPDATEs are not fenced, so the accepted T path (upsert whose update
  branch is `{}` on an existing NULL legacy row, followed by the transactional claim
  `WHERE p IS NULL OR p = staged.p`) and O's updates of already-present rows keep their accepted
  semantics. What the fence stops is the harmful thing: a restarted O image or a direct maintenance
  writer *re-creating* NULL-provenance rows after the sweep. NOT NULL / a CHECK stays with R.
- `down.sql`: same prerequisite guards, requires the exact shipped `pg_get_triggerdef`, drops trigger
  and function only; column, rows and every assigned provenance value remain. Refuses when the fence
  is absent (`G2-B fence absent`). Comment states that down voids drain evidence.

**Backfill (`backfillLedgerPlatform(prisma, {batch, maxPasses, lockRetries})`)**

- Resolves ONLY an exact `coach_id, intent_id, entity_type, source_id` match with exactly one staging
  row whose `source_platform` is canonical (`isCanonicalPlatform`; `unknown` is canonical only when
  literally staged). Zero matches → `orphan`; >1 → `ambiguous` (not constructible under the narrow
  staging unique, still counted); non-canonical → `invalid`. None of these are written.
- Writes NULL provenance only, from a second join to staging under the same SHARE lock (the written
  value is the staged value, never a client-side copy). Populated values are never overwritten; a
  populated value that disagrees with staging is reported as `mismatch`.
- Chunk = one interactive transaction (`timeout 45 s`, `maxWait 10 s`): `SET LOCAL lock_timeout '5s'`,
  `SET LOCAL statement_timeout '30s'`, `LOCK TABLE "ScoutIngestEntity" IN SHARE MODE`, then
  `… WHERE source_platform IS NULL AND id > $after ORDER BY id LIMIT $batch::int FOR UPDATE SKIP LOCKED`
  with a LATERAL exact-match count, then one id-bounded `UPDATE … WHERE l.id IN (…) AND
  l.source_platform IS NULL AND <exact match>`. Update count ≠ resolvable count →
  `BackfillIntegrityError`, chunk rolled back, run aborts.
- Pass = cursor walk (`after` = last id of the previous chunk; a short chunk ends the pass). Run =
  passes until a pass examines nothing or updates nothing, is stalled by locks, or `maxPasses`
  (default 3, max 10). Lock/statement timeouts (SQLSTATE 55P03/57014 in Prisma's P2010 message) are
  retried per chunk up to `lockRetries` (default 2), then the pass is `stalledByLocks`. Any other
  database error propagates unchanged.
- Report (counts only, no ids/payloads/platform strings): `ledgerTotal, nullBefore, nullAfter,
  mismatch, fenced, passes[], unresolved{orphan,invalid,ambiguous}, outcome`.
  `fenced` = exact shipped triggerdef present and enabled.
  Outcome: `nullAfter = 0` → `drained` if fenced else `complete_unfenced`; `nullAfter` equals the
  explained remainder → `unresolved`; otherwise (locked/unprocessed rows) → `stalled`.
- Zero updated with NULL remaining is STOP, never completion; there is no high-water mark, so a
  rerun is always safe and idempotent. Defaults: batch 500 (max 2000).

**CLI (`src/scout/scout-ledger-backfill.cli.ts`)** — `npx ts-node src/scout/scout-ledger-backfill.cli.ts
[--batch=N] [--passes=N] [--lock-retries=N]` with `DATABASE_URL` as the runtime (service) role; one JSON
line to stdout; exit 0 `drained`, 4 `complete_unfenced`, 2 `unresolved`, 3 `stalled`, 1 error/usage.
Guarded by `require.main === module`; not registered in any Nest module or HTTP route.

## 3. Promotion and compatibility

- Separate release artifact from E/T and from R/N/C. Prisma orders it after E by timestamp
  (`20270119…` > `20270118…`); `prisma migrate deploy` on an E-recorded database applies exactly B.
- Entry gate (operator-owned, not provable in source): T is the only deployed ledger writer image and
  no O image is restart-eligible. Applying the fence while O still runs makes every new O
  reconstruction fail closed (500, no row, no target) — that is the fence's purpose, so it must
  follow the T cutover, not precede it.
- Compatible with: T create (always with provenance), T claim of legacy NULL rows (UPDATE), O/T
  readers (no read path touched), anon/authenticated policy denial (unchanged; for a NULL row from
  an API role the BEFORE trigger answers first — either way refused), the E down (which refuses
  after any claim regardless of B), `prisma migrate resolve`.
- Order of operations for the drain: (1) T rolled out and O retired; (2) backfill runs →
  `complete_unfenced`; (3) B deployed → fence; (4) final backfill run → `drained` (the durable
  evidence R's NOT NULL / widening will consume); (5) `unresolved` classes go to provenance
  recovery at the staging source of truth (re-stage / correct token), never to ledger edits or
  deletions — then rerun. R may later retire the fence when its own constraint supersedes it.
- A **local `drained` verdict is a property of the disposable fixture only**; it is not a claim
  that any real deployed or restart-eligible old writer has been drained. No live action is proposed
  by this packet.

## 4. Proof scope (new behaviour only; accepted proofs not rerun)

`src/scout/scout-ledger-backfill.spec.ts` (default jest, DB-free): classification incl. `unknown`
and empty/null tokens; outcome table; exit codes; timeout recognition; chunk cursor and pass
termination with a rule-following in-memory ledger (statement shapes, 4/5 chunk transactions, 3
updates, idempotent rerun); `complete_unfenced`; skip-locked → stalled → drained; bounded lock
retries, non-timeout propagation; integrity refusal with rollback; option bounds before any query;
CLI argument parsing.

`test/rls-g2-b-drain.spec.ts` (guarded PG17 lane, `--runInBand`, fresh S5-shaped bootstrap: 164
migrations, no E): stage 1 O on narrow (400) → E (via accepted file + `migrate resolve`) → O on E
(30 NULL) + T on i2; stage 2 backfill without fence → `complete_unfenced`, staged values exactly,
other columns/staging byte-identical, then an O restart re-creates a NULL row; stage 3 B via
`prisma migrate deploy` (166), catalog unchanged, fence shape/ACL/search_path, raw rerun refused;
stage 4 direct and runtime-role NULL inserts refused, actual O binary 500 with no row/target, O
readers fine, API roles denied, T creates + claims a re-opened NULL row, replay identical; stage 5
1238 NULL rows (1230 resolvable, 2 erased + 2 cross-tenant + 1 wrong-family orphans, 3 invalid) with
2 mismatching and 10 claimed rows untouched → passes `[3,1238,1230]`,`[1,8,0]`, `unresolved`, 4
SKIP LOCKED selects / 3 UPDATEs, idempotent rerun, forward staging recovery → `drained`; stage 6
row lock skipped → stalled → drained, T paused at `staged` and at `claimed`, staging writer →
observed lock wait → lock_timeout → nothing written; stage 7 down keeps column/rows/history,
NULL admitted again, rerun down refused, up restores identical fence.

Not claimed: live `ambiguous` construction (impossible under the narrow staging unique; unit-tested
only), any production drain, R/N/C behaviour, re-proof of E/T-Q0 or C1.

## 5. Review questions and known risks (for the two independent reviews)

1. **Insert-only trigger vs `CHECK … NOT VALID`.** Chosen because an UPDATE-time check would have
   to be verified against Prisma's no-op `update: {}` upsert shape on NULL rows in T; unverifiable
   under a source-only grant. Reviewers may prefer the CHECK; the migration is small either way.
2. **Trigger execution privilege.** EXECUTE is checked at `CREATE TRIGGER` time, not at fire time,
   so `REVOKE ALL FROM PUBLIC` is safe; stage 4 proves it live for `service_role` (a wrong
   assumption would surface as `permission denied`, not as the fence message).
3. **Prisma typing.** `BackfillClient` is a structural subset (`$transaction`, `$queryRaw`,
   `$executeRaw`); `PrismaClient` should satisfy it under `tsc` (overload-to-single-signature
   assignability). If `tsc` disagrees at `scout-ledger-backfill.cli.ts:31`, the fix is a
   `Pick<PrismaClient, …>`-based alias — report before editing.
4. **Prisma raw parameter typing.** `LIMIT ${batch}::int` casts the bound number; `id > ${after}`
   binds text. `pg_get_triggerdef(oid) = ${FENCE_TRIGGER_DEFINITION}` compares text.
5. **`proconfig` rendering** of `SET search_path = ''` is asserted as `search_path=` or
   `search_path=""` (PostgreSQL quotes the empty value); the live run pins which.
6. **Formatting — closed.** Under the parent's format-only grant the five TS files were checked with
   the approved external Prettier 3.9.6 (`prettier.cjs` sha256 `6e922134…7906e` verified first, repo
   `.prettierrc`, non-blocking lock `execution/test-validation.lock` acquired/released per call).
   Three `src/scout` files already conformed; two `test/` files were reflowed (38 + 8 changed lines,
   whitespace-only; token stream identical). `--check` now passes on all five. Migration SQL is
   outside Prettier/ESLint scope (`.prettierignore` excludes `prisma/migrations/`). R75 banned-token
   self-scan with the repo's own patterns: 0 hits (not the repo script).
7. **CLI location.** The historical design placed operator scripts under `scripts/`; that path and
   `package.json` are outside this grant, so the entry lives in `src/scout/`. If the parent wants
   `scripts/` or an npm script, that is a one-line follow-up outside `src/scout/**`.
8. **Order dependence in stage 6c.** All 20 i3 rows are re-opened so the row T locks first is
   guaranteed to be among the candidates whatever T's processing order.
9. **Replay identity in stage 4** compares full ledger rows before/after T's replay; the ledger has
   `created_at` only (no `updated_at`), and the accepted etq0 spec makes the same `allLedger()`
   equality claim, so the assertion is sound.

## 6. Minimum runtime proposal (parent-granted later; NOT executed; only the format slot has run)

Corrected to the parent's execution constraints. Two separate phases; source review does not wait
on phase B preparation.

**Phase A — repo gate + DB-free spec (isolated repo only)**
1. Dependencies: reuse an isolated copy of the accepted C1 `node_modules` (same unchanged
   `package.json`/`package-lock.json`/`schema.prisma`, generated client included) — no `npm ci`, no
   `prisma generate`. Verify input pins first (package/lock blob ids equal C1's; generated
   `node_modules/.prisma/client/schema.prisma` matches `prisma/schema.prisma`).
2. Actual repo gate as the tracked hooks run it: `tsc --noEmit -p tsconfig.json`; `eslint
   --max-warnings 0` on the five TS files; `prettier --check` (already green with the approved
   3.9.6); `node scripts/check-r75.js`. The historical 400-LOC/density gate is retired in this repo
   (`.github` R75 policy only); if a reviewer finds an actual live LOC gate, decompose legitimately —
   no exclusions or workarounds.
3. `jest src/scout/scout-ledger-backfill.spec.ts` (default config, DB-free).
4. Genuine hooks: install the repo's tracked Lefthook hooks (`lefthook install` from the reused
   `node_modules`), then an ordinary Bradley-authored commit in the isolated repo (message §7).
   No commit is proposed without real tracked hooks executing.

**Phase B — real-PG binding (separate prepared review phase, no full source re-audit)**
5. PostgreSQL 17.6 dist and `/usr/bin/psql` are already recovered; nothing is downloaded or set up
   again. The accepted S5 cluster stays ABSENT; the retained stopped C1 cluster stays untouched.
6. A **uniquely named B disposable cluster/database/port** is created for this proof. Accepted
   bootstrap/helper bytes may be reused as fixture dependencies only. The current guard/harness
   (`test/utils/g2-pg17-db.ts` / `g2-pg17-harness.ts`) binds the S5 identity (database
   `g2_s5_etq0_disposable`, S5 cluster/database markers, `G2_PG17_CONFIRM`), and the new spec
   inherits that identity gate; therefore a **minimum B-only fixture/adapter variant** (own
   database name, markers and confirm literal; same guard shape) will be proposed in that phase —
   not a bypass of the old guard, and not a reconstruction of the S5 runtime or of the fresh51 /
   E/T-Q0 / C1 proofs.
7. Then one run: `jest --config jest.rls.config.js test/rls-g2-b-drain.spec.ts --runInBand`, output
   (`PG17_*` counts/shapes only) captured under `execution/95633079/s7-b-drain/runtime/`.
   Necessary B fixture setup (O legacy rows on narrow/E, E application, T rows) is fixture
   dependency, not a repeat of predecessor assertions; the spec asserts only B-new behaviour.

Nothing here pushes, merges, deploys, touches live accounts, or spends.

## 7. Proposed commit message (ordinary, Bradley-authored)

```
scout: fence obsolete ledger writers and backfill NULL provenance (G2-B)

Adds the B stage of the ledger provenance repair between the accepted E/T
rollout and the later R widening.

- 20270119000000_scout_ledger_obsolete_writer_fence: BEFORE INSERT trigger
  on ScoutReconstructionLedger refusing rows without source_platform, with
  the same identity/RLS prerequisites and lock budgets as E; down removes
  only the fence and refuses when it is absent.
- scout-ledger-backfill: bounded, resumable, idempotent backfill of NULL
  source_platform from the exact staging match (one canonical row only),
  SHARE lock on staging per chunk, FOR UPDATE SKIP LOCKED cursor, never
  overwrites populated values, reports orphan/invalid/ambiguous/mismatch
  counts and a drained / complete_unfenced / unresolved / stalled verdict.
- CLI entry with exit codes for operators; DB-free control-flow spec.
- rls-g2-b-drain live proof on the PG17 lane: fence vs O/T/RLS, deploy,
  refusal, down/up, bounded fixture, concurrency.

Both narrow unique indexes and the accepted E/T behaviour are unchanged.
```

Author/committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>` (repo-local config already set;
no trailers).

## 8. Safety ROI (owner doctrine)

- A (product affected, local consequence counts before any deployment): the packet adds one
  migration, one library module, one CLI entry and specs to the product tree. Local consequences:
  a new pending migration in `prisma/migrations` (applied by any future `migrate deploy`), a new
  operator-invocable writer of the ledger's `source_platform` column, and a new trigger that
  changes INSERT behaviour for every ledger writer once applied. Mitigations are in the artifact:
  the migration refuses on any prerequisite deviation and is separately promotable; the backfill
  writes only NULL cells from the exact staging row and never deletes or re-statuses; the CLI is
  not wired into any module or route.
- B (proof affected): new proof is confined to two new spec files and one helper; no accepted proof
  is edited or rerun.
- Concrete harm prevented: silent re-creation of NULL provenance by a stray old writer after the
  sweep, which would make R's NOT NULL either fail or be applied on false evidence.
- Blocked decision unlocked: whether R may proceed — decided by a `drained` verdict with the fence
  present, not by a count at a moment in time.
- Minimum closure: two reviews → the runtime steps above → commit in the isolated repo. No extra
  cycle is requested.
