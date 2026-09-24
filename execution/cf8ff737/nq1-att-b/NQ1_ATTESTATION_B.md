# N/Q1 Attestation B — readers, cursor v2, PG proof validity, binding runner

Lane: T4 independent attestation B (Lens B). Read-only: `git -C` reads with `GIT_OPTIONAL_LOCKS=0`, `sha256sum`, `/proc` reads. No edits, commits, tests, PG start/init, or lock acquisition. Only this directory written.
Route: Claude Fable 5.1 / High was requested; **no telemetry is available to this attester, so no claim is made about the model or effort actually used.**
Time: 2026-09-24 (PDT). Author: attestation-B subagent.

## Verdict

**GO for exactly one PG run** of `execution/cf8ff737/nq1/binding/nq1-pg-proof.sh` at head `61b93cff` (invocation per README: `timeout -k 30 3600 bash execution/cf8ff737/nq1/binding/nq1-pg-proof.sh`, under the single-run grant).

A-class findings: none. B-class findings: none. C-class records: 9 (below; record/qualify only — none creates a fixer, audit, rerun, harness, control or delay).

## 1. Identity (confirmed)

| Item | Observed |
|---|---|
| HEAD | `61b93cff7900b24c17011d481fd6c31f5abb59e4` |
| Tree | `7adad6965d60269046b3240343b54d7f71582d70` |
| Parent | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (accepted R head; `merge-base --is-ancestor` true) |
| Worktree | `/home/user/workspace/worktrees/s7-nq1`, `status --porcelain --untracked-files=all` empty, no MERGE_HEAD |
| Subject | `feat(importer): page and write the ledger by composite provenance identity` |
| Diffstat vs R | 25 files, +2743/−193 |
| Accepted R/B bytes | `git diff --stat 7d2895e1 HEAD -- test/utils/g2-tq0-worker.cjs test/utils/g2-r-ready-* test/scout/g2-r-ready-db-guard.spec.ts test/rls-g2-r-ready.spec.ts prisma/migrations` empty; the eight R pins in the runner (blob ids) match HEAD |
| Hooks | `git rev-parse --git-path hooks` → `worktrees/s7-b-drain/.git/hooks` (common dir of the linked worktree); pre-commit and commit-msg both contain `lefthook` — runner precondition satisfiable |

Accepted R/B bytes were not re-audited (rule).

## 2. Lens B(2) — readers and cursor v2

Sources read at HEAD: `src/scout/scout-cursor.ts`, roster service, entities service, `scout-reconstruct.service.ts` (staging reader), DTO/controller/contract/openapi diffs, `test/scout/scout-cursor.spec.ts`, roster/entities unit specs.

Findings (all conform to brief §3 / grant P1–P3):

