# S8-D decision record (ded755ab) — independent T4 security/design review (EXEC-FA72EFB2)
Route: GPT-6 Sol (independent of the Claude Fable 5 author). Read-only; no PG/jest; never take the lock; edit nothing but your report.
Subject: /home/user/workspace/worktrees/fa72-s8d fa72/s8d HEAD ded755ab7626f3791b1d927095810658aef9893f (parent dda794d7),
docs/decisions/2026-09-26-s8d-person-link.md (+ appended §7 forward pointer in 2026-09-24-s8-native-contract.md). Author report
s8d/s8d_decision_record.md. Binding authority: execution/fa72efb2/OWNER_DECISION_S8D_2026-09-26.md (OFFICIAL, L1–L8 + D-S8-2 (a)).
Questions:
(1) Fidelity: does the record implement L1–L8 and D-S8-2 (a) exactly — nothing weakened (e.g. any automatic link path, any
    claimant-typed contact accepted, confirmation skippable, undo narrower/wider than decided, email as identity key)?
(2) Account-takeover and privacy: attack the link/unlink/merge design (forwarded invite, contact change after invite, OTP brute
    force/replay, invite enumeration, malicious or mistaken coach, cross-tenant, races claim vs unlink vs import vs revoke, account
    deletion during the window, disclosure before verification, audit tamper/loss). Verify claims against code file:line.
(3) Data model: XOR owner CHECK on the five tables vs existing writers/readers/RLS (anything that assumes non-null user_id breaks?),
    migration safety (expand-only? locks on large tables?), "imported" provenance definition, re-own/return idempotency.
(4) Slice plan: grades (highest consequence wins), LOC estimates, >1,000 LOC flags, dependency order, migration sequencing after
    the S11 173-pin, owner boundaries (production enablement, spending — SMS phone channel).
(5) Open questions OQ-1..OQ-13: classify each as DERIVABLE (propose the default that is safest and consistent with L1–L8, one
    line why) or OWNER (material product/security decision Bradley must make — say exactly what to ask in plain words).
Classify findings A/B/C (A/B with the five fields). Write s8d/s8d_review.md; verdict GO/NO-GO for landing the doc on
integration/importer and starting S8-D1.
