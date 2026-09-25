# S8-C independent review A — new-source, proof-source and binding review

Reviewer: independent S8-C reviewer A (T4 high). Scope per `execution/64e33dc7/S8C_INDEPENDENT_REVIEW_GRANT.md`: complete review of the NEW delta and the PG proof sources only; accepted parent bytes (`93389265`) not re-audited. Read-only throughout: no product, Git, runtime or lock writes; no installs, tests, compiles, PG probes or pushes; `REVIEW_B.md` not read. Written 2026-09-24 ~22:10 PDT (2026-09-25 ~05:10Z).

Decision sought: readiness for ONE new PG proof grant (single run of `binding/v2/s8c-pg-proof.sh`). Not product acceptance, not S8-F/S8-D/S8-E/S9, no reader/customer/flag activation implied.

## 1. Candidate identity (recomputed, read-only)

| Item | Value | How verified |
|---|---|---|
| Frozen candidate | `527fe2bc24f954b26c0485c90345f237ce39a09d`, tree `d87a96267c2ec4f4d79d83d26e6b2928a56c8a85`, parent `93389265a846095b846fa8f1fb0dad782fb6ee9f` | `git log -1 --format=%H%n%T%n%P` in `/home/user/workspace/worktrees/64e33dc7-s8c` |
| Test-only follow-up (current HEAD) | `af9f7f5438fa545394b6d28792411439ded66caf`, tree `62a8071e544e6a307537bd08c55b52e2a9af4e7d`, parent `527fe2bc…`; author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; subject "S8-C: assert TrueCoach programs family unresolved" | `git log -1`, `git rev-parse HEAD`, porcelain empty (0 lines, `--untracked-files=all`) |
| 527→af9f delta | exactly `test/scout/reconstruct/mapping-spec.spec.ts` +9/−1; `git diff --stat 527fe2bc af9f7f54 -- src prisma docs test/utils test/rls-g2-s8c.spec.ts test/scout/g2-s8c-db-guard.spec.ts` empty; patch sha256 prefix `a79caec23e981643` matches `correction/run/delta.patch` and `correction/mapping-spec.spec.ts.delta-from-527fe2bc.patch` | recomputed |
| Base ancestry | `93389265^{tree}` = `a315dd651b8c54c2e82f2260fcc6058f0d13b64a` = BASE_TREE pin | recomputed |
| Base→af9f changed paths | 25 (24 at 527 + the one test file) | consistent with `checkpoints/v4/CHANGED_PATHS_from_base.txt` (25) |

Six proof-file blobs, identical at 527fe2bc and af9f7f54 and equal to the driver pins:

| Path | Blob (both heads) | Pin |
|---|---|---|
| `test/rls-g2-s8c.spec.ts` | `9fc44a2b051bbb572df98c3a5914c06eb887264a` | EXPECT_SPEC_BLOB ✓ |
| `test/utils/g2-s8c-bootstrap.sh` | `8aa86de8164fef29d85ec6b0720ece0903fb8a70` | EXPECT_BOOTSTRAP_BLOB ✓ |
| `test/utils/g2-s8c-db.ts` | `a7d67217fe959f65daae9615e5f00806cc3764d3` | EXPECT_DB_BLOB ✓ |
| `test/utils/g2-s8c-pg-harness.ts` | `4059883d70c26aed46398af707645aaacb306868` | EXPECT_PGH_BLOB ✓ |
| `test/utils/g2-s8c-harness.ts` | `d5cbf8779007dddf3ae75db76d706e3050ef9ceb` | EXPECT_HARNESS_BLOB ✓ |
| `test/utils/g2-s8c-worker.cjs` | `484030636dee841bcd5aff1af42536128858ac77` | EXPECT_WORKER_BLOB ✓ |

