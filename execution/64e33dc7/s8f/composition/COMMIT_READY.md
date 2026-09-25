# S8-F COMMIT_READY — grant S8F-COMP-1 phase 2 (parent mail 2026-09-25 11:06 PDT)

Builder: sole T4 `s8f_composition_prep`. Worktree `/home/user/workspace/worktrees/daceddc8-s8f`, branch `exec-dace/s8f`.
Committed, NOT pushed. Real-PG binding DRAFTED and pin-filled, NOT run. Evidence repo NOT committed.

## 1. Result

| item | value |
|---|---|
| HEAD | `e1ec2fecb71f315b6721d426ba0dacb84f304498` |
| tree | `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6` |
| parent | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` (land/s8-c head named by the grant; exactly one commit on it) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (both), date 2026-09-25T18:19:40Z |
| subject | `S8-F native readers report typed entity targets and the roster bridge qualifier` |
| files | 17 changed, 1869 insertions, 49 deletions (5 created; `test/utils/g2-s8f-bootstrap.sh` mode 100755) |
| hooks | genuine lefthook pre-commit: prod-readiness-quick, banned-cast-tokens (check-r75 staged), prettier, eslint, tsc — all passed; commit-msg `no-ai-tokens` passed. No `--no-verify`, no amend, no rerun. Log: `gates/commit.raw.log` |
| message | `commit-message.txt` (sha256 `756b6650…`); no trailer-like `^[A-Za-z-]+: ` lines; no R3 tokens |
| worktree after commit | porcelain empty (untracked-files=all) |

### Blobs at e1ec2fec (also `gates/HEAD.txt`, `checkpoints/v1/BLOBS.txt`)
```
8060a3685e707d88a4ccf65fe19e3f111a70e53c 100644 src/scout/scout-entities.controller.ts
8b0f8ec063344702e13139a69d9165b8479fc6cc 100644 src/scout/scout-entities.dto.ts
77db2ee4f72993b22db8af19e730c2cbd155462a 100644 src/scout/scout-entities.service.ts
02904b3db04a3245eab32d8cc070f0bef5d9670d 100644 src/scout/scout-roster.controller.ts
939713d7846fe1020074c9e77840f16f11a89ac2 100644 src/scout/scout-roster.dto.ts
4435cbf03805a15daab0964b79c98098b438a828 100644 src/scout/scout-roster.service.ts
1b2f183e3a0dc7e55da6b7b9a5bb77c2345bcccb 100644 test/scout/entities/scout-entities.contract.spec.ts
b16d0b752ae3da384420dc41f8a9ade5f51c2c54 100644 test/scout/entities/scout-entities.service.spec.ts
1c94e4de73557b2c46c2a7c16c117cd1e92ac43f 100644 test/scout/roster/scout-roster.controller.spec.ts
882ad737f5ebfe03549ad7eaef10c3f36ec66fd1 100644 test/scout/roster/scout-roster.service.spec.ts
77785ec5fa3d0bb15731ba7787c4ede4968eb51d 100644 test/rls-g2-s8f.spec.ts
9d1042a432f13d3f49409ca436e3cffad152da6f 100644 test/scout/g2-s8f-db-guard.spec.ts
5ac2753bdc0498899d1a9eef297ef4acc467ccb8 100755 test/utils/g2-s8f-bootstrap.sh
aeff4cb0f06d0d65b969bf7742c1d8cf377f4c79 100644 test/utils/g2-s8f-db.ts
a8acd231d10194d4552546339a7a4309c86fb8d4 100644 test/utils/g2-s8f-pg-harness.ts
4300eec371c3edbde48cf058e6f1f06021924b60 100644 test/contracts/importer-contract.spec.ts
8ebf936a9f12087a807cb37b069592d0c1e96cb2 100644 docs/contracts/importer-openapi.json   (sha256 9eacdd3eda125ab13c0a67bfeaed963a6eeabe0e431ff72e8b1d0cf4c7f74870)
```
Unchanged at head (pinned in the binding): `prisma/schema.prisma` 2e328bbc (sha256 0eb41f9a…), 172 tracked migrations, `jest.rls.config.js` 44c96915, `scripts/ci/supabase-shim.sql` 0f99f924, `src/scout/reconstruct/native` tree dfd8ef66, S8-C proof files a7d67217 / 7c3fba47 / 9d701783, `test/utils/g2-tq0-worker.cjs` aa35e7e2.

## 2. Branch move and overlap resolution (recorded per COMPOSITION_READY.md plan)
- `git checkout -b exec-dace/s8f 1c10e2a1` in the S8-F worktree; the 15 uncommitted paths were carried unchanged
  (15/15 sha256 equal to `MANIFEST.sha256` of the frozen composition checkpoint).
- Overlap check 87018a42 → 1c10e2a1 (34 files: S7-L lifecycle, generator CONTRACT_VERSION `2.0.0-c1-s2.0`, S8-C
  guard fix): the 10 tracked S8-F paths are byte-identical at both heads; the 5 new files are absent at 1c10e2a1.
  **No path overlap; no composition edit was needed.** The only extra source edit was the planned one outside the 15:
  `test/contracts/importer-contract.spec.ts` (frozen S7-L pin of `ReconstructedEntityDto` properties now lists
  `native_id` and `target_kind`; +4 lines incl. a two-line comment). Contract version left at `2.0.0-c1-s2.0`
  (additive fields only; the generator `scripts/importer-contract.ts` is outside the S8-F surface — a bump, if the
  parent wants one, is a separate generator-owner change).

## 3. Gate receipts (one script `s8f-gate.sh`, sha256 `85ddc0eb7aa8b2f4ea20631604bcf4fbee30cad00cb0da90621e7da82381cd10`; log `gates/s8f-gate.log`; manifest `GATES_MANIFEST.sha256`, 25 files)
Lock: `flock -n` on `/home/user/workspace/execution/test-validation.lock` fd 9, inode 674373, ACQUIRED 18:13:04Z,
released at process exit 18:20:33Z (file preserved; another lane took it afterwards). Zero postgres / heavy processes
at acquisition. No PG, no proof.

| gate | receipt |
|---|---|
| preflight | HEAD 1c10e2a1, branch exec-dace/s8f, delta exactly the 16 prepared paths, index empty, no node_modules; prettier prefix manifest 56/56 OK; node v20.20.1 sha a03953a7 |
| runtime | `cp -a` from `daceddc8-land-s8-c/node_modules` (649 entries): `.package-lock.json` 05bc530a…, client `index.d.ts` 9042e713…, client `schema.prisma` b8439203… (donor and copy equal); `npx --no-install prettier --version` = 3.9.9 via offline prefix; heap 4096 |
| contract regen 1 | `npm run -s contract:importer` rc 0; before 77d5ffd1… (blob f9109c06) → after 9eacdd3e…; numstat +28/−4; `gates/contract-delta.patch` |
| contract determinism | second cold process with `IMPORTER_CONTRACT_OUT=gates/contract-scratch.json` rc 0, `cmp` byte-identical |
| contract semantic check | `gates/contract-semantic-check.json` rc 0: version unchanged `2.0.0-c1-s2.0`, 15 paths / 36 schemas unchanged; `ReconstructedEntityDto` += exactly `native_id` (uuid, nullable) + `target_kind` (enum scout_entity/workout_program/workout_plan); `ScoutRosterResult` += exactly `roster_bridge_pending` (boolean, required); family enum `[workouts, client_history, programs]`. Observed text-only deltas: the two `@ApiOperation` descriptions and the `id` property description (all from the frozen DTO draft). Nothing else changed in the artifact; only the expected 17 paths were touched |
| prettier 3.9.9 | `--check` on 17 paths rc 1 → `--write` rc 0 → `--check` rc 0. Format delta 52 lines in 3 files (`gates/prettier-format-delta.patch`): `scout-roster.service.ts` (one chain joined), `test/rls-g2-s8f.spec.ts` (two calls wrapped), `test/utils/g2-s8f-db.ts` (one const wrapped). Artifact json untouched by prettier (sha unchanged) |
| eslint | `--no-warn-ignored --max-warnings 0` on the 15 .ts paths: rc 0, empty log |
| tsc | `tsc --noEmit` heap 4096: rc 0, empty log |
| jest (L2-2) | default-config `--listTests` snapshot; import closure ∩ default = 15 specs; fs-pinned (regex `prisma/migrations\|['"/]migrations['"]\|docs/contracts\|importer-openapi\|EXPECTED_MIGRATIONS\|BASE_HEAD`, via `rg` so the new untracked spec was included) ∩ default = 20; union 33 suites (`gates/affected-suites.txt`, includes `test/scout/g2-s8c-db-guard.spec.ts`, `g2-s8f-db-guard`, `ci/delivery-artifact`, `invariants/locked_defaults`, `migration-backfill-parity-r2`, `wearables/metric-bucket.map`, `openapi-spec`, `module-graph`, `roles-enforced`). `jest --ci --runTestsByPath`: **33 passed / 33; 666 passed, 11 skipped, 677 total; 102.8 s** (`gates/jest-affected.raw.log`). Skips are inherited: `ai-credits-stream1` (4 literal), `throttler.module` (1), `scout-entities.rls.live` (describe.skip wholesale without a live DB URL). No S8-F test is skipped; F03 runs against the `programs` family |
| post-gate | delta still exactly the 17 commit paths; `gates/pre-commit-source.sha256` |
| commit | `git add` 17 paths, staged tree = 2fe0201f = committed tree; hooked `git commit -F commit-message.txt` rc 0 (hook summary 49.5 s); parent, identity, clean porcelain verified |

## 4. Checkpoint export
`64e33dc7/s8f/checkpoints/v1/`: `s8f-e1ec2fec.bundle` (1c10e2a1..exec-dace/s8f, `git bundle verify` OK), `files/<17 paths>`
(each hashed equal to the head blob), `e1ec2fec-vs-1c10e2a1.patch`, `HEAD.txt`, `BLOBS.txt`, `MANIFEST.sha256` (21 entries,
verifies). Directory read-only.

## 5. Real-PG binding v1 (`64e33dc7/s8f/binding/v1/`, drafted, pins filled, NOT RUN)
`BINDING.sha256`:
```
e4b73c5923149399f89a0656a016ecd4a9fecea232b4bebceca391988f54b150  s8f-pg-proof.sh
88e8b2f3123b425211ba9e05c2add93b21a7fc6f5ed8d2bfbf9fd2018e362f30  s8f-fixture.sh
4c1793ea775c06e03deb2d4d7e1b5392ee99b7e80e8b6d7a18cf6f666c7d4f17  s8f-pg-proof.sh.unfilled
e74c3421e3b11d4822adb77ff9d982775e6acecf975992db4f8dafe606369db2  unfilled-to-filled.diff
dfdc28c1b90a575e260095679018087be4613f1e3dd11b20a1a5ea5a8087d47b  PINS.txt
2f229a69fe2fc7fbbfbbf84e0f0100d7e052e675a75879a7f7567887fdec26b7  README.md
a53f1c63ece9e4c51537cdca2f5b9801a37632084a2050d71ee89b99584aa082  tool-pins-reverify.txt
```
Shape (substitution from S8-C v4): port 55643, DB `g2_s8f_disposable`, admin `s8f_super`, cluster `s8f-disposable-pg17`,
DB marker `s8f-g2-native-reader-synthetic-disposable-fixture-safe-to-drop`; env exactly `G2_S8F_DATABASE_URL`
(`connection_limit=2`), `G2_S8F_CONFIRM`, `G2_S8F_PASSWORD`, `G2_S8F_PSQL=/usr/bin/psql` (18.6, a200e38c), `G2_S8F_SERVER_VERSION=170006`;
fresh lane `recovery-reset/proof-s8f-v1/clusters/s8-f` + socket `proof-s8f-v1/run/s8-f`; other lanes enumerated by
`clusters/*/` and `proof-*/clusters/*/` minus the own lane (today proof-v4/{s7l,s8-c}, proof-v5/s8-c), hashed pre/post, never
started; bootstrap `bash test/utils/g2-s8f-bootstrap.sh` (no subcommand; asserts applied == tracked, S8-B catalog shape);
identity stage pins applied migrations == 172; `jest --config jest.rls.config.js test/rls-g2-s8f.spec.ts --runInBand --ci` once;
data dir retained. Head pins filled by sed of seven `__FILL_AFTER_COMMIT__` values from e1ec2fec (see PINS.txt); all ten tool
pins re-verified read-only against live binaries (`tool-pins-reverify.txt`, all equal). Extra S8-F preconditions: head is exactly
one commit on 1c10e2a1 and the base..head delta is exactly the 17 S8-F paths (regex-checked), bootstrap mode 100755.

### Harness NOT NULL no-default audit (grant requirement; schema at 1c10e2a1)
Every table the harness / spec INSERTs into, with its NOT NULL no-default columns and the supplying code:
- `User`: supabase_id, email, name — supplied (role has default; no updated_at column).
- `ScoutImport`: coach_id, intent_id — supplied; state/mode/execution_epoch default; `mode_shape` CHECK satisfied
  (legacy mode, `import_intent_id` NULL, terminal_status `success`).
- `ScoutReconstructionLedger`: coach_id, intent_id, entity_type, source_id, source_platform, status — supplied (target_kind nullable).
- `ImportNativeProvenance`: coach_id, source_namespace, entity_type, source_id, native_kind, outcome — supplied.
- `WorkoutPlan`: coach_id, name, type, **updated_at (`@updatedAt`, no DB default)** — supplied explicitly (created_at too).
- `WorkoutProgram`: coach_id, owner_user_id, name, weeks, days_per_week, **updated_at** — supplied explicitly.
- `ScoutReconstructedEntity`, `Person`: updated_at has `@default(now())`; remaining NOT NULLs supplied.
Enums used (`Role.coach`, `WorkoutPlanType.strength`) exist. **Conclusion: no harness change required.**

### Baseline-count note
The spec asserts API page counts over intent-scoped rows after `resetData()` (deletes all rows of the 7 fixture tables) and
a role-denial `count(*)` accepting `'0'` or permission-denied. No absolute count over a seeded/shared table is asserted, so the
grant's baseline rule is satisfied without a change.

### db-guard note
`test/scout/g2-s8f-db-guard.spec.ts` pins markers, roles and refused ports and asserts **no** migration list (composition-tolerant);
the bootstrap asserts `applied == tracked` dynamically; the runner's identity stage pins 172 = the base-prefix history
(S7-L + S8-C composed head; S8-F adds no migration). Base-prefix-only is therefore asserted at the runner level; nothing in
the repo guard names a migration directory.

## 6. Not done / needs parent
- No push; no evidence-repo commit; no PG proof (binding v1 awaits a separate single-run grant).
- Contract version unchanged (`2.0.0-c1-s2.0`); if a bump is wanted for the additive S8-F fields it is a generator-owner change
  to `scripts/importer-contract.ts` outside the S8-F surface.
- `daceddc8-s8f/node_modules` (isolated copy, 469 MB) left in place for the binding's precondition checks.