- **Format**: one `canonicalV2` builder shared by encoder and decoder; key order `{v,c,i,f,o,s,p}`; `o = source_id:asc,source_platform:asc`; prefix `v2.`; length ≤ 8192 checked before decode and after encode. Encoder fails closed (500 `cursor boundary not encodable`) on non-value `c/i/s` or non-canonical `p`; it never emits an undecodable token.
- **Roundtrip**: decoder requires exact base64url and an exact JSON re-encode match (canonical bytes), so any reordering/whitespace/extra key is a 400 `malformed cursor`. Legacy tokens cannot collide with `v2.` (base64url alphabet has no `.`).
- **Scope + endpoint binding**: decoded `c/i/f` must equal the request's coach, intent and family; other coach/intent/family → 400 with no page read. Roster family is the constant `RECONSTRUCT_ENTITY_TYPE` ('clients'); scope is never widened (count/page `where` unchanged).
- **Legacy boundary resolution**: `resolveScoutCursor` runs inside the RepeatableRead tx after the 404 gate, `findMany take 2` within scope; exactly one surviving scoped row with canonical `p` → resolved boundary, otherwise 400 `malformed cursor` (documented restart-from-first-page text is in the openapi descriptions). Roster legacy = raw source id, unbound (P1); entities legacy = scope-bound JSON.
- **Ordering / ties**: `scoutCursorOrder()` = `[{source_id asc},{source_platform asc}]` on every page including the first; `scoutCursorWhere` = `OR[{s>b.s},{s=b.s, p>b.p}]`; `next_cursor` is encoded from the last ledger row of the `take limit+1` page. Ties across platforms are enumerated exactly once (unit specs a-plat/b-plat/c-plat/truecoach; PG Q04 with the narrow index dropped).
- **Emission safety for first-party consumers**: mobile at `c7641cb3` (read via blob-identical `ux03c-compose` worktree; `/tmp/landing/growth-project-mobile` is a partial clone at a5933fd with missing blobs) calls only `GET /scout/reconstruct/entities` (`importReviewApi.ts:37`), passes `cursor` through opaquely, `getNextPageParam: last.next_cursor ?? undefined`, schema `next_cursor: z.string().nullable()`; no roster consumer. Extension at `aa0abd83` uses only `/api/scout/ingest`, `/ingest/complete`, `/progress`; no reader tokens. Emitting v2 is safe.
- **Contract**: version `2.0.0-c1-s1.1` → `2.0.0-c1-s1.2`; openapi diff = info.version + four description strings; pair surface unchanged (P3); pin test updated.
- **Unit coverage** exists for encoder shape/key order, worst-case length, fail-closed encoder, legacy decode, resolve 1/0/≥2/non-canonical/null, 25 malformed shapes with no transaction opened, ValidationPipe worst-case, roster scope-not-widened, tie enumeration, legacy=v2 twin, non-encodable last row → 500 with no token.

No A/B finding.

## 3. Lens B(3) — PG spec and harness validity

`test/rls-g2-nq1.spec.ts` (777 lines, blob `8ad3af3f…`): no `skip/only/todo`. `beforeAll` identity gate: db `g2_nq1_disposable`, data dir `…/clusters/nq1/pg-data`, cluster marker, 169 migrations, R shape present, candidate client `source_platform String` (required) vs old client `String?`, migrations diff vs OLD_HEAD empty; teardown authority pattern retained.

Cases exist and test their brief conditions:

- **N01** migrate deploy "No pending migrations"; catalog/wide/narrow/fence unchanged; staging `ORDER BY (s,p)`; ledger predicate carries `source_platform + source_id + entity_type`; INSERT includes `source_platform`; replay identical.
- **N02** N vs T tally per family (clients failEvery 6 → 20/4; workouts 24/0); provenance = staged; one row per five-tuple and narrow key.
- **N03** (a) T paused `staged` then N; (b) N paused `before-ledger` with txTimeout 60000, T observed `blocked()` via `pg_stat_activity` lock wait as admin, both converge; (c) N paused, T completes; (d) success dominates skip from both; `PG17_N03_QUERIES` logged incl. T rollbacks after waiting.
- **N04** ledger `(shared,truecoach)` + staged `(shared,auto:other.example)` → 409 `reconstruction provenance conflict` for both N and T; nothing written.
- **N05** `rDownFile` + nullify one row → Q1 roster read 500; N writer ∈ {409,500} logged; nothing written; T reclaims; `rUpFile` in `finally`; shape restored; deploy nothing pending.
- **N06** N writes, T replays identical; Q1/Q0 unions equal; `next_cursor` null.
- **Q01** exact v2 tokens per page, REPEATABLE READ in logged queries, only `(s,p)` ORDER BY on the ledger, first page ordered. **Q02** Q1→Q0→Q1→Q1 and Q0→Q1→Q0→Q0 chains at limit 1 plus full enumerations. **Q03** legacy = v2 result; resolve query precedes page query and follows REPEATABLE READ; forged/foreign-intent/skipped → 400 with `readPage(queries)` false. **Q04** narrow index dropped (restored from `pg_get_indexdef` in `finally`), a/p1,a/p2,a/p3,d enumerated once, Q0 fed v2(a,p2) → third row, tied legacy 400 with no page read, untied resolves. **Q05** other-family/intent/coach v2, legacy other family, non-canonical `p` → 400 no page read; foreign coach 404. **Q06** re-scoped/deleted/Deleted-state hidden; cursor advances to null; `ledgerCount 3`. **Q07** long v2 (256-char s,p) accepted by Q1 and Q0; oversize/malformed lists incl. 8193 length → 400, no reflection, no page read.