Accepted-file pins in the driver (L100–106) recomputed at af9f7f54: all 11 match (`g2-s8b-db.ts 6b384f14…`, `g2-s8b-pg-harness.ts 6a3d80a1…`, `g2-s8b-harness.ts 02740722…`, `g2-s8b-bootstrap.sh 55ab8972…`, `g2-s8b-old-root.sh 72ef344b…`, `g2-s8b-db-guard.spec.ts 361c26bc…`, `rls-g2-s8b.spec.ts 0af1709f…`, migration dir `94c4d201…`, `prisma/schema.prisma 32e44110…`, `src/scout/reconstruct/sources a1a296ee…`, `jest.rls.config.js 44c96915…`). `src/scout/reconstruct/native/sources` absent (driver L109 would pass).

## 2. Binding hashes (recomputed with `sha256sum`, read-only)

Original filled binding `s8c/binding/` — every line of `BINDING.sha256` reproduced, and the file itself hashes to the parent-mailed value:

| File | sha256 | Match |
|---|---|---|
| `s8c-pg-proof.sh` (v1 filled) | `66a838ab51ab6486ec05ddd748dd39336bc1e9bed6dc19c48a46fb2e94e1c920` | ✓ parent mail / FINAL_PINS |
| `s8c-pg-proof.sh.unfilled` | `377c39223e2bce942af8e77fae86909cfe0bf9e6c49c0f6faf6d40936cfd4a78` | ✓ |
| `s8c-pg-proof.sh.diff-unfilled-to-filled` | `d5b8818184015f682f26cfdc0f0beea5d4e52798c852cf2d176f34c57ebd82a6` | ✓ |
| `s8c-fixture.sh` | `1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3` | ✓ = EXPECT_FIXTURE_SHA |
| `PINS.txt` | `b9df2be53a588de740b87f4717bc63eec1c9162f5a0d480434a373a2a7fc3c02` | ✓ |
| `README.md` | `a90b1aea6e362573e7fdc14a0d3c7022c8644f2aa0852bccc967b2fbc64d0dbb` | ✓ |
| `fill-pins.sh` | `611c7d7c378f98f0fbf2508a8c08da28ee4175877239919e65a02cf623b3dbad` | ✓ |
| `BINDING.sha256` (file) | `de827a3fc485c80e1a1ec2c567666425d558720c60e7610b7031b9854837b3af` | ✓ parent mail |

v2 binding `s8c/binding/v2/` — every line of `v2/BINDING.sha256` reproduced:

| File | sha256 | Match |
|---|---|---|
| `s8c-pg-proof.sh` (v2) | `038d6af62e09b0f7bce8bbc270e7283bcad06aa27b06daada898e1ac8281ee4f` | ✓ parent mail |
| `s8c-pg-proof.sh.v1` | `66a838ab…1920` | ✓ byte-identical to original filled driver |
| `s8c-pg-proof.sh.diff-v1-to-v2` | `d56b7db15f5801aeda98e731df3295fe7538959f05798b7641e6ae633bde755a` | ✓ |
| `s8c-fixture.sh` | `1a7faa5f…07b3` | ✓ unchanged |
| `PINS.txt` | `62ad8898e2771a58a42f1cef03389412ff4af2b8f7c306ddfd77cc7d3113c516` | ✓ |
| `PINS.txt.diff-v1-to-v2` | `9438cd938fb97431d8f9ace07716797339bb2048fe39ffc821528d501ad55c72` | ✓ |
| `README.md` | `a90b1aea…0dbb` | ✓ unchanged |
| `v2/BINDING.sha256` (file) | `2d04c03b0743a3a199b65c1b9bd260845d6804da4b9f42a408c099e08ad71c29` | recorded here for the parent |

v1→v2 driver delta read in full: exactly three lines — `D=…/binding` → `…/binding/v2` (L23), `EXPECT_HEAD` → `af9f7f54…` (L31), `EXPECT_TREE` → `62a8071e…` (L32). No other byte differs. `PINS.txt` delta: the same two pins plus two mechanical path strings (header comment, RECEIPTS path). Zero `__` placeholders remain (driver L82 check would pass).

