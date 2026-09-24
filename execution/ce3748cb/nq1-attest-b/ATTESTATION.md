# N/Q1 v2r — T4 delta attestation B

**Verdict: GO** for a single PG run of `nq1/binding/nq1-pg-proof.sh` (sha256 `aec602521f377a2b825026b1437fa57439794236321cb617129c48dc7e134756`) against `s7-nq1` HEAD `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` (tree `511710ee0c361a2ec68bf217c4d47f8504ef2790`), subject to the one mechanical pre-step in §7.

Attester: independent T4 delta attester B. 2026-09-24 ~20:45Z. Read-only: no PG process, no cluster, no file written outside this directory. Attester A's report not read. v1 bytes (parent `61b93cff`, previously dual-GO) not re-audited; only the delta and the five v1 failures were examined. Authority: `execution/cf8ff737/NQ1_V2_MINIMUM_CORRECTION_GRANT.md` + `execution/ce3748cb/NQ1_V2R_REBUILD_GRANT.md`. No model/effort claim is made.

## 1. Delta confinement — CONFIRMED

Independently re-derived from the worktree (`git diff --name-status 61b93cff HEAD`):

```
M  test/rls-g2-nq1.spec.ts          (8ad3af3f → a93382605a7e8099f5fd622cf2d0a92298460bd3)
M  test/utils/g2-nq1-pg-harness.ts  (c8f6fea8 → d51267f2c8a9972de4361f691f680b0792595209)
2 files changed, 178 insertions(+), 40 deletions(-)
```

- No `src/**`, `prisma/**`, contract/OpenAPI, worker (`test/utils/g2-tq0-worker.cjs`), bootstrap (`96b7668d…` unchanged), or other harness path changed.
- All 20 accepted S5/B/R pinned blobs that the runner checks (lines 80–95) re-derived at HEAD by me: **20/20 match**. `0d69c7ba` and `7d2895e1` are ancestors; `prisma/migrations` identical to `7d2895e1`.
- Exactly one commit on `61b93cff` (`git rev-list --count 7d2895e1..HEAD` = 2 → 61b93cff + 29e60705).

## 2. The five v1 failures were spec-only, and each correction is genuine — CONFIRMED

Source of failure facts: `nq1/NQ1_PG_PROOF_RESULT.md`, `receipts/15-pg-proof-jest-matrix.txt` (5 failed / 15 passed; in every failing case the N==T equality assertion had already passed).

