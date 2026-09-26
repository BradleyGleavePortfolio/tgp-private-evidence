# S11-A1 real-PG proof binding v3 — independent T3 delta review (EXEC-FA72EFB2)

Verdict: **GO**. No A/B findings. Two C notes.
Scope: the delta only (DELTA-from-v2.diff, DELTA-fixture-from-v2.diff) plus a live-byte check of every new pin, as the grant
S11A1_V3_BINDING_REVIEW_GRANT.md requires. The v2 body was reviewed GO earlier and is not re-audited here. Everything was read-only:
I did not run the runner, jest, PG or the fixture, did not take the lock, and made no edits or commits.

## Artefacts reviewed (sha256)
- binding/v3/s11-pg-proof.sh 201eced2cb02917cd4c70e2b9ec168ab272ddaf8d3ff8872381c80440e9615f8 (40896 B)
- binding/v3/s11-fixture.sh 777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636 (= EXPECT_FIXTURE_SHA)
- binding/v3/FREEZE-v3.sha256 e6e3a15a8f2d262bbeb06c7be3ec13581bbb59ca237936fbcd6278dbc9e24187 (= S11_FREEZE_SHA)
- binding/v3/DELTA-from-v2.diff 3007ada6…9e9a; DELTA-fixture-from-v2.diff 2f11f0e1…b110
- v2 base: d3a9f701/s11a1/binding/v2/s11-pg-proof.sh e9b87830…3d20 (matches the v3 header); v2 fixture 96d2e6b2…0916

## Delta is exactly what it says
- I re-ran `diff -u v2 v3` on both files. After the header, the output is identical to both committed DELTA files (DELTA_MATCH, FDELTA_MATCH).
- Runner delta:
  - comment header and Usage line;
  - D/RUNTIME_ROOT/SRC/W/DONOR_NM;
  - BASE_HEAD/TREE, EXPECT_HEAD/TREE, LAND_REF, EXPECT_SPEC_BLOB, S11_FREEZE(+SHA), EXPECT_FIXTURE_SHA, EXPECT_LOCK_INODE, DONOR_CLIENT_SHA/SCHEMA_SHA;
  - the inverted guard;
  - one log-message text change.
- Fixture delta: only the RUNTIME_ROOT literal, plus two comment lines.
- No stale v1/v2 literal is left in non-comment lines. I grepped for d3a9, 1910a060, /workspace/tgp-private, c8ee9005, 53b2f70, 7746a87 and 692282.

## Pin verification against live bytes (all MATCH)
| Pin | Live value | Command |
|---|---|---|
| EXPECT_HEAD / EXPECT_TREE | 3db615c0… / 6ea6852c… | `git -C worktrees/fa72-s11a1 rev-parse HEAD HEAD^{tree}` |
| BASE_HEAD (= HEAD^) / BASE_TREE | 6a33df9b… / 454fd501… | `rev-parse HEAD^ HEAD^^{tree}` |
| LAND_REF origin/land/s11a1-v3 | 3db615c0… in the source; also 3db615c0 in repos/backend | `rev-parse refs/remotes/origin/land/s11a1-v3` |
| Source clean | empty porcelain | `git status --porcelain` |
| EXPECT_SPEC_BLOB | a4ba04ee… | `rev-parse HEAD:test/rls-g2-s11.spec.ts` |
| Unchanged blobs (journey/guard/bootstrap 100755/db/harness/pgh/worker/jest/schema) | all equal the pins | `rev-parse HEAD:<p>`, `ls-tree` |
| Migrations tree HEAD = BASE | 7b6fe0ed…; 173 dirs; last = 20270124000000_scout_run_observation_expand | `rev-parse`, `ls-tree -d` |
| package-lock / schema sha at HEAD | b7fed5ed… / d6d01f54… | `git show HEAD:… \| sha256sum` |
| BASE..HEAD delta | exactly the 8 EXPECT_DELTA paths | `git diff --name-only HEAD^ HEAD` |
| FREEZE-v3 contents | sha256 of each of the 8 paths at HEAD equals the file line for line (FREEZE_MATCH) | `git show HEAD:p \| sha256sum` loop + `diff` |
| HARNESS_BASE 711c1f8f ancestor of BASE; no prisma/deps/test-utils diff | rc 0; empty | `merge-base --is-ancestor`, `diff --name-only` |
| Lock inode | 686480 | `stat -c %i test-validation.lock` |
| Donor hidden lock / client index.d.ts / client schema | 05bc530a / 2c819c8a / aca7a558; donor is a real directory | `sha256sum`, `stat` |
| Donor prisma CLI | 6.19.3 | `node_modules/.bin/prisma --version` |
| rt-setup.log NM_OK | hidden_lock=05bc530a, client_index_dts=2c819c8a, client_schema=aca7a558, prisma=6.19.3; sentinel RC=0, LOCK_INODE=686480 | read evidence execution/fa72efb2/runtime/raw/rt-setup.log |
| psql real / node | d1108fdb… / a03953a7… (both equal to the log and the pins) | `sha256sum` |
| PG17 postgres/initdb/pg_ctl | 23cd1748 / b7db9bc2 / af53d826 in runtime/pg17/dist; equal to the rt-setup-fa72efb2.sh pins, and the log says PG17_OK | `sha256sum`, `grep` |
| Source hooks | lefthook pre-commit/commit-msg are regular files; hooks path .git/hooks; core.hooksPath unset | `sha256sum`, `git config`, `rev-parse --git-path hooks` |
| Test counts at HEAD | rls 6 `it(` with 0 each/skip; journey 8 and guard blobs unchanged from v2 (8 / 94 accepted) | `git show \| grep -c` |

