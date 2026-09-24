# S8-B — SOURCE READY (phase 2 complete; hooked commit exists; PG NOT run; STOPPED as instructed)

Grant: parent mail 2026-09-24 ~21:57Z per `execution/ce3748cb/POST_C_SEQUENCING.md` (phase-2 fill of `s8b/DRAFT_READY.md`).
Builder: S8-B draft builder (sole writer of `s8-b` and `execution/ce3748cb/s8b/**`). 2026-09-24 21:58–22:10Z.
No model/effort claim is made. Nothing pushed. No PG process started; no cluster created or touched (`/home/user/pg17/clusters/`
still only `nq1`; `pgrep -cx postgres` = 0). `s7-nq1`, `s7-c`, `s7-l`, other lanes not written. `execution/ce3748cb/s8b/**`
append-only (phase-1 files kept in `phase1-snapshot/`; copies made before every replacement).

## Head
| item | value |
|---|---|
| **HEAD** | `edd6dc6b2c3ce82f64d567930edad27fbfc77255` on `s8-b`, parent **`1b6cc66164b3398d573ba92f0c8f6b039494be24`** (accepted C head; `merge-base --is-ancestor` ✔) |
| **TREE** | `5a4db6c9a833ea361c7259c57c38f85c8124aca0` |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both, `2026-09-24T22:04:46Z` (author date = committer date) |
| subject | `feat(importer): expand the native provenance ledger and type the reconstruction target` |
| trailers | none (`%(trailers)` empty). Body scanned: no co-authored/model/identity tokens. commit-msg hook `no-ai-tokens` ✔ |
| hooks | genuine lefthook v2.1.9 at `git rev-parse --git-path hooks` (`repos/growth-project-backend/.git/hooks`, shared by the worktree): pre-commit `prod-readiness-quick` ✔ `banned-cast-tokens` ✔ `eslint` ✔ `prettier` ✔ `tsc` ✔ (48.6 s); commit-msg `no-ai-tokens` ✔ (receipt 12) |
| `NODE_OPTIONS` | `--max-old-space-size=4096` exported for every tsc, Jest and for the commit |
| blobs | SPEC `test/rls-g2-s8b.spec.ts` = `bd94ef73847a9d8de114f989a92b3205adb62470` (641 lines; 4 describes, 13 `it`); BOOTSTRAP `test/utils/g2-s8b-bootstrap.sh` = `55ab89729f65bbd016ba90a2aa875fc24adabd24` |
| worktree | clean after commit and after export: `git status --porcelain --untracked-files=all` = 0 lines (node_modules `.gitignore`d) |
| migrations diff vs 1b6cc661 | exactly `prisma/migrations/20270122000000_scout_native_provenance_expand/{migration.sql,down.sql}` (runner precondition ✔) |
| continuity | every S5/B/R/N-Q1/C blob pin in the runner (39 pins incl. the R and C migration trees) verified against HEAD, 0 mismatches; OLD-side writer/reader files (`scout-reconstruct.service.ts`, `scout-roster.service.ts`, `scout-entities.service.ts`, `reconstruct/families.ts`) byte-identical to 1b6cc661 (receipt 13, 58/58 OK) |
| schema | `prisma/schema.prisma` sha `77f33bcdc36802f8e1d52553d011f546f56f757cacb391f23436ab266a148589` = the sha the S8-B-only `prisma generate` ran against (receipt 03) → client `index.d.ts` `b6716a865a705ffc0efab30ed88cd163b461e5344ad64e5926a0dff078b49f44` is consistent with the committed schema |

**Diffstat (1b6cc661 → edd6dc6b):** 10 files, +2108 −0 (`export/s8b-diffstat.txt`)
```
 prisma/migrations/20270122000000_scout_native_provenance_expand/down.sql      |  87 +
 prisma/migrations/20270122000000_scout_native_provenance_expand/migration.sql | 196 +
 prisma/schema.prisma                               |  33 +   (model ImportNativeProvenance; ledger target_kind String?; ImportIntent back-relation)
 test/rls-g2-s8b.spec.ts                            | 641 +
 test/scout/g2-s8b-db-guard.spec.ts                 | 124 +
 test/utils/g2-s8b-bootstrap.sh (+x) | 269 +   test/utils/g2-s8b-old-root.sh (+x) | 102 +
 test/utils/g2-s8b-db.ts | 117 +   test/utils/g2-s8b-harness.ts | 284 +   test/utils/g2-s8b-pg-harness.ts | 255 +
```
No `src/**` change at all (schema-only slice). Migration and down SQL byte-identical to the phase-1 drafts
(`6b55af3b…` / `b3779be8…`, see `phase1-snapshot/SNAPSHOT.sha256`).

