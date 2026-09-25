# S8-C independent review A — changed-question re-review of `87018a42` and binding v3

Reviewer: independent S8-C reviewer A (T4 high). Scope: only the seven-path delta `af9f7f54 → 87018a42` under the amended `S8C_REVIEW_MINIMUM_CORRECTION_GRANT.md`, its lineage/gates (`s8c/review-correction/`, `checkpoints/v5/`), the `S8C_GATE_SEQUENCE_DISPOSITION.md`, and the v3 binding. Unchanged analysis from `REVIEW_A.md` (immutable) is bound by reference, not repeated. Read-only: every source byte was read from committed objects via `git show`/`git diff`/`git rev-parse`, never the working tree; no product, Git, runtime or lock writes; no installs, tests, compiles, PG probes or pushes; `REVIEW_B.md` and any peer V3 report not read. Written 2026-09-24 ~22:28 PDT (2026-09-25 ~05:28Z).

Decision sought: GO / NOT GO for ONE new PG proof grant (single run of `binding/v3/s8c-pg-proof.sh`). Not product acceptance; no S8-F reader activation, customer/flag exposure, S8-D/E, S9 or production decision implied.

## 1. Identity and lineage (recomputed)

| Item | Value | Verified |
|---|---|---|
| Final frozen head | `87018a421f5be1064767d2cdd32e75ca935f7cdb` | `git cat-file -t` commit; `git log -1` |
| Tree | `cec7d05a91876ec3f6badb1020bb97aacdb9331d` | matches parent mail, receipt, v3 pins |
| Parent | `af9f7f5438fa545394b6d28792411439ded66caf` (tree `62a8071e…`, unamended) → `527fe2bc…` → base `93389265…` | lineage intact |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same | `%an %ae %cn %ce` |
| Subject | "S8-C: honour failed target verification, enum_unmapped, child provenance namespace" | body describes exactly the four closures |
| Delta af9f→8701 | exactly 7 files, +147/−27: `native-contract.ts` +8, `native-provenance.ts` +2/−1, `native-rules.ts` +5/−1, `native-writers.ts` +14/−7, `test/rls-g2-s8c.spec.ts` +26/−7, `native-rules.spec.ts` +5, `native-writers.spec.ts` +87/−11 | `git diff --stat`; patch sha256 prefix `addcc2a3b378a9be` equals `review-correction/run/delta-from-af9f7f54.7path.patch` |
| Out-of-surface paths | `docs/`, `prisma/`, `nest-cli.json`, `package.json`, `package-lock.json`: no change from af9f7f54; `prisma/` identical to base | `git diff --stat` empty |
| Worktree state at review time | HEAD `87018a42`, porcelain 0 (`--untracked-files=all`) — noted only; review used committed objects | |

Proof-file blobs at `87018a42` vs v3 pins:

| Path | Blob | Pin |
|---|---|---|
| `test/rls-g2-s8c.spec.ts` | `dc804fdef00757732a7e75eeb13dcd30d1920cb4` (was `9fc44a2b…`) | EXPECT_SPEC_BLOB ✓ |
| `test/utils/g2-s8c-bootstrap.sh` | `8aa86de8164fef29d85ec6b0720ece0903fb8a70` | unchanged ✓ |
| `test/utils/g2-s8c-db.ts` | `a7d67217fe959f65daae9615e5f00806cc3764d3` | unchanged ✓ |
| `test/utils/g2-s8c-pg-harness.ts` | `4059883d70c26aed46398af707645aaacb306868` | unchanged ✓ |
| `test/utils/g2-s8c-harness.ts` | `d5cbf8779007dddf3ae75db76d706e3050ef9ceb` | unchanged ✓ |
| `test/utils/g2-s8c-worker.cjs` | `484030636dee841bcd5aff1af42536128858ac77` | unchanged ✓ |