| v1 failure | Root cause (verified in product code) | v2r correction | Genuine / derived? |
|---|---|---|---|
| **N02** `spec:272` expected clients 20/4 failed, got 24/0 | `stageMany(..., failEvery)` wrote `name='FAIL'`. Registered mappers skip only on `unsupported_platform` or `missing_source_id` (`truecoach-clients.mapper.ts:36,40`, `truecoach-entity.mapper.ts:41,44`) — payload name is never inspected. Knob inert; 20/4 unreachable. | Harness `skipEvery`: every k-th row staged under `UNMAPPED_PLATFORM='auto:other.example'` (passes `isCanonicalPlatform`; not in `buildSourceMapperRegistry()` = {truecoach, conformance_alpha}). `families.ts map()` → `unsupportedPlatform(row)` → engine `writeOutcome(skipped, 'unsupported_platform:auto:other.example')`, `target_id` null. | Yes. Expected 24, k=6 → `floor(24/6)=4` skipped / 20 reconstructed / 0 failed for **both** families (workouts now also carries non-success; v1 had it all-success). Exact `toEqual` tally (stricter than v1's `toMatchObject`); skipped rows asserted row-by-row (`s00006,s00012,s00018,s00024`, platform, status, null target, product reason); zero reconstructed rows with the unmapped platform/null target/non-null reason. N==T: `src/scout/reconstruct/**`, `mappers/**`, `scout-platform.ts` and the worker are byte-identical between `7d2895e1` and HEAD (`git diff --quiet` empty); T's engine applies the same skip path and the same precedence rule (`updateMany` where `status != reconstructed` for non-success). |
| **N03(a)** `spec:302` expected reconstructed 1, got 4 | N01 stages `a,b,c` in the default scope; N03(a) staged `m1` without `resetData()` → 1+3. | `resetData()` added before staging `m1`. Original assertions kept. | Yes — pure isolation fix. |
| **N06** `spec:437` expected clients 9, got 12 | Same inert knob (`failEvery=4`). | `skipEvery=4`: 12 rows → `floor(12/4)=3` skipped / 9 reconstructed (clients); workouts 12/0 retained. Exact tally `toEqual`; skipped count asserted by platform+reason; visible union = 9 because both readers filter `status: reconstructed` (`scout-roster.service.ts:118`, entities likewise) — verified. | Yes, derived. |
| **Q05 ×2** `spec:654` expected 404 for a foreign coach with a scoped v2 token, got 400 | `decodeScoutCursor(cursor, coachId, intentId, family)` runs **before** the `$transaction` settled/ownership gate in both readers (`scout-roster.service.ts:68` vs `:94`; `scout-entities.service.ts:81` vs `:104`) and throws `BadRequestException('malformed cursor')` on `v.c !== coach \|\| v.i !== intent \|\| v.f !== family` (`scout-cursor.ts:80-88`). Brief L103: "foreign coach/intent → 400 `malformed cursor`". The spec's 404 was wrong. | Every scope-bound token (all v2; legacy *entities* token carries `c/i/f`) presented by a foreign coach **and** for a foreign intent → `toEqual(MALFORMED)`, `readPage()` false, failure JSON contains neither the token nor `foreign`. Token-less request and the scope-less legacy *roster* token (bare base64url source id; `scout-cursor.ts:73-76` returns `{s}` with no scope check) → reach the uniform 404 gate; asserted 404 with no page read (only `scoutImport.findUnique` runs before the throw). | Yes, matches brief L103 and the accepted R ordering. Family-conditional lists are correct: roster legacy token only exists for `clients`; entities legacy token only for `workouts`. |

**N03 "success dominates" vs a genuine non-success in both orders (grant items 3–4, brief L95):**

- (a) and (c): a genuinely skipped sibling (`m1-skip`, `m3-skip` under the unmapped platform) is staged beside the reconstructed row. Both writers, in both orders (N-completes/T-resumes; T-completes/N-resumes), tally `{staged 2, reconstructed 1, skipped 1, failed 0}`; one ledger row per identity; sibling reason = product reason. Ordering assumption `m1 < m1-skip`, `m3 < m3-skip` under `ORDER BY entity_type,source_id,source_platform` holds (prefix).
- (d) success-then-later-refusal (T then N, labelled `fixture:mapper-skip`): `m3` keeps `reconstructed` + `targetBefore` + null reason (engine: non-success `updateMany` is filtered to `status != reconstructed`). Sibling `m3-skip` takes `fixture:mapper-skip` — I independently derived this from `writeLedger`: the fixture mapper replaces `families.get(family).map` for the whole family, so the skipped sibling is rewritten by the last serialized non-success writer (`data: outcome` includes `reason`). The builder's amend (receipt 22) corrected exactly this before any PG run — derivation from code, not tuning to an observation (no PG was run).
- (e) new, the other order: committed skip first (by T, then by N) → later success from the other writer becomes `reconstructed` with a minted target and null reason (engine: `reconstructed` `updateMany` has no status filter). Asserted for both writer orders, plus `Person` count 0→1 and one ledger row.

**Recorded limit (C, agree with builder):** a same-identity success↔non-success flip cannot arise from staged data alone — the registered mappers' only skip branches depend on identity fields (`source_platform`, `source_id`), and the platform is part of the wide identity (changing it is the N04 409 path). The same-identity contest in (d)/(e) therefore necessarily uses the accepted, explicitly labelled fixture mapper of the unchanged shared worker (already used by v1's (d), dual-GO). No data-reachable `failed` exists (`failed` requires a throwing mapper or a DB error). The grant's stop condition ("no genuine non-success path reachable through data") did not trigger: `skipped` is genuinely reached. Coverage is preserved and extended, not reduced.

**Not tuned:** every changed number is `count − floor(count/k)` from the fixture, every reason string is the product's literal, and no expectation in the delta was set from a PG observation (none exists for this head).

## 3. Runner binding executes exactly this head and refuses drift — CONFIRMED

