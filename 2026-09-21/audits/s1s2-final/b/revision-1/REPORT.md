# S1 R4 + S2 R3 composed candidate — independent T4 audit B (final for head 9742037b at current evidence)

Written 2026-09-22 ~00:20Z (2026-09-21 17:20 PDT). Read-only. Sole output dir `execution/audits/s1s2-final/b/`. Original `execution/audits/s1-r3/b/` untouched. Peer `s1s2-final/a/` not read. No source edit, install, DB, test run, browser, hosted call, commit or push. Offline probes limited to `git`, `sha256sum -c`, `grep`, and one PyYAML parse of the 8 `fly-*.yml` files (read-only, seconds).

## 0. Verdict in one paragraph

The composition at head **`9742037b153221de565e651ad8ba3b721bc0fb31`** (tree **`5469fbefcdbb7001151e7a02084951e3c57a5dfe`**) is a genuine, verbatim union of S2 `e15e25c2` and S1 R4 `41f4d6a9` plus one S2-owned harness file; every S2 R3 source closure (S2-R2-A-01/02/03/05) and the S1 R4 TRUNCATE verifier fix are present in source and I independently confirm them. The first real PG 17.6 run (`execution/s2-composition/composition/20260922T000811Z/`, 63 passed / 4 failed, runner exit 1, S1 R4 discriminator NOT RUN) proves the material parts of the release path — fail-closed step 0 with no DB contact, genuine 164-parent replay, real candidate deploy to 165, verifier discovered and passed, out-of-band reversal detected, allowed-path drift detected, late lock → real Prisma P3018 failure, both documented recoveries — **but also exposes two real `scripts/release.sh` defects (inherited from the public base, never caught by any fake-Prisma test) that make the script's own success accounting false on Prisma 6.19.3: `pending_before` is always `0`/multi-line and `ALL_APPLIED` is always `unknown`.** Neither defect weakens fail-closed behaviour, but both contradict the script's stated contract, invalidate one PASS in the harness (C2), and mean the synthetic S2 tests encode wrong assumptions. **No unqualified composition/merge attestation is given for 9742037b.** A successor head is needed for release.sh (S2-owned lines) and one harness regex; then one complete re-run including the S1 R4 discriminator. Hosted protection, image/runtime, serving role, PG15, backup/recovery and product acceptance remain separate open holds, unchanged by this run.

## 1. Identity

| Item | Observed by me |
|---|---|
| Requested auditor identity | Claude Fable 5 / High (parent dispatch; EXECUTION_MANDATE.md line 16 amendment). Actual model/settings are not observable from inside the sandbox and are **not** asserted. See `IDENTITY.json`. |
| Composed worktree | `/home/user/workspace/worktrees/s2-composition`, branch `execute/20260921-s2-composition`, HEAD `9742037b…`, tree `5469fbef…`, `git status --porcelain` = 0 lines (checked at start and after reading the run packet). |
| Lineage (verified with `git log --graph` / `git diff --stat`) | `9742037b` = merge(`41f4d6a9` S1 R4) into `eb6904d1` (adds only `test/release/s1s2-composition.sh`, +238) ← `0af39f6c` = merge(`b7d7fe59` S1 R3) into `e15e25c2` (S2 R3 final) ← `1c6db2b6 ← a14ebee2 ← 0b05fcf5 ← 47763380 ← cb0bc910 ← 4a63b8ae ← b801a776 ← c23b9d9f` (public base). |
| Byte identity | Every S1-owned path at HEAD == `41f4d6a9` (migration.sql `72b0ad5a…`, down.sql `dd7dd6f3…`, verify.sql `266e62e9…9448`, guard, bootstrap, S1 harness, `_support/s1-truncate-controls.sh`, `s1-r4-truncate-discriminator.sh`). `git diff e15e25c2 HEAD -- <S2 paths>` is empty except the new harness. `41f4d6a9`'s parent is `b7d7fe59`; author/committer Bradley Gleave on all new commits. |
| Diff base→HEAD | 40 files, +4764/−392. |
| Run packet | 68 entries in `SHA256SUMS`, `sha256sum -c` all OK. Stamp: runner `2d09fd68…` (= v3 in READINESS_FIX_01.md), fixture `08987e4c…`, harness `499b3836…` (= HEAD file), `package-lock.json` `62b05b90…` (= S1 R3 lock), prisma CLI 6.19.3, node v20.20.1, server 17.6 (binaries `postgres_sha256=23cd1748…`, `initdb_sha256=b7db9bc2…` equal to the S1 R3 `PG17_PROVENANCE` values), psql client 18.6. |

