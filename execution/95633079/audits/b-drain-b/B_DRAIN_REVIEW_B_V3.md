# S7-3′ G2 B/drain — reviewer B, same-review binding of the frozen v3 changed lines

Read-only; no install/copy/hooks/lock/test/PG/probe/commit/index writes. Peer-A unread. Only the lines
changed v2→v3 and the four adapter files were read; unchanged v2 lines keep their frozen disposition
(`B_DRAIN_REVIEW_B_SOURCE.md`). Prior outputs untouched.

## 1. Identity (independently re-derived)

| Item | Check | Result |
|---|---|---|
| Base | worktree HEAD `a0ea1bea…`, tree `87798e74…`, real index clean, 11 untracked, no hooks (`.git/hooks` samples only), no `node_modules` | as stated |
| v3 tree `00b105ffe362c27808a38c44c6db1f733134f074` | exists as tree object; `git diff --shortstat` vs base: 11 files, +2320; vs v2 `3739193a`: 9 files, +896/−37 | matches |
| Blob pins | `git ls-tree -r 00b105ff` for the 11 paths == `frozen-v3/BLOBS.git-sha1`; `git hash-object` of every working-tree file == pinned blob; bootstrap mode `100755` | all match |
| sha256 | `SOURCE.sha256` OK against worktree and against `frozen-v3/files/`; `PACKET.v3.sha256` all OK; `fixture-proposal-v3/PROPOSAL.v3.sha256` all OK | all OK |
| Diff artefact | `sha256(git diff 3739193a 00b105ff)` == `sha256(frozen-v3/v2-to-v3.diff)` = `557b5b1f…0619` | identical |
| `migration.sql`, `cli.ts` | blobs `55c85906`, `bcc06577` unchanged from v2 | unchanged |
| Five S5 donors at HEAD | `git ls-files -s` == `S5_DONORS_UNCHANGED.git-sha1` (db `0e73d76d`, harness `ab9aaab4`, bootstrap `85a636ba`, guard `4fed8bcd`, old-root `b9080538`) | unchanged |
| Adapter bytes vs reviewed proposal | pg-harness, bootstrap, guard spec byte-identical; `g2-b-drain-db.ts` differs only by Prettier collapsing the 5-line `Set([...])` literal | as stated |
| v3 binding runner vs reviewed v1 | own `diff`: header (no cleanup guarantee, soft-sum 2835 s, outer `timeout -k 30 3600`, pre-step order copy→hooks→gates→hooked commit→pins→PG grant), `D=` path, lefthook `pre-commit`/`commit-msg` presence precondition, five S5 donor blob pins at HEAD, `PROVENANCE.txt` lines echoed into the receipt; `b-fixture.sh` byte-identical | as stated; pins still `__PLACEHOLDER__` → refuses to run |

## 2. Changed-property evaluation

### F1 — search_path-independent effective fence (product: `scout-ledger-backfill.ts`, `down.sql`; proof: helper `fence()`, spec stage 3/7) — **SOUND**
- `readDrainState`: plain joins `pg_trigger→pg_class→pg_namespace('public','ScoutReconstructionLedger')` and
  `pg_trigger.tgfoid→pg_proc→pg_namespace('public','scout_ledger_platform_fence', pronargs=0)`; `tgname` exact;
  `NOT tgisinternal`; `tgenabled <> 'D'`; `tgtype = 7` (ROW 1 | BEFORE 2 | INSERT 4 — correct bit values; AFTER/INSTEAD
  and statement-level shapes excluded); `tgqual IS NULL` (no WHEN); `tgattr::int2[] = '{}'` (no column list);
  `tgnargs = 0`; `tgconstraint = 0`. No `::regclass`/`regprocedure` cast → an absent table/function/trigger yields
  `fences = 0` → `fenced:false` → `complete_unfenced` (absent→false preserved, nothing throws pre-B). Trigger names
  are unique per table so `fences === 1` is the only positive value. `${FENCE_TRIGGER_TYPE}::int2` is a bound
  parameter with explicit cast — fine for Prisma raw. No dependency on `search_path` remains in the detector.
