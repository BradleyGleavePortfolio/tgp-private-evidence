# S8-C bootstrap correction — CORRECTION_RECEIPT (EXEC-DACEDDC8 grant S8C-BC-2)

Builder: `s8c_bootstrap_completion` (T4, sole writer of `worktrees/64e33dc7-s8c`, `s8c/bootstrap-correction/run/`, `s8c/checkpoints/v6/`, `s8c/binding/v4/`, this file). Authority: `execution/daceddc8/SCOPE.md` §S8C-BC-2 and §Additional grants (16:35Z); heavy slot relayed for the gate commit only. Parent orchestrator retains correctness ownership and publishes evidence; this builder committed nothing in the evidence repo and pushed nothing anywhere. Written 2026-09-25 ~16:41Z.

Result: **all four steps completed RC=0 on first attempt. No failure, no replay, no `--no-verify`, no amend, no PG, no Jest, no generator, no driver/fixture execution.**

## 0. Preconditions verified before the slot was used (16:36Z, read-only)

| Check | Observed |
|---|---|
| Worktree / branch | `/home/user/workspace/worktrees/64e33dc7-s8c`, `exec64/s8c-replacement` |
| HEAD / tree / parent | `87018a421f5be1064767d2cdd32e75ca935f7cdb` / `cec7d05a91876ec3f6badb1020bb97aacdb9331d` / `af9f7f5438fa545394b6d28792411439ded66caf` |
| Porcelain | exactly ` M test/utils/g2-s8c-bootstrap.sh`; 0 staged, 0 untracked, 0 stashes; numstat `7 2` |
| WIP blob / sha256 / mode | `7c3fba471f991e3750eb56fd29e271101652196e` / `0fdb0a4111c1c4914b7c4ca309e34bcca17f0a956d1719b5eb0b56c503c99eb5` / 755; byte-identical (`cmp`) to frozen `s8c/handoff-freeze/g2-s8c-bootstrap.sh.WIP` |
| Gate script | `bootstrap-correction/s8c-bootstrap-gate.sh` sha256 `b589713bf7b94d8e7c10fe293171a5a3b1a221f78b0b2a6fa618d6e601183ab4` = frozen `handoff-freeze/scripts-and-previews/s8c-bootstrap-gate.sh` (run UNCHANGED) |
| Canonical lock | `/home/user/workspace/execution/test-validation.lock` inode 674373, 0 holders (lslocks), 0 postgres processes |
| Runtime | `node_modules/.package-lock.json` `05bc530a…`, `.prisma/client/index.d.ts` `b6716a86…`, `.prisma/client/schema.prisma` `ded50406…`; pinned prettier prefix reports 3.9.9; hooks pre-commit `3b741de3…`, commit-msg `71029ce8…` (lefthook 2.1.9); `user.name`/`user.email` = Bradley Gleave / bradley@bradleytgpcoaching.com |
| `bootstrap-correction/run/`, `checkpoints/v6/`, `binding/v4/` | all absent before start |

## 1. Gate commit (heavy slot)

Launched detached (`setsid nohup … &`, polled) so a tool timeout could not kill it:
`S8C_BOOTSTRAP_RELAY=1 bash …/s8c/bootstrap-correction/s8c-bootstrap-gate.sh` — supervisor/gate pid 10494, launch record `run/LAUNCH.txt`.

| Event | UTC |
|---|---|
| Launch | 16:37:30Z |
| **Slot ACQUIRED** (flock -n fd9 in-process, inode 674373, lslocks=1, postgres=0) | **16:37:30Z** |
| DELTA `55f07d4730e3eb066d3401c1655f461789580ecc85f12158248b9ec2a3127fc6` (identical to prepared `delta-from-87018a42.1file.patch`), blob `7c3fba47…` | 16:37:30Z |
| BASH_N rc=0; no `cmp -s` remains; prettier prefix 3.9.9 | 16:37:30Z |
| STAGED_TREE `b249efb66e22f4c13529f255f3510d4a81314a99` | 16:37:31Z |
| COMMIT rc=0 (genuine lefthook hooks; hook_lines=6) | 16:38:19Z |
| **Slot RELEASED** (`RELEASED` line; fd9 closed at process exit; lock file preserved) | **16:38:20Z** |
| Post-check: lslocks holders 0, inode 674373 unchanged, postgres 0 | ~16:38:30Z |