Tool pins recomputed read-only against the runtime (all equal to driver L41–49 / FINAL_PINS): `pg17/dist/bin/postgres 23cd1748…`, `initdb b7db9bc2…`, `pg_ctl af53d826…`, `readlink -f /usr/bin/psql a200e38c…`, `readlink -f $(command -v node) a03953a7…`; in the worktree `prisma/schema.prisma 77f33bcd…`, `package-lock.json b7fed5ed…`, `node_modules/.package-lock.json 05bc530a…`, `node_modules/.prisma/client/index.d.ts b6716a86…`; `node_modules` is a real directory resolving inside the worktree (L111–112 pass); `pg17/PROVENANCE.txt` has `result=success`; `RUNTIME_ROOT` is a real path; hooks dir `growth-project-backend/.git/hooks` `pre-commit`/`commit-msg` both contain `lefthook` (L96–97 pass); canonical lock file present, inode 691716 (matches correction-gate log).

## 3. Driver / fixture / bootstrap compatibility (inspected, not executed)

- Env exported by the driver (L57–60) is exactly what the guard/harness read: `G2_S8C_DATABASE_URL=postgresql://s8c_super@127.0.0.1:55642/g2_s8c_disposable?schema=public&connection_limit=4` (no password in URL; guard requires that), `G2_S8C_CONFIRM=g2_s8c_disposable:55642`, `G2_S8C_PASSWORD`, `G2_S8C_PSQL=/usr/bin/psql`, `G2_S8C_DATA_DIRECTORY=$RUNTIME_ROOT/clusters/s8-c/pg-data` (fixture `initdb -D` uses the same absolute real path, so `current_setting('data_directory')` equality in the spec lane-identity case holds), `G2_S8C_SERVER_VERSION=170006`, `G2_S8C_CANDIDATE_HEAD=$EXPECT_HEAD` (spec asserts `git rev-parse HEAD` equals it and base is an ancestor).
- Marker literals present and checked in the driver: `cluster_name=s8c-disposable-pg17` (init marker L146, identity L162) and DB comment `s8c-g2-native-writer-synthetic-disposable-fixture-safe-to-drop` (L164); 171 applied migrations (L165); fixture refuses standalone invocation unless `S8C_RUNNER_PID` names a live `s8c-pg-proof.sh` (fixture L30–31; v2 path still contains that basename), fresh-init-only (L47), marker-gated start/destroy.
- Jest invocation: `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand --ci`, single run, sentinel written on every exit (`finish`), lock held on fd 9 to exit.
- Worker builds `ScoutReconstructService` and injects the fixture spec/rules through `buildFamilyRegistry({sourceMappers, nativeRules})` (worker L110–119) — this is the seam the A finding below turns on.

## 4. Findings

### A1 — the legacy `client_history` proof case cannot pass against the real service; the single PG run would fail on a fixture defect

Location (blob `9fc44a2b…`, identical at 527fe2bc and af9f7f54): `test/rls-g2-s8c.spec.ts` L512 `stage('h-1', 'client_history', { title: 'Ran 5k', client_id: 'c-1' })` — `stage()` (`test/utils/g2-s8c-harness.ts` L97–109) defaults `platform` to `PLATFORM = 's8c-proof'` (L16). L514 `run({ ...REGISTRY, family: 'client_history' })`; L516 expects `{ staged: 1, reconstructed: 1 }`; L527–531 expect the ledger row `status: 'reconstructed'` with truthy `target_id`.

