# C — SOURCE READY B1 (B1 closure committed; PG NOT run; STOPPED as instructed)

Grant: `execution/ce3748cb/C_B1_CLOSURE_GRANT.md`. Builder: C phase-1 re-draft builder (sole writer). 2026-09-24 ~21:40–21:48Z.
No model/effort claim is made. Nothing pushed. No PG process started; no cluster touched; `s7-nq1`, `/home/user/pg17`, other lanes not written. `execution/cf8ff737/c/**` append-only (previous filled runner/BINDING/EXPORT kept as `*.phase2-16cd67f4`). `SOURCE_READY.md` (16cd67f4) left as-is; this record supersedes its head/pin/export tables only.

## The B1 hunk (the only source change)
`test/utils/g2-c-harness.ts` `narrow()` — +2 −1:
```
     AND c.relnamespace='public'::regnamespace
+    AND i.indrelid IN ('public."ScoutIngestEntity"'::regclass,'public."ScoutReconstructionLedger"'::regclass)`);
```
Harm closed: the C14c decoy index `"ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_id_key" ON public.g2c_decoy` (spec L1021) no longer appears in `narrow()`, so `before.narrow` is `[]` at C14c and the cascade (C15, C10, continuity) cannot start from it.

**Other catalog helpers checked for the same relname-only pattern affected by the C14c decoys — none included, with reasons:**
| helper | pattern | affected by C14c decoys? |
|---|---|---|
| `wide()` (`g2-c-harness.ts` L55–65) | `indexes` by relname `*_identity_key`; `checks` by conname; `ledgerNotNull` by `attrelid` regclass | No — the spec's only decoys (L1019–1021; shadow tables at L208–209 are the two real names in schema `shadow`, which `relnamespace='public'` already excludes) carry the two narrow names; no wide name is decoyed anywhere in the spec |
| `narrowNamed()` (L75–79) | relname-only over `pg_class` | Intentionally relname-only: it exists to *find* decoys (C14c asserts `[NARROW_STAGING_NAME,'r'],[NARROW_LEDGER_NAME,'i']`) |
| `catalog()` (`g2-c-pg-harness.ts` L112–119) | `pg_index ... WHERE indrelid IN (four real tables)` | Already indrelid-scoped |
| `identityRows` / `stagedRows` / `ledger` / `targets` | data queries on the real tables | n/a |
Search: `rg "relname|pg_index|pg_class|indrelid|pg_constraint" test/utils/g2-c-*.ts` — every hit listed above.

## Head
| item | value |
|---|---|
| **HEAD** | `1b6cc66164b3398d573ba92f0c8f6b039494be24` on `s7-c`, parent `16cd67f490ea363ad7ff3dc8e98246a1ad3f6d76` (phase-2 head, untouched; no amend), grandparent `29e60705` (accepted N/Q1) |
| **TREE** | `cea546313b1b15a2bb4ea225b0ee7fa8ce5622b5` |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both, `2026-09-24T21:42:40Z` |
| subject | `test(importer): scope the narrow-key catalog helper to the two real tables` — body describes the hunk; no trailers |
| hooks | lefthook v2.1.9: `prod-readiness-quick` ✔ `banned-cast-tokens` ✔ `eslint` ✔ `prettier` ✔ `tsc` ✔ (46.2 s, `NODE_OPTIONS=--max-old-space-size=4096`); commit-msg `no-ai-tokens` ✔ (receipt 16) |
| pre-commit light gates | prettier `--check` ✔, eslint `--no-warn-ignored --max-warnings 0` ✔ on the file; check-r75 `--mode=staged` rc 0 (receipt 15) |
| worktree | clean (0 porcelain lines, untracked included) |
| blobs | harness `test/utils/g2-c-harness.ts` = `5186c35131b2dae4e06458141bfdd062629ad108` (was `daf74010`); SPEC `6c40544d…` and BOOTSTRAP `54ad1352…` unchanged; migrations diff vs 29e60705 still exactly C's two files |
| diffstat 29e60705→HEAD | 22 files, +2940 −103 (`export/c-b1-diffstat.txt`); 16cd67f4→HEAD: 1 file, +2 −1 (`export/c-b1-delta-16cd67f4-to-1b6cc661.patch`) |
Heavy slot: canonical `execution/test-validation.lock` held once for the hooked commit (acquired immediately, released on exit); lock file untouched. Default Jest not re-run: the hunk is a SQL string inside a PG-only helper not imported by any default-visible spec (`g2-c-db-guard.spec.ts` imports `g2-c-db.ts` only); hook tsc/eslint/prettier cover the file.

## Binding — `c/binding/`, `BINDING.sha256` resealed (`sha256sum -c` 3/3 OK)
| item | value |
|---|---|
| `c-pg-proof.sh` (B1) | sha256 **`cf462851ae988d616148d709e2afa7532a2ef0503cc3f1bd757b700acb674ef9`** |
| delta vs phase-2 filled (`ad6c8c53…`, kept as `c-pg-proof.sh.phase2-16cd67f4`) | `c-pg-proof.sh.diff-phase2-to-b1`: `EXPECT_HEAD=1b6cc661…`, `EXPECT_TREE=cea54631…`, header head-id only. No other line |
| unchanged pins | `NQ1_HEAD=29e60705…`, `EXPECT_SPEC_BLOB=6c40544d…`, `EXPECT_BOOTSTRAP_BLOB=54ad1352…`, `EXPECT_FIXTURE_SHA=cf342f4b…`, `EXPECT_NM_CLIENT_SHA=2141225d…`, `EXPECT_NM_LOCK_SHA=05bc530a…`, PG17 shas, the 19 S5/B/R/N-Q1 + 7 N/Q1 blob pins |
| `c-fixture.sh` / `derive-c-pg-proof.py` | unchanged `cf342f4b…` / `4476ec0e…` |
| `PINS.txt`, `README.md` | appended; `bash -n` ok |

## Export — `c/export/`, sealed by `EXPORT-b1.sha256` (phase-2 `EXPORT.sha256` kept, copy `EXPORT.sha256.phase2-16cd67f4`)
| file | sha256 |
|---|---|
| `c-b1-1b6cc66164b3398d573ba92f0c8f6b039494be24.bundle` (range `29e60705..s7-c`: 16cd67f4 + 1b6cc661; `git bundle verify` ok; head `refs/heads/s7-c` = 1b6cc661) | `bca0d99ecec7726bc1d21c73ab9ad7de65904d28bb374678d24ecf25d7ba759f` |
| `c-b1-1b6cc66164b3398d573ba92f0c8f6b039494be24.patch` (`format-patch 29e60705..HEAD`, 2 patches) | `95b3ab47eafcfd099624d40cce2952440204bd4cbf5086ad13f58f061f789a65` |
| `c-b1-delta-16cd67f4-to-1b6cc661.patch` (the B1 hunk alone, for the attesters' delta check) | `ed78502389686d6ab89a02762bf7e30391e659576504d80b7106a53abf0c77cf` |
| `c-b1-diffstat.txt` | `38db5a210e20cbbb9b27a2b95c970c6de19db016605efda8a9fa47dfdc17f497` |
Receipts 15–16 added; `receipts/RECEIPTS.sha256` resealed (15/15 OK).

**PG NOT run. STOPPED at `c/SOURCE_READY_B1.md`.** Next: attesters delta-check the single hunk (`c-b1-delta-16cd67f4-to-1b6cc661.patch`), then the separate PG grant for one `c-pg-proof.sh` run. No push.
