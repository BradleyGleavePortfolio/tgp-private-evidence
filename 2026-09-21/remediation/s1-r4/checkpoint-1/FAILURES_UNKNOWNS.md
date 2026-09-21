# S1 R4 — failures and unknowns (source stage)

- UNRUN. No script executed; psql/PostgreSQL absent on this host; no node_modules in the lane. All check counts
  (128 full harness, 44/45 standalone) are static expectations.
- Not self-certified. Independent acceptance requires the parent-named slot logs plus auditor review.
- Watch-list for first run (see REPORT.md "Failures / unknowns"): SQLSTATE parse in the rollback-only probe;
  psql -c multi-statement output in the authenticator precondition; fixture password assumptions
  (postgres_local_synthetic / authenticator_local_synthetic).
- Predecessor-verifier extraction requires b7d7fe59 in the composed tree's history (fails closed otherwise).
- Out of scope, left explicit: REFERENCES/TRIGGER not checked by the verifier; S1-A-06, S1-A-07, S1-R3B-02/03/04.
