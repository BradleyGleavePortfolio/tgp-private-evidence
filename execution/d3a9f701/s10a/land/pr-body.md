S10-A: pure unseen-source induction tier (T1/T2) per docs/decisions/2026-09-26-s10-induction.md D-S10-7.

- Scope: `src/scout/induction/{contract,parse,digest,verify,manifest-registry}.ts`, their five specs, `test/fixtures/scout/s10_pure/**` (14 files, frozen bytes). No schema, route, module registration or runtime wiring; nothing imports these modules yet (S10-C wires them).
- Head 92b96715 on e6f20300 (S9-C landing). Commit made with the repository hooks (prettier, eslint, tsc, R75 banned-cast tokens, commit-msg). Suites on this tip: 86/86.
- Missing or unverifiable evidence resolves to unknown (`known:false`), never zero.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
