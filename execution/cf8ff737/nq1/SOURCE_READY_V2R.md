# N/Q1 v2r — SOURCE READY (environment recovered, v2 correction rebuilt; PG NOT run; STOPPED as instructed)

Grant: `execution/ce3748cb/NQ1_V2R_REBUILD_GRANT.md` (incorporating `execution/cf8ff737/NQ1_V2_MINIMUM_CORRECTION_GRANT.md`). Builder: N/Q1 v2r T4 builder. 2026-09-24 20:10Z–20:35Z.
No model/effort claim is made. Nothing pushed. No PG process started; no cluster created; no other worktree or lane touched. v1 files untouched (receipts 01–15, `RECEIPTS.sha256`, `SOURCE_READY.md`, `NQ1_PG_PROOF_RESULT.md`, `runtime/**`, `export/nq1-61b93cff…*`, `EXPORT.sha256`).

## Head
| item | value |
|---|---|
| **HEAD** | `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` on `s7-nq1`, parent `61b93cff7900b24c17011d481fd6c31f5abb59e4` (recovered v1, byte-exact) |
| **TREE** | `511710ee0c361a2ec68bf217c4d47f8504ef2790` |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both, `2026-09-24T20:29:51Z` (author date = committer date) |
| trailers | none (checked: no co-authored/generated/model tokens; commit-msg hook `no-ai-tokens` ✔) |
| hooks | genuine lefthook v2.1.9, installed from the isolated tree (receipt 20; recovered clone had only `.sample` hooks): pre-commit `prod-readiness-quick` ✔ `banned-cast-tokens` ✔ `eslint` ✔ `prettier` ✔ `tsc` ✔ (49.5 s), commit-msg `no-ai-tokens` ✔ — receipt 22 |
| `NODE_OPTIONS` | `--max-old-space-size=4096` exported for the commit (receipt-07 heap qualification carried) |
| blobs | SPEC `test/rls-g2-nq1.spec.ts` = `a93382605a7e8099f5fd622cf2d0a92298460bd3`; harness `test/utils/g2-nq1-pg-harness.ts` = `d51267f2c8a9972de4361f691f680b0792595209`; bootstrap unchanged `96b7668dff7498cee5ed17ab988aae0f38ac512d` |
| worktree | clean (0 porcelain lines); `prisma/migrations` identical to R `7d2895e1`; `git diff 61b93cff HEAD -- src prisma scripts test/utils/g2-tq0-worker.cjs test/utils/g2-nq1-{db,harness,bootstrap,old-root}.*` = empty |

**Diffstat (61b93cff → 29e60705):**
```
 test/rls-g2-nq1.spec.ts         | 194 ++++++++++++++++++++++++++++++++--------
 test/utils/g2-nq1-pg-harness.ts |  24 +++--
 2 files changed, 178 insertions(+), 40 deletions(-)
```
Only the two permitted paths. No `src/**`, `prisma/**`, contract, worker, or pinned R/B/S5 object changed.

**Single-commit note (recorded, not hidden):** the first hooked commit `3f2d7a77` (receipt 21, all hooks ✔) was amended (`--amend --reset-author`, hooks re-run, receipt 22) before any attestation after the builder's own re-read found one wrong assertion in N03(d): the labelled fixture mapper applies to the whole family, so the genuinely-skipped sibling's `reason` follows the product's "last serialized non-success writer wins" rule (`fixture:mapper-skip`), not the unmapped reason. The result is still exactly one ordinary hooked commit on `61b93cff`. The `3f2d7a77` export files are preserved under `export/superseded-3f2d7a77/`; its pin fill is recorded in `binding/PINS.txt` as superseded.

