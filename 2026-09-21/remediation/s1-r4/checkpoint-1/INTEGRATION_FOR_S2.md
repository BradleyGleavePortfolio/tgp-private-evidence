# S1 R4 → S2 composition: minimal integration instructions (early, source frozen, unrun)

Goal: prove S1-R3-A-01 closure on S2's guarded PG 17.6 fixture (real 164-parent replay + candidate 165) without a
second fixture or a second full 89-check replay. S2 keeps ownership of the delivery harness and the lock-bearing
wrapper; S1 owns only the files listed here. Nothing here asks S2 to change CI, bootstrap or release.sh.

## What to merge

- Successor head `41f4d6a985e5037bf53831a38ed00a9a4314cf7d` (tree `8ab0eb9e942686896a0039038a2d3bbbe2aa4b06`), branch
  `execute/20260921-s1-r4`, parent = the already-composed S1 head `b7d7fe5964680050ab441c195055ea946282a9c3`.
- Source: `execution/s1-r4/s1-r4-41f4d6a9-from-public-c23b9d9.bundle` (prerequisite public `c23b9d9f…`, `git bundle verify` okay) or
  `s1-r4-41f4d6a9.patch` (one commit; `git am` keeps author/committer Bradley Gleave).
- Touched files (sha256 at HEAD):
  - `prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql` `266e62e9ed6def7491e886c1f9648ce31dd95d62931c839fb84db2b3140a9448` (replaces `2bbce0d7…323e`; B's EVIDENCE-REQ-01(d) "new hash with a diff" → the diff is in the patch)
  - `test/db/s1-rls-close-public-exposure.sh` `776a0339813d1bcd868e9c9a3d197b7ae54ed9f744eb9d886f3ad6ea7c33b5fd`
  - `test/db/_support/s1-truncate-controls.sh` `a9298c36a40720c1891a240b267c26391a1336e6c0f021eda0766a6e033d037e`
  - `test/db/s1-r4-truncate-discriminator.sh` `a7738d7381d584e01a33f8643a9b2287fbb5e55e4dcaf85980147042d4266403`
  - `migration.sql` / `down.sql` / guard / bootstrap: byte-identical to b7d7fe5 (no product SQL change besides verify.sql).
- The composed tree MUST contain commit `b7d7fe59…` in history: both entry points `git show b7d7fe5964680050ab441c195055ea946282a9c3:<MIG_DIR>/verify.sql`
  to obtain the predecessor verifier and fail closed if its sha256 ≠ `2bbce0d7ca2e2761f6a6b3d5cebe2df752ac47767f9936d0b77357a46996323e`.
  A shallow clone or a squash would make the controls FAIL (visibly, not skip).

## Preferred run shape (share the fixture, one extra step, ~1–2 min)

After S2's own composed proof leaves a database in the PROTECTED state (candidate 165 applied, current verify.sql
passing) and while S2's wrapper still holds the canonical lock `/home/user/workspace/execution/test-validation.lock`:

```bash
# from the composed repo root, same env S2 already uses for the guard
S1_PG_SUPER_URL='postgresql://<super>:<pw>@127.0.0.1:54321/postgres' \
S1_PG_PORT=54321 \
S1_PG_DISPOSABLE_CONFIRM='DESTROY-127.0.0.1:54321/<db>,<db>_lock' \
S1_PRISMA_CLI=<abs path>/node_modules/prisma/build/index.js \
S1_PROOF_LOG=<evidence dir>/s1-r4-discriminator.detail.log \
S1_R4_LOCK_HOLDER='<wrapper script name + pid holding test-validation.lock>' \
timeout --foreground 300 bash test/db/s1-r4-truncate-discriminator.sh <db> 2>&1 | tee <evidence dir>/s1-r4-discriminator.log
# preserve the pipeline's real exit: use `set -o pipefail` or capture ${PIPESTATUS[0]}
```

- `<db>` must match `^s1_rls_[a-z0-9_]{1,40}$` and be the database that already holds the applied candidate.
- Guard requirements are the harness's, unchanged: literal `127.0.0.1`, pinned port, `s1_rls_*` namespace, exact
  `DESTROY-…` confirmation, preflight proving `cluster_name='s1-disposable-pg17'`, data dir under `/home/user/pg17/clusters/`,
  superuser, PG 17.x, no foreign databases, fixture role flags (postgres=fttt, authenticator=fftf, service_role=ftff,
  anon/authenticated=ffff). The script destroys nothing (no DROP/CREATE/replay; only GRANT/REVOKE TRUNCATE on the
  seeded standalone `"MuxProcessedEvent"`, restored; one TRUNCATE inside a rolled-back transaction).
- If `S1_R4_LOCK_HOLDER` is unset the script takes the canonical lock itself nonblocking (exit 75 if busy). Set it when
  the wrapper already holds the lock; the value is stamped verbatim.
- Fixture passwords assumed = bootstrap constants (`postgres_local_synthetic`, `authenticator_local_synthetic`); if
  S2's fixture uses others, the precondition checks fail closed and I need to know.
- If `"MuxProcessedEvent"` is empty on the fixture the script inserts ONE synthetic marker row
  (`mux_event_id='s1-r4-synthetic-control'`) and deletes it at the end (stamped "note: …").
- Exit 0 ⇔ all checks pass (expected 44, or 45 with the marker row). Non-zero on any FAIL or precondition miss.

Stamps printed by the script itself: start/end UTC, head/tree/branch, scoped status fingerprint, sha256 of verify.sql /
controls / guard / discriminator / prisma CLI, prisma+node+psql versions, server_version, redacted super URL, port,
confirm literal, lock stamp, guard acceptance. S2's wrapper should additionally stamp its own lock identity and the
composed head as it already does.

## Alternative (if sharing is not possible)

Run the full S1 harness at the composed head under the preserved `run-proof.rev2.sh` pattern; §4b runs automatically on
DB1 and the expected total becomes 128 (89 + 3 + 36). This duplicates S2's replay and is the fallback only.

## What I need back

`s1-r4-discriminator.log` + `.detail.log` (or the full-harness log) with exit code, into `execution/s1-r4/runs/` or a
path you name. I will not edit them; I write the run report against them.
