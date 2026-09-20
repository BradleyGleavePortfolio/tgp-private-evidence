# S1 R3 fixer report — builder evidence (not self-audit)

- **Head:** `7cbbb03977455fcfb5da543bdaffaf5de3c45696` on `execute/20260920-s1-r3` (worktree `worktrees/s1-r3`), tree `81b5614f4f2fcbc2825de3bd429cc64f1d0108d8`, parent = frozen R2 head `90a6647513f3566393764eee87237d9b5b1f150b`. Status clean at report time (0 lines `git status --porcelain --untracked-files=all`).
- **Identity:** author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` (verified via `git var` before and `git cat-file -p HEAD` after); no trailers (`%(trailers)` empty); gpgsign off; repository-local config; nothing pushed.
- **Frozen material untouched:** `worktrees/s1` still at `90a6647`, clean. No R2 packet, audit report or bundle modified.
- **Bundles:** `s1-r3-7cbbb03-from-public-c23b9d9.bundle` (requires public backend `main c23b9d9`; contains 620b47f, 90a6647, 7cbbb03) and `s1-r3-7cbbb03.bundle` (requires 90a6647). Patch `s1-r3-7cbbb03.patch`. `SHA256SUMS` covers everything in this directory.
- **Executed in R3:** only the offline guard spec (`offline-guard-spec-head-7cbbb03.log`, 72/72 pass, exit 0, on the clean committed head, `psql` absent from PATH so stubs were the only executables). **No database, install, build or Prisma execution happened.** All DB-dependent claims below are *designed and unrun*.

## Change inventory (6 files, +614/−78)

| File | Change |
|---|---|
| `test/db/_support/s1-target-guard.sh` (new) | Two-layer disposable-target guard, exit 64 with `S1-GUARD REFUSED <code>` |
| `test/db/s1-harness-guard.spec.sh` (new) | 40 offline cases (72 assertions) with recording stubs |
| `test/db/s1-rls-close-public-exposure.sh` | Guard wired before any command; quoted identifiers; `${1-default}`; `S1_PRISMA_CLI`; §3 rewritten (late-stage lock, same-session checks, `prisma db execute` exit codes, verifier class probes, deterministic blocker release, liveness asserts) |
| `…/verify.sql` | EXPOSURE / ALLOWED-PATH classes; predicates, signatures, exact search_path, service_role EXECUTE; preconditions documented |
| `…/migration.sql`, `…/down.sql` | Comment corrections only (atomicity claim, idempotency scope, preconditions) |

## Finding dispositions

| Finding | Disposition | Where | Evidence state |
|---|---|---|---|
| S1-R2-A-01 destructive harness with no target guard | **Fixed (offline-proven).** Literal `127.0.0.1` URL grammar; pinned port; `^s1_rls_[a-z0-9_]{1,40}$` namespace with 63-byte limit incl. `_lock`; confirmation `DESTROY-127.0.0.1:<port>/<db>,<db>_lock`; read-only bounded preflight (addr, port, db, superuser, PG17.x, fixed `cluster_name=s1-disposable-pg17`, canonical data_directory under fixed `/home/user/pg17/clusters/` existing locally with no symlink escape, no foreign DBs, fixture role flags). Quoted identifiers. | guard, harness lines 34–40, 90 | 72/72 offline; refusal before any connection for URL/DB/CONFIRM classes, before any mutation for preflight classes; positive control reaches exactly one preflight then the quoted DROP/CREATE. Real-server preflight behaviour **unrun**. |
| S1-R2-A-02 / S1-R2B-02 atomicity test not discriminating | **Redesigned (unrun).** Blocker on `community_messages_2027_01` (second DO block); asserts `EXPECTED18` unchanged AND helper catalog pre-state (`protect_partition` absent, `create_month_partition` unpinned, `app.*` unpinned, 0 policies on the partition) after both psql `-1` and real `prisma migrate deploy` failures; blocker liveness asserted before each attempt. | harness §3 (3a, 3c) | Needs the synthetic slot. |
| S1-R2B-01 vacuous fresh-connection timeout proof | **Redesigned (unrun).** Success path: one connection, control `SET lock_timeout='5s'` observed, `\i migration.sql`, read → expects `0|0`; same for `down.sql`. Failure path: one connection `BEGIN; \i; ROLLBACK;` under held lock, expects exactly one 55P03 and `AFTER=0|0`. Prisma-session state explicitly declared not observable/not claimed. | harness 3b, 3g | Needs slot. |
| S1-R2B-03 verifier 1b mixes precondition with exposure | **Fixed in source (unrun).** Two classes in the exception text; both fail the gate; no GRANT added, no check demoted; preconditions P1–P4 written into verify.sql and migration.sql header. Synthetic probes: REVOKE from service_role → `0 exposure; 1 allowed-path` naming the privilege; RLS disable → `1 exposure; 0 allowed-path`; restored and re-verified. | verify.sql; harness 3e | Needs slot. Classification alone does not close a grant mismatch on a real target — that remains a precondition the target owner must satisfy; the verifier now says so instead of hiding it. |
| S1-R2B-04 `prisma db execute` exit code unverified (shared S2) | **Asserted in harness (unrun):** non-zero on pre-state, non-zero on allowed-path drift, zero on protected state. Interface fact to S2: verifier path unchanged; both routes fail closed. | harness 3 (`prisma_verify_rc`) | Needs slot; S2 needs only the log lines. |
| S5-A-05 / S5-B-04 generic idempotent recovery advice | **Corrected.** S1-DB-01 comments scope idempotency to that file and name E as a counter-example; `E_RECOVERY_PACKET.md` gives state-by-state directions (E0–E9) with discovery queries. | migration.sql, down.sql, packet | Directions only, **not executed**. |
| S5-A-09 accounting comment overclaims | **Direction + exact patch text** in the E packet §4; not applied here (file lives in the G2 stack at a different base; applying it in s1-r3 would create a conflicting writer). | packet §4 | Needs G2 stack owner. |
| S5-A-07 PG15 docs vs PG17 fixture | Note only: guard admits PG 17.x exclusively; PG15 remains the CI/hosted version and is a separate gate (parent's ruling). | guard | — |

## Parent review items (mail 15:51) — all addressed

(1) `${1-default}`: explicit empty refused, DB_EMPTY case restored. (2) socket URL expected `URL_QUERY`; `%2F` socket → `URL_ESCAPE`; empty host → `URL_HOST`. (3) `SERVER_DATADIR` is preflight-only; offline list no longer contains a data-root code. (4) marker and root are constants, not env; canonical-path, existence and `realpath` checks; spec creates a throw-away dir and an escaping symlink under the fixed root and removes them (and the root, if it did not pre-exist). (5) `PGCONNECT_TIMEOUT=5`, `statement_timeout=5s`, `timeout -k 2 20`; `PREFLIGHT_TIMEOUT` code. (6) vacuous grep removed; positive controls split into fresh-cluster and pre-existing-correct-flags.

## Known limitations / unknowns

- Exact catalog serialisation of `SET search_path = ''` is accepted as either `search_path=""` or `search_path=` (both mean empty); the synthetic run will show which one PG17 emits.
- `roles=` preflight parsing splits on `+`; role names containing `+` are impossible for the fixed set, but the parser is not general-purpose.
- The guard's data_directory check requires the server to run on this host (loopback); it therefore also refuses a Docker-published 127.0.0.1 port whose data directory is not visible — intended.
- Timing bounds (≤12 s direct, ≤20 s Prisma) are R2 values plus margin; a 2-CPU slot with cold Prisma may exceed the Prisma bound once; the wrapper preserves failed attempts.
- No claim about hosted applicability, S2 workflow integration, or production is made.

## Minimal validation request (for the parent, when the S1/S2 tree exists)

1. Shared S1/S2 full `npm ci` (lock 62b05b90…) — owned by whichever lane the parent picks; S1 uses it read-only via `S1_PRISMA_CLI=<tree>/node_modules/prisma/build/index.js`.
2. `apt-get install postgresql-client-18` (psql/pg_dump); zonky PG 17.6.0 binaries into `/home/user/pg17/dist` — the pinned artifact publishes SHA1 only on Maven Central; the wrapper/infra log will record the SHA256 of the downloaded jar so the limitation is explicit.
3. `lane-pg.sh s1 init/start` (recreated from the R2 archive) with two additions: `cluster_name = 's1-disposable-pg17'` and data dir `/home/user/pg17/clusters/s1` (canonical, no symlink).
4. One run: `execution/s1-r3/run-proof.sh 1` with `S1_PG_SUPER_URL=postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres S1_PG_PORT=54321 S1_PG_DISPOSABLE_CONFIRM='DESTROY-127.0.0.1:54321/s1_rls_proof,s1_rls_proof_lock'`. Expected wall time ≈ 4–6 min; needs the validation lock (nonblocking).
