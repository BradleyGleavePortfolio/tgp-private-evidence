# S8-G SOURCE_READY — FINAL identity (post-gate, committed; supersedes SOURCE_READY.md + REBASED.md, which are kept as history)

Lane G-NEW-1, EXEC-1910A060. Clone `/home/user/workspace/worktrees/1910a060-s8g`, branch `exec1910/s8g`. **Not pushed; parent owns landing.** Binding unfilled/unrun.

| Item | Value |
|---|---|
| Base | `62471b116267fdec6746073c4b4c80a154d09834` (tree `23614f0b7dc33dc37b90cf4f27fcb8331912e60f`; integration/importer after S8-F merge) |
| Commit | `820ce85be2ebf994112afbb90739eb9469ad628e`, tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`, sole parent = base (pure FF) |
| Author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com> (both); message `feat(scout): S8-G run orchestration — reconstruct-then-arbitrate settle hook`; no trailers; hooks ran genuinely (lefthook pre-commit: prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc; commit-msg: no-ai-tokens — all ✔) |
| Delta | 14 files, +3877 / −14 (2 modified, 12 created; bootstrap.sh mode 100755) — exactly the granted PATHS |
| Final patch | `gate/attempt-4/s8g-a4-62471b116267-to-820ce85be2eb.patch` sha256 `36b53f0c8d2efb1afa5d3e840a8ad7a9c32deb03ed3f440ada338fa7926a45dd` (byte-identical to `git diff --binary 62471b11 820ce85b`) |
| Gate | `gate/attempt-4/` rc 0: prettier check rc 0 (no rewrites needed), eslint rc 0, tsc rc 0, jest targeted 4 suites / 86 tests, full default jest 577 passed / 12 skipped of 589 suites, 9111 tests passed / 159 skipped / 5 todo, 6 snapshots (634 s), `rls-g2-s8g` did not run (guarded lane), lock inode 667698 held 22:15:23Z→22:27:57Z and released |

## Per-file final identity (`final-blob-hashes-820ce85b.txt`; all identical to the attempt-4 staged blobs logged by the gate)
| Path | blob | sha256 |
|---|---|---|
| src/scout/lifecycle/lifecycle.service.ts (M) | 1a6db74e41370d3dc34f7bc74996c2e097a0e9e5 | 14fadc5eaef30cc66d75a57fde49e497f5225a1cf6f903b1e6d7ed413fe84b5a |
| src/scout/scout-reconstruct.service.ts (M) | fb72850284e33249b4b682bbf3f1d28a914357b6 | 7b7d47a2d551c49a6937ee27822c7a6721ca4dc55ef3c9248e48e168940d0524 |
| src/scout/reconstruct/orchestration/family-plan.ts | 0a75e656d2b1f9d0b411599c6cbd15c684815df4 | a3e57e7605cacecc4ab3e4b8432ed9babc167ed04e0492c587b07ef645a32ce5 |
| src/scout/reconstruct/orchestration/run-context.ts | b07ebb853344d59b3b2dd6ac4dcf8d0d1f9182fe | bd4da5c86d91d7c6452d5bbacacb755f3b9a6e81f0402ec2b0a5c820c6e48c02 |
| test/rls-g2-s8g.spec.ts | 86a944c11d69f4561812f86bd82431e625832752 | 208f36b1465fece12faebad81723f944b8abfd342758bf0e5d2173728b3ac341 |
| test/scout/g2-s8g-db-guard.spec.ts | 4009f753a8d194fc9f9b180960a53f50a28bc79f | d2f6a75c2f125fba847dd88e1db27793f4298cf37f86d0dad3e800490d8c5f92 |
| test/scout/orchestration/family-plan.spec.ts | 829ad280b6c773c6e861797001176ae0c55f72df | d21c1e60e5212e69c48d00f6fff01d782bc9f10f3ae307363993bdff74f76cc9 |
| test/scout/orchestration/reconstruct-run.spec.ts | 497798e1daaa5027c4435dd5b5bc3022b16f6328 | e333bc513a638a293b907384199322b8289ef96b24b70a502b0004def7beb355 |
| test/scout/orchestration/settle-hook.spec.ts | 4465515d77865ffaacd94ef47c9240d2539f5806 | 06c1562861040777bc1a8f6dceb28f8c045fd36198b37b598aa8a422b63ee342 |
| test/utils/g2-s8g-bootstrap.sh (755) | 2ab85a1341cd4545edeb145dded67e6bef3fa2bf | 3241806c42cb7a2b421d18827d9365f960d2db159083ba988602fd6ff2fdf374 |
| test/utils/g2-s8g-db.ts | c654e6bd7364be70fba9b63d9f061aa60646b122 | 40d8655ef18c6d3ca205e0eb957d4262c49714b70253fc04d7e9802959809199 |
| test/utils/g2-s8g-harness.ts | ee2a41a2c118d4576878b65bf9b65cf220d0cf27 | 75f3e39fd29ab8c209455c2467f877f488cc97f1cd140643d496e7305f65eac5 |
| test/utils/g2-s8g-pg-harness.ts | a02612463dcb2ed8b7605d68348011a0b1321be8 | 196852344a2db6e1c8764204232199c997fcae648c65da9513e91f8663bc7ab8 |
| test/utils/g2-s8g-worker.cjs | 65ee972d3bb44eca84a6007d81b4675452e2d94c | 787316a24ae10ab2e4920d80a0e03954cb09bf582be0efd3aa230eca6a2563c2 |

Product `src/**` blobs (4) are byte-identical to the reviewed SOURCE_READY patch — product SOURCE GO from both reviews still applies verbatim. Unchanged at base and head: prisma/schema.prisma 2e328bbc, package-lock 354de3da, package.json, jest configs, lefthook.yml, R75 policy, all 20 accepted S7-L/S8-C pins and all 17 S8-F paths (see `binding/v1/PINS.txt.unfilled`).

## Complete delta vs the reviewed patch (`s8g-candidate-62471b11.patch`, sha256 9119d6d3…) — `delta-reviewed-to-820ce85b.patch` sha256 b39222513531698fcc2b77efface21905f3159c517f64862ef4fd1e1c9fc2a38
Reviewed tree (base + reviewed patch, reconstructed via a temp index) = `a14aaac25784135f3576df978437e8538b468b72`. `git diff a14aaac2 820ce85b`: 6 files, +507/−126 — ALL in test files; product src unchanged. Decomposition:
1. **Prettier (formatting only, gate attempt 1 `--write`)** — `test/rls-g2-s8g.spec.ts` (+/− 468 lines: wrapped long lines; no token change), `family-plan.spec.ts` (22), `settle-hook.spec.ts` (31), and parts of `reconstruct-run.spec.ts` / `g2-s8g-db-guard.spec.ts`. Verifiable: attempt-1 `gate/postformat/*` copies equal reviewed content after `prettier --write`, and `gate/prettier-check-2.log` rc 0.
2. **FIX-1** (`gate/FIX-1.md`, `FIX-1.diff`) — reconstruct-run.spec L77 `(s as Record<string, unknown>)[k]` → `s[k as keyof Staged]` (tsc TS2352 closure; parent disposition 15:04 PT).
3. **FIX-2** (`gate/FIX-2.md`, `FIX-2.diff`) — reconstruct-run.spec inline source-spec fixture gains the required `clientSourceId` rule for programs/workouts/client_history (parser correctly rejected the fixture; disposition 15:09 PT).
4. **Dev-loop iteration 2** (`gate/DEV-LOOP.md`, `dev-loop/iter-2.diff`; review-B B2/C1) — `test/utils/g2-s8g-db.ts` adds `'55643'` (retained S8-F lane) to `REFUSED_PORTS` + comment (55644 suggested); `g2-s8g-db-guard.spec.ts` fixture moves 55643→55644, adds the 55643-refused case, adjusts the mismatched-ack/foreign-db ack literals. One assertion added, none weakened.
Non-formatting delta measured against the attempt-1 post-format copies: reconstruct-run.spec 17 lines, g2-s8g-db-guard.spec 61 lines, g2-s8g-db.ts 6 lines; all other files 0. Dev-loop iteration 1 made no edits.

## Gate history (all evidence preserved under `gate/`)
attempt 1 rc 73 tsc (one TS2352, test file) → FIX-1 → attempt 2 rc 73 jest-targeted (fixture rejected by parser) → FIX-2 → dev loop (iter-1 85/85, slot NOT held — disclosed in DEV-LOOP.md; iter-2 86/86 under held slot after the 55643 change) → attempt 3 launched then deliberately ABORTED by the builder during full jest, before commit, to fold iteration 2 into the single commit (`attempt-3/ABORTED`) → attempt 4 rc 0 (this commit).

## Binding draft status (`binding/v1/`, still `.unfilled`, unrun; pre-review snapshot kept in `binding/v1-pre-review-snapshot/`)
Applied per reviews A/B: runner `LANE=$CLUSTERS/s8-g` (+ own-lane skip in both other-lane scans), `PORT=55644` (runner + fixture), `BASE_HEAD=62471b11…` / `BASE_TREE=23614f0b…`, accepted-file pins re-verified at 62471b11 (20/20 identical), 17 S8-F accepted-at-base blobs added, stale schema-mismatch message text fixed (was `!= bcd`), Phase-2 scoping table of S8-G harness files vs S8-C ancestors (none differ by pin literals alone — all seven carry substantive lane-design changes). Nine head pins derivable now are in `gate/attempt-4/BINDING-PINS-820ce85be2eb.txt` (EXPECT_HEAD 820ce85b…, EXPECT_TREE 7ede6dbb…, spec 86a944c1, bootstrap 2ab85a13, db c654e6bd, pgh a0261246, harness ee2a41a2, worker 65ee972d, fixture sha256 b2dd548a… of the post-review fixture) — NOT filled into the runner (awaits parent grant).
