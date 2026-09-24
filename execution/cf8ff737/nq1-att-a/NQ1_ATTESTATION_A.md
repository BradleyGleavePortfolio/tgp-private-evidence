# N/Q1 — T4 attestation A (Lens A: final writer and contract)

**Verdict: GO** for one single-run PG proof of `execution/cf8ff737/nq1/binding/nq1-pg-proof.sh` on the exact head below. No A or B findings. Five C records (no action).

| field | value |
|---|---|
| Attester | `nq1_att_a` — independent of the builder; read-only (`git -C` with `GIT_OPTIONAL_LOCKS=0`; no edit/commit/push/test/PG/lock). Wrote only `execution/cf8ff737/nq1-att-a/`. |
| Route | requested Claude Fable 5.1 / High — **no telemetry available; none claimed.** |
| Time | 2026-09-24 ~18:30Z |
| Head bound | `61b93cff7900b24c17011d481fd6c31f5abb59e4` tree `7adad6965d60269046b3240343b54d7f71582d70` parent `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (R, accepted) in `/home/user/workspace/worktrees/s7-nq1`, branch `s7-nq1`, `git status --porcelain` empty |
| Inputs read | `NQ1_BUILD_GRANT.md` (P1–P3), `nq1-prep/NQ1_SLICE_BRIEF.md`, `nq1/SOURCE_READY.md`, receipts 01–13 + `RECEIPTS.sha256`, `nq1/binding/*`, `nq1/export/EXPORT.sha256`, R binding `r-ready/binding/{r-pg-proof.sh,r-fixture.sh}` (hash only), `/tmp/tgp-agent-context/AGENT_RULES.md` |
| Not done | No re-audit of accepted R/B bytes (only blob-identity pins re-checked). No gate rerun. No PG case executed. |

## 1. Identity, provenance, scope

- Commit object: author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`; `%(trailers)` = `[]`; single parent `7d2895e1`; `7d2895e1` is an ancestor. Not pushed.
- Hooks: receipt 13 shows genuine Lefthook v2.1.9 `pre-commit` (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc) and `commit-msg` (no-ai-tokens), all ✔; hooks dir `worktrees/s7-b-drain/.git/hooks/{pre-commit,commit-msg}` contain lefthook now. Commit rc=0.
- Diff `7d2895e1..61b93cff`: 25 files, +2743/−193. Every path is inside the granted owned set — NQ1-a reader (cursor module, two services, two DTOs, two controllers, `scripts/importer-contract.ts`, regenerated `docs/contracts/importer-openapi.json`, contract pin spec, cursor/roster/entities specs), NQ1-b writer (`prisma/schema.prisma` ledger line + comment only, `scout-reconstruct.service.ts`, three test fakes), NQ1-c test-only (`test/rls-g2-nq1.spec.ts`, `test/utils/g2-nq1-{db,harness,pg-harness}.ts`, `g2-nq1-bootstrap.sh`, `g2-nq1-old-root.sh`, `test/scout/g2-nq1-db-guard.spec.ts`). Nothing under mobile/extension/CI/native writers.
- `prisma/migrations`: tree object `ed358876…` identical at R and N/Q1; `git diff --quiet 7d2895e1 HEAD -- prisma/migrations` clean. No migration, no C work packaged.
- `schema.prisma` change is exactly `source_platform String? → String` plus the D1 comment rewrite; both `@@unique` lines retained (narrow + wide `ScoutReconstructionLedger_identity_key`).

## 2. Final writer (required-p, five-field wide selector) on R

Read at `HEAD:src/scout/scout-reconstruct.service.ts`:

- **Selector:** `upsert({ where: { coach_id_intent_id_entity_type_source_platform_source_id: identity }, create: {...identity, ...outcome}, update: {} })` with `identity` = five fields including `source_platform: row.source_platform`. No `coach_id_intent_id_entity_type_source_id` reference remains anywhere in `src/` or `test/` (`git grep` at HEAD: zero hits). No narrow-selector dependency.
- **Null-claim removed:** the `updateMany OR[{p:null},{p:row.p}]` step and its `count !== 1` check are gone; there is no claim step (so the harness `claimed` barrier can never fire — spec uses `staged`/`before-ledger`, consistent with the brief).
- **Transactional:** `family.persist` (target) then `writeLedger` in one `$transaction`, target-before-ledger lock order kept; `retryContention` wraps the whole transaction; `writeOutcome` (skip/failed) also one transaction with the same retry wrapper.
- **Precedence:** unchanged success-dominates `updateMany` keyed on the five-field identity: `reconstructed` writes unconditionally; non-success only where `status != reconstructed`.
- **Ordering:** staging page `orderBy [{source_id:'asc'},{source_platform:'asc'}]` with `skip` (post-settle, unchanged risk profile).
- **P2002 handling:** `retryContention` retries once on P2002/P2034; if the retry throws P2002 again it throws `ProvenanceConflict` (409 `'reconstruction provenance conflict'`); any other second error is rethrown. In `reconstructRow` the success-path catch rethrows `ProvenanceConflict` (does not record `failed`); on the outcome path it propagates out of `writeOutcome`. Result for the brief's **narrow collision on R** (ledger `(s,p1)` committed, staged `(s,p2)`): wide upsert misses → INSERT hits the narrow key → P2002 → retry → P2002 → 409, transaction rolled back, nothing written = T parity, not a raw 500. Reasoning in the code comment is sound: a wide-identity race cannot yield a second P2002 because the retry's upsert matches the committed row and ledger rows are never deleted. Unit test `maps a P2002 that survives the single retry to the 409 provenance conflict` (upsert called twice, ledger size 0) and PG case N04 (N and T both 409, ledger/targets/count unchanged, `nullCount()=0`) cover it.
- **N05 409|500 qualification — judged acceptable (C):** N05 is a negative control for the release-order precondition "N/Q1 only on R". On the E+B shape the N client has no wide unique in the DB and a NULL-p row exists; native upsert fails on the missing ON CONFLICT target (500) while an emulated upsert hits the narrow key (409). The spec accepts either **and asserts** `write.result` undefined, targets unchanged, `ledgerCount` unchanged, `nullCount()=1` (nothing fabricated, nothing partial), logs `PG17_N05_WRITER`, then proves T reclaims and R-up restores shape with `No pending migrations`. That is the property the brief requires; the status code in a forbidden deployment state is not product-reachable. Record only.

## 3. P1 / P2 / P3 and contract drift

Read at `HEAD:src/scout/scout-cursor.ts`, both services, DTOs, controllers, `scripts/importer-contract.ts`, OpenAPI diff:

- **P1 exact:** `resolveScoutCursor` — legacy boundary → `findMany({ where: {coach_id, intent_id, entity_type, status:'reconstructed', source_id}, select:{source_platform}, take:2 })`; exactly one row with `isCanonicalPlatform(p)` → `{s,p}`; zero or ≥2 → `throw new BadRequestException('malformed cursor')`. No new public string. Restart semantics documented in DTO/controller 400 text and the regenerated OpenAPI.
- **P2 exact:** single code path; no source-only fallback, no env/config/runtime schema detection anywhere in the cursor module or services. Resolution runs inside the RepeatableRead transaction after the 404 gate and before any count/page read (roster and entities), strictly within `(coach, intent, family)`; roster scope fixed to `RECONSTRUCT_ENTITY_TYPE` (`clients`).
- **P3 exact:** `CONTRACT_VERSION '2.0.0-c1-s1.1' → '2.0.0-c1-s1.2'` once; pin spec L442 updated. OpenAPI diff is 10 lines: the version and the four cursor/400 description strings (entities cursor, entities 400, roster cursor, roster 400) — the pair-surface section is untouched. The checked-in JSON is byte-checked against a fresh in-process and subprocess regeneration by `test/contracts/importer-contract.spec.ts`, which PASSED in receipt 11.
- Emission: `encodeScoutCursor` uses the shared `canonicalV2` builder (key order `{v,c,i,f,o,s,p}`), asserts `value()` on c/i/s and `isCanonicalPlatform(p)`, and fails closed (500 `'cursor boundary not encodable'`) rather than emit an undecodable token — unreachable on R because ingest bounds s ≤256 UTF-16 units and the DB CHECK enforces canonical p. Decoder keeps exact base64url + exact JSON re-encode; `SCOUT_CURSOR_MAX_LENGTH` 8192 enforced pre-decode and via `@MaxLength` in both DTOs (unchanged). Both readers `select source_platform`, order `[source_id, source_platform]` on every page, and use the lexicographic OR predicate from `scoutCursorWhere(position)`.
- Contract text ↔ code consistent: "Accepts legacy and scoped v2 tokens; emits scoped v2", unresolvable legacy → 400 restart.

## 4. Receipts and gate claims (verified, not rerun)

- `RECEIPTS.sha256`: all 13 receipts OK (`sha256sum -c` inside `receipts/`). `BINDING.sha256`: 3/3 OK. `EXPORT.sha256`: 4/4 OK.
- Freeze (05): `WRITE_TREE=7adad696…` = committed tree; staged 25 paths, unstaged/untracked 0 → gates ran on the committed source.
- 07 tsc rc=0 (4 GiB heap); 08 eslint rc=0 on 21 changed `.ts`; 09 prettier rc=0; 10 check-r75 rc=0 "no positive token change", `bash -n` rc=0 on both shell helpers.
- 11 affected Jest rc=0: `Test Suites: 40 passed, 40 total`, `Tests: 5 skipped, 726 passed, 731 total`; includes PASS for `importer-contract.spec.ts`, `scout-cursor.spec.ts`, `scout-reconstruct.service.spec.ts`, roster/entities service specs, `g2-nq1-db-guard.spec.ts`.
- 12 full Jest rc=0: `Test Suites: 12 skipped, 558 passed, 558 of 570 total`, `Tests: 159 skipped, 5 todo, 8617 passed, 8781 total`, 699 s. `test/rls-*.spec.ts` excluded by the default `testPathIgnorePatterns`, so the PG spec did not run (correct).
- 06 lock: flock held 18:09:22Z→18:22:14Z and 18:23:03Z→18:23:55Z; `LOCK_FREE_VERIFIED`. 13 commit rc=0.
- 02/03: isolated `node_modules` copy, nlink 1 on `.prisma/client` files, N-only `prisma generate`; live check now: `node_modules/.prisma/client/index.d.ts` = `92d42c56…`, `.package-lock.json` = `05bc530a…` (match pins).

## 5. Binding — GO/NO-GO for a single PG run

- `nq1-pg-proof.sh` sha256 `e47c9ac1bd073e2b92432bf1a4809bd2d30e4c63c61aec33fa0ccc339746a190` (matches task, PINS.txt, BINDING.sha256). `nq1-fixture.sh` `29db46ad…`, `derive-nq1-pg-proof.py` `41624792…`.
- **Derivation reproduced independently** into `nq1-att-a/scratch/`: `derive-nq1-pg-proof.py` run against the accepted R binding (`r-pg-proof.sh` `787d34b0…`, `r-fixture.sh` `6e71d754…`) yields `nq1-pg-proof.sh` = `e14db001…` and `nq1-fixture.sh` = `29db46ad…` byte-identically. `diff` substitution-only vs filled = header line 2 wording + exactly the five pins (`EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/FIXTURE_SHA`). `nq1-pg-proof.sh.diff-vs-r` reproduces exactly.
- **Pins vs head:** HEAD `61b93cff…`, TREE `7adad696…`, `HEAD:test/rls-g2-nq1.spec.ts` = `8ad3af3f…`, `HEAD:test/utils/g2-nq1-bootstrap.sh` = `96b7668d…`, fixture sha `29db46ad…` — all match. All 19 blob pins for accepted S5/B/R files and the R migration dir match at HEAD; B `0d69c7ba` and R `7d2895e1` are ancestors; PG binaries `23cd1748…`/`b7db9bc2…` match; PG 17 dist present.
- **Environment preconditions currently satisfied (read-only observation):** `/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-…`, `r-ready` only (no `nq1`); `execution/cf8ff737/nq1/runtime` absent; port 55481 has no listener; `pgrep -cx postgres` = 0; `test-validation.lock` exists and is free (the runner takes it with `flock -n`, exit 75 if busy).
- Runner safety: refuses placeholders (70), dirty worktree, hookless commit, adopted lane dir (71), sentinel reuse (76); bounded stages (soft sum 2835 s < 3600 outer); T root = detached checkout of `7d2895e1` outside the candidate at `RT/old-root`, T client generated into `RT/old-root/.g2-nq1-old-client` (custom `output`), never into the shared `node_modules/.prisma` → the N client is verified, not regenerated; retained C1/B/R clusters hashed pre/post, never started; data dir retained after stop; single Jest invocation `jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci` (config `testMatch` covers `test/rls-*.spec.ts`).
- Guard `g2-nq1-db.ts` refuses B (55461) and R (55471) ports and names.

**GO.** Invocation under the separate single-run grant only: `timeout -k 30 3600 bash /home/user/workspace/execution/cf8ff737/nq1/binding/nq1-pg-proof.sh`.

## 6. Findings (Safety ROI)

No A. No B.

C (record only; no fixer, rerun, or delay):
1. **Prose vs behaviour on legacy tokens.** Commit body and SOURCE_READY say "Cursors minted by the R readers are rejected the same way / a cursor from a Q0/R response is always 400". The code, DTO/OpenAPI text and tests do the opposite and correct thing: R/Q0 legacy tokens are accepted and resolved; only an unresolvable one (0 or ≥2 rows) is 400. P2 as granted ("missing boundary on R → always 400, no fallback") is what is implemented. The commit message is immutable at this head; read it as "rejected the same way when unresolvable".
2. `test/utils/g2-nq1-old-root.sh` is not in the brief's NQ1-c file list but is test-only, `g2-nq1-*`-prefixed, within the grant's "harness adapted from R's" and inside the worktree; its clone recipe is the accepted S5/R one (git object hardlinks in a local clone are immutable objects, not the forbidden `node_modules` hard links).
3. SOURCE_READY says eslint ran on "22 changed .ts"; receipt 08 lists 21 files, which is the complete set of changed `.ts` files. Counting slip only.
4. N05 409|500 (see §2) and the T-root "whole history via `migrate deploy`" deviation from "by file" — both already recorded by the builder; N/Q1 ships no migration so a by-file replay would be a no-op, and N01 asserts "No pending migrations".
5. Heavy slot taken by direct `flock` (builder's recorded precedent) rather than parent relay; exclusivity was still guaranteed by the primitive; receipt 06 shows no displaced holder.

## 7. Boundaries of this attestation

Attests: implemented + unit/contract-tested + gate-green at exact head, and that the binding is fit for one PG run. Does **not** attest: the PG cases N01–N06 / Q01–Q07 (not yet run), merge eligibility, deployment, drain, or customer acceptance. Attestation B (Lens B: cursor contract/pagination completeness) is required independently per G10 before the PG grant is dispatched.
