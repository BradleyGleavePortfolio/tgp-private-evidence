# S11-A1 builder summary (T2, test-only, real PG)

- **Record:** ACCEPTED S11-0, /home/user/workspace/private-evidence/execution/d3a9f701/s11-0/2026-09-26-s11-journey.md (D-S11-6, D-S11-7, D-S11-8 row S11-A1, §3 J01-J08)
- **Worktree:** /home/user/workspace/worktrees/d3a9-s11a1
- **Branch:** exec-d3a9/s11a1. HEAD is still 92b9671511279254a8545c4cb531bf965762c597, with no commit made.
- **Status:** SOURCE COMPLETE and NOT RUN.
  - No npm, jest, tsc, prisma or postgres was run, no lock was taken, and nothing was committed.
  - The only checks run were `node --check` on the worker (OK), `bash -n` on the bootstrap (OK) and `rg` for the R75 banned tokens (0 hits in all 8 files).
- **Scope:** no `src/**`, `prisma/**` or S10-owned path is touched. `git status` shows only the 8 new files, all untracked.

## Files (sha256, lines, it() count)

| path | sha256 | lines | it() |
| --- | --- | --- | --- |
| test/utils/g2-s11-bootstrap.sh | f95d3015f14ecf8a6af0fca3fe9e5dd3a8c6424bfd8e1a1c839b1368a312efcc | 234 | - |
| test/utils/g2-s11-db.ts | 4edc214fb5a83ca1a525084c3fe84e7dcb43f7f5a2da00e4bf51c21c86324a15 | 163 | - |
| test/utils/g2-s11-harness.ts | 84b20c76823f29d561f4f579be2a783617aba53faf24b99ec4363f3b868243fe | 361 | - |
| test/utils/g2-s11-pg-harness.ts | 8d7c4c68ca0654f5ad581b756f7cbe7523e2a579541526d05d2a4487172efa5c | 260 | - |
| test/utils/g2-s11-worker.cjs | 34203db81f188c44358bd455e8539492240b86f24ab46ca0c2a1f250c42a0075 | 357 | - |
| test/utils/g2-s11-db-guard.spec.ts | 9e143abdb76dd0c586db158c9520f7c651cb31790ecd88c47efd194c7d8b0ed8 | 300 | 10 it + 1 it.each (61 URLs) |
| test/rls-g2-s11.spec.ts | e0e361d888218e7b9c086d8fdf9e3636c420947fe6baa468bea704c6abb50876 | 207 | 6 |
| test/scout/s11/journey-core.pg.spec.ts | 4544cf634bda7cf80fc2894155e5af4480348a56a6dd73b81a03463a6788967b | 620 | 8 (J01-J08) |

The full diff against the substituted donor is saved at /home/user/workspace/s11a1_diff_vs_donor.patch (662 lines).

## Lane (D-S11-6 lane descriptor)

- **Port:** 55648. It is double-entered in the confirmation `g2_s11_disposable:55648` and is not hard-coded as the accepted port.
- **Database and roles:** db `g2_s11_disposable`; admin `s11_super`; runtime `service_role`; migrator `postgres`.
- **Environment:** `G2_S11_*` and `G2_S11_WORKER`.
- **Markers:**
  - cluster `s11-disposable-pg17`;
  - database `s11-g2-journey-multi-host-synthetic-disposable-fixture-safe-to-drop`.
- **Refused ports:** the donor list plus **55646 (S9-C) and 55647 (S10-B)**.
  - The guard also refuses 55649, the s9c and s10b database names, and the s9c/s10b superusers.
- **Base and migrations:** BASE_HEAD = 92b96715…; EXPECTED_MIGRATIONS = 172 (the last is S7-L). S11-A1 ships no migration. The bootstrap requires a prisma tree byte-identical to the base.

## Diff vs donor (g2-s9c-* at 92b96715)

Every file was derived by literal substitution: s9c→s11, S9C→S11, S9-C→S11 and s9c-proof→s11-proof. Remaining line deltas against the substituted donor:

- **db.ts (27 lines):** header; the new database marker; base head 92b96715; 55646 and 55647 refused; the lane comment. The logic is unchanged.
- **pg-harness.ts (31 lines):** header and comments (guard path, S11-A1); `Result.mints` added. The logic is unchanged.
- **bootstrap.sh (30 lines):** header; BASE_HEAD; DB_MARKER; guard path and "S11-A1" comments. The logic is unchanged.
- **worker.cjs (115 lines):**
  - `require` of ExtensionPairService, ScoutRosterService and ScoutEntitiesService, placed before the side-effect spy reset.
  - A synthetic `auth.mintExtensionSessionForCoach` stub that counts `mints` and returns non-JWT strings. This is the only non-real dependency; H-C authentication is out of scope per D-S11-1.
  - `messaging` added to the side-effect load spy keys, because J08 names messaging.
  - ADDED actions:
    - `pair-init` and `pair-redeem` (D-S11-6);
    - `pair-current` and `pair-session`;
    - `progress`: recordProgress, then the new `cached` barrier, then an optional `scout.flush()` of THIS process;
    - `roster` and `entities`.
  - REMOVED actions: `settled`, `report`, `reconstruct`, `run-pass`.
  - Kept actions: start, cancel, fence, ingest, complete, status.
  - All pauses, the head attestation, the instrument Proxy and the registry injection are unchanged.
