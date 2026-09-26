# S8-D/E + D-S8-LINK decision record — T4 author report (EXEC-FA72EFB2)

Grant: `execution/fa72efb2/s8d/S8D_DECISION_RECORD_GRANT.md`. Rules: `execution/fa72efb2/WORKER_RULES.md`.
Authority: `execution/fa72efb2/OWNER_DECISION_S8D_2026-09-26.md` (OFFICIAL D-S8-2 option (a) + D-S8-LINK L1–L8,
Bradley 17:44Z). Docs only: no `.ts`, no `prisma/**`, no PostgreSQL, no push. Nothing was run in node_modules.

## Deliverable

| Item | Value |
| --- | --- |
| Clone | `/home/user/workspace/worktrees/fa72-s8d`, branch `fa72/s8d`, base `dda794d7e8bee0482a7ad373795fcc51dcf54bb5` (S11-B r2), cloned from `worktrees/fa72-s11b` (has dda794d7), push URL `no_push://disabled-fa72efb2`, user/email Bradley Gleave `<bradley@bradleytgpcoaching.com>`, `node_modules` = `cp -al` of `worktrees/fa72-s11a1/node_modules` (649 entries), lefthook hooks synced (pre-commit, commit-msg). |
| New doc | `docs/decisions/2026-09-26-s8d-person-link.md` — 544 lines, sha256 `c11017baa5ee1d77fffc714cc257b470f50dc24111beecb076b684b751a6a4c8` |
| Edited doc | `docs/decisions/2026-09-24-s8-native-contract.md` — +8 lines APPENDED as a new `## 7. Forward pointer` (sha256 `40645a56675856ec39a072149d3e629f301ce09cd28f1def0191db8d48f39561`). Appended at the end, not inserted at D-S8-2, because 47 places in `src/**` and `docs/**` cite `S8-DOC Lx` by line number and a mid-file insertion would have shifted them. Parent may drop this hunk if unwanted (grant: "only if its own text says it is the contract" — S8-DOC L3-5 "binds the S8-A…S8-F build slices", L507 "§4.1 and §4.5 are their starting contracts"). |
| Production LOC | 0 (docs only). |
| Commit | `ded755ab7626f3791b1d927095810658aef9893f` on `fa72/s8d`, parent `dda794d7e8bee0482a7ad373795fcc51dcf54bb5`, tree `b7b070e1e811f6bdb1c655b43a504e41f553e2ae`; author = committer = Bradley Gleave `<bradley@bradleytgpcoaching.com>`; no trailers; 2 files, +552; not pushed (push URL disabled). |

## Summary of the record

1. **Decision** — Bradley's verbatim text (17:44Z) and D-S8-2 (a) + L1–L8 reproduced unchanged; supersession table against
   S8-DOC (interim L72-74, reserved (a) L84-89, §4.1 qualifier L372-374, §4.5 L440-462, D-S8-3 L102, D2 comment
   `schema.prisma` L6943-6950). Nothing else in S8-DOC touched.
2. **Data model** — five client-owned tables get nullable `person_id` beside a now-nullable User FK with a hand-written
   XOR CHECK (`WorkoutSession` L864-865, `WeightLog` L932-933, `Habit` L1038-1039, `CheckIn` L1104-1105 + partial unique
   `(person_id,date)` for L1129, `ClientWorkoutAssignment` L2327-2328); children (`ExerciseSet`, `HabitLog`, snapshot)
   inherit. RLS: existing `user_id = app.current_user_id()` policies fail closed on NULL (rls_fitness_backend.sql
   L136-146); Person/invite/link tables stay service_role-only (20261223000200 L76-86). `Person.linked_user_id`
   (indexed, not unique). New `PersonInvite` (token hash, coach-confirmed contacts held on the invite and scrubbed at
   terminal, one open per Person), `PersonInviteChallenge` (6-digit HMAC code, 5-attempt lockout — the ExtensionPairCode
   precedent L6748-6751 / service L41, L319-327, L389-391), `PersonLink` (written in the link transaction = primary audit;
   `AuditService.write` swallows errors L168-172/L185-215 so it is secondary; 30-day `undo_deadline_at`; per-Person
   active-link partial unique). "Imported" := has an `ImportNativeProvenance` row; new `provenance.person_id` (set at
   import, never cleared) drives return-on-unlink. Person state transition table; link/unlink transaction steps under a
   Person `FOR UPDATE`; idempotency/race table (two claims, claim vs unlink, claim vs import, claim vs revoke, re-mint).
3. **Link flow** — reuse: signup (`auth.service.ts` L88-157, L900-944), `assertCoachCanAcceptClients` L65-76, email
   transport/template (`email.types.ts` L16, `_sendInviteEmail` L793-832), notifications (L297-301), attach semantics
   L606-609. Not reused: `InviteCode` (`intended_email` login-email match L583-592 = email-as-key, checked before the
   email is verified since `register` returns `requires_verification` L150-156 and `signupWithCode` attaches at L928-936;
   30-bit code; distinguishing messages in `acceptByToken` L886-903). Supabase magiclink/verifyOtp (L333-355) not
   applicable (verifies the login email). **No SMS transport exists** (only `redact-secrets.ts` L52) → phone channel is a
   separate owner-gated slice. Endpoints and minimum disclosure per step (pre-verification: coach card + masked
   channels only; post-verification: Person display name + per-family counts/date ranges; never row contents).
