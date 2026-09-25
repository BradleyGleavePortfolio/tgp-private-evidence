# S8-C independent review B — new source + filled binding (527fe2bc) bound to test-only follow-up (af9f7f54) + v2 binding

Reviewer: independent S8-C reviewer B (T4 high, step budget 200). Grant: `S8C_INDEPENDENT_REVIEW_GRANT.md`, extended by parent mail to bind the one-test follow-up and v2 binding without repeating unchanged analysis. Date: 2026-09-25 (UTC), written ~05:10Z.

Scope actually performed: complete NEW-delta review of every path changed from accepted base `93389265` (24 paths at 527fe2bc; 3 M src, 1 M contract JSON, 20 A), the S8 native contract, the S8-B CHECKs it relies on, all new unit/PG suites, the full filled binding (driver, template, diff, fixture, PINS, README, fill script, fill log), the source-gate receipts, the correction grant + correction receipt + v2 binding, and the v4 export. Unchanged accepted bytes (`prisma/`, `src/scout/reconstruct/sources/`, S8-B harness sources) were only identity-checked, not re-audited. Read-only throughout: `git show`/`rev-parse`/`diff` on the worktree, `sha256sum`, `sha256sum -c`; no product/Git/runtime writes, no install/compile/test/lock/PG/push, no sub-delegation. Peer `REVIEW_A` not read.

## 1. Identity and hashes (all recomputed by me, read-only)

| Item | Claimed (receipt / FINAL_PINS / parent mail) | Recomputed | Match |
|---|---|---|---|
| Frozen candidate HEAD | `527fe2bc24f954b26c0485c90345f237ce39a09d` | `git rev-parse` in `worktrees/64e33dc7-s8c` (was HEAD at review start) | yes |
| Candidate tree | `d87a96267c2ec4f4d79d83d26e6b2928a56c8a85` | `527fe2bc^{tree}` | yes |
| Parent = accepted base | `93389265a846095b846fa8f1fb0dad782fb6ee9f`, tree `a315dd65…` | `527fe2bc^`, `^{tree}` | yes |
| Author/committer | Bradley Gleave `<bradley@bradleytgpcoaching.com>` | `git log -1 --format` | yes (both heads) |
| Changed paths from base | receipt says 25 / 21 A | `git diff --stat 93389265 527fe2bc`: **24** paths, 20 A, 4 M | C(a), parent-qualified |
| `prisma/`, `src/scout/reconstruct/sources/` | byte-identical to base | `git diff --quiet` | yes; 171 migration dirs |
| Six proof blobs (spec/bootstrap/db/pg-harness/harness/worker) | `9fc44a2b / 8aa86de8 / a7d67217 / 4059883d / d5cbf877 / 48403063` | `git rev-parse HEAD:<path>` at 527fe2bc **and** at af9f7f54 | yes, identical at both heads |
| 11 base-file pins in driver L100-105 (g2-s8b-* blobs, migration tree `94c4d201`, schema `32e44110`, sources tree `a1a296ee`, `jest.rls.config.js` `44c96915`) | as in PINS.txt | `git rev-parse` at both heads | yes |
| Filled driver `binding/s8c-pg-proof.sh` | `66a838ab51ab6486ec05ddd748dd39336bc1e9bed6dc19c48a46fb2e94e1c920` | sha256sum | yes |
| Template `.unfilled` / diff / fixture / PINS / README / fill-pins | `377c3922… / d5b88181… / 1a7faa5f… / b9df2be5… / a90b1aea… / 611c7d7c…` | sha256sum; `sha256sum -c BINDING.sha256` 7/7 OK | yes |
| `BINDING.sha256` file | `de827a3fc485c80e1a1ec2c567666425d558720c60e7610b7031b9854837b3af` | sha256sum | yes |
| Unfilled + diff → filled | — | `patch` in /tmp reproduces `66a838ab…` | yes |
| Nine tool pins | postgres `23cd1748…`, initdb `b7db9bc2…`, pg_ctl `af53d826…`, `/usr/bin/psql`→pg_wrapper `a200e38c…`, node `a03953a7…` v20.20.1, `node_modules/.package-lock.json` `05bc530a…`, `.prisma/client/index.d.ts` `b6716a86…`, `schema.prisma` `77f33bcd…`, `package-lock.json` `b7fed5ed…` | sha256sum of live files; `postgres --version` 17.6; `PROVENANCE.txt result=success`; fill log nine `TOOL_PIN_OK`, mismatch 0 | yes |
| checkpoints/v3 five hashes | FINAL_PINS | manifest verified | yes |
| **Follow-up HEAD** | `af9f7f5438fa545394b6d28792411439ded66caf` | `git cat-file -t` commit; current worktree HEAD; branch `exec64/s8c-replacement`; porcelain 0 | yes |
| Follow-up tree / parent | `62a8071e544e6a307537bd08c55b52e2a9af4e7d` / `527fe2bc` | `^{tree}`, `^` | yes |
| Follow-up delta | one file `test/scout/reconstruct/mapping-spec.spec.ts` +9/−1 | `git diff --stat`; `src/`, `prisma/`, `docs/` identical to 527fe2bc | yes; patch sha `a79caec2…` equals `correction/run/delta.patch` and `correction/mapping-spec.spec.ts.delta-from-527fe2bc.patch` |
| v2 driver `binding/v2/s8c-pg-proof.sh` | `038d6af62e09b0f7bce8bbc270e7283bcad06aa27b06daada898e1ac8281ee4f` | sha256sum | yes |
| v1→v2 driver delta | exactly 3 lines | `diff`: L23 `D=…/binding` → `…/binding/v2`; L31 `EXPECT_HEAD`; L32 `EXPECT_TREE` | yes; `$D` used only for `R=$D/run` (receipts) and `FIX=$D/s8c-fixture.sh` (fixture present in v2, byte-identical `1a7faa5f…`) |
| v2 manifest | 7 entries | `sha256sum -c binding/v2/BINDING.sha256` 7/7 OK; `s8c-pg-proof.sh.v1` = `66a838ab…`; original `binding/BINDING.sha256` still 7/7 OK (untouched) | yes |
| v2 PINS delta | two pins + two path strings | `PINS.txt.diff-v1-to-v2` read: exactly that | yes |
| v4 export | `MANIFEST.sha256` | 5/5 OK | yes |

