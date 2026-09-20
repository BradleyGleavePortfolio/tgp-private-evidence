# S5 G2 — R1 audit finding dispositions (S5-A = audit a, S5-B = audit b)

Status legend: FIXED-S5 (validation/harness change in candidate), ASSERTED (S5 test now proves the behaviour; fix owned elsewhere), ESCALATE-S1 (schema/migration/generator/doc owner), ESCALATE-PARENT, CHARACTERIZED (recorded, not fixed by design), OPEN.
Live-run column is filled from the resume proof run (see REPORT.md "What ran").

| Finding | Disposition | S5 action (files) | Owner of remaining work |
|---|---|---|---|
| S5-A-01 / S5-B-01 no live proof; bootstrap lacks `postgres` role | FIXED-S5 | bootstrap creates non-superuser `postgres` LOGIN NOSUPERUSER CREATEDB CREATEROLE BYPASSRLS + service_role LOGIN BYPASSRLS + anon/authenticated NOLOGIN, password from env only; DB owned by postgres (`test/utils/g2-pg17-bootstrap.sh` §2–3). Migration `20260613000000_message_rls_split_update` (`ALTER FUNCTION ... OWNER TO postgres`) now runs as that owner. Live result: see REPORT | S5 (re-run on regression) |
| S5-A-02 | FIXED-S5 | same as above; bootstrap verifies role flags `f:t:t` (nosuper:bypassrls:login) before creating the DB | — |
| S5-A-03 / S5-B-03 DDL as superuser | FIXED-S5 | every harness DDL/data/E up/down/`prisma migrate` call runs as `postgres`; spec `beforeAll` asserts `user:postgres, super:false, bypassrls:true, owner:postgres` and zero public tables owned by another role; cluster superuser used only for `pg_stat_activity` lock observation (`sqlAdmin`) and CREATE DATABASE/ROLE | — |
| S5-A-04 heap | FIXED-S5 | `NODE_OPTIONS=--max-old-space-size=4096` exported by runner and printed into `env-<stage>-<ts>.log`; matches `.github/workflows/ci.yml` rls-live-tests | — |
| S5-B-02 runner not fail-closed | FIXED-S5 | `run-proof.sh` exits on first failing stage; live stage never starts after bootstrap failure; lock released with rc; per-stage timestamped logs | — |
| S5-A-05 / S5-B-04 down.sql leaves E history applied | ASSERTED + ESCALATE-S1 | stage 5 asserts: after drained down, `_prisma_migrations` still 165 and `migrate deploy` reports "No pending migrations" (false up-to-date); `prisma migrate resolve --rolled-back E` REFUSED with P3012 on clean history (S1 R2 semantics re-proven for E); forward repair `psql --single-transaction -v ON_ERROR_STOP=1 -f migration.sql` then catalog verify. NOT implemented: auditor recommendation to use `resolve --rolled-back` as recovery (contradicted by S1's empirical finding). Packet/doc recovery text is S1's | S1 (E packet recovery sequence) |
| S5-A-06 E negatives absent | FIXED-S5 (partial) | ported onto populated base: wrong public index owner (up & down), search_path decoys (both directions, shadow table untouched, 1230 rows identical), NOBYPASSRLS owning role refused by RLS in down; assigned provenance without staging already refused in "rolls E back only while every provenance is NULL". NOT modelled: live drift (2 rolled_back rows in hosted history — names never supplied; synthetic history has 0 rolled_back rows and the spec asserts that, so a hosted run would need S1's history fixture) | S1 (hosted history fixture / names) |
| S5-A-07 / S5-B-05 docs say PG15 | ESCALATE-S1/docs | S5 evidence records PG 17.6 (server_version_num 170006) on every run; in-tree G2 docs + CI `postgres:15` service are not S5 files | S1 / docs owner / CI owner |
| S5-A-08 O-after-T downgrade fencing | CHARACTERIZED + ESCALATE-PARENT | spec "characterizes actual O after T: provenance stays but O can downgrade success" is the evidence; packet wording "T enabled only after every O writer is drained" belongs to the G2 rollout packet (d7404cd4 docs, not S5-owned) | packet owner via parent |
| S5-A-09 accounting comment overclaims | ESCALATE-S1 | comment lives in T service source (product), out of S5 scope | S1 |
| S5-A-10 test quality | FIXED-S5 | staging PK now `${coach}-${intent}-${family}-${platform}-${source}`; collision `toThrow` assertions match product constraint names (`ScoutIngestEntity_coach_id_intent_id_source_id_key`, `ScoutReconstructionLedger_coach_id_intent_id_entity_type_source`); port 54325 remains double-entered via `G2_PG17_CONFIRM` (guard design, documented); single-shot bootstrap now refuses a populated DB and runner has explicit `reset` stage | — |
| S5-A-11 timing on shared box | CHARACTERIZED | lock-budget 5–30 s, volume run, worker 90 s kill: failures classified infra and re-run once when idle; see REPORT for actual outcome | — |
| S5-A-12 contract 1.4.1 vs #526 | ESCALATE-PARENT | not batchable in S5; dependency ordering decision | parent |
| S5-B-06 execution-dependent assumptions | CHARACTERIZED | P2002 ROLLBACK count, volume timing, `application_name` visibility: actual observed values recorded in REPORT from the live log; assertions adjusted only where the observed product behaviour is explainable and recorded | — |
| S5-B-07 contract limits | CHARACTERIZED | narrow identities/collisions remain explicit limitations carried to B/drain → R → N/Q1 → C; no architecture fork | later lanes |

## Live result column (proof run TS 20260920T184713Z, live 50/50, PROOF_EXIT=0; HEAD 485c6797)
| Finding | Live result |
|---|---|
| S5-A-01/02/03, S5-B-01/03 | PASS — bootstrap as non-superuser `postgres` (`false:true:true`), 164 migrations, all public tables owned by postgres; spec identity `super:false, bypassrls:true` |
| S5-A-04 | applied — `NODE_OPTIONS=--max-old-space-size=4096` in every `env-*.log`; live suite 211.6 s without OOM |
| S5-B-02 | applied — runs #1/#2 stopped at bootstrap; live never started after a bootstrap failure |
| S5-A-05 / S5-B-04 | PASS — history 165 after drained down, `migrate deploy` "No pending migrations", `resolve --rolled-back` P3012 refused, forward repair via `psql --single-transaction -f up`; escalation to S1 stands (packet recovery text) |
| S5-A-06 | PASS — wrong index owner up/down refused, search_path decoys both directions (1230 rows intact), NOBYPASSRLS owner refused by RLS (2 hidden claims); hosted drift still not modelled |
| S5-A-07 / S5-B-05 | evidence PG 17.6 (170006) on every run; doc/CI change remains S1/CI owner |
| S5-A-08 | CHARACTERIZED live — "O after T: provenance stays but O can downgrade success" passed; NEW: T claim transaction paused >5 s is rolled back by Prisma's default interactive-transaction ceiling before E's 5 s lock_timeout, so a drained down succeeds and T fails closed (500/P2022) — drain is a process boundary, not a lock (`PG17_CLAIM_RACE`, both runs) → parent/S1 packet wording |
| S5-A-09 | OBSERVED live — O tally on populated base counts the whole coach/intent/entity_type ledger (600 staged → 596/8/21 incl. 25 legacy rows) → S1 |
| S5-A-10 | PASS — collision assertions hit product constraint names; reset stage used between runs |
| S5-A-11 | PASS on shared box — lock budgets 11.3 s (5–30 s window), volume 13.7 s, no worker kill |
| S5-A-12 | unchanged — parent |
| S5-B-06 | observed values: P2002 `ROLLBACK` counts `[0,1]`; volume ≥10 ROLLBACKs on 1050; `application_name` only visible to cluster superuser (`sqlAdmin`) |
| S5-B-07 | unchanged — narrow identities/collisions carried to later lanes |
Additional harness observations fixed in S5 (not findings against product): worker IPC message lost when `process.disconnect()` raced `process.send()` for large results; O replay bumps `Person.updated_at` (enumeration compared without it).