## 2. What the real run proves and does not prove (composition/proof-adequacy)

Source: `composition/20260922T000811Z/{stamp.txt,exit-codes.txt,harness/*}`; assertions in `test/release/s1s2-composition.sh` (HEAD). The builder's `execution/s2-composition/B1_DIAGNOSIS.md` was written after my diagnosis and was **not read** for this report; findings B-01/02/03/07 are derived from the logs and source directly.

| Claim | Evidence | Status |
|---|---|---|
| Guard refuses hosted / unconfirmed targets before any connection | `20-refusal-hosted.log`, `21-refusal-noconfirm.log` exit 64; `10-guard-spec.log` 72/72 | proven (offline layer) |
| S2-only tree refuses at step 0 with no DB contact | `C0.release.log`: `verifiers_discovered = 0`, `REQUIRED catalog verifier missing`, exit 1, no `step 1:`; `CLOSED_URL` port 1, no P1001 | proven (S2-R2-A-03 closure, real) |
| Integrated tree minus verify.sql refuses at step 0 | `C0b.release.log` exit 1, names missing verifier | proven |
| 164 genuine parent replays, genuine ledger, legacy pre-state, candidate pending | `P1/P2.parent-deploy.log` real `migrate deploy` exit 0; harness PASS lines 40–51 count `_prisma_migrations` = 164; pre-state verify fails with 258 exposure / 19 allowed-path problems, 36× `still holds TRUNCATE` (`P1.verify-prestate.log`) | proven on both DBs |
| Real release applies candidate → 165, verifier discovered and passed | `C1.release.log`: `Applying migration 20261224000000_…`, `Database schema is up to date!`, `verifiers_passed = 1 (discovered=1, required=1)`, exit 0; `C1v.verify-psql.log` `S1-DB-01 VERIFY OK: 18 relations protected (4 … partitions), 5 functions pinned`; ledger total 165 (harness L67–68) | proven |
| Idempotent second run | `C2` exit 0, verifier still invoked | proven — but the `pending_before=0` PASS is non-discriminating (see B-01) |
| Out-of-band down.sql: status “up to date” yet release fails | `C3.release.log` L39–40: `catalog verifier FAILED … S1-DB-01 VERIFY FAILED (258 exposure …)`, exit 1 | proven (status ≠ truth; R2-A-05 stage B) |
| Documented recovery via direct re-apply | `C4` exit 0 after `psql --single-transaction migration.sql` | proven (fixture); requires psql outside the runtime image |
| Allowed-path drift fails, restore passes | `C5` exit 1 `0 exposure; 1 allowed-path`, `service_role lost SELECT`; `C5r` exit 0 | proven |
| Late lock → real Prisma failure propagates, failed ledger row | `C7.release.log` L32 `P3018`, L38 `55P03`, L41 `canceling statement due to lock timeout`; failed row finished_at null; whole-file rollback → pre-state intact | proven (Prisma 6.19.3 whole-file atomicity re-confirmed for this migration) |
| `resolve --rolled-back` then release | `C8.resolve.log` `marked as rolled back`; `C8` exit 0; step 2 re-applied; ledger excludes rolled-back row | proven — but step-1 status said "up to date" (B-07) |
| Post-run tree clean, fixture stopped, no survivors, lock released | harness L146; `50/51-*.log`; `exit-codes.txt` | proven |
| `ALL_APPLIED=165`, `pending_before=1` accounting | FAIL ×3 | **not proven — real defects, §3 B-01/B-02** |
| Prisma CLI present in S2-only tree (C0 assertion) | FAIL — harness regex; but `C0.release.log` L7 shows the CLI ran (`Prisma schema loaded …`) | substantive claim holds; assertion wrong (B-03) |
| S1 R4 discriminator (predecessor false-green vs successor detect, TRUNCATE-only) | `s1_r4_discriminator=notrun` — runner stops at first failing step (`run-composition-when-granted.sh` L110) | **not run** |
| S1 R4 full S1 harness (128 checks incl. §4b) | not part of this runner | **not run** |

