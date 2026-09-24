# S8-0 independent T3 review

- **Reviewer:** an independent T3 reviewer, not the author. Read-only. This file is my only write.
- **Candidate:** `72fa09cb95b0c842e2bbcd47998b041f5cd365bd` on branch `s8-0`, file `docs/decisions/2026-09-24-s8-native-contract.md`.
- **Base:** I = `c7a5fe8d`.
- **Other sources read:** NQ `61b93cff` (via `GIT_OPTIONAL_LOCKS=0`), X `aa0abd83`, PLAN at `1ebbed7`, and the C grant and brief (`execution/cf8ff737/C_BUILD_GRANT.md`, `c-prep/C_SLICE_BRIEF.md`).
- **Not done:** no runtime, tests or PG. Model and effort are not claimed.

## Verdict: NOT ACCEPT (narrow)

Three A findings. All three can be fixed with text-only changes to this one file. They block S8-0 only as the binding contract for S8-B and S8-C. They block nothing that is executing now: S8-A continues, and S8-B drafting continues. S8-C cannot start yet in any case, because it needs S8-A, S8-B and C.

**Minimum closure:** one follow-up Bradley commit on `s8-0` covering A1–A3, with the same hooks and no trailers. Then a delta-only re-check by the parent or this reviewer. Do not re-review the unchanged sections.

## Verified OK

- **Commit identity:** author and committer are both Bradley Gleave <bradley@bradleytgpcoaching.com>. The message has no trailers.
- **Commit shape:** parent is `c7a5fe8d`. One file, +444. The worktree is clean.
- **Report values:** the blob `4c1b2c3c…` and sha256 `ae88b127…` match the report. `commit-2.log` shows every hook passing (prettier, tsc, no-ai-tokens). `commit.log` is the earlier tsc out-of-memory failure, and no commit was made from it. Both match the report.
- **Citations at I:** schema lines were spot-checked against the blob and match. These cover User L158; the client-owned `User` foreign keys at L2327-2328, 864-865, 932-933, 1038-1039 and 1104-1105; WorkoutPlan, Program, Exercise and Revision at L2135-2317; CheckIn L1107-1129; ExerciseCatalogItem L4332-4336; D2 L6904-6911; staging L6882-6898; and generic L6981-6993.
- **Source citations:** these also match:
  - `families.ts` L25-28, 50-53, 60-88, 97-130, 124 and 141-142;
  - the registry at L64-66;
  - the mappers at L35-41, L57 and L70/L83;
  - the reconstruct DTO at L4-18, L98-114, and the ingest DTO at L55-56 and L141-142;
  - `coach.service` L133-147;
  - `workout-builder` L50, 52, 101, 345-366, 526, 551, 746, 800-830, 967, 1125, 1283, 1336 and 1535-1550.
- **Triggers:** the "no trigger on S8-C targets" claim holds. The only `CREATE TRIGGER`s are on `TeamSubCoachAssignment` and the ledger fence.
- **Other repos:** PLAN L248, 251, 298, 306-313 and 319 match, as do X `_interface.js` L32-39 and `blueprint.js` L40-47.
- **North star:**
  - Mapping is data-only, through one interpreter. There are no inferred units, zones, enums or defaults, and every gap gets a closed unresolved code. NEW SOURCE → CORE DIFF = 0 applies to mapping, with an explicit S8-A acceptance hook.
  - The rules follow from that: create-only, no merging by name or email, and non-destructive conflicts.
  - Side-effect suppression is concrete: a live-method deny list, a module-boundary rule, a spy, no assignments, and `is_regime=false`.
  - `roster_bridge_pending` stops the doc from claiming imported clients appear in the roster.
- **D-S8-2:** recorded correctly. Interim (b) is in force with `unresolved:no_native_client_principal`. Option (a) is reserved to Bradley. Only S8-D and S8-E are blocked. The client-linked classification rule (§3.8) is deterministic.
- **Consistency with accepted contracts:**
  - The ledger vocabulary and `staged = reconstructed + skipped + failed` are unchanged.
  - The (c,i,e,p,s) ledger identity from R, N/Q1 and C is untouched.
  - The provenance key is separate from the ledger key.
  - The skip reasons are byte-identical.
  - Nothing contradicts C's owned paths, D-C1 or D-C2.

## A findings

### A1: the revision rule is miscited and leaves the `head_revision_id` of imported program days undetermined (§3.6, §4.2, §4.3)

**Fact at I.** §3.6 says the native program create paths write an initial `WorkoutProgramRevision` and set `head_revision_id` (L1046, L1204, L1252). That is wrong:

