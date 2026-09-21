# S1 R3 — Independent audit B (final-head, read-only)

**Lane / round:** S1 (RLS close-public-exposure), R3, auditor **B**.
**Subject head:** `b7d7fe5964680050ab441c195055ea946282a9c3` (tree `abc1ac55bd8f93383b7b0075ec9a4c856e4455d9`), frozen copy `/home/user/workspace/initialization/recovered/s1-r3-b7d7fe5` (verified: HEAD matches, worktree clean).
**Evidence packet audited:** `/home/user/workspace/repos/tgp-private-evidence/2026-09-20/remediation/s1-r3/revision-1/` (SHA256SUMS + SHA256SUMS.addendum: all entries OK).
**Prior inputs:** S1 R2 audits A and B (`.../audits/s1-r2/{a,b}/revision-1/REPORT.md`), builder R3 REPORT + ADDENDUM_01 + ADDENDUM_02 + S2_COMPOSITION_INTERFACE + FAILURE_CLASSIFICATION + E_RECOVERY_PACKET + PARENT_NOTE.
**Not read:** anything under `execution/audits/s1-r3/a/` or auditor A messages (mandate: current-round auditors do not read each other).
**Method:** bounded static/source reasoning plus checksum, bundle and log cross-checks. **No database, install, test execution, Prisma or network use.** No source edited. Only this directory written.

## 0. Bottom line

| Question | Answer |
|---|---|
| Are the three product SQL files (`migration.sql`, `verify.sql`, `down.sql`) at `b7d7fe5` sound for their stated design (deny-all RLS + REVOKE for anon/authenticated on 18 relations, protected future partitions via wrapper, pinned helper search_path)? | **Yes, no new source defect found.** Product SQL is byte-identical to `7cbbb03` (diff `7cbbb03→b7d7fe5` touches only `test/db/**`). |
| Does the R3 test/proof layer close the R2 findings (S1-R2-A-01, S1-R2-A-02, S1-R2B-01…05)? | **Yes on the PG 17.6 synthetic fixture**, and the run-4 evidence is internally consistent with the frozen head (see §2). The atomicity/timeout proof is now discriminating, not vacuous. |
| Does the 89/89 run clear the live/hosted serving role, PG 15, or the S2 release gate? | **No.** It proves the candidate against a synthetic Supabase-shaped fixture on PG 17.6 with a superuser-bootstrapped, `postgres`-BYPASSRLS role model. Live role identity, grantor/ownership, PG 15 behaviour and release.sh gating remain **missing evidence / composition-dependent** (§3, §4). |
| Independent final-head attestation? | **Source/proof attestation for the S1 lane in isolation: given** (§5). **Composition-dependent attestation: reserved** pending the precise evidence listed in §4 / `EVIDENCE_REQUESTS.md`. |

## 1. What I verified independently

1. **Head identity.** `git rev-parse HEAD` = `b7d7fe59…`; tree `abc1ac55…`; `git status --porcelain` empty. Chain `b7d7fe5 ← 760104c9 ← 16a3a707 ← 7cbbb039 ← 90a66475 (R2) ← 620b47fc ← c23b9d9f (public main)`. Bundles `s1-r3-b7d7fe5.bundle` and `s1-r3-b7d7fe5-from-public-c23b9d9.bundle` verify OK and list HEAD = `b7d7fe59…`.
2. **Run-4 stamps match head.** `proof-run-04-head-b7d7fe5.log` records `harness_sha256=5b85bf3d…`, `guard_sha256=6f66e436…`, `bootstrap_sha256=e8c42d2e…`, `verify_sql_sha256=2bbce0d7…`, `migration_sql_sha256=72b0ad5a…`, `down_sql_sha256=dd7dd6f3…`, `package_lock_sha256=62b05b90…`; **all seven equal `sha256sum` of the frozen-head files.** `head_after=b7d7fe59… clean_after=yes`. Detail log sha256 `b90e0d73…` matches `SHA256SUMS`, `ARCHIVE_SHA256SUMS`, REPORT.md and the console record.
3. **Run-4 content.** Summary log: 89 `PASS`, 0 `FAIL`, `== 89 passed, 0 failed (server 17.6, head b7d7fe5)`, `harness_exit_code=0`. Detail log shows: `164 migrations found` for the parent replay (candidate removed) and `165 migrations found` for the candidate deploy; `ERROR:  55P03` raised by `ALTER TABLE public.community_messages_2027_01 ENABLE ROW LEVEL SECURITY` inside `community_messages_protect_partition` (i.e. the **late-stage** object, migration.sql:256 second DO block), Prisma `P3018` with `SqlState(E55P03)`, `CONTROL=5s` / `AFTER=0|0` for both success-path same-session checks, `Database schema is up to date!` followed by `P3012` on clean-history `resolve --rolled-back`, and the `ALLOWED-PATH: DunningAttempt: service_role lost SELECT` class message. Forward schema dumps `fwd1`/`fwd2` share sha256 `eb10563c…`.
4. **Tooling recorded:** prisma CLI 6.19.3 (sha256 `c2a77456…`), node v20.20.1, psql/pg_dump **client 18.6** against **server 17.6**.
5. **Fixture identity in the log** is the synthetic loopback identity documented in the packet (`127.0.0.1:54321`, maintenance db `postgres`, confirm literal `DESTROY-127.0.0.1:54321/s1_rls_proof,s1_rls_proof_lock`, URL credential redacted). I do not assert this identity beyond what the log records.

