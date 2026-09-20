# S2 R3 — delivery fixer report (builder evidence, not an audit)

Worker: requested Claude Fable 5 / High (requested identity; runtime identity NOT verified).
Role: S2 R3 T4 fixer, discovery/runner owner. S1 owns schema/migrations/grants and verifier content.
Brief obeyed: `execution/R3_FIX_AUDIT_BRIEF.md`; parent mails 22:42 / 22:47 / 22:51 / 22:52 / 22:53 UTC applied.

This document is builder evidence. It is not a clearance, not a self-audit, and claims nothing about
merge, deployment, enablement or production behaviour.

## 1. Frozen result

| Item | Value |
|---|---|
| Branch | `execute/20260920-s2-r3` (worktree `/home/user/workspace/worktrees/s2-r3`) |
| Head | `1c6db2b68c3521fbdf7c0f468b1f52d0152a16b9` |
| Tree | `e44f976e928d53b82d5d538a7d5812750c02fbf3` |
| Predecessor (frozen, untouched) | `0b05fcf5352287109ac88ed2ba3682e441e3a076` — `worktrees/s2` verified still at that head, clean |
| Public base required by bundle | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (hosted `main`) |
| Commits | `a14ebee2` fix(delivery) code+tests; `1c6db2b6` docs(delivery) |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` on both, verified via `git var` before and `git log --format='%an <%ae> | %cn <%ce>'` after; no AI trailers |
| Clean status at freeze | yes (`HEAD.txt`) |
| Bundle | `execution/s2-r3/bundle/s2-r3.bundle`, sha256 `1f572e505b546d6724cccaadf1a4c8dc78115899c76d519ccbbb643541b1a48b`, `git bundle verify` OK, prerequisite c23b9d9f |
| Not done (by rule) | no push, no GitHub workflow dispatch, no settings/secrets, no live/deploy/activation, no hosted calls, no schema writes |

## 2. What changed (diff 0b05fcf5..1c6db2b6: 15 files, +694 / −110)

### Workflows
- **Deleted** `.github/workflows/fly-logs-dump.yml`. It ran `flyctl machine start "$MID"` from a workflow described as diagnostic, outside any `environment:`, and interpolated `${{ inputs.app }}` into `run:`. The read-only `fly-logs.yml` covers the need. Removal chosen over gating per brief ("prefer remove if diagnostic").
- **Rewritten** `fly-secrets-list.yml`, `fly-recent-auth-set.yml`: every input reaches shell only via step `env:` (`APP`, `CONFIRM`), consumed as quoted `"${APP}"`; `run:` blocks contain no `${{ inputs.* }}` / `${{ github.event.inputs.* }}`; `permissions: contents: read`; `set +x`; token check. `fly-recent-auth-set` gains `concurrency: fly-secrets-${{ inputs.app }}` (expression in a non-shell field; not a shell sink).
- **All seven** app-input operator workflows (`fly-db-secrets-set`, `fly-feature-flags-set`, `fly-launch-env-set`, `fly-logs`, `fly-recent-auth-set`, `fly-secrets-list`, `fly-secrets-set`) gain a first step `Validate Fly app target`: `case "${APP}" in backend-spring-lake-3890) ;; *) exit 1`. It runs before any step that references `FLY_API_TOKEN` or calls `flyctl` (malformed app is rejected before credentialed commands, per parent). `fly-launch-env-set` normalized from `github.event.inputs.*` to `inputs.*`, gets `permissions: contents: read`, a default app and the concurrency guard.

### `scripts/release.sh`
- New **step 0** (before any DB connection): `prisma/migrations` must be a directory; discovery via checked pipeline `find … -name verify.sql -type f | LC_ALL=C sort > "$DISCOVERED_LIST"` (failure → exit 1; no `< <(…)` anywhere); **pinned** contract file `scripts/release-required-verifiers.txt` (no env override — removed after parent concern) must exist and list ≥1 entry; entries: comments stripped, spaces/tabs trimmed only (CR not trimmed → CRLF is malformed), must match `^[A-Za-z0-9_][A-Za-z0-9_-]*$` (no `/`, no `..`, no globs), no duplicates, each must resolve to a discovered `prisma/migrations/<name>/verify.sql`. Any violation → exit 1 **before `migrate deploy`**.
- **Step 4** iterates the captured list (`done <"${DISCOVERED_LIST}"`), keeps the exact runner string `npx prisma db execute --url "${DIRECT_URL}" --file "${verifier}"`, and asserts `ran == discovered ≥ required ≥ 1`. Header no longer says "Zero verifiers is fine". Success block prints `verifiers_passed=<n> verifiers_required=<m>`.
- Failure banner now says the *rollout* is aborted and that the DB may have changed if step 2 ran; trap comments state truthfully that EXIT/ERR cannot observe SIGKILL/OOM-kill (no new trap subsystem added, per parent).
- Step 0 wording claims only "this image, this command, before mutation" — not global production state.

### Contract file `scripts/release-required-verifiers.txt` (new)
Lists `20261224000000_rls_close_public_exposure` (S1's migration at frozen S1 head `90a6647`). Consequence: **this S2 candidate alone cannot release** — step 0 fails closed with no DB contact until composed with S1. That is deliberate (parent: "do not hardcode current missing S1 set to zero").

### Dockerfile
Runtime stage `COPY scripts/release-required-verifiers.txt` + `test -f` in the build-time artifact check.

### Tests `test/ci/delivery-artifact.spec.ts` (NOT RUN — see §4)
- Removed `fly-logs-dump.yml` from pinned-refs list.
- New: release.sh step-0-before-deploy structure, pinned contract path / no `RELEASE_REQUIRED_VERIFIERS_FILE`, no process substitution, step 4 count assertion, contract file well-formed; Dockerfile copies/asserts contract.
- New fixture-driven describe: runs `scripts/release.sh` in a temp root with a fake `npx` (logs argv, emulates status/deploy/db execute): happy path → 0 with counts; required missing → refused pre-deploy; migrations dir absent → refused pre-deploy; contract missing/empty → refused; traversal/slash/duplicate/CRLF entries → refused; RAISE → exit 1 after deploy.
- New operator-workflow describe (js-yaml parse, already a dependency): no `run:` interpolates inputs; app env var consumed quoted; `Validate Fly app target` present, correct, and ordered before any `flyctl`/`FLY_API_TOKEN` step; `permissions: contents: read`; no mutating `flyctl machine start|stop|restart|destroy|kill|update`, `deploy`, `scale` in any operator workflow; `fly-logs-dump.yml` absent.
- The test's regex/ordering assertions were mirrored in plain Node against the committed files (all true) because jest could not run; that mirror is not a substitute for the suite.

### Docs (`1c6db2b6`)
- `docs/delivery-controls.md`: §2.5 admin bypass is *required false* (manifest does not carry it); manifest path `release-evidence/release-evidence-<sha>.json`; §3 verify-fly-release does not read `checks[].status`, only `/readyz` probes health; §5 SBOM check described as denylist + sentinel, not closure proof; §6 hosted env observed was `noble-celebration / production`, none named `production` (GitHub auto-creates on first dispatch, unprotected → gate fails closed); §7 rewritten as a stage table (A pre-migration / B migrate-deploy-or-later / C post-rollout) with rollback tag from `machines-before.json image_ref.tag` (first gated release: `deployment-*`, not `sha-*`), "revert code only, never delete an applied migration directory", SIGKILL banner boundary, `fly-logs-dump` removal noted; §7.1 documents the contract; §8 notes actionlint does not flag `inputs.*` in `run:`.
- `docs/deploy-runbook.md`: §3 items 3–4 split by stage, gate refuses older sha ("re-dispatch previous main sha" superseded), migration-directory deletion warning, first-release tag source, ungated command uses the recorded tag; §7 table rows split by stage, logs via `fly-logs.yml`; §11.2 now step 0–4; §11.3 success/failure banner matches code; §11.4 stage determination, no-delete rule, verifier-failure and contract-failure steps.
- `scripts/ci/assert-prod-sbom.sh` header and `release-evidence-gate.sh` OK line: "denylist/sentinel check" wording (the gate's *failure* string `production-closure proof` is unchanged because `test/ci/release-evidence-gate.spec.ts` asserts it; renaming it is a follow-up, not done here).

## 3. Finding dispositions (stable IDs)

| ID | Disposition at 1c6db2b6 | Evidence |
|---|---|---|
| S2-R2-A-01 dispatch shell injection (3 workflows) | **Fixed** (data env + quoted use + allowlist, class-wide across 7). | p02: 352 step executions × hostile payloads, 0 markers, hostile app refused, allowed app reaches fake flyctl as one argv. Positive control at 0b05fcf5: 48 failures incl. 12 marker executions (`logs/p02-…-POSITIVE-CONTROL…`). |
| S2-R2-A-02 hidden machine start in read-only diag | **Fixed by removal** of `fly-logs-dump.yml`; test forbids mutating verbs in operator workflows. | p01 successor 0 failures; negative control at 0b05fcf5 flags the verb. |
| S2-R2-A-03 discovery process-substitution fail-open | **Fixed** (step 0 checked pipeline + pinned required contract, fail-closed pre-deploy). | p03: 16/16 on successor; predecessor 3/16 — e.g. `migrations-dir-absent` exited 0 and ran `migrate deploy` (concrete repro of fail-open). |
| S2-R2-A-04 SBOM "closure proof" overclaim | **Wording corrected** in docs + script headers; check logic unchanged (it is a denylist/sentinel check and now says so). Gate failure string left for test compatibility. | diff of `assert-prod-sbom.sh`, `delivery-controls.md` §5 |
| S2-R2-A-05 recovery overclaim | **Fixed** — stage-specific recovery in both docs and banner. | `delivery-controls.md` §7, runbook §3/§7/§11.4 |
| S2-R2B-01 doc misstatements (bypass, manifest name, checks, env name) | **Fixed** after verifying each against `release-evidence-gate.sh` L184–190, `verify-fly-release.sh`, `fly-deploy.yml` L102–104/212–213. | `1c6db2b6` |
| S2-R2B-02 stale "re-dispatch previous main sha" | **Superseded in runbook** (gate accepts only current main head). The stale sentence lives in a frozen evidence packet (`CROSS_LANE_DISPOSITION.md`) which this lane must not edit — parent to annotate. | runbook §3.4 |
| S2-R2B-03 revert deleting migration fails closed | **Documented**: never delete applied migration dir; revert code only. | runbook §3.4, §11.4.4 |
| S2-R2B-04 first-release rollback tag | **Fixed**: target read from `machines-before.json image_ref.tag`; first release is `deployment-*` (prod GH_SHA `5076a07a`). | runbook §3.4, controls §7 stage C |
| S2-R2B-05 post-replacement failure | **Documented** as stage C (verify/readyz failure after rollout). | controls §7 |
| S2-R2B-06 gate trust | Not a code defect in this lane; wording now says gate is a consumer of checks and hosted state is UNKNOWN. **Unchanged / acknowledged.** | controls §2, §6 |
| S2-R2B-07 lint never run | **Closed for this head**: shellcheck 0.10.0 + actionlint 1.7.7 run on baseline (0 findings) and on committed head (0 findings). | `logs/lint-BASELINE-at-0b05fcf5.log`, `logs/FINAL-proof-at-1c6db2b6.log` |
| S2-R2B-08 self-review | Not closable by the builder. **Open — needs independent R3 audit.** | — |
| S2-R2B-09 `--url` argv exposure (low) | **Unchanged** (deliberately; exact runner string is asserted by existing test and release machine is single-tenant). Follow-up candidate. | — |
| S2-R2B-10 count reporting | **Fixed**: `verifiers_passed = ran (discovered=, required=)` + accounting assertion. | release.sh step 4 |
| S2-B10 (inherited) operator mutation outside environment | **Closed for logs-dump by removal**; remaining mutating operator workflows already bind `environment: production` (existing test). | p01 |

## 4. What ran / what did NOT run

Ran (offline, serial, ≤ seconds each, no network except Slot A downloads, no DB, no hosted calls), all re-run bound to committed head `1c6db2b6` in `logs/FINAL-proof-at-1c6db2b6.log`:
- `probes/p01-workflow-static.py` — PyYAML parse of 19 workflows; structural rules. 0 failures. Negative control on 0b05fcf5: 15 failures.
- `probes/p02-dispatch-injection-exec.py` — executes every real `run:` step of the 7 operator workflows under 10 hostile input strings + allowed app with a fake `flyctl`; 352 executions, 0 failures. Positive control on 0b05fcf5: 48 failures (12 marker writes).
- `probes/p03-release-verifiers.sh` — 16 synthetic scenarios with fake `npx`; 16/16. Negative control on 0b05fcf5: 3/16.
- shellcheck 0.10.0 on the 10 `scripts/**/*.sh` (same selection as `infra-lint.yml`) and actionlint 1.7.7 (with embedded shellcheck): 0 findings at baseline and at head. Note: actionlint did not flag the original `${{ inputs.app }}`-in-`run:` at baseline — it is not in its untrusted-context set; the structural test is the real control.
- `bash -n` on all scripts.

Failed attempts preserved: `logs/p03-first-run-FAILED-summary.txt` — first p03 run had 3 FAILs (full log overwritten by the re-run; verdict lines reproduced verbatim) (CRLF trimmed by `[:space:]` → tightened to `[:blank:]`; fake `npx` `${*##…}` bug fixed in the probe, not the product). p01 negative-control log line `exit=0` is the `tee` status; the probe's own count line `failures=15` is the result.

NOT run:
- **jest `test/ci`** — no `node_modules` in the worktree; install requires a separate slot (parent: backend dependency restore is a separate request; check S1/S2 package-lock reuse first). New tests are therefore *written, not tested*; a mirror of their regex/ordering assertions in plain Node passed, which is weaker evidence.
- Docker build, any GitHub/Fly call, any DB.
- Integrated S1+S2 `release.sh` run against a synthetic PostgreSQL (needs S1 worktree + slot).

## 5. Slot A accounting (for parent)
- Lock `execution/test-validation.lock` acquired non-blocking 22:46:26Z, released 22:46:26Z (download + version capture only, ~1 s). Not re-acquired. Lint runs done without the lock (cheap, local).
- actionlint tarball verified against the official `actionlint_1.7.7_checksums.txt` (OK). shellcheck tarball: the project publishes no checksum file; sha256 `6c881ab0…df87` matched the value I recalled from packaging records (shellcheck-py / distro) — disclosed as recalled, not fetched. Binaries live outside the worktree at `execution/s2-r3/tools/`.

## 6. Remaining unknowns
1. Whether the new/changed jest tests compile and pass (ts-jest strictness, js-yaml import in this config) — unknown until a suite slot.
2. Whether S1's final migration directory name stays `20261224000000_rls_close_public_exposure`; any rename requires a one-line contract update (S2 file, S1 name). `INTERFACE_S1_S2.md` states this.
3. Behaviour of the seven workflows on GitHub-hosted runners as changed (never dispatched).
4. The frozen evidence packet sentence for S2-R2B-02 remains stale until the parent annotates it.
5. `release-evidence-gate.sh` failure string still says "production-closure proof" (test-coupled); wording-only follow-up.

## 7. Smallest follow-ups
1. Parent/S5: one read-only `npm ci` tree, then `npx jest test/ci/delivery-artifact.spec.ts` on `1c6db2b6` (and `release-evidence-gate.spec.ts` unchanged expectations).
2. Integrated candidate (S1 head + this head): run `bash scripts/release.sh` against synthetic PostgreSQL; expect step 0 `verifiers_required = 1 (all present)` and step 4 `verifiers_passed = N (discovered=N, required=1)`. Without S1, expect step 0 exit 1 before `migrate deploy` (proven offline here).
3. Rename gate failure string + its 3 test assertions to "denylist/sentinel check" (wording only).
4. Independent R3 audit pair on `1c6db2b6` (closes S2-R2B-08 only if they say so).

## 8. Files in `execution/s2-r3/`
`PLAN.md`, `INTERFACE_S1_S2.md`, `HEAD.txt`, `REPORT.md`, `bundle/s2-r3.bundle(+.sha256)`, `probes/p01-workflow-static.py`, `probes/p02-dispatch-injection-exec.py`, `probes/p03-release-verifiers.sh`, `logs/` (baseline lint, slot-A download, each probe on successor + control runs on the predecessor, `FINAL-proof-at-1c6db2b6.log`), `tools/` (shellcheck 0.10.0, actionlint 1.7.7, tarballs, checksums).