- `sha256sum -c binding/BINDING.sha256` → 3/3 OK (`nq1-pg-proof.sh` `aec60252…`, `nq1-fixture.sh` `29db46ad…`, `derive-nq1-pg-proof.py` `41624792…`).
- `diff nq1-pg-proof.sh.v1-61b93cff nq1-pg-proof.sh` = **exactly** the header sentence and three lines: `EXPECT_HEAD=29e60705…`, `EXPECT_TREE=511710ee…`, `EXPECT_SPEC_BLOB=a9338260…`. No other runner change; v1 copy retained (`e47c9ac1…`).
- Refusal surface (verified in the script): placeholder pins (rc 70); fixture sha; `HEAD`, `HEAD^{tree}` (covers the harness blob), spec blob, bootstrap blob; `status --porcelain --untracked-files=all` empty; no `MERGE_HEAD`; lefthook in `pre-commit` + `commit-msg`; 20 S5/B/R pinned blobs; B and R ancestry; `prisma/migrations` == R; isolated non-symlink `node_modules` with lock/client shas; jest/ts-node/prisma bins; PG binary shas; `/usr/bin/psql`. Post-run re-checks HEAD and porcelain hash (rc 74). Sentinel present → rc 76; lock busy → rc 75.
- Donor clusters (`s5`, `c1-builder`, `b-drain`, `r-ready`): the preflight's `else` branches record `ABSENT` and only *require* S5 absence — no "ABSENT" edit was needed; correct that none was made.
- Live preconditions I re-checked now: HEAD/tree match; porcelain (incl. untracked) 0 lines; hooks at `repos/growth-project-backend/.git/hooks/{pre-commit,commit-msg}` are lefthook; `node_modules` real dir inside the worktree; `.package-lock.json` `05bc530a…` ✓, `.prisma/client/index.d.ts` `92d42c56…` ✓; bins present; `/home/user/pg17/clusters` absent; `pgrep -cx postgres` = 0; port 55481 free.
- Export: `EXPORT-v2r.sha256` 3/3 OK; `git bundle verify` okay, single head `refs/heads/s7-nq1` = `29e60705…`, prerequisite `7d2895e1`.

## 4. Environment pins — CONFIRMED

`env/ENV_RECEIPTS.sha256` 8/8 OK. Live: `dist/bin/postgres` `23cd1748…` ✓ (17.6), `dist/bin/initdb` `b7db9bc2…` ✓, `/usr/bin/psql` 18.6 ✓, `PROVENANCE.txt` `postgres_sha256=23cd1748… result=success` ✓ (the format the runner greps). Dependency pins as in §3. Client engine pin is in the receipts (not runner-checked; consistent).

## 5. Identity / hook posture — CONFIRMED

Author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, `2026-09-24T20:29:51Z` both. Body has no co-authored/generated/model/signed-off tokens. Receipt 22 shows the amend ran the tracked lefthook v2.1.9 hooks genuinely: `prod-readiness-quick`, `banned-cast-tokens`, `eslint`, `prettier`, `tsc` (49.5 s), `no-ai-tokens` — all ✔; hooks installed from the isolated tree (receipt 20, recovered clone had only `.sample`). The amend of `3f2d7a77` is recorded openly (PINS.txt, `export/superseded-3f2d7a77/`), happened before any attestation, and yields one ordinary hooked commit on `61b93cff` — compliant with "one new commit". Receipt 19's first line (`--cached` wrong flag, rc 1 operational) is kept honestly; the hook's `--mode=staged` run is authoritative ✔. `RECEIPTS-v2r.sha256` 9/9 OK; v1 `RECEIPTS.sha256` still verifies.

## 6. Findings

| # | Class | Finding | Harm / decision blocked | Closure |
|---|---|---|---|---|
| F1 | **C** | No data-reachable `failed` outcome and no same-identity genuine flip exist in current `src/scout`; N03(d)/(e) precedence uses the labelled fixture mapper (accepted in v1). Genuine `skipped` covers the grant's "failed or skipped". | None. Brief L95 coverage ("success dominates failed/skipped both ways") is exercised in both orders and both writer roles. | RECORD / CONTINUE. Do not add product code. |
| F2 | **C** | Q05's "foreign-scope rows invisible" (brief L103 second clause) is not asserted in Q05 itself; it is v1 territory (Q03/Q06 patterns) and unchanged. | None to this delta. | RECORD. |
| F3 | **C** (precondition, see §7) | v1 `runtime/run/nq1-pg-proof.sentinel` exists → runner exits 76 by design. `runtime/old-root` absent (sandbox loss). | Blocks the *run mechanically*, not the decision. | Parent's PG grant includes the preserving rename of v1 `nq1/runtime/` (e.g. `runtime.v1-failed-61b93cff-<UTC>`), nothing deleted. The v2 grant's planned `clusters/nq1` rename is moot (directory no longer exists). |
| — | — | No A or B finding. | | |

