# B PG tooling recovery receipt (tooling only)

Grant: execution/cf8ff737/B_PG_TOOLING_RECOVERY_GRANT.md. Driver pg-tooling/b-pg-env-recovery.sh sha256 bce3ce1552bfb3bc9313eedb007b1e4decf191b0f5edf487b71fa00621f60ad2 (== grant), run once, `timeout -k 30 1500`, canonical slot held fd9 nonblocking 15:09:22Z -> released on exit (verified free after).

RC=0 STAGE=done START 2026-09-24T15:09:22Z END 2026-09-24T15:10:41Z (79 s).

Client: apt update rc0; postgresql-client-18 18.6-0ubuntu0.26.04.1 install rc0; /usr/bin/psql "psql (PostgreSQL) 18.6" sha256 a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94 (identical to C1 06:29Z record).
Server: Maven jar curl rc0, .sha1 rc0; maven sha1 8163322358dbe4e6c2abccc90f2e543f8cfc65db == pinned; jar sha256 23da5a04...1d29d (14894072 B) == grant; txz 26fa6334...067c0 (14889140 B) == grant; extracted /home/user/pg17/dist; `postgres --version` 17.6; postgres sha256 23cd1748...f873a == grant; initdb b7db9bc2...0882a == grant; pg_ctl af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401 (recorded prefix match); /home/user/pg17/PROVENANCE.txt result=success written.
VERIFY_OK: clusters_dir=absent, postgres_procs=0. No initdb/cluster/database/bootstrap/O-client/Jest/C1-S5 action. Worktree and node_modules untouched.

C (nonblocking): the inherited script's pre-final snapshot line hardcodes `sha256sum c1-env-recovery.log > RECEIPTS.sha256`; with the renamed log it wrote "No such file" (visible in launcher.out) and an empty RECEIPTS.sha256. Driver not edited post-run; the external MANIFEST.sha256 in pg-tooling/ covers the actual log/sentinel/launcher/receipt instead.

Next: single B PG proof remains ungranted; waits for both independent attestations of head 75a2863bf79a44f84050406d6878ec9a87f4053e and a separate parent proof grant.
