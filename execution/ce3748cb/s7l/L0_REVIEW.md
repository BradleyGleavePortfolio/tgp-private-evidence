# S7-L0 independent review (T4, not the author) — `docs/decisions/2026-09-24-s7l-run-lifecycle.md` @ f12661af

Verdict: **ACCEPT** as the S7-L1/L2/L3 build contract, with two class-B doc amendments (B1, B2 below) that must land in
one hooked docs-only commit on `s7-l` before S7-L2 (`LifecycleService`) starts. Neither blocks S7-L1 SQL/harness drafting;
B1 can additionally be enforced in the still-uncommitted L1 SQL at zero cost. No A findings. No rerun, no new harness.

Read-only review: `git show` on `c7a5fe8d`, `61b93cff`, `f12661af` (backend), `1ebbed7` (context PLAN), mobile `c7641cb3`,
extension `aa0abd83`; grants, brief, `DRAFT_READY.md`, receipt `04-commit-l0.txt`. Nothing edited, run or pushed.

## 1. Identity / provenance (verified)
- Commit `f12661af` parent `61b93cff`; author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`; raw object
  has no trailers (`git cat-file -p`); one file, +244 lines; blob sha256 `922cff80…2fff` = DRAFT_READY table.
- Receipt 04 shows lefthook v2.1.9 pre-commit (prod-readiness-quick, banned-cast-tokens, prettier, tsc) and commit-msg
  (no-ai-tokens) all ✔, hooks path = shared `repos/growth-project-backend/.git/hooks`, no `core.hooksPath` override in the
  worktree. Consistent with "genuine hooks, not bypassed".
- Parent freeze honoured verbatim: 300 000 ms lazy deadline / no timer (D-S7L-3), arbiter default
  `partial/reconciliation_not_performed` until S9 (D-S7L-2 step 4, §8), lineage `2.0.0-c1-s2.0` (§7), no new flag (§0, §6).

## 2. Cited source facts (all checked at c7a5fe8d unless noted)
Accurate: `FEATURE_GATED_ROUTES` `/api/scout`→`FEATURE_SCOUT_INGEST` L22; `SCOUT_TERMINAL_STATUSES` dto L109;
read vocabulary + "deliberately absent" dto L154-159; `/complete` `$transaction` ledger-first + upsert L263-293, P2002 no-op
L295-301; `projectReadStatus` unknown→`failed` L384-397; controller `progress` L70 / `ingest/complete` L90 /
`import/status` L126; ingest `createMany({skipDuplicates})` with no run gate L65-95; ADR 2026-07-15 L69-71; C1 doc L29-30,
L65-69; `ConflictException({code,message})` extension-pair L88-89; `source=extension` auth.service L191/L250;
`migration-dry-run.yml` L85-93; PLAN L243-253 and decisions 2/4/5/6 at L261-268; extension `ext-${Date.now()}` L579 /
`imp-${Date.now()}` L825; mobile `decodeTerminalStatus` → `'unknown'` L155-160; no `import/status` caller in either
client repo; `ImportIntent @@unique([id, coach_id])`, `ExtensionPairCode` composite FK `ON DELETE CASCADE` (C1 migration).

Inaccuracies (all C, record only):
- C1. Path typo: `src/common/feature-flag-not-found.middleware.ts` → actual `src/common/feature-flag/feature-flag-not-found.middleware.ts` (line 22 correct).
- C2. Reader-gate line refs (`scout-reconstruct.service.ts` L138-148, `scout-entities.service.ts` L99-105) are exact at
  N/Q1 `61b93cff`, not at `c7a5fe8d` as the preamble states (there: L138-142 and L98-100; same code, ranges overlap).
- C3. §1/§7 "mixed-version `/complete` from an old pod fails closed": true only for claim `success`. An old pod writing
  claim `partial` or `failed` onto a `mode='server'` row passes the shape CHECK (both words are in both vocabularies) and
  would set `terminal_status` directly, bypassing the arbiter (no `reason_code`, phase left open). Harmless today (routes
  dark, rollout-order rule already recorded) but the doc's "fails closed" wording overstates. Fix wording; keep rule.
- C4. §8 L8 "owner erasure fails closed while a server run exists": the live GDPR flow tombstones the User row and never
  hard-deletes it (`account-deletion.service.ts` L831-846: "We do NOT DELETE the row"), so the `User→ImportIntent` cascade
  never fires from erasure and `ON DELETE RESTRICT` has no effect on the current product path. The seam is about a
  hypothetical hard-delete only; say so. RESTRICT remains a reversible metadata-only choice; not an L8 pre-emption.

## 3. State machine — completeness and determinism
Holds:
- Single terminal arbiter for server mode (`arbitrate()` only; `cancel`/`timed_out`/`revoked` all route through it);
  `cancelled` and `timed_out` are first-class terminals and appear in the widened `status` enum.
- Extension claim demoted: stored in `ScoutImportCompletion`, projected as `claimed_status`, used only as arbiter input
  (step 2, `failed` with zero staged rows). `complete` is unreachable without an S9 verdict (step 3), so "never complete
  without reconciliation" is structurally true, and §9 requires the arbiter table to prove every fence/claim/verdict cell.
- Legacy byte-identity: non-UUID `intent_id` skips the gate entirely; old extension builds never call Start; legacy
  `/complete` upsert path unchanged; `import/status` additive and un-called by clients; `state` keeps mirroring
  `terminal_status`. `success` only on legacy rows / `complete` only on server rows is a clean CQ-18 marker.
- Tenant scoping: `import_intent_id` is a composite FK to `ImportIntent(id, coach_id)`; Start/cancel on unowned intents are
  uniform 404; foreign UUIDs from another coach fall to that coach's own legacy namespace (`(coach_id, intent_id)` key), so
  no cross-tenant collision or oracle.
- Authority: `revoked` reserved, `fence(…,'revoked')` exported with no route/principal; extension bearer stays the coach
  token; no G3-AUTH or L8 decision is made. Owner-reserved boundary (main/deploy/flag) restated in §9.

Findings:

**B1 — identity binding not listed as an invariant (contract gap; L1/L2 could satisfy the doc while diverging).**
D-S7L-1 defines `server ⇔ intent_id is the text form of import_intent_id`, but §4 invariant 2 (the "persisted by S7-L1"
list) omits `mode='server' ⇒ intent_id = import_intent_id::text`, and the draft L1 shape CHECK does not enforce it. Every
writer resolves the run by text `(coach_id, intent_id)` while Start/uniqueness key on the UUID; unbound, a Start could
create a server row whose text key differs from the UUID the extension will send, turning the run into permanent
`409 run_not_started`/legacy-path ambiguity. Also unspecified: `/complete` and `/progress` on an owned UUID with no run
(table has rows only for open/fenced/terminal), and the 409 precedence for Start when both `superseded_at` is set and a
terminal run exists.
- Harm: non-deterministic run identity between the two keys; S7-L2 specs could pass with a latent mismatch.
- Blocked: S7-L2 `LifecycleService` start/assertRunOpen implementation only.
- Minimum closure: add to invariant 2 `mode='server' ⇒ intent_id = import_intent_id::text` (persist as one more predicate
  in `ScoutImport_mode_shape_check` while L1 is uncommitted); add two table rows (`/complete`, `/progress` on owned UUID
  without run → 409 `run_not_started` / 204 ignored — author's choice, but stated); state Start guard order
  (owned → paired → superseded → run-terminal → run-open). Docs-only + one SQL predicate; L01 catalog string in the L1
  harness updates accordingly.

**B2 — §3.1 lock discipline is self-blocking on the lazy deadline and deadlock-prone for concurrent writers.**
As written, `assertRunOpen` takes `SELECT … FOR SHARE` inside the writer's transaction and, when `now() > deadline_at`,
fences `timed_out` "in a separate short transaction, then 409". Under Prisma interactive transactions the writer's
connection still holds the FOR SHARE row lock, so the separate fence transaction's `FOR UPDATE` waits on the writer, which
waits on the fence → hang until `lock_timeout`, never a clean 409. Independently, two concurrent writers (ingest batch and
the 5 s `/progress` flush both write `last_observed_at`) each holding FOR SHARE and then issuing the CAS UPDATE on the same
run row is the textbook PG share-lock upgrade deadlock (40P01) → spurious 500s under normal extension traffic.
- Harm: lazy-deadline path stalls instead of fencing; concurrent ingest/progress can abort with deadlock errors on a live
  server run (after activation only; dark today).
- Blocked: S7-L2 `assertRunOpen`/fence implementation and PG proofs L08/L10 as specified.
- Minimum closure (doc paragraph in §3.1, no new artefact): (a) gate with `FOR NO KEY UPDATE` (or make the CAS UPDATE of
  `last_observed_at`/`phase` the first statement, which is the gate and the lock in one) so writers on one run serialize
  briefly instead of deadlocking; (b) deadline fence ordering: the writer's own transaction is rolled back (or itself
  commits the fence without inserting rows) before/instead of a second connection acquiring the row; (c) add "concurrent
  ingest + progress on one run" to L08's barrier cases. The PLAN L251 guarantee (commit-before-fence or observe-fence) is
  preserved by either variant.

Class C (record / qualify / continue):
- C5. D-S7L-2 step 1 says fence `revoked` → "that outcome", but `revoked` is not a terminal; the table maps it to `blocked`
  with `reason_code='revoked'`. State the mapping once.
- C6. "Enforced lazily on every mutation and read" vs invariant 5 "no reader change": roster/entity readers and
  `POST /scout/reconstruct` gate on `terminal_status IS NOT NULL` and do not fence, so a past-deadline server run that no
  lifecycle route has touched is not yet reviewable (CQ-03) until the next `import/status`/mutation fences it. Say
  explicitly which routes apply the lazy fence; UX polling makes this moot in practice.
- C7. `/complete` push (`notifyComplete`, scout.service L403-418) carries the raw claim as `terminal_status` in the push
  payload; for server runs the doc is silent on whether the push (copy already says "Migration is not verified") carries
  the claim or the arbiter terminal. Decide in S7-L2; recommend arbiter terminal + `claimed_status`.
- C8. `/complete` on an already fenced run: table says "none" writes, so the claim is not stored and `claimed_status`
  stays null — consistent, but D-S7L-2's "claim is stored unchanged" is then conditional; note it.
- C9. Start has no stated throttle (cancel 30/min). Add one number in S7-L2.
- C10. Because every fence immediately arbitrates, an open run always has `execution_epoch=1` and epochs only reach 2;
  "monotonic" is correct but the field is effectively a fenced flag. Fine as designed (S8-G may later fence without
  terminal); no change requested.
- C11 (from DRAFT_READY, verified by reading L1 SQL, out of scope otherwise): non-partial unique on `import_intent_id`,
  the pair CHECK and `deadline_at > accepted_start_at` all match §4 invariants 2/4/7; the doc/SQL are consistent.

## 4. Decision
ACCEPT the L0 contract. Required before S7-L2 activation: one docs-only hooked commit on `s7-l` applying B1 and B2 (plus
the C1/C3/C4/C5 wording fixes if the author is already in the file). Optional zero-cost: fold the B1 predicate into the
uncommitted `ScoutImport_mode_shape_check`. Execution unlocked now: S7-L1 SQL/harness drafting continues unchanged;
schema hunk + PG waits on the accepted C head per grant; S7-L2 starts after the B1/B2 amendment.

## 5. Delta review of closure commit 7f14a304 (parent f12661af) — FINAL ACCEPT

Verified: HEAD `7f14a304`, author = committer Bradley, no trailers, second commit (no amend); doc 286 lines, sha256
`b581a30b…17ea` = DRAFT_READY amendment; receipt 05 shows pre-commit (65.7 s incl. tsc) + commit-msg ran, `commit_rc=0`,
no bypass. Only the doc changed in the commit; L1 drafts remain uncommitted (mirrored CHECK predicate
`"intent_id" = "import_intent_id"::text` confirmed in `migration.sql` L144).

B1 closed: D-S7L-1 and invariant 2 persist `intent_id = import_intent_id::text`; Start row writes the text key; guard
order stated (owned → paired → not superseded → no terminal run → no open run, with 404/`intent_not_paired`/
`intent_superseded` taking precedence over `run_terminal`); explicit rows for `/complete` (409 `run_not_started`) and
`/progress` (204, no write) on an owned UUID with no run.

B2 closed: gate is the writer's first statement, a row-locking UPDATE with the open-run predicate (`terminal_status IS
NULL AND fenced_at IS NULL AND deadline_at > now()`), no `FOR SHARE`, no lock upgrade; zero rows → writer tx rolled back
before an unlocked re-read and classification; the deadline fence runs in its own tx with `FOR NO KEY UPDATE` only after
the writer released the row (no self-wait). Lock semantics check out: UPDATE's row lock conflicts with the fence's
`FOR NO KEY UPDATE`, so a fence waits for the writer's commit; a writer blocked behind a committed fence re-evaluates the
WHERE under READ COMMITTED and gets zero rows → 409 `run_fenced`. PLAN L251 preserved. CAS predicate adds
`fenced_at IS NULL`; L08/L10 and the L1 SQL-level serialization check now name the cases.

C fixes verified: middleware path (C1), mixed-version claims (C3), erasure seam wording with the tombstone fact (C4),
`revoked`→`blocked` (C5), lazy-fence route list (C6), claim-stored-only-when-accepted (C8).

No new A/B. One new C (record only): the binding compares text keys, and `uuid::text` renders lowercase, so an extension
sending an upper-case UUID resolves to "owned intent, no row" → 409 `run_not_started` (fail-closed, deterministic; the
new spec's case-changed-UUID refusal covers the persisted side). S7-L2 should lowercase-normalise or reject non-canonical
UUIDs at the DTO so the failure names the real cause. C7 (push payload for server runs) and C9 (Start throttle) remain
open S7-L2 decisions, not blockers.

**FINAL ACCEPT** of S7-L0 at `7f14a304`. S7-L2 unblocked (after the accepted C head / S7-L1 schema hunk per grant).