Not covered by this run at all: Docker image build / `USER node` / `/tmp` in image; Fly `release_command` environment; hosted GitHub workflows, environment protection, branch protection; PG 15 CI services; live serving role; backups/restore.

## 3. Findings — S2 (delivery controls, release runner)

### S1S2-B-01 — `release.sh` pending-migration count is always `0` (and multi-line) on Prisma 6.19.3
**Material for the script's own truthfulness/observability; does not weaken fail-closed behaviour. Owner S2 (S2-owned file; lines inherited verbatim from public base `c23b9d9f` L127–129).**
- Lines: `scripts/release.sh` 212–216 (`grep -cE '^[[:space:]]+-[[:space:]]+[^[:space:]]+$' … || echo 0`).
- Evidence: `C1.release.log` shows Prisma printing `Following migration have not yet been applied:` then the bare name `20261224000000_rls_close_public_exposure` (no dash), then `pending_migrations_detected = 0` followed by a stray `0` line; the success banner prints `pending_before=0` then `0`. Same in `C8.release.log`. `grep -c` prints `0` and exits 1, so `|| echo 0` appends a second `0` → the variable is `"0\n0"` — the exact multi-line-metric corruption class the script's own comment (L298–303) claims to have eliminated for `ALL_APPLIED`.
- Consequence: every production release would log `pending_before=0` while applying migrations; the comment at L206–208 ("Prisma 5 lists pending migrations with an ASCII dash") is false for the pinned 6.19.3. No gate decision depends on `PENDING_COUNT` (step 2 always runs), so safety is unchanged. Harness C2's `pending_before=0` PASS (harness L175) is vacuous.
- Why nothing caught it: every S2 proof used a fake `npx` (`test/ci/delivery-artifact.spec.ts` L548–567; R3 `probes/p03-release-verifiers.sh` L16) that emulates `migrate status` output; none used genuine Prisma 6 text.
- Smallest closure: parse the Prisma 6 block (lines after `Following migration(s) have not yet been applied:` up to the blank line) or derive the count from step-3 vs step-1 status; replace `|| echo 0` with a form that cannot double-print; add the genuine `C1/prisma_status.log` as a fixture in the spec. Requires a successor head and a real re-run (harness L159/L229 will then discriminate).

### S1S2-B-02 — `ALL_APPLIED` is always `unknown`: `prisma db execute --stdin` lacks `--url`/`--schema`
**Material for the contract line 11 ("succeed visibly … `ALL_APPLIED=<n>`"); warning-only, exit 0 preserved. Owner S2 (inherited from base L185).**
- Lines: `scripts/release.sh` 305–319. `C1.release.log`: `WARNING: prisma db execute failed querying _prisma_migrations: Error: Either --url or --schema must be provided.` → `ALL_APPLIED=unknown`. Same in C2/C4/C5r/C8.
- Consequence: the one grep-able monitoring metric the header promises is never produced on the pinned toolchain; the harness FAIL (L164) is correct. Fake `npx` in spec L566 / p03 L17 emulate a successful count (`" 1"`, `" 3"`), encoding a behaviour real Prisma does not have.
- Caution for closure: to my knowledge `prisma db execute` does not return result rows even with `--url` (it reports script execution only), so adding `--url` alone will likely still yield `unknown` via the L310 parse branch. Closure must either (a) compute the count from `_prisma_migrations` through a path that returns rows (node + `@prisma/client` `$queryRaw`, present in the runtime image) or (b) drop the promise and derive `ALL_APPLIED` from step-3 output (`165 migrations found` + `up to date`). Decide whether `unknown` should remain non-fatal; today it silently degrades a contractual line. Verify in the real re-run (EVR-01/03).