- L1046 is `forkTemplate`. It writes **no** program revision and leaves the program head null. Instead, `copyProgramPlans` writes a **`WorkoutPlanRevision`** for each day: index 0, cause `initial`, with the plan head set (L984-1004).
- L1204 and L1252 are clone-to-client: cause `clone`, `is_template=false`. That is not a template create.
- The only program create that writes an initial program revision is the AI materialiser, with `author_kind='ai'` (`create-workout-plan.materialiser.ts` L493-521).

§4.3 then sets the plan `head_revision_id` "as the native create path", and the only plan path it cites is `createPlan`, which writes no revision.

**Harm.** Autosave and undo reject any plan with a null head: "Plan has no revision baseline" returns 409 (`workout-builder-autosave.service.ts` L494-521). The same code states that "MWB-1 guarantees every program/plan is created with an initial revision". If S8-C follows `createPlan` for program days, coaches cannot edit or undo imported program days in the builder. That breaks the coach-edit path on real customer data. The program-revision rule itself is also left to the builder, which is not deterministic.

**Blocked:** S8-C's column and revision rules only.

**Minimum closure:** correct the §3.6 citations, then state an explicit rule:

- **Every program-day `WorkoutPlan`:** gets `WorkoutPlanRevision` index 0, cause `initial`, author the importing coach, with `exercises_json` and `plan_meta_json` in the `copyProgramPlans` shape (the rows actually written). `head_revision_id` is set in the same transaction.
- **Standalone plans:** follow `createPlan` (no revision).
- **`WorkoutProgram`:** pick one and state it. Either the fork precedent (no program revision, head null) or revision 0 with cause `initial`.

**Unlocks:** S8-C's column rules for §4.2 and §4.3.

### A2: child provenance and replay semantics are internally inconsistent (§3.2, §3.3, §3.4, §3.5, §4.4)

**The contradictions:**

- §3.3 says there is "one provenance record per native row written". §4.4 then requires provenance rows for **unresolved** children, which have no native row. `native_id` nullability for `outcome=unresolved` is never stated, which S8-B's schema needs.
- §3.2 and §3.5 define `already_present` as "provenance exists and the native row exists → no write". That definition ignores child state.
- Children are not ledger rows, yet S8-C acceptance says both "tally = ledger" and "unresolved children counted". The contract never says where the child counts come from.
- §4.4 says gaps are kept "so a later resolution does not renumber". That implies inserting children into an existing imported plan later, which conflicts with create-only (D-S8-4). It could also collide with an exercise the coach added at that `order` (partial unique index, L2315-2317). No rule covers this.
- The child key `<parent>#<child id>` or `#<ordinal>` is not injective. A child with id `3` and an id-less child at ordinal 3 collide, and so does a `#` inside a parent id. The second child would then silently converge to `already_present`.

**Harm.** Under the S8-C precondition, **every** exercise is `unresolved:exercise_reference`. So every imported plan hits this path. A literal replay, or a new intent, would see every plan as `already_present` and could report `workouts` as complete with zero exercises imported. That claims data that was never imported.

**Blocked:** the S8-B provenance shape (`native_id` nullability, child key) and S8-C replay accounting.

**Minimum closure:** amend the text to say:

1. An unresolved child provenance row is written in the parent's transaction, with `native_id` null and a reason.
2. On every pass, an `already_present` parent re-reports its persisted unresolved children from provenance. The family cannot be `complete` while any child provenance row is unresolved.
3. S8 never inserts a late-resolved child into an existing imported plan. It stays unresolved (S9), or this contract is amended explicitly.
4. The child key encoding is injective, for example distinct `#id:` and `#ord:` markers plus escaping or length-prefixing of the parent id.

**Unlocks:** S8-B schema and S8-C replay.

### A3: many-to-one step → family mapping silently merges identities (§2 D-S8-1, D-S8-3)

**Fact.** After C, staging identity is (c,i,e,p,s), so the same `source_id` can be staged under two different source labels. The D-S8-3 key uses the **canonical** family and drops the label. Suppose a spec maps two source steps to one family, and their id spaces overlap (for example `workouts` and `workout_templates`, both numeric). The second record then resolves to `already_present` against the first record's native row.

**Harm.** A different record is counted as `already_present_verified` and never imported. That violates "fail closed on ambiguous mapping" and "never claim unimported data".

**Blocked:** S8-A spec validation and the S8-B key (one sentence).

**Minimum closure:** a one-sentence rule plus one S8-A test. A mapping spec may map at most one source step to a canonical family, unless it explicitly declares that the steps share one id space. Otherwise the interpreter rejects the spec (fail closed). The alternative is to put the source step label in the key.

**Unlocks:** S8-A validation and S8-B keying. Current S8-A execution is not blocked; the existing families map 1:1.

## B findings

None. No accepted proof is invalidated, because this is a doc-only commit.

