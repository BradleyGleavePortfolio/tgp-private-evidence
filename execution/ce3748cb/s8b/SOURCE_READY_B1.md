# S8-B — SOURCE READY B-1 (closure commit exists; PG NOT run; STOPPED as instructed)

Grant: `execution/ce3748cb/S8_B_B1_CLOSURE_GRANT.md`. Builder: S8-B builder (sole writer of `s8-b` and `execution/ce3748cb/s8b/**`).
2026-09-24 22:25–22:32Z. No model/effort claim is made. Nothing pushed. No PG process, cluster or other lane touched
(`/home/user/pg17/clusters/` still only `nq1`; `pgrep -cx postgres` = 0). S8-C's worktree not touched. `s8b/**` append-only:
every replaced binding/export file kept under a suffixed name.

## B-1 as found by both attesters
Spec `tally()` (`test/rls-g2-s8b.spec.ts` L97–102) built `{staged, reconstructed, skipped, failed}`; the real
`ScoutReconstructService.tally()` returns `{intent_id, staged, reconstructed, skipped, failed}` (`src/scout/scout-reconstruct.service.ts`
L322–327), and the spec compares with `toEqual` at five call sites (stage 1 baseline, P05 ×3, P04) → deterministic stage-1 failure,
nothing learned from the single PG run. Fixture intent value confirmed `'intent'` (`g2-s8b-pg-harness.ts` L126 default; harness
helpers default `intent = 'intent'`).

## Closure — exactly one hunk
```
 const tally = (staged: number, reconstructed: number) => ({
+  intent_id: 'intent',
   staged,
```
`git diff --numstat edd6dc6b HEAD` = `1 0 test/rls-g2-s8b.spec.ts`; no other path changed. Migration, down, schema.prisma
(`77f33bcd…`), generated client (`b6716a86…`) untouched.

## Head
| item | value |
|---|---|
| **HEAD** | `8a0075de1ac6ec6cef439af77105896ad0862859` on `s8-b`, parent **`edd6dc6b2c3ce82f64d567930edad27fbfc77255`** (no amend; phase-2 commit retained), grandparent `1b6cc661` (accepted C) |
| **TREE** | `b8aab8e6fdbe8a4170fb67db95751c9d34c57031` |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both, `2026-09-24T22:26:51Z` |
| subject | `test(importer): expect the intent_id the reconstruction tally returns in the S8-B proof` |
| trailers | none (`%(trailers)` empty); body has no identity tokens; commit-msg `no-ai-tokens` ✔ |
| hooks | lefthook v2.1.9 pre-commit `prod-readiness-quick` ✔ `banned-cast-tokens` ✔ `eslint` ✔ `prettier` ✔ `tsc` ✔ (46.6 s, heap 4096); commit-msg ✔ (receipt 16) |
| blobs | SPEC `test/rls-g2-s8b.spec.ts` = **`0af1709f037fed1ec4980cf658ba79b0fe9b91f4`** (was `bd94ef73…`); BOOTSTRAP unchanged `55ab8972…` |
| worktree | clean after commit and after export (0 porcelain lines) |

## Gates on the hunk (receipts 14–17; `receipts/RECEIPTS.sha256` resealed, 16/16 OK)
| gate | result |
|---|---|
| prettier `--check` + eslint `--max-warnings 0` on the spec | rc=0 (14) |
| check-r75 `--mode=staged` | rc=0 "no positive token change" (15); hook ✔ |
| hooked commit | rc=0 (16) |
| static precondition re-check of the re-pinned runner vs HEAD (read-only) | 48/48 OK, `fails=0` (17): HEAD/TREE/parent/SPEC/BOOTSTRAP, all 39 S5/B/R/N-Q1/C blob pins, migrations diff = S8-B's two files, only-spec-changed, one-line, client/schema shas, lane absent, no postgres |
Not re-run (unchanged inputs; class C): whole-tree tsc outside the hook (the hook's tsc ✔ covers HEAD), affected Jest (the rls spec is
excluded from the default project; the guard/db files did not change).

## Binding — `s8b/binding/`, `BINDING.sha256` resealed (`sha256sum -c` 10/10 OK)
| item | value |
|---|---|
| `s8b-pg-proof.sh` (re-filled) | sha256 **`be7981ebea205195e0aeecf4438a32f390be8167a29b8462bf21c5054f8ab3b9`** |
| delta vs the edd6dc6b filled form | header word + `EXPECT_HEAD` + `EXPECT_TREE` + `EXPECT_SPEC_BLOB` only — `s8b-pg-proof.sh.diff-edd6dc6b-to-8a0075de` |
| unchanged pins | `OLD_HEAD=1b6cc661…`, `EXPECT_BOOTSTRAP_BLOB=55ab8972…`, `EXPECT_FIXTURE_SHA=360b093b…`, `EXPECT_NM_CLIENT_SHA=b6716a86…`, `EXPECT_NM_LOCK_SHA=05bc530a…`, PG17 binary shas; no `__` placeholder remains (only the guard `case … *__*)` itself); `bash -n` ok |
| kept | `s8b-pg-proof.sh.phase2-filled-edd6dc6b` (`3fbdcdb1…`), `PINS.txt.phase2-edd6dc6b`, `BINDING.sha256.phase2-edd6dc6b`; `PINS.txt` updated (status, HEAD/TREE/SPEC, `filled_sha`, `phase2_filled_sha_edd6dc6b`); `README.md` B-1 section appended |
| `s8b-fixture.sh` / `derive-s8b-pg-proof.py` | unchanged `360b093b…` / `60e18f23…` |

## Export — `s8b/export/`, `EXPORT.sha256` resealed (6/6 OK; previous seal kept as `EXPORT.sha256.edd6dc6b`)
| file | sha256 |
|---|---|
| `s8b-b1-8a0075de1ac6ec6cef439af77105896ad0862859.bundle` (range `1b6cc661..s8-b`, two commits edd6dc6b + 8a0075de, prerequisite 1b6cc661; `git bundle verify` ok; head `refs/heads/s8-b` = 8a0075de) | `f2c5b6b1bf15093ce7e3fb4538d3490882c48a54f734c077a34a332b657326f0` |
| `s8b-b1-8a0075de1ac6ec6cef439af77105896ad0862859.patch` (`format-patch 1b6cc661..HEAD --stdout`, 2 patches) | `38b83fd9e3e6802cfd63b51521e02d388b127a6ece86ecc23a6fc24b6a118c1e` |
| `s8b-b1-diffstat.txt` (10 files, +2109) | `d2c942ef57a73574cfbe40718fee557f79a3dd645f792fa5cf0f65a1b30c6d7b` |
The edd6dc6b bundle/patch/diffstat remain in `export/` unchanged.

## For the attesters' delta check
- Hunk: `git -C worktrees/s8-b diff edd6dc6b 8a0075de` (one added line, L98 `intent_id: 'intent',`).
- Pins: `binding/s8b-pg-proof.sh` L2 (header), `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB`; `binding/PINS.txt`; seals
  `binding/BINDING.sha256`, `export/EXPORT.sha256`, `receipts/RECEIPTS.sha256`.
- Note for the PG run: `S8-C` has merged `edd6dc6b` into its own worktree; the S8-B proof runs from `worktrees/s8-b` at 8a0075de
  and does not read S8-C's tree.

**PG NOT run. STOPPED at `s8b/SOURCE_READY_B1.md`.** Next (parent): attesters' delta check → single PG grant for
`timeout -k 30 3600 bash execution/ce3748cb/s8b/binding/s8b-pg-proof.sh`. No push.