Hook results (`run/commit.raw.log`, ANSI stripped): pre-commit — `prod-readiness-quick` ✔ 0.02s, `banned-cast-tokens` ✔ 0.10s, `tsc` ✔ 48.27s; `eslint (skip) no files for inspection`, `prettier (skip) no files for inspection` (the staged `.sh` is outside both hook globs, as the grant anticipated); commit-msg — `no-ai-tokens` ✔ 0.02s. `supervisor.stderr` empty; `supervisor.stdout` byte-identical to `run/s8c-bootstrap-gate.log`. `git commit` was run with `timeout -k 30 1800`, `NODE_OPTIONS=--max-old-space-size=4096`, `npm_config_prefix` = pinned prettier prefix, `npm_config_offline=true`.

Resulting commit:

| Field | Value |
|---|---|
| **HEAD** | `e0cee7e04bef88811310f6dde1fd921f45d103ad` |
| **TREE** | `b249efb66e22f4c13529f255f3510d4a81314a99` (= staged tree written before commit) |
| Parent | `87018a421f5be1064767d2cdd32e75ca935f7cdb` (exact frozen parent) |
| Author / Committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same, `2026-09-25T16:37:31Z` |
| Subject | `S8-C: pin the accepted generated client schema copy by SHA256 in the G2 bootstrap` (body = `commit-message.txt` `43511173…`; no trailers; gate trailer check passed) |
| Delta | exactly `M test/utils/g2-s8c-bootstrap.sh`, +7/−2; blob `8aa86de8164fef29d85ec6b0720ece0903fb8a70` → **`7c3fba471f991e3750eb56fd29e271101652196e`**, mode 100755 |
| Porcelain after | 0; reflog top `e0cee7e0 commit: …` over `87018a42` |
| Not pushed | branch has never been pushed |

Raw logs preserved in `s8c/bootstrap-correction/run/` (see `run/RUN_MANIFEST.sha256`): `LAUNCH.txt` `13d0ba7d…`, `s8c-bootstrap-gate.log` `0f189e3e…`, `commit.raw.log` `fcaeb8d4…`, `bash-n.log` (empty), `delta-from-87018a42.1file.patch` `55f07d47…`, `supervisor.stdout` `0f189e3e…`, `supervisor.stderr` (empty), `export-v6.log` `219c9148…`, `prepare-binding-v4.log` `38782293…`.

## 2. Checkpoint v6 (`s8c/checkpoints/v6/`)

Exported 16:39:02–16:39:03Z with parent-prepared `export-v6-daceddc8.sh` (sha256 `b8f65f729be04e17a1d6a94bc2939dfb6fdaf1317c0240432b315edbe5bceb4d`, run **unchanged**; `bash -n` OK; refusals for existing v6 / dirty / wrong parent / non-one-file delta all passed). RC=0. `git bundle verify … is okay`; bundle lists exactly `e0cee7e0… refs/heads/exec64/s8c-replacement`, requires `93389265…`. `sha256sum -c MANIFEST.sha256`: 5/5 OK.

`MANIFEST.sha256` (file sha256 `768c6f4b5b8347af38ee7cc154150bb04f0e421f21a6b66c84f17ad0ba87e3bc`):
```
8c75a9c38da397cd640c2c4e9e4b6475b7163173b6b0e13aeea2a714108514fb  CHANGED_PATHS_from_87018a42.txt
04c03f408313ec8e37cbdba11892962f2c2ad31752e03d01dc708e712aa4aa63  CHANGED_PATHS_from_base.txt
c0d85237e29594bfc30971ebcbdf049b16c200bf2c65b31a872beaadd6fa61df  HEAD.patch
48a22bf88524907386029ee536bef84c4ad869bc9fc52fb7361daee66cd8fc59  HEAD.txt
97c14d066883b3fa0b4bb46aa9fa585a261957541e580a253c79d2806998603f  s8c-e0cee7e0.bundle
```
`HEAD.txt` records: PRISMA_TREE / SRC_TREE / DOCS_CONTRACTS unchanged from parent = yes; BOOTSTRAP_BLOB `7c3fba47…` mode 100755; PORCELAIN=0. Also present: `bundle-create.log` (empty), `bundle-verify.log` `c3190099…` (not in manifest, same as v5 shape).

## 3. Binding v4 (`s8c/binding/v4/`)