### S1S2-B-03 — Banner `prisma_cli` line records the schema-loaded message, not the version; harness C0 regex depends on it
**Low; observability + one wrong harness assertion. Owners: S2 (release.sh L59), S2 (harness L117).**
- `npx --no-install prisma --version | head -1` yields `Prisma schema loaded from prisma/schema.prisma` on 6.19.3 (`C0/C1.release.log` L7). Harness L117 expects `prisma_cli += prisma`. The substantive C0 claim (refusal is contract-driven, not "prisma missing") is nonetheless supported: the CLI clearly executed. Closure: `grep -m1 '^prisma '` (or `sed -n 's/^prisma *: *//p'`) in release.sh; align the harness regex.

### S1S2-B-04 — Harness expectations vs. defects: classification
The four FAILs decompose as: C1 `pending_before` = B-01; C1 `ALL_APPLIED` = B-02; C0 `prisma_cli` = B-03 (harness regex + banner); C8 `pending_before` = B-01 **and** B-07 (the C8 assertion would stay invalid even after B-01 is fixed, see below). The harness's "assert, don't assume" stance worked as intended: it refused to promote a run whose contractual lines were false. Harness changes warranted: L117 regex and L229 (C8) expectation; do not loosen L159/L164.

### S1S2-B-07 — After `migrate resolve --rolled-back`, Prisma 6.19.3 `migrate status` reports "up to date" while `migrate deploy` re-applies the migration
**Material for recovery guidance and for what step 3 can attest; not a code defect introduced by S1 or S2. Owners: S2 (release.sh step 3 wording, runbook §11.4), S1 (fact-1 recovery text), harness L229.**
- Evidence: `C8.release.log` step 1 (`C8/prisma_status.log`): `165 migrations found … Database schema is up to date!` — then step 2: `Applying migration 20261224000000_rls_close_public_exposure … successfully applied`. The ledger at that moment held the candidate only as a `rolled_back_at`-marked row (C8 setup, `C8.resolve.log`).
- Consequence 1 (harness): `pending_before=1` cannot be observed in C8 on this toolchain regardless of B-01; the discriminating facts for C8 are "deploy re-applied" + "ledger total = 165 excluding the rolled-back row" (both PASSed).
- Consequence 2 (release semantics): `migrate status` "up to date" is not proof that every migration is applied — a rolled-back row is enough to satisfy it. Step 3 (L248–258) therefore attests less than its comment implies; the catalog verifier (step 4) is the only control in the path that would catch a DB left in this state (e.g. operator runs `resolve --rolled-back` and never re-releases). This strengthens the case for the mandatory verifier contract and should be stated in `docs/deploy-runbook.md` §11.4 / `delivery-controls.md` §7 ("status is satisfied by a rolled-back row; always re-run the release; the verifier is the truth"). Not to be treated as a Prisma bug report — observed behaviour on 6.19.3 only.
- Smallest closure: doc sentences above; harness C8 expectation replaced by the two discriminating facts; no S1 SQL change.