- `down.sql`: same structural predicate; keeps `to_regprocedure('public.scout_ledger_platform_fence()')`
  (schema-qualified → path-independent; NULL when absent, so a genuinely absent fence reaches `RAISE 'G2-B fence
  absent'` rather than erroring) and `NOT prosecdef`; drops the `pg_get_triggerdef` text compare; deliberately does
  not require `tgenabled` (a disabled fence is still B's object and is correctly removable by down). Drops trigger
  then function only; `migration.sql` up-guard never used the text compare (existence checks only) — unchanged.
  Migration-dry-run down/up parity unaffected.
- Proof alignment: `fence()` now sends `SET search_path = '';` then the SELECT through the same psql stdin session
  (`-qAt` suppresses the `SET` tag, so `JSON.parse` still sees one row); every object reference in that SELECT is
  either schema-qualified (`public."ScoutReconstructionLedger"`, `to_regprocedure('public.…()')`) or in `pg_catalog`
  (implicitly searched even with an empty path). Stage 3 asserts the tuple
  `[name,'O',FENCE_TRIGGER_TYPE,FENCE_TRIGGER_DEFINITION]` — canonical fully qualified text is what PG renders under
  an empty path (`EXECUTE FUNCTION public.scout_ledger_platform_fence()`), so the oracle is now stable. DB-free fake
  still dispatches on `pg_trigger` and no earlier branch (`FILTER (WHERE source_platform IS NULL)`, `AS mismatch`,
  candidates) matches the new query text.

### F2 — test-only ACL correction (spec stage 3) — **SOUND**
- `proacl IS NOT NULL` (explicit ACL after `REVOKE … FROM PUBLIC`), `aclexplode` shows no `grantee = 0` EXECUTE
  entry, and a direct `SELECT public.scout_ledger_platform_fence()` is refused with `trigger functions can only be
  called as triggers` as `postgres`, `anon`, `authenticated`, `service_role`. `SET ROLE` from the migration role is
  valid: bootstrap grants `anon, authenticated, service_role TO postgres WITH ADMIN OPTION`. Honest note recorded
  in the spec comment: the API roles may hold EXECUTE through the fixture's `ALTER DEFAULT PRIVILEGES` (as on
  Supabase); B does not widen any REVOKE. The direct-call refusal is a parse-time error (independent of ACL), so the
  assertion proves non-callability, not privilege — which is exactly what the comment claims.

### B-1 — zero lock retries — **library SOUND; new unit assertion DEFECTIVE (B-4 below)**
- `bounded(value, fallback, max, min = 1)`; only `lockRetries` passes `0`; batch/passes minimum unchanged; message
  `(${min}..${max})`; `-1` still rejected. Live spec's three `lockRetries: 0` sites are now legal.

### B-2 — honest fixture history / relative counts / exactly-B deploy (helper + spec) — **SOUND**
- `beforeAll`: `base = Number(appliedMigrations())`, `expect(base).toBe(164)` (O-root fixture identity, as the
  bootstrap pins); none of S1/C1/E/B recorded. Stage 1: after O rows on the narrow shape, S1 then C1 (chronological,
  the order `migrate deploy` would use) are applied from their shipped `migration.sql` via `sqlFile` and recorded with
  `prisma migrate resolve --applied` — the identical path E takes next; `base+2`, column still absent; E → `base+3`.
  Nothing is marked applied without its SQL. S1 closes 14 unrelated relations and requires the three API roles
  (present via the shim); C1 creates `ImportIntent`/alters `ExtensionPairCode`; neither touches the four scout
  tables, so O/T behaviour and `catalog()` are unaffected. If S1's SQL cannot apply on the shim fixture, that is a
  fixture-shape fact the run will record, not a B defect.
- Stage 3: `start = SELECT now()` (server clock) taken after `beforeCatalog`; `appliedSince(start) === [B]` (Prisma
  writes `finished_at` with the server clock; the stage-1 `resolve` timestamps precede `start`), `base+4`; rerun,
  stage 7 use `base+4`. Output still asserted to contain B and not E.

### Identity adapter — **SOUND** (literal-only derivation confirmed earlier; v3 bytes verified above); spec/helper
identity delta identical in content to the reviewed 21-line delta, composed with the closures in the same files.

### Binding — **order and bound correct**; pins placeholders → not runtime-grantable (its own status).

## 3. Findings on v3

