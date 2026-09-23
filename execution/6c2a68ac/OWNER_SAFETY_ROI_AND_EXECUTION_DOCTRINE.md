# TGP SAFETY ROI & EXECUTION DOCTRINE

Owner amendment supplied by Bradley in session 6c2a68ac-77b8-4d08-86d5-680d240e58f3 on 2026-09-23 at 08:56 PDT. The following owner text governs ongoing work.

MISSION

Build the correct product as quickly as possible without taking unacceptable customer, data, security, financial, or irreversible risk.

Safety is not the product.
Auditing is not the product.
Evidence is not the product.

They exist so we can move quickly while knowing that the result is real.

The product outcome is:

working software → trustworthy behavior → integrated system → real customer proof.

For the importer specifically:

authorized source → autonomous discovery → native TGP reconstruction → reconciliation → truthful completion → usable coach experience

and ultimately:

AI-assisted + autonomous + site-agnostic + browser-agnostic + self-learning + NEW SOURCE → CORE DIFF = 0.

## CUSTOMER-BACKWARD TEST

Before doing safety work, ask:

WHAT BAD CUSTOMER OR SYSTEM OUTCOME DOES THIS PREVENT?

Valid answers include:
- wrong customer's data;
- missing or corrupted records;
- duplicates;
- false Complete;
- broken relationships;
- unauthorized writes;
- writes after cancellation/revocation;
- unintended messages/charges/side effects;
- destructive irreversible mutation;
- security/tenancy failure;
- runtime behavior that makes the product unusable;
- evidence so unreliable that we cannot know whether one of the above occurred.

If no concrete consequential outcome can be named:
the work is presumptively NON-BLOCKING.

## THREE FINDING CLASSES

A — PRODUCT / CUSTOMER / DATA RISK

The defect can materially change actual product behavior or create meaningful security, privacy, financial, integrity, availability, authorization, tenancy, reconciliation, or customer-experience harm.

ACTION:
BLOCK affected path.
FIX.
REVIEW changed candidate.
EXECUTE.

Examples:
wrong tenant
duplicate native entities
missing required relationships
false Complete
cancelled run continues writing
wrong account continues
native records corrupted
unexpected messages or charges
real deadlock/hang
unsafe destructive action

B — PROOF-INVALIDATING

The product may be correct, but current evidence cannot reliably tell us whether it is correct.

ACTION:
BLOCK ONLY THE AFFECTED PROOF.
Fix the smallest evidence defect necessary.
Review it.
Immediately execute the proof.

Examples:
failed step masked by later exit 0
stale result attributed to current execution
wrong candidate SHA audited
runner silently skips required assertion
owned worker survives and can still mutate test state
result cannot distinguish timeout from success

A B-finding is NOT authorization to redesign the entire safety system.

C — EVIDENCE HYGIENE / THEORETICAL IMPROVEMENT

The issue improves neatness, provenance, theoretical certainty or defense-in-depth but does not materially change product behavior, customer risk, irreversible risk, or the validity of the next decision.

ACTION:
RECORD.
QUALIFY.
CONTINUE.

C NEVER creates another fixer/audit cycle by itself.

## DELETE TEST

For every safety mechanism, audit, control, harness, report or gate:

ASK:
"If we deleted this entirely, what concrete bad outcome becomes meaningfully more likely?"

If the answer is unclear:
DELETE IT.

If another existing mechanism already catches the same failure:
DELETE THE DUPLICATE.

If a standard tool already solves the problem:
USE THE STANDARD TOOL.

Do not invent bespoke:
- supervisors;
- evidence frameworks;
- validator frameworks;
- process managers;
- meta-auditors;
- safety SDKs;
- orchestration layers;

unless a demonstrated failure proves the existing mechanism insufficient.

## CONSTRAINT RULE

At every moment identify the CURRENT BOTTLENECK.

Examples:
S2 control execution
S1/S2 composition
S3 integration
S5 correction
S6 execution
native writers
reconciliation
real-platform proof

Work that does not advance or unblock the constraint must justify why it should consume resources now.

Do not optimize a non-constraint while the actual constraint waits.

Parallel work is valuable only when it:
- advances another independent critical path;
- prepares work that will soon become executable;
- or reduces idle time without creating rework.

ACTIVITY ≠ THROUGHPUT.

## REVERSIBILITY RULE

Apply safety effort proportional to consequence.

REVERSIBLE + LOCAL + NON-CUSTOMER:
bias strongly toward action.

HIGH-CONSEQUENCE BUT RECOVERABLE:
use bounded execution + rollback + targeted proof.

IRREVERSIBLE / PRODUCTION / SECURITY / TENANCY / MONEY / CUSTOMER DATA:
require strong evidence before action.

