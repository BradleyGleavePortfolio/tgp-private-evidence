# S8-C independent review B — V3: changed-question re-review of `87018a42` + `binding/v3`

Reviewer: independent S8-C reviewer B (T4 high). Authority: `S8C_INDEPENDENT_REVIEW_GRANT.md`; scope narrowed by `S8C_REVIEW_MINIMUM_CORRECTION_GRANT.md` (amended 05:16Z) to the closures, new lineage/gates and versioned binding only; `S8C_GATE_SEQUENCE_DISPOSITION.md` (05:25Z) included. Written 2026-09-25 ~05:30Z. `REVIEW_B.md` (initial report on `527fe2bc` bound to `af9f7f54`/v2) is immutable and not modified; this file supersedes only its §5 decision.

Method: read-only `git cat-file`/`rev-parse`/`diff`/`show`/`git grep` on `worktrees/64e33dc7-s8c`, `sha256sum`/`sha256sum -c` on evidence. No product/Git/runtime writes, no install/compile/test/lock/PG/push, no peer report read, no sub-delegation. Unchanged bytes from the initial review were not re-audited.

## 1. Identity and pins (all recomputed)

| Item | Claimed | Recomputed | Match |
|---|---|---|---|
| HEAD | `87018a421f5be1064767d2cdd32e75ca935f7cdb` | `git cat-file -t` commit; worktree HEAD; branch `exec64/s8c-replacement`; porcelain 0 | yes |
| Tree / parent | `cec7d05a91876ec3f6badb1020bb97aacdb9331d` / `af9f7f54…` | `^{tree}`, `^` | yes |
| Author/committer | Bradley Gleave `<bradley@bradleytgpcoaching.com>` | `git log --format`; no trailer-like body lines | yes |
| Delta from `af9f7f54` | exactly 7 paths, +147/−27 | `git diff --stat`: `native-contract.ts` 8, `native-provenance.ts` 3, `native-rules.ts` 6, `native-writers.ts` 21, `test/rls-g2-s8c.spec.ts` 33, `native-rules.spec.ts` 5, `native-writers.spec.ts` 98 = 147/27 | yes; patch sha `addcc2a3…` equals `review-correction/run/delta-from-af9f7f54.7path.patch` |
| Untouched surfaces | `prisma/`, `src/scout/reconstruct/sources/` = base; `docs/` = 527fe2bc | `git diff --quiet` | yes |
| Proof blobs | spec `9fc44a2b…` → `dc804fdef00757732a7e75eeb13dcd30d1920cb4`; bootstrap `8aa86de8`, db `a7d67217`, pg-harness `4059883d`, harness `d5cbf877`, worker `48403063` unchanged | `git rev-parse` at af9f7f54 and 87018a42 | yes |
| 11 base-file pins (driver L100-105) | g2-s8b-* blobs, migration dir `94c4d201`, schema `32e44110`, sources tree `a1a296ee`, `jest.rls.config.js` `44c96915` | each `git rev-parse HEAD:<path>` == pin | 11/11 OK |
| v3 driver `binding/v3/s8c-pg-proof.sh` | `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8` | sha256sum | yes |
| v2→v3 driver delta | exactly four lines | `diff ../v2/s8c-pg-proof.sh s8c-pg-proof.sh`: L23 `D=…/binding/v3`, L31 `EXPECT_HEAD`, L32 `EXPECT_TREE`, L33 `EXPECT_SPEC_BLOB` | yes; nothing else |
| v3 manifest | `BINDING.sha256` file `ede987a6536f35103f978d97690e45ed84d58c196615560561fbef3d9f7514ec` | sha256sum; `sha256sum -c` 7/7 OK (`s8c-pg-proof.sh.v2` = `038d6af6…` and byte-identical to `v2/s8c-pg-proof.sh`; diff `c409ab3e…`; fixture `1a7faa5f…`; PINS `316dd121…`; PINS diff `563930aa…`; README `a90b1aea…`) | yes |
| v3 PINS delta | 3 pins + 2 path strings | `PINS.txt.diff-v2-to-v3` read: header path, `EXPECT_HEAD/TREE/SPEC_BLOB`, `RECEIPTS=` path | yes |
| Old bindings | v1, v2 untouched | `sha256sum -c` v1 7/7, v2 7/7 | yes |
| Nine tool pins | as `FINAL_PINS_527fe2bc.txt` | unchanged lines in v3 driver L41-49; recomputed against live binaries in the initial review, all matched | yes |
| Checkpoints | v5 `MANIFEST.sha256`; v3, v4 untouched | v5 5/5 OK; `HEAD.txt` head/tree/parent/author/spec-blob agree; v4 5/5, v3 5/5 | yes |
| Gate receipts | `review-correction/run/RECEIPTS.sha256` 15 files | `sha256sum -c` 15/15 OK | yes |