### B-4 — new DB-free zero-retry assertion is deterministically wrong (blocks Phase A and CI `npm test`)
- **Evidence.** `src/scout/scout-ledger-backfill.spec.ts:270-277` reuses the `db` fake from the preceding two runs in
  the same `it`. After the "recovered" run both rows carry a platform (`nulls = 0`) and `db.fenced = true`;
  `backfillLedgerPlatform` always runs at least one chunk, the single attempt faults (`lockFailures: 1`,
  `stalledByLocks: true` — that part holds), but `decideOutcome(0, true, …)` returns **`'drained'`**, not the
  asserted `'stalled'`. `FakeLedger.transactions` is cumulative (3 + 3 + 1 = 7 by then), so
  `expect(db.transactions).toBe(1)` also fails. The `jest.config.js` root `src/scout` discovers this spec, so the
  failure hits the Phase-A gate and the ordinary CI build-and-test lane.
- **Class.** B — proof/gate defect only; library change is correct. No product harm.
- **Minimum closure (test-only, ~4 lines).** Use a fresh fake for the zero-retry case:
  `const zero = new FakeLedger([row('a')]); zero.fenced = true; zero.faults = ['lock'];` then
  `backfillLedgerPlatform(zero, { batch: 500, lockRetries: 0 })` → passes `[{chunks:0, lockFailures:1,
  stalledByLocks:true}]`, `outcome 'stalled'` (one NULL row remains, unexplained), `zero.transactions === 1`.
- **Affected path/proof.** `src/scout/scout-ledger-backfill.spec.ts` only → new blob, new tree, new pins.
- **Execution unlocked.** Phase-A DB-free gate; no other stage depends on it.

### C (record only; no further fix/control/test alone)
- C-8 `down.sql` structural predicate omits `tgenabled` by design (down removes a disabled fence too); library
  `fenced` requires enabled — intentional asymmetry, documented in both comments.
- C-9 `fence()` mutates the psql session's `search_path` — the session is per-call (`execFileSync`), so nothing
  leaks; `sqlFile`/`catalog()` are unaffected.
- C-10 Runner `for pin … do set -- $pin` reassigns the script's positional parameters; the script uses none, so
  harmless.
- C-11 `tsc` observations for Phase A (not defects): `installed.function.proacl` is `any` via `json()`;
  `appliedSince` returns `any` typed as `string[]`; `FENCE_TRIGGER_TYPE` interpolation in a tagged template.

## 4. Disposition

- Product changed lines (`down.sql` `91e646dd`, `scout-ledger-backfill.ts` `957fb8c6`): **SOURCE_GRANTABLE**;
  together with the unchanged `migration.sql` `55c85906` and `cli.ts` `bcc06577` the v3 product set is grantable.
- Proof/adapter changed lines: **SOURCE_GRANTABLE except B-4**; live spec `9b31fd18`, helper `469cbd2a`, four
  adapter blobs accepted as reviewed; `scout-ledger-backfill.spec.ts` `3a97093a` **BLOCKED** until the B-4 fresh-fake
  fix (test-only) — same review, changed lines only, new blob/tree/pins afterwards.
- **No A findings.** v3 tree `00b105ff` therefore cannot be the pinned head; the next candidate differs from it by
  one test file.

## 5. Narrowed Phase-A gate and pin-binding requirements (after B-4)

1. Isolated copy of the accepted C1 `node_modules` into the worktree; verify `.package-lock.json` `05bc530a…` and
   `.prisma/client/index.d.ts` `bf679a16…`; no `npm ci`, no candidate `prisma generate`.
2. `./node_modules/.bin/lefthook install` (standalone repo → only its `.git/hooks`); confirm `pre-commit`/`commit-msg`
   reference lefthook.
3. Gates from that tree only: `tsc --noEmit`; `eslint --max-warnings 0` + `prettier --check` on the 7 new/changed TS
   files; `node scripts/check-r75.js` (covers the new `.sh` under `test/`); `jest src/scout/scout-ledger-backfill.spec.ts
   test/scout/g2-b-drain-db-guard.spec.ts` (DB-free; the B guard spec reads `test/utils/g2-b-drain-bootstrap.sh`).
4. One ordinary Bradley-authored commit with the hooks executing (message per handoff §7, no trailers).
5. Fill `EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/EXPECT_FIXTURE_SHA` from the committed head; record the five S5
   donor blobs (already constant in the runner) and the `PROVENANCE.txt` lines. Then, under a separate PG grant,
   exactly one `timeout -k 30 3600 bash fixture-proposal-v3/binding/b-pg-proof.sh`; S5 ABSENT, C1 cluster stopped and
   hash-guarded; the O-client generate inside `runtime/old-root` is the only generate.
Reviewer B remains available for the B-4 one-file delta and for the actual head/results; not a new audit track.