## 2. Findings (stable IDs `S1-R3B-NN`)

Classification key: **DEFECT** (source must change), **EVIDENCE-GAP** (source may be fine; proof/infrastructure missing), **EXTERNAL** (outside S1 source; preconditions/hosted facts), **COMPOSITION** (depends on the unrun S1+S2 build), **PACKET** (evidence-hygiene, not source), **INFO**.

### S1-R3B-01 — Packet `.copy` files are the 7cbbb03 versions, not the proven head — PACKET
- **Scope:** `revision-1/s1-target-guard.sh.copy` and `s1-harness-guard.spec.sh.copy`.
- **Observation:** `cmp` against the frozen head fails (guard differs at line 116/122/128/174: `left(rolsuper::text,1)` formatting and `postgres) want=fttt`; spec differs at lines 150/158: `postgres/tttt`, `postgres/fttt`). Both `.copy` files are byte-identical to `git show 7cbbb03:<path>`. SHA256SUMS lists them as-is, so the manifest is internally consistent but the files do **not** represent `b7d7fe5`.
- **Consequence:** A reader who trusts the `.copy` files instead of the bundle would review the pre-fix guard that refused every real server (`SERVER_ROLE`). The bundle, patch and the run-4 stamped hashes are the authoritative head artifacts and **do** match.
- **Closure:** replace or relabel the `.copy` files (`…copy.7cbbb03`) and add `…copy.b7d7fe5`, or drop them and point at the bundle. No source change.

### S1-R3B-02 — S1 verify gate is not wired at this head; release.sh still checks only Prisma history — COMPOSITION (reserved)
- **Scope:** `scripts/release.sh:152-171` at `b7d7fe5` (`npx prisma migrate deploy` → `prisma migrate status` → grep "up to date"); `verify.sql:11-17` documents the intended `prisma db execute --file verify.sql` route.
- **Observation:** Nothing at this head runs `verify.sql` in release. The harness proves the intended gate route exits 0/non-zero correctly (`s1-rls-close-public-exposure.sh:151,202,210`; run-4 PASS) — this closes **S1-R2B-04** for Prisma 6.19.3/PG 17.6 — but the *gate itself* is S2 work.
- **Consequence:** Until S2 composition evidence exists, "Prisma says up to date while catalog is exposed" (harness §9, `INVARIANT` checks at lines 314-317, PASS) is a live blind spot, not a closed one.
- **Closure / evidence request:** see `EVIDENCE-REQ-01` (composed release.sh path executing verify.sql with exit propagation shown on both a protected and a deliberately-drifted fixture).