Source (blob at both heads): `src/scout/reconstruct/families.ts` L63 `const sourceMapperRegistry = buildSourceMapperRegistry();` (repository sources only: `truecoach`, `conformance_*`); `genericEntityFamily` L112–120 (`client_history`) and `clientsFamily` L75–79 call `sourceMapperRegistry.get(row.source_platform)` and return `unsupported_platform:<platform>` (L66–68) when absent. `buildFamilyRegistry` L167–181 forwards `options.sourceMappers` only to `buildNativeFamilies` (L170–173); L177 constructs `genericEntityFamily(RECONSTRUCT_FAMILY.client_history)` with no injection. The worker's injected `REGISTRY` (worker L115–118) therefore never reaches the legacy family. For `h-1` on `s8c-proof` the real service returns `unsupported_platform:s8c-proof` → `skipped: 1, reconstructed: 0`; L516 fails, then L527–531 fail. The builder's own unit test states the same behaviour and stages the legacy row on `truecoach` for that reason (`test/scout/reconstruct/native/native-families.spec.ts` L221–228).

Concrete harm: a certain red run of the one granted proof on a test-fixture defect, consuming the sentinel (`finish` writes it on every exit; L63 refuses a second run) and the heavy slot, with no information gained about the native writer.

Blocked decision: issuing the single PG grant for `binding/v2/s8c-pg-proof.sh` at `af9f7f54` (and, equally, v1 at `527fe2bc`).

Smallest closure (test-only, no product file): in `test/rls-g2-s8c.spec.ts` L512 stage `h-1` on a repository source, e.g. `stage('h-1', 'client_history', { title: 'Ran 5k', client_id: 'c-1' }, 'coach', 'intent', 'truecoach')`. Checked read-only: `truecoach.json` declares `client_history` with `label` paths `title`/`name` and `clientSourceId` path `client_id` (so the payload maps); `truecoach` is canonical (R CHECK / `isCanonicalPlatform`); the service does not match the staged platform against the `ScoutImport` row (`settle()` inserts coach/intent/state/terminal_status only); `byKey(ledgerRows(), 'client_history', 'h-1')` (spec L79–80, harness L123–128) filters by coach/intent/entity_type/source_id, not platform; the L532 provenance filter is unaffected (legacy path writes evidence, not provenance); the pre-inserted `legacy-1` row (L510–511) is untouched. Same shape as the parent's mapping-spec correction: one ordinary hooked Bradley follow-up, changed-file gate only, then a v3 binding whose only deltas are `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` and the `D=` path.

Execution unlocked: the single PG proof grant on that follow-up head with the v3 binding, reviewed delta-only.

### B1 — child provenance `entity_type` deviates from the accepted native contract and the proof pins the deviation

Location: `src/scout/reconstruct/native/native-writers.ts` L287 `const childKey: ProvenanceKey = { ...provenance, sourceId: child.childSourceId };` — children inherit the parent's `entityType` (`workouts`); `native-provenance.ts` L315–325 `countUnresolvedChildren` is consistent with that (prefix + `native_kind` filter). `docs/decisions/2026-09-24-s8-native-contract.md` §3.3 / §4.4 specify child rows under `entity_type = 'workouts.exercise'`. Proof spec L242–263 `byKey(provenance, 'workouts', childSourceId(...))` and L264 (row count 5) pin `'workouts'`.

Concrete harm: a green proof would attest a contract non-conformance as the accepted native-provenance shape; a later conformance fix would invalidate the proof and re-open S8-C. Reader harm is nil today (S8-F READINESS routes by `target_kind`/`native_kind`/`native_id`; length-prefixed `childSourceId` keeps parent/child identities disjoint in practice).

