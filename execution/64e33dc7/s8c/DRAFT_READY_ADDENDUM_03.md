# DRAFT_READY addendum 03 — complete source-only PG proof binding (2026-09-24 21:17 PDT)

Source-only. Nothing executed beyond `bash -n`. No lock taken, no initdb/server/bootstrap/migration/PG/jest/tsc.

## 1. Checkpoint hygiene (C, acknowledged)

`checkpoint/` was refreshed in place once (addendum 02) before the parent's instruction; the original bytes remain recoverable from the durable publication at `7290d871`. From now on every new checkpoint goes to a versioned directory `execution/64e33dc7/s8c/checkpoints/vN/` with its own manifest; sealed paths are never rewritten again. The worktree is unchanged since addendum 02 (manifest `CHECKPOINT_MANIFEST.sha256` still verifies), so no new checkpoint version was created by this addendum.

## 2. Binding files — `execution/64e33dc7/s8c/binding/` (sha256 in `BINDING.sha256.unfilled`)

| file | sha256 | role |
|---|---|---|
| `s8c-pg-proof.sh` | `377c39223e2bce942af8e77fae86909cfe0bf9e6c49c0f6faf6d40936cfd4a78` | complete one-run orchestration (unfilled head pins; refuses to run) |
| `s8c-fixture.sh` | `1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3` | lock-free lane helper init/start/stop/status/destroy |
| `PINS.txt` | `e45e9929d7e692fcd24f9168982576c2a3a8bb9dead71ad5b5a8cc847030678e` | all pins + fill procedure |
| `README.md` | `c419d4d15be6bfb524d7bc9387ebc86fc2bbc1b5453f7e43c6267df9edbfa89d` | order and scope |

Derived by substitution from the accepted `execution/ce3748cb/s8b/binding/{s8b-pg-proof.sh,s8b-fixture.sh}` with the EXEC-64E33DC7 deltas. What the runner covers, per the parent's list:

- **Candidate pins**: `EXPECT_HEAD`, `EXPECT_TREE`, blobs of the six committed proof files (`rls-g2-s8c.spec.ts`, `g2-s8c-bootstrap.sh`, `g2-s8c-db.ts`, `g2-s8c-pg-harness.ts`, `g2-s8c-harness.ts`, `g2-s8c-worker.cjs`), `EXPECT_FIXTURE_SHA` — nine `__FILL_AFTER_ATTESTATION__` values; the runner refuses while any is unfilled and refuses `EXPECT_HEAD == base`. `G2_S8C_CANDIDATE_HEAD` is exported as `EXPECT_HEAD`, so the committed guard (`g2S8cCandidateHead`), bootstrap (`CANDIDATE_HEAD=` line checked in the log) and worker all re-bind to the same head. Base ancestry, base tree `a315dd65…`, clean worktree (`--untracked-files=all`), no `MERGE_HEAD`, lefthook hooks present, prisma tree identical to base, accepted S8-B/sidecar/schema/migration/`jest.rls.config.js` blobs unchanged (blob ids embedded, listed in PINS.txt), native writer files present, no native sidecar dir.
- **Nonblocking canonical flock held through cleanup**: `exec 9>>$LOCK; flock -n 9` before any state change (refuses rc 75 if busy or if the lock file is absent — never created/deleted here); held until process exit, i.e. through stop, post, receipt hashing and sentinel write; `LOCK_INODE` recorded in START/PREFLIGHT/POST/sentinel lines. Children never inherit fd 9 (`9>&-` in the fixture).
- **Fresh cluster/socket/data paths**: `recovery-reset/clusters/s8-c/pg-data`, socket `recovery-reset/run/s8-c`, binaries `recovery-reset/pg17/dist`; fixture refuses data paths inside `pg17/dist` or under `/home/user/pg17`; fresh-init-only (lane dir must be absent, socket dir empty); other lanes under `recovery-reset/clusters/*` are hashed (postgresql.conf + pg_control) pre/post, must have no `postmaster.pid`, and are never started; port 55642 must be free and `pgrep -cx postgres` must be 0 before start.
- **Tool hashes**: postgres/initdb/pg_ctl (runtime receipt pins), `readlink -f /usr/bin/psql` 18.6, node v20.20.1 binary, donor `node_modules/.package-lock.json`, generated client `index.d.ts` (`b6716a86…`, unchanged since S8-C ships no schema change — checked before and after the proof), `schema.prisma` `77f33bcd…`, `package-lock.json` `b7fed5ed…`, `pg17/PROVENANCE.txt result=success`; jest/ts-node/prisma versions logged.
- **Timeouts**: per-stage `timeout -k 30` — init 60, start 60, bootstrap 900, identity 5×15, jest 1500, stop 75 (soft sum 2670 s); outer `timeout -k 30 3600`.
- **Cleanup**: first nonzero stops; if this run started the postmaster, one bounded fast stop is attempted and its rc, `pgrep -cx postgres`, port listener count and any survivor pid are logged; a "successful" stop with a live postmaster is rc 4 (never recorded clean). Data dir retained; `destroy` is a separate marker-gated command that never discards a stop failure. No autonomous cleanup is guaranteed if the outer timeout kills bash — the terminal evidence governs.
- **Result receipt**: `binding/run/s8c-pg-proof.log`, `run/jest.log`, `run/RECEIPTS.sha256`, sentinel `run/s8c-pg-proof.sentinel` = `RC= STAGE= END= HEAD= LOCK_INODE=`; once-only (sentinel present → rc 76, no retry). Jest summary lines and any guard-refusal strings (including the new candidate-binding refusals) are echoed into the main log.
- **Identity gate before the proof**: `data_directory`, `server_version_num=170006`, `cluster_name=s8c-disposable-pg17`, DB comment marker, `_prisma_migrations` applied = 171 — all via psql with `PGPASSWORD`, never a URL password.

## 3. Pin fill procedure (after commit + two attestations)

Documented in `PINS.txt`: nine read-only `git rev-parse` / `sha256sum` values from the attested head; fill by sed of exactly those placeholders; record filled runner sha256 and unfilled→filled diff as `BINDING.sha256` before the PG grant. Nothing else in the runner changes between review and run.

## 4. Status

Queued for the heavy source-gate slot (S7-L active lock). Binding prepared without execution, ready for dual review. Idle until explicit relay.
