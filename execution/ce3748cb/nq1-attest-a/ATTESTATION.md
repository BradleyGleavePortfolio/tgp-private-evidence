# N/Q1 v2r — independent T4 delta attestation A

**Verdict: GO** for a single PG run of `execution/cf8ff737/nq1/binding/nq1-pg-proof.sh` bound to HEAD `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd`, subject to the one pre-existing lane precondition in §7 (parent's preserving rename of the v1 `runtime/` — already planned in the v2 grant; no candidate or binding change).

Attester A, 2026-09-24 ~20:45Z. Read-only: no PG started, no file modified except this report. Did not read attester B's report. Scope is the delta `61b93cff → 29e60705` plus the spec-only classification of the five v1 failures; unchanged v1 bytes were not re-audited. No model/effort claim.

Authority read: `execution/cf8ff737/NQ1_V2_MINIMUM_CORRECTION_GRANT.md`, `execution/ce3748cb/NQ1_V2R_REBUILD_GRANT.md`, brief `nq1-prep/NQ1_SLICE_BRIEF.md` (§6 table, Q05/N03 rows).

## 1. Delta confinement — PASS

| check | observed |
|---|---|
| `git diff --stat 61b93cff 29e60705` | `test/rls-g2-nq1.spec.ts` (+154/−40 net 194 lines), `test/utils/g2-nq1-pg-harness.ts` (+18/−6 net 24); **2 files only** |
| `src/**`, `prisma/**`, contract, `test/utils/g2-tq0-worker.cjs`, `g2-nq1-{db,harness,bootstrap,old-root}.*` | no diff (bootstrap blob `96b7668d…` identical on both heads) |
| parent | `61b93cff` (v1), tree of v1 `7adad696…` → new tree `511710ee0c361a2ec68bf217c4d47f8504ef2790` |
| `7d2895e1` (R head / T root) ancestor of HEAD | yes |
| `prisma/migrations` vs `7d2895e1` | identical (N/Q1 still ships no migration) |
| `src/scout/reconstruct/**`, `src/scout/mappers/**`, `src/scout/scout-platform.ts` vs `7d2895e1` | identical → the N and T processes share the exact family dispatch / mapper registry / canonical-platform rule (N==T for the new skip path is structural, not observed) |
| worktree | clean |

Harness delta content: `failEvery` (inert `name='FAIL'`) → `skipEvery` (every k-th row staged under `UNMAPPED_PLATFORM='auto:other.example'`), new exported constants `UNMAPPED_PLATFORM`, `UNMAPPED_REASON`, helper `skippedOf(count,k)=floor(count/k)`; `stage()` and everything else unchanged.

## 2. The five v1 failures were spec-only and are genuinely closed — PASS

Receipt 15 / `NQ1_PG_PROOF_RESULT.md`: in all five failures the N==T tally equality passed immediately before the failing spec-authored expectation, and the received values (24/0, 4, 12, 400) are what the product logic produces on that fixture. I verified each against the product source, not the builder's narrative:

**Q05 ×2 (expected 404, received 400).** `decodeScoutCursor` (`src/scout/scout-cursor.ts:60-97`) throws `BadRequestException('malformed cursor')` when `v.c !== coach || v.i !== intent || v.f !== family`, and both readers call it *before* the `$transaction` containing the `ScoutImport` settled/ownership gate that yields the 404 (`scout-roster.service.ts:68` vs `:94`; `scout-entities.service.ts:81` vs `:104`). Brief §6 Q05 row: "foreign coach/intent → 400 `malformed cursor`". The v1 404 expectation contradicted both the brief and the accepted R reader ordering. **Correction is contract-correct:** the v2r spec asserts 400 + `readPage()===false` + no reflection (failure JSON contains neither the token nor `foreign`) for every scope-bound token (all v2 tokens; legacy *entities* token, which carries `c/i/f`) under foreign coach **and** foreign intent, in both directions. The 404 path is retained where it genuinely applies: token-less request and the scope-less legacy *roster* token (bare base64url source id, `scout-cursor.ts:72-75` returns `{s}` with no scope check) — `foreign` coach/intent are never settled in the fixture (`resetData()` settles only `coach/intent`; `beforeEach` at spec:549), so the gate's uniform 404 with no page read is the product outcome. Coverage widened, not dropped.

**N03(a) (expected reconstructed 1, received 4).** v1 staged `m1` without `resetData()`; N01's three default-scope rows were counted. v2r adds `resetData()` before `stage('m1', …)`; original assertions (one ledger row for `m1`, one `Person`, identity row `['clients','m1','truecoach','reconstructed']`) stand, extended by the sibling (below).

**N02 (expected 20/4 failed) and N06 (expected 9).** `stageMany(..., failEvery)` wrote `name='FAIL'`; nothing in `src/scout` reads the payload name as a failure (registered mappers are total: `source-mapper-registry.ts` doc; `families.ts` `map()` only branches on `sourceMapperRegistry.get(row.source_platform)`). The 20/4 and 9 expectations were unreachable — spec defect. **Replacement path is genuine and data-reachable:** `families.ts:50-53,64-65,103-104` — an unregistered `source_platform` returns `{ok:false, reason:'unsupported_platform:<token>'}` for both `clients` and generic-entity families → engine `reconstructRow` → `writeOutcome(skipped, reason)` (`scout-reconstruct.service.ts:204-212`), target null. `auto:other.example` satisfies `isCanonicalPlatform` (`scout-platform.ts`) and the R CHECK `^[a-z0-9][a-z0-9._:-]{0,255}$` on both `ScoutIngestEntity` and the ledger (migration `20270120000000` L129-132), so it is staged and ledgered, never a structural 409. Registry contains only `truecoach` and `conformance_alpha`. **Expectations derived, not tuned:** N02 24 rows, k=6 → `floor(24/6)=4` skipped / 20 reconstructed / 0 failed, both families (v1 only "failed" clients; workouts now also carries a non-success outcome); N06 clients 12 rows, k=4 → 3/9; workouts k=0 → 12/0. Asserted with exact `toEqual` on the full N tally `{intent_id,staged,reconstructed,skipped,failed}` (matches `tally()` shape at `scout-reconstruct.service.ts:319-327`), skipped rows asserted row-by-row (`s00006,s00012,s00018,s00024` = `(i+1)*k` zero-padded, platform, `skipped`, null target, exact product reason), and a zero-count assertion that no reconstructed row has a non-`truecoach` platform, null target or non-null reason. N==T tally equality and `outcomes(n)==outcomes(t)` retained. N06's reader-union check keeps `success = 12 − skipped = 9` (readers page `status='reconstructed'` only, unchanged v1 code).

**N03 "success dominates … both ways" (brief N03 row) — coverage kept and completed.** Product rule (`writeLedger` precedence `updateMany`, `scout-reconstruct.service.ts:296-306`, byte-equal to T's precedence block per `git diff 7d2895e1 HEAD`): success has no status filter (overwrites anything); non-success is filtered `status != reconstructed` (last serialized non-success writer wins; never touches a committed success).
- (a) N-then-T and (c) T-then-N now each stage a genuinely skipped sibling (`m1-skip`, `m3-skip` under the unmapped platform); both writers' tallies `{staged 2, reconstructed 1, skipped 1, failed 0}`; one ledger row per identity; one `Person`; sibling reason = `unsupported_platform:auto:other.example`. T's claim step (`OR [{platform:null},{platform:row.platform}]`) matches N's committed sibling row, so T converges — consistent with the accepted N03(a) v1 mechanics.
- (d) success-then-non-success from T then N (accepted labelled fixture mapper `mapper:'skip'` of the unchanged shared worker, already used in v1 (d)): `m3` keeps `reconstructed` + `targetBefore` + null reason (asserted `''` = psql `-At` NULL rendering, same convention as v1); the sibling stays `skipped`/null target and — because the fixture mapper applies to the whole family — takes the last non-success writer's reason `fixture:mapper-skip`. I derived this from the precedence filter independently; it matches the spec (this is the assertion the builder corrected in the amend, receipt 22).
- (e) **new**: non-success-first (T then N, each order) then success from the other writer → `reconstructed`, minted target, `Person` count 0→1, one ledger row, null reason. For T-first: T's narrow-key upsert creates the row with `source_platform='truecoach'`; N's wide-key upsert matches it and its unfiltered precedence update flips it. For N-first: T's claim matches on `truecoach` and its unfiltered success update flips it.

**Stop condition:** did not trigger — a genuine data-reachable non-success outcome exists and is used. Recorded limit (C, see §6): the *same identity* cannot genuinely flip success↔non-success from data (mappers total and deterministic), so the same-identity flip in (d)/(e) necessarily uses the accepted fixture mapper; the genuine skip appears as a sibling in every mixed-writer pass. No product code was added.

## 3. Binding refill — PASS

| check | observed |
|---|---|
| `diff nq1-pg-proof.sh.v1-61b93cff nq1-pg-proof.sh` | exactly 4 lines: header comment word (61b93cff→29e60705 + v1-copy note), `EXPECT_HEAD=29e60705…`, `EXPECT_TREE=511710ee…`, `EXPECT_SPEC_BLOB=a9338260…` — **pins only** |
| pins vs actual head | `git rev-parse HEAD`=`29e60705…` ✔, `HEAD^{tree}`=`511710ee…` ✔, `HEAD:test/rls-g2-nq1.spec.ts`=`a9338260…` ✔, `HEAD:test/utils/g2-nq1-bootstrap.sh`=`96b7668d…` ✔ (unchanged), `EXPECT_FIXTURE_SHA`=`29db46ad…` = `sha256sum nq1-fixture.sh` ✔ |
| harness blob `d51267f2…` | not separately pinned — the runner has no harness pin variable; it is covered transitively by the TREE pin (adding a variable would exceed "pins only") |
| `sha256sum nq1-pg-proof.sh` | `aec602521f377a2b825026b1437fa57439794236321cb617129c48dc7e134756` (matches task/SOURCE_READY_V2R) |
| `sha256sum -c BINDING.sha256` | 3/3 OK (`nq1-pg-proof.sh` aec60252…, `nq1-fixture.sh` 29db46ad…, `derive-nq1-pg-proof.py` 41624792…) |
| v1 seal `BINDING.sha256.v1-61b93cff` | preserved; v1 runner copy `e47c9ac1…` matches the v1 seal line |
| donor-cluster preflight | runner `else` branches already record `c1/b/r_cluster=ABSENT`; S5 absence required and satisfied (`/home/user/pg17/clusters` absent) → no "ABSENT" edit needed; none made ✔ |

## 4. Environment pins — PASS (live re-hash by me)

| pin | runner expects | live |
|---|---|---|
| `/home/user/pg17/dist/bin/postgres` | `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a` | identical; `postgres (PostgreSQL) 17.6` |
| `/home/user/pg17/dist/bin/initdb` | `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a` | identical |
| `node_modules/.package-lock.json` | `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` | identical (real dir inside worktree, 20:17Z) |
| `node_modules/.prisma/client/index.d.ts` | `92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4` | identical |
| `/usr/bin/psql` | present | `psql (PostgreSQL) 18.6` |
| `PROVENANCE.txt` | grepped by runner | `postgres_sha256=23cd1748…`, `result=success` |
| `pgrep -cx postgres` / clusters | 0 / `/home/user/pg17/clusters` absent (fresh init only) | ✔ |

## 5. Identity, trailers, hooks — PASS

- Author **and** committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, `2026-09-24 20:29:51 +0000` (identical dates). `%(trailers)` empty; message body contains no co-authored/generated/model tokens (commit-msg `no-ai-tokens` ✔ in receipt 22).
- Hooks: `.git` common dir `hooks/pre-commit` and `hooks/commit-msg` are genuine lefthook launchers (call `lefthook` / worktree `node_modules/lefthook-linux-x64`), installed per receipt 20 (`rc=0`); `lefthook.yml` pre-commit = `banned-cast-tokens` (check-r75 staged), `tsc`, `eslint --max-warnings 0`, `prettier --check`, `prod-readiness-quick`. Receipt 22 (amend) shows all five pre-commit commands ✔ (tsc 49.5 s) and commit-msg ✔ producing `29e60705`.
- Single commit on `61b93cff`: the amend of `3f2d7a77` is recorded openly (SOURCE_READY_V2R, receipt 21/22, `export/superseded-3f2d7a77/`); the correction it made ((d) sibling reason) is the one I independently derived above. Result is one hooked commit; nothing hidden.
- Gates on the final head: prettier rc=0, eslint rc=0 (receipt 23), tsc rc=0 46 s (receipt 24), check-r75 via hook ✔. `RECEIPTS-v2r.sha256` verifies 9/9 (receipts 16–24). v1 receipts/`SOURCE_READY.md`/`NQ1_PG_PROOF_RESULT.md`/`runtime/**` untouched.

## 6. Findings (Safety ROI)

No A. No B.

- **C-1 (record/continue):** same-identity success↔non-success flips in N03(d)/(e) use the accepted labelled fixture mapper (`fixture:mapper-skip`) rather than a data-only path, because the product has no data-reachable same-identity flip (mappers total/deterministic) and no data-reachable `failed` outcome at all (a noncanonical token is the structural 409 already covered by N04). The genuine `skipped` outcome is present as a sibling in every mixed-writer pass and in N02/N06. This is the minimum consistent with the grant's stop condition; no product code was added. No action.
- **C-2 (record):** harness blob `d51267f2…` is pinned only transitively via `EXPECT_TREE`; the runner has no harness pin slot and the grant limits the runner delta to pins. Tree pin is sufficient. No action.
- **C-3 (record):** `/usr/bin/psql` is client 18.6 against server 17.6, same as S1/S2/v1 history; runner only requires presence. No action.

## 7. Precondition for the PG grant (not a candidate defect)

`runtime/run/nq1-pg-proof.sentinel` (v1: `RC=1 STAGE=jest … HEAD=61b93cff…`) exists; runner line 51 refuses with rc 76 while it exists. The v2 grant already provides the preserving rename (B v4 PRE-1 precedent) at the start of the next PG grant; the rename must cover `nq1/runtime/` (or `runtime/run/`), not only `clusters/nq1` (which no longer exists; `runtime/old-root` also absent, so preflight line 114 passes). Nothing is deleted; v1 evidence stays under the renamed path.

## Verdict

**GO** — single PG run of `binding/nq1-pg-proof.sh` (sha `aec60252…`) against `s7-nq1` HEAD `29e60705…`, after the parent's preserving rename of the v1 `runtime/` per §7. Delta is confined to the two permitted test paths; every v1 failure was a spec-authored expectation contradicted by product logic the N and T heads share byte-for-byte; the corrections follow the brief and derive expectations from fixture + product source; required coverage (N==T tally, success-dominates both orders, Q05 400-no-page-read) is kept or widened; pins, seal and environment match live.

---

## FINAL ACCEPT — post-run verification (attester A, 2026-09-24 ~20:58Z)

Read-only check of the raw run evidence (`nq1/runtime/run/*`, receipts 25–27, `NQ1_V2R_PG_PROOF_RESULT.md`); no source re-audit; attester B's report not read.

| question | evidence |
|---|---|
| Exact attested head executed | runner log L1 `START … head_expect=29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd`; `PRECONDITIONS_OK` implies HEAD/TREE/SPEC/BOOTSTRAP/FIXTURE pin checks (runner L67-72) passed; sentinel `RC=0 STAGE=done END=2026-09-24T20:54:50Z HEAD=29e60705…`; `POST_OK` (worktree unchanged, HEAD still `29e60705`); `s7-nq1` clean at `29e60705` now |
| Exact attested binding executed | receipt 26 `RUN_START … runner_sha=aec60252…`; `binding/nq1-pg-proof.sh` sha now `aec602521f377a2b825026b1437fa57439794236321cb617129c48dc7e134756`; `BINDING.sha256` verifies 3/3 (re-run by me from `binding/`) |
| Environment as attested | `PRECONDITIONS_OK server='postgres (PostgreSQL) 17.6' … pg17_provenance='postgres_sha256=23cd1748… result=success'`; `IDENTITY_OK data_directory=/home/user/pg17/clusters/nq1/pg-data server_version_num=170006 cluster_name=nq1-disposable-pg17`; `OLD_ROOT … head=7d2895e1` (T root); `PREFLIGHT_OK ndir=absent … postgres_procs=0`, c1/b/r/s5 clusters `ABSENT` as predicted |
| Single run, once-only | PRE-1 preserving rename `runtime` → `runtime.v1-failed-61b93cff-20260924T204543Z` (receipt 25): the four v1 files hash identically before/after; v1 sentinel retained there. New run started only after the canonical validation lock was free (72 polls, no lock broken). One `START`/`END` pair; no retry |
| Acceptance criteria (brief §6: N01–N06, Q01–Q07 once on the exact head, raw receipts) | `jest.log` L2884-2907: 20 `✓`, `Tests: 20 passed, 20 total`, `Test Suites: 1 passed`, 354.69 s; `JEST_END rc=0`; the five v1 failures (N02, N03, N06, Q05 ×2) pass on the corrected spec; N05 negative control still surfaces the 409; `END rc=0 stage=done` |
| Receipts sealed | `receipts/RECEIPTS-v2r.sha256` 13/13 OK (25–27 included); `runtime/run/RECEIPTS.sha256`: `jest.log` OK; `nq1-pg-proof.log` mismatch at rest is the known runner design (sealed before the final `POST_OK`/`END` lines are appended) — `head -n -2 nq1-pg-proof.log | sha256sum` = sealed `c748a5da…` exactly. **C** (evidence hygiene, identical to R's runner), no action |

Findings from the run: none A/B. C only (log seal excludes the two trailing lines by design; `clusters/nq1/pg-data` retained stopped, disposal is a separate grant).

**FINAL ACCEPT** — the single PG run executed exactly the attested head `29e60705…` with the attested binding `aec60252…` in the attested environment, once, and its raw evidence satisfies N/Q1 acceptance (N01–N06, Q01–Q07, 20/20, rc 0). Scope of the claim: local real-PG proof on the isolated synthetic fixture; no deployment, drain or customer acceptance is claimed. Landing is the parent's decision.
