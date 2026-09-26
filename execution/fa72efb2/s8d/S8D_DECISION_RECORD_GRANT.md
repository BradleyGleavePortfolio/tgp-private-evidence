# S8-D/E + D-S8-LINK — decision record and slice plan (EXEC-FA72EFB2)
Grade T4 (identity, account linking, schema, security). Route: Claude Fable 5 drafts; GPT-6 Sol reviews independently.
Authority: execution/fa72efb2/OWNER_DECISION_S8D_2026-09-26.md (OFFICIAL Bradley decision, L1–L8 — binding; do not weaken or
reinterpret; if something is underivable or contradicts a landed invariant, list it as an open question, do not decide it).
Clone: create /home/user/workspace/worktrees/fa72-s8d (standalone, Bradley identity, push disabled `no_push://disabled-fa72efb2`,
node_modules `cp -al` from worktrees/fa72-s11a1/node_modules, lefthook installed) at integration/importer dda794d7e8bee0482a7ad373795fcc51dcf54bb5.
Deliver ONE docs-only commit: docs/decisions/2026-09-26-s8d-person-link.md, grounded file:line in this tree:
1. Decision (owner, verbatim quote + date) and what it supersedes in docs/decisions/2026-09-24-s8-native-contract.md (D-S8-2
   interim, §4.1 qualifier, §4.5) — add a short forward pointer in that S8 doc only if its own text says it is the contract.
2. Data model: which client-owned tables get nullable person_id (schema.prisma: ClientWorkoutAssignment, WorkoutSession,
   WeightLog, Habit, CheckIn — verify the full list), exactly-one-owner constraint (user_id XOR person_id), RLS/tenant rules
   (coach scope), indexes; Person states (InvitePending/Invited/Claimed/Suspended/Deleted) transitions; a PersonLink (or
   equivalent) audit/undo record with 30-day window; how records are re-owned on link and returned on unlink (only imported
   records — define "imported" via provenance), idempotency, concurrency (two claims, claim vs coach unlink, claim vs import).
3. Link flow (L2–L5, L7, L8) against the existing invite machinery (src/invite-codes/**, InviteCode model incl. intended_email
   check, src/invite-landing/**, auth/signup) — reuse vs new; OTP channel verification (what exists in src/auth or supabase);
   notifications to the other side; what the client sees before confirming (minimum disclosure before verification).
4. Threat model: account takeover via forwarded invite, contact change, coach mistake, malicious coach, enumeration, replay,
   race, cross-tenant — each with the rail that closes it.
5. Roster: "imported, not yet joined" rendering contract (existing importer-G roster read, scout-roster.service.ts) and the
   typed `person` handoff that lets roster-bearing imports settle `complete` (families.ts L75-103, S9-A bucket f) — this is the
   D2 finding in s10d2/d2_diagnose_fix.md.
6. Slice plan with T-grades, dependencies, owner boundaries (production enablement, live accounts stay reserved), expected
   hand-written production LOC per slice (flag any slice > 1,000 for PROCEED/SPLIT/SIMPLIFY), migration sequencing (the S11
   lane pins 173 migrations; S11-A2 is in flight — schema slices land after S11-A2/S11-D proofs or re-pin explicitly), and
   the mobile/extension UX slices.
Gates: prettier --check on the doc (runtime/tools/prettier-3.9.9); commit through hooks under
`flock -w 3600 /home/user/workspace/execution/test-validation.lock` only while /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE
exists. Bradley author/committer, no trailers, no push. No code changes. Report s8d/s8d_decision_record.md (summary, open
questions, slice table, commands+RC, head/tree). Rules: execution/fa72efb2/WORKER_RULES.md.