## 2. Changed questions — closures reviewed against the frozen contract

### B1 (REVIEW_B) — failed target verification on the evidence path — CLOSED
`native-writers.ts` L373-384: in `persistEvidence`, when `recordNoNativePrincipal` and existing provenance is not `unresolved`, `verifyTarget` is called and `if (!verified.ok) return verified;` precedes the evidence upsert and `recordUnresolved`. `verifyTarget` (L66-88, unchanged) yields `unresolved:identity_conflict` for kind mismatch / null native_id / foreign coach and `unresolved:native_target_removed` for missing or archived target, so §3.5 (contract L215) is honoured with both reasons retained; the `PersistOutcome` failure shape (`persist-outcome.ts` L31) is returned unchanged. Successful replay path is the same `ok(targetId, workout_plan, countUnresolvedChildren)`; the new-client-linked evidence path (no existing provenance or existing unresolved) is untouched.
Regression `native-writers.spec.ts` L481-521: archive → `native_target_removed` with calls exactly `['importNativeProvenance.findUnique','workoutPlan.findUnique']`; delete → `native_target_removed`; foreign coach → `identity_conflict`; wrong kind → `identity_conflict`; `entities.size` 0, `plans.size` 1, every provenance row equal to the post-create snapshot except the test's own kind mutation, and no `upsert|update|create` call. Precondition of `recordUnresolved` (native-provenance.ts L90-92) is now actually guaranteed by the caller.

### B2 (REVIEW_B) — `enum_unmapped` — CLOSED
`native-contract.ts` L45 adds only `enum_unmapped` to `UNRESOLVED_CODE` and L63 to `QUALIFIED`; `native-rules.ts` L329-333: present key absent from `rule.map` → `unresolved(enum_unmapped, field)`; mapped destination outside `allowed` → `invalid(field)`; non-string/number raw (L326) and absent/default (L321-325) branches untouched. Matches contract L295/L397. `native-rules.spec.ts` L322-330: `kind:'yoga'` → `unresolved:enum_unmapped:type`; added `kind:{not:'a key'}` → `unresolved:invalid_value:type`. No other unused contract codes added (`unit_unknown`, `date_zone_unknown`, `no_native_destination` remain out of scope as granted).

### A-review B1 — child provenance namespace (§3.3) — CLOSED, source correction as chosen by parent
Contract L175 (`entity_type = <family>.<child>`, e.g. `workouts.exercise`) and L432. `native-contract.ts` L40 `CHILD_ENTITY_TYPE.workouts_exercise = 'workouts.exercise'` (constant only; `NATIVE_FAMILY`, DTO and registry unchanged). `native-writers.ts` L288-292 child key `{...provenance, entityType: CHILD_ENTITY_TYPE.workouts_exercise, sourceId: child.childSourceId}` used by all three child writes (L295, L302, L316; `git grep` shows no other child-key construction). `native-provenance.ts` L120 `countUnresolvedChildren` filters `entity_type = workouts.exercise` while retaining coach, namespace, `startsWith(childSourceIdPrefix)`, `native_kind = workout_plan_exercise`, `outcome = unresolved`. Key and count filter move together, so a top-level `workouts` row whose arbitrary `source_id` equals an encoded child id now differs in `entity_type` under the unique key `(coach_id, source_namespace, entity_type, source_id)` (schema L6989) which omits `native_kind`.
Database compatibility for the proof: the S8-B migration `20270122000000_scout_native_provenance_expand` defines CHECKs only on `native_kind`, `outcome`, `native_id` shape and unresolved reason (L140-148); `entity_type` is `TEXT NOT NULL` without a CHECK, so `workouts.exercise` is insertable. No schema, migration or accepted identity-key change.
Regression `native-writers.spec.ts` L252-282: top-level row with `source_id = '3:w-1#id:n'` (equal to an unresolved child id of `w-1`) persists as a distinct `workouts`/`workout_plan` identity (two provenance rows share the source_id under different entity types), `plans.size` 2; replay of `w-1` still reports `unresolvedChildren: 4`, the colliding row 0. Existing assertions extended with `entity_type` columns (L196-203, L239-244), none removed or weakened.

