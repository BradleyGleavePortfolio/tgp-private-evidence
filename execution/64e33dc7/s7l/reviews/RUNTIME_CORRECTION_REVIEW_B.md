# S7-L runtime minimum correction — changed-question re-attestation, independent reviewer B (non-builder)

Written 2026-09-25 ~05:40Z under `S7L_RUNTIME_MINIMUM_CORRECTION_GRANT.md` (parent disposition 05:23Z) and the parent's
final-pins mail. Scope: P1/P2 closure, new head lineage, no other product change, scoped gates, exact v3 binding with fresh
`proof-v3` lanes and retained-lane hashing, unchanged tools. Read-only; no tests, probes, Git writes, PG, locks, gates or peer
reads. `REVIEW_B.md`, `REVIEW_B_V2.md`, `RUNTIME_REVIEW_B.md` untouched. This is the only file created.

## Verdict

**GO** for exactly one parent-bound execution of `s7l/binding/v3/s7l-pg-proof.sh` (outer `timeout -k 30 3900`) against head
`a68cdac70d81aea384fdc99c01c9c983a08e80eb` / tree `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb`, bound by
`s7l/binding/v3/BINDING.sha256` (file sha256 `82f501a33c8e0325e6b0781a6afdf12533a89e1b945cc8b3a56761182a16aac2`), on the fresh
`recovery-reset/proof-v3` lane, when the parent separately grants that single run and the driver's own preflight
(canonical lock free, port 55641 free, `pgrep -cx postgres` = 0) holds. No PG authority is implied by this attestation; S8-C is
the sole heavy grantee now. A pass on this run supports head a68cdac7 only and never the failed 54970cd9 run.

## 1. Lineage and head (worktree `/home/user/workspace/worktrees/64e33dc7-s7l`, `GIT_OPTIONAL_LOCKS=0`)