4. **Threat model** — forwarded invite, contact change, coach mistake, malicious coach, enumeration, replay, race,
   cross-tenant, contact PII at rest, audit loss, privilege — each with its rail (table in §4 of the record).
5. **Roster** — D2 finding chain re-grounded at dda794d7 (`families.ts` L83-102/L157-158 → `scout-reconstruct.service.ts`
   L510-520 → `reconcile.ts` L60-61/L136-146); everything downstream already admits `person` (CHECKs 20270122 L141/L191,
   `persist-outcome.ts` L16, `types.ts` L83-87, `readPersons` L1003-1015). S8-D1 = typed `person` handoff + provenance
   row; plus Deleted→removed in `readPersons` (L1010-1012). Coach roster contract: sibling `imported_people[]`
   ("imported, not yet joined"), `person_link` marker on the client row while undo is open; importer-G reader drops
   `roster_bridge_pending` (dto L42, service L175-178, facts L145-148).
6. **Slice plan** — below. Migration sequencing pinned to the S11 lane facts: `EXPECTED_MIGRATIONS = 173`
   (`g2-s11-pg-harness.ts` L39; `g2-s11-bootstrap.sh` L36, L159-160), last dir must be S10-B's (bootstrap L164-165),
   prisma tree byte-identical to `711c1f8f` (bootstrap L150-156; guard spec L194-195, L220-222). 173 directories present
   in the tree.

## Slice table

| Slice | Scope | Grade | Depends on | Migration | Prod LOC | Ruling |
| --- | --- | --- | --- | --- | --- | --- |
| S8-D0 | Decision record (+ S8-DOC forward pointer) | T4 | OWNER | no | 0 | this commit |
| S8-D1 | Typed `person` handoff + provenance for `clients`; `readPersons` Deleted→removed | T3 | S11-A2 landed | no | 150–250 | PROCEED |
| S8-D2 | Coach roster `imported_people[]` + `person_link`; retire `roster_bridge_pending`; contract regen; suggestions (read-only) | T3 | S8-D1 | no | 250–400 | PROCEED |
| S8-D3 | Schema: `Person.linked_user_id`; `PersonInvite`, `PersonInviteChallenge`, `PersonLink`; `provenance.person_id`; nullable owner + `person_id` + XOR CHECK + indexes on 5 tables; RLS; type ripple (16/10/5/19/8 non-spec files touch the models) | T4 | S11-A2 + S11-D proofs landed, or explicit re-pin | yes (1 dir) | 450–650 | PROCEED |
| S8-D4a | Invite mint/list/revoke/send (email)/public preview; InvitePending↔Invited; audit | T4 | S8-D3 | no | 350–450 | PROCEED |
| S8-D4b | Email OTP challenge/verify/disclosure/confirm; link transaction incl. CheckIn collision; notifications; race specs | T4 | S8-D4a | no | 450–600 | PROCEED (split from ~900–1,000) |
| S8-D5 | Unlink (client, coach ≤30d, admin); return-only-imported; notifications | T4 | S8-D4b | no | 300–450 | PROCEED |
| S8-D6 | L5 coach-approved match + L8 merge | T4 | S8-D5; OQ-1, OQ-6 | no | 300–450 | PROCEED |
| S8-D7 | Phone channel (SMS transport + phone OTP) | T4 | owner spending/provider decision | no | 200–300 | BLOCKED (owner) |
| S8-E1a | `WorkoutSession`+`ExerciseSet` person-owned writer; CHECK expand for new kinds | T4 | S8-D3, S8-D1 | yes (CHECK) | 300–450 | PROCEED |
| S8-E1b | `WeightLog` + `CheckIn` writers (explicit `reviewed_by_coach` amendment) | T4 | S8-E1a | no | 250–350 | PROCEED |
| S8-E1c | `Habit` + `HabitLog` writer | T3 | S8-E1a | no | 150–250 | PROCEED |
| S8-E1d | `ClientWorkoutAssignment` inactive import | T4 | S8-E1a; OQ-12 | no | 150–250 | PROCEED after OQ-12 |
| UX-D2 | Mobile roster imported rows + label + Invite form + invite list | T2 | S8-D2, S8-D4a | — | 300–500 | PROCEED |
| UX-D4 | Mobile client claim screens (preview→verify→disclosure→yes/no) | T3 | S8-D4b | — | 300–450 | PROCEED |
| UX-D5 | Mobile undo affordances + notification copy | T2 | S8-D5 | — | 150–250 | PROCEED |
| UX-EXT | Extension: none required; optional readiness count from server | T1 | S8-D2 | — | ≤50 | OPTIONAL |