Path correction: the grant says the log is at `/home/user/workspace/execution/fa72efb2/runtime/raw/rt-setup.log`, but that path does not exist. The log is in the evidence repo at `repos/tgp-private-evidence/execution/fa72efb2/runtime/raw/rt-setup.log`. The runner does not reference the log, so this has no effect on the proof.

## The inverted guard (`!=` → `==`)
- In v2 the inequality guard meant the pinned POSTGEN client (2c819c8a) could only appear if `prisma generate` actually rewrote a stale donor client.
- In v3 the donor client already equals the POSTGEN pin, so the POSTGEN check alone cannot tell "generate ran" apart from "copy only".
- This does not weaken what S11-A1 proves:
  1. The candidate changes no prisma/package bytes. The runner enforces this with the migrations tree check at both HEAD and BASE, `diff -- prisma package.json package-lock.json` empty, the schema sha, and EXPECT_DELTA being test-only. So the correct client for the candidate is exactly the base-schema client, whether it was freshly generated or copied.
  2. The runner still runs generate in the clone and requires rc=0. It also checks: the client index/schema pin, engine equal to the pinned @prisma/engines copy, donor csig unchanged, a clean clone, and the POST client pin.
  3. The bootstrap CANDIDATE_CLIENT_VERIFIED structural check is unchanged.
- The `==` guard is also the correct self-consistency check for v3. Without it, a mis-pinned donor would pass the donor check and only fail later.
- Class C: record the loss of the "generate provably rewrote" signal. It has no bearing on S11-A1 because no candidate schema delta is possible.

## Is anything in the unchanged v2 body wrong in the new environment?
- **Partial-clone source.** origin has `[blob:none]` and the runner exports GIT_NO_LAZY_FETCH=1. I ran every source-side git operation the runner and bootstrap use, with GIT_NO_LAZY_FETCH=1:
  - ancestor checks, and `diff --name-only` for HARNESS_BASE→BASE and BASE→HEAD (including `-- test/utils`);
  - `diff --quiet BASE HEAD -- package.json package-lock.json`;
  - `git show HEAD:*` for all pinned files.
  All returned rc 0 with the expected results, and none needed a lazy fetch. `gitShow` in g2-s11-pg-harness.ts is not called by any S11 spec. The parent already dry-ran clone and checkout (rc 0, tree 6ea6852c).
- **Paths.**
  - The evidence repo now lives under repos/. D is correct and binding/v3/run does not exist yet (the runner runs `mkdir -p` on it).
  - W=worktrees/fa72-s11a1-pg3 does not exist.
  - RUNTIME_ROOT/pg17/dist exists; clusters/ and run/ are absent, as the fresh-lane precondition needs.
  - Free space is about 7.9 GB, above the 1.5 GB minimum.
  - The fixture carries the matching RUNTIME_ROOT line, which the runner cross-checks.
- **Donor hard links (C).** Donor engine files have link count 4 because node_modules is shared by hard link with the builder clones (WORKER_RULES §4). The runner uses `cp -a`, which creates new inodes, so the clone's generate cannot write through into the donor. A builder writing into its own node_modules is forbidden, and the runner would catch it anyway through the csig and DONOR_CHANGED refusal. That makes it a fail-closed refusal, not a false pass. Class C.
- The runner file mode is 644, compared with 755 in v2. It is invoked as `bash …`, so this has no impact.

## A/B findings
None.

## Minimum closures
None required for GO. Optional: correct the rt-setup.log path in the grant or its future copies to the location under the evidence repo.

## Commands run (all read-only, all RC 0 unless noted)
- `cat` of WORKER_RULES.md, the grant, and both DELTA files; `sha256sum` of the v3 and v2 bindings. On the v2 directory glob sha256sum returned RC 1 because of a directory entry.
- `diff -u v2 v3` (RC 1, expected because the files differ) and a `diff` against the committed DELTAs (RC 0).
- git read-only commands in worktrees/fa72-s11a1 (rev-parse, status, ls-tree, diff --name-only/--quiet, show, merge-base, config, remote -v, log -1), and `rev-parse` / `cat-file -t` in repos/backend.
- `sha256sum` and `stat` on the donor node_modules files, hooks, lock, psql, node and PG17 binaries.
- `grep`/`sed` on the runner, the fixture, rt-setup-fa72efb2.sh, rt-setup.log and its sentinel. `df -k`. `find` to locate rt-setup.log.
- A `tail -1 -n 4` typo produced an error on one line with no effect.

Open risks: none beyond the two C notes.