## 7. Decision

**GO** for exactly one run of `timeout -k 30 3600 bash execution/cf8ff737/nq1/binding/nq1-pg-proof.sh` from `/home/user/workspace`, bound to `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` / tree `511710ee…` / runner `aec60252…`, on condition that the PG grant first performs the preserving rename of v1 `nq1/runtime/` (F3) and the run starts only when `execution/test-validation.lock` is free (it is currently held by another lane's jest — the runner will self-refuse rc 75 otherwise; that is a scheduling fact, not a defect). Any other change to the worktree, binding, or environment before the run invalidates this attestation.

---

## 8. FINAL — post-run verification (2026-09-24 ~20:58Z, read-only)

**FINAL ACCEPT.** The single PG run executed exactly the attested head and binding, and its evidence satisfies N/Q1 local acceptance (brief §6: N01–N06, Q01–Q07 once on the exact candidate head with raw receipts).

Independently verified from `nq1/runtime/run/*` and receipts 25–27 (not from the result document alone):

| check | evidence |
|---|---|
| Exact head | log line 1 `START … head_expect=29e60705…`; sentinel `RC=0 STAGE=done END=2026-09-24T20:54:50Z HEAD=29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd`; worktree still at `29e60705`, porcelain 0 (runner `POST` re-check passed → `POST_OK`). |
| Exact binding | `binding/BINDING.sha256` still verifies 3/3 (`nq1-pg-proof.sh` = `aec60252…`, the attested sha) — no post-attestation runner change. `PREFLIGHT_OK worktree_porcelain_sha=e3b0c442…` (sha256 of empty = clean, incl. untracked). |
| Preconditions | `PRECONDITIONS_OK 20:48:30Z` PG 17.6, psql 18.6, jest 30.4.1, provenance `23cd1748…`; donor clusters recorded `ABSENT` (c1/b/r) and s5 `ABSENT` as the attestation predicted; `ndir=absent port55481=free postgres_procs=0`. |
| Fixture / T side | `FIXTURE_INIT rc=0`, `FIXTURE_START rc=0`, `OLD_ROOT rc=0 head=7d2895e1…`, `BOOTSTRAP rc=0`, `IDENTITY_OK data_directory=/home/user/pg17/clusters/nq1/pg-data server_version_num=170006 cluster_name=nq1-disposable-pg17`; in-spec `PG17_DATABASE {… "database":"g2_nq1_disposable", "directory":"/home/user/pg17/clusters/nq1/pg-data", "version":"170006"}`. |
| Jest | `JEST_START 20:48:54Z` with the bound command (`jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci`) → `JEST_END rc=0 20:54:49Z`; `jest.log`: **20 ✓, 0 ✕, `Tests: 20 passed, 20 total`, 354.69 s**; all five v1 failures (N02, N03, N06, Q05 ×2) pass under the corrected titles; `PG17_N03_QUERIES` and `PG17_N05_WRITER 409` markers present; 404 `PG17_PROCESS` worker records. |
| Seals | `runtime/run/RECEIPTS.sha256`: `jest.log` `40988d89…` OK. `nq1-pg-proof.log` sealed value `c748a5da…` equals `head -n -2` of the file (I recomputed it) — the runner seals before appending `POST_OK`/`END` (script line 190 then `finish()`), identical to the R runner's design; full file `ca5d3803…`, 554 lines. **C** (evidence hygiene): record, no action. `receipts/RECEIPTS-v2r.sha256` 13/13 OK. |
| PRE-1 | receipt 25: `runtime` → `runtime.v1-failed-61b93cff-20260924T204543Z` by `mv`; the four v1 hashes identical before/after; directory present now. Nothing deleted; v1 failure remains recorded. |
| Lane after | `pgrep -cx postgres` = 0; no `postmaster.pid`; `clusters/nq1/pg-data` retained stopped per runner; `STOP_STATE_OK`, `POST_OK`, `END rc=0 stage=done`. Single run, no retry (sentinel now blocks any rerun). |

Findings: none A/B. C: runner-log seal excludes its own last two lines (design). Scope of this acceptance: local real-PG proof of N/Q1 on the isolated synthetic fixture on the exact head `29e60705…`; no deployment, drain, or customer acceptance is claimed.
