S11-A1 (T2, test-only): the one shared disposable-PG harness for S11 (docs/decisions/2026-09-26-s11-journey.md D-S11-6).

- Lane s11 (port 55648, g2_s11_disposable), derived from the landed g2-s9c harness (unchanged). Guard spec (no DB), RLS/posture spec (forced RLS on the S10-B tables), J01-J08 journey core.
- Review GO after three narrow fix rounds. v2: the J07 journey assertion is corrected after the first real-PG run (the legacy projection reports execution_epoch 1; test defect, delta review GO). Supersedes #552. Commit made with the repository hooks (eslint, prettier, tsc, R75). No src, prisma or contract change.
- Real-PG validation runs before landing. Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
- Stacked on S10-C (#555) and S10-D P; lands after them.
