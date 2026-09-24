# UX-04/05/06 readiness brief grant (T3, read-only)

Parent EXEC-CE3748CB, ~20:15Z.

Lanes: UX-04 Import Start, Progress & Stop; UX-05 Failure, Partial & Recovery; UX-06 Imported Results & Native Deep Links. UX-01/02/03/07 accepted and landed (mobile main c7641cb3; extension staged at land/s4-r6 aa0abd83). UX-08 converges with S11/S12.

## Inputs (read-only)
- mobile `main` c7641cb3 (import/pairing screens, hooks, mirrors), extension `origin/land/s4-r6` aa0abd83 (`popup/*`, `background.js`, `shared/**`), backend `integration/importer` c7a5fe8d (scout ingest/progress/complete/reconstruct routes and contract).
- `tgp-private-evidence/execution/95633079/ux/**` (UX-01 journey spec, UX-07 design packet), `execution/e7d2385c/IMPORTER_PROGRESS_AND_PARALLEL_UX_PLAN.md`, `execution/cf8ff737/ux-doctrine/**`, `ux03-handoff-prep/**`, UX-03a/b/c acceptance records.
- `/home/user/workspace/docs/UX_DOCTRINE_APPLICABILITY.md`.

## Question
For each of UX-04/05/06: what the accepted spec requires; what already exists (exact files/lines, repo, head); the gap; which server/contract facts it depends on (existing, or blocked on S7-C/S8/S9/G3-AUTH — name exactly); and the first 1–3 path-disjoint, presentation-first build slices that are executable NOW without inventing server behavior, each with repo, base head, owned paths, tier (T0–T4 with trigger), acceptance evidence (tests/gates), and whether mobile or extension. Verify or refute the prior claim "extension popup markup for 4 of 5 panels is unbuilt".

## Constraints
No product edits, no npm install, no runtime. Output only `/home/user/workspace/execution/ce3748cb/ux-readiness/UX04_06_BRIEF.md` (≤200 lines). No full-doctrine conformance claim.
