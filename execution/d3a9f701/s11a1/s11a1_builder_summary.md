# S11-A1 builder summary (T2, test-only, real PG)

- **Record:** ACCEPTED S11-0, /home/user/workspace/private-evidence/execution/d3a9f701/s11-0/2026-09-26-s11-journey.md (D-S11-6, D-S11-7, D-S11-8 row S11-A1, §3 J01-J08)
- **Worktree:** /home/user/workspace/worktrees/d3a9-s11a1
- **Branch:** exec-d3a9/s11a1. HEAD is now 711c1f8f8b42157bca97f2a721557be7ef006667 (S10-A → S10-B a2c74e90 → D1 384035ec → S11-0 doc 711c1f8f); the 8 files remain untracked, with no commit made.
- **Status:** SOURCE COMPLETE and NOT RUN.
  - No npm, jest, tsc, prisma or postgres was run, no lock was taken, and nothing was committed.
  - The only checks run were `node --check` on the worker (OK), `bash -n` on the bootstrap (OK) and `rg` for the R75 banned tokens (0 hits in all 8 files).
- **Scope:** no `src/**`, `prisma/**` or S10-owned path is touched. `git status` shows only the 8 new files, all untracked.

## Files (sha256, lines, it() count) — current after fix 3 (includes the pinned-prettier reflow from devloop-1 of worker, guard, rls and journey)

| path | sha256 | lines | it() |
| --- | --- | --- | --- |
| test/utils/g2-s11-bootstrap.sh | 4520c02889bb8f1d9ad5a9fe2e8ae009677554e9b37312d495b449a327f01abe | 255 | - |
| test/utils/g2-s11-db.ts | 0122b355c91e7ea6ad5dd2599a8ebe0361068fdb1cf4c50cc6ebf727daef66af | 164 | - |
| test/utils/g2-s11-harness.ts | d86ae588abef6673e4f29f799fdf62f33869cce95eb6f2bb08cc76361c5cd514 | 381 | - |
| test/utils/g2-s11-pg-harness.ts | 5e28004c94f77001f83c59ab4c9a88b8ba86527aac9150b8ced8a4d9d75f38e6 | 269 | - |
| test/utils/g2-s11-worker.cjs | 9586346766781319a23b34769026cdb3d1e986adaa8c313f2deab05e8a11ab64 | 412 | - |
| test/utils/g2-s11-db-guard.spec.ts | 4e8c0fee796be2666b565b8e34111df4017869ce0baf3048eec1a615dd7c0c68 | 360 | 10 it + 3 it.each (61 URLs; 20 prohibited ports; 3 controls) |
| test/rls-g2-s11.spec.ts | 923a927d4e84dfa4b9c3949cdf75edb1eb7afab96a0d2dc9325f7ee3fd8ed895 | 250 | 6 |
| test/scout/s11/journey-core.pg.spec.ts | 6a56358aa61e7398b1c58d8f227a2cc1d7d5ea0c35fef8f21ba121e1354770f9 | 691 | 8 (J01-J08) |

The full diff against the substituted donor is saved at /home/user/workspace/s11a1_diff_vs_donor.patch (662 lines).

## Fix 1 (review /home/user/workspace/s11a1_review.md, three class-B findings; delta at /home/user/workspace/s11a1_fix1.diff, 345 lines)

Fix 1 changed 5 files. `db.ts`, `bootstrap.sh` and `rls-g2-s11.spec.ts` are unchanged. Nothing was run; the only checks were `node --check`, `bash -n` and `rg` (0 banned tokens, 0 slugs).

1. **Refused-port guard now discriminates (guard spec).**
   - New `it.each` over the 20 prohibited ports. Each port is paired with its own *matching* confirmation `g2_s11_disposable:<port>`, so only the explicit refused-port set can reject it.
   - New `it.each` positive control: 55648, 55649 and 55650 are each accepted with their matching confirmation.
   - The existing mismatch cases are kept as confirmation tests.
2. **J07 compares A's rows by content (journey spec plus harness reader `stagedRows`).** Before and after B's calls, it compares:
   - A's full staged rows (not just the count);
   - `targetSnapshot(COACH, a)`: persons, programs, plans, evidence, provenance and ledger;
   - A's completion rows.

   B's rows are also checked for isolation:
   - B's staged rows are exactly its own `q-1` batch;
   - neither coach has any staged row under the other's intent;
   - no B provenance row names A's intent;
   - B's ledger is exactly `q-1`;
   - there is no B ledger under A's intent and no A ledger under B's;
   - B has exactly its own completion row.
