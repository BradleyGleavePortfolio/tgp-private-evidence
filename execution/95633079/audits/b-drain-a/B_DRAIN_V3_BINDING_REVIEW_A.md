# S7-3′ B/drain — same-review binding of frozen v3 (affected closure/adapter/binding lines only)

Reviewer A, continuation of `B_DRAIN_SOURCE_REVIEW_A.md` / `B_FIXTURE_PROPOSAL_REVIEW_A.md` (both immutable). Read-only git/blob comparisons and file reads only; no install, copy, hooks, lock, test, PG, probe, commit or index write. Peer B unread. Class C entries record/qualify only; no optional controls or extra assertions requested.

## 0. Disposition

**v3 tree `00b105ffe362c27808a38c44c6db1f733134f074`: all requested closures land correctly except one — the added zero-retry DB-free unit case (B-1) is wrong as written and will be red at the phase-A `jest` gate. Class B, test-only, one hunk.** Product SQL/TS closures (F1 fence identity, zero-retry bound, S1+C1 history, F2 ACL/direct-call proof, identity adapters) are verified and need no further change. Disposition therefore: **not yet commit-grantable as v3; grantable as v4 = v3 + the FB-3 hunk (format-only lock, same-review binding of that hunk only).** Binding template remains placeholder-only and is NOT runtime-grantable; its corrections are accepted.

## 1. Pins independently recomputed

| Item | Result |
|---|---|
| Base | HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree `87798e742c7b48f56b05e9b5c30efa877180a9b3`; tracked files unmodified (`git diff --quiet HEAD`); index clean; `.git/hooks` samples only; no `node_modules` |
| v3 tree | `00b105ffe362c27808a38c44c6db1f733134f074` exists as a tree object; working tree == v3 tree for all 11 paths (`verify/v3-blobs.git-sha1` == `verify/v3-wt-blobs.git-sha1`); == `frozen-v3/BLOBS.git-sha1`; `frozen-v3/files/**` byte-equal; bootstrap mode `100755` |
| v3 vs base | 11 `A`, +2320 — recomputed `git diff-tree -p` byte-equal to `frozen-v3/b-drain.v3.diff` (`verify/recomputed.v3.diff`) |
| v3 vs v2 | 5 `M` + 4 `A`, +896/−37 — byte-equal to `frozen-v3/v2-to-v3.diff` (`verify/recomputed.v2-to-v3.diff`); `migration.sql` `55c85906` and `cli.ts` `bcc06577` unchanged |
| Packet | `PACKET.v3.sha256`, `SOURCE.sha256` (11/11), `fixture-proposal-v3/PROPOSAL.v3.sha256` all OK |
| Formatter-only | Reverse-applying `preformat/format-only.*.diff` reproduces the claimed pre-format blobs `87f193ee` (spec) and `9f1d1dfc` (db.ts); whitespace/trailing-comma-normalised token streams identical for both files (array reflow; `Set([...])` collapse) |
| S5 donors | `0e73d76d…`, `ab9aaab4…`, `85a636ba…`, `4fed8bcd…`, `b9080538…` identical at HEAD, in the v3 tree and in the working tree; full sha1s embedded in the v3 binding match |
| Adapters vs reviewed proposal | `g2-b-drain-pg-harness.ts`, `g2-b-drain-bootstrap.sh`, `g2-b-drain-db-guard.spec.ts` byte-identical to `fixture-proposal/adapter/*`; `g2-b-drain-db.ts` differs only by the Prettier `Set` collapse (6 lines) |
| Migration set | Candidate `prisma/migrations` has 168 dirs; the only dirs absent from the O root `925780e0` are exactly S1 `20261224000000_rls_close_public_exposure`, C1 `20270117000000_durable_import_setup`, E `20270118…`, B `20270119…` → `base(164)+2/+3/+4` and `appliedSince(start) === [B]` are consistent |
| Binding v3 | `b-fixture.sh` byte-identical to the reviewed fixture; `b-pg-proof.sh` diff vs proposal-v1 == provided diff (28 changed lines) |

## 2. Closure-by-closure evaluation