### S1S2-B-05 — S2 R3 closures at the composed head (S2-R2-A-01/02/03/05 and R2-B items)
Independently checked at HEAD (not inherited from builder logs):
- **A-01 (inputs as shell):** PyYAML parse of the 8 `fly-*.yml`: zero `run:` steps containing `${{ … inputs.` ; all have `permissions: contents: read`; mutating `fly-*-set` jobs carry `environment: production` (deploy, db-secrets-set, feature-flags-set, launch-env-set, recent-auth-set, secrets-set); `fly-logs.yml`/`fly-secrets-list.yml` read-only, no environment. R3 packet's p02 (352 hostile executions, 0 markers; positive control 12 markers at 0b05fcf5) and the real jest run at e15e25c2 (172/172, `logs/jest-test-ci-at-e15e25c2-…log`) are accepted as builder evidence, not re-run. **Source closed; never dispatched on GitHub-hosted runners (hosted hold).**
- **A-02 (logs-dump machine start):** `.github/workflows/fly-logs-dump.yml` absent at HEAD (19 workflows). **Closed by removal.**
- **A-03 (discovery fail-open):** step 0 L142–191 checked pipeline + pinned contract (`scripts/release-required-verifiers.txt` lists exactly `20261224000000_rls_close_public_exposure`); Dockerfile L76 copies and L101 asserts the contract; `.dockerignore` excludes `test/` but not `prisma/` or `scripts/release*`. **Closed in source and now proven by real C0/C0b (exit 1, no DB contact).** Boundary: the contract pins a directory *name*, not verify.sql content/hash; content trust rests on the gate's SHA equality + review route, not on step 0.
- **A-05 (recovery overclaim):** `docs/delivery-controls.md` §7 stage table A/B/C, §7.1 contract; `docs/deploy-runbook.md` §3 L305 "never delete or edit an applied migration", L312/324 rollback tag from `machines-before.json image_ref.tag`. Real C3→C4 and C7→C8 exercised the stage-B semantics (status ≠ truth; forward re-apply vs `resolve --rolled-back` for a *failed* row only — consistent with S5 item 1). **Closed in documentation + fixture-proven; not drilled on Fly.**
- **A-04 / R2B-01/02/04/07/10:** wording fixes present (§5 denylist/sentinel; §6 `noble-celebration / production`); lint 0 findings at e15e25c2 per packet. Accepted. `release-evidence-gate.sh` failure string still says "production-closure proof" (builder-acknowledged, wording-only).
- **R2B-08 self-review / R2B-06 gate trust:** unchanged — hosted/owner decisions.

### S1S2-B-06 — Verifier output via `prisma db execute` is exit-code-only
`C1v` note: the S1 `VERIFY OK` NOTICE is absent from `prisma_verifier.log` (0 occurrences) while failures do surface (`C3.release.log` L40 carries the full RAISE text). Consequence: a green production release log will not contain the "18 relations protected" line; only the count line `verifiers_passed = 1`. Acceptable, but docs §7.1 should say so explicitly so operators do not search for it. Low.

### S2 holds unchanged by this run (not defects)
Hosted protection (no `production` environment / branch protection / rulesets observed at R2 — not re-observed by me; no hosted calls made); image never built, `release.sh` never run inside the image as `USER node`; S3 `5c7b42b3` `dependency-audit.yml` job `npm audit (high+critical, whole graph)` is a hard gate input (`release-evidence-gate.sh` L54) so S1+S2 cannot release before S3 lands; `ci.yml` still on PG 15 services; `--url` argv exposure (R2B-09) unchanged.

## 4. Findings — S1 (schema/RLS migration and verifier)

### S1S2-B-10 — S1-R3-A-01 (TRUNCATE) closure status
- **Source:** `git diff b7d7fe5 41f4d6a9 -- …/verify.sql` adds exactly `'TRUNCATE'` to the API-role effective-privilege array (L147) with a rationale comment; migration.sql/down.sql/guard/bootstrap unchanged (blob-identical to b7d7fe59). Confirmed.
- **Real positive evidence (new):** the successor verifier fails the legacy pre-state citing `anon/authenticated still holds TRUNCATE` for all 18 relations (`P1.verify-prestate.log`, 36 occurrences) and passes the released state via both routes (C1v psql OK line; step 4 exit 0 in C1/C2/C4/C5r/C8). So on PG 17.6 the migration does revoke effective TRUNCATE from anon/authenticated, and the verifier sees it.
- **Missing:** the isolated discriminator (TRUNCATE granted alone to anon/authenticated/PUBLIC; predecessor `2bbce0d7…` exits 0 = false-green, successor non-zero; rollback-only TRUNCATE probe) — `s1_r4_discriminator=notrun`. The S1 R4 full harness (89→128) is also unrun. Static expectations (44/45, 128) remain unverified claims per `execution/s1-r4/FAILURES_UNKNOWNS.md`.
- **Disposition:** source fix accepted; closure *at evidence level* pending the discriminator run (EVR-02). Not a defect.