### S1-R3B-03 — Serving-role BYPASSRLS and grantor/ownership preconditions remain unproven live — EXTERNAL (inherits S1-A-06 / S1-B-07)
- **Scope:** `migration.sql:23-31` (asserts postgres/service_role are BYPASSRLS so RLS is a no-op for the app), `migration.sql:144,200` (REVOKE as executing role), `migration.sql:266-308` (CREATE OR REPLACE of `app.*` requires ownership), `verify.sql:157-158` (BYPASSRLS check is a NOTICE only, on the *verifier's* role, not the serving role).
- **Observation:** The fixture creates `postgres` as `LOGIN NOSUPERUSER BYPASSRLS` owner (`supabase-like-bootstrap.sql:29,43-47`) and grants default privileges as `postgres` (`:52-57`), so REVOKE-as-owner and CREATE OR REPLACE-as-owner succeed by construction. On the real target, if (a) the serving role is not BYPASSRLS, FORCE RLS + deny-all policies block the application; if (b) grants were made by a different grantor or functions are owned by another role, the migration fails (42501 → whole-file rollback, fail-closed) or the REVOKE is a silent no-op (caught later by `verify.sql:136-137` as EXPOSURE, still fail-closed). Fail-closed in every branch, **but the success branch is not demonstrated live.**
- **Closure / evidence request:** `EVIDENCE-REQ-02` — one read-only catalog probe against the actual target (or a dump of it): `rolbypassrls/rolsuper` for the serving role(s) named in `DIRECT_URL`/`DATABASE_URL`, `relowner` and `relacl` (with grantor) for the 18 relations, `proowner` for the five functions. No mutation; no secrets in the artifact.

### S1-R3B-04 — PG 15 behaviour is untested by design of the guard; CI gate evidence absent — EVIDENCE-GAP / EXTERNAL
- **Scope:** `s1-target-guard.sh:152-154` refuses any `server_version_num` outside 17.x; `.github/workflows/migration-dry-run.yml:122-123` uses `postgres:15.18`; the packet contains **no** CI run for `b7d7fe5`.
- **Observation:** The three SQL files use no PG16+/17-only syntax that I can identify (`to_regclass`, `format`, `FORCE ROW LEVEL SECURITY`, `pg_get_function_identity_arguments`, `proconfig`, `polroles/polcmd/polpermissive` all exist on 15). The `search_path=""` catalog serialisation accepted by `verify.sql:190` is what PG 17.6 emitted (run 4 PASS); PG 15 serialises the same way to my knowledge, but that is reasoning, not evidence.
- **CI-specific risk:** `prisma/migrations/_supabase_bootstrap.sql` creates `service_role/authenticated/anon` (lines 50-56) but **no `ALTER DEFAULT PRIVILEGES`**. On that target `service_role` may hold no table grants, so `verify.sql` §1b (`:143-151`) would report ALLOWED-PATH failures — meaning `verify.sql` **cannot be used as a CI pass gate on the bare PG15 CI bootstrap without also shimming default privileges** (or accepting that CI proves migration+down parity only). Not a production defect; an integration constraint S2 must know.
- **Closure / evidence request:** `EVIDENCE-REQ-03` — the PG 15.18 `migration-dry-run` job log for the `b7d7fe5` (or composed) tree showing forward apply, `down.sql`, re-apply and dump parity; plus, if verify.sql is to be run in CI, one run showing its result on that bootstrap.

### S1-R3B-05 — Destructive fixture guard: sound and fail-closed; two low-severity parser edges — INFO (no action required)
- **Scope:** `s1-target-guard.sh` offline (`:64-101`) and preflight (`:112-186`) layers; parser `:190-192`; harness call sites `s1-rls-close-public-exposure.sh:38-40` (main shell, so `exit 64` in `s1_guard_refuse` terminates the harness — confirmed, not a subshell).
- **Assessment (challenged):** literal-loopback URL grammar with rejection of `?`, `%`, second `@`, non-`postgres` maintenance db; pinned port equality; `^s1_rls_[a-z0-9_]{1,40}$` namespace; NAMEDATALEN check for `<db>_lock`; confirmation literal binding host:port **and both** database names (closes the R2 "port-only" shape, spec line 133); server-side checks of `inet_server_addr/port`, current db, superuser, 17.x version, fixed cluster marker, `data_directory` under a fixed host root + canonical + `realpath -e` self-resolution, zero foreign databases, and pre-existing fixture role flags (`postgres` must be `fttt`, i.e. a stock superuser `postgres` cluster is refused). Preflight bounded by `PGCONNECT_TIMEOUT=5`, `statement_timeout=5s`, `timeout -k 2 20`. Offline spec (72/72 at three heads; `offline-guard-spec-head-b7d7fe5.log` hash OK) covers each refusal code plus a non-vacuous positive control that stops at the first quoted `DROP DATABASE`.
- **Edges (low):** (a) `s1_guard_field` tokenises on spaces, so a foreign database whose name contains a space would be truncated at the first token; the FOREIGN_DB check could then compare only a fragment. Compensated by cluster marker + datadir + role-flag layers; an operator-mistake guard, not an adversarial boundary. (b) Role-flag check validates only roles that already exist; a cluster with none of the five roles passes — intended ("fresh cluster" positive control, spec line 157).
- **Closure:** none required for R3. Optional hardening: emit fields with a non-space delimiter (e.g. `\x1f`) and set `-F` accordingly.

### S1-R3B-06 — Timeout/atomicity/recovery proof is now discriminating (closes S1-R2-A-02, S1-R2B-01, S1-R2B-02 on PG 17.6) — INFO with one residual
- **Scope:** harness `:153-198` (late-stage blocker on `community_messages_2027_01`, tagged `application_name=s1_blocker`, released by `pg_terminate_backend`), `:172-177` (psql `-1` path and same-session failure path), `:181-188` (real `prisma migrate deploy`, `EXPOSED_SQL` and `HELPER_SQL` compared to pre-state), `:226-236` (same-session success path with a control SET), `:243` (fresh-session defaults).
- **Assessment:** The blocker holds ACCESS SHARE inside an open transaction; the failing statement is in the **second** DO block (`migration.sql:244-255`) after the 14-table DO and the `CREATE OR REPLACE FUNCTION`s. Because `HELPER_PRE` (`protect=absent;create_sp=unpinned;app_sp=0;policies_2027_01=0`) is unchanged after both the psql and Prisma failures, the whole file was rolled back — a per-statement client would have left `protect=present`. This is a genuine discriminator. The control `SET lock_timeout='5s'` before `\i` makes the `AFTER=0|0` assertion meaningful (a missing RESET would read `5s`). The duplicated `55P03` block in the detail log (lines 1012 and 1018) is the psql-`-1` run and the same-session run each logging once; the check counts on the captured same-session output only — not a double-count.
- **Residual (honest, already stated by the builder at `:234-236`):** the settings state of Prisma's own connection after `migrate deploy` is not observable; the Prisma-path RESET claim rests on file content + psql evidence. Acceptable: with whole-file single-transaction execution proven, the `RESET` lines (`migration.sql:337-338`) execute in the same transaction, and the connection is closed afterwards.
- **Composition dependence:** whole-file atomicity is a Prisma CLI behaviour proven for **6.19.3** (lockfile `62b05b90…`). If S2 changes the Prisma version, this specific proof does not carry (`EVIDENCE-REQ-04`).

### S1-R3B-07 — Verifier privileged interface — INFO with two design notes
- **Scope:** `verify.sql:56-221`.
- **Assessment:** exposure vs allowed-path classes (`:56-57`, `:213-218`) close **S1-R2B-03** and are exercised (harness `:203-217`). `has_table_privilege` and `has_function_privilege` need no elevated rights; unknown role → error → non-zero exit (fail-closed). Function checks require exact identity signatures (`:176-183`) and treat overloads as EXPOSURE. EXECUTE denial is asserted only for the two public partition helpers (`:198-202`), not for `app.*` predicates — correct, because RLS policy expressions run as the invoking role and anon/authenticated must be able to call them (parent migration `20261212000000:…` grants them).
- **Design notes (not defects):** (a) the verifier reads catalog truth and never mutates, so it is safe to run from a low-privilege role; but the harness only demonstrates it as `postgres` (BYPASSRLS, owner). (b) The BYPASSRLS NOTICE (`:157-158`) concerns the verifier's session, not the serving role — do not read a passing verify as serving-role clearance (see S1-R3B-03).

### S1-R3B-08 — Future-object boundary: wrapper-only protection, no event trigger — INFO (inherited residual from R2 A-07)
- **Scope:** `migration.sql:162-211` (`community_messages_protect_partition(regclass)`, parentage guard `:181-184`, EXECUTE revoked from PUBLIC/anon/authenticated `:207`, granted to service_role `:211`), `:216-240` (wrapper), `:244-255` (catalog-driven protection of all current children incl. `community_messages_default`).
- **Assessment:** Any partition created via the wrapper is protected at creation (harness §7, PASS incl. anon 42501 and 3 policies). A partition created **outside** the wrapper (manual `CREATE TABLE … PARTITION OF` / `ATTACH PARTITION` by the owner) inherits Supabase default privileges and is exposed until the next `verify.sql` run, which will catch it (relations are derived from `pg_inherits`, `verify.sql:74-77`). No application code calls the wrapper (`rg` over `src/`: none; only `20261212000000` and tests), so provisioning is operator-driven. The negative guard case ("not a partition of public.community_messages") is **still not exercised** by the harness (no test string matches `migration.sql:184`); the function is SECURITY INVOKER and only owner/superuser can `ALTER TABLE`, so exposure risk from that gap is nil, but the RAISE path is untested.
- **Closure:** none required for R3; record as accepted residual. Optional: one harness check calling `protect_partition('public."DunningAttempt"'::regclass)` and expecting the RAISE.

### S1-R3B-09 — `down.sql` is an exposure re-open, not a containment action — INFO (inherited)
- **Scope:** `down.sql:51-56` (`DROP POLICY`, `NO FORCE`, `DISABLE`, **`GRANT ALL PRIVILEGES … TO anon, authenticated`**), `:80` (`GRANT EXECUTE … TO PUBLIC`).
- **Assessment:** Correct for the CI reversibility gate (parity proven on 17.6: `fwd1 == fwd2`, dumps `--no-privileges` so ACL parity is by construction not by dump), but running it live re-creates the S1 finding. E_RECOVERY_PACKET directions remain **unrun**. Keep operator-only; never part of an automated rollback.

### S1-R3B-10 — Reported vs observable model/settings — INFO (mandate G-rule: report honestly)
- Dispatch **requested** "Claude Fable 5, High". The runtime does not expose its model identifier or reasoning-effort setting to me; I therefore **cannot confirm** the executing model/settings and do not assert them. Recorded in `IDENTITY.json` as requested-only.

## 3. What the 89/89 result does and does not prove

Proves (PG 17.6, synthetic fixture, prisma 6.19.3, psql client 18.6): the 164-migration parent chain plus `rls_fitness_backend.sql` reproduces exactly the 18 RLS-disabled relations; the candidate closes all 18 (RLS on+forced, restrictive deny-all for anon/authenticated, service_role bypass policy, REVOKE) and pins five functions; anon/authenticated via `authenticator`+`SET ROLE` get 42501 on all CRUD on all 18 and cannot execute the partition helpers; a non-bypass role **with** grants is denied by policy (RLS layer independent of grants); service_role/postgres paths work; parent `community_messages` policies untouched and the coach/member/non-member/forged-sender behaviours hold; wrapper-created partition is protected; late-stage lock → bounded 55P03, whole-file rollback for both psql `-1` and Prisma; documented recovery works; out-of-band reversal is invisible to Prisma but caught by `verify.sql`; forward→down→forward dump parity; data preserved.

Does **not** prove: live serving-role identity/flags; live grantor/ownership; PG 15 behaviour; hosted Supabase `postgres`/`supabase_admin` specifics; release.sh gating; behaviour under any Prisma version other than 6.19.3; backup/restore posture; that the production pre-state is exactly the fixture's pre-state (fixture is a twin *by construction*).

## 4. Composition-dependent conclusions (reserved) and smallest evidence requests

Full text in `EVIDENCE_REQUESTS.md`. Summary:

| Req | Evidence (smallest sufficient) | Unblocks |
|---|---|---|
| EVIDENCE-REQ-01 | Composed `scripts/release.sh` log on a `s1_rls_*` fixture showing `verify.sql` executed via `prisma db execute` after `migrate deploy`, exit 0 on protected state **and** exit ≠0 (with `ALLOWED-PATH`/`EXPOSURE` text) on one induced drift, with the composed head + file hashes stamped | S1-R3B-02 |
| EVIDENCE-REQ-02 | Read-only catalog probe (or dump excerpt) from the real target: serving role `rolsuper/rolbypassrls`, `relowner`+`relacl` grantors for the 18 relations, `proowner` for the 5 functions | S1-R3B-03 |
| EVIDENCE-REQ-03 | PG 15.18 `migration-dry-run` job log for the composed tree (forward, down, re-apply, parity); optional verify.sql result on that bootstrap | S1-R3B-04 |
| EVIDENCE-REQ-04 | Composed tree's `package-lock.json` sha256 or `prisma --version` output showing CLI == 6.19.3, or a re-run of harness §3 under the actual version | S1-R3B-06 carry-over |

## 5. Attestation

- **S1 source at `b7d7fe5` (isolated lane):** I attest that the product SQL is unchanged from the R2-reviewed design plus the R2-requested corrections, that no new defect was found under independent static challenge of the RLS/role/partition/future-object boundaries, and that the R3 test layer's guard, atomicity, timeout, recovery and verifier-interface evidence is discriminating and consistent with the frozen head's hashes. **R2 findings S1-R2-A-01, S1-R2-A-02, S1-R2B-01, S1-R2B-02, S1-R2B-03, S1-R2B-04 are closed for the PG 17.6 synthetic scope; S1-R2B-05 remains informational.**
- **Live / hosted / PG 15 / serving-role / release-gate clearance: NOT given.** These are EXTERNAL or COMPOSITION items (S1-R3B-02/03/04) and stay pending until the parent returns the evidence in §4.
- One packet-hygiene finding (S1-R3B-01) should be fixed before the packet is cited as the reference for the guard/spec source.

*Auditor B — read-only; wrote only `execution/audits/s1-r3/b/{REPORT.md,EVIDENCE_REQUESTS.md,IDENTITY.json}`.*
