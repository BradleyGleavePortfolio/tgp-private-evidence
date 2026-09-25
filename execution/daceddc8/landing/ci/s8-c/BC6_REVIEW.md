# BC-6 changed-question review — `test/scout/g2-s8c-db-guard.spec.ts` composition tolerance (reviewer A)

Reviewer: independent nonbuilder T4 reviewer A (REV-BC6). Read-only; this file is the only output. Method: `git` on `/home/user/workspace/worktrees/daceddc8-land-s8-c` (branch `land/s8-c`), `sha256sum -c`, `cmp`, `rg`; receipts in `daceddc8/landing/ci/s8-c/{CI_RED.md,BC6_RECEIPT.md,bc6/**,build-and-test-108184866662.log}`. No lock, gate, test, PG, push or git write; evidence repo not committed.

VERDICT: GO 1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47

## Identity (recomputed)

- HEAD `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`, tree `aa160557577f821b6f284435d22037e046991202`, sole parent `2542af44ab5b4d296f84e9f5f311632f7f5aeb25` (merge of S7-L `df713fd9` + S8-C `f428db9a`); porcelain (incl. untracked) 0.
- `git diff-tree 2542af44 1c10e2a1`: exactly `test/scout/g2-s8c-db-guard.spec.ts`, +15/−8, blob `4a0c083a…` → `c3fc6bded0906fb27fd5cab49dc51fb17825db04`. `bc6/run/delta-from-2542af44.1file.patch` byte-equals `git diff 2542af44 1c10e2a1` (sha `1119156b…`). `bc6/run/RECEIPTS.sha256` verifies.

## (a) Only the directory-scan assertions changed — YES

The single hunk (former L148–L156) replaces the `readdirSync → toHaveLength(171) / toContain(S8B) / filter(> S8B) == []` block and its comment. The 8 removed lines contain no constant, no `toContain(\`…\`)` pin line, no import. `BASE_HEAD = '93389265…'`, `EXPECTED_MIGRATIONS = 171`, `S8B_MIGRATION = '20270122000000_scout_native_provenance_expand'` (L134–136), the bootstrap `toContain` pins for `BASE_HEAD=`, `EXPECTED_MIGRATIONS=`, `S8B_MIGRATION=`, `G2_S8C_CANDIDATE_HEAD`, the harness `export const …` pins (L139–147), the fixture-marker test (L85–99), the candidate-head test and every other `it` are byte-unchanged (all other diff lines are context).

## (b) Still proves the proof base's 171 migrations present, in order, ending at S8-B — YES (same strength as before)

New logic: names sorted; `baseMigrations = first 171`; `toHaveLength(171)`; `baseMigrations[170] === S8B_MIGRATION`; no base name `> S8B_MIGRATION`. Because directory names are unique and sorted, this is equivalent to: exactly 170 directories sort below S8-B, S8-B is present, and everything else sorts strictly above it. The old block asserted exactly 171 directories total, S8-B present, none above it — i.e. the identical property on the base range. Neither form asserts the *identity* of the 170 earlier names (see C-1); the delta neither adds nor removes that. Real-tree check: base tree `93389265:prisma/migrations` has 171 directories; the composed tree `1c10e2a1` has 172; set difference is exactly `20270123000000_scout_run_lifecycle_expand` (S7-L), and the sorted 171st name at `1c10e2a1` is the S8-B migration. `readdirSync` with `isDirectory()` still excludes `migration_lock.toml`, `_supabase_bootstrap.sql`, `rls_fitness_backend.sql`, `gym_distribution_scaffold.md`.

## (c) Later migrations admitted only if well-formed; no other guard weakened — YES

Each later name must be `> S8B_MIGRATION` (14-digit timestamp prefix makes the string order the timestamp order), match `^\d{14}_[a-z0-9_]+$` (every existing directory matches), and contain `migration.sql` (S7-L's has `migration.sql` + `down.sql`). Nothing else in the file, in `test/utils/g2-s8c-bootstrap.sh` or `test/utils/g2-s8c-pg-harness.ts` changed (tree delta is one path); those files reference the guard only in comments. Constants and pins unchanged (see (a)).

## (d) Genuine hook, Bradley identity, no trailers — YES

`git cat-file -p 1c10e2a1`: author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, same timestamp; body has no `Key: value` trailer lines. `bc6/run/commit.raw.log`: lefthook pre-commit prod-readiness-quick ✔, banned-cast-tokens ✔, prettier ✔, eslint ✔, tsc ✔ (47.5 s); commit-msg no-ai-tokens ✔; `[land/s8-c 1c10e2a1] … 1 file changed, 15 insertions(+), 8 deletions(-)`. Gate log: slot inode 674373 acquired 17:59:02Z, released 18:01:05Z, one launch, no retry; head/tree/blob/porcelain lines match my recomputation. Not pushed (receipt: remote `land/s8-c` still `2542af44`).

## (e) Any other spec CI's full `npm test` would still fail on — NONE expected

- CI on `2542af44` (`build-and-test-108184866662.log` L2853–2854): `Test Suites: 1 failed, 12 skipped, 571 passed, 572 of 584`; `Tests: 1 failed … 8948 passed`; the sole `●` failure is this guard case. Lint, tsc, build passed; other checks green.
- The delta is one test file no other module imports (`rg g2-s8c-db-guard` finds only comments in the two S8-C utils). So the only suite whose result can change is this one: `bc6/run/jest-guard-spec.log` PASS 50/50 under the default `jest.config.js`.
- L2-2 sweep: 17 suites / 366 tests passed, 10 env-conditional skips (`jest-sweep.log`, `jest-sweep.suites.txt`). I re-enumerated default-config specs referencing `prisma/migrations`, the `'prisma','migrations'` join, `EXPECTED_MIGRATIONS`, `BASE_HEAD` or `docs/contracts` (excluding `test/rls*`, ignored by the default config): my set is a strict subset of `bc6/sweep-suites.txt`, so the sweep covered every reader I can find.

## Findings (Safety-ROI form)

- **C-1 (note):** the guard asserts cardinality and ordering bound (170 names below S8-B, S8-B at position 171), not the identity of the 170 earlier directories — exactly as before the delta. Harm: none introduced; a substituted earlier-named directory was never caught by this guard. Decision blocked: none. Closure: none required for BC-6.
- **C-2 (note):** the commit message's "the first 171 are the proof base's set" overstates C-1 slightly (the code checks count + last element). No harm; documentary.
- **C-3 (note):** the S8-C PG proof bootstrap/harness (`EXPECTED_MIGRATIONS=171` on the lane) remain pinned to the lane head `f428db9a` via binding v5 (`EXPECT_HEAD`), and `test/rls*` is outside the default CI config; running that proof against the composed head would refuse on head pin before any 172-migration mismatch. Consistent by design; not a CI matter and not changed here.
- **C-4 (note):** `later > S8B_MIGRATION` compares whole names, so a directory sharing S8-B's exact timestamp with a lexicographically later suffix would be accepted as "later"; Prisma orders identically, and no such directory exists. No harm.
- No A or B findings.

## Verdict

**GO** — fast-forward `land/s8-c` `2542af44 → 1c10e2a1` (no force) is safe from this review's standpoint: one test-only path, scan-assertion change only, base-range property preserved at identical strength, later migrations constrained to well-formed timestamped directories with `migration.sql`, constants/pins untouched, genuine hooked Bradley commit without trailers, and no remaining CI failure predicted (single prior red suite now 50/50; nothing else depends on the file).

VERDICT: GO 1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
