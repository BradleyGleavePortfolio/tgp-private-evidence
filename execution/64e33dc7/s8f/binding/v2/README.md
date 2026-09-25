# S8-F PG proof binding v2 (source-only; nothing here has been executed; NOT GRANTED)

Prepared by RT-NEW-1 (EXEC-1910A060, owner reset of 2026-09-25) as the minimum derivation of the immutable v1 binding
(`../v1/`, BINDING.sha256 unchanged, 7/7 verified) for the NEW 1910a060 runtime. Reviewers A and B judged v1 logic
sound as a template (source GO); v2 keeps that logic and changes only:

1. Environment pins (REVIEW_A §5.3 / REVIEW_B §2.2): `D` → `binding/v2`, `RUNTIME_ROOT` →
   `/home/user/workspace/execution/1910a060/runtime`, `W` → `/home/user/workspace/worktrees/1910a060-s8f`
   (standalone clone at e1ec2fec, branch `exec1910/s8f`), lane `proof-s8f-v2/{clusters,run}/s8-f`,
   `EXPECT_{POSTGRES,INITDB,PGCTL,PSQL,NODE,NM_LOCK,NM_CLIENT,NM_CLIENT_SCHEMA,FIXTURE}_SHA` re-measured on this host
   (`tool-pins-reverify.txt`), lock inode commentary corrected to 667698.
2. CB1 (REVIEW_B): `PSQL=/usr/lib/postgresql/18/bin/psql` (the real client binary) is pinned and used for every psql
   call and `G2_S8F_PSQL`; `psql --version` major 18 asserted. The pg_wrapper dispatcher hash is no longer the pin.
3. CB2 (REVIEW_B): generated-client provenance — `prisma/schema.prisma` blob must be 2e328bbc (`EXPECT_SCHEMA_BLOB`),
   the generated `schema.prisma`/`index.d.ts` must contain `ImportNativeProvenance` AND `target_kind`; the generation
   receipt (postinstall `prisma generate` from that blob, prisma 6.19.3, deterministic re-generate) is in
   `execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md`.
4. CB3 (REVIEW_B): the hooks-installed check is kept as a current-state check only; the evidence that e1ec2fec was
   produced through the lefthook hooks is the original S8-F gate log (`COMMIT rc=0 hook_lines=8`), not this runner.
5. REVIEW_A: after the single jest run, `Tests: 11 passed, 11 total` is asserted (`EXPECT_TESTS=11`, counted by grep in
   `test/rls-g2-s8f.spec.ts` at e1ec2fec; no `.skip`/`.only`); mismatch fails with rc 72.
6. Dependency-tree comment: `node_modules` in W is the genuine `npm ci` output of RT-NEW-1 (lock unchanged, hidden lock
   05bc530a… equals the prior donor record) rather than a copied donor; the checks (real dir inside W, sha pins) are unchanged.

Unchanged from v1: every repo-content pin (heads, trees, blobs, schema sha, package-lock sha, 172 migrations, seven
accepted-file blobs, 17-path allow-list), lock discipline (`flock -n` fd 9 on `execution/test-validation.lock`, held to
exit, never deleted), once-only sentinel, fresh-lane preflight, other-lane hashing, stage bounds, committed bootstrap
without subcommand, identity stage, single jest invocation, bounded stop with data dir retained, post checks, receipts.
Port 55643 kept (free on this host; lane dir absent).

PG 17.6 identity claim: the runtime binaries under `1910a060/runtime/pg17/dist` were fetched fresh from the recorded
no-cost Maven route (zonky embedded-postgres-binaries-linux-amd64 17.6.0, sha1 8163322…) and hash-verified; their hashes
equal the predecessor's recorded artifact hashes. That is a same-artifact statement about bytes, not a claim that any
old runtime instance, cluster or proof state survives — none does (`execution/64e33dc7/recovery-reset` is absent).

Files: `s8f-pg-proof.sh`, `s8f-fixture.sh`, `PINS.txt`, `README.md`, `v1-to-v2-proof.patch.py`,
`v1-to-v2-fixture.patch.py` (the exact substitution scripts applied to copies of v1), `v1-to-v2-proof.diff`,
`v1-to-v2-fixture.diff`, `tool-pins-reverify.txt`, `BINDING.sha256`.

Not run. Not granted. Next: dual independent review of v2 → parent's separate single-run PG grant → this runner once
(`timeout -k 30 3600 bash .../binding/v2/s8f-pg-proof.sh`), only while no other lane holds the slot.