## 2. Proof source / binding compatibility (inspected, not executed)

- Driver takes `flock -n` on fd 9 of `/home/user/workspace/execution/test-validation.lock` before any state change, once-only sentinel, refuses while any placeholder remains or `EXPECT_HEAD == BASE_HEAD`; checks clean worktree (`--untracked-files=all`), no `MERGE_HEAD`, hooks present, head == `EXPECT_HEAD`, tree == `EXPECT_TREE`, descent from base, six proof blobs and eleven base-file pins, nine tool pins; exports only `G2_S8C_*` (`G2_S8C_CANDIDATE_HEAD=EXPECT_HEAD`, `G2_S8C_CONFIRM=g2_s8c_disposable:55642`).
- Fresh lane `recovery-reset/clusters/s8-c/pg-data`, socket `run/s8-c`, port 55642, superuser `s8c_super`, DB `g2_s8c_disposable`, cluster marker `s8c-disposable-pg17`, DB marker `s8c-g2-native-writer-synthetic-disposable-fixture-safe-to-drop`; neither `clusters/` nor `run/` exists yet (lane fresh). Data dir retained after stop, never pushed.
- Fixture `S8C_FIXTURE_INIT_OK data=… port=… superuser=… cluster_name=…` / `S8C_FIXTURE_START_OK pid=` match the driver greps. Bootstrap creates a fresh DB, runs all 171 migrations via `prisma migrate deploy` as NOSUPERUSER `postgres`, never reruns S8-B, verifies the generated client without `generate`; role matrix postgres/service_role LOGIN BYPASSRLS, anon/authenticated NOLOGIN.
- `jest.rls.config.js` (`test/rls-*.spec.ts`) picks up `test/rls-g2-s8c.spec.ts`; default `jest.config.js` ignores it. pg-harness derived by controlled substitution from the accepted S8-B harness plus a barrier; worker asserts `git rev-parse HEAD` of root == attested head before constructing Prisma; fixture registry injected via `service.families`; pause hooks `after-target` / `before-ledger`. Fixture inserts satisfy required columns (User, ScoutImport, ScoutIngestEntity, ExerciseCatalogItem). Platform `s8c-proof` passes `isCanonicalPlatform`.
- PG spec covers: N1/N4 program create in one `BEGIN..COMMIT`; standalone plan ordering / exact catalog / unresolved children; replay preserves coach edits; program-day pending → converge rev 0; N2 client-linked explicit unresolved without User; tenant isolation; contention convergence + held-ledger rollback; legacy NULL-kind untouched; later-removed target keeps precedence (spec L535-568, S8-G noted as owner of completion).
- The v2 driver's only behavioural difference from the reviewed v1 is the two head/tree pins and the receipts/fixture directory; the follow-up head changes no byte the proof executes (`src/`, six proof blobs, `prisma/` identical), so the v1 compatibility analysis carries over unchanged.

