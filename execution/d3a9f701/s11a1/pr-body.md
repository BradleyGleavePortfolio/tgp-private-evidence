S11-A1 (T2, test-only): the one shared disposable-PG harness for S11 (docs/decisions/2026-09-26-s11-journey.md D-S11-6).

- Lane s11 (port 55648, g2_s11_disposable), derived from the landed g2-s9c harness (unchanged). Guard spec (no DB), RLS/posture spec (forced RLS on the S10-B tables), J01-J08 journey core.
- Review GO after three narrow fix rounds. Commit made with the repository hooks (eslint, prettier, tsc, R75). No src, prisma or contract change.
- Real-PG validation runs before landing. Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
