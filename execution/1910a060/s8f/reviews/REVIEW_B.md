# S8-F independent review B (REV-F1, reviewer `s8_c_review_b`) — source + binding v1

Written 2026-09-25 ~14:20 PT by the T4 independent non-builder reviewer B. Read-only review; sole write is this file
(no git commit). Reviewer A's report was NOT read. This is a review verdict, not acceptance and not proof: the historical
33/33 gate receipt was not rerun, no PG runtime exists in this environment, and nothing below claims the PG proof result.

Owner context honoured: 14:08 PT OWNER CONTINUATION RESET (absent old runtime = environment recovery dependency, not an
owner blocker; fresh binding prepared by a new T4 runtime worker retaining v1; exact S8-F reuse, no rebuild) and 14:14 PT
note (RT-NEW-1 may stand up a NEW PG17.6 environment; binding v2 re-pins runtime artifacts; v1 stays immutable; judge v1
as the logic/controls template and separate environment-specific pins from logic defects).

## 0. Candidate identity (verified from the checkpoint, not from a live worktree)

| Item | Value | How verified here |
| --- | --- | --- |
| Candidate head / tree | `e1ec2fecb71f315b6721d426ba0dacb84f304498` / `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6` | `checkpoints/v1/HEAD.txt`, `BLOBS.txt`; `git bundle verify s8f-e1ec2fec.bundle` OK (requires 1c10e2a1, present locally). Head commit object itself is NOT in the local partial clone, so head == tree binding rests on the checkpoint + bundle, not on `git rev-parse`. |
| Base | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`, tree `aa160557…` | Local `main` HEAD; `rev-parse 1c10e2a1^{tree}` == PINS `BASE_TREE`. |
| Changed paths | 17 (6 src, 10 test, 1 contract artifact); 5 new files | patch headers == `BLOBS.txt` == runner allow-list regex. |
| Head blobs | all 17 `files/<path>` blobs == `BLOBS.txt` via `git hash-object`; bootstrap mode 100755 | done earlier this session; `MANIFEST.sha256` 21/21 OK. |
| Accepted-file pins at base (PINS.txt) | `jest.rls.config.js` 44c96915, `prisma/schema.prisma` 2e328bbc, `scripts/ci/supabase-shim.sql` 0f99f924, `src/scout/reconstruct/native` tree dfd8ef66, `test/rls-g2-s8c.spec.ts` 9d701783, `g2-s8c-bootstrap.sh` 7c3fba47, `g2-s8c-db.ts` a7d67217, `g2-tq0-worker.cjs` aa35e7e2 | all equal `git ls-tree 1c10e2a1` locally (tree objects are local; blobs are not). Whether they are unchanged AT THE HEAD is asserted by the patch (no diff hunks for them) and would be re-checked by the runner at run time. |
| Migrations | 172 tracked dirs at base | `git ls-tree 1c10e2a1 prisma/migrations/` → 172 trees (+4 non-dir files). Patch touches no `prisma/` path. |
| S8-B migration in base history | `20270122000000_scout_native_provenance_expand` blob 0e026270 | equals the evidence copy under `execution/ce3748cb/s8b/phase1-snapshot` (hash-object match), so the CHECK names and RLS the spec asserts were read from the exact committed SQL. |
| Base schema | blob 2e328bbc | equals `execution/64e33dc7/s7l/checkpoints/draft-0*/files/prisma/schema.prisma` (hash-object match) — used for the NOT NULL / enum audit below. |
| Binding v1 | `BINDING.sha256` 7/7 OK; 7 `__FILL_AFTER_COMMIT__` fills == HEAD/BLOBS values; `EXPECT_FIXTURE_SHA` == sha256 of `s8f-fixture.sh` | `sha256sum -c`, `unfilled-to-filled.diff` inspected. |

Not verified here (no head object, no runtime): the commit went through lefthook hooks (gate log claims `hook_lines=8`);
`jest.rls.config.js` content (44c96915 not local; S8-C's accepted proof used the same config with the same
`test/rls-g2-*.spec.ts` path shape); `g2-tq0-worker.cjs` full content (aa35e7e2 confirmed as the post-S5-R3 blob via the
S5-R3 delta patch; its `entities|roster` actions with `coach/family/cursor/limit` options are confirmed only through the
accepted N/Q1 and S8-B specs that call it that way).

## 1. Source review (all 17 paths read in full: head files under `checkpoints/v1/files/` + the complete 2335-line patch)

### 1.1 `src/scout/scout-entities.service.ts` (+dto, +controller)
- Dispatch on ledger `target_kind` via `effectiveKind`: NULL/`scout_entity` → unchanged generic join (re-asserts `coach_id`
  AND `entity_type`); `workout_plan`/`workout_program` → same-coach `archived_at: null` native row AND same-coach
  `ImportNativeProvenance` row with matching `(native_kind, native_id)` and outcome ∈ {created, already_present}; typed kind
  with NULL `target_id`, `person`, or unknown kind → dropped without any native read. Fail-closed on every branch; no
  `import_intent_id` predicate; all three joins carry the explicit `coach_id` fence (the runtime role is BYPASSRLS, so the
  application predicate is the tenancy control — present everywhere).
- Consistent with the accepted S8-C writer (read at `execution/64e33dc7/s8c/checkpoint/src/scout/reconstruct/native/*`):
  the writer records `created` provenance keyed `(native_kind, plan.id|program.id)`, replays as `already_present`, treats
  archived/other-tenant targets as `unresolved`, writes `owner_user_id = coachId, visibility = 'owner_only'`, and for
  client-linked workouts falls back to `scout_entity` with an `unresolved` workout_plan provenance row (native_id NULL) —
  exactly the case the reader's F05 tests exclude. The `ImportNativeProvenance` `@@index([coach_id, native_kind, native_id])`
  at base makes the provenance query index-aligned.
- Everything runs inside the existing RepeatableRead `$transaction`; cursor stays ledger-anchored; `page_count` keeps its
  "size of this page" meaning; analytics remain counts-only (unit test asserts no names/ids leak).
- Response: additive `target_kind` (closed 3-value enum, no `person`) + nullable `native_id`; native rows use the LEDGER's
  `(source_platform, source_id)`, `label = native.name`, `client_source_id = null`, `entity_type = family`. Banned fields
  (`coach_id`, `owner_user_id`, `payload`, `visibility`, `email`) asserted absent.

### 1.2 `src/scout/scout-roster.service.ts` (+dto, +controller)
- Person join restricted to rows with `target_kind === null || 'person'`; typed non-person rows never reach `person.findMany`
  even when `target_id` equals a Person id (unit test proves the lookup id list). Accounting stays ledger truth; cursor
  anchored to all ledger rows. `roster_bridge_pending: true` constant (`ROSTER_BRIDGE_PENDING`) at response level on every
  page including empty; no per-row flag; no principal minted; S8-D/E principal policy left owner-reserved.

### 1.3 Contract artifact + contract specs
- `docs/contracts/importer-openapi.json`: `ReconstructedEntityDto` adds `target_kind` (enum) and `native_id` (nullable,
  `format: uuid`) to `required`; roster result adds `roster_bridge_pending` to `required`; descriptions updated; version
  string unchanged `2.0.0-c1-s2.0`; paths 15→15, schemas 36→36 (`gates/contract-semantic-check.json`). Regen was recorded
  deterministic (two regen logs). `importer-contract.spec.ts` frozen property list updated to the 10 names.

### 1.4 Unit/fake specs (entities service, entities contract, roster service, roster controller)
- FakePrisma gains real predicate semantics for `workoutPlan`/`workoutProgram`/`importNativeProvenance` (`id IN`, `coach_id`,
  `archived_at IS NULL`, `outcome IN`, `OR` over `(native_kind, native_id IN)`), so F01–F09/F11 are behavioural, not
  pre-decided. F03 now runs unconditionally on `programs` (S8-C added the family). Coverage of the readiness matrix is
  complete for what fakes can prove; cross-tenant provenance, unresolved provenance, kind/table mismatch, archived paging,
  NULL target with typed kind, unknown/person kind, analytics leakage and the 404 gate are each asserted.

### 1.5 New PG proof files (`test/rls-g2-s8f.spec.ts`, `g2-s8f-pg-harness.ts`, `g2-s8f-db.ts`, `g2-s8f-bootstrap.sh`, `g2-s8f-db-guard.spec.ts`)
- Guard: literal substitution of the S8-B guard; new identity (`g2_s8f_disposable`, `s8f_super`, markers
  `s8f-disposable-pg17` / `s8f-g2-native-reader-synthetic-disposable-fixture-safe-to-drop`), refused-port set extended
  with 55511/55641/55642, double-entry confirmation, loopback only, password only via env; login-role matrix
  {s8f_super, postgres, service_role}. Markers are literals; the db-guard spec asserts the bootstrap carries them verbatim
  and not via `${}` expansion. `55643` in the guard spec is an example port (not refused) and matches the binding lane.
- Bootstrap: reduction of S8-B's (no OLD side, no subcommand). Order is safe: identity (17.x exact version, loopback,
  superuser, cluster marker, no hosted-platform roles) BEFORE any write; fixture role matrix; create DB once with marker
  comment; refuses a same-named DB without the exact marker; refuses a non-empty `public`; verbatim CI shim; `prisma
  migrate deploy` of the whole tracked history as `postgres`; asserts `applied == tracked` and the S8-B catalog shape
  (`ImportNativeProvenance` table, `ScoutReconstructionLedger.target_kind`); requires a pre-generated candidate client
  containing `model ImportNativeProvenance` (no install/generate). Refuses uncommitted `prisma/` changes.
- Harness: psql via `execFileSync` with `PGPASSWORD` only; seeding as non-superuser BYPASSRLS `postgres`; readers run in
  a forked OS process through the unchanged `g2-tq0-worker.cjs` as `service_role` with the candidate client; worker log
  prints shapes/outcomes only. `resetData()` deletes only the seven synthetic tables it seeds.
- NOT NULL / enum audit (done independently against schema blob 2e328bbc): every raw INSERT supplies all NOT NULL
  no-default columns — User(id, supabase_id, email, name; `role='coach'` ∈ enum Role), ScoutImport(id, coach_id,
  intent_id; state/terminal_status explicit), Ledger(id gen_random_uuid(), coach_id, intent_id, entity_type, source_id,
  source_platform, status; created_at default), ScoutReconstructedEntity(all incl. created_at/updated_at),
  WorkoutPlan(id, coach_id, name, `type='strength'` ∈ WorkoutPlanType, created_at, updated_at — `@updatedAt` has no DB
  default, supplied), WorkoutProgram(id, coach_id, owner_user_id, name, weeks, days_per_week, created_at, updated_at),
  ImportNativeProvenance(id, coach_id, source_namespace, entity_type, source_id, native_kind, outcome; created_at default;
  `reason` supplied when unresolved), Person(id, coach_id, source_platform, source_person_id; state default). Provenance
  identity key `(coach_id, source_namespace, entity_type, source_id)` is unique per stage seed. COMMIT_READY's "no change
  needed" conclusion is confirmed.
- Spec stages: stage 0 identity (DB, version, cluster marker, DB comment, port, S8-B shape, RLS enabled on WorkoutPlan /
  WorkoutProgram / ImportNativeProvenance); stage 1 F01/F02/F04 with lexical ledger order `w-cross < w-legacy < w-plan <
  w-prog < w-typed-evidence` (C.UTF-8 collation from initdb; ordering claim checked), cross-tenant pointer dropped, other
  coach sees nothing, API-role denial via `SET ROLE` (0 rows or permission denied, on seeded tables so 0 is meaningful);
  stage 2 F05 denials + the three S8-B CHECK names (`ImportNativeProvenance_native_id_shape_check`,
  `ImportNativeProvenance_native_kind_check`, `ScoutReconstructionLedger_target_kind_shape_check` — all exist verbatim in
  the committed migration 0e026270); stage 3 F07 archived paging across three pages with limit 2 (page arithmetic checked)
  and un-archive reappearance; stage 4 F10 roster qualifier, kind fence, and the uniform 404 for both readers including the
  other coach. Counts are intent-scoped page counts after `resetData()`; no absolute table counts.

### 1.6 Findings

No A-class finding. No B-class finding. The following are C (record and continue; none blocks source or proof):

- C1 — Contract version unchanged (`2.0.0-c1-s2.0`) while two `ReconstructedEntityDto` properties and one roster property
  become `required`. Additive for consumers; stricter only for producers of the DTO (server-side). Version policy and the
  generator live outside the S8-F surface; owner/generator decision, deferred as COMMIT_READY states.
- C2 — Provenance vouching is per `(coach_id, native_kind, native_id)`, not per this ledger row's `(source_platform,
  source_id, entity_type)`. Any same-coach qualifying provenance for that native id serves the row, even if it was produced
  by a different import/source of the same coach. No cross-tenant path (coach fence on ledger, native table and provenance);
  the writer's own `verifyTarget` is similarly id-keyed. Tightening (add `source_namespace = row.source_platform`,
  `entity_type = family`, `source_id = row.source_id` to the provenance predicate) is a possible later hardening, not a
  defect against the readiness matrix.
- C3 — WorkoutProgram `visibility` / `owner_user_id` are not consulted; the reader relies on `coach_id` + import provenance.
  The S8-C writer sets `owner_user_id = coachId, visibility = 'owner_only'`, so served programs are import-created and
  owner-scoped in practice. Record for the S8-D/E principal design (owner-reserved), no change requested here.
- C4 — `native_id`/`id` carry OpenAPI `format: uuid`; Prisma ids default to `uuid()` but the columns are free `String`, and
  the PG fixture seeds non-uuid ids. Descriptive only (no runtime validation); harmless.
- C5 — A page can be empty with `next_cursor != null` when every ledger row on it is dropped (already true for erased rows
  pre-S8-F; typed/archived rows make it likelier). Consumers must continue paging until `next_cursor` is null; the contract
  text says dropped rows are dropped "from the page" but does not spell out the empty-page-with-cursor case. Documentation
  nuance, not a behaviour defect.
- C6 — The bootstrap's client-shape precheck greps only `model ImportNativeProvenance `; a client generated from a
  schema that has provenance but lacks `ScoutReconstructionLedger.target_kind` would pass the grep and fail later inside
  jest (fail-closed anyway). Adding a `target_kind` grep would fail earlier. Cosmetic.

SOURCE VERDICT (B): the S8-F source at e1ec2fec on base 1c10e2a1 is coherent with the accepted S8-B schema/CHECKs and the
accepted S8-C writer semantics, fail-closed on every non-qualifying path, tenancy-fenced by explicit predicates on all
joins, additive on the wire, and its prepared PG proof (spec + harness + bootstrap + guard) is internally consistent with
the base schema and migration history. No blocking finding. This is a source review verdict; it does not assert the PG
proof outcome and does not restate or rerun the 33/33 gate.

## 2. Binding v1 review (`execution/64e33dc7/s8f/binding/v1/`; not run; judged as the template per the 14:14 note)

### 2.1 Logic and controls (template-worthy; carry into v2 unchanged in substance)
- Single canonical nonblocking `flock -n` on fd 9 (append-open, never deleted) before any state change, held to exit;
  once-only sentinel; `set -uo pipefail` with explicit rc handling at every stage; first nonzero stops; bounded
  `timeout -k 30` on every external stage; failure path attempts one bounded stop only if this run started the postmaster;
  data dir retained; header honestly states cleanup is not guaranteed if the outer timeout kills bash.
- Candidate identity: placeholder refusal; HEAD/tree/base-tree pins; base is ancestor AND `HEAD^ == BASE` (exactly one
  commit); five S8-F proof-file blob pins (+ unchanged worker blob) — all equal the checkpoint; bootstrap mode 100755; clean
  worktree, no MERGE_HEAD; `prisma/` tree identical to base; seven accepted-file blob pins (all equal base here); delta is
  exactly 17 paths AND every path matches the S8-F allow-list regex (regex checked against the 17 paths — all match).
- Environment isolation: node_modules must be a real in-worktree copy; `npm_config_offline`, `GIT_NO_LAZY_FETCH=1`,
  `CHECKPOINT_DISABLE=1`; only `G2_S8F_*` exported (no S8-C/S8-B/S7-L names); fresh lane only (lane dir absent, socket dir
  empty, port free, zero `postgres` processes); every other lane under `clusters/*` and `proof-*/clusters/*` (own lane
  excluded by exact path compare) hashed pre and post and checked for no `postmaster.pid`.
- Run: committed bootstrap without subcommand; identity stage re-checks data_directory, 170006, cluster marker, DB marker,
  applied == 172; the one jest invocation `--config jest.rls.config.js test/rls-g2-s8f.spec.ts --runInBand --ci`, no
  `--forceExit`/`--testTimeout`/retry; bounded fast stop; post checks (other lanes unchanged, worktree porcelain sha and HEAD
  unchanged, generated client unchanged); `RECEIPTS.sha256` + sentinel with rc/stage/head/lock inode.
- Fixture helper: lock-free by design, refuses standalone use unless `S8F_RUNNER_PID` is a live `s8f-pg-proof.sh`; fresh
  init only; marker-gated start/destroy; refuses data path inside `pg17/dist` or `/home/user/pg17`; `destroy` never
  discards a stop failure and refuses while any process references the data dir; loopback only, `cluster_name` literal
  equals the guard marker; `9>&-` so children never inherit the lock fd.

### 2.2 Environment-specific pins (to be re-pinned explicitly in v2; NOT logic defects)
`RUNTIME_ROOT` (`/home/user/workspace/execution/64e33dc7/recovery-reset`) and everything derived from it (`DIST`, `LANE`,
`SOCK`, `CLUSTERS`, `npm-cache`, `xdg-cache`, `pg17/PROVENANCE.txt` `result=success` check); worktree `W`
(`worktrees/daceddc8-s8f`, branch `exec-dace/s8f`); `LOCK` path and the recorded inode 674373; `EXPECT_POSTGRES_SHA`,
`EXPECT_INITDB_SHA`, `EXPECT_PGCTL_SHA` (17.6 build), `EXPECT_PSQL_SHA` (18.6 client), `EXPECT_NODE_SHA` (v20.20.1);
donor `EXPECT_NM_LOCK_SHA`, `EXPECT_NM_CLIENT_SHA` (9042e713), `EXPECT_NM_CLIENT_SCHEMA_SHA` (b8439203); the "other lanes
today" list in PINS.txt (proof-v4/{s7l,s8-c}, proof-v5/s8-c); `tool-pins-reverify.txt` (all ten hashes were taken against
the predecessor environment and are informational only for a new one). Port 55643 / DB / admin / markers are lane logic
tied to the committed guard and db-guard example — keep them unless the new environment already occupies 55643 (then the
committed guard still accepts any non-refused loopback port, but the db-guard spec's example and PINS must move together).
Repo-content pins that are NOT environment-specific and must stay identical in v2: all head/tree/blob pins, `BASE_HEAD`,
`BASE_TREE`, `EXPECT_SCHEMA_SHA` (0eb41f9a… = blob 2e328bbc), `EXPECT_PKG_LOCK_SHA`, `EXPECT_MIGRATIONS=172`, the seven
accepted-file blob pins, `EXPECT_FIXTURE_SHA` (recomputed if the fixture text changes for the new root).

### 2.3 Logic gaps in v1 (C; suggested v2 improvements; none blocks)
- CB1 — `EXPECT_PSQL_SHA` hashes `readlink -f /usr/bin/psql`, which on Debian is `/usr/share/postgresql-common/pg_wrapper`
  (a dispatcher script), not the psql binary that actually runs; the real client version is only logged, never asserted.
  v2: pin the version-specific binary (e.g. `/usr/lib/postgresql/<N>/bin/psql`) or the PG17 dist psql, and assert
  `psql --version` major.
- CB2 — Generated-client ↔ schema correspondence is established only by donor sha pins; a byte difference from
  `prisma/schema.prisma` is downgraded to a NOTE. The readers depend on the client knowing `target_kind`, `archived_at`,
  `importNativeProvenance`. v2 (which must build its own client anyway): record the generation receipt (schema blob
  2e328bbc → client) and add a `target_kind` grep alongside the bootstrap's `ImportNativeProvenance` grep (see C6).
- CB3 — The "hooked commit" check only proves lefthook hooks are installed in the worktree now, not that e1ec2fec was
  produced through them; the gate log (`COMMIT rc=0 hook_lines=8`) is the actual evidence. Keep the check, but v2's
  README should cite the gate log rather than imply the runner proves it.
- CB4 — Fixture password `s8f_local_synthetic` is a literal in both binding files (synthetic, disposable, loopback-only;
  consistent with accepted S5/S8-B/S8-C shape). Acceptable; note only.
- CB5 — `GUARD_REFUSAL_OBSERVED_IN_JEST_LOG` greps message fragments that do not all match the S8-F guard's actual error
  strings (`S8-F G2 proof requires…` matches `G2 proof requires`; the others are S8-B/S8-C-era phrases). Informational
  only since a nonzero jest rc fails the run regardless.

BINDING EXECUTABILITY VERDICT (B): v1 is NOT executable in this environment — the runtime root, worktree, donor
node_modules, PG17 dist and lock file it pins are absent here — which per the 14:08/14:14 owner mails is an environment
recovery dependency, not a candidate or owner blocker. As a template, v1's control logic (lock, once-only, pins, one-commit
and 17-path allow-list, fresh-lane isolation, other-lane hashing, bounded stages, single jest run, retained data dir, post
checks) is sound and should be carried into v2 with only the §2.2 pins re-recorded and the §2.3 items considered. v1 must
stay immutable (BINDING.sha256 verified 7/7). The separate dual review of v2 before any proof is the right place to check
the new pins against the new environment; nothing in v1's logic requires a source change to e1ec2fec.

## 3. Boundaries of this review
Read-only; no branch change, fetch, unbundle, gate rerun, test, hook, PG, install, lock or remote mutation. Base blobs are
not in the local partial clone; base content for modified paths was taken from the patch, and the exact base schema and
S8-B migration from evidence copies whose `git hash-object` equals the base tree entries. Reviewer A's report not read.