3. **J08 now observes outbound calls (worker, pg-harness `Result`, harness `outboundTableCounts`, journey J08, guard).**
   - **Channel methods:** after the startup import graph loads, every exported class in the already-loaded notifications, email, messaging, drip, nudge and digest modules has each prototype method replaced by a stand-in that records `{channel, method, recipient}` and then throws.
   - **Transports:** `http.request`/`get`, `https.request`/`get` and `globalThis.fetch` are replaced the same way.
   - **Non-vacuity:** `outboundSpied` lists what was replaced. J08 asserts that it includes `NotificationsService.*` and all four HTTP(S) transport methods.
   - **Pushes asserted on the call:** the injected notifications stand-in records `{userId, kind}`. J08 asserts:
     - `outbound` is `[]` for every result;
     - non-complete actions have `pushCalls` `[]`;
     - every complete push is exactly `{userId: <that run's coach>, kind: 'import.complete'}`;
     - there is ≤ 1 push per run, and at least 2 coach pushes (J02 for coach A, J07 for coach B);
     - `pushes === pushCalls.length`.
   - **Persisted side effects:** the row counts of Notification, NotificationDeliveryLog, Message, MessageDraft, CoachMessage, EmailSendLog, CoachNudge, NudgeLog and DripResolverMarker are unchanged from the file's `beforeAll` baseline.
   - **What was dropped or kept:** the static `pushToUser` source scan is removed. The module-load counters stay, as a supplementary check only.
   - **Guard:** it now pins, in the worker source, that the spies are installed after the load-counter reset and that pushes are recorded on the call.
   - **Unverified risk:** the method stand-ins replace prototype methods on `NotificationsService` and similar classes. The scout path never builds those classes, since it gets the injected stand-in. If any other loaded class in those directories were built on the path, its call would now fail visibly instead of passing silently. That is the intended fail-closed behaviour, but it is still unrun.

## Fix 2: base move to 711c1f8f (delta at /home/user/workspace/s11a1_fix2-base.diff, 297 lines)

Seven files changed; `journey-core.pg.spec.ts` is unchanged. Donor g2-s9c-* files are byte-identical between 92b96715 and 711c1f8f (`git diff --stat` empty), so donor-provenance comments still name 92b96715 ("as landed at"). Nothing was run: only `bash -n`, `node --check` and `rg` (0 banned tokens, 0 slugs).

- **bootstrap.sh:**
  - `BASE_HEAD=711c1f8f8b42157bca97f2a721557be7ef006667`, `EXPECTED_MIGRATIONS=173`, new `S10B_MIGRATION=20270124000000_scout_run_observation_expand` and `S10B_TABLES`.
  - Step 4 requires the S10-B migration file and that the last sorted migration directory is S10-B's (exit 4).
  - Step 5 requires S10-B recorded as applied, and each of ScoutRunDeclaration, ScoutRunObservation and ScoutRunSettledBasis present with `relrowsecurity = t` (exit 5).
  - Step 6 requires the three S10-B models in the generated client (exit 7).
  - Comments updated (173, S10-B client).
  - Tree/blob pins: none exist. The bootstrap pins the prisma tree by `git diff --name-only $BASE_HEAD HEAD -- prisma` being empty, so moving BASE_HEAD moves the pin; there are no separate tree or blob hashes to recompute.
- **pg-harness.ts:** `EXPECTED_MIGRATIONS = 173`, new `S10B_MIGRATION` and `S10B_TABLES` exports; comments updated.
- **db.ts:** `G2_S11_BASE_HEAD = '711c1f8f…'`; header updated.
- **guard spec:** pins the new base, 173, the S10-B migration, `S10B_TABLES` in both files and the last-directory check; the repository order check is now S8-B → S7-L → S10-B as the last three; the non-base candidate test uses the new base.
- **rls spec:** lane identity expects the last applied migration to be S10-B and the three S10-B tables to have RLS on; the anon/authenticated posture loop now also covers the three S10-B tables (refused or 0).
- **Not enumerated in resetData, on purpose:** the S10-B tables carry insert-only triggers that refuse a top-level DELETE and pass only the parent-run `ON DELETE CASCADE` from ScoutImport. resetData already deletes ScoutImport, so direct deletes would fail and are not added.
- harness.ts, worker.cjs: comment-only (donor provenance wording).

## Fix 3: forced RLS and non-vacuous S10-B role reads (review 2; delta at /home/user/workspace/s11a1_fix3.diff, 63 lines)

Applied on top of the post-prettier bytes. Only `bootstrap.sh` and `rls-g2-s11.spec.ts` changed. Nothing was run: only `bash -n` and `rg` (0 banned tokens, 0 slugs).

