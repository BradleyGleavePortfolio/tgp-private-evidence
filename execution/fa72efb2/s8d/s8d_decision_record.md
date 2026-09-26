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