The 11 accepted-file pins in driver L100–106 recomputed at `87018a42`: all match (`g2-s8b-*` ×5, `g2-s8b-db-guard.spec.ts`, `rls-g2-s8b.spec.ts`, migration dir `94c4d201…`, `prisma/schema.prisma 32e44110…`, `src/scout/reconstruct/sources a1a296ee…`, `jest.rls.config.js 44c96915…`). `src/scout/reconstruct/native/sources` absent at the head. Native-module imports at the head remain inside the allowed set (`@prisma/client`, `fs`, `path`, `./*`, `../mapping-spec`, `../source-mapper-registry`, `../../scout-reconstruct.dto`); `native-provenance.ts` gained only `CHILD_ENTITY_TYPE` from `./native-contract`. No reader of `importNativeProvenance.*` exists in `src/` outside the native module.

## 2. Closure review (the changed question)

### 2.1 REVIEW_A A1 (parent-classified B, proof-only) — legacy `client_history` fixture platform — CLOSED
`test/rls-g2-s8c.spec.ts` L520–527: `stage('h-1', 'client_history', { title: 'Ran 5k', client_id: 'c-1' }, 'coach', 'intent', 'truecoach')`. Payload and every assertion of the case preserved (L529–554); the pre-inserted `legacy-1` row untouched. `truecoach.json` (blob unchanged) declares `client_history` with `label` paths `title`/`name` and `clientSourceId` path `client_id`, so the repository mapper maps the row; ledger lookup ignores platform; legacy `target_kind` NULL assertion stands. The one deterministic failure identified in `REVIEW_A.md` §4 A1 no longer exists.

### 2.2 REVIEW_A B1 — child provenance namespace §3.3 — CLOSED by source
- `native-contract.ts` L35–40: `CHILD_ENTITY_TYPE = { workouts_exercise: 'workouts.exercise' }` (constant only; `NATIVE_FAMILY`, DTO enum, family registry untouched). Contract wording confirmed at `docs/decisions/2026-09-24-s8-native-contract.md` L175 and L432 (`entity_type = workouts.exercise`).
- `native-writers.ts` L288–292: child key `{ ...provenance, entityType: CHILD_ENTITY_TYPE.workouts_exercise, sourceId: child.childSourceId }`, used for both `recordUnresolved` and `recordCreated` of children.
- `native-provenance.ts` L120: `countUnresolvedChildren` filters `entity_type: CHILD_ENTITY_TYPE.workouts_exercise`; coach/namespace/prefix/`native_kind = workout_plan_exercise`/`outcome = unresolved` filters retained.
- DB compatibility: `ImportNativeProvenance` (migration `20270122000000…` L125–160) has CHECKs on `native_kind`, `outcome`, `native_id` shape and unresolved-reason only; `entity_type` is free TEXT and part of the unique identity key — `workouts.exercise` is accepted and separates the namespaces as the parent required.
- Unit regression `native-writers.spec.ts` L252–282: top-level row with raw `source_id = '3:w-1#id:n'` (equal to an encoded unresolved child id) persists as a distinct `workouts`/`workout_plan` created identity; two provenance rows share that `source_id` under different `entity_type`; original parent still re-reports `unresolvedChildren: 4` on replay, colliding row reports 0; `tx.plans.size` 2. Existing assertions strengthened to include `entity_type` (L196–203, L239–244), none removed.
- PG spec: child `byKey(provenance, 'workouts.exercise', …)` L242–270; row count 5 unchanged (L272); parent still `'workouts'` (L236); legacy no-foreign-provenance filter now excludes `['workouts','workouts.exercise']` (L549–553) — exactly the "child-provenance entity-type expectations required by the correction". No other PG assertion changed; remaining `'workouts'` provenance lookups (L443, L474, L581) address parent rows and stay correct.

