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
