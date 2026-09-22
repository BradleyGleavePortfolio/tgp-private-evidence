# SLOT REQUEST 03 (B3-S1S2-COMPOSITION-R3) — IMMUTABLE, frozen 2026-09-22T00:48Z. Corrections, if any, go in a new named file.

## Candidate (frozen)
head d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c  tree c0ab87d4dc584b2a7ccad53db16fa551b93fe359  parent 21ea3252de90cab66c591cf907b65a0ee7eef879 (frozen B2 source, untouched)
branch execute/20260921-s2-composition-r2, worktree /home/user/workspace/worktrees/s2-composition-r2 (clean)
delta vs 21ea3252: ONE file test/release/s1s2-composition.sh (+12/-7), sha256 c766a8d9d9e3a600be88a5bf2d60a108eabb88aac363fbe5acf85c96a973b867
  (B2 harness sha256 44737549…01b6). No product / release.sh (8831f8f7…f073 unchanged) / contract / S1 change: git diff 56fb0d22..HEAD -- prisma/migrations test/db = empty.
  Note: an intermediate commit 7f6fa2de (same intent, S1_OWNED_PATHS referenced $MIG before definition; caught by the stub control: "MIG: unbound variable")
  was amended into d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c before being bundled or reported; it is not part of any frozen state.
bundle bundle/s2-composition-r3-d5cd9b8b-from-public-c23b9d9.bundle sha256 3b6cee481319dd518268b7573ebed142fa234e193b874d8712a6cdf5493c0f75 (verify ok; needs public c23b9d9f); commits: bundle/commits-r3.txt
all commits author=committer Bradley Gleave <bradley@bradleytgpcoaching.com>, no trailers

## Root cause fixed (B2's exactly two failures, both check C0)
C0 built the "S2-only tree" by git archive of the historical S2 head e15e25c2; after release.sh changed (93a85544) the identity check compared old vs new
release.sh and the banner check asserted the new 'prisma 6.19.3' banner on the old script. Now: C0_TREE_COMMIT=$(git rev-parse HEAD) exported to a throwaway
mktemp dir; only the declared S1-owned paths ($MIG_DIR, test/db) are removed INSIDE that export (never the worktree); check text/stamp say so
(c0_tree_commit=…). Retained byte-for-byte: release.sh identity assertion, 'prisma_cli += prisma 6.19.3$' banner assertion, and all refusal assertions
(exit 1, 'REQUIRED catalog verifier missing', no 'step 1:', no P1001/Can't reach, no /tmp/prisma_migrate.log, no success banner). Tree check now also
asserts $MIG_DIR and test/db absent. Check count unchanged: 68.

## Cheap offline controls (no DB, no install; evidence c0-offline-control/20260922T004424Z/)
- New construction (HEAD export minus S1 paths) vs old (e15e25c2 export), both run against synthetic unreachable postgresql://…@127.0.0.1:54321/s1_rls_unreachable_c0
  with NO listener on 54321 and no pg17 postgres process before/after (stamped): new → release.sh sha identical to HEAD (8831f8f7…), verify.sql/mig dir/test/db
  absent, 164 migration dirs, exit 1, contract refusal=1, banner 'prisma_cli = prisma 6.19.3'=1, no step 1, no P1001, no success banner, no prisma_*.log created,
  release_verifiers_discovered.txt 0 lines. Old → same refusal/no-contact, but identity=0 (9908234e…) and banner=0 ('Prisma schema loaded…') = B2's two failures reproduced.
  (These commands replicate the new C0 block; the harness's own C0 block cannot run offline because the S1 guard preflight precedes it.)
- Refusal harness at d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c with hosted URL → exit 64 (guard refusal reached; the earlier ordering slip would have failed here).
- r3 runner stub controls: success at pinned head → final 0, all steps; pre-existing /tmp/prisma_status.log → final 70, file left untouched (content verified after).

## Runner (v5.0, pinned to these bytes) run-composition-r3-when-granted.sh sha256 6b75a93345216886905b75fb01ac35e26909424e7b38fd6364db5047e3308122
copy runner-history/run-composition-r3-when-granted.sh.v5.0.frozen. Delta vs v4.1 (14ca1e85, B2 as-run): EXPECT_HEAD=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c; namespace clusters/s2comp-r3,
DB s1_rls_s2comp_r3, out composition-r3/<utc>/, selftest runner-selftest-r3/; pre-existing release.sh /tmp scratch files → REFUSE exit 70 with listing, never
moved/deleted (replaces v4.1's preserve-by-move). Everything else identical (nonblocking canonical lock, refusals 64/64 before any server, fresh-only
namespace/54321/no-postgres prechecks, anchored survivor scan, stop attempted whenever start attempted, 71 on cleanup failure).
fixture infra/s2-fixture.sh 6062f4ce43ecd10ce9407f295293ea2515e18cfd42fea1b9581250e87f9a6d61 ; launch-detached.sh 64302b3e77de039a8c74f601227cf431d655f8e1251d5489febb4fb72db0a36d ; dependency closure = A2 node_modules via git-ignored symlink (runner re-verifies lock/package.json/schema bytes + stamp).

## Requested slot B3 (after S6; not now)
launch: cd /home/user/workspace/execution/s2-composition && ./launch-detached.sh start composition-r3 env -u S2_RUNNER_STUBS timeout --foreground -k 60 2100 bash /home/user/workspace/execution/s2-composition/run-composition-r3-when-granted.sh
bound 2100 s + 60 s kill; ≤2 CPU / <3 GB; sole heavy owner; loopback 54321 only; fresh clusters/s2comp-r3 only; B1 s2comp, B2 s2comp-r2 and S5 clusters preserved.
prechecks at launch (reported, not assumed): lock FREE via check-lock.sh, no pg17 postgres, no 54321 listener, clusters/s2comp-r3 absent, /tmp scratch files absent, head d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c clean.
steps: guard spec → refusals 64/64 → fresh PG 17.6 fixture → real 164+1 composition (harness, 68 checks) → S1 56fb0d22 discriminator (S1 expects 47/48; S1 interprets) → stop → survivor/listener/lock proof.
report: real PID/launch time/deadline, actual counts (not expected), pending_before single-line, ALL_APPLIED, discriminator detail logs, exit sentinel/exit-codes, stop/survivors/listener/lock.
On first unexpected failure the runner stops after that step (cleanup always) and I preserve and diagnose; no retry, no repair without authorization.