## The four corrections (spec/harness only; expectations derived from fixture + product logic)
1. **Q05** — every scope-bound token (all v2 tokens; the legacy *entities* token, which carries `c/i/f`) presented by a foreign coach or for a foreign intent → `400 malformed cursor`, `readPage()` false, no reflection (failure JSON contains neither the token nor `foreign`). Derivation: `decodeScoutCursor` runs before the settled-intent `$transaction` gate in both readers (`scout-roster.service.ts:68/94`, `scout-entities.service.ts:81/104`) and throws on `v.c !== coach || v.i !== intent`. The legacy *roster* token is a bare source id with no scope, so with a foreign coach/intent it (like a token-less request) reaches the uniform 404 gate; asserted as 404 with no page read. Brief L103 satisfied.
2. **N03(a)** — `resetData()` before staging `m1`; the original assertions stand (now with the sibling, below).
3. **N02 / N06** — inert `failEvery` (`name='FAIL'`) replaced in the harness by `skipEvery`: every k-th row is staged under `UNMAPPED_PLATFORM = 'auto:other.example'` (canonical per the R CHECK; no registered mapper). `families.ts` `map()` → `unsupportedPlatform(row)` → engine `writeOutcome(skipped, 'unsupported_platform:auto:other.example')`; `src/scout/reconstruct`, `src/scout/mappers`, `scout-platform.ts` are byte-identical N vs T (`git diff --quiet 7d2895e1 HEAD` on those paths), so N==T is preserved. Expected numbers: N02 24 rows, k=6 → `floor(24/6)=4` skipped / 20 reconstructed / 0 failed, **both families**; N06 clients 12 rows, k=4 → 3/9, workouts 12/0 (all-success replay retained). Exact tally objects asserted (`toEqual` with `intent_id/staged/reconstructed/skipped/failed`); the skipped rows are asserted row-by-row (`source_id`, platform, `skipped`, null target, product reason) and no reconstructed row carries the unmapped platform / null target / a reason. Readers page only `reconstructed`, so N06's visible union = 9 (clients) on Q1 and Q0.
4. **N03 both orders** — (a) and (c) stage a genuinely skipped sibling (`m1-skip`, `m3-skip` under the unmapped platform) beside the reconstructed row: both writers' tallies are `{staged 2, reconstructed 1, skipped 1, failed 0}`, one ledger row each, sibling reason = product reason. (d) success dominates a later refusal from T then N (labelled fixture mapper); sibling stays `skipped`/null target and takes the last non-success writer's reason; `m3` reason stays null. (e) new: the other order — a committed skip (fixture mapper, by T then by N) followed by a genuine success from the other writer becomes `reconstructed` with a minted target and null reason.

**Recorded limit (C):** the current `src/scout` has no data-reachable `failed` outcome (registered mappers are total and identity-only; a noncanonical token is a structural 409, N04), and a same-identity non-success↔success flip cannot arise from data alone. The genuine path is `skipped`; the same-identity flips in (d)/(e) use the accepted, explicitly labelled fixture mapper of the unchanged shared worker. **Stop condition did not trigger.**

