# Current execution dispatches

See `SCOPE.md` for owner authority and exact pins.

- B/drain builder: `b_drain_exact_recovery_and_remainder_mufn6ybc`, ACTIVE exact recovery; sole next heavy-slot grantee. No PostgreSQL execution grant.
- J3 executor: `j3_r5_source_only_recovery_mufn6y98`, ACTIVE source-only recovery; no heavy-slot, environment, commit or gate grant.
- Parent: orchestration and private publication only; no product implementation or self-audit.
- Predecessor worker identities are historical assignments, not claimed live processes in this runtime.

No acceptance or execution beyond the durable predecessor results is claimed by this dispatch record.
