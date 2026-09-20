# S1 R3 final builder packet

Preserved 2026-09-20 from the frozen builder packet. Source head is `b7d7fe5964680050ab441c195055ea946282a9c3`, tree `abc1ac55bd8f93383b7b0075ec9a4c856e4455d9`. Original manifest and separate addendum manifest verified before copying; setup logs and PostgreSQL provenance are included.

The final exact-head run passed 89/89 checks on the local PostgreSQL 17.6 synthetic fixture. Earlier failed attempts are retained. The original report contains historical preparation sections; its final header and SLOT C execution record supersede earlier unrun descriptions. This is builder evidence, not audit, PG15 CI, hosted, release, or customer clearance.

The original S2 interface is preserved, not endorsed wholesale. Addendum 01 corrects migration-history recovery semantics: `resolve --rolled-back` is not the repair for clean applied history after out-of-band reversal. Direct forward re-application is the demonstrated route in that case.

The interface's section 3 claim that full historical replay must fail is contradicted by the actual frozen harness and run-04 PASS records. The harness bootstraps and genuinely replays the parent migration chain with the candidate removed, then applies the legacy RLS file. S2 must use the actual executed preparation, not substitute ledger-only baselining. A builder correction has been requested separately.

The guard permits databases in the `s1_rls_*` namespace; a dedicated `s1_rls_s2comp` fixture is allowed by the current guard, but no composition execution is authorized by this note. Original proof databases remain preserved and stopped. Both independent final-head S1 reviewers have been dispatched without access to each other's work.