| Check | Observed |
|---|---|
| HEAD / tree | `a68cdac70d81aea384fdc99c01c9c983a08e80eb` / `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb` |
| HEAD^ / tree | `54970cd937afc8dea689b33243961abfef8b9dd6` / `513c71d7c1390787e1521ccbfa46b30bb52b5462` (v2 preserved) |
| HEAD^^ / tree | `839b54c53ccb252f95b4ec63df0b08595bbe7698` / `f02205c60ad0bfeb24ce82d74b0025ee9a185df6` (v1 preserved) |
| HEAD~3 | `93389265a846095b846fa8f1fb0dad782fb6ee9f` (accepted base); `merge-base --is-ancestor` true |
| Worktree | clean (`status --porcelain --untracked-files=all` empty) |
| Author = committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>`; subject `test(scout): S7-L PG proof spec — assert observed lock-timeout text; always release held transaction`; body describes P1/P2 only; no trailers |
| Delta HEAD^..HEAD | exactly `test/rls-g2-s7l.spec.ts` +11/−6, blob `052fa35d` → `94e7fac4b8cbb8a8e2146700cbdc7ce9129b9f92` |

## 2. P1 / P2 closure (`test/rls-g2-s7l.spec.ts`, stage-1 held-transaction test, L263-284 at the new head)

Hunk `@@ -265,12 +265,17 @@` verified line by line:
- **P1**: `refusedFile(upFile, '55P03')` → `refusedFile(upFile, 'canceling statement due to lock timeout')` — the exact text
  psql printed in the failed run (`binding/v2/run/jest.log` L38) and the accepted S8-B assertion (`test/rls-g2-s8b.spec.ts`
  L254). One explanatory comment added. No psql verbosity, harness or migration change.
- **P2**: `const started`, `refusedFile`, the `>= 4500` ms timing, `lifecycleColumns() == []` and `shape() == before`
  assertions are now inside `try { … }`; the pre-existing `holder.release()` is in `finally { … }` with one comment. The
  `await holder.held` barrier before the block, the 200 ms settle and the released-lock `pg_locks` count assertion after the
  block are unchanged. No assertion removed or skipped; no `kill` fallback, global registry, afterAll sweep, harness or
  timeout change; no other holder (§3.1/fence/stage-4) touched. This closes the exact cascade mechanism recorded in
  `RUNTIME_REVIEW_B.md` §2 (assertion throw before release → leaked lock → 20 cascades + open handle).

No other product change: blob pins re-derived from the new head and equal to v2 — bootstrap `ebef51fc`, old-root `cb1137fe`,
db `384e1b74`, pg-harness `d8b71d68`, harness `f0860a8d`, worker `a8fed545`, guard spec `27fcba5f`, migration directory tree
`4ce57646`, `prisma/schema.prisma` `2e328bbc` (sha256 `0eb41f9a…`), `lifecycle.service.ts` `5949a293`,
`lifecycle.service.spec.ts` `52d4f144`. `src/**`, `prisma/**`, contracts, helpers, hooks and dependencies untouched.

## 3. Scoped gates (`s7l/runtime-correction/`, `RECEIPTS.sha256 -c` all OK)

`slot-5.log`: canonical `flock -n` fd9 inode 691716 ACQUIRED 05:24:48Z (after the relayed S8-C release), isolated prettier
3.9.9 prefix verified 56/56, `PRETTIER_CHECK_1 rc=0`, `ESLINT rc=0` (empty `eslint.raw.log`), staged tree `6c00e248`,
`GIT_COMMIT rc=0`, thin bundle (requires 93389265) and full-history bundle both "okay", `DONE` and `RELEASING` 05:25:39Z.
`commit-attempt-1.raw.log`: genuine lefthook v2.1.9 pre-commit — prod-readiness-quick, banned-cast-tokens, R75 `--cached`
("OK — no positive token change"), prettier, eslint, tsc 45.17 s — all ✔️; commit-msg no-ai-tokens ✔️; resulting commit
`a68cdac7`, 1 file +11/−6. Not run, per grant: default Jest unit suite, PG spec, install/generate. `CORRECTION_RECEIPT.md`
(05:32Z) is consistent with every value above.

## 4. Binding v3 (`s7l/binding/v3/`, frozen 05:30:27Z)

Recomputed sha256 — all equal to `BINDING.sha256` (8/8) and `SUPPLEMENT.sha256` (2/2):
`s7l-pg-proof.sh` `0c33b22279324b39132d06f4c7e5e00d9158bdb89e2174306389e043d7dedffd`, `s7l-fixture.sh`
`721468ac49eae624697feafa78ddfbddab9fee41303be03c36c66c923e6f7945`, `freeze-v3.sh` `875c6ba3…`, `PINS.txt` `28772b0b…`,
`README.md` `0533695b…`, `DELTA-v2-to-v3.md` `e8e804d7…`, `driver-v2-to-v3.diff` `1debd672…` (pre-fill),
`fixture-v2-to-v3.diff` `44ffeb9b…`; supplement `driver-v2-to-v3.filled.diff` `2e31f986…`; manifest file `82f501a3…`.
v1 `binding/BINDING.sha256 -c` and v2 `binding/v2/BINDING.sha256 -c` all OK; v2 run receipts `jest.log` `d6253d28…` and
`s7l-pg-proof.log` `2eae19cd…` unchanged.

**Fixture delta (my `diff v2 v3` byte-identical to the recorded `fixture-v2-to-v3.diff`)**: L12 comment; L27
`LANE=$RUNTIME_ROOT/proof-v3/clusters/s7l`; L28 `SOCK=$RUNTIME_ROOT/proof-v3/run/s7l` (DATA/LOG derive from LANE). Guard
regex `/execution/64e33dc7/recovery-reset/.*/s7l/pg-data$` (fixture L35, spec L140) accepts the new data directory without any
committed helper change. Fresh-init-only refusal (L49), runner-PID gate, port, identities, markers unchanged.

**Driver delta (my `diff v2 v3` byte-identical to `driver-v2-to-v3.filled.diff`)**, exhaustively: header comment; usage path
and `D=…/binding/v3`; `EXPECT_PARENT` 839b54c5→54970cd9, `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_SPEC_BLOB` →
a68cdac7/6c00e248/94e7fac4, `EXPECT_FIXTURE_SHA` → 721468ac; `LANE`/`SOCK`/`OLDROOT` → `proof-v3/…` with
`CLUSTERS=$RUNTIME_ROOT/clusters` kept; placeholder/not-frozen messages say v3; lineage block now checks HEAD^==54970cd9,
its tree 513c71d7, `EXPECT_PARENT^`==839b54c5, `EXPECT_PARENT^^`==base, `EXPECT_PARENT^^{tree}`==f02205c6 (I resolved
`git rev-parse 54970cd9^^{tree}` read-only → `f02205c6…`, confirming the parent's peel-syntax reading); one-path delta check
`test/rls-g2-s7l.spec.ts`; both other-lane loops (preflight L161, post L211) exclude the own lane by `"${d%/}" != "$LANE"`
instead of basename `s7l`, so the retained `clusters/s7l` (stopped: no `postmaster.pid`, checked read-only) is hashed
(postgresql.conf, global/pg_control) before and after and must be unchanged. Nothing else differs: lock handling, fixture
calls, bootstrap, identity, single Jest invocation, stop/post, bounds, sentinel, exit codes are v2's.

**Tool pins** recomputed and equal: postgres `23cd1748…`, initdb `b7db9bc2…`, pg_ctl `af53d826…`, psql wrapper `a200e38c…`,
node `a03953a7…`, package-lock `b7fed5ed…`, `.package-lock` `05bc530a…`, client index.d.ts `9042e713…`,
jest.rls.config.js `99c9f4f1…`, schema `0eb41f9a…`.

`freeze-v3.sh` vs `freeze-v2.sh` (`freeze-v2-to-v3.diff`): v3 paths, PARENT 54970cd9 with v2/v1/base lineage refusals,
one-path delta, fixture delta must equal the recorded diff and be exactly 3 `>` lines, v2 `BINDING.sha256 -c` and v2
`jest.log` hash refusals added, manifest widened to the two diffs. `PINS.txt`, `README.md`, `DELTA-v2-to-v3.md` are
consistent with all of the above; `proof-v3/` does not yet exist under the runtime root (nothing has run).

## 5. Record-only (C) — no action requested

- C1: `driver-v2-to-v3.diff` inside the freeze is the pre-fill diff (placeholders); the actual filled comparison is the
  supplement `driver-v2-to-v3.filled.diff` outside the frozen manifest. I verified the filled one against my own diff; the
  parent's mail discloses this. Acceptable as documented.
- C2: the own-lane exclusion `"${d%/}" != "$LANE"` in the `$CLUSTERS/*/` loops can never match (the v3 lane is not under
  `$CLUSTERS`); it is harmless and correctly leaves `clusters/s7l` and `clusters/s8-c` in the other-lane checks.
- C3: scheduling, not a defect — `clusters/s8-c` now exists (05:33) and S8-C holds heavy authority; the v3 preflight fails 71
  on any live postgres or port-55641 listener, and the post check fails 74 if another lane's conf/control changes during the
  run. The parent must bind the run to a window in which S8-C's cluster is stopped and quiescent.
- C-R1/R2/R4 from `RUNTIME_REVIEW_B.md` remain record-only, unchanged.

## 6. Unverified (runtime) — unchanged from `REVIEW_B_V2.md`

Nothing has run on this head. F1/F2, L01–L12, catalog exactness, RLS byte-equality, barriers and the constraint matrix are
still runtime-unverified; the v2 run verified only OLD bootstrap 171, decoy refusals (×2), lock-timeout refusal on up/down
with nothing applied, and the driver's bounded failure path. The P1 literal is confirmed against the observed psql output;
P2 is confirmed by construction, not by execution.
