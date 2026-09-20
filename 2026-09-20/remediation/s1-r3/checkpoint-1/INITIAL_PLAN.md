# S1 R3 fixer — initial plan (T4)

Sent to parent before implementation. Fixer, not auditor. Coordination IDs known: S2 `s2_r3_delivery_fixer_muaeepli`, S5 `s5_r3_validation_fixer_muaeeplq`.

## Identity

- Worktree: `/home/user/workspace/worktrees/s1-r3`, branch `execute/20260920-s1-r3`, created from exact frozen head `90a6647513f3566393764eee87237d9b5b1f150b` (verified `worktrees/s1` unchanged, clean, same head).
- Repository-local identity set and checked with `git var`: author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; gpgsign off; no AI trailers will be added.
- Requested builder routing: Claude Fable 5 / High. Actual runtime identity known to me: Claude (Anthropic) subagent inside Perplexity Computer; provider version/reasoning setting not exposed, not claimed.

## Fixture / package inventory (this sandbox, 2026-09-20 22:45 UTC) — NOTHING from R2 is present

| Item | R2 packet expectation | Present now |
|---|---|---|
| PG 17.6 server (zonky) `/home/user/pg17` + `lane-pg.sh` | installed | **absent** (no dir, no `initdb` anywhere) |
| `psql`/`pg_dump` client 18 | apt `postgresql-client-18` | **absent** (`which psql` empty; only libreoffice-sdbc-postgresql installed) |
| Backend `node_modules` (prisma 6.19.3 CLI) | `worktrees/s1-database/node_modules` | **absent** in `worktrees/{s1,s5,s2-r3}`, `repos/backend`; `/home/user/node_modules` has 209 unrelated packages, no `prisma` |
| Node | — | v20.20.1 present |
| `execution/test-validation.lock` | — | free (nonblocking flock succeeded) |
| Disk / CPU / RAM | — | 7.9 GB free, 2 CPU, 7 GB RAM |

`package-lock.json` at `90a6647` is blob `a23abae6…`, identical to backend `main c23b9d9`; so any backend dependency tree installed by another lane from the same lock is reusable read-only by S1 (symlink, disclosed) — none exists yet.

Smallest install set S1 actually needs for DB execution (only when parent grants the slot; not started):
1. `apt-get install postgresql-client-18` (psql/pg_dump) — or 17 if available.
2. zonky `embedded-postgres-binaries-linux-amd64 17.6.0` jar → `/home/user/pg17/dist`, sha1-verified as in `PG17_INFRA.md`; recreate `lane-pg.sh` from the archived copy (evidence `s1-r2/revision-1/infra/lane-pg.sh`) with **one change**: cluster_name marker for the disposable guard (see below).
3. Prisma CLI only: `npm install --no-save prisma@6.19.3` into an isolated tools dir (`/home/user/tools/prisma-cli`), NOT a full backend `npm ci` (the harness needs only `migrate deploy/status/resolve` and `db execute`). Harness gains `S1_PRISMA_CLI` override for this; default remains `node_modules/prisma/build/index.js`. If S2/S5 need a full `npm ci` anyway, S1 will reuse that tree read-only instead.

## Slices (all in `worktrees/s1-r3`; static work now, DB later)