- **harness.ts (116 lines):**
  - Header.
  - The `intent()` setup label changed from the real slug `truecoach` to the synthetic `SETUP_LABEL = 's11-label'` (D-S11-7(7): no S11 file keys on a platform slug; D-S11-7(1): the label never matters).
  - Appended wrappers:
    - `on(host, role, opts)`;
    - pairInit, pairRedeem, pairCurrent and pairSession;
    - startRun, cancelRun, ingestBatch, completeRun, statusOf, progressOf, progressHeld (paused at `cached`), rosterOf and entitiesOf.
  - Appended readers: `snapshotRows`, `intentRow`, `pairCodeRows`.
  - `host` and `role` are labels only; they appear in the PG17_PROCESS log line and are never a service input.
- **Guard spec:** the donor's 8 blocks, substituted, plus the extra refused entries. It adds 3 static S11 checks:
  1. The worker's action set is exactly the kept + added actions, and the removed actions are gone; the donor's set is also pinned.
  2. No S11 file names a real source slug (derived from `src/scout/reconstruct/sources/*.json` minus `conformance_*`) or a donor lane identity.
  3. The journey spec is inert without the lane and never builds its own harness.

## Deviations needing parent acceptance

D-S11-6 names only pair-init and pair-redeem as added actions. These additions go beyond that:

1. **`pair-current` and `pair-session`.** J01 ("current on P1 showing paired") and J07 (uniform-404 session read) cannot be proven without them.
2. **`progress`.** J03, J04, J07 (cross-coach /progress 204) and the legacy case cannot be proven without it.
   - It re-carries the landed `test/utils/g2-s7l-worker.cjs` `progress` action, split around a `cached` barrier so P1 can hold a pending snapshot.
   - J04's "kill" is `stop()` at `cached`.
3. **`roster` and `entities`.** These are needed for step 11 (native review) and the J07 reconstruct-read 404.
4. **Donor-literal deltas beyond the lane descriptor:**
   - the `messaging` spy key (J08);
   - the synthetic setup label in place of the real `truecoach` slug (D-S11-7(7));
   - `Result.mints`.

If any of these is not accepted, the cases depending on it are J01 (current), J03, J04, J07 and J02's step-11 tail. Per D-S11-6 those cases stop and are re-graded; nothing else changes.

## Run notes (for the parent's real-PG run)

- **`test/rls-g2-s11.spec.ts`** runs via jest.rls.config (testMatch `test/rls-*.spec.ts`).
- **`test/scout/s11/journey-core.pg.spec.ts`** is not matched by jest.rls.config, and it is not ignored by the default config.
  - To keep the default no-DB suite green, it is `describe.skip` unless `G2_S11_DATABASE_URL` is set. This follows the precedent of `scout-entities.rls.live.spec.ts`.
  - It loads the harness lazily in `beforeAll`, so it performs no lane side effects when skipped. With the variable set, the harness import fails closed on any other lane.
  - Run it with the default config and the same G2_S11_* env: `jest --runInBand test/scout/s11/journey-core.pg.spec.ts`.
  - Later slices add `test/scout/s11/*.pg.spec.ts` the same way. D-S11-6 says their cases run "through" rls-g2-s11; I did NOT import the journey file from rls-g2-s11, to avoid running cases twice. Say if you want an import there instead.
- **Isolation:** both S11 specs reset the same lane's rows, and worker application names are `g2g_<n>` per spec process. Run the two files **sequentially**, never in parallel.
- **Guard placement:** the guard is at `test/utils/g2-s11-db-guard.spec.ts`. It is discovered by the default config (roots `test`, `.spec.ts`) and needs no DB.
  - The donor guard lives at `test/scout/g2-s9c-db-guard.spec.ts`; I placed the S11 one where the D-S11-8 owned path names it.
- **Unverified risk:** the worker now `require`s `src/extension-pair/extension-pair.service`, which loads `auth.service` (supabase-js, ws) at import time for the DI metadata. Its side-effect loads are zeroed before any action, like the donor's startup requires. I could not verify that this import is clean in a bare worker without running it.

## What each case asserts

**test/scout/s11/journey-core.pg.spec.ts** (P1 and P2 are distinct forked processes; phone and ext are labels):

- **J01:**
  - init on P1: code and intent id returned, 0 mints; the setup row is unpaired with the synthetic label; current shows `pending`.
  - redeem on P2: synthetic tokens, the label and the intent echoed, 1 mint; the code row is used.
  - A replayed redeem on P1 gives 410 `already_used` with 0 mints.
  - current on P1 is `paired`, and session on P2 equals it.
  - Start on P2 creates exactly one server run (discovering, epoch 1). A replayed Start on P1 is deep-equal, still one run, with the row unchanged.
