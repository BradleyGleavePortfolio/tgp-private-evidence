# B/drain — independent reviewer A (successor) — preliminary continuation note

Status: **PRELIMINARY**. Written 2026-09-24 ≈14:56Z while the builder's granted environment recovery is running (`env-recovery.log`: `NPM_CI start` 14:55:00Z). Final binding waits for the actual committed head, gate receipts and the filled PG binding.

Identity/telemetry: this is a **successor** reviewer A continuing the existing review question of `audits/b-drain-a/B_DRAIN_V4_BINDING_REVIEW_A.md`; it is not the inaccessible former reviewer A. Requested route Claude Fable 5 (live label Claude Fable 5.1) / High is a request only; no runtime telemetry was observed by this reviewer and none is claimed. Peer B reports were not read. Read-only: `git rev-parse/ls-tree/diff-tree/hash-object` (no `-w`), `sha256sum`, file reads. No install, hooks, gates, commit, PG, lock, or worktree/index write. Sole writes: this directory.

## 1. Applicability of the original A source verdict to the durable restoration — APPLICABLE

| Check (independently recomputed in `worktrees/s7-b-drain`) | Result |
|---|---|
| HEAD / tree | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` / `87798e742c7b48f56b05e9b5c30efa877180a9b3` == PINS_A base; porcelain: exactly the 11 untracked v4 paths, 0 tracked modified |
| 11 working files vs A's `verify/v4-blobs.git-sha1` | all 11 `git hash-object` ids equal; modes 644×10, 755 for `g2-b-drain-bootstrap.sh` — match |
| v4 tree object | `f4922ca070e887fb7f613ce955b12621b5c33156` exists; `diff-tree base..v4` = 11 `A` only; `diff-tree -p` sha256 `9206197e…` == A's `verify/recomputed.v4.diff` (byte-equal) |
| S5 donors at HEAD | `0e73d76d`, `ab9aaab4`, `85a636ba`, `4fed8bcd`, `b9080538` unchanged |
| Inputs | `package.json 656d11a2`, `package-lock.json 354de3da`, `prisma/schema.prisma eb390870` == PINS_A/C1 |
| History | shallow graft `c23b9d9f` identical to the original s7-c1 shape; O `925780e0` is an ancestor of HEAD (old-root fixture precondition satisfiable) |
| Sealed PG inputs | `execution/95633079/s7-b-drain/fixture-proposal-v3/` restored; `PROPOSAL.v3.sha256` 3/3 OK against the private sealed copy; `b-fixture.sh` = `4525f01d…` (grant's `EXPECT_FIXTURE_SHA`); template still holds exactly the 5 placeholders |
| Commit message | `remainder/commit-message.txt` byte-identical to private `phase-a/commit-message.txt` (`fca0b6aa…`) |

Conclusion: the restored candidate is byte-identical to the frozen v4 that the source verdict SOURCE_GRANTABLE (phase A) was issued on. Nothing in the candidate, base, donors or inputs changed. **No source re-audit is warranted and none was performed.** Phase-A gate list and the five-pin binding requirements in the prior report §3–4 carry over unchanged (EXPECT_TREE `f4922ca0…`, EXPECT_SPEC_BLOB `9b31fd18…`, EXPECT_BOOTSTRAP_BLOB `b4503eef…`, EXPECT_FIXTURE_SHA `4525f01d…`, EXPECT_HEAD = actual commit).

## 2. Concrete environment/binding obstacles introduced by the fresh runtime

Only one class-B item; it is already dispositioned by the parent grant `B_ENVIRONMENT_RECOVERY_AND_REMAINDER_GRANT.md` and matches this reviewer's own independent reading. No new safety mechanism is requested.

**B-ENV-ABSENT (B, execution-only).**
- Harm: the phase-A remainder's gates (`tsc`, `eslint`, `prettier --check`, `check-r75`, two-file jest) and the genuine Lefthook hooks cannot execute — `worktrees/s7-c1` and its verified 717M copy no longer exist, no durable dependency archive exists, `/home/user/pg17` and `/usr/bin/psql` absent (the latter two irrelevant to phase A). Without them any "gate passed / hooked commit" claim would be false (G05/G07/G09).
- Blocked decision: actual-head pin fill and the later single PG grant.
- Minimum closure (confirmed sufficient by reading `env-recovery/env-recovery.sh`, sha256 `1ae379b7…`): reproduce the recorded C1 route once — `npm ci --ignore-scripts` from the identical lock (`.package-lock.json` must equal `05bc530a…`), pinned prisma engines (`c2990dca`, `a2924eab…`, `5d42b181…`) + one `prisma generate` (`index.d.ts` must equal `bf679a16…`), tooling-only Prettier 3.9.6 from the preserved manifests (`6c39ea3d…`/`3e2189ff…`, CLI `6e922134…`, version-checked) with the same absolute `.bin/prettier` link C1 had. Every step refuses on mismatch; `write-tree` must remain `87798e74` before/after. The product lock contains no `node_modules/prettier` package (only an optional peer range), so the `.bin/prettier` absence precondition is expected to hold as in C1.
- Execution unlocked: stage-2 remainder → hooked Bradley commit → filled binding → this review's head/receipt binding.

Qualifications (C, record/continue):
- C-1 The sealed template comment (`b-pg-proof.sh` line 80: "not a fresh npm ci") is prose; its machine checks are the two hashes plus isolation/executables, which a hash-equal reconstruction satisfies. Receipts should state plainly "reconstructed via recorded route, hash-equal to C1" — no template edit (that would break the sealed `25eb6837…` hash and the substitution-only rule).
- C-2 `.prisma/client/schema.prisma` (`cbb5d402…` recorded) is not pinned by the script; `index.d.ts` is the accepted pin and suffices.
- C-3 Builder's note that a different Prettier 3.9.9 launcher hashes the same `6e922134…` is correct and already covered by the added `--version`/package version checks; not a defect.
- C-4 Later PG phase only: PG 17.6 dist and `psql` need the already-pinned `c1-pg/c1-env-recovery.sh` route; the template tolerates `c1_cluster=ABSENT` and requires S5 absent (true here). Old-root `git clone` from a shallow source should work (git falls back to transport clone and propagates the graft) but is unobserved in this lineage; the helper's own O-identity gate would catch any failure. No action now.

## 3. What this reviewer binds next (same review, on arrival)

1. `env-recovery` receipts: sentinel rc 0; the three pin families above; `write-tree` unchanged; hooks still absent at that point.
2. Remainder receipts: `.git/hooks/pre-commit`/`commit-msg` present and Lefthook-referencing; staged tree == `f4922ca0…`; ordered gate exits (first-nonzero honored); jest two-file summary; commit object: author+committer Bradley Gleave `<bradley@bradleytgpcoaching.com>`, parent `a0ea1bea…`, tree `f4922ca0…`, message == `fca0b6aa…` text, no trailers.
3. Filled binding at `execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh`: diff vs sealed template must be exactly the five placeholder lines; EXPECT_HEAD == committed head; other four pins as §1.
4. Then: PG-run readiness statement for the parent's separate single-run grant. Nothing else reopened.

Failures, if any, are recorded as failures; no autonomous retry or wider gates are proposed.