No slice exceeds 1,000 LOC after splitting D4 and E1. Owner boundaries unchanged (production, `FEATURE_*` values,
live accounts, G3-AUTH, CWS, branch protection, S8-D7 spending).

## Threat-model summary

| Threat | Rail |
| --- | --- |
| Forwarded invite / takeover | Link claims nothing alone; OTP to a coach-confirmed contact (claimant cannot supply one — enum-only body); explicit "is this you?"; 30-day undo + coach notified. |
| Contact change / wrong contact | Coach confirms contact at mint; pre-verification page discloses only coach card + masked channels; revoke/re-mint any time. |
| Coach mistake | Two-sided confirmation; both sides unlink ≤30d; only imported rows return; `records_moved` visible. |
| Malicious coach | Cross-tenant impossible (`person.coach_id` must equal user's coach or user unattached; link never changes an existing `coach_id`); client confirmation; minimum disclosure (OQ-10). |
| Enumeration | ≥128-bit hashed token; uniform `{valid:false}`; 6-digit code behind TTL + per-row lockout 5 + per-IP throttle + constant-time compare (pairing precedent L378-388); uniform 404 posture as roster reader L85-97. |
| Replay | Idempotent confirm (returns existing link); single-use invite via `updateMany WHERE status='open'`; email idempotency key per invite; single `verified_at`. |
| Race | Person `FOR UPDATE` serialises all transitions; S8-E writer reads Person under lock and writes to the linked user directly when Claimed; serialization retries exist (S11-B r2). |
| Cross-tenant data movement | `coach_id` from token everywhere; `PersonLink.coach_id = person.coach_id`; unlink join requires `provenance.coach_id = person.coach_id`; service_role-only RLS on all new tables. |
| Contact PII / audit loss / privilege | Contacts only on invite, scrubbed at terminal; digest on link; `PersonLink` in-transaction = primary audit; owners/coach-role refused as today (L563-568). |

## Open questions for Bradley (recorded in §7 of the record, not decided)

1. **OQ-1** L6 "one Person ↔ one account per coach" vs L8 two-platform merge (two Persons → one account). Recommended DB rail: per-Person uniqueness absolute; per-(coach,user) uniqueness except `path='merge'`.
2. **OQ-2** Imported rows edited while linked return to the Person with edits — acceptable?
3. **OQ-3** `CheckIn` (user_id,date) collision on link: leave with Person + count `skipped` (proposed) vs refuse the link.
4. **OQ-4** Claimant attached to another coach → refused (proposed); coach-role users never linkable.
5. **OQ-5** TTLs: invite 14d, code 10min, verified window 15min, lockout 5.
6. **OQ-6** Does L5 (already-a-client) also require the one-time code? Proposed: in-app confirmation only.
7. **OQ-7** Account deletion inside the 30-day window: return imported rows first, or delete with the account? Erasure of a Claimed Person while linked?
8. **OQ-8** What sets/clears `Suspended` (no code sets it today).
9. **OQ-9** Notes/goals/measurements/profile have no person-capable native table.
10. **OQ-10** Disclosure before "yes": display name + per-family counts/date ranges — too much or too little?
11. **OQ-11** `Person.display_name` overwrite on replay (`families.ts` L98) vs D-S8-4 create-only once `person` carries provenance.
12. **OQ-12** Define "inactive" for imported `ClientWorkoutAssignment` (no flag exists, L2323-2358).
13. **OQ-13** Phone provider = spending (no SMS transport exists).

Findings classification: all C (recorded, qualified, execution continues). No A/B: nothing here blocks a landed decision;
the D2 product finding (roster runs cannot settle `complete`) is already recorded by the parent and is closed by S8-D1.

## Commands run (clone `/home/user/workspace/worktrees/fa72-s8d` unless noted) and RC

| # | Command | RC |
| --- | --- | --- |
| 1 | `git clone -q --no-hardlinks worktrees/fa72-s11b fa72-s8d && git checkout -q -b fa72/s8d dda794d7…; git remote set-url --push origin no_push://disabled-fa72efb2; git config user.name/email (Bradley)` | 0 |
| 2 | `cp -al worktrees/fa72-s11a1/node_modules ./node_modules` (649 entries) ; `npx --no-install lefthook install` → "sync hooks: ✔️ (pre-commit, commit-msg)" | 0 |
| 3 | Read-only: `sed -n`/`nl`/`rg`/`cat -n` over schema.prisma, migrations, src/invite-codes, src/invite-landing, src/auth, src/extension-pair, src/audit, src/notifications, src/scout/**, src/coach, src/account-deletion, test/utils/g2-s11-*, docs/decisions/*; `ls -d prisma/migrations/*/ \| wc -l` = 173 | 0 |
| 4 | `prettier --version` (3.9.9 from runtime/tools) ; `prettier --check` both docs → first run RC=1 (table padding; an unescaped `\|` inside inline code in one cell was mis-split) | 1 |
| 5 | `prettier --write docs/decisions/2026-09-26-s8d-person-link.md` ×3 (padding only; the one mis-split cell rewritten to avoid the pipe); whitespace-normalised diff vs the pre-prettier copy = intended edits only | 0 |
| 6 | `prettier --check docs/decisions/2026-09-26-s8d-person-link.md docs/decisions/2026-09-24-s8-native-contract.md` → "All matched files use Prettier code style!" | 0 |
| 7 | `git add` both docs; `git diff --cached --stat` = 2 files, +550 (later +552) | 0 |
| 8 | `git checkout -- docs/decisions/2026-09-24-s8-native-contract.md` (reverted my first, mid-file pointer insertion before re-adding it as an appended §7) | 0 |
| 9 | `ls /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE` → absent at 18:0xZ (present at 17:42Z when the grant was read) | 2 |

Disclosure: one `flock -n …lock -c 'echo'` probe was run once to see whether the heavy slot was free (result: held). It
did not acquire or steal the lock, but WORKER_RULES §3 says not to probe with `-n`; it was not repeated. No heavy
command was run; no `tsc`, `jest`, `eslint`, generator, or PG.

## Commit status

Commit command prepared (not yet executed at report time because `PROOF_SLOT_FREE` was absent):

```
flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c \
  'cd /home/user/workspace/worktrees/fa72-s8d && git commit -F /home/user/workspace/worktrees/fa72-s8d/.git/S8D_COMMIT_MSG'
```

with message `docs(decisions): S8-D/E person-link decision record and slice plan (D-S8-2 option a, D-S8-LINK)`.
## Commit result

`PROOF_SLOT_FREE` was absent 18:00Z–18:17Z (polled passively with `ls`/`[ -e ]` every 20 s; no lock probe) and
reappeared at 18:17Z. Commit executed at 18:20Z:

| # | Command | RC |
| --- | --- | --- |
| 10 | `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c 'cd …/fa72-s8d && git commit -F .git/S8D_COMMIT_MSG'` — lefthook pre-commit: prod-readiness-quick ✔ 0.01 s, banned-cast-tokens ✔ 0.14 s ("OK — no positive token change"), prettier ✔ 2.78 s ("All matched files use Prettier code style!"), tsc ✔ 47.76 s; commit-msg: no-ai-tokens ✔ | 0 |
| 11 | `git rev-parse HEAD HEAD^{tree}` → `ded755ab7626f3791b1d927095810658aef9893f` / `b7b070e1e811f6bdb1c655b43a504e41f553e2ae`; `git status --short` empty; `git diff --name-only dda794d7 HEAD` = the two docs only | 0 |

Post-commit sha256 (unchanged from staging): record `c11017ba…6a4c8` (544 lines), S8-DOC `40645a56…39561`.
`PROOF_SLOT_FREE` was still present after the commit (not touched by this worker).

## Open risks

- **R1 (C)** Any S8-D3 or S8-E1a migration breaks the S11 lane's 173-pin (`g2-s11-pg-harness.ts` L39; bootstrap L36,
  L150-165; guard spec L194-195, L220-222) until the parent re-pins; the plan sequences D3 after S11-A2/S11-D or an explicit
  re-pin. Not a defect in this commit (docs only).
- **R2 (C)** The forward pointer is an append to S8-DOC (§7). If the parent prefers S8-DOC untouched, drop that hunk;
  the record stands alone.
- **R3 (C)** LOC estimates are author estimates from file touch counts (16/10/5/19/8 non-spec files reference the five
  models), not measured; the S8-D3 type ripple is the least certain.
- **R4 (C)** The record recommends readings for OQ-1, OQ-3, OQ-4, OQ-6 but decides none of them; a T4 security review
  should confirm the OTP/lockout parameters (OQ-5) before S8-D4b is granted.
- **R5 (C)** This clone's `node_modules` is a hardlink copy of fa72-s11a1's; nothing was written into it, but the parent
  should not treat it as an independent install.


---

# Round 2 — closure of the independent T4 review (NO-GO on `ded755ab`)

Review read in full: `s8d/s8d_review.md` (B1–B5, C1–C8, OQ classification). One **new** commit on
`fa72/s8d` (no amend), docs only, hooks passed, not pushed.

| Item | Value |
| --- | --- |
| Head | **`7a7d18dec976b4ca3a6e222bb8ac78eb4026a385`** (parent `ded755ab7626f3791b1d927095810658aef9893f`, base `dda794d7`) |
| Tree | **`1f32837280789404ffca04d6839435f3ac0ded2e`** |
| Author / committer | Bradley Gleave `<bradley@bradleytgpcoaching.com>` / same; no trailers |
| Changed | `docs/decisions/2026-09-26-s8d-person-link.md` only: 544 → **802 lines**, +469/−211; sha256 `8fab88f2e597ff99a9fd04d620b8008e5b35a4c06ae8f6de19c5212a33e9efd8`. S8-DOC untouched in this commit (still `40645a56…39561`). |
| Hooks | pre-commit: prod-readiness-quick ✔, banned-cast-tokens ✔, prettier ✔ (2.69 s), tsc ✔ (47.54 s); commit-msg: no-ai-tokens ✔. RC 0. |
| Gate | `PROOF_SLOT_FREE` absent 18:39–18:44Z (waited, `ls`/`[ -e ]` only, no lock probe); present at 18:44Z; commit ran under `flock -w 3600 …/test-validation.lock` at ~18:50Z. |

## Closure table B1–B5 → record section (line numbers at `7a7d18d`)

| Finding | Where closed | What the text now says |
| --- | --- | --- |
| **B1** RLS claim false | §2.2 (L119–217) | Effective-policy inventory for all 8 tables with file:line (`rls_fitness_backend.sql` is out-of-band, `test/db/s1-rls-close-public-exposure.sh` L15/L101; CheckIn `20260607…` L352–391; CWA `20260702…` L28–63 + `20260621…` L47–56; ExerciseSet `20261213…tier3` L81–101; HabitLog `…tier5` L190–214; snapshot `20261215…` L327–347); **new fact**: no migration directory enables RLS on WorkoutSession/WeightLog/Habit (harness gap). Decision: `person_id IS NULL` on every non-owner branch incl. WITH CHECK; three parents get in-tree policies; owner exception stated truthfully and kept; CheckIn cross-tenant pin via `CHECK(person_id IS NULL OR coach_id IS NOT NULL)` + composite FK `(person_id, coach_id) → Person(id, coach_id)`; role × owner-state matrix (9 principals × 2 states, USING + WITH CHECK). Present-tense "unreadable by construction" removed. |
| **B2** proposals vs active unique | §2.5 (L292–363), §2.3 (L218–245) | `PersonLinkProposal` table (open/accepted/declined/expired/revoked/superseded, 14 d expiry, authorization, actor ids, same-tx activation); `PersonLink` is completed-only, `linked_at NOT NULL`; uniques `WHERE linked_at IS NOT NULL AND unlinked_at IS NULL`; **strict** `(coach_id,user_id)` unique with no merge exemption until OQ-1 (merge activation refused by DB); anchor constraints (composite FK same coach/account, self-check, distinct-Person + active via trigger, cascade-unlink). No `InvitePending → Claimed` edge. |
| **B3** re-link bypass | §2.3 table (L218–245), §2.7 step 1 (L389–402), §3.3 (L535–560) | Every path (L2, L5, L8) activates only through a Person-bound `PersonInvite` (`target_user_id` for proposals) + challenge + client "yes"; precondition: if any historical `PersonLink` exists, invite `created_at` > latest `unlinked_at`. Proposal "yes" alone links nothing. OQ-6 may only relax first-time L5; never re-links. |
| **B4** D1 create-only / Deleted | §5.1 (L614–658) | OQ-11 = create-only (derived from D-S8-4 + `native-writers.ts` L91–105): provenance lookup → verify coach (`identity_conflict`) and `state` (`Deleted` → `native_target_removed`, no update, no resurrection) → `already_present` with `display_name` untouched; pre-D1 rows adopted once; named specs (edited names, deleted targets, other-coach ref, adoption, NULL-kind historical ledgers, 5 repeated runs); C6 completeness rule. |
| **B5** undo not deployable | §3.5 (L574–591), §2.5 outbox (L352–363) | `FEATURE_PERSON_LINK` shared by D4b **and** D5; flag may not exist anywhere before D5 specs green; in-app notifications written in the link tx via `createNotification(input, tx)` (L297–301); `PersonLinkOutbox` drained by `@Cron` worker with back-off, `notify_status` on the link, admin alert on exhaustion. |
| C2 | §2.9 (L469–490) | D3 = 3 directories: catalog-only ALTERs + `NOT VALID` constraints with `lock_timeout 5s`/`statement_timeout 30s` (precedent `20270118…` L5–7); `VALIDATE CONSTRAINT`; `CREATE INDEX CONCURRENTLY` outside a transaction (precedent `20260704000001…` L8–27); no backfill; down.sql each. |
| C3 | §2.4 | Atomic `failed_attempts = failed_attempts + 1`; unknown tokens charge nothing; resend limits; all challenges voided on revoke/decline/lock/expiry. |
| C4 | §2.5, §3.4 | `unlinked_by_user_id`, `coach_confirmed_by_user_id`, `decided_by_user_id`; `unlink_reason_code` enum; free-text note never auto-shown. |
| C5 | §2.7 | Four-field provenance compare; deleted-while-linked → `records_returned.missing`; collisions abort (`link_collision`, `unlink_collision`), never downgrade; shared Person-lock discipline; one transaction. |
| C7 | §6 | D1, D2 → T4; LOC labelled estimates; D3 550–800 with SPLIT trigger. |
| C8 | §2.4, §7.2 OQ-13 | `logged ≠ delivered`; channel offered only when transport configured and send `sent`; email-only = capability limitation. |

Derived defaults adopted as decided-by-derivation (§7.1): OQ-3 fail-closed collision abort; OQ-4 refuse other-coach/coach-role claimants, no reassignment; OQ-5 14 d / 10 min / 15 min / 5 + resend limits; OQ-8 admin-only `Suspended`; OQ-11 create-only.

Owner OQs kept open with interim defaults and blocked slices (§7.2): OQ-1 (strict L6; blocks D6 merge part), OQ-2 (edits travel back; D5 acceptance), OQ-6 (code on every path; D6 match relax only), OQ-7 (deletion blocked inside undo window; D5 acceptance + deletion touchpoint), OQ-9 (unresolved; none), OQ-10 (kinds only, no counts; D4b payload/UX-D4 copy), OQ-12 (assignments stay unresolved; E1d), OQ-13 (email-only; D7). **Confirmed: S8-D1 and S8-D2 depend on none of them** (§6 note, §7.2 confirmation).

## Updated slice table (§6 at `7a7d18d`)

| Slice | Grade | Depends on | Migration | LOC (est.) | Blocked by owner OQ | Ruling |
| --- | --- | --- | --- | --- | --- | --- |
| S8-D0 | T4 | OWNER; T4 review | no | 0 | — | this commit |
| S8-D1 typed `person` handoff, create-only + verification, Deleted→removed, named specs | **T4** | S11-A2 | no | 200–300 | none | PROCEED after re-review |
| S8-D2 roster `imported_people[]` + `person_link` + `proposal`; retire `roster_bridge_pending` | **T4** | D1 | no | 250–400 | none | PROCEED |
| S8-D3 schema + RLS rewrite (8 tables) + matrix spec, staged | T4 | S11-A2 + S11-D proofs or explicit re-pin | **yes, 3 dirs** | 550–800 | none | PROCEED; SPLIT if > 1,000 measured |
| S8-D4a invite mint/revoke/resend/preview; Suspended admin freeze | T4 | D3 | no | 400–500 | none | PROCEED |
| S8-D4b OTP/verify/disclosure/confirm; link tx; outbox; gate flag | T4 | D4a | no | 500–650 | OQ-10 (copy) | PROCEED; not enableable before D5 |
| S8-D5 unlink + reason codes + outbox worker | T4 | D4b | no | 400–550 | OQ-2, OQ-7 (acceptance) | PROCEED; D4b+D5 one releasable gate |
| S8-D6 proposals lifecycle; L5 activation; L8 merge | T4 | D5 | yes (exemption index) | 350–500 | **OQ-1** (merge), OQ-6 | match PROCEED; merge BLOCKED |
| S8-D7 phone channel | T4 | owner | no | 200–300 | **OQ-13** | BLOCKED |
| S8-E1a WorkoutSession+ExerciseSet writer | T4 | D3, D1 | yes (CHECK, 1 dir) | 300–450 | none | PROCEED |
| S8-E1b WeightLog+CheckIn (`coach_id = person.coach_id`) | T4 | E1a | no | 250–350 | none | PROCEED |
| S8-E1c Habit+HabitLog | **T4** | E1a | no | 150–250 | none | PROCEED |
| S8-E1d assignments | T4 | E1a | no | 150–250 | **OQ-12** | BLOCKED |
| UX-D2 / UX-D4 / UX-D5 / UX-EXT | T2 / T3 / T2 / T1 | D2+D4a / D4b / D5 / D2 | — | 300–500 / 300–450 / 150–250 / ≤50 | OQ-10 copy on UX-D4 | PROCEED / OPTIONAL |

## Commands run (Round 2) and RC

| # | Command | RC |
| --- | --- | --- |
| 12 | `cat s8d/s8d_review.md` (98 lines, read in full) | 0 |
| 13 | `rg -n -i 'POLICY [^ ]+ ON "?(WorkoutSession\|ExerciseSet\|WeightLog\|Habit\|HabitLog\|CheckIn\|ClientWorkoutAssignment\|ClientWorkoutAssignmentSnapshot)"?' prisma/migrations`; `rg … '"(WorkoutSession\|WeightLog\|Habit\|CheckIn\|ClientWorkoutAssignment)"' … \| rg -i 'policy\|row level\|rls\|force'`; `rg 'rls_fitness_backend\|_supabase_bootstrap' …`; `rg 'ENABLE ROW LEVEL SECURITY' prisma/migrations/*/migration.sql \| rg '"(WorkoutSession\|WeightLog\|Habit)"'` (→ no hits, RC 1 as expected) | 0 / 1 |
| 14 | `nl -ba`/`sed -n` reads: `rls_fitness_backend.sql` L1-50, L120-150, L204-214; `20260607000000_rls_remaining_gaps` L1-60, L80-90, L345-395; `20260508000001` L30-38, L88-110; `20260621000000` L20-62; `20260702000000` L20-60; `20261213…tier3` L80-102; `20261213…tier5` L190-216; `20261215…mwb_1` L325-349; `20260704000001…concurrent` L1-40; `20270118000000…` L1-12; `schema.prisma` L2063-2082, L2323-2332, L6951-6957; `families.ts` L80-103; `native-writers.ts` L66-106; `data-export.service.ts` L410-420; `notifications.service.ts` L297-301; `scout-roster.controller.ts` L76-84; `g2-s11-bootstrap.sh` (rg rls) | 0 |
| 15 | `rg -n '@Cron\(\|@Interval\('`, `rg -i outbox src`, `rg 'lock_timeout\|NOT VALID\|VALIDATE CONSTRAINT' prisma/migrations` | 0 |
| 16 | `python3 .git/s8d_round2_edit.py` (section-level replacements, every anchor asserted unique) → "ok 801" | 0 |
| 17 | `prettier --write` (×2, padding/blank-line only — whitespace-normalised diff empty) ; `prettier --check` both docs → clean | 0 |
| 18 | table column-count scan (awk) — mismatches all traced to escaped `\|` in inline code; `rg` for banned tokens in the doc → none | 0 |
| 19 | `git add docs/decisions/2026-09-26-s8d-person-link.md`; waited for `PROOF_SLOT_FREE` (absent 18:39–18:44Z, poll `[ -e ]` every 20 s; one poll loop hit the sandbox 630 s wall — no side effects) | 0 |
| 20 | `flock -w 3600 …/test-validation.lock bash -c 'git commit -F .git/S8D_COMMIT_MSG2'` → `[fa72/s8d 7a7d18d]`, 1 file, +469/−211 | 0 |
| 21 | `git log -1`, `git rev-parse HEAD^{tree}`, `git status --short` (clean); temp files under `.git/` removed | 0 |

## Open risks after Round 2

- **R6 (C)** The RLS inventory is from reading migration SQL in directory order, not from `pg_policies` on a live database; D3's matrix spec is the proof. If any policy was altered outside the tree (e.g. by the out-of-band file being re-run after a migration), production may differ from the inventory — D3-1 recreates every affected policy idempotently so the end state is the same either way.
- **R7 (C)** Round 2 chooses fail-closed aborts for `CheckIn` collisions on link and unlink. A collision on unlink is argued unreachable by construction; if it occurs, the L7 undo needs admin intervention rather than completing partially. Recorded, not hidden.
- **R8 (C)** The strict `(coach_id, user_id)` unique blocks L8 two-platform merges until OQ-1 is answered; if the owner wants merges in the first release, OQ-1 must be answered before D3, not D6, to avoid a second index migration.
- **R9 (C)** The record is 802 lines; the parent may want an independent re-review scoped to §2.2, §2.5, §2.7, §3.3, §3.5, §5.1 (the sections that changed) before granting D1.
- R1–R5 from Round 1 stand (S11 173-pin: D3 is now three directories, so the re-pin moves to 176 + E1a + D6).

---

# Round 3 — closure of the Round-2 delta review (B6, B7, B5 follow-up)

Review read: `s8d/s8d_review.md` "Round 2" section (NO-GO on two document contradictions; D1 GO once corrected). One **new** commit on `fa72/s8d` (no amend), docs only, hooks passed, not pushed.

| Item | Value |
| --- | --- |
| Head | **`f91dea4de7843e5e7e04c87e19559907b52ab2a0`** (parent `7a7d18de…`, base `dda794d7`) |
| Tree | **`ab85787c564a3b8f553b403d9a3e092d3c5a3ccd`** |
| Author / committer | Bradley Gleave `<bradley@bradleytgpcoaching.com>` / same; no trailers |
| Changed | `docs/decisions/2026-09-26-s8d-person-link.md` only (`git diff --name-only 7a7d18d HEAD`): 802 → **858 lines**, +106/−50; sha256 `cd5566360241d375dfb3124d5bb6977e0a134c5fd192fc4fb3b62740bb5fcab4`. S8-DOC untouched. |
| Hooks | pre-commit: prod-readiness-quick ✔, banned-cast-tokens ✔, prettier ✔ (2.88 s), tsc ✔ (48.75 s); commit-msg: no-ai-tokens ✔. RC 0. |
| Gate | `PROOF_SLOT_FREE` present at check time; commit ran under `flock -w 3600 …/test-validation.lock`; no lock probe. |

## Closures → section / line (at `f91dea4`)

| Finding | Where | What changed |
| --- | --- | --- |
| **B6** disclosure payload contradicts OQ-10 interim | §3.2 step 4 (L545–554); §3.3 L5 pre-verification (L567–569); §7.2 OQ-10 row; §9 L856 | Post-verify response is now **exactly** the §7.2 interim payload: `{coach_display_name, person_display_name, family_kinds: [...]}` — kinds derived from provenance `native_kind`; **no** counts, **no** date ranges, **no** row contents before "yes". Counts appear only after confirmation (`records_moved`, `link_collision` refusal in §2.7 step 4). Proposal-path pre-verification shows the coach card only (no Person name), matching §3.2 step 2. §4 threat rows checked: "Coach mistake" says "after seeing the disclosure" (no shape), "Contact change" says "never the Person's name or history" — consistent; no edit needed. One disclosure contract; amend §3.2 + §7.2 together after Bradley answers OQ-10. |
| **B7** composite FK before its unique key | §2.9 (L475–508); §2.2 item 3 (Person unique "must exist before" the FK); §2.5 anchor bullet; §6 D3 row ("4 dirs") and pin note (L776–781); §9 L857 | D3 is now **four directories** with the ordering rule stated (unique key before referencing FK; NOT VALID on populated tables then VALIDATE; CONCURRENTLY outside a transaction). D3-1: new empty tables incl. `PersonLink(id, coach_id, user_id) UNIQUE` **before** the anchor FK in the same statement list, nullable columns, `NOT VALID` CHECKs, RLS rewrites, **no composite FK to Person**. D3-2 (no tx): `CREATE UNIQUE INDEX CONCURRENTLY Person(id, coach_id)` + the parent indexes. D3-3: `ADD CONSTRAINT … UNIQUE USING INDEX` then all composite/plain FKs `NOT VALID`. D3-4: `VALIDATE CONSTRAINT`. Sequence proof paragraph for both named FKs. S11 pin note: 173 → 177 at D3, 178 after E1a, 179 after D6; `EXPECTED_MIGRATIONS`/`LAST_MIGRATION`/prisma-tree base move together. Not executed against PG (rule). |
| **B5 follow-up** flag-off strands undo | §3.5 (L611–637); §3.4 routes (L589–593); §4 partial-deployment row; §9 L858 | Chosen: **authenticated unlink path outside the gate** — `POST /api/person-links/:id/unlink` (client) and `POST /api/coach/person-links/:id/unlink` (coach), prefixes in no `FEATURE_GATED_ROUTES` entry (`feature-flag-not-found.middleware.ts` L20–31, L38–64; `/api/scout` is darkened by `FEATURE_SCOUT_INGEST` L22 so the coach route was moved off it). Why safer: the reason to flip a flag is an incident in the claim path, when waiting up to 30 days for links to close is not possible, and a people-enforced env-var rule is not a rail the record can prove; the ungated routes are JWT-guarded, owner-scoped, uniform-404 for foreign ids, and can only return rows (never create/verify/link) — a data-rights recovery path like account deletion; R-DARK-1 exception recorded deliberately (`scout-ingest.controller.ts` L68, L88 name the rule). Belt-and-braces: admin alert when the flag is disabled with links inside their undo window; UX-D5 reads from the ungated route. `FEATURE_PERSON_LINK` now fronts claim/confirm/proposal-start only. |

## Commands run (Round 3) and RC

| # | Command | RC |
| --- | --- | --- |
| 22 | `awk '/Round 2/{f=1} f' s8d_review.md`; `git status --short`; `git rev-parse HEAD`; `nl -ba` decision L469–490, L523–534, L541–546, L561–591, L176–186, L325–333, L596–598; `rg` for count/date/disclosure mentions | 0 |
| 23 | `nl -ba src/common/feature-flag/feature-flag-not-found.middleware.ts` L14–70; `rg -n 'R-DARK-1' docs src test` (real rule: `scout-ingest.controller.ts` L68, L88; `scout-reconstruct.controller.ts` L31) | 0 |
| 24 | Python in-place edits (11 anchored `replace`, each asserted unique; §2.9 replaced as a whole section) → `ok` | 0 |
| 25 | `prettier --write` then `--check` (both decision docs) → clean; whitespace-normalised diff pre/post prettier = 0 lines; table column scan — only the known escaped-`\|` rows (shifted +4); banned-token `rg` → none | 0 |
| 26 | `git add …`; `[ -e PROOF_SLOT_FREE ]` (present); `flock -w 3600 …/test-validation.lock bash -c 'git commit -F .git/S8D_COMMIT_MSG3'` → `[fa72/s8d f91dea4]`, 1 file, +106/−50 | 0 |
| 27 | `git log -1`, `git rev-parse HEAD^{tree}`, `git status --short` (clean), `sha256sum`, `git diff --name-only 7a7d18d HEAD` (one file); temp message file removed | 0 |

## Notes

- Slice table: only the D3 row changed ("yes — 4 dirs"); grades, LOC estimates, dependencies and owner-OQ blocks are as in Round 2. D1 and D2 still depend on no owner OQ and on no migration.
- The reviewer's RLS note (migration-only environments may lack RLS on WorkoutSession/WeightLog/Habit; conditional risk, not a proven production exposure; needs a separately authorised read-only live inventory) is an owner-facing item for the parent — outside this docs grant, not acted on here.
- OQ-7 data-rights review before live claims (reviewer note) is already the interim default's caveat in §7.2; no change.
