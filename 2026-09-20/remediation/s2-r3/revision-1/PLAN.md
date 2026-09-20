# S2-R3 initial plan — delivery fixer (`s2_r3_delivery_fixer_muaeepli`)

Worker: requested Claude Fable 5 / High; actual runtime model identity NOT independently verified by me. Lane: NEW `worktrees/s2-r3`, branch `execute/20260920-s2-r3` from frozen `0b05fcf5352287109ac88ed2ba3682e441e3a076` (tree `fba0a9f0…`). Frozen `worktrees/s2`, R2 packets and audit reports untouched. Repository-local identity set: `git var` = `Bradley Gleave <bradley@bradleytgpcoaching.com>` (author + committer).

Inputs read: R3 brief, AGENT_RULES G01–G22, EXECUTE, LAST_OPERATOR_STATE, R2 A + B reports and probes, R2 parent disposition. Parent mail 22:42 UTC: heavy lock free but grant still request-based; S1 owns schema/grants, S2 owns discovery/runner; required expected verifiers must be proven at the integrated candidate, not hardcoded to today's empty S2 set.

## Findings owned (stable IDs) and intended closure

| ID | Fix |
|---|---|
| S2-R2-A-01 (dispatch inputs are shell source; `fly-logs-dump`, `fly-secrets-list`, `fly-recent-auth-set`) | All `inputs.*` move to step `env:`; `run:` uses quoted `${VAR}` only. Structural test: no `${{ inputs.* }}` / `${{ github.event.inputs.* }}` inside any `run:` block of any operator workflow. Execution-level negative probe: hostile app string with `$(…)`, backticks, quotes, newline, `;` against the actual step text with a fake `flyctl` → no marker file, step refuses. |
| bounded app target (A-01 smallest fix) | Uniform "Validate Fly app target" step in every operator workflow that takes `app`: `case "${APP}" in backend-spring-lake-3890) ;; *) exit 1` — the only Fly app in `fly.toml`. Applied to all 7 app-input operator workflows so the control is a class property, not a per-file patch. |
| S2-R2-A-02 / S2-B10 (hidden `machine start` in "read-only" logs-dump) | **Remove** `fly-logs-dump.yml` (brief: prefer remove if diagnostic). Read-only log capture already exists in `fly-logs.yml` (env-quoted, `--no-tail`). Test: file absent; no operator workflow other than `fly-deploy.yml` invokes `flyctl machine start|stop|restart|destroy|deploy|scale`. Documented as an intentionally removed capability; a future boot-capture needs the mutation gate. |
| S2-R2-A-03 (verifier discovery fail-open; zero verifiers accepted) | `release.sh`: new **step 0 preflight before any DB contact**: `prisma/migrations` must be a directory; discovery via an explicitly checked pipeline into a list file (no `< <(…)`); required-verifier contract file `scripts/release-required-verifiers.txt` must exist, list ≥1 migration dir, and every entry must resolve to an existing discovered `verify.sql`; any failure exits before `migrate deploy`. Step 4 iterates the captured list and asserts `ran == discovered ≥ required ≥ 1`. Contract file lists the integrated S1 verifier `20261224000000_rls_close_public_exposure` (name to be confirmed by S1 owner via `execution/s2-r3/INTERFACE_S1_S2.md`); consequence: standalone S2 release_command refuses at step 0 (pre-migration) until S1 lands — intended fail-closed composition. Dockerfile runtime copies the contract file and asserts presence. Offline probes: discovery failure → exit ≠0 before deploy; contract missing/empty/unresolved → exit ≠0 before deploy; happy path with fake prisma + required present → 0 and counts match; verifier RAISE → exit 1. |
| S2-R2-A-05 / S2-R2B-02/03/04 (recovery overclaims) | Runbook §3/§7/§11.4 and `delivery-controls.md` §7 rewritten as stage-specific: (a) pre-migration failure (step 0/1) — nothing changed; (b) migration/verifier failure after `migrate deploy` — DB may be ahead of running code, old machines serving; (c) post-rollout failure (verify-fly-release / readiness) — machines already replaced; red run ≠ unchanged production. Forward-only rule: revert code only, never delete an applied migration directory; first gated release rollback target = `machines-before.json` `image_ref.tag` (current prod image has no `sha-*` tag); supersede "re-dispatch previous main sha". |
| S2-R2B-01 (delivery-controls doc misstatements) | Fix §2.5 (admin bypass is required false, not "reported"), §2 manifest filename, §3 "passing checks" → readiness curl only, §6 environment name `noble-celebration / production`. |
| S2-R2-A-04 (SBOM wording) | Rename claim to denylist/sentinel check in docs + script header; no closure-equivalence claim. |
| S2-R2B-07 (lint never run) | `shellcheck` + `actionlint` on successor head. Neither binary is present in the sandbox and no install is allowed without a slot → **request**: one-off download of static `shellcheck` (v0.10.0) and `actionlint` (v1.7.7, matches `infra-lint.yml`) into `/home/user/workspace/execution/s2-r3/tools/` (outside repo), then `shellcheck scripts/**/*.sh` and `actionlint -color` in `worktrees/s2-r3`. Until granted, lint is reported as NOT RUN. |

Not touched: `scripts/setup-branch-protection.sh` backup-GET caution (A §5) — recorded as follow-up, hosted-settings owner; `release.sh` `--url` argv exposure (B-09, low) — recorded; gate/SBOM logic unchanged.

## Ownership intersections
- S1: verifier directory name + grant/role postconditions inside `verify.sql`; S2 never edits `prisma/**`. Interface file written for S1.
- S3: `dependency-audit.yml` composition unchanged.
- S5: recovery directions referenced, not implemented (drain/fencing stays unimplemented and is stated so).

## Validation request (smallest)
1. Cheap offline (running now, no slot): Python YAML parse of all workflows; bash probes above (fake `flyctl`/`prisma`, temp dirs, serial, seconds each).
2. **Slot A (small):** static binary download + `shellcheck`/`actionlint` (~1 min, network to GitHub releases, no repo dependency install).
3. **Slot B (moderate):** `npx jest test/ci` at the final head with reused read-only `node_modules` only if package/lock unchanged vs a lane that has them (disclose provenance); otherwise skip and report focused tests as NOT RUN.
4. Integrated S1/S2 synthetic `release.sh` run against S1's loopback fixture (parent-scheduled, S1 leads).

Output: `execution/s2-r3/{PLAN.md, INTERFACE_S1_S2.md, REPORT.md, HEAD.txt, probes/, logs/, bundle/}`.