### 2.3 REVIEW_B B1 (per grant; my C6) — `persistEvidence` fall-through — CLOSED
`native-writers.ts` L373–384: with declared rules and existing non-unresolved provenance, `const verified = await verifyTarget(...); if (!verified.ok) return verified;` precedes the evidence upsert and any `recordUnresolved`. `verifyTarget` (L66–89, unchanged) yields `unresolved:identity_conflict` (kind mismatch / null native_id / foreign coach) and `unresolved:native_target_removed` (missing or archived) as distinct `PersistOutcome` failures — the same shape `persistWorkoutTemplate` returns at L247–248, so engine/ledger precedence handling is identical. Regression `native-writers.spec.ts` L482–522: archived → removed with calls exactly `['importNativeProvenance.findUnique','workoutPlan.findUnique']`; deleted → removed; foreign coach → conflict; kind mismatch → conflict; `entities.size` 0, `plans.size` 1, every provenance row (parent and children) equal to the post-create snapshot except the test's own mutation, and zero `upsert|update|create` calls. Successful replay path and new client-linked evidence path unchanged (L383–386 onward untouched).

### 2.4 REVIEW_B B2 (per grant; my C3) — `enum_unmapped` — CLOSED
`native-contract.ts` L45 adds `enum_unmapped` to `UNRESOLVED_CODE` and L63 to `QUALIFIED`; nothing else added to the vocabulary. `native-rules.ts` L328–333: present string/number key absent from `rule.map` → `unresolved:enum_unmapped:<field>`; mapped destination outside the native enum → `invalid_value:<field>`; non-string/number raw → `invalid_value` (L326); absent/empty with default → defaulted (L321–324) unchanged. `native-rules.spec.ts` L322–329: `kind:'yoga'` → `unresolved:enum_unmapped:type`; added `kind:{not:'a key'}` → `unresolved:invalid_value:type`. Qualifier `field` passes the `unresolved()` guard regex as before.

### 2.5 Scope compliance
Only the seven granted paths differ; no skip/deletion/weakening of assertions (every removed line in the tests is re-asserted in strengthened form); no sidecar, mapping spec, engine, schema, generated artifact, dependency, workflow, helper (`fake-native-tx.ts` unchanged — it keys provenance on the 4-tuple including `entity_type`, so the collision regression is meaningful) or contract-document change.

## 3. Gate lineage and process deviation (evidence only)

- `review-correction/run/RECEIPTS.sha256`: 15/15 files verify, 0 mismatches (`sha256sum -c`, read-only).
- Attempt 1 (05:18:33–05:18:51Z, `run/attempt-1/`): prettier/eslint rc 0; Jest 1 failed / 43 passed — the new B1 regression selected `provenance.values()[0]` (a child row) as the parent.
- Attempt 2 (05:19:37Z ACQUIRED inode 691716, postgres=0 → 05:20:40Z RELEASED): prettier write/check rc 0, eslint rc 0, Jest 4 suites / 44 tests passed (`jest-native-4.log`), hooks ✔ prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc 46.16 s, no-ai-tokens (`commit.raw.log`), commit `87018a42` / tree `cec7d05a` / porcelain 0 / files = the seven paths.
- Independent comparison of the two attempt patches: same seven `diff --git` headers; every hunk outside `native-writers.spec.ts` byte-identical (only `index` lines differ); within `native-writers.spec.ts` the sole difference is the new regression's parent selection (`[0]` → `find(native_kind === 'workout_plan')`), locating the parent by `id` for the test's own mutation, and snapshotting all provenance rows. Product source and the PG proof spec are identical between attempts. This matches `CORRECTION_RECEIPT_ADDENDUM_01.md` and `S8C_GATE_SEQUENCE_DISPOSITION.md`.
- Process deviation recorded per the disposition: the attempt-1 correction and attempt-2 launch had no specific parent relay, contrary to the amended grant's "stop and report; no automatic rerun". Recorded here as an execution-process deviation (C, nonblocking for this exact-candidate review, no retroactive authorization claimed). The 44/44 and hook results are evaluated as observed evidence of the committed bytes, not as an authorized sequence. No repeat gate is requested or would repair the history.
- `checkpoints/v5/HEAD.txt`: BASE/PARENT/HEAD/TREE/AUTHOR/COMMITTER consistent with the recomputed identity.

## 4. Binding v3 (recomputed with `sha256sum`, read-only)

