# S1 R4 — source successor for S1-R3-A-01 (effective TRUNCATE gap in verify.sql)

Status: SOURCE FROZEN, UNRUN. No install, no database, no test execution has happened in this lane. Every
"expected" statement below is a static claim about scripts that have not yet been executed; it becomes a
result only after a parent-named slot produces stamped logs. I cannot self-certify acceptance.

## Identity

| item | value |
|---|---|
| lane worktree | `/home/user/workspace/worktrees/s1-r4` (isolated `git clone --no-hardlinks` of the frozen base; remotes `recovered-s1` → frozen base, `public-local` → `/home/user/workspace/repos/growth-project-backend`; no remote pushes) |
| branch | `execute/20260921-s1-r4` |
| predecessor (frozen base) | `b7d7fe5964680050ab441c195055ea946282a9c3` (tree `abc1ac55bd8f93383b7b0075ec9a4c856e4455d9`), untouched at `/home/user/workspace/initialization/recovered/s1-r3-b7d7fe5` |
| successor head | `41f4d6a985e5037bf53831a38ed00a9a4314cf7d` |
| successor tree | `8ab0eb9e942686896a0039038a2d3bbbe2aa4b06` |
| working tree | clean (`git status --porcelain` = 0 lines after commit) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both (checked with `git var` before and `git cat-file -p HEAD` after; no trailers) — see `HEAD-41f4d6a9.commit-object.txt` |
| public prerequisite | bundle requires public backend `main` `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; `git bundle verify` = okay |
| files | `s1-r4-41f4d6a9.patch`, `s1-r4-41f4d6a9-from-public-c23b9d9.bundle`, `s1-r4-41f4d6a9.diffstat`, `SHA256SUMS` (this directory) |

Commit: one commit on top of b7d7fe5. `git diff --stat b7d7fe5..HEAD`: 4 files, +312/−4.

| file at HEAD | sha256 | change |
|---|---|---|
| `prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql` | `266e62e9ed6def7491e886c1f9648ce31dd95d62931c839fb84db2b3140a9448` (was `2bbce0d7…323e`) | +15/−3; ONE executable token added: `'TRUNCATE'` in the API-role privilege array; rest is comment truth |
| `prisma/migrations/…/migration.sql` | `72b0ad5a07cd6ccbcc1e88ef94e311606fb1a85d97f0efa6c38cf87de3cae344` | byte-identical to b7d7fe5 |
| `prisma/migrations/…/down.sql` | `dd7dd6f33f03fb0738e635530e69299741c1ec4d6e6a848e15ed937a74a7bdeb` | byte-identical to b7d7fe5 |
| `test/db/s1-rls-close-public-exposure.sh` | `776a0339813d1bcd868e9c9a3d197b7ae54ed9f744eb9d886f3ad6ea7c33b5fd` | +19/−1: header note and new §4b block (DB1, after "verify.sql still passes after re-run", before §5) |
| `test/db/_support/s1-truncate-controls.sh` (new) | `a9298c36a40720c1891a240b267c26391a1336e6c0f021eda0766a6e033d037e` | the shared 36-check control set |
| `test/db/s1-r4-truncate-discriminator.sh` (new, +x) | `a7738d7381d584e01a33f8643a9b2287fbb5e55e4dcaf85980147042d4266403` | narrow standalone entry point for an already-protected `s1_rls_*` database |
| `test/db/_support/s1-target-guard.sh` | `6f66e43624fd7ad4337b9b4b67e108fc2192230e8b6e8cc4287b193fe997a8ec` | unchanged |
| `test/db/_support/supabase-like-bootstrap.sql` | `e8c42d2e6f2173f0d4acbf5cf47316c4aefaad23aee023e6e08171a6e536da60` | unchanged (B's PG15 CI bootstrap note is not acted on here, per parent) |

Static checks done (cheap, allowed pre-slot): `bash -n` on all three scripts; `git diff --check` clean; no shellcheck on this host.
Not done: any execution.

## Finding disposition

### S1-R3-A-01 — verifier missed effective TRUNCATE — FIXED IN SOURCE, PROOF PENDING

Cause (auditor A, confirmed by my read of frozen `verify.sql:134-139`): the API-role effective-privilege loop
checked `SELECT, INSERT, UPDATE, DELETE` only. PostgreSQL row security is consulted for those four commands
only; `TRUNCATE` is a separate table privilege, so `GRANT TRUNCATE ON public."MuxProcessedEvent" TO anon`
(or `TO PUBLIC`) leaves RLS enabled+forced with deny-all policies intact and the frozen verifier prints
`VERIFY OK` while `anon` can empty the table.

Fix: `verify.sql:147` array is now `['SELECT','INSERT','UPDATE','DELETE','TRUNCATE']` inside the existing
`has_table_privilege(api_role, format('public.%I', t), priv)` loop, i.e. effective semantics — a direct grant,
a PUBLIC grant and an inherited membership are all reported, one `EXPOSURE: <rel>: <role> still holds TRUNCATE`
line per API role. Header comment states the RLS/TRUNCATE rationale and that REFERENCES/TRIGGER are not checked.

Deliberately NOT changed (scope per dispatch and auditor A):
- no `GRANT`/`REVOKE` change in `migration.sql`, no unconditional `REVOKE … FROM PUBLIC` (the migration only
  revokes from anon/authenticated; a PUBLIC-held privilege is a drift the verifier now names, not one the
  migration silently removes);
- service_role ALLOWED-PATH precondition list stays `SELECT/INSERT/UPDATE/DELETE` — the migration does not
  rely on service_role TRUNCATE and a passing verifier must not start demanding it;
- OK notice text unchanged (`S1-DB-01 VERIFY OK: 18 relations protected (4 community_messages partitions)…`),
  so every existing harness assertion and B's EVIDENCE-REQ-01(b) string still hold;
- REFERENCES / TRIGGER not added (not asked; neither reads, writes nor destroys rows; listed as a known
  non-coverage in the verifier header and below so nobody reads the gate as "all privileges").

Regression controls (`s1_truncate_controls`, run on the seeded standalone `public."MuxProcessedEvent"` — confirmed
in `prisma/schema.prisma:5248-5256` to have no relations; the control set also asserts
`pg_constraint … confrelid` = 0 at run time):

| id | state | asserted (both verifier routes = psql `-X -v ON_ERROR_STOP=1 -f` and `node <pinned prisma> db execute --url --file`) |
|---|---|---|
| C0 | protected | seeded ≥1 row; no FK references; anon and authenticated effective `S,I,U,D,T` = `f,f,f,f,f`; CURRENT verify exit 0; PREDECESSOR verify exit 0 (agree on positive) |
| C4 | protected | rollback-only `SET LOCAL ROLE anon; TRUNCATE` → `42501`; rows intact |
| C1 | `GRANT TRUNCATE … TO anon` | anon `f,f,f,f,t`; authenticated unchanged; RLS flags/policies unchanged (`t,t,3`); **PREDECESSOR exit 0 (false green)**; **CURRENT psql exit non-zero**, `1 exposure problem(s); 0 allowed-path problem(s)`, `EXPOSURE: MuxProcessedEvent: anon still holds TRUNCATE`; **CURRENT prisma route non-zero**; rollback-only probe: `00000`, in-txn count 0, owner count after ROLLBACK = seed; REVOKE → `f,f,f,f,f`, verify 0 |
| C2 | `GRANT TRUNCATE … TO authenticated` | `f,f,f,f,t`; CURRENT non-zero; `EXPOSURE: MuxProcessedEvent: authenticated still holds TRUNCATE`; REVOKE → verify 0 |
| C3 | `GRANT TRUNCATE … TO PUBLIC` | 0 direct anon/authenticated ACL entries (effective-only); both roles `f,f,f,f,t`; **PREDECESSOR exit 0**; **CURRENT psql non-zero**, `2 exposure problem(s); 0 allowed-path problem(s)`, both roles named; **CURRENT prisma non-zero**; `REVOKE … FROM PUBLIC` → both `f,f,f,f,f`, verify 0 on psql AND prisma routes; rows intact |

The predecessor verifier is not a copy: both entry points run `git show b7d7fe5964680050ab441c195055ea946282a9c3:<MIG_DIR>/verify.sql`
into a temp file and FAIL (never skip) unless its sha256 equals the pinned frozen hash `2bbce0d7ca2e2761f6a6b3d5cebe2df752ac47767f9936d0b77357a46996323e`
and `cmp` shows it differs from the current file. This is the "predecessor fails / current passes" discriminator
the dispatch asked for, phrased in the verifier's own terms: predecessor exit 0 on a drifted state = the defect;
current exit non-zero = the fix. No data is ever destroyed: the only TRUNCATE executed runs inside a transaction that
is rolled back, and the seeded row count is asserted equal before and after.

Expected totals (static): full harness 89 → 128 checks (3 §4b framing + 36 controls); standalone discriminator 44
checks (45 when it has to insert its own synthetic marker row into an empty control table). Run-time truth will
replace these numbers.

### Preserved closures (unchanged source ⇒ preserved by construction, re-proved when the full harness re-runs)

- S1-R2-A-01 / S1-R2-A-02 / S1-R2B-01 / S1-R2B-02 (late-stage atomicity, same-session timeout reset, recovery) —
  `migration.sql`, `down.sql`, guard, bootstrap and harness §§1–3 byte-identical; §4b is inserted after §4's
  "verify.sql still passes after re-run" and restores every grant before §5, and re-asserts the catalog snapshot
  of the other relations afterwards.
- S1-A-03 / S1-R2B-03 (verifier failure classes, prisma exit-code propagation) — §3e untouched.
- Guard 72/72 offline spec — guard byte-identical.

### Explicitly still open (not addressed here; must stay visible in any composition)

- S1-A-06 / S1-R3B-03: live serving-role BYPASSRLS, ownership and ACL grantor facts — EXTERNAL, needs operator
  read-only probe (B's EVIDENCE-REQ-02).
- S1-A-07: verifier topology limits — it derives partitions from `pg_inherits` of `public.community_messages`
  only, discards child namespace, and requires ≥1 partition; unchanged in R4.
- S1-R3B-02: verify gate wiring in `scripts/release.sh` — S2's scope; the new verify.sql hash
  `266e62e9…9448` plus the diff in `s1-r4-41f4d6a9.patch` is what B's EVIDENCE-REQ-01(d) asks for when the
  verifier changed.
- S1-R3B-04: PG 15 CI bootstrap default-grant mismatch — integration evidence gap, not changed here (parent).
- REFERENCES / TRIGGER effective privileges are not checked by the verifier (new explicit non-claim).
- The verifier is still demonstrated only from the fixture `postgres` role (BYPASSRLS owner) — B's S1-R3B-07 note.

## Failures / unknowns

- UNRUN: none of the new scripts has executed against a database; psql and PostgreSQL are not installed on this
  host; `/home/user/pg17` does not exist; no `node_modules` in the lane. A syntax or expectation error would only
  surface in the slot. Two spots I would watch first: (1) `s1_trunc_probe_rollback_only` parses
  `ERROR:  <SQLSTATE>:` from `psql -v VERBOSITY=verbose` output exactly as the frozen `sqlstate` helper does;
  (2) `q "$AUTHN_URL" "set role anon; select current_user"` relies on psql `-c` returning the last statement's
  output.
- The standalone discriminator requires the harness's `DESTROY-…` confirmation literal although it destroys
  nothing; that is intentional (one guard contract, no weaker variant) and is stated in its header.
- Full-harness count 128 is a static expectation, not a result.
