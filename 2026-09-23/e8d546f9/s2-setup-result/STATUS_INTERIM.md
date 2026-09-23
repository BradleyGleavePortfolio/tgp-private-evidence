# S2 fresh setup — interim status (not frozen; superseded by SETUP_RESULT.md)

Executor: restore_upstream_proof_inputs_muddwjad (sole heavy owner under execution/e8d546f9/S2_SETUP_GRANT.md sha256 89b77ec5…defa52).

- Restoration report frozen first: execution/e8d546f9/upstream/REPORT.md (b16955a1…) + MANIFEST.sha256. Prerequisites confirmed at 00:55:59Z: PRE-OK 37/37; WT HEAD d5cd9b8b, tree c0ab87d4, porcelain 0; lockfile 62b05b90…1390; six script hashes exact; 10 GB disk, 7.7 GB RAM available; canonical lock absent; no other heavy workload (only the platform code-mode node daemon). ENV01: infra/logs and runs created; parents restored to 0555; 0 writable source files.
- S10 setup-10-e8d546f9: start 00:56:17Z, sentinel 0 at 00:56:29Z; postgresql-client-18 18.6 (psql ≥ 17); no survivors; lock FREE; source clean. ACCEPTED.
- S20 setup-20-e8d546f9: start 00:57:02Z, sentinel 0 at 00:57:04Z; PROVENANCE.txt result=success with all four pinned SHA256s (jar 23da5a04…, txz 26fa6334…, postgres 23cd1748…, initdb b7db9bc2…) re-hashed on disk; no cluster dir, no postgres process, no listener; lock FREE; source clean. ACCEPTED.
- S30 setup-30-e8d546f9: start 00:57:42Z pid 8027, RUNNING (npm ci --ignore-scripts on the locked graph in worktrees/s2-runner53). Exact `wait … 2300` observer detached, output → 30-wait.txt. Head/lockfile/clean prechecks inside the script passed.

Observation note: check-lock.sh prints "lock FREE" but returns rc 1 by construction (its last command is the /proc fd-scan test that finds no holder); the probe creates the empty canonical lock file — documented behaviour, recorded, not acted upon.
