# S12 prep report (T3 planner, EXEC-FA72EFB2)

## Deliverable
- `execution/fa72efb2/s12/S12_PILOT_READINESS.md`: 406 lines, sha256
  `3f4d08e6cfa7551fcd6a75e03cc3806520a7b435b6777a48f25df3d16079ed16`.
- This report is `execution/fa72efb2/s12/s12_prep.md`.
- I made no code change, no commit and no push. I ran no PostgreSQL, heavy command, network fetch, real-service call
  or account action, and spent nothing. I did not use the heavy-slot lock, because the grant needs no heavy command.

## Summary
- **Acceptance is split in two.**
  - S12a: one real import for one pilot coach, with no client contact.
  - S12b: a client invite through D-S8-LINK, after S8-D4b and S8-D5 land together.
  - Every step of the journey is mapped to a landed synthetic proof (J01-J20, D2 R39, S10/S11 specs), alongside what
    only a real account adds (readiness §1.1).
- **Four source facts shape S12:**
  1. The landed extension (`a889f4ad`) creates legacy run ids and never calls `runs/start`
     (`daceddc8/e2/CONSUMER_FREEZE.md` L74, L97). So no shipped client drives the server-mode journey that S11 proved.
  2. No real platform has a verifier or induction manifest (S10-DOC L87-89), and TrueCoach, the only real mapping in
     `src`, has no native rules. So an honest pilot result is `partial` with named reasons, never `complete`, and no
     native programs appear.
  3. The importer flags are global environment booleans (`feature-flag-not-found.middleware.ts` L20-31, L41-42). No
     pilot-coach scoping exists.
  4. Production has not received `integration/importer`. Backend `main` is `1c10e2a1`, one new migration is in range,
     and Fly deploys were blocked by overdue invoices as of 2026-09-25 (`PR530_MERGE_SAFETY.md` L17, L94-100).
  - Mobile can pair and show readiness, but it does not read the verdict or the roster yet.
- **Buildable now (no owner needed):**
  - S12-B1: pilot-coach allowlist (T4);
  - S12-B2: exclude test manifests from production, D2 C1 (T3);
  - S12-B3: mobile M-bind for status and verdict (T2/T3);
  - S8-D1 → S8-D2 → UX-D2 (roster);
  - S8-D3 through D5 and UX-D4/D5 (S12b);
  - S12-B4: pilot runbook and read-only report pack (T1/T2);
  - S12-B5: RLS check script, written and not run (T2);
  - S12-B6: add `FEATURE_SCOUT_RECONSTRUCT` to the flag workflow (T2);
  - S12-B7: native mapping for the chosen platform (T2/T3, needs owner question 2).
- **Findings:**
  - B1: global flags.
  - B2: no server-mode client.
  - B3: a real `complete` is impossible (acceptance definition).
  - B4: out-of-band RLS for WorkoutSession, WeightLog and Habit (S12b and S8-E only).
  - Class C items are listed in readiness §5.

## Ordered owner questions for Bradley (recommended defaults are recommendations, not decisions)
1. **Pass criteria (Q-S11-4).** Until a real verifier exists, will you accept an honest `partial` with named reasons
   as a pilot pass, and keep a real-platform `complete` switched off? *Recommended:* yes.
2. **Account.** Which platform and account do we import from, and whose clients are in it? *Recommended:* TrueCoach;
   your own coach account or one friendly coach; one workspace; 20 people or fewer.
3. **Consent and retention.** Will the coach agree in writing? How long do we keep the data, and who may ask for it to
   be deleted? *Recommended:* written consent from the coach; no client contact in S12a; rows stay until S10 Q3 is
   decided; deletion only by a separately approved script.
4. **Environment.** Production or staging first? *Recommended:* production with the pilot allowlist, and every other
   coach dark.
5. **Pay Fly and deploy.** May we clear the Fly invoices, protect the GitHub `production` environment, merge one exact
   approved `integration/importer` commit into `main`, and deploy it with the flags off? *Recommended:* yes, one
   pinned sha after S11-D, S12-B1 and S12-B2, following D1-D6.
6. **Pilot flags.** May we turn on pairing, import and review in production for the pilot coach only?
   *Recommended:* yes, after full rollout, with an allowlist of exactly one coach id and `FEATURE_PERSON_LINK` absent.