- **J02 (plus steps 9-11):**
  - Four ingest batches alternate P1/P2 (people, blocks, routines, log tokens), with exactly `{received, deduped:0}` each and 5 staged rows.
  - The open status JSON is byte-equal on P1 and P2.
  - The claim on P1 acks, with exactly one terminal UPDATE, one push, one `scout.run.settled`, a terminal set with state = terminal, and one completion row.
  - A replayed claim on P2 acks with no terminal query, 0 pushes, and the row and completion unchanged.
  - The settled status is byte-equal on both hosts, with status = the row terminal and claimed `success`; reads write nothing.
  - Roster and workouts entities are 200 and byte-equal across hosts; one native program exists.
- **J03 (G2):**
  - P1 posts progress and pauses at `cached` after its gate committed; no mirror row exists.
  - P2 status truth fields are current: running, transferring, `last_observed_at` equal to the DB value, epoch 1, reason null, counts `[{people:1}]`. The mirror is absent (not 0), and no `committed:0` appears.
  - After P1 resumes and flushes: one gate statement, and one mirror row with exactly the posted counts. The next P2 truth is unchanged.
- **J04:**
  - Two batches go P1/P2, then P1 is paused at `cached` and killed; its done rejects.
  - No mirror row exists. P2 truth equals the pre-kill truth except the new `last_observed_at`, with counts `[{people:2}]` and running.
  - The row keeps terminal null, fenced null, epoch 1 and transferring; 2 staged rows remain.
- **J05:**
  - Order 1: the ingest on P1 pauses at `gated` and the cancel on P2 is blocked on the lock (0 staged meanwhile). The batch commits `{received:2}`, then the cancel returns `{cancelled, epoch 2}`; 2 staged rows; the terminal is `cancelled` / `cancelled_by_coach`; exactly one `scout.run.fenced`.
  - Order 2: the cancel on P2 pauses at `locked` and the ingest on P1 is blocked. The cancel wins and the ingest gets 409 `run_fenced` with `fence_reason: cancelled`; 0 staged rows; one fenced event.
  - No 500 or 40P01 on any process. A repeated cancel from P1 is idempotent.
- **J06:**
  - Start on P1 with `deadlineMs: 1`; after 50 ms with no touch the run is still open.
  - Concurrent status reads on P1 and P2 both return `timed_out`, byte-equal, with one `scout.run.fenced` in total.
  - The row is `timed_out` / `timed_out` / fence `timed_out` / epoch 2. A later P2 read is identical, with no new fence and the row unchanged.
- **J07:**
  - A pairs and starts, ingests, and flushes a mirror; B pairs and starts on swapped hosts and ingests. A's state is snapshotted.
  - B on A's intent:
    - status (before any B evidence), start, cancel, pair-session, roster and entities each give 404;
    - each failure deep-equals the same call on a never-owned UUID from the other host (no oracle);
    - no gate statement runs, and A's id never appears in a failure.
  - B /progress on A's intent succeeds (the 204 path) with no gate statement. B settles its own run on P2.
  - A is exactly unchanged: run row, setup row, code rows, staged count, A-keyed mirror rows and total run count.
  - B's later status on that string is either 404 or a non-server projection with no counts, no epoch and no A clock.
  - A's status is byte-equal on both hosts (running, epoch 1).
- **J08:**
  - The collected results cover every action type and both hosts.
  - Every worker has all six side-effect load counters (notifications, drip, assignment, email, billing, messaging) at 0.
  - Only `complete` pushes, and each run has ≤ 1 push in total.
  - A static check confirms the only `pushToUser` in scout.service.ts is addressed to `coachId` with kind `import.complete`.
  - Mints are 1 per successful redeem and 0 per refused redeem.

**test/rls-g2-s11.spec.ts:**

1. Lane identity: PG17 version, cluster marker, data directory, port (not 55646/55647), db, 172 migrations ending at S7-L, S8-B and journey tables present, no supabase roles.
2. Candidate binding: 40-hex, not base, HEAD = candidate, clean tree, descends from base, no prisma diff, **no src diff**.
3. Two hosts: the pairInit, P1 status and P2 status PIDs are distinct from each other and from jest. Uniform 404 on both; the injected families are pinned; each removed donor action gives 500 unknown action; the host label is inert.
4. Role posture: anon and authenticated see 0 rows, or are refused, on ImportIntent, ExtensionPairCode, ScoutImport and ScoutProgressSnapshot while rows exist.
5. J07 legacy case: A gets 404 on the legacy string. B's progress on it writes exactly one B-keyed mirror row with no gate. B's status is a non-server running projection with no counts. A still gets 404 on both hosts, and the run count is unchanged.
6. Legacy settled row: A reads its own legacy success; B gets 404.

**test/utils/g2-s11-db-guard.spec.ts:** no DB. It covers target accept/refuse (61 URLs), confirmation refusal, markers, the fixture-password role set, pins (base, migrations, harness constants), candidate binding plus attestation order, the donor G12 scan, and the 3 S11 shape checks above.