Real service, real clients, independent connections: `test/utils/g2-nq1-pg-harness.ts` requires `G2_NQ1_*` env (throws otherwise); each `worker()` forks the unchanged `test/utils/g2-tq0-worker.cjs` as a separate OS process with its own PrismaClient (query log, per-worker `application_name`); the worker redirects `@prisma/client` to `input.client` so N (`node_modules/.prisma/client`) and T (`$RT/old-root/.g2-nq1-old-client`) constructors never mix. Services are invoked in-process by the worker (same accepted etq0/B/R pattern). Negative controls: N04, N05, Q03/Q05/Q07 400/404/409/500 paths with "no page read / nothing written" assertions.

Old-root helper `g2-nq1-old-root.sh`: `git clone --no-checkout` of the candidate + detached checkout at `7d2895e1` outside the candidate root; gates on 169 migrations, E+R dirs, migrations identical to candidate, three `src/scout` service files byte-identical to OLD_HEAD, old schema `String?`; prints `G2_NQ1_OLD_ROOT_OK`.

Bootstrap `g2-nq1-bootstrap.sh` (blob `96b7668d…`): identity/marker checks before any write; roles matrix; marked DB, single-shot; step 4 old-root checks + `node_modules` symlink after `package.json/package-lock.json` diff-quiet vs candidate; step 5 `prisma migrate deploy` from the T root as `postgres` (non-superuser), asserts 169 applied, NOT NULL `source_platform`, both wide keys; step 6 T client generated inside the T root with `PRISMA_GENERATE_SKIP_AUTOINSTALL=1`, engine/runtime pinned to the shared tree, schema asserted R-shaped (`String?`); step 7 candidate client only verified (N-shaped `String`, no `String?`, wide keys); `G2_NQ1_BOOTSTRAP_OK`.

Default-Jest guard: `jest.config.js` `testPathIgnorePatterns` excludes `<rootDir>/test/rls/` and `<rootDir>/test/rls-.*\.spec\.ts$`; `jest.rls.config.js` inverts this. `test/scout/g2-nq1-db-guard.spec.ts` is DB-free and meaningful: accepts only the confirmed loopback target; refuses 31 unsafe URLs (other hosts, refused ports incl. 5432/6543/54321/55439/54325/55461/55471, other DB names incl. b/r/tq0/etq0/ledger_expand, password-in-URL, other roles, fragment, `schema=private`, duplicate/ambiguous params); refuses absent/mismatched confirmations; pins both markers as literals and asserts the bootstrap carries them verbatim (not env-derived); `withFixturePassword` limited to the login matrix. Receipt 11 shows `PASS test/scout/g2-nq1-db-guard.spec.ts` (affected 40/40 suites); receipt 12 full default jest 558 suites passed, 12 skipped (pre-existing), 8617 tests passed.

No A/B finding.

## 4. Lens B(4) — binding runner

Files at `execution/cf8ff737/nq1/binding/`, sha256 verified against `BINDING.sha256`:
`nq1-pg-proof.sh` `e47c9ac1…a190` ✔, `nq1-fixture.sh` `29db46ad…4bc3` ✔, `derive-nq1-pg-proof.py` `41624792…8bfe` ✔.

Pins verified against the live worktree/environment (all match): EXPECT_HEAD, EXPECT_TREE, SPEC blob `8ad3af3f…`, BOOTSTRAP blob `96b7668d…`, eight R object pins, R ancestor, `prisma/migrations` diff vs R empty, `node_modules` is a real directory inside `$W` (not a symlink), `.package-lock.json` `05bc530a…`, `.prisma/client/index.d.ts` `92d42c56…`, `dist/bin/postgres` `23cd1748…`, `dist/bin/initdb` `b7db9bc2…`, hooks lefthook.