Verdict on binding/proof sources: **ready** at `af9f7f54` + `binding/v2` — no binding-level blocker.

## 3. Source-gate receipts (verified without repeating tests)

- `gates/run/RECEIPTS.sha256`: 58 entries, 57 OK; the single FAILED line is the manifest's own self-entry (`e3b0c442…` = empty-file hash recorded before the file had content). Parent-qualified C; preserve.
- Attempt history matches the receipt table: attempt 1 R75 FAIL (7 casts), 2 tsc FAIL, 3 eslint FAIL, 4 (`run/` top level, 04:43:32Z) Jest affected 26 suites / 7 FAIL / 472 pass, 5 (`attempt-5-resume1`, 04:48:02Z) 15 suites 13 pass, FAIL `mapping-spec.spec` + `native-rules.spec` (owned `7:` vs correct `8:` length prefix; HEAD L83 now `8:`), 6 (`attempt-6-resume2`, 04:49:37Z) 2 suites, native-rules PASS, mapping-spec known FAIL allowed via `S8C_ALLOW_KNOWN_FAIL`; hook tsc OOM at default heap (`exit status 134`) after prod-readiness/banned-cast/prettier/eslint ✔; 7 (`s8c-gates-resume.log`, 04:51:34Z) `COMMIT_ONLY` with `git write-tree` == `d87a9626…` asserted before commit, hooks all ✔ at heap 4096, commit rc 0, HEAD `527fe2bc`, RELEASED 04:52:24Z, lock inode 691716 preserved. Lock file still present (0 bytes, 03:23), no holder.
- R75 `--cached` OK; prettier 3.9.9 offline prefix; contract regen idempotent (`727eb523…` before == after, +2 `programs` lines); `fill-pins.log` rc 0.
- Correction gate (`correction/run/s8c-correction-gate.log`): ACQUIRED 05:01:41Z, DELTA single file `a79caec2…`, prettier rc 0, eslint rc 0, Jest changed file 1 suite / 40 / 40 pass, STAGED_TREE `62a8071e…`, hooked commit rc 0 (tsc 48 s at heap 4096, `no-ai-tokens` ✔), HEAD `af9f7f54`, RELEASED 05:02:44Z. Matches the correction grant's exact writable delta: title adjusted descriptively, `notes` assertion and three supported-family checks retained, explicit `unresolved_family:programs` branch, no skip/deletion/mapping change.

## 4. Findings

Class legend: A blocks everything, B blocks one decision with concrete harm + minimum closure, C recorded and qualified, no blocker.

