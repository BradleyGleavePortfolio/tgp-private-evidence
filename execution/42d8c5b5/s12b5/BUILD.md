# S12-B5 BUILD report (EXEC-42D8C5B5, T2, builder claude_sonnet_5_0)

## Scope

`execution/fa72efb2/s12/S12_PILOT_READINESS.md` §2b row S12-B5 (owner question 8):
one read-only SQL/TS script querying `pg_policies` / `pg_class.relrowsecurity` /
`relforcerowsecurity` for `WorkoutSession`, `WeightLog`, `Habit`, `CheckIn`,
`ClientWorkoutAssignment*`, emitting an explicit expected-vs-actual verdict per
table; transaction `READ ONLY`; no DDL/DML; documented invocation for Bradley.
Written and reviewed — **not run against production**.

## What was built

`scripts/check-rls-catalog.ts` in the backend repo. One `git commit`, one file
added (`scripts/check-rls-catalog.ts`, 360 lines) plus a `scripts/README.md`
inventory-row edit.

Before writing the script I audited `prisma/migrations/**` with `rg` for
`ALTER TABLE "<table>" ENABLE ROW LEVEL SECURITY` for each of the six tables
in scope (`ClientWorkoutAssignment*` expanded to both
`ClientWorkoutAssignment` and `ClientWorkoutAssignmentSnapshot`, since the
readiness doc's `*` covers the snapshot child table). Result:

| Table | RLS migration on file? | Where |
|---|---|---|
| `WorkoutSession` | **No** — never enabled in any migration (only its child `ExerciseSet` has RLS) | — |
| `WeightLog` | **No** — never enabled in any migration | — |
| `Habit` | **No** — never enabled in any migration (only its child `HabitLog` has RLS) | — |
| `CheckIn` | Yes, `ENABLE`+`FORCE` + policies | `20260607000000_rls_remaining_gaps` |
| `ClientWorkoutAssignment` | Yes, `ENABLE`+`FORCE` + policies | `20260508000001_rls_workout_builder`, fixed through `20260702000000_fix_workout_rls_coach_role` |
| `ClientWorkoutAssignmentSnapshot` | Yes, `ENABLE`+`FORCE` + policies | `20261215000000_mwb_1_data_model` |

This is the exact shape of the gap owner question 8 exists to close: three
person-owned health/fitness tables with no RLS migration in history at all.
The script's `EXPECTED_STATE` table encodes this static finding as the
*expected* verdict per table, but every printed verdict is computed from the
actual `pg_class`/`pg_policies` read inside the transaction — never assumed —
so a real out-of-band change in either direction (someone enabled RLS on
`WorkoutSession` outside a migration; or a policy got dropped from `CheckIn`)
shows up as a mismatch instead of silent agreement.

Script behavior:
- Single `prisma.$transaction` interactive callback; issues
  `SET TRANSACTION READ ONLY` as defense-in-depth on top of the fact every
  statement is a `SELECT`; always rolls back (throws a private
  `ReadOnlyRollback` marker at the end) — nothing is ever committed.
- Two `$queryRawUnsafe` reads: `pg_class` joined to `pg_namespace` for
  `relrowsecurity`/`relforcerowsecurity`, and `pg_policies` for per-policy
  rows (name, cmd, roles), both filtered to `schemaname/nspname='public'`
  and `tablename/relname = ANY($1::text[])` against the six target tables.
- No DDL, no DML, no `SET ROLE`, no repair logic.
- No default `DATABASE_URL` — refuses to run (exit 2) if unset, so it can
  never fall through to a stray production connection string left in the
  shell environment.
- Exit codes: `0` every table matches expected state; `1` at least one
  mismatch; `2` connection/query error (fails closed — a failed read is
  never reported as "0 gaps").
- Full invocation, safety notes, and the "for Bradley" instructions are in
  the file's header docblock (not duplicated in the source of truth here).

## Head / tree / pushed ref

- Clone: `/home/user/workspace/worktrees/x42-s12b5`, branch `x42/s12b5`, from
  base `419a756da4e6eebc28e22b19d0c08d72549f6d4e` (matches GRANT.md).
- Commit: `fdd19af4843459887e00148e2ad8c81716288258`
  (tree `ece4f29daee2dae1daa0c0e7eef51e5c5d804437`), author/committer
  `Bradley Gleave <bradley@bradleytgpcoaching.com>` through the installed
  lefthook hooks (no `--no-verify`, no AI/co-author trailer).
- Pushed: `git push preserve HEAD:refs/heads/cand/x42/s12b5` →
  `fdd19af4843459887e00148e2ad8c81716288258` (verified with
  `git ls-remote preserve refs/heads/cand/x42/s12b5`, exact match). RC=0.
- `node_modules`: `cp -al` from `worktrees/x42-donor` (its
  `rt-setup.sentinel` read `RC=0 STAGE=done` before the copy), then
  `./node_modules/.bin/lefthook install` (RC=0).

## LOC

- `scripts/check-rls-catalog.ts`: 360 lines added (all new file — no
  production/test split; this is a standalone operator script, same class
  as `scripts/smoke.ts` / `scripts/bootstrap-owners.ts`).
- `scripts/README.md`: +1 inventory row (net +15/-7 lines per `git show
  --stat`, mostly line-wrap of the existing table).
- Total: 368 insertions, 7 deletions across 2 files.

## Gates / validation, with RC

All heavy commands ran under the canonical lock
(`flock -w 3600 /home/user/workspace/execution/test-validation.lock`) per
WORKER_RULES §5, launched with `nohup setsid … &` and polled (the shared lock
was under very heavy multi-worker contention throughout this build; each
heavy command queued 15–30 minutes before acquiring it).

| Gate | Command | RC |
|---|---|---|
| Prettier | `prettier --check scripts/check-rls-catalog.ts scripts/README.md` | 0 |
| ESLint | `npx eslint --no-warn-ignored --max-warnings 0 scripts/check-rls-catalog.ts` | 0 |
| tsc | `NODE_OPTIONS=--max-old-space-size=3072 npx tsc --noEmit` | 0 |
| R75 banned-cast (pre-commit hook, staged mode) | `node scripts/check-r75.js --mode=staged` | 0 |
| lefthook pre-commit (prod-readiness-quick, banned-cast-tokens, eslint, prettier, tsc) | via `git commit` | all ✔️ |
| lefthook commit-msg (no-ai-tokens) | via `git commit` | ✔️ |
| Dry-run: no `DATABASE_URL` | `npx ts-node scripts/check-rls-catalog.ts` (unset) | 2 (fails closed, as documented) |
| Dry-run: unreachable `DATABASE_URL` | `DATABASE_URL=postgresql://…@127.0.0.1:54329/nonexistent?connect_timeout=3 npx ts-node scripts/check-rls-catalog.ts` | 2 (fails closed on `P1001`, as documented) |
| **Local-PG catalog proof (grant-specified)** | `migrate deploy` + script run against a throwaway local PG | **NOT RUN — see Deviations** |

First `tsc --noEmit` attempt (before `NODE_OPTIONS` was set in that
particular invocation) OOM'd (RC=134, heap limit) — re-ran with
`NODE_OPTIONS=--max-old-space-size=3072` per WORKER_RULES §5 and it passed
in ~95s inside the lefthook run.

First commit attempt failed the `banned-cast-tokens` (R75) pre-commit hook:
two `TARGET_TABLES as unknown as string[]` casts were a net-positive change
in the banned `as unknown as` token class. Fixed by building one
`TARGET_TABLE_NAMES: string[] = [...TARGET_TABLES]` plain array instead of
casting the readonly tuple at each `$queryRawUnsafe` call site — zero
`as unknown as` tokens in the final file, `banned-cast-tokens` reported
"OK — no positive token change" on the successful commit.

## Deviations

1. **Local-PG validation (grant requirement) was not performed by this
   builder.** GRANT.md asks the builder to "Validate on a throwaway local PG
   from the runtime (migrate deploy at base) under the lock and record the
   output." WORKER_RULES.md §5 states plainly: "Real-PG lanes, initdb,
   pg_ctl, `*.pg.spec.ts` and `rls-g2-*` live runs are PARENT-ONLY." Standing
   up a throwaway local PG requires `initdb`/`pg_ctl` from
   `execution/42d8c5b5/runtime/pg17/dist/bin`, which is explicitly
   parent-only. WORKER_RULES.md is binding on every builder/reviewer this
   parent dispatches and I take it as the controlling instruction where the
   two documents conflict, so I did not run `initdb`/`pg_ctl` myself and did
   not run the migrate-deploy-then-script proof against a live cluster.
   In its place I ran two no-DB dry-run behavior checks confirming the
   script's own fail-closed contract (see gates table): exit 2 with no
   `DATABASE_URL`, and exit 2 (`P1001`, "failing closed") against an
   unreachable connection string. I did **not** verify the PASS/GAP verdict
   logic against a real catalog with actual `pg_class`/`pg_policies` rows —
   that requires the parent (or the S12-B5 T3 reviewer, if the review grant
   permits real-PG lanes) to run `prisma migrate deploy` at base against a
   throwaway PG17 instance and then this script, and record the output.
2. Table naming: the readiness doc writes `ClientWorkoutAssignment*` with a
   trailing wildcard. I read that as covering exactly
   `ClientWorkoutAssignment` and `ClientWorkoutAssignmentSnapshot` (its only
   child table with an `assignment_id` FK) and listed both explicitly in
   `TARGET_TABLES` rather than have the SQL layer interpret a wildcard,
   since Postgres `pg_class`/`pg_policies` have no native prefix-match
   convenience for this without a fragile `LIKE` on `relname` that could
   silently match an unrelated future table starting with the same prefix.
3. Used `PrismaClient` + `$queryRawUnsafe`/`$transaction`, matching this
   repo's existing script convention (`scripts/bootstrap-owners.ts`,
   `scripts/export-openapi.ts`) rather than adding a direct `pg` dependency,
   which is not in `package.json`.