| File (`s8c/binding/v3/`) | sha256 | Match |
|---|---|---|
| `s8c-pg-proof.sh` | `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8` | ✓ parent mail / receipt |
| `s8c-pg-proof.sh.v2` | `038d6af62e09b0f7bce8bbc270e7283bcad06aa27b06daada898e1ac8281ee4f` | ✓ = `binding/v2/s8c-pg-proof.sh` (v2 untouched) |
| `s8c-pg-proof.sh.diff-v2-to-v3` | `c409ab3e05b463c77f4d5da1205c62c2dfa7a5c0900e47e22156b445fd921d7b` | ✓ |
| `s8c-fixture.sh` | `1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3` | ✓ = EXPECT_FIXTURE_SHA, unchanged since v1 |
| `PINS.txt` | `316dd1214efae211fe215bf80d0ff3c5bde120f9a2369e8a9760ec3553ad3603` | ✓ |
| `PINS.txt.diff-v2-to-v3` | `563930aabf5f80baf7ae31b52420ded9a63ffd0495af2b1cf1a54b26b816e40c` | ✓ |
| `README.md` | `a90b1aea6e362573e7fdc14a0d3c7022c8644f2aa0852bccc967b2fbc64d0dbb` | ✓ unchanged |
| `BINDING.sha256` (file) | `ede987a6536f35103f978d97690e45ed84d58c196615560561fbef3d9f7514ec` | ✓ parent mail |

Original `binding/s8c-pg-proof.sh` still `66a838ab…` (v1 untouched). Independent `diff` of v2 vs v3 drivers: exactly four changed lines — L23 `D=…/binding/v3`, L31 `EXPECT_HEAD=87018a42…`, L32 `EXPECT_TREE=cec7d05a…`, L33 `EXPECT_SPEC_BLOB=dc804fde…`; nothing else differs, so every precondition, env export, marker check, jest invocation, stop/post logic and the nine tool pins reviewed in `REVIEW_A.md` §2–3 apply unchanged. `PINS.txt` delta: the same three pins plus two mechanical path strings. Zero placeholders. Tool/dependency pins were recomputed against the runtime and worktree in `REVIEW_A.md` §2 and are unaffected by this source-only delta (`prisma/schema.prisma`, `package-lock.json`, `node_modules` not in the delta).

## 5. Findings

No new A or B finding from the seven-path delta. All previously open A/B items are closed by source at `87018a42` (§2.1–2.4).

C (record/qualify only; no blockers, fixes, controls or reruns):
1. Gate-sequence deviation (§3) — process record per `S8C_GATE_SEQUENCE_DISPOSITION.md`; product/PG bytes identical between attempts.
2. Carried from `REVIEW_A.md` §4 C1: the driver writes its sentinel on preflight failure (rc 71: port busy, live `postgres`, other lane `postmaster.pid`); with the `s7l` lane present under `clusters/`, the single run is only meaningful when no postmaster survives. Qualification for the grant executor, unchanged inherited S8-B behaviour.
3. Carried C items 2, 4, 5, 7–16 of `REVIEW_A.md` stand unchanged; C3 and C6 are now closed by §2.4 and §2.3.
4. `persistEvidence` failure return on a previously CREATED identity leaves the ledger under precedence (`reconstructed` never downgraded) with the target gone — same accepted S8-B/N semantic as the template path; consistent, S8-G owns.

## 6. Decision for the single new PG grant

**GO** — reviewer A attests exact head `87018a421f5be1064767d2cdd32e75ca935f7cdb` (tree `cec7d05a91876ec3f6badb1020bb97aacdb9331d`) together with filled binding `s8c/binding/v3/s8c-pg-proof.sh` (`9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8`), fixture `1a7faa5f…`, `BINDING.sha256` `ede987a6…`, as ready for ONE granted PG proof run. The prior NOT GO in `REVIEW_A.md` rested on A1 and B1, both closed here; the additional REVIEW_B closures are verified and in scope; no new A/B arises from the delta or the bindings.

Conditions inherent to the grant (not new controls): run once, exactly `binding/v3/s8c-pg-proof.sh` under the parent's separate grant with the worktree at `87018a42` and clean; the proof outcome is evidence for later product acceptance, which this attestation does not confer. Source isolation from S7-L and S8-F preserved.
