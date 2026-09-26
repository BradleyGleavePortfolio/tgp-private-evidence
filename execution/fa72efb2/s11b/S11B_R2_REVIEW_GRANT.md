# S11-B r2 (9149f823) — independent T4 delta review (EXEC-FA72EFB2)
Route: GPT-6 Sol (second T4 lens; not the fixer). Read-only; no PG/jest; never take the lock; edit nothing but your report.
Subject: /home/user/workspace/worktrees/fa72-s11b fa72/s11b-r1 HEAD 9149f82381c38cdee8caf9b2b7ff47b2d358ac21, parent
4d31616f (dual T4 GO; live J13 failed — PROOF_A_V1_FINDING.md). Delta: lifecycle.service.ts (isSerializationFailure also true
for P2010 with meta.code 40001/40P01) + lifecycle.service.spec.ts (3 cases). Fixer report s11b_r2_fix.md. Review the DELTA only.
Questions: (1) Is the Prisma 6.19.3 raw-error shape claim right (verify in node_modules read-only)? (2) Is widening the retry
safe for every caller of settleWithSnapshot: each attempt re-locks and re-checks terminal/epoch, retry is idempotent, bounded
by SETTLE_ATTEMPTS, and nothing non-serialization is newly retried? Could a retried tail double-write anything (basis, ledger,
events) or change a terminal already decided? (3) J13 after the fix: the loser retries, sees the terminal, returns null → ack;
does the spec's expectRedriveTrace/ack assertion hold on that path? Any other live J12–J16 / S9 / S10-C test whose outcome
this change flips (e.g. a test that expected a 500 on raw contention, rls-g2-s10c R36)? (4) Tests discriminate (mutation note).
Classify A/B/C (A/B five fields). Write s11b/s11b_r2_review.md; verdict GO/NO-GO.
