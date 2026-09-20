Disclosure (2026-09-20 23:11Z): scripts/release.sh hardcodes /tmp/prisma_migrate.log, /tmp/prisma_status.log,
/tmp/prisma_verify.log, /tmp/prisma_verifier.log and /tmp/release_verifiers_discovered.txt (no TMPDIR support).
My offline probe p03 runs release.sh copies with a FAKE npx, so every p03 run (first ~22:49Z through the bound-to-head
FINAL run at 22:57:23Z) wrote FAKE content to those global paths. The five files quarantined here (mtime 22:57:23Z) are
the last such writes; their content is fake-npx output — e.g. "Error: P1010 S1-DB-01 VERIFY FAILED (drift)" is the
fake's canned string, NOT a real Prisma/S1 result — and must never be read as S1 or composition evidence.
They were moved out of /tmp so a later real-Prisma run (S1 or composition) cannot be confused by them.
I cannot prove whether any S1 artifact existed at those paths before my first p03 run (~22:49Z); S1's harness writes to
its own $LOG and S1's proof had not run at that time, so probably none, but this is unverified.
Follow-up for a later S2 head (not 1c6db2b6): make release.sh honour TMPDIR (or mktemp) so probes and real runs cannot
collide; the composition runner must snapshot/restore /tmp as the plan states.
