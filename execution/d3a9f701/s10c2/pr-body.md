S10-C2 (T2, contract-only): the importer contract publishes POST /api/scout/runs/declaration and POST /api/scout/runs/observation, which the scout module already mounts through the observation module.

- Regenerated OpenAPI delta: +2 paths, +6 schemas (declaration and observation DTOs and results); every existing path and schema, the bearer security scheme and info.version (2.0.0-c1-s2.0, additive change per the S8-F and S9-C precedent) are unchanged. The contract spec pins security, request and response schemas, codes and DTO fields.
- Review GO. No src or prisma change.
- Stacked on S10-C (#555), S10-D P (#556) and S11-A1 (#557); lands after them by one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
