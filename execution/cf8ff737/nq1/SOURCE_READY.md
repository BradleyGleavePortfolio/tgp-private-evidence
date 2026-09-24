# N/Q1 SOURCE_READY — builder stop point (2026-09-24T18:25Z)

Builder `nq1_final_writer_reader_t4_build` (sole T4 builder; grant `execution/cf8ff737/NQ1_BUILD_GRANT.md`).
Requested route Claude Fable 5 / High — **no telemetry available to me; I claim none.**
Status: source committed, all gates green, binding filled, bundle exported. **PG proof NOT run; no cluster
initialised or started (`pgrep -cx postgres` = 0 throughout; `/home/user/pg17/clusters/` has no `nq1`).** Stopping
here per grant; the parent dispatches two T4 attestations, then a single PG grant for `binding/nq1-pg-proof.sh`.

## Head / tree / commit
| field | value |
|---|---|
| worktree / branch | `/home/user/workspace/worktrees/s7-nq1` / `s7-nq1` |
| HEAD | `61b93cff7900b24c17011d481fd6c31f5abb59e4` |
| TREE | `7adad6965d60269046b3240343b54d7f71582d70` (equals the freeze write-tree in receipt 05) |
| parent | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (accepted R head; ancestor verified) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both; trailers `[]`; no amend; **not pushed** |
| hooks (receipt 13) | genuine Lefthook v2.1.9 `pre-commit` (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc) + `commit-msg` (no-ai-tokens) — all ✔ |
| subject | `feat(importer): page and write the ledger by composite provenance identity` |
| diff stat | `25 files changed, 2743 insertions(+), 193 deletions(-)` (full list `export/nq1-diffstat.txt`); `prisma/migrations` byte-identical to 7d2895e1 (no migration ships) |
| post-commit status | `git status --porcelain` empty |

## Gate receipts (`receipts/`, sealed in `RECEIPTS.sha256`)
| gate | result | receipt |
|---|---|---|
| tsc `--noEmit` (frozen source) | rc=0, 44 s, `NODE_OPTIONS=--max-old-space-size=4096` | 07 |
| eslint `--no-warn-ignored --max-warnings 0` (22 changed .ts) | rc=0 | 08 |
| prettier `--check` (changed .ts/.json) | rc=0 | 09 |
| check-r75 `--mode=staged` + `bash -n` bootstrap/old-root | rc=0 ("no positive token change") | 10 |
| affected default Jest `npx jest test/scout test/contracts --ci` | rc=0 — 40 suites, 726 passed / 5 skipped; includes `PASS test/scout/g2-nq1-db-guard.spec.ts` | 11 |
| full default Jest `npx jest --ci` | rc=0 — 558 suites passed (12 skipped), 8617 tests passed / 159 skipped / 5 todo, 698 s | 12 |
| hooked commit | rc=0, 52 s | 13 |
| heavy slot | `06-lock.txt`: flock acquired 18:09:22Z → released 18:22:14Z (gates), re-acquired for the hooked commit → released 18:23:55Z; `LOCK_FREE_VERIFIED` both times | 06 |

**Process note (class C):** the grant says the parent relays `execution/test-validation.lock`. A subagent cannot receive
a relay mid-run, so — following the accepted R builder's recorded precedent (`r-ready/receipts/06-lock.txt`) — I
verified the lock free with `flock -n`, took it with `flock -w 1800` under holder tag `nq1-gates`, ran the two heavy
gates, and released immediately. The flock primitive is what guarantees exclusivity; no other holder was displaced or
waited. Recorded in receipt 06; nothing to re-run.

## Owned-path proof
- Writes confined to `/home/user/workspace/worktrees/s7-nq1` and `/home/user/workspace/execution/cf8ff737/nq1/`.
- `git -C worktrees/s7-r-ready status --porcelain` → empty; HEAD `7d2895e1` unchanged.
- `git -C worktrees/s7-b-drain status --porcelain` → empty; HEAD `0d69c7ba` unchanged.
- `/home/user/pg17/clusters/`: `b-drain`, `b-drain.v4-failed-…`, `r-ready` only — untouched; no `nq1`; no PostgreSQL started or initialised.
- node_modules: own physical copy (717 MB, not a symlink, zero multi-link files at depth ≤2); `.package-lock.json` sha `05bc530a…` (= C1/B/R record); disk free 5 GiB (floor 3 GiB).
- Only out-of-tree scratch: `/tmp/nq1-oldroot-check` (a `git clone --shared --no-checkout` used to dry-run the T-root helper; registers nothing in the repository) and `/tmp/nq1-*` logs.

