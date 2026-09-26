S10-D P (T1, test-only): the native-families, manifest-registry, mapping-spec and facts coverage specs state shipped-source invariants instead of assuming no source package ships on disk, so a new source package can land without editing core tests (prerequisite for the S10-D core-diff gate).

- Review GO. Devloop green (27 suites, 498 tests); eslint and prettier clean. No src, prisma or contract change.
- Stacked on S10-C (#555). Landing: one ordinary fast-forward push of this exact head after S10-C lands and CI is green. The merge button is not used. Non-production. `main` is untouched.