- **Forced RLS:** the bootstrap (step 5, exit 5) and the rls spec's lane-identity case now require `relrowsecurity/relforcerowsecurity` = `true/true` for each of ScoutRunDeclaration, ScoutRunObservation and ScoutRunSettledBasis.
- **Non-vacuous API-role reads:** the role-posture case now seeds, through the owner path (`sql()`, the postgres owner role):
  - a parent run (`legacyRun(COACH, i, null)`, satisfying the composite FKs);
  - one declaration (valid platform, 64-hex digest, 32-byte challenge);
  - one observation (`clients`, `source_signed_enumeration`);
  - one settled basis.

  It asserts the owner count is ≥ 1 for ImportIntent, ScoutImport, ScoutProgressSnapshot and all three S10-B tables before the anon/authenticated loop. That loop still requires `0` or a permission refusal for every journey and S10-B table. ExtensionPairCode is not seeded by this case, so it is excluded from the ≥ 1 check.
- **Cleanup:** resetData's ScoutImport delete removes the seeded S10-B rows by ON DELETE CASCADE (the nested delete the insert-only triggers allow).

## Lane (D-S11-6 lane descriptor)

- **Port:** 55648. It is double-entered in the confirmation `g2_s11_disposable:55648` and is not hard-coded as the accepted port.
- **Database and roles:** db `g2_s11_disposable`; admin `s11_super`; runtime `service_role`; migrator `postgres`.
- **Environment:** `G2_S11_*` and `G2_S11_WORKER`.
- **Markers:**
  - cluster `s11-disposable-pg17`;
  - database `s11-g2-journey-multi-host-synthetic-disposable-fixture-safe-to-drop`.
- **Refused ports:** the donor list plus **55646 (S9-C) and 55647 (S10-B)**.
  - The guard also refuses 55649, the s9c and s10b database names, and the s9c/s10b superusers.
- **Base and migrations (fix 2):** BASE_HEAD = 711c1f8f…; EXPECTED_MIGRATIONS = 173 (the last is S10-B's 20270124000000_scout_run_observation_expand; S7-L and S8-B precede it). S11-A1 ships no migration. The bootstrap requires a prisma tree byte-identical to the base.

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
  - A is exactly unchanged (fix 1):
    - run row, setup row, code rows, A-keyed mirror rows and total run count;
    - the **full staged rows**, not just the count;
    - `targetSnapshot` (persons, programs, plans, evidence, provenance, ledger);
    - completion rows.
  - B is isolated (fix 1):
    - B's staged rows are exactly its own batch, and neither coach has staged rows under the other's intent;
    - no B provenance row names A's intent, and B's ledger is exactly its own row;
    - there is no cross-intent ledger in either direction;
    - B has exactly its own completion row.
  - B's later status on that string is either 404 or a non-server projection with no counts, no epoch and no A clock.
  - A's status is byte-equal on both hosts (running, epoch 1).
- **J08 (fix 1):**
  - The collected results cover every action type and both hosts.
  - On every process, the recording, throwing stand-ins were installed: `NotificationsService.*` plus the http/https transports appear in `outboundSpied`.
  - `outbound` (observed calls to a notification, email, messaging, drip, nudge or digest method, or to HTTP(S)/fetch) is `[]` for every result.
  - Non-complete actions have `pushCalls` `[]`.
  - Each complete push is asserted on the call as `{userId: run's coach, kind: 'import.complete'}`, with ≤ 1 per run and ≥ 2 in total.
  - The persisted outbound table counts equal the file baseline.
  - The load counters stay at 0, as a supplementary check.
  - Mints are 1 per successful redeem and 0 per refused redeem.

**test/rls-g2-s11.spec.ts:**

1. Lane identity: PG17 version, cluster marker, data directory, port (not 55646/55647), db, 173 migrations ending at S10-B, S8-B and journey tables present, the three S10-B tables present with RLS on, no supabase roles.
2. Candidate binding: 40-hex, not base, HEAD = candidate, clean tree, descends from base, no prisma diff, **no src diff**.
3. Two hosts: the pairInit, P1 status and P2 status PIDs are distinct from each other and from jest. Uniform 404 on both; the injected families are pinned; each removed donor action gives 500 unknown action; the host label is inert.
4. Role posture: anon and authenticated see 0 rows, or are refused, on ImportIntent, ExtensionPairCode, ScoutImport and ScoutProgressSnapshot while rows exist.
5. J07 legacy case: A gets 404 on the legacy string. B's progress on it writes exactly one B-keyed mirror row with no gate. B's status is a non-server running projection with no counts. A still gets 404 on both hosts, and the run count is unchanged.
6. Legacy settled row: A reads its own legacy success; B gets 404.

**test/utils/g2-s11-db-guard.spec.ts:** no DB. It covers target accept/refuse (61 URLs), each prohibited port with its own matching confirmation (20) plus 3 accept controls, confirmation refusal, markers, the fixture-password role set, pins (base, migrations, harness constants), candidate binding plus attestation order, the donor G12 scan, and the 3 S11 shape checks above.
