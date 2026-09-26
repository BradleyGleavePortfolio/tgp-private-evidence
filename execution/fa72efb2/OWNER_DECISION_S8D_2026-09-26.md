# Owner decision — D-S8-2 option (a) direction (EXEC-FA72EFB2), 2026-09-26 17:38Z
Bradley (verbatim): "yes i like S8-D's direction - But lets also make sure we have a VERY ROBUST way to akin those people to
them once they sign up - I want to brainstorm ways to do this clealry (or, if we already have this planned, I want it explained
to me just like you did s8-d)"
Context given to Bradley: option (a) of D-S8-2 (docs/decisions/2026-09-24-s8-native-contract.md L84-87): client-owned records
may belong to an imported, not-yet-joined Person; the roster shows such people labelled that way until they sign up.
Status: DIRECTION approved. Linking (Person → signed-up account) design requested as robust and explicit; existing plan is
D2/Op 59 (schema.prisma "linked to an AuthPrincipal only later, via an explicit credential-verified claim"; email never a
linking key; PersonState InvitePending/Invited/Claimed/Suspended/Deleted). The claim flow is not designed or built yet;
a decision record for it goes to Bradley before S8-D/E claim work is built (identity linking is security-relevant).

## Linking answers (Bradley, 17:41Z, verbatim)
"1.) verify email OR phone, let them decide?
2.) Always have client confirmation required
3.) Yes, 30 days to undo VIA coach side? Or client/coaches both can unwind linkage?"
Parent recommendation returned for (1): the client picks the channel, but only among contacts the coach has on file for that
person (verifying an arbitrary new contact would let a forwarded invite be claimed). For (3): both sides can unlink within 30
days; after 30 days the coach cannot unilaterally unlink (client's own data/rights path or admin). Pending Bradley's confirmation
in the decision record.

## OFFICIAL — Bradley decision D-S8-2 + D-S8-LINK (17:44Z, verbatim): "I like the linking decision - log it as official Bradley decision - EXECUTE"
DECIDED by Bradley Gleave (owner), 2026-09-26 17:44Z. Supersedes the D-S8-2 interim for its end state.
D-S8-2 = option (a): client-owned native records may belong to an imported Person (nullable person_id beside the User FK,
family by family); the coach roster shows imported Person rows as "imported, not yet joined" until they join. No login User is
minted for an imported person (D2 stands); email is never an identity or linking key (D2 stands).
D-S8-LINK (linking an imported Person to the account of the human who signs up):
 L1 Never automatic. No link by email, name, phone or any fuzzy match; suggestions may be shown to the coach, never applied.
 L2 Main path: coach taps Invite on an imported Person → single-use, expiring, revocable invite bound to exactly that Person,
    sent to a contact the coach confirms (held on the invite, not as identity).
 L3 Verified contact: the client chooses email OR phone, but only among the contacts the coach holds for that Person; one-time
    code verification of that channel is required. A contact typed in by the claimant is never accepted for the claim.
 L4 Client confirmation ALWAYS required ("Coach X brought over your history: … Is this you?"). "No" leaves it unlinked and
    notifies the coach.
 L5 Fallback (client joined another way): coach may approve a suggested match; the client must still confirm (two-sided).
 L6 Integrity: one Person ↔ at most one account per coach; never across coaches/tenants; every link/unlink audited; records are
    handed over (re-owned), never copied; replays idempotent.
 L7 Undo: for 30 days after linking, EITHER the client or the coach can unlink. Only imported records return to the Person;
    anything logged after joining stays with the client; the other side is notified; re-linking needs a fresh invite + fresh
    client confirmation. After 30 days the coach cannot unlink alone; client data rights (deletion/export) and admin support apply.
 L8 Merges (already-a-client, or the same person imported from two platforms): two-sided confirmation, same rails.
Build rule: graded T4 (identity/security/schema); decision record lands in backend docs/decisions; slices sequenced after
S11-A2's migration-count pin; production enablement remains owner-reserved.