### A-review A1 — legacy PG fixture stages `client_history` on `truecoach` — CLOSED, proof-only
`test/rls-g2-s8c.spec.ts` L522-530: `stage('h-1','client_history',{title:'Ran 5k',client_id:'c-1'},'coach','intent','truecoach')`. Harness `stage()` (unchanged blob `d5cbf877`, L97-109) already accepts coach/intent/platform; `ScoutIngestEntity` has no FK on `source_platform` (schema L6890-6897). Service query (`scout-reconstruct.service.ts` L78-99) scopes staged rows by coach/intent/family only, so the row is processed; `families.ts` L148-178 routes `client_history` through the repository mapper registry regardless of the injected native seam, and accepted `truecoach.json` `client_history` maps `client_id`/`title` — payload fits. Assertions (`staged 1, reconstructed 1`, legacy NULL kind, truthy target, legacy ledger row untouched) preserved; the "no foreign provenance" filter L549-553 now excludes both `workouts` and `workouts.exercise`; child `byKey` lookups L243-265 use `workouts.exercise`; parent lookup L236 stays `workouts`. No other child expectation keyed on the parent type remains (`rg` on the spec).

Result: every A/B open at `af9f7f54` (REVIEW_B B1, B2; A-review A1, B1 as dispositioned by the parent) is closed in source within the seven granted paths. No new A/B found in the delta.

## 3. Lineage and gates (observed evidence; not an authorized-sequence claim)

- `review-correction/run/attempt-1/` (05:18:33-05:18:51Z, lock inode 691716, postgres 0): prettier write/check rc 0, eslint rc 0, Jest four native suites 43/44 — FAIL `native-writers.spec.ts` L487 new regression read `provenance.values()[0]` (a child row, `workoutPlanExercise-48`) as the parent; STOP rc 78, no auto replay inside the driver, lock released.
- Attempt 2 (`run/s8c-review-gate.log`, 05:19:37-05:20:40Z): prettier write/check rc 0, eslint rc 0, `JEST_NATIVE_4 rc=0` 4 suites / 44 tests, `STAGED_TREE=cec7d05a…`, genuine hooks all ✔ (`commit.raw.log`: prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc 46 s at heap 4096; commit-msg no-ai-tokens), commit rc 0, HEAD `87018a42`, RELEASED 05:20:40Z.
- Independent patch comparison (attempt-1 `babe39e7…` vs final `addcc2a3…`): same seven files; 13 differing content lines, all inside the new `persistEvidence` regression case — parent selected by `native_kind === 'workout_plan'`, mutation located by `id`, and a full-snapshot equality instead of a single-row equality. Production source (`native-contract.ts`, `native-provenance.ts`, `native-rules.ts`, `native-writers.ts`), the PG spec and `native-rules.spec.ts` are byte-identical between attempts. The final bytes are the ones the 44/44 run and the hooks observed (`STAGED_TREE` logged before commit equals the committed tree).
- Process deviation (record only, per `S8C_GATE_SEQUENCE_DISPOSITION.md` and `CORRECTION_RECEIPT_ADDENDUM_01.md`): attempt 2 was launched without the specific parent relay the amended grant required. I record it as a nonblocking execution-process deviation; it changes no byte, binding or test outcome, and I make no claim that the sequence was authorized. No further gate is requested.

## 4. C — recorded and qualified, no blockers
- (a) Process deviation above (parent-dispositioned).
- (b) v3 driver header L2 still reads "UNFILLED head pins; NOT RUN; NOT GRANTED" — stale comment carried from v1/v2; refusal logic keys on placeholders, zero remain.
- (c) `CHANGED_PATHS_from_base.txt` in v5 = `04c03f40…` (same 25 paths as v4): correct, since the seven corrected paths are all already in that set.
- (d) `verifyTarget` on the evidence path performs one extra `workoutPlan.findUnique` per replay of an already-created row before returning; bounded, one read.
- (e) Initial-review C items (composite gate evidence for 527fe2bc, `RECEIPTS.sha256` self-entry, pg_wrapper pin, etc.) stand unchanged; the four native suites were re-run on the exact final tree here.

## 5. Decision for the single new PG-proof grant (not acceptance)

Exact candidate: HEAD `87018a421f5be1064767d2cdd32e75ca935f7cdb`, tree `cec7d05a91876ec3f6badb1020bb97aacdb9331d`, on `af9f7f54` → `527fe2bc` → accepted `93389265`. Exact binding: `s8c/binding/v3/s8c-pg-proof.sh` `9ddb52de…`, fixture `1a7faa5f…`, `BINDING.sha256` `ede987a6…`, spec blob `dc804fde…`, five other proof blobs, base-file pins and nine tool pins unchanged from the fully reviewed v1.

**GO** for exactly one PG-proof execution of this head with this v3 binding under a separate parent grant. No A or B remains open against the source, proof sources or binding; the process deviation is recorded, not blocking. This is not product acceptance, which awaits the runtime result and its own review.
