# S1 R3 auditor A — narrow evidence requests, not execution authority

No DB run, install, or broad test is requested from the auditor. Parent schedules any execution and approves the target/guard before a connection; S1 remains the sole source owner. ([Execution mandate](../../../EXECUTION_MANDATE.md))

## Request A — S1-R3-A-01, smallest unchanged-head discriminator

**Purpose:** confirm the statically identified TRUNCATE-only false-green in the frozen verifier; this is not permission to change hosted/customer privileges. ([Affected verifier, lines 134–139](../../../../initialization/recovered/s1-r3-b7d7fe5/prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql))

On an already prepared **parent-approved session-owned disposable PG17.6** database, under the canonical nonblocking lock:

1. Stamp source head/tree/status and verifier hash, actual Prisma/toolchain/lockfile identity, exact command, target synthetic marker/database/roles, start/end and every child exit.
2. Require protected-state verifier exit 0 using both psql stop-on-error and the real pinned Prisma `db execute --file` command.
3. Use the existing seeded standalone `public."MuxProcessedEvent"` table if schema review confirms no referencing FK; grant **only TRUNCATE** to `anon`.
4. Record effective CRUD=false and TRUNCATE=true; run unchanged verifier through both routes and preserve actual output/exit. Static prediction is both still succeed. No data destruction is needed to prove this verifier omission: effective TRUNCATE=true plus PostgreSQL's documented RLS exclusion is sufficient.
5. Revoke the synthetic direct grant, verify positive state, then repeat with **PUBLIC-only TRUNCATE** to establish the effective-grant case; restore immediately.
6. Optional, only if parent wants behavioral destructive corroboration: in a rollback-only transaction, switch to anon, TRUNCATE the synthetic standalone table, reset role, count as owner, then ROLLBACK and prove the seed survived. This optional step must never be promoted to a customer/HTTP exploit claim.

The semantic basis is PostgreSQL17's explicit exclusion of TRUNCATE from RLS and separate TRUNCATE privilege. ([PostgreSQL17 row security](https://www.postgresql.org/docs/17/ddl-rowsecurity.html), [TRUNCATE privilege](https://www.postgresql.org/docs/17/sql-truncate.html))

**Expected additional cost:** a handful of SQL/CLI invocations on the already provisioned fixture, roughly under 1–2 minutes excluding setup; no install, full replay, or broad suite solely for this discriminator. New evidence stays in the owning builder's packet; no candidate source modifications by auditors.

**Closure after a sole-owner fix:** positive protected state still passes, direct and PUBLIC-only effective TRUNCATE cases both fail with EXPOSURE through both routes, restoration passes, exact final-head applicability/dual follow-up. No grant widening or unconditional PUBLIC revoke is prescribed here: verifier should detect the target prerequisite/drift rather than silently alter wider grant ownership.

## Request B — S1-R3-A-E01, actual release composition packet

This is a pending evidence hold, not an allegation of a defect in the unrun composition. The parent brief says real composition is separately being built and is unrun; this review does not inspect or infer its outcome. ([Mandate](../../../EXECUTION_MANDATE.md))

Please return only:

- Exact integration commit/tree/base parents and clean/dirty fingerprint; S1 migration/down/verifier/guard/bootstrap hash applicability to `b7d7fe5964680050ab441c195055ea946282a9c3`.
- Target ownership/unique session namespace and immutable synthetic marker; offline refused-target controls **before connection/destruction**; nonblocking canonical lock held across preflight and all mutations.
- Actual parent-chain preparation: 164 real migration SQL applications, out-of-band legacy RLS pre-state, genuine ledger, then candidate 165 through the real release entry point. No ledger-only baselining or fake Prisma substitute. ([Corrected S1 interface](../../../../repos/tgp-private-evidence/2026-09-20/remediation/s1-r3/revision-1/ADDENDUM_02_full_parent_replay.md))
- Positive release exit 0 with actual verifier discovery/invocation; refusal/failure runs preserving real child/release exits, no success artifact on failure, and evidence that applicable missing/failed verifier cannot be skipped.
- At least one catalog exposure-drift and one allowed-path-drift failure through release, including the already-applied/out-of-band reversal case where Prisma status is not truth; late-lock migrate failure/recovery only to the extent claimed by this composition.
- Exact trusted verifier-artifact selection/integrity scope: what SQL is executed with privileged migration credentials, and why missing/stale/untrusted verifier selection cannot produce green.
- Explicit limitations: PG17.6 fixture, no serving-role measurement, no production backup/PITR, no PG15 or deployment clearance, no E-state recovery claimed merely from S1 reapply.

Do not duplicate the historical 89 checks for volume if S1 relevant inputs remain unchanged and applicability is shown. A changed S1 verifier must be named as a successor and receives scoped new evidence/review rather than being silently covered by the original run. ([G09/G10](../../../../repos/tgp-agent-context/AGENT_RULES.md))

## Retained S1-A-06 / S1-A-07 live/future-object reservation

Before any live clearance, the smallest additional observations remain: deployed app-client role (not DIRECT_URL/admin inference), effective allowed/denied privileges including non-CRUD destructive rights, actual relation/function owners and helper job caller, exact public direct-child namespace/topology, real history and authorized backup/restore readiness. If the parent wants complete partition drift verification rather than the bounded existing-flat-public claim, request wrong-parent/wrong-schema and detached-child controls, using original S1-A-07 rather than multiplying duplicate findings. ([Runtime-role packet](../../../../repos/tgp-private-evidence/2026-09-20/remediation/s1-r2/revision-1/RUNTIME_ROLE_VERIFICATION_PACKET.md), [verifier relation selection](../../../../initialization/recovered/s1-r3-b7d7fe5/prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql))
