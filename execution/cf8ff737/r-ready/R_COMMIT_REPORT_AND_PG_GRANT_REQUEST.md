# R identity-ready — gates PASSED, committed; request for the separate single-run PG grant

T4 R builder → parent (cf8ff737). Heavy slot used 16:14:36Z–16:18:37Z and released (verified free). No push. No PG run.
Fable/High was requested for this builder; no telemetry is claimed.

## Head
- **HEAD** `df36e3310d4088501c93bcac3ce07617d02c749d` on `s7-r-ready` (worktree `/home/user/workspace/worktrees/s7-r-ready`)
- **TREE** `74ddf4dd57657300d96b9a7b0cdd6e6237a52abd` == frozen pre-gate write-tree (receipt 05; identical)
- parent `0d69c7ba…` (accepted B); author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no trailers; no amend
- subject `feat(importer): make scout identity ready with canonical platform tokens`; 11 files, +1961/−1
- Hooks: genuine Lefthook v2.1.9 pre-commit (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc — all ✔) and commit-msg (no-ai-tokens ✔), receipt 12
- Worktree clean after commit (porcelain 0). `s7-b-drain` untouched: clean, HEAD `0d69c7ba…`.

## Gates (in order, under lock, first-nonzero policy — none nonzero)
| gate | rc | elapsed | receipt |
|---|---|---|---|
| freeze (`git add -A`, write-tree, staged patch) | — | — | `receipts/05-freeze.txt`; patch sha `daeb32e8…` |
| lock `test-validation.lock` (`flock -n`) | acquired | — | `receipts/06-lock.txt` (release verified 16:18:37Z) |
| `tsc --noEmit` | 0 | 47 s | `receipts/07-gate-tsc.log` |
| `eslint --no-warn-ignored --max-warnings 0` on 7 changed .ts | 0 | 1 s (+ JSON confirm: linted, 0/0) | `receipts/08-gate-eslint.log` |
| `prettier --check` on 7 changed ts | 0 | 1 s | `receipts/09-gate-prettier.log` |
| `node scripts/check-r75.js --mode=staged` | 0 ("no positive token change") | 1 s | `receipts/10-gate-check-r75.log` |
| default Jest: `g2-r-ready-db-guard.spec.ts`, `scout-ingest.validation.integration.spec.ts`, `contracts/importer-contract.spec.ts` | 0 — 3 suites / 90 tests passed | 62 s | `receipts/11-gate-jest.log` |
| hooked commit | 0 | 47 s | `receipts/12-commit.log` |
`receipts/RECEIPTS.sha256` covers 01–12.

## Export (`execution/cf8ff737/r-ready/export/`)
- `s7-r-ready.bundle` (0d69c7ba..s7-r-ready, `git bundle verify` ok) sha `fe8e8440…`
- `s7-r-ready-df36e33.patch` (format-patch) sha `9a31a932…`; `r-ready-staged.patch` (pre-commit staged diff) sha `daeb32e8…`
- `COMMIT_MSG.txt`, `staged-status.txt`

## Binding (`execution/cf8ff737/r-ready/binding/`, pins filled from df36e33)
- `r-pg-proof.sh` filled sha **`ac437b90057ab471f851f63cc3bbb7a3ffc8b62e220154c3b0c075e8ee38be15`** (substitution-only `eba6eb0f…`; derived from B v5 `e895b16e…`, diff in `r-pg-proof.sh.diff-vs-b-v5`, generator `derive-r-pg-proof.py`)
- `r-fixture.sh` sha `6e71d754…` (from B v5 fixture `4525f01d…`)
- pins: HEAD `df36e331…`, TREE `74ddf4dd…`, SPEC blob `a6f3f166…`, BOOTSTRAP blob `67b77f7a…`, FIXTURE `6e71d754…`, NM lock `05bc530a…`, R client `7c367454…`, PG binaries unchanged
- `PINS.txt`, `BINDING.sha256`, `README.md` (substitution table; two added read-only checks: B files blob-identical at R head; stopped B cluster hashed/unchanged/never started)
- Identity: port 55471, `r_super`, `g2_r_ready_disposable`, CONFIRM `g2_r_ready_disposable:55471`, cluster `/home/user/pg17/clusters/r-ready`, marker `r-disposable-pg17`, new detached O checkout at `r-ready/runtime/old-root`

## Attestations
1. Actual head: `git -C worktrees/s7-r-ready rev-parse HEAD` = `df36e3310d4088501c93bcac3ce07617d02c749d`; `HEAD^{tree}` = `74ddf4dd…` (checked at pin fill).
2. Binding: `sha256sum binding/r-pg-proof.sh` = `ac437b90…`; `bash -n` ok; 0 placeholders remain.
(Both by the builder; an independent second attestation is the parent's call.)

## Request
Separate **single-run PG grant** for `timeout -k 30 3600 bash /home/user/workspace/execution/cf8ff737/r-ready/binding/r-pg-proof.sh`
(runs `test/rls-g2-r-ready.spec.ts` R01–R12 exactly once on a fresh r-ready cluster; data dir retained; destroy = separate grant).
Lane state now: no postgres processes; `/home/user/pg17/clusters/` has only `b-drain` (stopped) and `b-drain.v4-failed-…`; no `r-ready`, no `s5`; ~4.7 GiB free.
Not run until granted. No push.

## C qualifications carried (unchanged from receipt 04)
Contract JSON not regenerated (generator has no CLI plugin encoding the DTO rule; `importer-openapi.json` byte-identical); client schema.prisma differs from source only by Prisma formatting; one authoring `prettier --write` before the check gate.
