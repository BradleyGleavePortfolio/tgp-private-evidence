# S10-B binding v1: independent pins-only review

This is a read-only review. I used only `git rev-parse`, `ls-tree`, `cat-file` and `diff`, plus `sha256sum` on files. I did not run the binding and made no index writes.

Inputs:
- `binding/v1/s10b-pg-proof.sh` (filled; sha256 620f0458…)
- `s10b-pg-proof.sh.template` (sha256 e4b1d599…)
- gate receipt `gate/HEAD-a2c74e904ff2.txt`
- clone `worktrees/d3a9-s10b`

## Verdict: GO on the pins, after one small fix: re-hash BINDING.sha256 (B1)

All 13 filled values match three sources: the receipt, the actual commit, and the clone. The file differs from the template only in the `__FILL__` lines. B1 is a one-line manifest update and does not touch any pin.

## 13 filled values

| Pin | Filled | Receipt | Actual (clone) | Result |
|---|---|---|---|---|
| BASE_HEAD | 92b9671511279254a8545c4cb531bf965762c597 | base= | `HEAD^` | = |
| BASE_TREE | b6fbbfd2a6495183433657814193b080c9582ab7 | base_tree= | `92b96715^{tree}` | = |
| EXPECT_HEAD | a2c74e904ff227b16881c77ee5a08bd006972d48 | head= | `HEAD` | = |
| EXPECT_TREE | 2cd46ef508745e6f39d10cfbf44e21e98c4f3fc0 | tree= | `HEAD^{tree}` | = |
| EXPECT_MIGRATIONS_TREE | 7b6fe0eda137ab1e3013b8a7c3b0c7637f69a521 | migrations_tree= (dirs=173, last=S10-B) | `HEAD:prisma/migrations` | = |
| EXPECT_SPEC_BLOB | b89fec1cb9254a2475908154b1109f16585af0b0 | blob line | `HEAD:test/rls-g2-s10b.spec.ts` | = |
| EXPECT_DB_BLOB | 3375f08ba0130bee8f20fb8a4f395a8fac4a5e10 | blob line | `HEAD:test/utils/g2-s10b-db.ts` | = |
| EXPECT_PGH_BLOB | 7cf6d63308d6a2150626ad89d759366a6644d2ec | blob line | `HEAD:…/g2-s10b-pg-harness.ts` | = |
| EXPECT_HARNESS_BLOB | 9956aff77a5664e748a30673760c1a3824c44a7e | blob line | `HEAD:…/g2-s10b-harness.ts` | = |
| EXPECT_WORKER_BLOB | e0af841268a03dbe5fc3db25e7e57a7bfe9f275f | blob line | `HEAD:…/g2-s10b-worker.cjs` | = |
| EXPECT_FIXTURES_BLOB | 8055dbefa6a4008a6e04f5f851c8d535f755dee1 | blob line | `HEAD:…/g2-s10b-fixtures.ts` | = |
| EXPECT_NM_CLIENT_SHA | 2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c | postgen_client index_dts= | sha256 `$W/node_modules/.prisma/client/index.d.ts` | = (≠ donor 9042e713) |
| EXPECT_NM_CLIENT_SCHEMA_SHA | aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5 | postgen_client schema= | sha256 `$W/node_modules/.prisma/client/schema.prisma` | = |

## Other checks

- **Diff against the template:** only the 13 `__FILL__` lines at :32-33, :36-44 and :68-69 changed, and every comment is unchanged. No `__FILL` token remains.
- **Pins that were not filled:** these still match HEAD at a2c74e90: bootstrap 32305683, schema f86c1f5d, migration.sql 695c694d and down.sql b5e5243e.
  - `EXPECT_FIXTURE_SHA` 7d9ee89b equals the fixture on disk.
  - `S10A_PARENT` is e6f20300, which is the parent of 92b96715.
- **Test count:** `EXPECT_TESTS=24` equals `grep -cE '^\s*it\('` on `HEAD:test/rls-g2-s10b.spec.ts`, which gives 24.
- **Commit shape:**
  - BASE..HEAD contains 16 paths.
  - The clone's status is empty: 0 porcelain lines.
  - The branch is `exec-d3a9/s10b`.
  - `.git/hooks/pre-commit` and `commit-msg` are regular lefthook files.
- **Lane state:**
  - `runtime/clusters/s10-b` and `runtime/run/s10-b` are both absent.
  - The existing lanes are s8-g, s9-b and s9-c.
  - `binding/v1/run/` is absent, so there is no sentinel yet.

## Findings

### B1: BINDING.sha256 still records the template bytes for `s10b-pg-proof.sh`

- **Evidence:** `BINDING.sha256:1` is `e4b1d599… s10b-pg-proof.sh`, which is the template sha. The filled file hashes to 620f0458…, and `sha256sum -c BINDING.sha256` reports `s10b-pg-proof.sh: FAILED`. The script does not read BINDING.sha256 when it runs, so this does not affect the run.
- **Harm:** the frozen-bytes record does not cover the script that will actually run. After the run, the evidence does not tie the executed bytes to a reviewed sha.
- **Blocks:** a clean evidence chain for the PG proof receipt.
- **Minimum fix:** re-hash BINDING.sha256 so it holds `620f0458dd50d7d2dbc8b2f93b7a37788759f9dc619b69467838c010b761f554  s10b-pg-proof.sh`. Keep the template as a separate entry at e4b1d599…. Then confirm `sha256sum -c` shows all entries OK before the run.
- **Unblocks:** a PG proof run whose executed bytes are attested by the manifest and by this review.

There are no A findings and no C findings.
