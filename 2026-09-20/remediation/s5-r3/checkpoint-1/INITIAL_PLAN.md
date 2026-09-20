# S5 R3 initial plan — validation-only fixer (T4)

Written 2026-09-20 22:45 UTC by the S5 R3 fixer. Requested routing: Claude Fable 5 / High (parent's catalog request). Actual runtime identity is not independently verifiable from inside this session and is not claimed; tools used are read/bash/git/file writes only.

## Base and ownership

- New worktree `worktrees/s5-r3`, branch `execute/20260920-s5-r3`, created detached from frozen R2 head `485c67973b56758fb9b8404579f5ddaec87136bd` (tree `2fbf5028413557f99faea3f1de27b1352a4fe8d4`); `worktrees/s5` remains detached at the same head, untouched.
- Identity: repository-local `.git/config` `Bradley Gleave <bradley@bradleytgpcoaching.com>`; `git var GIT_AUTHOR_IDENT`/`GIT_COMMITTER_IDENT` confirmed before any commit.
- Files S5 may write: `test/rls-g2-pg17-etq0.spec.ts`, `test/utils/g2-tq0-worker.cjs`, `test/utils/g2-pg17-harness.ts`, `test/utils/g2-pg17-bootstrap.sh` (comments/preflight pointer only), new `test/utils/g2-pg17-old-root.sh`, and packet docs/scripts under `execution/s5-r3`. NO `src/`, `prisma/`, generator, workflow or S1 recovery-text edits.

## Findings addressed

| Finding | Repair | Owner |
|---|---|---|
| S5-R2-A-02 / S5-R2B-03 (terminal result logged, not asserted; post-completion state unasserted; refused branch never exercised) | (a) Existing claim-race characterization: snapshot ledger/targets before starting the paused worker; after `done`, assert branch-specific terminal outcome (`down-applied` ⇒ `failure {500, 'Internal server error', P2022}`, `result` undefined, no completion event, zero ledger rows for the source, zero Person/entity targets, column still absent, history 165) BEFORE forward repair; after forward repair assert T replay reclaims exactly one row/one target. `down-refused` branch keeps both legal orderings (commit vs P2028 failure) but asserts coupled ledger/target atomicity for each. (b) New deterministic refused-branch test: harness-only `txTimeout` option lets the T worker's interactive transaction outlive E's 5 s `lock_timeout`; asserts `down` is refused with `lock timeout`, column/catalog/history untouched, then the released claim commits intact (`reconstructed`, one Person, target_id linkage, completion event). No product source or product timeout changes; the knob is passed only as a Prisma `$transaction` option in the fixture process. | S5 |
| S5-R2-A-03 / S5-R2B-01 (archive-only O recreation cannot pass bootstrap's Git identity gate) | New `test/utils/g2-pg17-old-root.sh`: creates a disposable detached `git clone --shared --no-checkout` of the candidate root and `checkout --detach 925780e0` (no shared refs modified), then preflights exactly the bootstrap gate offline: `rev-parse HEAD`, clean relevant-path diff, identical `package.json`/lock vs candidate, no E directory, 164 migrations, byte-identical `src/scout/*` service files. Runs without DB or dependencies. Packet README/runner recipe corrected; `git archive` recipe struck. | S5 |
| S5-R2-A-01 / S5-R2B-02 (E recovery wording: "idempotent forward file" vs E's fail-closed non-idempotent forward file) | NOT S5's to write. Mapped explicitly to S1 (sole E recovery/schema owner) in `S1_HANDOFF_E_RECOVERY.md` with the exact measured facts S1 must incorporate; S5 only removes/avoids the "idempotent" wording in its own fixture docs and the harness comment that cites "S1's verified recovery guidance". | S1 via parent |
| S5-R2B-07 (hard-coded port 54325 in spec `beforeAll`) | Read the port from the guarded target instead; one-line cleanup, nonmaterial. | S5 |

Not touched: hosted applicability, serving role, drain/fencing procedure, PG-version CI/doc truth, ledger-tally wording (service owner), C1/#526 ordering. Accepted 50/50 + 26/26 historical evidence at `485c6797` is preserved unchanged and not re-run for duplication.

## Ownership intersections

- S1: E recovery packet text (S5 supplies measured facts only); S1's PG17 lane `lane-pg.sh s5` is the fixture server; S1 destructive-target guard review precedes any S5 DB run.
- S2: verifier interface — S5's spec already proves `prisma migrate deploy` false "No pending migrations" after out-of-band down and `resolve --rolled-back` P3012; S5 will not add verifier workflow logic. If S2 needs the exact catalog check S5 uses (`pg_attribute ... attname='source_platform' AND NOT attisdropped`), it is in `test/utils/g2-pg17-harness.ts` `hasColumn`.
- No shared dependency tree is modified; `node_modules` is absent in every S5 worktree in this sandbox.

## Minimal synthetic execution request (for the parent slot, after S1 guard review)

Cost: `npm ci --ignore-scripts && prisma generate` in `worktrees/s5-r3` (Prisma 6.19.3; ~2–4 min, heavy lock), plus ONE serialized `guard → oldroot → bootstrap → live` replay (~4 min; previous run 201 s live + 9 s guard) on S1's lane s5 (PG 17.6, port 54325, database `g2_s5_etq0_disposable`, loopback only, explicit confirmation `g2_s5_etq0_disposable:54325`, password via `G2_PG17_PASSWORD` only). `reset` drops only that disposable database.

Order:
1. `bash execution/s5-r3/run-proof.sh oldroot` — offline; creates and preflights the detached O clone (no DB, needs only git). Can run before dependencies.
2. `bash execution/s5-r3/npm-ci.sh` — heavy lock; only when parent requests.
3. `G2_PG17_PASSWORD=<lane s5 fixture> bash execution/s5-r3/run-proof.sh reset && ... all` — non-blocking lock (`flock -n`); fail-fast; exit codes preserved; head/tree/status/env stamped.

Expected: guard 26/26, `G2_PG17_OLD_ROOT_OK`, `G2_PG17_BOOTSTRAP_OK`, live 51/51 (50 existing + 1 new deterministic refused-branch test). The existing claim-race test's `down-applied` branch is the expected observed branch; either branch is legal. One infra-class rerun allowed per S5-A-11/S5-R2B-03 with both logs preserved.

Until that slot: static edits, `bash -n`, `node --check`, and a type-check only if an existing compatible `typescript` binary is available read-only (candidate: `worktrees/s6/node_modules/typescript` — different package tree, disclosed if used; it would be syntax-only because backend deps are absent).