## Binding (`binding/`, FILLED, NOT RUN, NOT GRANTED)
| file | sha256 |
|---|---|
| `nq1-pg-proof.sh` (filled) | `e47c9ac1bd073e2b92432bf1a4809bd2d30e4c63c61aec33fa0ccc339746a190` |
| `nq1-fixture.sh` | `29db46ad3189ca12bd507e79cd2f2b87c3c375aeb454f6db76973bb467ad4bc3` |
| `derive-nq1-pg-proof.py` (reproduces substitution-only form `e14db001…` byte-identically) | `416247925aa4c343d91544b1745d77e266b50c78ff73b55911fc9094c38bfb9e` |
| `BINDING.sha256` | manifest of the three above |
| `PINS.txt` | HEAD 61b93cff… TREE 7adad696… SPEC `8ad3af3f1f8a43d9006b929fea5e9cb3ae35a7b2` BOOTSTRAP `96b7668dff7498cee5ed17ab988aae0f38ac512d` FIXTURE 29db46ad… |
Pins also carried: `EXPECT_NM_CLIENT_SHA=92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4` (N `index.d.ts`, receipt 03),
`EXPECT_NM_LOCK_SHA=05bc530a…`, PG binaries `23cd1748…`/`b7db9bc2…` unchanged. Identity: port 55481, `nq1_super`,
`g2_nq1_disposable`, cluster `nq1-disposable-pg17`, `G2_NQ1_*` env, spec `test/rls-g2-nq1.spec.ts` via
`jest.rls.config.js --runInBand --ci`. Runner adds read-only pins that eight accepted R objects are blob-identical at
the N/Q1 head and hashes the retained stopped R cluster (never started). Details: `binding/README.md`.
Invocation later, under the separate single-run grant only: `timeout -k 30 3600 bash execution/cf8ff737/nq1/binding/nq1-pg-proof.sh`.

## Export (`export/`, sealed in `EXPORT.sha256`)
`nq1-61b93cff….bundle` (7d2895e1..s7-nq1; `git bundle verify` okay), `nq1-61b93cff….patch` (format-patch), `nq1-diffstat.txt`,
`nq1-staged.patch` (pre-commit freeze snapshot, sha `02e5a0d6…`, receipt 05).

## Scope delivered vs grant
- NQ1-a reader (v2 composite cursor, legacy resolve → existing 400 `'malformed cursor'` [P1], R/Q0 cursor → 400 no fallback [P2]).
- NQ1-b final writer (`source_platform` required in schema; five-field upsert; 409 `'reconstruction provenance conflict'` on repeated P2002; no migration).
- Contract label bumped once → `2.0.0-c1-s1.2`, pair-surface section unchanged [P3]; OpenAPI regenerated.
- NQ1-c test-only PG proof: sixth identity, T root = R head (`test/utils/g2-nq1-old-root.sh`), cases N01–N06, Q01–Q07, DB-free guard.
- Out of scope untouched: migrations, C work, native writers, G3-AUTH, mobile/extension.

## C qualifications (recorded; no further action)
1. tsc default heap OOMs (rc 134) at baseline too; all runs use a 4 GiB heap.
2. T-root design deviates from "by file": the whole 169-migration history installs through the T root's own `prisma migrate deploy`; N/Q1 ships no migration so there is nothing to replay by file (receipt 04, binding README).
3. N05: the N writer over a nulled provenance row may return 409 or 500; the spec accepts both and logs `PG17_N05_WRITER`.
4. Two spec-only fixes during gating (wrong `ledgerCount` import source; unused `allLedger` import) — receipt 04.
5. Heavy-slot acquisition by direct flock rather than parent relay (above).

## Next (parent)
Two independent T4 attestations of head `61b93cff…` → single PG grant for `binding/nq1-pg-proof.sh` → destroy grant for the retained `nq1` data dir afterwards.