### B1 — provenance `reason` of a CREATED row overwritten on the client-linked/no-principal path
- Where (identical bytes at 527fe2bc and af9f7f54): `src/scout/reconstruct/native/native-writers.ts` L367-379 and L400-407; `src/scout/reconstruct/native/native-provenance.ts` L90-111 (`recordUnresolved`, `update: { native_kind, reason }`), precondition comment L90-92.
- Behaviour: when `recordNoNativePrincipal` is true and provenance for the identity is already `created`, the writer verifies the target (`verifyTarget`, L65-88). If verification fails because the coach archived or deleted the plan, control falls through to the evidence upsert and then `recordUnresolved(... no_native_client_principal)`, whose `update` branch rewrites the CREATED row's `reason` to `unresolved:no_native_client_principal` while `outcome` stays `created` and `native_id` remains set.
- Concrete harm: provenance row becomes self-contradictory (outcome `created`, reason `unresolved:*`), violating the function's own precondition and contract §3.5 (L215: "Provenance exists but the coach archived or deleted the native row → `unresolved:native_target_removed`; do not recreate"). Reachable by data alone: first replay creates the plan, the coach removes it, a later replay of the same staged entity arrives client-linked without a native principal. Consumers keyed on `reason` (S8-G / audit) misclassify.
- Exact blocked decision: granting the single PG proof to `af9f7f54` **as the acceptance candidate** (a one-run proof spent on a head with a known contract deviation must be repeated after the fix).
- Smallest closure: in the `existing.outcome !== unresolved` branch, when `verified.ok` is false, return `failed(unresolved(UNRESOLVED_CODE.native_target_removed))` (or at minimum skip `recordUnresolved`) instead of falling through; one unit expectation in `native-writers.spec.ts`. Two-to-four source lines; no schema/contract/binding change beyond a 3-line v3 pin delta.
- Execution unlocked: single PG proof on the corrected head.

### B2 — enum map miss emits `invalid_value:<field>`, contract requires `enum_unmapped:<field>`
- Where: `src/scout/reconstruct/native/native-rules.ts` `enumField` L312-330 (L329 returns `invalid(field)` for an unmapped key); `src/scout/reconstruct/native/native-contract.ts` `UNRESOLVED_CODE` L37-49 lacks `enum_unmapped`, `unit_unknown`, `date_zone_unknown`, `no_native_destination`; `docs/decisions/2026-09-24-s8-native-contract.md` L295 and L397 (`type` → "else `enum_unmapped:type`"); the deviation is pinned by `test/scout/reconstruct/native/native-rules.spec.ts` L322-325 (`unresolved:invalid_value:type` for `kind: 'yoga'`).
- Concrete harm: the closed §3.7 code catalogue advertised in the contract is not what the writer emits; a source value merely absent from the spec's enum map is reported as an invalid value, so a spec author cannot distinguish "add a map entry" from "bad data", and S8-G reporting keyed on codes is wrong from the first run.
- Exact blocked decision: same as B1 (proof spent on a head whose unresolved-code surface will change).
- Smallest closure: add `enum_unmapped` to `UNRESOLVED_CODE`, use it in the map-miss branch of `enumField` only, update the one expectation at spec L322-325. Type-only branch; `invalid_value` remains for non-string/non-number raw values.
- Execution unlocked: single PG proof on the corrected head.

Note on B1/B2 disposition: neither is exercised by the PG spec, so neither would change the proof's runtime result; the harm is exclusively to the one-run proof economy and to acceptance. If the parent explicitly disposes both as deferred with a named owner (S8-G or an S8-C follow-up slice) and records that the eventual fix will require a new head + new proof, I have no remaining B against granting the proof to `af9f7f54`/v2.

