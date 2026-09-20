# S1 R3 proof attempt 1 — failure classification (written BEFORE any source correction)

**When:** 2026-09-20 ~23:14 UTC, SLOT C, fixture `s1-disposable-pg17` on 127.0.0.1:54321 (PG 17.6), head `7cbbb03977455fcfb5da543bdaffaf5de3c45696` clean.
**Command:** `execution/s1-r3/run-proof.sh 1` with the approved synthetic env (superuser URL redacted in all logs).
**Result:** `S1-GUARD REFUSED SERVER_ROLE: session role is not a superuser` — exit 64 from the guard preflight, before any stamp, lock hold, mutation, or harness step. No `proof-run-01-*` log was produced by design (refusal precedes logging). Console preserved at `execution/s1-r3/failed-runs/proof-run-01-attempt1-guard-SERVER_ROLE.console`.

## Root cause (verified against the live fixture, read-only)
`test/db/_support/s1-target-guard.sh` preflight SQL builds text with `||`:
```
'super='||(select rolsuper …)                       -> super=true      (guard expects super=t)
rolname||'/'||rolsuper||rolbypassrls||rolcanlogin||rolinherit -> s1_super/truetruetruetrue (guard expects e.g. postgres/ftft)
```
In PostgreSQL an implicit boolean→text cast yields `true`/`false`; psql prints bare boolean *columns* as `t`/`f`. The guard's parser (`[ "$super" = "t" ]`, ROLE_FLAGS table `ftft/fftf/ftff/ffff`) and the offline spec stubs both assumed the bare-column form. Consequence on a real server:
- `SERVER_ROLE` refuses every session, including the legitimate superuser (fail-closed, observed).
- `ROLE_FLAGS` would refuse every bootstrapped cluster (latent; unreachable behind SERVER_ROLE).
- The `roles=` empty (fresh cluster) path is unaffected.

## Class
**Builder-side guard source defect (formatting), detected by real-target validation.** Not: fixture, environment, provider, credentials, product schema/migration/grants, harness §3 logic, or wrapper ordering. Fail direction was closed (refused), so nothing unsafe happened.

## Why offline testing missed it
`test/db/s1-harness-guard.spec.sh` stubs `psql` with a hand-written identity line (`super=t … roles=`). The stub encodes the intended contract, not PostgreSQL's cast rules. Lesson recorded for REPORT.md: at least one preflight query must be validated against a real PG once, or the stub must be generated from a real server transcript.

## Proposed correction (strict, not a loosening)
Format each boolean explicitly to psql's one-letter form in SQL: `left(rolsuper::text,1)` (→ `t`/`f`) for `super=` and for the four role flags. The parser, refusal codes, expectations and the spec's stub lines stay unchanged; the spec's expected strings are already the correct contract. Spec gains no weakened case. New commit on top of frozen `7cbbb03` (never amended), same identity rules; then offline spec rerun, then proof attempt 2.

---
# Proof attempt 2 — head `16a3a7074db395347958f70525da8dffec09c342` — 75 passed / 14 failed (exit 1)

Logs preserved: `execution/s1-r3/proof-run-02-head-16a3a70.log` (+ `-harness-detail.log`, 3 schema dumps), console in `failed-runs/`. Guard offline+preflight accepted on the real PG 17.6 fixture; bootstrap, forward migration, verify, §3 late-stage blocker set-up, bounded lock wait, direct + Prisma late-stage atomicity checks all PASSED.

**First failure:** `DB2: blocker released (no lock left on community_messages_2027_01) expected 0 got 1`. All 13 subsequent failures (recovery deploy, verify after recovery, verifier class probes, down.sql, resolve-state check, same-session RESET checks, re-apply) are a cascade of the still-held lock (`55P03 canceling statement due to lock timeout` on the same relation each time).

**Root cause:** harness line 186 releases the blocker with `kill $BLOCKER` on the client psql. The server backend running `pg_sleep(120)` does not notice the closed socket (`client_connection_check_interval = 0` by default) and keeps the open transaction — and the lock — until the sleep ends. The harness checks the lock immediately, so the release is a no-op for ~2 minutes.

**Class:** builder-side harness/test-support defect (blocker lifecycle), detected by real-target validation. Not: product migration/down/verify SQL, grants, guard, fixture, wrapper. Fail direction: the harness reported FAIL honestly (no false pass).

**Correction:** tag the blocker session with `application_name=s1_blocker` and release it server-side with `pg_terminate_backend()` (then reap the client and poll the lock for up to 10 s). No expectation weakened; the assertion "no lock left" stays exact.

---
# Proof attempt 3 — head `760104c90c9c4d53d6cd662bb802bf8077bdd4a4` — `S1-GUARD REFUSED ROLE_FLAGS` (exit 64, before any mutation)

`pre-existing role postgres has flags super/bypassrls/login/inherit=fttt, fixture expects ftft`. Console preserved in `failed-runs/`. Run 2 left the bootstrapped roles/databases on the fixture (intended: the harness DROP/CREATEs its two databases per run; roles are cluster-wide), so this is the first run exercising the "existing fixture roles" preflight path against a real server.

**Root cause:** `test/db/_support/supabase-like-bootstrap.sql` creates `postgres LOGIN NOSUPERUSER CREATEDB CREATEROLE BYPASSRLS` (inherit default true) → `fttt`. The guard's expected-flag table in 7cbbb03 says `postgres) want=ftft` (login=f), and the offline spec's positive control encodes the same wrong constant, so 72/72 offline could not detect it. `authenticator=fftf`, `service_role=ftff`, `anon/authenticated=ffff` match the real bootstrap exactly.

**Class:** builder-side guard constant defect, fail-closed (would refuse every rerun on a legitimately bootstrapped fixture; never admits anything unsafe). Not a product/schema/grant issue.

**Correction:** `postgres) want=fttt` in the guard; spec positive control `postgres/fttt`; spec "stale postgres role is superuser" case becomes `postgres/tttt` (still refused). Superuser `postgres`, BYPASSRLS `authenticator`, etc. remain refusals.