## Risks

- **The gap this script exists to catch is real in the migration history**,
  not hypothetical: `WorkoutSession`, `WeightLog`, and `Habit` have no RLS
  migration on file today. If production's actual catalog matches the
  migration history (most likely, since nothing suggests out-of-band DDL),
  running this script against production will report GAP for those three
  tables — that is a class-A finding per S12_PILOT_READINESS.md §5 (item
  referencing "MINIMUM CLOSURE: owner item 13 plus S12-B5") and should route
  to S8-D3, not to a quick fix from whoever runs it.
- Because the local-PG proof did not run (see Deviations §1), the verdict
  computation itself (join logic, `ANY($1::text[])` parameter binding,
  PASS/GAP classification) is validated by type-checking and by the two
  no-DB dry runs only — not by an actual catalog read with real
  `relrowsecurity`/`pg_policies` rows. There is a residual (believed low)
  risk of a query-shape bug (e.g. a param-binding mismatch, or a
  `pg_policies.roles` array-type surprise in `$queryRawUnsafe`'s row
  mapping) that would only surface on a real run. This should be caught by
  the T3 review or the parent-run local-PG proof before this script is ever
  pointed at production.
- The script intentionally has no default `DATABASE_URL` and no retry/loop;
  it is a single manual invocation. If Bradley runs it against production
  per §4 item 13's recommendation, the output should be captured into
  evidence exactly as the readiness doc specifies, and any GAP verdict
  treated as class A per the finding above.