## Steps of the grant
1. Snapshot `phase1-snapshot/` (9 worktree drafts + `binding-phase1/` + `DRAFT_READY.md`; `SNAPSHOT.sha256` 17/17 OK) →
   `git merge --ff-only 1b6cc661` on `s8-b` (zero commits to carry; untracked drafts carried unchanged).
2. schema.prisma hunk (+33 lines): `model ImportNativeProvenance` (11 fields; `@@unique(..., map: "ImportNativeProvenance_identity_key")`,
   two `@@index`, relation `fields: [import_intent_id, coach_id] references: [id, coach_id] onDelete: Restrict onUpdate: Cascade`),
   ledger `target_kind String?` with comment, `ImportIntent.native_provenance ImportNativeProvenance[]` back-relation (required
   by Prisma for the relation; no other model touched). `prisma validate` ok.
3. S8-B-only `prisma generate` in the isolated `s8-b/node_modules` (receipt 03; client `b6716a86…`; `s7-nq1` client untouched
   `92d42c56…`; hidden lock `05bc530a…` unchanged).
4. Re-pins: `OLD_HEAD=1b6cc661…` in `g2-s8b-pg-harness.ts`, `g2-s8b-bootstrap.sh`, `g2-s8b-old-root.sh`; `EXPECTED_MIGRATIONS=170`
   (both .sh), spec `EXPECTED_HISTORY = 170`; OLD-root gates now also require the C migration dir
   (`C_MIGRATION=20270121000000_scout_identity_contract`) — text "lacks E, R or C". No stale `29e60705`/`169` remains.
5. Gates below. 6. One hooked commit; pins, reseal, export below.

