# S7-3′ G2 B/drain — independent T4 source review B (v2 candidate)

Reviewer: independent non-builder reviewer B (parent EXEC-95633079). Read-only against candidate source;
sole writes under `execution/95633079/audits/b-drain-b/**`. Peer-A reports not opened. Nothing installed,
generated, tested, committed, hooked, locked or run against PostgreSQL. This is the SOURCE phase, not final
acceptance. Routing requested "Claude Fable 5 / High"; actual runtime effort is whatever produced this file.

## 0. Identity independently re-derived (not taken from prose)

| Item | Derived | Matches handoff |
|---|---|---|
| Isolated repo HEAD / tree | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` / `87798e742c7b48f56b05e9b5c30efa877180a9b3`, author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no remote, no non-sample hooks, no `node_modules`, index clean, exactly 7 untracked paths | yes |
| Candidate tree | `3739193a5badb104a0aa880a5242ff21e2a98fb0` exists as a tree object; `git diff --name-status 87798e74..3739193a` = 7 × `A`, 1461 insertions, 0 modified accepted files | yes |
| Blob sha1 of the 7 working-tree files (`git hash-object`, no write) | `8c6710e7` down.sql, `55c85906` migration.sql, `bcc06577` cli.ts, `e64d8263` spec.ts, `8493f278` backfill.ts, `c970ab29` rls-g2-b-drain.spec.ts, `09c677fa` g2-b-drain-harness.ts | = `frozen-v2/BLOBS.git-sha1` |
| sha256 of working tree files vs `frozen-v2/SOURCE.sha256` and `frozen-v2/files/**` | all 7 OK | yes |
| O head `925780e0` migration dirs | 164; candidate root tracked dirs 167 (+`20261224` S1 RLS, `+20270117` C1, `+20270118` E) + untracked B = 168 | see B-2 |
| `package.json`/`package-lock.json` O head vs candidate | identical (`git diff --stat` empty) — the accepted bootstrap's shared-`node_modules` precondition holds | n/a |

Accepted C1 base, E, T/Q0, S5 are NOT re-audited here; they are read only where B's semantics depend on them.

## 1. What the source actually does (independently derived)

**Fence migration `20270119000000_scout_ledger_obsolete_writer_fence/migration.sql`.** One explicit
`BEGIN…COMMIT`; `SET LOCAL lock_timeout '5s'`, `statement_timeout '30s'`; ACCESS EXCLUSIVE on both scout
tables (byte-for-byte the E guard discipline). DO-block preconditions: both narrow unique indexes with exact
`pg_get_indexdef` (with `::name` truncation for the 71-char ledger index name), `relkind='r'`, RLS + FORCE,
valid/ready/immediate, no predicate/expression; E column present as `text`, nullable, no default, not
generated/identity, no `pg_constraint` referencing it; trigger and function absent. Creates a plain plpgsql
trigger function (`SET search_path = ''`, not SECURITY DEFINER, `REVOKE ALL FROM PUBLIC`) that raises
`check_violation` when `NEW.source_platform IS NULL`, and a `BEFORE INSERT FOR EACH ROW` trigger. Never
derives/defaults a platform. **`down.sql`**: same index/column guards, requires the exact shipped
`pg_get_triggerdef` and `NOT prosecdef`, drops trigger then function only; refuses when absent. Column,
rows and assigned provenance are retained. No `_prisma_migrations` rewrite (recorded honestly in the spec).

**Backfill `src/scout/scout-ledger-backfill.ts`.** Per chunk one interactive transaction (`maxWait 10s`,
`timeout 45s`): `SET LOCAL` both budgets → `LOCK TABLE "ScoutIngestEntity" IN SHARE MODE` → one SELECT of
NULL-provenance ledger rows `id > $after ORDER BY id LIMIT $batch::int FOR UPDATE SKIP LOCKED` with a
LATERAL exact 4-key (`coach_id,intent_id,entity_type,source_id`) count/`min(source_platform)` against
staging → classify (0 → orphan, >1 → ambiguous, non-canonical → invalid, else resolvable) → one UPDATE …
FROM staging on the resolvable ids only, `AND l.source_platform IS NULL` and the same exact join, written
value = staged value → `updated !== resolvable.length` → `BackfillIntegrityError` (chunk rolled back, run
aborts). Pass = cursor walk from `''` until a short chunk; run = passes until a pass examines 0 or updates
0, stalls on locks (per-chunk retries only for SQLSTATE 55P03/57014 text), or `maxPasses`. Report is
counts only. `drained` requires `nullAfter = 0` AND the exact shipped trigger present and not disabled;
otherwise `complete_unfenced`; NULL remainder equal to last-pass orphan+invalid+ambiguous → `unresolved`;
otherwise `stalled`. Ledger `id` is Prisma `String @id @default(uuid())` → PG `text`, so `id > ''` and
`ORDER BY id` are a consistent total order; the cursor strictly increases → every pass terminates; passes
≤ 10; batch ≤ 2000 (`Prisma.join` parameter count bounded).

**Concurrency/termination facts verified against the accepted T writer (`scout-reconstruct.service.ts`).**
T never writes staging (reads via `findMany`), so B's SHARE lock contends only with staging *writers*
(ingest / maintenance), never with T. B's lock order is always staging-table-then-ledger-rows and it takes
no further lock after the SELECT, so no B↔T deadlock cycle exists (T holds a ledger row → B skips it; B
holds rows → T's claim waits on B and then re-evaluates `p IS NULL OR p = staged.p`, which B has set to the
same staged value → `count = 1`). `LIMIT` sits above `LockRows`, so a short chunk means the unlocked NULL
set is exhausted, not that locked rows consumed the limit; skipped rows are revisited on the next pass
(no one-way high-water mark). Staging narrow unique `(coach_id,intent_id,source_id)` is stricter than the
4-key join → `matches ≤ 1` always; `mismatch` count cannot double-count. Staging `source_platform` is NOT
NULL in the accepted schema; `isCanonicalPlatform` rejects `''`, `null`, uppercase/space tokens, accepts
`unknown` only when literally staged. Populated values are never written (SELECT and UPDATE both require
`IS NULL`); status/target/reason/created_at/payload untouched; no DELETE anywhere.

**O vs T under the fence.** T always INSERTs with `source_platform` (validated canonical before the
transaction) → passes; T's claim/precedence UPDATEs are unfenced. An O image `INSERT`s without the column →
NULL → refused with `check_violation`; O's `retryContention` only retries P2002/P2034 → propagates → 500,
transaction rolled back (no ledger row, no target). Readers untouched. RLS policies untouched; BEFORE ROW
trigger fires before WITH CHECK, both paths refuse.

**Repo gates actually present (verified in tree, not from prose).** `lefthook.yml` pre-commit: `node
scripts/check-r75.js --mode=staged`, `npx tsc --noEmit`, `npx eslint --no-warn-ignored --max-warnings 0
{staged}`, `npx prettier --check {staged}`, `prod-readiness-precheck --quick`; commit-msg: R3 identity-token
scan (the proposed message in handoff §7 contains none). `.github/workflows/r100-quality-gate.yml` states
the 400-LOC and 2.0-density jobs were **retired 2026-09-20**; only banned-cast R75 remains, scoped by
`.github/r75-policy.json` (`src/`, `test/`, `scripts/`, `.ts/.js/.sh`). No live LOC gate exists → no
exemption question arises. `migration-dry-run.yml` on PG 15.18 applies the whole chain then, for each
new dir with `down.sql`, does forward→down→forward with `pg_dump -s` parity: B's down/up recreate
identical trigger/function/comments (OIDs not dumped), so parity is expected. `tsconfig.json` has no
`include` → `tsc --noEmit` type-checks all five TS files under `strict: true`. Default `jest.config.js`
has `src/scout` as a root and ignores `test/rls-*.spec.ts`; `jest.rls.config.js` selects `test/rls-*`.
`prisma/migrations/` is outside ESLint and Prettier. My own lexical scan of the five TS files for every
R75 token class and R45 hostname: 0 hits (not a substitute for `scripts/check-r75.js`).

## 2. Findings

Every A/B carries harm-or-blocked, minimum closure, affected path/proof, execution unlocked.

### B-1 — live proof requests `lockRetries: 0`, library refuses it (proof-invalidating)

- **Evidence.** `scout-ledger-backfill.ts:118-124` `bounded()` throws `RangeError` for `value < 1` and is
  applied to `lockRetries` (`:250`). `test/rls-g2-b-drain.spec.ts:436, 483, 508` call
  `backfill(…, { lockRetries: 0 })`. Stage 6a/6c/6d would throw before any query; the DB-free spec
  (`:291`) tests `-1` but never `0`, so it cannot catch this. The CLI regex (`cli.ts:20`) admits
  `--lock-retries=0` and then fails at run time with the same RangeError.
- **Class.** B (product may well be correct; the concurrency proof cannot execute as written). Not A: no
  customer/data path is affected — the option is only over-restrictive.
- **Why it blocks.** Stage 6 is the only real-PG evidence for SKIP LOCKED, lock-timeout stall and
  staging-writer contention; it cannot run.
- **Minimum closure.** Allow zero retries: give `bounded()` a `min` parameter (default 1) and pass `0` for
  `lockRetries` (2–3 lines in `scout-ledger-backfill.ts`), plus one DB-free assertion that `{ lockRetries: 0 }`
  is accepted and yields exactly one attempt. Alternative test-only closure: use `lockRetries: 1` at the
  three call sites and change the 6d expectation to `lockFailures: 2` — acceptable but leaves the
  CLI/library inconsistency. I recommend the library fix. Same-review delta; no re-audit.
- **Execution unlocked.** Phase A gates on the touched file + DB-free spec; stage 6 of the live proof.

### B-2 — live proof's migration-count and "applies exactly B" assertions are bound to the S5 lane root, not this root (proof-invalidating)

- **Evidence.** Spec asserts fresh bootstrap `164` (`:127`), `165` after E (`:186`), `166` after
  `prisma migrate deploy` from `root` with output containing B and "exactly B" (`:236-242`), `166` again
  in stage 7. The accepted bootstrap deploys the **O root's** 164 dirs. This candidate root carries three
  tracked dirs absent from O: `20261224000000_rls_close_public_exposure` (S1), `20270117000000_durable_import_setup`
  (C1), `20270118000000_scout_ledger_platform_expand` (E). `prismaMigrateDeploy(root)` therefore applies
  S1 + C1 + B (→ 168), or fails on S1/C1 in this fixture; either way `166` and "exactly B" cannot hold.
  (S1's SQL does not touch the four scout tables, so `catalog()` parity is unaffected; the counts are.)
- **Class.** B. The product migration is unchanged; the proof's fixture assumptions are stale relative
  to the composed C1 base. No product harm: on a real E-recorded database that also records S1/C1,
  `migrate deploy` applies exactly B as the handoff says.
- **Why it blocks.** Stage 3 (release-mechanism application) is the promotion-safety evidence.
- **Minimum closure (test/fixture only).** Either (a) the B fixture bootstrap records S1 and C1 before the
  spec (apply their `migration.sql` by file + `migrate resolve --applied`, exactly the path stage 1 uses
  for E) and the spec computes `base = appliedMigrations()` in `beforeAll` and asserts `base+1` after E,
  `base+2` after B, and "exactly B" via `SELECT migration_name FROM _prisma_migrations WHERE finished_at >
  <stage-3 start>` = `[B]`; or (b) the spec itself applies S1 and C1 in stage 1 the same way as E. ~6–10
  changed test lines; no product bytes.
- **Execution unlocked.** Stages 3 and 7 of the live proof; the whole spec becomes runnable on the C1
  lineage.

### B-3 — live proof identity is S5-bound; cannot run on a B identity without a test-only delta (binding, already known to parent — recorded for completeness)

- **Evidence.** `test/rls-g2-b-drain.spec.ts:111` literal `'g2_s5_etq0_disposable'`, `:120`
  `/\/pg17\/clusters\/s5$/`; module-load guard in `test/utils/g2-pg17-harness.ts:22-34` requires
  `G2_PG17_DATABASE_URL/PASSWORD/PSQL/OLD_ROOT/OLD_CLIENT/DATA_DIRECTORY` and `G2_PG17_CONFIRM ===
  'g2_s5_etq0_disposable:<port>'`; markers `s5-disposable-pg17` / `s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop`
  in `g2-pg17-db.ts`; `REFUSED_PORTS` includes `55439` (the retained C1 cluster's port).
- **Class.** B (binding). Minimum closure is the parent's separate B-only fixture/adapter with its own
  database/markers/confirm and the two spec literals redirected to imported constants; no old-guard bypass,
  no S5 reconstruction. Dependencies the proof needs and that do **not** exist in this sandbox today: an O
  checkout at `925780e0` (`G2_PG17_OLD_ROOT`) and a generated **O** client (`G2_PG17_OLD_CLIENT`) — the O
  client requires one `prisma generate` against the O schema (fixture dependency, not the candidate's
  client). PG 17.6 dist, `/usr/bin/psql`, retained stopped `c1-builder` cluster and `s7-c1/node_modules`
  (generated client with `source_platform String?`) are present; 0 postgres processes observed.
- **Execution unlocked.** Phase B run.

### C (record, qualify, continue — none creates a cycle)

- C-1 **Prose vs behaviour: O "updates keep accepted semantics" is not generally true.** Prisma's
  ledger upsert qualifies for native `INSERT … ON CONFLICT DO UPDATE`; PostgreSQL fires BEFORE INSERT row
  triggers for every proposed row *before* conflict resolution, so an O image replaying an already-present
  row is also refused (NEW.source_platform is NULL). This is stricter than handoff §2 claims and is
  desirable (O must be retired); T is unaffected because its proposed row always carries the platform.
  Fix the comment/handoff wording when cheap; stage 4b only tests O on a new row so no assertion is wrong.
- C-2 **Fence bypass surface.** `''` (empty string) passes the fence (`IS NULL` only) — canonical CHECK is
  R's job by design; `session_replication_role = replica` disables `tgenabled='O'` triggers but is SUSET;
  an owner `DISABLE TRIGGER` is detected by `fenced=false`. No action now.
- C-3 **`unresolved` reflects the last pass only**; when the last pass `stalledByLocks` after partial
  chunks, the report can read `stalled` (correct) or, by coincidence, `unresolved` while `stalledByLocks`
  is true in `passes[]`. Outcome never over-claims `drained`; operators should read `passes[]`. Optional
  later: fold `stalledByLocks` into `decideOutcome`.
- C-4 **T contention during a chunk.** B's `FOR UPDATE` holds resolvable rows until commit (ms-scale at
  batch 500); a concurrent T claim waits up to T's own 5 s interactive-transaction ceiling and fails
  closed (row remains, replayable). `LOCK TABLE … SHARE` requires UPDATE/DELETE/TRUNCATE privilege on
  staging for the backfill role (service_role has ALL). Ingest INSERTs into staging block for the chunk
  duration (design intent).
- C-5 **Prisma `timeout 45s` vs statement budgets.** Worst case LOCK 5 s + SELECT 30 s + UPDATE 30 s can
  exceed the 45 s transaction ceiling → P2028 → not matched by `isLockOrStatementTimeout` → propagates →
  exit 1 with no verdict (honest). Fine at default sizes.
- C-6 **CLI diagnostics on database failure print only `err.name`** (identifier hygiene); Prisma code
  (`P2010`) and SQLSTATE from `meta` are identifier-free and would help operators. CLI lives in
  `src/scout/` (ships in `dist/`, guarded by `require.main === module`, not wired to Nest/HTTP); design
  placed it in `scripts/` — parent's call, one-line follow-up outside this grant.
- C-7 **`tsc` items to confirm at the gate (not defects):** `PrismaClient` → `BackfillClient` structural
  assignability at `cli.ts:32` (overload-to-single-signature; method bivariance makes this pass by my
  reading); `$on('query')` typing with inline `log` literal in `g2-b-drain-harness.ts:71-77` (documented
  Prisma pattern). `proconfig` rendering asserted as `search_path=` or `search_path=""` — live run pins.

**No A findings.** Source-product harms considered before deployment: a new pending migration (applied
by any future `migrate deploy`) that refuses on any prerequisite deviation and whose only effect is
refusing NULL-provenance INSERTs; a new operator-invocable writer that can only set NULL cells to the
exact staged value; a CLI not reachable from the app. No tenant, PII, money, deletion or re-status path.

## 3. Verdict

**Product bytes (`migration.sql`, `down.sql`, `scout-ledger-backfill.ts`, `scout-ledger-backfill.cli.ts`):
SOURCE_GRANTABLE** as v2, with B-1's two-line library fix recommended (it may alternatively be closed
test-only). **Proof bytes (`scout-ledger-backfill.spec.ts`, `rls-g2-b-drain.spec.ts`,
`g2-b-drain-harness.ts`): BLOCKED-PROOF (B-1, B-2, B-3)** until the minimal same-review deltas above
exist. None of B-1/B-2/B-3 is an A; none requires redesign, new control, or a new audit track. Re-review
scope after the deltas: the changed lines only.

## 4. Proportionate minimum gate (this reviewer's position)

Phase A, isolated repo: reuse `worktrees/s7-c1/node_modules` (verify `package.json`/lock blob ids equal
C1's and `node_modules/.prisma/client/schema.prisma` == `prisma/schema.prisma`; no `npm ci`/`generate`);
`tsc --noEmit`; `eslint --max-warnings 0` and `prettier --check` on the five TS files; `node
scripts/check-r75.js`; `jest src/scout/scout-ledger-backfill.spec.ts`; then `lefthook install` from the
reused `node_modules` and one ordinary Bradley-authored commit **with the tracked hooks genuinely
executing** — hooks before commit, never after. Pins recorded from the committed head.
Phase B: the B-only fixture (B-3) with B-2's history closure and B-1 fixed, then exactly one
`jest --config jest.rls.config.js test/rls-g2-b-drain.spec.ts --runInBand`; capture `PG17_*` lines. No
S5 reconstruction, no C1 cluster mutation, no predecessor proof replay. Nothing pushes or deploys.