### A. Harness disposable-target guard (S1-R2-A-01) — new `test/db/_support/s1-target-guard.sh`, sourced by the harness before ANY psql/node/pg_dump
Offline (no connection):
- `S1_PG_SUPER_URL` must match a strict literal grammar: `postgresql://<user>:<pw>@127.0.0.1:<port>/postgres`, user/pw `[A-Za-z0-9_]+`, no `?`, `%`, `,`, `;`, whitespace, second `@`, brackets, hostname (`localhost` rejected: not literal), IPv6, unix socket.
- `<port>` must equal `S1_PG_PORT` (pinned, default 54321).
- DB name argument must match `^s1_rls_[a-z0-9_]{1,40}$` (namespace); derived `${DB}_lock` too. Identifiers are still double-quoted in SQL.
- `S1_PG_DISPOSABLE_CONFIRM` must equal exactly `DESTROY-127.0.0.1:<port>` (double-entry, same design as S5's `G2_PG17_CONFIRM`).
Online preflight (one read-only connection, before any DROP/CREATE):
- `inet_server_addr()='127.0.0.1'`, `inet_server_port()=<port>`, `current_database()='postgres'`, session role is superuser (needed for bootstrap), `server_version_num` in `[170000,180000)`.
- `cluster_name` must equal `s1-disposable-pg17` (set in the lane's postgresql.conf; a real/hosted cluster never has it).
- No database outside `{postgres,template0,template1} ∪ s1_rls_*` exists in the cluster (an unrelated local DB or tunnel target fails closed).
- If `postgres`/`authenticator`/`service_role`/`anon`/`authenticated` roles pre-exist, their flags must match the bootstrap expectations (nosuper/bypassrls/login/inherit); do not rely on `IF NOT EXISTS` for fidelity.
- Every rejection prints `S1-GUARD REFUSED <code>: …` and exits 64 before any destructive command.

### B. Offline negative tests — new `test/db/s1-harness-guard.spec.sh`
Runs the real harness entry point with a PATH-first recording stub for `psql`, `pg_dump`, `node`. Cases: remote host, `localhost`, IPv6 loopback, wrong port, query-string override, `@` override, non-namespace DB name, SQL metacharacters/quotes/`;` in DB name, over-long name, missing/wrong confirmation, wrong DB in URL path; plus preflight-stub cases (wrong version, missing cluster_name, foreign database present, non-superuser) and one positive case that reaches exactly the preflight query and nothing destructive. Assertion per case: nonzero exit with the expected code AND zero recorded `DROP`/`CREATE DATABASE`/`node`/`pg_dump` invocations. Needs only bash — parent can run it now (seconds, no DB).

### C. Discriminating recovery proof (S1-R2-A-02 / S1-R2B-01 / -02) — harness §3 edits
- Blocker moves to `community_messages_2027_01` (protected in the second DO, after the 14-table DO and helper `CREATE OR REPLACE`s). After both the direct `psql -1` failure and the real `prisma migrate deploy` failure, assert: 18 still exposed (14-table DO rolled back), `community_messages_protect_partition` absent, `create_month_partition` search_path unpinned, `app.*` helpers unpinned, failed history row present. Blocker liveness is asserted (a dead blocker marks the test FAIL, not PASS).
- Same-session timeout checks: one psql session runs a control `SET lock_timeout='5s'` (proves the check can observe a leak), then `\i migration.sql`, then reads `current_setting` in the same session → expects defaults. Failure path: same-session read after the 55P03-aborted transaction. Success and failure paths are labelled and reported separately; Prisma-path same-session state is declared not observable/not claimed.
- Retain failed-history/resolve/deploy recovery checks.

### D. Verifier grant/role consistency (S1-R2B-03/-04, with S2) — `verify.sql`
- No GRANT added to the migration; no check demoted. Problems are classified `EXPOSURE` (RLS/policy/API privilege) vs `ALLOWED-PATH` (service_role privilege, partition attachment, function presence) and the exception message names both counts and classes so a release operator can tell them apart. Still exit nonzero on either.
- Tighten: service_role policy predicates `true/true`; exact `search_path` values; function set by exact signature.
- Synthetic evidence in the harness: (i) post-apply verify passes on the Supabase-like fixture; (ii) `REVOKE … FROM service_role` on one table → verify fails with ALLOWED-PATH only and zero EXPOSURE, then restored; (iii) `prisma db execute --file verify.sql` exit code nonzero on pre-state/drift and zero on protected state — the fact S2's release gate needs. Interface fact for S2: expected verifier set at the integrated head = `prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql` (S1) — S1 does not add others.

### E. Comment/claim corrections — `migration.sql`, `down.sql`
Whole-file rollback wording describes the late-stage test rather than asserting OBSERVED before the run; idempotent re-apply advice stays only for THIS migration (it is idempotent) and explicitly says it does not transfer to non-idempotent migrations such as G2-E.

### F. E-specific recovery packet (document only; E lives in the G2 stack, not this worktree) — `execution/s1-r3/E_RECOVERY_PACKET.md`
State-dependent directions for `20270118000000_scout_ledger_platform_expand`: never applied / failed attempt (lock vs prerequisite guard) / applied / applied-then-drained-down (history says applied, P3012 refusal) / down refused (assigned provenance, wrong shape) / column present without history / wrong-shape column / hosted history with foreign rolled_back rows; each with the catalog query that identifies it, ownership/policy/data invariants, and the intentional rerun refusal (`platform column already exists` is by design, so "re-run idempotently" is WRONG for E). Includes the corrected T-service accounting wording (S5-A-09) as an exact proposed comment patch against the G2 head for the parent to route to that stack's owner; not applied in this worktree (file differs at `c23b9d9` vs `fdbbaef`; editing it here would create a conflicting writer).

### G. Heavy-run wrapper — `execution/s1-r3/run-proof.sh`
Nonblocking `flock -n` on `execution/test-validation.lock`; stamps exact head/tree/clean state, psql/node/prisma versions, package-lock and CLI hashes, command, start/end, `pipefail`, real child exit code preserved, failed attempts kept.

## Ownership intersections
- S2: consumes `verify.sql` classification and `prisma db execute` exit-code evidence; S1 writes neither release.sh nor workflows. S1 needs from S2 only: confirmation of the discovery glob/expected-set format so the verify.sql path stays discoverable (path unchanged).
- S5: E packet directions only; S5 keeps validation-only. Recovery wording will be shared with S5 for consistency with its stage-5 assertions before freezing. S1 does not touch `test/rls-g2-*`.
- Nobody else edits `prisma/**`, `test/db/**` in this lane.

## Minimal validation request to parent (not before the offline guard is reviewed)
1. Now: review guard source + run `test/db/s1-harness-guard.spec.sh` (bash only, ~5 s).
2. Then one bounded slot (~25 min including installs): install items 1–3 above, init/start a fresh `s1` cluster on 127.0.0.1:54321 with `cluster_name='s1-disposable-pg17'`, run `execution/s1-r3/run-proof.sh` once (harness ~3–4 min based on run-05 timings). Synthetic only; no hosted/customer URL; not hosted applicability.
3. Then S5 slot; then integrated S1/S2 verifier probe if S2 needs one beyond (D iii).

No product push, PR, deploy, flag, or live DB access requested.