Blocked decision: the parent must dispose of one of two options before the PG grant, because the grant fixes the spec bytes: (a) record a contract amendment (child `entity_type` = parent family; identity separation via `childSourceId`'s `<len>:<parent>#…` encoding) — record-only, no source change, current blobs stand; or (b) grant a narrow change to `native-writers.ts` L287 (`entityType: 'workouts.exercise'`), `countUnresolvedChildren`, the native unit tests and proof spec L242–264, then re-gate and re-pin. Option (a) is the smallest closure and combines with the A1 follow-up without an additional round.

Execution unlocked: the single PG grant under an unambiguous contract; a B-class item cannot remain open under it.

### C — record and qualify (no blockers, fixes, controls or reruns)

1. Sentinel on preflight failure. Driver `fail` → `finish` writes the sentinel for every non-zero exit after L65, including preflight rc 71 (port 55642 busy, any `postgres` process alive, other lane `postmaster.pid`). `clusters/` currently contains an `s7l` lane; the parent reports S7-L now uses the heavy slot for its first PG. If the S8-C grant is executed while an S7-L postmaster survives, the single run is consumed by an environmental refusal, not by the candidate. Inherited S8-B binding semantics; qualified only — the flock (exit 75 before any sentinel) covers the concurrent case, not a stopped-but-surviving postmaster.
2. `supersetGroupId` = `<len>:<parent>#group:<key>` (`native-contract.ts` L153–155) vs contract §4.4 `<parent source_id>:<group key>`; more injective; free-string column; no reader depends on the format.
3. `UNRESOLVED_CODE` (`native-contract.ts` L75–87) omits contract §3.7 `enum_unmapped`, `unit_unknown`, `date_zone_unknown`, `no_native_destination`; `enumField` (`native-rules.ts` L312–330) reports an unmapped enum as `invalid_value:<field>`; units are declared in rules so `unit_unknown` is unreachable. Unreachable in production (no sidecar shipped); truthful codes.
4. `interpretProgram` with no declared rules → `missing_required_field:weeks` (truthful fail-closed).
5. Exercise `order` falls back to the source ordinal when no rule (`native-rules.ts` L565) — legitimate source ordinal per §4.4, not a default, so no `defaulted:` tag; correct.
6. `persistEvidence` (`native-writers.ts` L359–409): an existing CREATED provenance whose `verifyTarget` fails falls through to evidence upsert plus `recordUnresolved` on a CREATED row (reason set while outcome stays `created`). Rare edge; for acceptance-time attention, not proof-blocking.
7. Later-removed target (spec L535–568): writer returns `native_target_removed` skipped; ledger precedence (service L338–346) keeps `reconstructed`; tally reads the ledger (L349) so the result shows `reconstructed: 1` while the target is gone. Accepted S8-B/N semantic, S8-G owns; the spec asserts it correctly.
8. Engine does not forward `entity_type` to `map()` (builder C1 acknowledged); dispatch token falls back to the family; A3 guard via `resolveStagedFamily`; `conformance_beta` `programs` step→`workouts` correctly refused `unresolved_family:programs`.
9. Historical NULL-kind `workouts` ledger rows replayed through the evidence path receive `target_kind='scout_entity'` (an actual re-persist, not a guess); legacy `clients`/`client_history` rows keep NULL kind — asserted at spec L518–531.
10. No `native/sources/` directory → empty native rule registry → production `workouts` stay on the evidence path; `import_intent_id` written NULL (builder C2). Driver L109 enforces absence.
11. Worker assigns `service.families` (TS `private readonly`, runtime assignment; same as the tq0/S8-B heritage); worker runs as `service_role` (BYPASSRLS); harness DDL/DML as `postgres`; admin `s8c_super` only for `pg_stat_activity`. Bootstrap is single-shot (exit 3 if public tables exist), refuses a foreign `cluster_name`, refuses hosted roles, verifies prisma tree == base, 171 migrations, no `npm ci`, `PRISMA_GENERATE_SKIP_AUTOINSTALL=1`, engine/runtime sha equality, generated-client schema comparison. `g2-s8c-db.ts` refuses 55641/55511 and other lanes' ports, requires `G2_S8C_CONFIRM=g2_s8c_disposable:<port>`, username `s8c_super`, no URL password.
12. Fixture-row checks passed read-only: `s8c-proof` is canonical (regex and R CHECK `^[a-z0-9][a-z0-9._:-]{0,255}$`); `ScoutImport` has no FK to `ImportIntent` (settle without intent row is fine); required columns satisfied for `User`/`ScoutImport`/`ScoutIngestEntity`/ledger/`ExerciseCatalogItem` inserts; `ExerciseCatalogItem` is global (no `coach_id`) per §4.4; `weight_lbs` Float (float8 round-trip exact); `WorkoutPlanType` enum strength/cardio/mobility; unknown family → `BadRequestException` (service L71) → 400 as the spec expects; families Map order `clients, workouts, client_history, programs`.
13. Remaining PG cases walked against source (replay idempotence and the `not.toMatch(/INSERT INTO "public"."WorkoutPlan"/)` regex — closing quote excludes `WorkoutPlanExercise`; program-day pending → converge with `unresolved:relationship_pending:programs` formatted by `unresolved()` L67–76; client-principal deferral marker + `unresolved:no_native_client_principal`; tenant isolation; paused-worker contention → P2002 → single retry converges; held ledger identity → lock wait observed → ROLLBACK → retry with `updateMany` precedence). All consistent with the implementation; A1 is the only case that fails by construction.
14. Parent's own C items preserved as stated: original gates manifest self-hash failed only on its self entry; 57 receipt files OK; original receipt path count 25 vs actual 24 harmless. `prepare-binding-v2.sh` first invocation rc 1 at a `grep -c` zero-count idiom after substantive checks passed; log/hashes completed with identical commands (`v2/prepare-binding-v2.log`) — recorded, not re-run.
15. Correction gate receipts read, not rerun: `correction/run/jest-changed-file.log` 1 suite / 40 tests passed; eslint and prettier logs clean; `s8c-correction-gate.log` ACQUIRED 05:01:41Z inode 691716 → STAGED_TREE `62a8071e…` → HEAD `af9f7f54…` → RELEASED 05:02:44Z; `commit.raw.log` hooks prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc (48.38 s), no-ai-tokens all ✔. The one-file delta is within `S8C_MAPPING_EXPECTATION_CORRECTION_GRANT.md`: `notes` assertion retained verbatim; `clients`/`workouts`/`client_history` still `{ ok: true, family }`; explicit `programs` branch asserts `{ ok: false, reason: 'unresolved_family:programs' }`; title adjusted descriptively; `truecoach.json` unchanged (`src/` tree identical).
16. Module boundary: unit test `native-families.spec.ts` L245–277 pins the allowed import set for `src/scout/reconstruct/native/*.ts`; `nest-cli.json` unchanged; no `native/sources` directory. Consistent with the read source.

## 5. Decision for the single new PG grant

**NOT GO** for a PG grant on `af9f7f54` / `binding/v2/s8c-pg-proof.sh` (`038d6af6…`), and likewise on `527fe2bc` / v1 (`66a838ab…`).

Reason: A1 — `test/rls-g2-s8c.spec.ts` L512–531 asserts a legacy `client_history` reconstruction on the fixture platform `s8c-proof`, which the unchanged legacy family path (`families.ts` L63, L112–120, L177) cannot map; the granted single run would fail deterministically and consume the sentinel. B1 must also be disposed (amendment record or narrow change) so the proof does not pin an unamended contract deviation.

Everything else reviewed is ready: candidate and follow-up identity, six proof blobs, eleven accepted-file pins, nine tool pins, fixture hash, both bindings' hashes, driver/guard/bootstrap/spec compatibility, and the one-test correction.

Path to GO (for the parent; not a directive to the builder): one test-only Bradley-authored hooked follow-up changing only `test/rls-g2-s8c.spec.ts` L512 platform argument (closure in A1) with a changed-file gate; parent disposition of B1 (option (a) is record-only); `binding/v3/` with exactly `D=`, `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` changed and hashes recorded. Reviewer A will then review only that delta and the v3 pins and report GO/NOT GO for the single run.

No product acceptance, S8-F reader activation, customer/flag exposure, S8-D/E, S9 or production decision is implied by anything above. Source isolation from S7-L and S8-F preserved (no S7-L/S8-F files were read except `s8f/READINESS.md` for reader-routing context).
