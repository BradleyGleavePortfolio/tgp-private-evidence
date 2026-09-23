# S3-PREP2-INTEGRATION validation (slot-03V) — request-03 steps 09–14 all raw 0 on head be0ba827 (revision 1, frozen)

Executor: `restore_s3_candidate_mue9wspd`, sole T4 builder/executor, parent EXEC-6c2a68ac. Requested policy Claude Fable 5 / High; runtime telemetry not observable, not asserted. Activation: parent mail + `tgp-private-evidence/execution/6c2a68ac/S3_STEP08_DISPOSITION_AND_VALIDATION_ACTIVATION.md` (sha256 `aeaf7339eb12d232a6a0c49551958a0f67dd46169b54fa4adff2d0a47730cf43`, committed at private `90ff9a6e`). Executed 2026-09-23T17:05:36–17:11:55Z. Prior packets untouched: continuation seal **ca604a0d…** 23/23 OK at start; stopped result `bf7800bd…`; restoration `s3-restore/`. Original step 08 raw 127 and its newline-comparison note remain as recorded there; nothing relabelled, no identity re-review.

## 1. Applicability (`logs/V0`, once, read-only)

HEAD `be0ba8274e486dee77f15d18fe367a13ff08ecf5`, tree/write-tree `a584a1b95423f95dae8daabf673ef3776604acbb`, parents `d5cd9b8b… 5c7b42b3…`, porcelain 0, MERGE_HEAD absent, lock `b7fed5ed…` ✔, tool CLI `6e922134…` ✔ (link intact), node_modules + generated client present, canonical lock free, no lane processes, `~/.npm/_npx` 0. Nothing reinstalled, regenerated, formatted, committed or hooked.

## 2. Step statuses (request-02 §1 pattern; holders label `S3-PREP2 slot-03V`; env `NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true CHECKPOINT_DISABLE=1` + notification-off vars stamped in each header; every `flock -n` acquired immediately; each step's post-check limited to command exit + write-tree/HEAD unchanged, plus for 09 bundle existence and bundle head)

| Step | Command (from `$W`) | Bound | Raw exit | Result | step_status |
|---|---|---|---|---|---|
| 09 | `git bundle create $O/s3-into-s1s2-be0ba827-from-public-c23b9d9.bundle c23b9d9f…..HEAD && git bundle verify … && sha256sum …` | 60 s | 0 | "is okay"; contains `be0ba827… HEAD`, requires `c23b9d9f…`; sha1 algo; **sha256 `d204a582acab8c07ec108ceca5411fa2786756742b1917c89fe76f85195e2d7b`** (273,998 bytes) | 0 |
| 10 | `node scripts/check-r75.js --mode=range --base=c23b9d9f… --head=HEAD` | 60 s | 0 | policy `be0ba827:.github/r75-policy.json`; "as any: +2 -2 net 0 — OK, no positive token change" | 0 |
| 11 | same, `--base=d5cd9b8b…` | 60 s | 0 | "as any: +2 -2 net 0 — OK" | 0 |
| 12 | `npx --no-install eslint --max-warnings 0 scripts/check-r75.js test/ci/{r75-gate,r75-boundaries,r75-wiring,r75-enforcement,r100-pathspec,dependency-audit}.spec.ts` | 300 s | 0 | no output (0 problems, 0 warnings); 2 s | 0 |
| 13 | `npx --no-install tsc --noEmit -p tsconfig.json` | 900 s | 0 | no diagnostics; 45 s | 0 |
| 14 | `npx --no-install jest --ci --runInBand --verbose` + the exact 20-entry targeted list | 1800 s | 0 | **Test Suites: 31 passed, 31 total; Tests: 825 passed, 825 total; Snapshots: 0**; 288.956 s; 0 FAIL lines, 0 console.warn/error lines, 0 obsolete | 0 |

No timeout, no kill, no unexpected mutation, no unknown. No step re-run.

## 3. Source preservation and final state (`logs/V9`)

HEAD unchanged `be0ba827…`; tree `a584a1b9…` before and after every step; porcelain 0 (also `--untracked-files=all` 0 beyond ignored); MERGE_HEAD absent; commit object sha256 `297de278…` unchanged; lock `b7fed5ed…` unchanged; hooks `pre-commit`/`commit-msg` still installed; repo-local identity Bradley Gleave unchanged; `~/.npm/_npx` 0 → no network resolution in 09–14 (npm offline). Engine-binary fetch disclosure unchanged (16:44:25Z during original step 03; `PRISMA_ENGINES_MIRROR` unset). No product source, formatting, private-checkout, peer worktree or remote write. S2-owner composed-proof prep lane not touched or probed.

## 4. Not claimed

Not a full suite, build, deployment, applicability or acceptance decision; not the two independent final-head nonauthor attestations nor the S2-owner composed-lock release proof (both downstream). Hook-pass evidence and steps 12–14 are validation on the exact committed tree only. Warnings W1–W8 from the prep packet remain findings, not edits. The head exists only as a detached local commit in `worktrees/s3-prep2` plus this bundle; no branch ref, no push.

## 5. Owned outputs and runtime release

`execution/6c2a68ac/s3-integration-validation/{REPORT.md, SHA256SUMS.txt (non-self-including), bundle, bundle.sha256, logs/V0, 09–14 (+ empty *.runner.out), V9, steps/*}`; `.holders` appended 12 lines (`slot-03V`). Worktree, substrate, hooks and head preserved for attestation. **Canonical runtime slot released** to parent EXEC-6c2a68ac with this report; this lane holds no process, lock or further write.
