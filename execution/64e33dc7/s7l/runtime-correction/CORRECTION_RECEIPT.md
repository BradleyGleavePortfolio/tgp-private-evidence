# S7-L runtime minimum correction — CORRECTION RECEIPT (05:32Z)

Grant: `S7L_RUNTIME_MINIMUM_CORRECTION_GRANT.md` (parent disposition 05:23Z; source-gate relay 05:22Z section). Builder `s7_l_replacement_builder_muge72rg`. Status: **DRAFT_READY for dual changed-question review; NOT accepted; NO PG run granted or performed.** Heavy authority ended at slot release 05:25:39Z and was not reacquired.

## 1. Lineage (exact)
accepted base `93389265a846095b846fa8f1fb0dad782fb6ee9f` (tree a315dd65) → v1 `839b54c53ccb252f95b4ec63df0b08595bbe7698` (tree f02205c6, preserved) → v2 `54970cd937afc8dea689b33243961abfef8b9dd6` (tree 513c71d7, preserved; failed first proof) → **v3 head `a68cdac70d81aea384fdc99c01c9c983a08e80eb`, tree `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb`**, branch `exec64/s7l-replacement`, worktree `/home/user/workspace/worktrees/64e33dc7-s7l` clean. Author = committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, date 2026-09-25T05:24:52Z, 0 trailers, no amend/bypass/push.

## 2. Source delta 54970cd9 → a68cdac7 (exactly one file)
`test/rls-g2-s7l.spec.ts` (+11 −6), new blob `94e7fac4b8cbb8a8e2146700cbdc7ce9129b9f92` (was 052fa35d). Stage-1 test "a held transaction on the run table makes up hit lock_timeout (55P03); nothing applied; release → free" only:
- P1: `refusedFile(upFile, '55P03')` → `refusedFile(upFile, 'canceling statement due to lock timeout')` (psql default stderr message; S8-B pattern). No psql verbosity or migration change.
- P2: `started`/`refusedFile`/timing/`lifecycleColumns`/`shape` assertions wrapped in `try { … } finally { holder.release(); }`; the `await holder.held` barrier, 200 ms settle and the released-lock `pg_locks` assertion after the block are unchanged. Two explanatory comment lines added. No assertion removed, no skip, no kill fallback, no global registry/afterAll sweep, no harness/timeout change.
Nothing in `src/**`, `prisma/**`, contracts, other tests, helpers, dependencies, hooks or workflows changed (verified by `git diff --name-only`). Patches: `bundle/v3/s7l-v3-followup-54970cd937af-to-a68cdac70d81.patch` (c49357ed…), cumulative from base (705ab156…).

## 3. Gate run (slot 5, `runtime-correction/slot-5-runtime-correction.sh`, log `slot-5.log` b97cab38…)
Launched after the explicit relay (S8-C released 05:20:40Z, parent verified no holder 05:22:14Z). pid 26198, canonical `flock -n` fd9 inode 691716 ACQUIRED 05:24:48Z → RELEASED 05:25:39Z rc0 (lock file preserved). Preconditions: HEAD == 54970cd9, tree 513c71d7, modified set exactly the one path. Isolated prettier 3.9.9 prefix re-verified 56/56 (never re-copied), `npx --no-install prettier --check` rc0 (no rewrite required), `npx eslint --max-warnings 0` rc0 (empty log), checkpoint `runtime-correction-02-formatted-precommit`, staged tree 6c00e248, `git commit -F commit-message.txt` with genuine lefthook v2.1.9 pre-commit (R75 --cached, prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc 45.17 s — all pass) and commit-msg (no-ai-tokens pass), `NODE_OPTIONS=--max-old-space-size=4096`, offline npm config (`commit-attempt-1.raw.log` fd16699f…). Not run (per grant): default Jest unit suite, PG spec, contract regen, install, 48-suite rerun.

## 4. Checkpoints and exports
- `checkpoints/runtime-correction-01-precommit` (pre-format source, spec sha b893157e…) and `runtime-correction-02-formatted-precommit` (identical bytes; prettier required no change).
- `bundle/v3/`: `s7l-v3-a68cdac70d81.bundle` 7cd4c05b… (thin, requires 93389265; verified), `s7l-v3-a68cdac70d81-full-history.bundle` 5aac1c75… (complete history; verified), follow-up and cumulative patches, `MANIFEST-name-status-…` (`M test/rls-g2-s7l.spec.ts`), `HEAD-a68cdac70d81.txt` 4da3e7c5…, `SHA256SUMS`.

## 5. Binding v3 (`s7l/binding/v3/`, frozen 05:30:27Z from the committed clean head)
- `s7l-pg-proof.sh` **0c33b22279324b39132d06f4c7e5e00d9158bdb89e2174306389e043d7dedffd**
- `s7l-fixture.sh` **721468ac49eae624697feafa78ddfbddab9fee41303be03c36c66c923e6f7945** (v2 fixture + exactly 3 changed lines: LANE, DATA/SOCK line, one comment)
- `freeze-v3.sh` 875c6ba3…, `PINS.txt` 28772b0b…, `README.md` 0533695b…, `DELTA-v2-to-v3.md` e8e804d7…, `driver-v2-to-v3.diff` 1debd672… (taken pre-fill; placeholders shown), `fixture-v2-to-v3.diff` 44ffeb9b…
- `BINDING.sha256` file sha256 **82f501a33c8e0325e6b0781a6afdf12533a89e1b945cc8b3a56761182a16aac2**; supplement (outside the freeze, for reviewers): `driver-v2-to-v3.filled.diff` (post-fill diff) + `SUPPLEMENT.sha256`.
- Pins: EXPECT_PARENT 54970cd9, EXPECT_HEAD a68cdac7, EXPECT_TREE 6c00e248, EXPECT_SPEC_BLOB 94e7fac4; all other proof-object/schema/migration blobs and all tool pins unchanged from v2 and re-verified OK at freeze (HEAD_PIN_OK ×14, TOOL_PIN_OK ×10).
- Fresh runtime paths under `/home/user/workspace/execution/64e33dc7/recovery-reset`: data `proof-v3/clusters/s7l/pg-data`, socket `proof-v3/run/s7l`, old-root `proof-v3/s7l/old-root` (+`.g2-s7l-old-client`). `CLUSTERS=$RUNTIME_ROOT/clusters` kept; both other-lane loops now exclude the own lane by actual `$LANE` path so the retained failed v2 `clusters/s7l` is checked as another stopped lane. Port 55641, identities, markers, canonical lock, bounds, single Jest invocation, cleanup and sentinel semantics unchanged.
- Lineage checks in driver and freeze: HEAD^ == 54970cd9 (tree 513c71d7), HEAD^^ == 839b54c5 (tree f02205c6), HEAD^^^ == base, base ancestry, one-path delta. freeze-v3 additionally verified v1 and v2 `BINDING.sha256 -c` intact and v2 run `jest.log` hash d6253d28… unchanged.
- v1 (`binding/`), v2 (`binding/v2/` incl. `run/`), failed v2 lane `clusters/s7l`, `run/s7l`, `s7l/old-root`: untouched.

## 6. Not done / boundaries
No PG, bootstrap, database probe, fixture action, unit or PG test execution, install, generate, acceptance, push or production change. Record-only C items unchanged (general holder hardening, harness session timeouts, log-hash-before-END ordering). Next: reviewers write `s7l/reviews/RUNTIME_CORRECTION_REVIEW_A.md` / `_B.md` against head a68cdac7 + binding v3; only two GO plus a separate parent single-run grant permit execution on the fresh v3 lane.