### F1 — structural, search_path-independent fence identity: **closed**
- `readDrainState` (`scout-ledger-backfill.ts` 238-258): plain joins `pg_trigger → pg_class/pg_namespace (public.ScoutReconstructionLedger) → pg_proc/pg_namespace (public.scout_ledger_platform_fence, pronargs 0)`, `tgname` exact, `NOT tgisinternal`, `tgenabled <> 'D'`, `tgtype = ${FENCE_TRIGGER_TYPE}::int2` (7 = ROW|BEFORE|INSERT), `tgqual IS NULL`, `tgattr::int2[] = '{}'`, `tgnargs = 0`, `tgconstraint = 0`. No `::regclass`/`::regprocedure` cast → absent table or function yields `fences = 0` → `fenced:false` → `complete_unfenced`; nothing throws before B exists. `pg_get_triggerdef` text no longer consulted. `FENCE_TRIGGER_DEFINITION` retained as documented test oracle only.
- `down.sql` 47-71: same structural predicate; keeps `to_regprocedure(...)` (NULL when absent → `NOT EXISTS` → `RAISE 'G2-B fence absent'`, no error) and `NOT prosecdef`; `'public."ScoutReconstructionLedger"'::regclass` on the table is the pre-existing v2/E-pattern prerequisite (throws only if the table itself is missing — correct fail-loud). Drops trigger then function; refusal text unchanged.
- Harness `fence()` runs `SET search_path = '';` in the same psql session before rendering (pg_catalog remains implicitly resolvable; all object refs qualified), adds `tgtype`; spec stage 3 asserts `[name,'O',FENCE_TRIGGER_TYPE,FENCE_TRIGGER_DEFINITION]`; stage 7 equality unchanged. Library ↔ down ↔ test now agree on one structural identity.
- Class C qualification (record only): library additionally requires `tgenabled <> 'D'` (effective fence), down additionally requires `NOT prosecdef` (shape to drop); a disabled trigger is reported unfenced by the library and still removed by down — both are the intended semantics.