Substitution-only vs accepted R runner (`787d34b0…`): after identity substitution the only differences are the header text, the N pins, the added R-object/ancestor/migrations preconditions, RDIR hashing before/after (never started), the N/Q1 old-root helper call with head/marker assertions, and removal of the R-specific O-ancestor check (O is not this proof's old side). Fixture derived from `r-fixture.sh` (`6e71d754…`) with identity substitution only.

Discipline confirmed in the runner text:
- **Single run**: refuses if sentinel exists (rc 76); `flock -n` on `execution/test-validation.lock` (rc 75); the fixture refuses standalone use unless `NQ1_RUNNER_PID` names a live `nq1-pg-proof.sh`; refuses unfilled `__` pins (rc 70).
- **Preconditions**: `$NDIR` absent, `$RT/old-root` absent, port 55481 listeners = 0, `pgrep -cx postgres` = 0, s5 absent, c1/b-drain/r-ready `postmaster.pid` absent with conf/pg_control hashed and re-checked at the end.
- **Live state now**: `/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-…`, `r-ready`; no `nq1`; `$RT` (`execution/cf8ff737/nq1/runtime`) does not exist; port 55481 free; 0 postgres processes; no active flock on the lock inode (`/proc/locks`); disk 4.5 GiB free on `/` (R run consumed ~77 MB runtime + ~76 MB cluster; repo objects 7 MB).
- **Bounds**: init 60, start 60, old-root 180, bootstrap 900, identity 4×15, jest 1500, stop 75; outer `timeout -k 30 3600`.
- **Proof invocation**: `jest --config jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci`, once; no `--forceExit/--testTimeout`; guard refusal strings surfaced.
- **Cleanup**: bounded `stop` on failure only when this run started the postmaster; post-stop asserts 0 procs, 0 listeners, no `postmaster.pid`, data dir retained; other clusters unchanged; worktree porcelain and HEAD unchanged; `RECEIPTS.sha256` over log + jest log; sentinel with RC/STAGE/HEAD.

**GO/NO-GO: GO** for one run.

## 5. C-class records (record only)

1. N01 asserts the five-field predicate and INSERT with `source_platform`, but does not explicitly label native-vs-emulated upsert branch (brief §4 wording); harmless.
2. N03 "P2002 retry path observed" is logged (`PG17_N03_QUERIES` rollbacks) rather than asserted.
3. Q07 "maximal" (256-char c/i) token is refused by scope mismatch with the same `malformed cursor` message as the length bound; true maximal emitted-token acceptance is proven by the unit test through ValidationPipe, not on PG.
4. The PG proof drives services in-process (no HTTP/ValidationPipe), consistent with the accepted etq0/B/R pattern.
5. Roster "resolve before any count" test counts `ledgerReads` only; code order verified by reading the service.
6. Builder's own C notes in SOURCE_READY (tsc needs 4 GiB heap — baseline also OOMs; T-root deploy design; N05 accepts 409 or 500; two spec-only fixes; direct flock for the heavy slot) — acknowledged, not re-opened.
7. Runner has no explicit disk-floor check (same as the accepted R runner); current free space 4.5 GiB vs ~150 MB observed R consumption.
8. Old-root helper default is a self-contained local clone (not `--shared`); with a 7 MB object store this is immaterial.
9. `/tmp/landing/growth-project-mobile` is a partial clone with missing blobs at a5933fd; mobile consumer verification used the blob-identical `ux03c-compose` worktree at `c7641cb3`.

## 6. What this attestation does not claim

- It does not claim the PG proof has run or passed; the runner has not been executed (no `$RT`, no sentinel).
- It does not re-accept R/B bytes; it only confirms they are unchanged at this head.
- It makes no claim about the model/effort used to produce this attestation (no telemetry).