### S1S2-B-11 — Live catalog (catalog-only, `execution/live-catalog-20260921T232916Z.json`) and the serving-role hold
- Live PG 17.6: all 18 relations owned by `postgres`, `rls=false`, ACL `anon=arwdDxtm`, `authenticated=arwdDxtm` (includes TRUNCATE `D`), i.e. the exposure S1 targets is real in production pre-migration. Roles: `postgres` login, **bypassrls=true**, not superuser; `service_role` bypassrls=true; `anon`/`authenticated` nologin, no bypass.
- Consequence for S1's protection claim: FORCE RLS + deny-all policies bind only roles without BYPASSRLS. If the deployed app's `DATABASE_URL` role is `postgres` (bypassrls) the RLS layer is inert for the app path and protection reduces to the GRANT/REVOKE layer for PostgREST roles. The JSON's `not_proven` list correctly excludes the serving role. **Hold S1-R3B-03 / S1-A-06 unchanged; requires operator identification of the serving role (no HTTP exploit or production mutation inferred).**
- Fixture applicability: the composed run's `postgres` role is a synthetic non-superuser (`postgres_local_synthetic`); role attributes vs. live (`bypassrls`) are not asserted equal by the harness.

### S1S2-B-12 — Prior S1 holds carried forward, unchanged
S1-R3B-04 PG 15 CI bootstrap lacks `ALTER DEFAULT PRIVILEGES` (verify.sql ALLOWED-PATH would fail there — never run on PG15); S1-R3B-06 whole-file atomicity proven only for Prisma 6.19.3 (this run re-stamps lock `62b05b90…` → applicability holds for this head); S1-R3B-08 partition protection wrapper-only; S1-R3B-09 down.sql re-grants ALL to anon/authenticated (operator-only; C3 shows the release path catches it); REFERENCES/TRIGGER not checked by the verifier; C4 recovery needs psql (absent from runtime image) → operator action, document.

## 5. Dispositions

| Boundary | Disposition at 9742037b |
|---|---|
| Source composition identity | **Attested** (verbatim S1 R4 + S2 R3 + one S2 harness; clean; hashes as stamped). |
| S2 source closures A-01/02/03/05 | Closed in source; A-03 real-proven; hosted execution open. |
| S1 R4 TRUNCATE fix | Present; real positive evidence; discriminator unrun. |
| Composition proof (release path on real PG 17.6) | **NOT PASS** (63/4, exit 1). Material paths proven; two release.sh accounting defects (B-01, B-02), one banner/regex (B-03) and one invalid C8 expectation + doc gap (B-07) must be fixed in a successor and re-run in full. Findings frozen at 9742037b; the parent-authorised isolated S2 successor is a new head requiring a fresh delta review + complete re-run (incl. S1 R4 discriminator) before any attestation. |
| T4 cumulative merge attestation | **Withheld.** Not because of missing hosted evidence alone — because the candidate's own release script emits false contractual lines on the pinned toolchain. |
| Hosted review/protection, image/runtime, serving role, PG15, backup/recovery, product acceptance | **Open holds**, separately stated, unchanged by this run. |

## 6. Exact-head attestation (bounded)

I attest that head `9742037b153221de565e651ad8ba3b721bc0fb31` / tree `5469fbefcdbb7001151e7a02084951e3c57a5dfe` is the composition described in §1, that the run packet `20260922T000811Z` is bound to it (stamp head/tree/hashes, `sha256sum -c` OK), and that the findings above are derived from that source and packet. I do **not** attest composition-proof PASS, merge readiness, hosted/image/activation readiness, or the S1 R4 discriminator result. Any successor head voids this attestation and requires a fresh exact-head review of the delta plus a complete re-run. Parent is sole publisher; nothing here is self-certification.
