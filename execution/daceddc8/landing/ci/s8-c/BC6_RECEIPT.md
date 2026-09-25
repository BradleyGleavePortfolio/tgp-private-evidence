# S8C-BC-6 receipt — LAND-2 CI red (L2-1, class B) closure option (a)

Executor `s8c_bootstrap_completion` (T4). Grant: `daceddc8/SCOPE.md` §"LAND-2 CI red (L2-1): parent disposition (18:05Z)".
Worktree `/home/user/workspace/worktrees/daceddc8-land-s8-c`, local branch `land/s8-c`. **Not pushed** (remote `land/s8-c`
still `2542af44`, ls-remote 18:01Z). Evidence repo not committed by the executor.

## Commit
| item | value |
|---|---|
| **HEAD** | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` |
| parent | `2542af44ab5b4d296f84e9f5f311632f7f5aeb25` (LAND-2 composition of S7-L `df713fd9` + S8-C `f428db9a`) |
| **tree** | `aa160557577f821b6f284435d22037e046991202` |
| changed path (only) | `test/scout/g2-s8c-db-guard.spec.ts` — blob `c3fc6bded0906fb27fd5cab49dc51fb17825db04` (+15/−8) |
| delta patch | `bc6/run/delta-from-2542af44.1file.patch` sha256 `1119156b81016519010fe0827876207fea4402c47e534da8209fbef2442322bd` |
| author / committer | Bradley Gleave `<bradley@bradleytgpcoaching.com>` / same; no trailers |
| subject | `test(scout): make the S8-C migration-directory guard composition-tolerant` (`bc6/commit-message.txt`) |
| hooks (genuine lefthook v2.1.9, `bc6/run/commit.raw.log`) | pre-commit: prod-readiness-quick ✔ 0.05 s, banned-cast-tokens ✔ 0.31 s, prettier ✔ 1.64 s, eslint ✔ 2.26 s, tsc ✔ 47.49 s; commit-msg: no-ai-tokens ✔ |
| porcelain after | 0 |

## Change (directory-scan assertions only; former L148–L156)
Before: `readdirSync(prisma/migrations)` directories → `toHaveLength(171)`, `toContain(S8B)`, `filter(> S8B) == []`.
After: the directory names are **sorted**; `baseMigrations = first 171` must have length 171, its last element must be
`S8B_MIGRATION` (`20270122000000_scout_native_provenance_expand`), and none of the 171 may be later than S8-B (so the
proof base's 171 are present, in order, up to and ending at S8-B); every later directory must be strictly later than S8-B,
match `^\d{14}_[a-z0-9_]+$`, and contain `migration.sql` (permits landed lanes' later migrations, e.g. S7-L's
`20270123000000_scout_run_lifecycle_expand`). Comment updated accordingly. `BASE_HEAD`, `EXPECTED_MIGRATIONS`,
`S8B_MIGRATION` constants, the bootstrap/harness `toContain` pins and every other assertion in the file are byte-unchanged
(the gate asserts the pin lines are present and that ≤ 9 lines were removed). Cross-check outside the spec: the base tree
`93389265:prisma/migrations` has 171 directories, the composed tree 172, difference exactly
`20270123000000_scout_run_lifecycle_expand`.

## Pre-commit checks (scoped, offline)
prettier 3.9.9 from prefix `recovery-reset/s8c/tools/prettier-3.9.9` (`npx --no-install`, `npm_config_offline=true`):
`--check` rc=0. eslint `--no-warn-ignored --max-warnings 0` on the file: rc=0 (empty output). Heap 4096 throughout.

## Slot
`flock -n` on `/home/user/workspace/execution/test-validation.lock` (inode 674373), fd 9, pid 16228: **ACQUIRED
17:59:02Z → RELEASED 18:01:05Z** (held through commit and both Jest runs; 0 holders / 0 postgres before and after).
One gate launch (`bc6/s8c-bc6-gate.sh`, relay-flag + once-only guarded); no refusal, no retry.

## Tests (default `jest.config.js`, `--ci --runTestsByPath`, still under the slot)
1. Corrected spec alone (17:59:53–18:00:04Z): `test/scout/g2-s8c-db-guard.spec.ts` **50 passed / 50**, including
   "pins the base head and migration count identically across bootstrap, harness and repository" ✓ (`run/jest-guard-spec.log`).
2. L2-2 sweep (18:00:04–18:01:05Z) — every default-config spec that reads `prisma/migrations`, `docs/contracts` or
   `BASE_HEAD`/`EXPECTED_MIGRATIONS` pins, enumerated by `rg` over `test/` + the config's `src/` roots (literal strings, the
   `'prisma','migrations'` join form, and `readdirSync/readFileSync` + `migrations`), excluding the `test/rls*` paths the
   default config ignores → 17 suites (`bc6/sweep-suites.txt`):
   **Test Suites: 17 passed / 17; Tests: 366 passed, 10 skipped, 376 total; rc=0** (`run/jest-sweep.log`, per-suite
   PASS list `run/jest-sweep.suites.txt`). The 10 skips are the suites' own env-conditional skips
   (`scout-entities.rls.live.spec.ts` `describe.skip` without a live DB URL; `deploy-readiness.spec.ts` strict-gate
   `it.skip`), identical in kind to CI's default run.

## Files
`landing/ci/s8-c/bc6/`: `s8c-bc6-gate.sh`, `commit-message.txt`, `sweep-suites.txt`, `run/{s8c-bc6-gate.log,
delta-from-2542af44.1file.patch, prettier-check.log, eslint.log, commit.raw.log, jest-guard-spec.log, jest-sweep.log,
jest-sweep.suites.txt, gate.stdout, gate.stderr, RECEIPTS.sha256}`.

## Next (not mine)
REV changed-question review of the one-file delta; LAND-2 pushes `land/s8-c` fast-forward `2542af44 → 1c10e2a1`
(no force) after GO; CI green; then FF of `integration/importer`.