### C — recorded and qualified, no blockers, fixes, controls or reruns
- (a) `SOURCE_RECEIPT.md` says 25 paths / 21 A for 527fe2bc; actual 24 / 20 A. v4's `CHANGED_PATHS_from_base.txt` "25 paths" is correct for af9f7f54 (adds `mapping-spec.spec.ts` M). Parent-qualified harmless.
- (b) `RECEIPTS.sha256` self-entry mismatch (see §3); 57/57 real receipts OK.
- (c) Gate evidence for 527fe2bc is composite: 26-suite affected run on the attempt-4 tree; 15-suite rerun on the attempt-5 tree; 2-suite rerun on the final tree `d87a9626` (attempt 6/7). No `write-tree` was logged for attempts 4-5, so the 11 suites not re-run after remediation (contract, module-graph, scout-entities.*, controller/migration/flag specs) are attested on earlier bytes. Qualification: the attempt 5→6 change is evidenced as test-only (`native-rules.spec.ts` L83 `7:`→`8:`), tsc/eslint/prettier/R75 hooks ran on the exact final trees, and the affected mapper/registry/service suites did run post-remediation. No rerun requested; acceptance CI will run the full suite.
- (d) Nine-pin `psql` hash is of `/usr/share/postgresql-common/pg_wrapper` (perl dispatcher), inherited from S8-B; the 18.6 client binary itself is not pinned. Version string is checked by the driver.
- (e) `supersetGroupId` shape `<n>:<parent>#group:<key>` vs §4.4 wording — consistent internally, documented in unit test.
- (f) Duplicate `order` among children → later child `invalid_value:order` instead of a tie-break; deterministic, fail-closed.
- (g) Engine `findMany` omits `entity_type`, so dispatch step-routing is nominal; behaviour unchanged from accepted engine.
- (h) Legacy workouts with NULL `target_kind` receive `scout_entity` on replay (typed ledger backfill); §3.6-consistent, noted for S8-G.
- (i) `promoteToCreated` unreachable from `persistProgram` L117-120 (dead path).
- (j) No rules declared → programs `missing_required_field:weeks` rather than a family-level code; fail-closed.
- (k) `native-rule-registry.ts` L262-266 documents the `nest-cli.json` asset need; `nest-cli.json` L11 already includes `scout/reconstruct/sources/*.json` — no change needed.
- (l) Generator re-ran idempotently in attempts 2-4 (same hash) before the "no replay" note.
- (m) `as WorkoutPlanTypeValue` plain assertion (R75-clean).
- (n) Filled v1 and v2 driver header L2 still reads "UNFILLED head pins; NOT RUN; NOT GRANTED" — stale comment only; refusal logic keys on placeholders, none remain (zero in v2).
- (o) Same-intent replay after coach removal reports `reconstructed:1` via accepted precedence (spec L548) — matches §3.5 "do not recreate"; S8-G owns completion semantics.
- (p) `prepare-binding-v2.sh` first invocation exited rc 1 at a `grep -c` zero-count idiom after substantive checks passed; hashes/log completed manually with identical commands (self-reported in `prepare-binding-v2.log`); I recomputed every v2 hash independently — all match.
- (q) `s8c/correction/` and `binding/v2/` exist alongside untouched originals; original `BINDING.sha256` 7/7 still OK.

### Positives (confirmed in source)
Typed handoff in the same transaction with precedence update (service L218-259, L300-347); target write before ledger; retry-once on P2002 → 409; legacy string path leaves `target_kind` untouched; `verifyTarget` enforces coach ownership and archived state; relationships resolved via provenance only; catalog match is exact `id`/`slug` (comment L167-172 cites `exercise-catalog.service.ts` `{ OR: [{ id }, { slug }] }`; confirmed at `src/exercise-catalog/exercise-catalog.service.ts` L91/L240/L262 in this head); create-only, never updates coach-owned rows; §3.6 revision rules; native module boundary (no Nest module additions, `module-graph.spec` unaffected); children ids length-prefixed to prevent parent/child collision; client-linked without principal → evidence + explicit unresolved, programs skipped; `RECONSTRUCT_FAMILY.programs` addition fail-closed for TrueCoach (now asserted by the follow-up test).

## 5. Decision for the single new PG-proof grant (not acceptance)

- Frozen candidate `527fe2bc` / v1 binding: **NOT GO** — superseded; its own gate carries a preserved Jest failure (`mapping-spec.spec.ts`) that the follow-up closes.
- Follow-up `af9f7f54` (tree `62a8071e…`) + `binding/v2` (driver `038d6af6…`, fixture `1a7faa5f…`): binding, proof sources, pins, gates and correction receipt are all verified and internally consistent; **no A**. Two **B** findings (B1, B2) remain open in unchanged source bytes. Under the grant's rule that no final GO issues while a B is open: **NOT GO as-is**.
- Path to GO (smallest): one ordinary follow-up head closing B1 + B2 (≈ 2 source files, 2 owned test expectations; `src/` change means the changed-file Jest set is `native-writers.spec`, `native-rules.spec`, `engine-handoff.spec`, `native-families.spec` plus genuine hooks), then a v3 binding with the same mechanical 3-line delta; I will review only that delta and recompute hashes. Alternatively, an explicit parent disposition deferring B1/B2 with a named owner converts both to C, after which my verdict for `af9f7f54` + v2 is **GO** for exactly one PG execution under a separate grant.
- Nothing here is a product-acceptance statement; acceptance awaits the runtime result and its own review.