### F2 — ACL / direct-call proof (test-only): **closed**
Stage 3 now asserts `proacl IS NOT NULL`, no `grantee = 0` (PUBLIC) EXECUTE entry via `aclexplode`, and direct `SELECT public.scout_ledger_platform_fence()` refused with `trigger functions can only be called as triggers` as `postgres` and via `SET ROLE anon|authenticated|service_role` (fixture grants those memberships to `postgres` WITH ADMIN OPTION; same `SET ROLE` idiom as the accepted etq0 spec). No product `REVOKE` widened.
Class C qualification: that message is raised by plpgsql at call time ([pl_comp.c, REL_17_STABLE](https://raw.githubusercontent.com/postgres/postgres/REL_17_STABLE/src/pl/plpgsql/src/pl_comp.c)), i.e. after the executor's EXECUTE ACL check; it is observed for the three API roles precisely because the fixture's default privileges grant them EXECUTE (the F2 premise). On a fixture without those grants the refusal would read `permission denied` instead. The B fixture is Supabase-shaped, so the assertion is truthful for its target; recorded, no change requested.

### B-1 — zero lock retries: bound **closed**, unit case **defective (FB-3)**
- Library: `bounded(value, fallback, max, min = 1)`; only `lockRetries` passes `min 0`; `for (attempt = 0; attempt <= lockRetries …)` → exactly one attempt at 0; `{ lockRetries: -1 }` still rejected. Correct.
- **FB-3 (Class B, test-only).** `scout-ledger-backfill.spec.ts` 270-277 appends the zero-retry case to the *same* `FakeLedger` after the "recovered" run. At that point both rows are already drained (`platform` set) and `transactions` is cumulative (3 + 2). Observed behaviour would be: `$transaction` throws the injected lock fault → pass `{chunks 0, lockFailures 1, stalledByLocks true}` (this part holds) → `after.nulls === 0 && fenced` → `decideOutcome` returns **`'drained'`**, not `'stalled'`; and `db.transactions` is **6**, not 1. Two of the four new expectations fail → the DB-free spec is red → phase-A `jest` gate blocked and a red test would be committed. Concrete harm: false gate/commit evidence for the retry bound; blocked decision: phase-A completion. **Minimal closure:** run the case on a fresh fenced fake with one NULL row, e.g. `const zero = new FakeLedger([row('z')]); zero.fenced = true; zero.faults = ['lock'];` and assert on `zero` (`transactions 1`, outcome `'stalled'`, same pass shape). One hunk, spec file only; nothing else in v3 changes. Execution unlocked: phase-A gate + commit.

### B-2 — S1+C1 fixture history, relative counts, exact B-only deploy: **closed**
Stage 1 applies S1 then C1 from their shipped `migration.sql` via `sqlFile` (psql `--single-transaction -f`; C1 carries BEGIN/COMMIT → nested-tx WARNING only, as for E; S1's `BEGIN` tokens are DO-block bodies; neither file contains CONCURRENTLY/ADD VALUE/VACUUM/CREATE DATABASE/EXTENSION) and records each with `prisma migrate resolve --applied` (E's existing path). `beforeAll`: `base = Number(appliedMigrations()); expect(base).toBe(164)`; none of S1/C1/E/B recorded. Stage 3: `start = SELECT now()` (server clock; Prisma writes `finished_at = now()` server-side) → `appliedSince(start)` equals `[B_MIGRATION]` exactly → `base+4`; stage 7 relative. Nothing about S1/C1 is asserted or proven. Candidate-only migration set confirmed to be exactly {S1, C1, E, B}.

### Identity adapter + donors: **closed**
Four additive files as reviewed (one Prettier collapse); spec/helper identity delta (imports, `G2_B_*` markers, `g2_b_drain_disposable`, `/pg17/clusters/b-drain/pg-data$`, `G2_B_RUNTIME_ROLE`, `G2_B_PASSWORD`) combined with closures 1–4 in the same files; five S5 donors byte-identical. Guard spec `test/scout/g2-b-drain-db-guard.spec.ts` is discovered by default jest (`roots` includes `<rootDir>/test`).

### Binding template v3: corrections **accepted**; still NOT runtime-grantable
Outer bound `timeout -k 30 3600` vs stated 2835 s soft sum (FB-2 closed); header no longer claims guaranteed cleanup (observed terminal evidence governs; no trap framework — accepted by parent); pre-step order copy → `lefthook install` → affected gates (incl. guard spec) → hooked Bradley commit → fill pins → separate PG grant (FB-1 closed); new read-only preconditions: `.git/hooks/pre-commit` and `commit-msg` present and lefthook-based (hookless commit refused), five S5 donor blobs pinned with correct full sha1s, `PROVENANCE.txt` echo. Pins `__PLACEHOLDER__`; script refuses. `b-fixture.sh` unchanged.

### Class C (record/qualify only)
| ID | Note |
|---|---|
| CV-1 | Library/down predicate asymmetry (`tgenabled` vs `prosecdef`) — intended, see F1. |
| CV-2 | Direct-call refusal message depends on EXECUTE being held (fixture default privileges) — see F2. |
| CV-3 | `${FENCE_TRIGGER_TYPE}::int2` binds a JS number as int4 then casts; valid. `installed.function.proacl` / `appliedSince` typing is `any`-derived — the phase-A `tsc` decides, no product decision depends on it. |
| CV-4 | `appliedSince` relies on `finished_at` written by Prisma server-side `now()`; same host in any case. |
| CV-5 | Prose in `V3_CLOSURE_MAP.md` §3 states "`db.transactions === 1` (exactly one attempt)" — true of the library, false of the test as written (FB-3). |

## 3. Narrowed phase-A gate (after FB-3 hunk → v4, same-review binding of that hunk)
Source/grant for env reuse and hooks (no PG): isolated copy of the accepted C1 `node_modules` into the worktree + verification against C1 records (`.package-lock.json 05bc530a…`, `.prisma/client/index.d.ts bf679a16…`) → `./node_modules/.bin/lefthook install` (record `.git/hooks/pre-commit`, `commit-msg`) → `tsc --noEmit -p tsconfig.json`; `eslint --no-warn-ignored --max-warnings 0` on the 8 TS files (`scout-ledger-backfill.ts`, `.cli.ts`, `.spec.ts`, `test/rls-g2-b-drain.spec.ts`, `test/utils/g2-b-drain-{harness,db,pg-harness}.ts`, `test/scout/g2-b-drain-db-guard.spec.ts`); `prettier --check` on the same 8; `node scripts/check-r75.js --mode=staged` with the 11 paths staged; `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts` → ordinary Bradley-authored commit through the installed hooks → pins. No `npm ci`, no candidate `prisma generate`, no old proofs.

## 4. Later pin-binding requirements (actual head, before any PG run)
Committed head/tree/spec blob/bootstrap blob/fixture sha filled into `fixture-proposal-v3/binding/b-pg-proof.sh`; head's tree must equal the v4 frozen tree; hooks receipt present; S5 donors unchanged at head; then a single `b-pg-proof.sh` run under a separate PG grant with outer `timeout -k 30 3600`; reviewer A binds `RECEIPTS.sha256`, jest summary, sentinel, survivor/listener evidence. O-client `prisma generate` inside the old root is accepted as an old-schema fixture dependency, not candidate regeneration.

## 5. Files written by this section
`B_DRAIN_V3_BINDING_REVIEW_A.md`, `verify/v3-blobs.git-sha1`, `verify/v3-wt-blobs.git-sha1`, `verify/recomputed.v3.diff`, `verify/recomputed.v2-to-v3.diff`, `MANIFEST.v3.sha256` (covers every file in this directory; original `MANIFEST.sha256` untouched).