## C findings (record and continue)

- **C1.** The `Person` range L6920-6937 overshoots. The model ends at L6934, and L6936-6937 is the ledger comment.
- **C2.** §3.3 says `created_at`/`updated_at` keep "database defaults". `updated_at` on `WorkoutPlan` and `WorkoutProgram` is Prisma `@updatedAt` with no database default (L2149, L2225). The intent (no source timestamps in audit columns) is fine; only the wording is off.
- **C3.** The existing `Person` persist overwrites `display_name` on replay (`families.ts` L83), yet `person` is listed as a native kind under create-only D-S8-4. There is no coach edit surface for `Person` today. S8-D must revisit this when `Person` becomes coach-visible.
- **C4.** NQ success-dominates precedence (`61b93cff` `scout-reconstruct.service.ts` ~L293-305) means a later `native_target_removed` in the same intent cannot downgrade a `reconstructed` ledger row. S9 reconciliation should check provenance and native existence, not only the ledger.
- **C5.** `author_kind='coach'` is fixed even when a sub-coach imports. Native `copyProgramPlans` uses `sub_coach` (L1064). This is acceptable because reconstruct is a coach-JWT path; note it if sub-coach import is ever allowed.

## Delta check: closure commit `e322602d` (parent `72fa09cb`)

**Scope.** This check reviews only the `72fa09cb..e322602d` diff. Unchanged text was not re-reviewed.

**Commit hygiene.**
- Author and committer are both Bradley. There are no trailers.
- The commit changes one file (+95/−32). There is no `src/` change against the base.
- The blob is `e177069f` and the sha256 is `efc98c3a…`, both matching the report.
- `commit-3.log` shows all hooks passed.
- The worktree is clean, and HEAD is `e322602d`.

### A1: closed

New citations were verified at I:
- `copyProgramPlans` at L913. It is called from fork at L1061-1066, with cause `initial`, and the head is set at L1001-1004.
- `serialiseExerciseRows` at L1446-1471.
- `plan_meta_json` at L989-995.
- Autosave rejects a null head at L494-522.
- Fork creates the program at L1046-1060, with no program revision.
- Clone-to-client at L1204/L1252 and the AI materialiser at L493-521 are correctly excluded as precedents.

**Standalone reading (no revision, null head, as in `createPlan`) is ACCEPTED.** The evidence at I:
- The only native creator of a standalone plan is `createPlan`, at L356. It writes no revision.
- The only other `workoutPlan.create` calls are `copyProgramPlans` (L951) and the AI materialiser (L272). Both always set a `program_id`.
- `setExercises` (L460-547) never touches revisions. A revision baseline on an imported standalone plan would therefore go stale under the legacy editor, and a later undo could restore stale data. The author's reasoning holds.
- A null head therefore gives exact parity with native standalone plans. It is not a regression, because autosave and undo are unavailable for native standalone plans too.

Program days get revision 0 plus a head, which keeps them editable in the builder. `WorkoutProgram` follows fork: no revision, null head, `version 1`. That is deterministic and stated in the §4.2 and §4.3 rows.

### A2: closed

The contract now states each required rule:
- **Nullable `native_id`.** `native_id` is null exactly when the outcome is `unresolved`. The unresolved child row is written in the parent's transaction, and top-level unresolved outcomes stay in the ledger.
- **Child counts.** Child counts come from provenance, and "tally = ledger" applies to top-level rows only.
- **Complete.** A family is `complete` only if no child provenance row is `unresolved`.
- **Replay.** An `already_present` parent re-reports its persisted unresolved children on every pass (§3.2, §3.4, §3.5, §4.4).
- **No late child inserts.** Order gaps are kept.
- **Injective child key.** The encoding is `<len>:<parent>#id:<x>` or `<len>:<parent>#ord:<n>`. The length prefix plus distinct markers remove both collisions.
- **S8-B acceptance.** It now adds the nullable `native_id` and the key-width requirement.

### A3: closed

- D-S8-1 now allows at most one source step per canonical family, unless the spec declares a shared id space. Otherwise the whole spec is rejected before any row is mapped.
- D-S8-3 now ties its key safety to that rule.
- S8-A acceptance names `test/scout/reconstruct/mapping-spec-validation.spec.ts`, which falls inside S8-A's owned glob `mapping-spec*.spec.ts`.

**C1 closed.** The `Person` range now reads L6920-6934.

**No new A or B findings.** C2–C5 remain recorded.

## FINAL: ACCEPT

S8-0 is accepted at `e322602dfd0ba2d60bd6f9a77ea9cfce26f83f38` as the binding source-to-native contract for S8-A, S8-B, S8-C and S8-F. S8-D and S8-E remain blocked on D-S8-2(a), which is reserved to Bradley.