7. **D2 C1.** Must test-only source keys be excluded from production builds before any flag goes on?
   *Recommended:* yes.
8. **Extension automation and distribution (Q-S11-2, CWS).** May we build an extension that runs Start, send, finish
   and finish-retry by itself under the paired setup, and give it to the pilot coach as a private side-load instead of
   publishing it on the Chrome Web Store? *Recommended:* yes; no declaration or observation relay; your non-author
   approval on extension `main`; no CWS publication in S12.
9. **Run time limit (Q-S11-1).** How long may one import run before it is timed out? *Recommended:* one fixed
   window of 30 minutes (`SCOUT_RUN_DEADLINE_MS`=1800000), no renewable lease; revisit after the pilot.
10. **Switch-on order (Q-S11-3).** Is the order backend fully rolled → pilot flags → extension → mobile build?
    *Recommended:* yes.
11. **G3-AUTH.** Are you OK with no in-product "disconnect source" button and one workspace per coach per platform
    for S12a? *Recommended:* yes, for S12a only.
12. **Mobile pilot build and spending.** May we make an internal-track mobile build with the import screens on, and
    pay its cost? *Recommended:* yes, internal track only.
13. **RLS check (S12b and S8-E only).** May someone run one reviewed, read-only production query to confirm the
    WorkoutSession, WeightLog and Habit policies? *Recommended:* yes, once, recorded in evidence. A gap found there is
    class A and is closed by S8-D3.
14. **S12b invite.** Once invite, claim and undo are proven, may the pilot coach invite one consenting client by
    email, with OQ-2, OQ-7 and OQ-10 on their interim defaults? *Recommended:* yes, email only, after questions 13
    and D4b+D5.

Questions 1-12 are the minimum set for S12a. Questions 13-14 are needed only for S12b.

## Commands run (all read-only; RC 0 unless noted)
- `cat`, `sed -n`, `awk`, `grep -n`, `wc -l` and `ls` over the grant, WORKER_RULES, TAKEOVER, LAST_OPERATOR_STATE,
  OWNER_DECISION_S8D, LEARNINGS, `1910a060/SCOPE.md`, `1910a060/extension/LANDED.md`,
  `daceddc8/{SCOPE,HALF_DONE_WORK}.md`, `daceddc8/e2/{SOURCE_READY,CONSUMER_FREEZE}.md`,
  `daceddc8/prod/PR530_MERGE_SAFETY.md`, `fa72efb2/s10d2/d2_review.md` and `fa72efb2/s11d/PROOF_V1_FINDING.md`.
- In `worktrees/fa72-s11d2` (read only):
  - `git log`, `git status`, `git rev-list --count`, `git diff --stat/--name-only 1c10e2a1 HEAD -- prisma/migrations`;
  - `rg` over `src`, `.github/workflows` and `docs`;
  - `sed` on the S10 and S11 records, `docs/deploy-runbook.md`, the flag middleware, the community guard,
    `fly-feature-flags-set.yml`, `fly-deploy.yml` and the S11 specs;
  - `python3` JSON key listing of `truecoach.json`.
- In `worktrees/fa72-s8d`: `git log`; `grep` and `sed` on the S8-D record.
- In `repos/backend`: `git rev-parse origin/main origin/integration/importer`.
- In `repos/mobile`: `git log`, `git branch -a --contains a876268c`, and `git show` / `git grep` / `git ls-tree` on
  `origin/main`. The working tree was not modified.
- `sha256sum` and `git status --short` on the evidence repo.

## Open risks
- Landing state comes from the local tracking refs and LAST_OPERATOR_STATE (19:25Z). I did not fetch from GitHub.
- The extension source is absent from this workspace. Its behaviour is taken from evidence (CONSUMER_FREEZE,
  SOURCE_READY, LANDED) at `a889f4ad`. I did not verify which real platforms its extractors support.
- The current production image, schema and flag values are unknown. They must be read back, under the owner's
  approval, before question 5.
- The S12-B1 design (checking the allowlist after auth, with a uniform 404) needs its own T4 review. Unauthenticated
  `redeem` is covered only indirectly, because it accepts only codes minted through the gated `init`.
- The 30-minute deadline and the 20-person roster are planning guesses. Neither was measured.
