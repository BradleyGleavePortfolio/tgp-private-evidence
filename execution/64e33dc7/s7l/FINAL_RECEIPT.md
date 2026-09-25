# S7-L replacement builder — FINAL RECEIPT (2026-09-25T04:40Z) — candidate frozen for two independent reviews

## Candidate
- branch `exec64/s7l-replacement`, worktree `/home/user/workspace/worktrees/64e33dc7-s7l`, clean
- base `93389265a846095b846fa8f1fb0dad782fb6ee9f` (tree a315dd65) -> **HEAD `839b54c53ccb252f95b4ec63df0b08595bbe7698`**, **tree `f02205c60ad0bfeb24ce82d74b0025ee9a185df6`**, single commit, HEAD^ == base
- author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailer block (git interpret-trailers empty), subject `scout: S7-L server-owned run lifecycle (Start/Cancel, writer gate, fences, arbiter)`
- genuine lefthook: pre-commit prod-readiness-quick / banned-cast-tokens / prettier 3.9.9 (isolated builder-local prefix, offline npx) / eslint / tsc (heap 4096) all pass; commit-msg no-ai-tokens pass — `gates/commit-attempt-3.raw.log`
- 30 files, +5582/-35; surface exactly the granted paths incl. the amended `src/scout/scout-ingest.controller.ts` 409 decorator+import; S8-C `scout-reconstruct.service.ts`, S8-B proof files, jest.rls.config.js, package(-lock).json, lefthook.yml, .github all blob-identical to base (asserted again by the driver preconditions)
- generator: `scripts/importer-contract.ts` blob 1d50fe99 (sha 7e89abfe...), `docs/contracts/importer-openapi.json` blob 3c1fd2ac sha `fc42af0a8ec8f162dbc8e79dc05eeb09663d735b031314c316d98e834ed8d60e`, CONTRACT_VERSION `2.0.0-c1-s2.0`, ingest 409 enum [run_not_started, run_fenced]; `test/contracts/importer-contract.spec.ts` blob e3db4b62, 56/56 targeted

## Exports (bundle/, all in SHA256SUMS, verified)
- `s7l-839b54c53ccb.bundle` (thin: prerequisite 93389265 — retained as granted)
- `s7l-839b54c53ccb-full-history.bundle` (self-contained, `git bundle verify`: complete history; heads HEAD + refs/heads/exec64/s7l-replacement) — added per parent grant
- `s7l-839b54c53ccb.patch`, `MANIFEST-name-status-839b54c53ccb.txt`, `HEAD-839b54c53ccb.txt`; earlier tree-7086b682 exports unchanged
- checkpoints draft-01..04 unchanged

## Slot
- run 1 pid 25779 04:27:23-04:27:29Z rc72 (prettier file filter; fixed), run 2 pid 26166 04:28:15-04:30:19Z rc0; flock in-process fd9, lock file preserved; released at exit; parent confirmed no holder 04:31:04Z. Lock is now held by another process (pid 795, S8-C) — not S7-L. No S7-L process alive; no postgres; `recovery-reset/clusters` still absent.

## PG proof binding (binding/, source-only, NOT RUN, no PG granted) — frozen 04:39:00Z, `binding/BINDING.sha256`
- `s7l-pg-proof.sh` sha `3e97da2e51fdb7eab32cb828620e639d92c4ed9f6e527eadd2c4a8ae62cef307` — complete candidate-bound driver; canonical `flock -n` on fd9 in-process held to exit; all head pins FILLED (EXPECT_HEAD 839b54c5, tree f02205c6, 10 proof-object ids, fixture sha) and all tool pins (PG17.6 postgres/initdb/pg_ctl, psql 18.6, node 20.20.1, lockfiles, generated client, schema, jest.rls.config.js); fresh unique paths (clusters/s7l/pg-data, run/s7l, s7l/old-root, port 55641); old-image (detached base, 171 migrations via OLD root) / new-image (candidate client verified, spec applies S7-L in L01); bounded stages (outer `timeout -k 30 3900`); raw jest log + RECEIPTS.sha256 + sentinel; bounded stop cleanup; single-shot
- `s7l-fixture.sh` sha `dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2`; `freeze.sh` `c891972b...`; `PINS.txt` `c41a53a7...`; `README.md` `22fe2dfa...`
- freeze.sh re-derived every head pin from the committed clean head and re-checked tool sha256s read-only: 13 HEAD_PIN_OK, 10 TOOL_PIN_OK, 0 mismatches. Two freeze-script false refusals (naive trailer regex hitting the `scout:` subject; pipefail on grep -c) were fixed in freeze.sh itself, not by editing any pin. No source edits after the commit.

## A/B residuals (unchanged; recorded in SOURCE_READY.md)
Prisma full-unique vs DB partial-unique on the intent link; legacy spec doubles amended; pinned catalog renderings unverified until PG; no S9 reconciliation path; ingest 409 closed. C classifications by parent: unprotected donor copy 04:02-04:05Z; thin-bundle prerequisite.

## Not done / not claimed
No PG run, no fixture init, no 48-suite rerun, no push, no production, no historical-evidence edits, no S8-C paths, no self-acceptance.
