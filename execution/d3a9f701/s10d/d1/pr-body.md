S10-D part D1 (T3) per docs/decisions/2026-09-26-s10-induction.md D-S10-5 / D-S10-7.

- `nest-cli.json`: two asset entries for the data-only source manifests.
- `scripts/s10-core-diff-gate.sh`: executable CORE DIFF = 0 check (D-S10-5 checks 1-7; allowed paths must be regular 100644 blobs).
- Stacked on #549 (S10-B, a2c74e90); lands by fast-forward after #549. Review GO. Commit made with the repository hooks; nest build ok.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
