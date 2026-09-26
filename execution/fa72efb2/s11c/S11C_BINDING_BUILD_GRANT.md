# S11-C real-PG proof binding build grant (EXEC-FA72EFB2)

Grade T3 (proof-bearing runner derived by substitution from an accepted runner). Requested route: Claude Opus 5.5.
Source only: do NOT run the runner, PG, bootstrap or jest; do not take the lock.

Template (accepted; ran RC=0 at 15:27:54Z): execution/fa72efb2/s11a1/binding/v3/{s11-pg-proof.sh, s11-fixture.sh,
FREEZE-v3.sha256}. Derive execution/fa72efb2/s11c/binding/v1/{s11c-pg-proof.sh, s11-fixture.sh (byte copy; the runner
pins its sha — the fixture's runner-cmdline check greps `s11-pg-proof.sh`, so either keep the runner filename
`s11-pg-proof.sh` in the new dir or change that one fixture literal; prefer keeping the filename), FREEZE-s11c.sha256,
DELTA-from-s11a1-v3.diff, README.md, BINDING.sha256} with the MINIMUM changes:
- D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11c/binding/v1; SRC=/home/user/workspace/worktrees/fa72-s11c
  (HEAD 7fdcbc04, clean, lefthook hooks, origin/land/s11c = 7fdcbc04 fetched from GitHub);
  W=/home/user/workspace/worktrees/fa72-s11c-pg1. Donor node_modules unchanged (fa72-s11a1/node_modules, same pins).
- BASE_HEAD=3db615c0a5e64a63b910d34ce7c732ee6e63f24d (tree 6ea6852ca16253f7e5b269aa9a1cdfb69bac2ddb; = integration/importer
  after S11-A1 landed); EXPECT_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752 (tree a802231ee1f4dd693284b349e7eb078b3688e8d5);
  LAND_REF=refs/remotes/origin/land/s11c. HARNESS_BASE ancestry and "no prisma/package/test-utils change" checks as template.
- EXPECT_DELTA = the 7 S11-C paths (sorted): docs/contracts/importer-openapi.json src/extension-pair/__tests__/readiness.spec.ts
  src/extension-pair/extension-pair.dto.ts src/extension-pair/extension-pair.service.ts test/contracts/importer-contract.spec.ts
  test/rls-c1-setup.spec.ts test/scout/s11/readiness.pg.spec.ts. New FREEZE-s11c.sha256 = sha256 of those 7 at HEAD; FREEZE
  paths == delta. KEEP the A1 FREEZE-v3 check too, but as "the 8 A1 files are byte-identical at HEAD" (not == delta).
- Keep all A1 blob pins (unchanged at HEAD — verify). Add EXPECT_READINESS_BLOB for test/scout/s11/readiness.pg.spec.ts,
  its pinned live switch form, BADPAT refusal and it() count (compute; expected 6), and pins for the two product files.
- Commands, each exactly once, template order: bootstrap; rls-g2-s11 (6); journey-core (8, regression: S11-C changes
  extension-pair.service.ts which journey-core drives); NEW readiness: `./node_modules/.bin/jest --runInBand --ci
  test/scout/s11/readiness.pg.spec.ts` (default config) with its own log jest-readiness.log, count check, receipts entry;
  guard (94, no DB). Bound the added stage inside the existing total budget (adjust the stage-bound comment and, if the
  template enforces a sum, the timeout arithmetic).
- Keep STARTED placement, teardown, receipts, refusals exactly as the template (no other restructuring).
Read-only helpers: git in fa72-s11c, sha256sum, bash -n. Rules: execution/fa72efb2/WORKER_RULES.md.
Return: file list + sha256, every changed pin with its verified value, the full delta summary, open risks.