Do not give a reversible local test the same ceremony as a destructive production migration.

## NO MOVING FINISH LINE

Acceptance criteria freeze before execution.

After a candidate satisfies them, new blockers require:
- a concrete newly discovered A defect;
- a concrete B defect;
- changed candidate behavior;
- changed consequential boundary;
- or explicit owner scope change.

"We could test more"
"We would feel safer"
"another edge case is imaginable"

are NOT sufficient.

Confidence has diminishing returns.

## NO TESTING THE TEST OF THE TEST

One layer proves behavior.
A second layer may validate that proof mechanism when materially necessary.
Any additional recursive validation requires a demonstrated defect.

Never build:

product → test → test validator → validator validator → validator audit → validator-audit fixer

without concrete evidence requiring each layer.

STOP RECURSION.

## NO HYPOTHESIS-FREE FAILURE INVENTION

Do not generate arbitrary fault scenarios because they are imaginable.

A fault test must correspond to at least one of:
- an observed failure;
- known architecture boundary;
- credible production failure mode;
- customer invariant;
- security invariant;
- acceptance requirement.

Infinite hypothetical edge cases exist.
Engineering resources are finite.

## NEVER REBUY EVIDENCE YOU ALREADY OWN

Do not rerun or re-audit valid unchanged evidence unless applicability changed.

No repeated:
- source restoration;
- installation;
- setup;
- test suite;
- browser proof;
- audit;
- process census;
- negative control;

simply because a new operator arrived or more certainty is possible.

Preserve applicable evidence and move forward.

## SAFETY WORK MUST BUY A DECISION

Before authorizing safety work, answer:

1. What exact uncertainty exists?
2. What A or B consequence does it create?
3. What decision is currently blocked?
4. What is the minimum evidence needed to unblock it?
5. Do we already possess applicable evidence?
6. What execution becomes possible immediately afterward?

If #6 has no clear answer:
QUESTION WHETHER THE WORK SHOULD EXIST.

## SAFETY ROI TEST

Safety work has cost:
credits
wall-clock time
context
operator attention
worker capacity
integration delay
customer-feedback delay

Therefore ask:

EXPECTED RISK REDUCTION
versus
COST OF DELAY.

Do not spend $100 of engineering effort protecting against a $1 failure that is reversible, observable and easily recovered.

Do spend heavily where failure could:
- leak customer data;
- corrupt canonical data;
- cross tenants;
- create financial effects;
- destroy production state;
- make false success believable;
- or create irreversible consequences.

Safety intensity must match consequence.

## CONVERGENCE REQUIREMENT

Every safety cycle must converge toward execution.

GOOD:
audit → concrete defect → narrow fix → exact review → EXECUTE

BAD:
audit → theoretical concern → framework enhancement → audit → provenance enhancement → audit → another hypothetical → framework enhancement

If a lane completes TWO safety cycles without reaching a new execution boundary:
the parent must explicitly state:

A/B DEFECT:
WHY IT BLOCKS:
MINIMUM FIX:
EXECUTION UNLOCKED:

If those cannot be filled credibly:
STOP THE LOOP.
EXECUTE.

## NO CROSS-LANE HOSTAGE TAKING

A blocked lane blocks its actual dependents.
Nothing else.

S5 does not freeze S2.
Browser work does not freeze independent backend work.
Database work does not freeze unrelated source preparation.

Maximize useful parallel throughput while respecting real contention.

## THE ULTIMATE TEST

The purpose of validation is eventually to answer:

DOES THE REAL PRODUCT WORK?

For the importer that means progressively proving:

real runtime
→ real integration
→ native writes
→ relationships
→ reconciliation
→ real source
→ structurally different source
→ unseen-source learning
→ multiple browser hosts
→ actual coaches
→ measured pilot

A beautifully audited harness with no customer proof is unfinished engineering.

## OPERATING DEFAULT

A = BLOCK AND FIX.
B = BLOCK THE PROOF, FIX MINIMALLY, THEN RUN IT.
C = RECORD AND MOVE.

REVERSIBLE uncertainty = bias toward execution.
IRREVERSIBLE consequential uncertainty = bias toward proof.

DO NOT optimize safety for its own sake.
DO NOT maximize number of tests.
DO NOT maximize number of audits.
DO NOT maximize certainty.

MAXIMIZE:

TRUSTWORTHY CUSTOMER VALUE PER UNIT OF TIME + COMPUTE + HUMAN ATTENTION.

## FINAL RULE

A safety mechanism earns its continued existence only if it:

1. catches a consequential defect;
2. protects a consequential boundary;
3. makes otherwise-untrustworthy evidence trustworthy; or
4. materially accelerates safe execution.

Otherwise:
DELETE IT.

Be safe enough to know the result is real.
Then move.