## Gates — receipts `s8b/receipts/` 01–13, sealed by `RECEIPTS.sha256` (12/12 OK)
| gate | result |
|---|---|
| prettier `--write` then `--check` on the 5 new .ts files | rc=0 (05; `schema.prisma` has no prettier parser, as at C) |
| eslint `--no-warn-ignored --max-warnings 0` on the 5 .ts files | rc=0 (06) |
| `bash -n` both .sh | ok (07); runner + fixture `bash -n` ok (binding) |
| tsc `--noEmit` whole tree with the S8-B client, heap 4096 | rc=0, 47.7 s (08); hook tsc ✔ at commit |
| check-r75 `--mode=staged` (after `git add` of the 10 paths) | rc=0 "no positive token change" (09); hook `banned-cast-tokens` ✔ |
| affected default Jest `jest test/scout test/contracts --ci` (C's set + the new guard) | **42 suites passed, 809 passed, 5 skipped (pre-existing), 0 failed**, 74 s (10). Includes PASS `g2-s8b-db-guard.spec.ts`, `g2-c-db-guard.spec.ts`, `scout-reconstruct.migration.spec.ts`, `scout-ingest.idempotency.spec.ts` |
| db-guard alone `test/scout/g2-s8b-db-guard.spec.ts` | PASS 44/44 (11) |
| static precondition check of the filled runner vs HEAD (read-only) | 58/58 OK, `fails=0` (13) |
| chain-harness PG15 dry-run | **not run (C, recorded):** no PostgreSQL server in this environment and the grant forbids a PG run; left to the PR's CI `migration-dry-run` (deploy → S8-B `down.sql` → re-apply → `pg_dump -s` compare) |
Canonical slot: `execution/test-validation.lock`, `flock` held per gate (never busy; never deleted). The Jest run was launched
detached (`setsid nohup`) and completed under the lock; every other gate ran in the foreground.

## Source corrections made during phase 2 (all inside S8-B-owned files; recorded)
- None to the SQL, spec, harness or guard beyond the re-pins in step 4 and the added C-migration presence gate in the two .sh
  helpers. No gate required a code change.

## Binding — `s8b/binding/`, `BINDING.sha256` resealed (`sha256sum -c` 8/8 OK)
| item | value |
|---|---|
| `s8b-pg-proof.sh` (filled) | sha256 **`3fbdcdb17a3885174b450ea8e668787b6ebb1c0ca3f0c83065f5eb072f11c59a`** |
| `derive-s8b-pg-proof.py` (phase 2) | `60e18f23fa19923fb5ee6ad8ace95f03df11cf863f40240601a618a5662bf1f9` — OLD_HEAD → 1b6cc661; N/Q1 blob pins moved to their 1b6cc661 values (pg-harness `d51267f2`, spec `a9338260`; the S7-L draft carried the 61b93cff blobs); eight accepted C blob pins added at the marked slot. Output kept as `s8b-pg-proof.sh.phase2-unfilled` (`8be755b8…`) |
| filled delta | `s8b-pg-proof.sh.diff-unfilled-to-filled`: header word + seven pin lines, nothing else |
| pins | `OLD_HEAD=1b6cc661…`, `EXPECT_HEAD=edd6dc6b…`, `EXPECT_TREE=5a4db6c9…`, `EXPECT_SPEC_BLOB=bd94ef73…`, `EXPECT_BOOTSTRAP_BLOB=55ab8972…`, `EXPECT_FIXTURE_SHA=360b093b…`, `EXPECT_NM_CLIENT_SHA=b6716a86…`, `EXPECT_NM_LOCK_SHA=05bc530a…` (unchanged), PG17 `postgres`/`initdb` shas unchanged; no `__` placeholder remains; `bash -n` ok |
| `s8b-fixture.sh` | unchanged `360b093b0f06360a45ad00cf6ed98d764f16d861227e827a466ba844d65b4b0b` (lane `clusters/s8-b`, port 55511, `s8b_super`) |
| phase-1 copies kept | `PINS.txt.phase1`, `README.md.phase1`, `BINDING.sha256.phase1`; phase-1 runner `e208f321…` under `phase1-snapshot/binding-phase1/` |
| `PINS.txt` / `README.md` | FILLED (`9a9e2a60…`) / phase-2 section appended (`3aa6b42d…`) |

## Export — `s8b/export/`, sealed by `EXPORT.sha256`
| file | sha256 |
|---|---|
| `s8b-edd6dc6b2c3ce82f64d567930edad27fbfc77255.bundle` (range `1b6cc661..s8-b`, one commit, prerequisite 1b6cc661; `git bundle verify` ok; head `refs/heads/s8-b` = edd6dc6b) | `5699fa1488cfb7a1bf7d907ba0812c09c99ad70daedf049e94e2bd0269465874` |
| `s8b-edd6dc6b2c3ce82f64d567930edad27fbfc77255.patch` (`format-patch 1b6cc661..HEAD --stdout`, 1 patch) | `53801fd18bc09968e44970af23567aeeacfc6a9d0a510fdbc3bb54db704eb9ce` |
| `s8b-diffstat.txt` | `f91718d7e71471f34fac8aee23ce416b41eb68c2adc45b470212bb0fd63385b4` |
Bundle written directly under `export/` (absolute path); worktree re-checked clean (0 porcelain lines).

## Recorded limits / deviations (all C)
- Phase-1 findings 1–13 of `DRAFT_READY.md` stand (notably: UNVERIFIED `pg_get_*def` rendering strings in `g2-s8b-harness.ts`
  — first PG run may need proof-string corrections; extra CHECKs/indexes beyond the contract minimum; down refuses on typed
  ledger rows too).
- `ImportIntent` gained a back-relation field (`native_provenance`) — Prisma requires it for the composite relation; it is a
  client-side field only (no column, no DDL). Recorded because the grant said "new model + ledger target_kind only".
- Two OLD-root helper gates were tightened in phase 2 (C migration dir required) — inside S8-B-owned files, no behaviour
  change for the accepted C head.
- The chain-harness PG15 dry-run is deferred to CI (above). Nothing else outstanding from the grant.

**PG NOT run. STOPPED at `s8b/SOURCE_READY.md`.** Next (parent): dual T4 attestation, then a single PG grant for
`s8b-pg-proof.sh` (`timeout -k 30 3600 bash execution/ce3748cb/s8b/binding/s8b-pg-proof.sh`; sentinel rc 76 semantics
unchanged). S7-L rebases onto edd6dc6b before its PG run if S8-B is accepted first (per POST_C_SEQUENCING). No push.