Prepared 16:39:16–16:39:17Z with parent-prepared `prepare-binding-v4-daceddc8.sh` (sha256 `7c21f1421a5e0c46b5a39f099e6a916e775045851abe85c3f266bb53880d70b0`, run **unchanged**). Verified before running: `diff prepare-binding-v4.sh prepare-binding-v4-daceddc8.sh` is byte-identical to the recorded `prepare-binding-v4-daceddc8.diff` (`3e455ab9…`); the only differences from frozen `2c6f01c3…` are the header comment, the loop/comment literals adding `"$RUNTIME_ROOT"/proof-v4/clusters/*/`, the README appendix wording and the matching LOOP_REWRITE_COUNT assertion. Script's own refusals/assertions (existing v4, dirty, wrong parent, non-one-file delta, v3 manifest 7/7 OK, six blob pins vs head, unchanged-pin diff vs v3, loop count 2, no `basename`, `CLUSTERS` constant, no `__FILL`, fresh paths, fixture pin derived) all passed. RC=0. **Driver, fixture, bootstrap, PG and Jest were never executed.**

`BINDING.sha256` (file sha256 **`c2cfd0a3f65b3889c41eef24313658be626651adc3f5205f9d11e50883dc5f03`**; `sha256sum -c` 10/10 OK):
```
73b291dba1725353583f27d61cb162017a95bc3d9aca0810227cfae0212db2bd  s8c-pg-proof.sh
c59326b56d8aaedf2cd509fb602cb64eb41620bf4c0c1773e2b4c5c6710685e9  s8c-fixture.sh
f2b5ee7c47f2b0cb4e20f91fc2a78eeee4aa19d54f81ae26ad957316a3c98ea5  PINS.txt
f2a72405e0234cbc62e64905f00112fa439490be60ad33751b222679b100cff0  README.md
9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8  s8c-pg-proof.sh.v3
1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3  s8c-fixture.sh.v3
316dd1214efae211fe215bf80d0ff3c5bde120f9a2369e8a9760ec3553ad3603  PINS.txt.v3
b8f944385a5ceb36d05af668b746c1d275b615a440d9fed68650792ddf46b76f  s8c-pg-proof.sh.diff-v3-to-v4
112e2f2e1720d427d4615977810f65cb310e98f683ae4bf50ba785ba4bb341eb  s8c-fixture.sh.diff-v3-to-v4
8baf4e852370a5db7c5d2cff832364e498eb5c17bd36fd213e0bfc357947f91b  PINS.txt.diff-v3-to-v4
```
**v4 driver `s8c-pg-proof.sh` sha256 `73b291dba1725353583f27d61cb162017a95bc3d9aca0810227cfae0212db2bd`; v4 fixture `s8c-fixture.sh` sha256 `c59326b56d8aaedf2cd509fb602cb64eb41620bf4c0c1773e2b4c5c6710685e9`** (both mode 755). `.v3` copies are byte-identical to `binding/v3/` (same sha256 as the v3 manifest). `prepare-binding-v4.log` `38782293…` (written after the manifest, not in it — same as v3's shape). `binding/v4/run/` does not exist (fresh sentinel/receipt path).

Builder's independent verification of the output (read-only):
- Driver pins derived from the head and equal in driver, PINS.txt and `git rev-parse`: EXPECT_HEAD `e0cee7e0…`, EXPECT_TREE `b249efb6…`, EXPECT_BOOTSTRAP_BLOB `7c3fba47…`, EXPECT_SPEC/DB/PGH/HARNESS/WORKER_BLOB unchanged (`dc804fde…`, `a7d67217…`, `4059883d…`, `d5cbf877…`, `48403063…`), EXPECT_FIXTURE_SHA = actual fixture sha `c59326b5…`.
- All other pins byte-identical to v3: BASE_HEAD/TREE, nine tool pins (POSTGRES, INITDB, PGCTL, PSQL, NODE, NM_LOCK, NM_CLIENT, SCHEMA, PKG_LOCK), PORT 55642, `FIX=$D/s8c-fixture.sh`, accepted-base blob pins.
- Driver diff v3→v4 is 17 changed lines: `D=…/binding/v4`; EXPECT_HEAD/TREE/BOOTSTRAP_BLOB/FIXTURE_SHA; `LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v4/run/s8-c` (+1 comment line); both other-lane loops (preflight L138, post L182) now `for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/; … [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}`. `CLUSTERS=$RUNTIME_ROOT/clusters` kept (1 occurrence); `basename` 0; `__FILL`/`__PREVIEW` 0; `proof-v4` 4 in driver, 4 in fixture; `bash -n` OK both. Receipts path `R=$D/run` → `binding/v4/run`.
- Versus the frozen preview `preview-driver-paths-loops.sh` (`09bf448b…`): differs only in the filled HEAD/TREE/FIXTURE_SHA and the added `proof-v4` glob + its comment. Versus `preview-fixture-paths.sh` (`097a4fa6…`): differs only in the two/three header-comment lines (as SOURCE_EDIT_READY anticipated).
- Fixture diff v3→v4: `LANE=`/`DATA…SOCK=` constants and the header-comment lines only (9 changed lines).
- Sandbox path note: in this fresh sandbox `recovery-reset/clusters`, `proof-v3` and `proof-v4` do not currently exist; the loops' `[ -d "$d" ] || continue` guard and the driver's `PREFLIGHT clusters_dir=ABSENT` line handle that. Both retained-lane paths from the old sandbox are not present here (HALF_DONE_WORK §C).

## 4. Deviations, observations and things NOT done

1. **No script was modified.** Both parent-prepared helpers (`export-v6-daceddc8.sh` `b8f65f72…`, `prepare-binding-v4-daceddc8.sh` `7c21f142…`) and the gate (`b589713b…`) ran byte-unchanged. No defect blocking execution was found.
2. **Label inaccuracy in `checkpoints/v6/HEAD.txt`:** its last line reads `EXPORTED_BY=execution/daceddc8 parent operator 2026-09-25T16:39:03Z`. The export was actually executed by this T4 builder under the parent's grant. Left as emitted (script unchanged; hashed into the manifest); this receipt is the correction of record.
3. **Stale documentary line in `binding/v4/PINS.txt` L57 (pre-existing in the frozen prepare script, not introduced by the daceddc8 derivation):** `DIST=$RUNTIME_ROOT/pg17/dist  DATA=$RUNTIME_ROOT/clusters/s8-c/pg-data  SOCK=$RUNTIME_ROOT/run/s8-c` still shows the v3 lane paths. The driver and fixture (the executed artifacts) carry the correct fresh `proof-v4/clusters/s8-c` and `proof-v4/run/s8-c`; PINS.txt is not read by the driver. Not hand-edited (bindings are derived, never hand-adjusted; v4 is frozen and hashed). Flagged for the parent/reviewers; a correction, if wanted, would need a recorded fill-script change and a new binding version, not an edit of v4.
4. `run/bash-n.log` and `run/supervisor.stderr` are empty (sha256 of the empty string), as expected for a clean run.
5. `mkdir -p …/bootstrap-correction/run` was done by the builder just before launch so `supervisor.stdout/stderr` could be redirected there; the gate's own `mkdir -p` is idempotent.
6. Untouched: S7-L worktree (`a68cdac7`, only `rev-parse` read), other lanes, `binding/v1–v3` (v3 manifest verified 7/7 OK, unchanged), `binding/v3/run/`, checkpoints v3–v5, all reviews and receipts. Nothing pushed; evidence repo not committed by the builder.
7. Slot state at hand-back: 0 holders on `test-validation.lock` (inode 674373 preserved), 0 postgres processes, worktree porcelain 0.

## 5. Summary line for the orchestrator

HEAD `e0cee7e04bef88811310f6dde1fd921f45d103ad` · TREE `b249efb66e22f4c13529f255f3510d4a81314a99` · parent `87018a42…` · bootstrap blob `7c3fba471f991e3750eb56fd29e271101652196e` · v6 bundle `97c14d06…` · v4 driver `73b291dba1725353583f27d61cb162017a95bc3d9aca0810227cfae0212db2bd` · v4 fixture `c59326b56d8aaedf2cd509fb602cb64eb41620bf4c0c1773e2b4c5c6710685e9` · v4 `BINDING.sha256` `c2cfd0a3f65b3889c41eef24313658be626651adc3f5205f9d11e50883dc5f03` · slot acquired 16:37:30Z, released 16:38:20Z. Next (not this builder): dual changed-question review (`BOOTSTRAP_CORRECTION_REVIEW_A/B`), then a separately granted single `timeout -k 30 3900 bash s8c/binding/v4/s8c-pg-proof.sh`.