## Gates (light, on the touched files) — receipts 16–19, 23–24
| gate | result |
|---|---|
| prettier `--check` | rc=0 (receipts 16, 23) |
| eslint `--no-warn-ignored --max-warnings 0` | rc=0 (17, 23) |
| tsc `--noEmit -p tsconfig.json` (`NODE_OPTIONS=--max-old-space-size=4096`) | rc=0, 47 s pre-amend (18); rc=0, 46 s on the final head (24); hook tsc ✔ both commits |
| check-r75 `--mode=staged` | rc=0 (19 — the first line of 19 is the builder's wrong `--cached` flag, rc=1 operational, kept; the hook run in 21/22 is authoritative ✔) |
| db-guard `test/scout/g2-nq1-db-guard.spec.ts` | not triggered: imports only `test/utils/g2-nq1-db.ts`, untouched |
| default Jest | not run (PG spec excluded from default Jest; nothing default-visible touched) |
`receipts/RECEIPTS-v2r.sha256` seals 16–24; v1 `RECEIPTS.sha256` untouched and still verifies (15/15 OK).

## Environment recovery (Phase E) — `nq1/env/`, sealed by `ENV_RECEIPTS.sha256`; summary `ENV_RECOVERY.md`
| pin | expected | observed | result |
|---|---|---|---|
| Maven jar sha1 / sha256 | `8163322358…` / `23da5a04…` | identical | OK |
| inner txz sha256 | `26fa6334…` | identical | OK |
| `dist/bin/postgres` | `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a` | identical; `postgres (PostgreSQL) 17.6` | OK |
| `dist/bin/initdb` | `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a` | identical | OK |
| `/usr/bin/psql` | ≥17 | `postgresql-client-18 18.6-0ubuntu0.26.04.1` (same as S1/S2 history) | OK |
| `package-lock.json` | `b7fed5ed…` (receipt 02) | identical | OK |
| `node_modules/.package-lock.json` | `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` | identical after `npm ci --ignore-scripts` | OK |
| `.prisma/client/index.d.ts` (N generate) | `92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4` | identical (Prisma 6.19.3) | OK |
| client engine | `a2924eab…` | identical | OK |
Heavy slot: `execution/test-validation.lock` held by E3 only (flock -n) 20:12:01Z–20:17:36Z, released on exit. `/home/user/pg17/clusters` ABSENT (nothing created). `/home/user/node_modules` (platform-owned) unchanged. E1 wrote `/home/user/pg17/PROVENANCE.txt` (`result=success`) in the format the runner greps.

## Binding
| item | value |
|---|---|
| `binding/nq1-pg-proof.sh` (v2r) | sha256 **`aec602521f377a2b825026b1437fa57439794236321cb617129c48dc7e134756`** |
| v1 copy kept | `nq1-pg-proof.sh.v1-61b93cff` = `e47c9ac1bd073e2b92432bf1a4809bd2d30e4c63c61aec33fa0ccc339746a190`; `BINDING.sha256.v1-61b93cff` |
| pins | HEAD `29e60705…`, TREE `511710ee…`, SPEC `a9338260…`; BOOTSTRAP `96b7668d…`, FIXTURE `29db46ad…` unchanged; `bash -n` ok |
| `BINDING.sha256` | resealed; `sha256sum -c` → 3/3 OK (`nq1-fixture.sh` 29db46ad…, `derive-nq1-pg-proof.py` 41624792… unchanged) |
| `PINS.txt`, `README.md` | appended (v1 lines unchanged) |

**Runner delta:** pins only (three `EXPECT_` lines + one header word). The donor clusters `s5/c1-builder/b-drain/r-ready` are absent; the runner's preflight does **not** require their presence — its existing `else` branches record `c1_cluster=ABSENT` / `b_cluster=ABSENT` / `r_cluster=ABSENT` and it requires S5 absence (satisfied). No "ABSENT" edit was needed, so none was made.

**Static precondition check of the runner against the recovered environment (read-only, not a run):** hooks lefthook ✔; node_modules is a real directory inside the worktree, lock/client hashes ✔; jest/ts-node/prisma bins present ✔; PG17 dist + binary hashes + 17.6 ✔; `/usr/bin/psql` ✔; R/B/S5 pinned blobs are untouched by this commit (only two test files changed) ✔; 7d2895e1 ancestor ✔; migrations identical ✔.
**Lane flag for the next PG grant (v1 leftovers, untouched by me):** `runtime/run/nq1-pg-proof.sentinel` exists → runner refuses rc 76 until the parent grants the preserving rename of the v1 `runtime/` (v1 `runtime/old-root` did not survive the sandbox loss; `clusters/nq1` no longer exists, so the planned cluster rename is moot).

## Export — `nq1/export/`, sealed by `EXPORT-v2r.sha256`
| file | sha256 |
|---|---|
| `nq1-v2r-29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd.bundle` (range `7d2895e1..s7-nq1`: 61b93cff + 29e60705; prerequisite 7d2895e1; `git bundle verify` ok) | `051691b56bb7d5ff03b466009382468ecc9c3c7f7f803719ca924d46376ebb00` |
| `nq1-v2r-29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd.patch` (`format-patch 61b93cff..HEAD`) | `4826724f46f13adae7feea1bec964cd606f55921c48b117e763b80df99fa01f0` |
| `nq1-v2r-diffstat.txt` | `480b4b28d317ab9dec35afcf5502f161ab4c5f96061d131ab2fd5b6521397198` |
Recovery check: `git am --committer-date-is-author-date` of the patch onto `61b93cff` in a scratch clone (Bradley committer identity) reproduced **the identical SHA `29e60705…` and tree `511710ee…`**; scratch clone removed.

## Lane state at stop
`s7-nq1` clean at `29e60705`; `s7-c` untouched (its 8 untracked C-redraft files are that lane's, observed only); `pgrep -cx postgres` = 0; `/home/user/pg17/clusters` absent; validation lock currently held by the UX-M1 lane's jest (not this lane); 5.6 GiB free.

## Next (parent)
Two independent delta re-attestations bound to `29e60705` (spec delta + the five v1 failures were spec-only), then the preserving rename of v1 `runtime/` and a new single-run PG grant. Builder STOPPED here.
