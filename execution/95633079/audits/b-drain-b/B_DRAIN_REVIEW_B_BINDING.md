# S7-3′ G2 B/drain — reviewer B, additive section: B-only fixture / identity adapter / execution binding proposal

Same review, same reviewer, read-only. Inspected AFTER the v2 product-source disposition in
`B_DRAIN_REVIEW_B_SOURCE.md` was frozen. Input: `execution/95633079/s7-b-drain/fixture-proposal/**`,
`PROPOSAL.sha256` (16 entries, all `OK` by `sha256sum -c`), proposal document sha256
`5f3182e3…a280a`. Peer-A not opened. Nothing executed against PG, no install, no copy, no hook, no commit.

## 1. Independent verification of the proposal's claims

| Claim | Independent check | Result |
|---|---|---|
| Donors unchanged | `DONORS.sha256` vs my `sha256sum`/`git rev-parse HEAD:<path>`: db.ts `0e73d76d`, harness `ab9aaab4`, bootstrap `85a636ba`, guard spec `4fed8bcd`; S5 fixture `3a7d57bf`, C1 runner `50506175` | match; the four S5 files stay byte-identical in the worktree |
| `g2-b-drain-db.ts` literal-only | own diff with identity literals normalised | residue = `REFUSED_PORTS` + `54325`, four error-string lane names. Function body identical. `54325` is S5's real port (`c1-pg/donor/s5-fixture.sh:21`), so the added refusal is correct |
| `g2-b-drain-pg-harness.ts` literal-only | same | residue = one error string. Logic identical |
| `g2-b-drain-db-guard.spec.ts` | same | port/ack literals, adds refusal of S5 db name and S5 port, marker regex `^b-`; reads `../utils/g2-b-drain-bootstrap.sh` and requires `CLUSTER_MARKER=`/`DB_MARKER=` verbatim (mirrors S5 rule). Lives under `test/` → default `jest.config.js` root `<rootDir>/test` discovers it (DB-free, good) |
| `g2-b-drain-bootstrap.sh` literal-only except step 7 | same | confirmed: only substantive change is step 7 — `prisma generate` for the candidate removed, replaced by presence + `ScoutReconstructionLedger` + engine sha + runtime realpath + `source_platform` verification of the already-generated client; `node_modules` missing message now names the isolated C1 copy. Step 6 (O client generate inside the old root, resolving `@prisma/client` to the pinned tree) kept unchanged |
| `b-fixture.sh` vs S5 donor | same | literal-only plus: log path `clusters/b-drain/pg.log`, `mkdir -p $(dirname $DATA)`, runner-guard token `b-pg-proof.sh`. scram + pwfile, marker-guarded start/destroy, bounded stop with survivor report unchanged |
| v2→v3 identity diff = 21 lines / 2 files | own `diff` v2 worktree file vs `spec-v3-candidate/**`: 12 + 9 changed lines | matches the shipped diff; only import paths, `G2_PG17_*`→`G2_B_*`, db literal, directory regex, runtime role/password env |
| Identity values unique | `55461` appears nowhere else under `execution/` or the worktree; not in any refused set (`5432/5433/6543/54321/54322/55439/54325`); data dir, cluster marker, db name, comment and confirm token are consistent across db.ts, bootstrap, guard spec, fixture and runner; `G2_B_DATABASE_URL` uses only `schema=public&connection_limit=4` (both allowed by the guard's option whitelist) | consistent |
| Worktree is its own repository | `git rev-parse --git-common-dir` = `.git` (not a linked worktree); `.git/hooks` contains samples only | `lefthook install` will affect this repo only |
| Shared `node_modules` for the O root is legitimate | `git diff --stat 925780e0 HEAD -- package.json package-lock.json` empty | bootstrap step-4 manifest check will pass |

## 2. Answers to the proposal's four questions

1. **Additive derivation vs parameterising S5 files — CONFIRMED as the minimum.** The accepted S5 guard
   spec pins the S5 literals and the guard deliberately has no injection point; parameterising would
   modify accepted bytes and weaken the "no operator variable can re-point a destructive step" property
   for S5. Four B-named siblings with the same function bodies keep both guards fail-closed.
2. **Diffs-vs-donor — CONFIRMED literal-only** with the single substantive step-7 change (candidate
   `generate` → verification), which is exactly the "no candidate generate by default" rule. The O-client
   `generate` (step 6) is a genuine fixture dependency: no O client exists anywhere in the sandbox and the
   O binary cannot run against the E/T client (which knows `source_platform`). It writes only inside
   `runtime/old-root/.g2-b-old-client`. Parent decision, but I see no cheaper honest alternative.
3. **"The 21-line identity delta is the entire product change needed for binding" — NOT CONFIRMED.** The
   v3 candidate spec still contains both v2 proof defects from my source report:
   - **B-1**: `spec-v3-candidate/test/rls-g2-b-drain.spec.ts:461, 493, 514` still pass `lockRetries: 0`,
     which `bounded()` rejects (`RangeError`) → stage 6 cannot run.
   - **B-2**: lines `131/185/245/272/553/565` still assert `'164'/'165'/'166'`, and bootstrap step 5
     still deploys the O root's 164 dirs, while this candidate root tracks S1 (`20261224…`) and C1
     (`20270117…`) in addition to E; stage-3 `prismaMigrateDeploy(root)` therefore applies S1 + C1 + B
     (168) or fails inside S1/C1 — `'166'`, "exactly B" and `not.toContain(E)` cannot all hold.
   So v3 = identity delta **+ B-1 closure + B-2 closure**. Both stay test/fixture-scoped except the
   recommended 2–3-line library fix for B-1.
4. **Identity table and binding order/bounds — CONFIRMED with corrections (below).** S5-ABSENT hard
   requirement and retained-C1 hash guard are appropriate and currently satisfiable (`/home/user/pg17/clusters/`
   holds only `c1-builder`, stopped, 0 postgres processes).

## 3. Concrete minimum closures for the binding (same review; no new audit track)

- **BIND-1 (order — parent already caught; recorded as the binding rule).** Pre-steps must run in this
  order, each with its own receipt: (a) isolated dependency copy `cp -a worktrees/s7-c1/node_modules →
  worktrees/s7-b-drain/node_modules` and verify `.package-lock.json` `05bc530a…` and
  `.prisma/client/index.d.ts` `bf679a16…` (already pinned in the runner); (b) `./node_modules/.bin/lefthook
  install` from that copy so the tracked `lefthook.yml` hooks are genuinely present in `.git/hooks` of this
  standalone repo; (c) gates from the same tree: `tsc --noEmit`, `eslint --max-warnings 0` and `prettier
  --check` on the six TS files (five v2 + guard spec; Prettier glob excludes `.sh`), `node scripts/check-r75.js`
  (covers the new `.sh` under `test/`), `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts`;
  (d) one ordinary Bradley-authored commit with the hooks executing; (e) fill `EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB`
  and `EXPECT_FIXTURE_SHA` from the committed head; (f) run. §5 of the proposal lists (d) before (a); that
  order is not executable (no hooks, no `tsc`, no `jest` without the tree) and must be rewritten.
- **BIND-2 (B-2 closure inside the fixture or spec).** Either add bootstrap step 5b — after the 164 O
  migrations, apply `prisma/migrations/20261224000000_rls_close_public_exposure/migration.sql` and
  `20270117000000_durable_import_setup/migration.sql` from the candidate root as the migration role and
  `prisma migrate resolve --applied` each (the same path stage 1 uses for E), asserting `166` before
  `G2_B_BOOTSTRAP_OK` — or do the same in spec stage 1. Then the spec asserts `base = appliedMigrations()`
  in `beforeAll`, `base+1` after E, `base+2` after B, and "exactly B" as the set of `migration_name`
  with `finished_at` after the stage-3 start. Neither S1 nor C1 touches the four scout tables (S1
  mentions E only in a comment; C1 creates `ImportIntent` and alters `ExtensionPairCode`), so `catalog()`
  parity is unaffected. If S1's SQL cannot apply on the Supabase-shim fixture, that is a fixture-shape
  fact to record, not a B defect. Marking S1/C1 applied without running their SQL would also unblock the
  count but is less honest; I do not recommend it.
- **BIND-3 (B-1 closure).** Library fix in `src/scout/scout-ledger-backfill.ts` (`bounded(value,
  fallback, max, min = 1)`, `min 0` for `lockRetries`) plus one DB-free assertion; or spec-only
  `lockRetries: 1` ×3 with 6d `lockFailures: 2`. Must land in v3 before pins are taken.
- **BIND-4 (runner hygiene, small).** `b-pg-proof.sh` compares `EXPECT_POSTGRES_SHA/INITDB_SHA` against
  constants copied from S1/S2 provenance — at pin-fill time also record the current
  `/home/user/pg17/PROVENANCE.txt` line so the receipt is self-contained. The runner passes `--ci` (fine);
  worst-case jest bound `1500 s` vs 26 tests × `240 s` per-test ceiling is not a hard cover — acceptable
  because the first timeout fails the run; note it in the receipt rather than raising the bound.
- **BIND-5 (record, no action).** Bootstrap step 4 creates `old-root/node_modules → $ROOT/node_modules`
  symlink and step 6 writes the O client inside `runtime/old-root/` — both outside the candidate worktree;
  `git clone` (local, hard-linked objects) of the standalone repo is read-only for the source repo and
  leaves an `origin` pointing at the local path inside the old root (harmless, no remote fetch, `GIT_NO_LAZY_FETCH=1`).
  The runner's "worktree clean incl. untracked" pre/post check is compatible because `node_modules/` is
  gitignored and jest writes no files into the worktree. Data dir is retained after the run; `destroy` is
  marker-guarded and needs its own grant.

## 4. Binding verdict

Proposal shape: **ACCEPTABLE-MINIMUM as an identity/execution design; NOT EXECUTABLE/GRANTABLE yet**
(its own status). Blocking before pins: BIND-1 order rewrite, BIND-2 (B-2), BIND-3 (B-1). Everything else
is literal-derivation confirmed. Final candidate/pins still require the exact same-review binding
(committed v3 head + tree + spec/bootstrap blobs + fixture sha) before any PG run; the v2 tree
`3739193a…` stays the frozen product reference and its four product files are unaffected by v3 unless
BIND-3 takes the library route (then `scout-ledger-backfill.ts` changes by ≤3 lines and gets re-gated).
