# S10-B gate + real-PG binding — independent review B

Scope: I read the source only and ran nothing. That covers `s10b/gate/` (s10b-gate-d3a9.sh, PINS.env), `s10b/binding/v1/` (s10b-pg-proof.sh, s10b-fixture.sh) and the S10-B harness bytes in worktrees/d3a9-s10b. I used only read-only git, with `GIT_OPTIONAL_LOCKS=0`, and ran no index commands.

## Verdict: NO-GO as frozen; GO once the pin changes in §3 are made

- **Safety envelope:** sound. I found no class A issue.
- **Why NO-GO:** the frozen pins still assume S10-A is one commit on a4af8e33. The new plan puts S10-A on e6f20300. With the current bytes, the gate and the binding fail closed. But several of the stale checks run *after* the one-shot sentinel is written, so a run with stale pins uses up the gate or binding without producing a proof (B1).
- **What turns it into GO:** the pin edits listed in §3. None of them loosens a safety property.

## 1. Safety envelope (verified, no finding)

**Lock**
- The binding opens the lock with `exec 9>>` and `flock -n 9`, then checks inode = 692282 (s10b-pg-proof.sh:94-96).
- The fixture refuses to run unless `S10B_RUNNER_PID` is a live `s10b-pg-proof.sh` (fixture:34-35).
- The fixture closes fd 9 for PG children with `9>&-` (fixture:39).
- The gate does the same: inode checked against LOCK_ESTABLISHED and 692282, then `flock -n` (gate:~111-118).

**One-shot sentinel**
- Binding: `$SENT` present → rc 76 (s10b-pg-proof.sh:93). `finish` writes the sentinel on every exit after the lock is taken (:101-103).
- Gate: `$E/STARTED` present → rc 76 (gate:111). STARTED is written at gate:118, straight after ACQUIRED.

**Fresh lane only**
- The binding refuses if `clusters/s10-b` exists, if the socket dir is non-empty, if port 55647 has a listener, or if `pgrep -cx postgres` ≠ 0 (s10b-pg-proof.sh:199-202).
- Fixture `init` refuses an existing `$DATA` (fixture:50).

**Other lanes**
- Every `clusters/*` and `proof-*/clusters/*` lane (including s9-c) is refused if it has a postmaster.pid.
- Each lane's postgresql.conf and pg_control shas are recorded before and after the run and must match (:203-208, :250-255).

**Identity markers before writes**
- Fixture `start` and `destroy` require the `cluster_name` marker (fixture:73, :84).
- Bootstrap checks `cluster_name` before any write (g2-s10b-bootstrap.sh:83-86).
- The binding's identity step checks: data_directory, 170006, cluster_name, DB comment marker, 173 applied migrations, `max(migration_name)` = S10-B dir, 3 tables with ENABLE+FORCE RLS, and `inet_server_port` (:221-235).

**Refused ports, roles and DBs**
- In g2-s10b-db.ts:55-75, `REFUSED_PORTS` lists 5432/5433/6543 and every earlier lane port through 55646 (S9-C).
- The role and DB are allow-listed exactly: `s10b_super` / `g2_s10b_disposable` (db.ts:14, 23, 84-87). That refuses s9c_super, g2_s9c_disposable and every other lane.
- The binding also checks that 55647 is *not* refused and that 55646 *is* (:158-159).

**G2 env isolation**
- Every `G2_*` variable except `G2_S10B_*` is unset, and `G2_S10B_WORKER` is unset too (:82-83).
- The exported set (:84-87) covers every `process.env.G2_S10B_*` the harness reads: DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, CANDIDATE_HEAD.
- `WORKER` is set only by pg-harness.ts:131 for its children.

**Teardown**
- The stop is bounded (75 s).
- Afterwards the binding requires `pgrep` = 0, port free, no postmaster.pid, and the datadir retained (:244-248).
- On failure after start, `fail` runs a bounded stop and logs survivors (:105-108).

**The jest run cannot pass vacuously**
- Command: `jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts --runInBand --ci`. The config's testMatch includes `test/rls-*.spec.ts`.
- It needs rc 0 **and** the line `^Tests: +24 passed, 24 total` (:239-241).
- The `it(` count at HEAD must be 24 (:160). The worktree has 24, with no skip/only/todo/xit/fit.
- The spec blob is pinned (:161-165).

**Fixture captured-bytes check**
- `data_dir_users` now captures `/proc/<pid>/cmdline` into a variable and uses a here-string `grep -qF` (fixture:45-46). There is no `tr | grep -q` pipe left.
- Apart from that fix, the diff against the s9c v2 fixture is literal substitution only.

**Gate**
- Relay, pin and banned-token checks run before the lock.
- No `| grep -q` pipelines.
- The targeted suite needs `Test Suites: 7 passed, 7 total`.
- The contract is regenerated in scratch and compared with cmp against `HEAD:contract`.
- R75 runs both early and on the staged set.
- The commit is hooked and checked for identity and trailer.

## 2. Findings

### B1: stale base pins fail after the one-shot sentinel is written, so the run is used up with no proof
- **Evidence:**
  - Gate: STARTED is written at gate:118. `BASE^ != S10A_PARENT` is checked at gate:131 and the contract blob/sha at gate:177, both after it.
  - Binding: `finish` writes `$SENT` on any exit after the lock. `BASE^ != S10A_PARENT` is checked at s10b-pg-proof.sh:126.
  - PINS.env:8 and s10b-pg-proof.sh:34 still say `S10A_PARENT=a4af8e33…`.
  - PINS.env:61-62 pin the a4af8e33 contract: blob 8ebf936a, sha 9eacdd3e.
- **Harm:** S10-A will be committed on e6f20300. As frozen, the gate refuses (rc 70) but has already written STARTED, and the binding would do the same with its sentinel. That uses up the single authorised attempt and forces a new grant and re-freeze. No product or data consequence.
- **Blocks:** the S10-B gate commit and the PG proof.
- **Minimum fix:** make the §3 pin changes before any run. Then dry-check them with the gate's read-only `--fill-help` probe (gate:58-59 prints BASE^, schema blob, contract blob and the S10A_PARENT..BASE delta) against the real S10-A landing.
- **Unblocks:** one gate run and one binding run that can actually succeed.

### B2: the gate's `HARNESS_BASE_HEAD` rule contradicts the planned base
- **Evidence:** gate:79 requires `HARNESS_BASE_HEAD = S10A_PARENT or BASE`. PINS.env:9 has a4af8e33. The harness literals are `BASE_HEAD=a4af8e33…` (g2-s10b-bootstrap.sh:29) and `G2_S10B_BASE_HEAD = 'a4af8e33…'` (g2-s10b-db.ts:140).
- **Harm:** once S10A_PARENT = e6f20300, the gate refuses with rc 78. This check runs before the lock, so it does not use up the gate, but the gate cannot run.
- **Fix option (a), recommended:** replace gate:79 with an ancestor rule, `git merge-base --is-ancestor $HARNESS_BASE_HEAD $S10A_PARENT`. gate:132 already checks the ancestor against HEAD. Keep HARNESS_BASE_HEAD = a4af8e33. This works because:
  - a4af8e33 is e6f20300's first parent.
  - `git diff a4af8e33..e6f20300 -- prisma` is empty: schema blob 2e328bbc and migrations tree 654550cb are the same at both commits.
  - `package.json` and `package-lock.json` shas are the same at both commits.
  - So the harness's prisma check (exactly 3 files versus base, bootstrap:151-158) and the binding's check (:136-137) still hold.
  - No owned bytes change, and the binding blobs stay valid. The binding already uses the ancestor form (:128).
- **Fix option (b):** change both harness literals to e6f20300. This changes owned bytes (OWNED_PINS, EXPECT_BOOTSTRAP_BLOB, DB blob) and needs a re-freeze and re-review.
- **Unblocks:** the gate runs on the e6f20300-based S10-A.

### B3: S10-B dev-loop evidence was produced on a4af8e33, not on the new base
- **Evidence:**
  - observation.service.ts:11-12 imports `isFenceReason`, `runConflict`, `ScoutLifecycleService`, `Tx` and calls `lifecycle.classifyClosed`.
  - S9-C changed `lifecycle.service.ts`, `reason-codes.ts` and `reason-domains.ts` (+413/-15). The `RUN_REASON_CODES` changes are additive: three appended codes plus new enums.
  - The exported symbols S10-B uses still exist at e6f20300. I checked by source only; I compiled nothing.
- **Harm:** a compile, behaviour or test mismatch would only show up inside the one-shot gate (tsc/jest) or binding, and would use up that attempt (same failure mode as B1).
- **Minimum fix:** before the gate, run one non-binding dev-loop tsc + jest pass of the S10-B tree on the real e6f20300-based S10-A commit.
- **Unblocks:** confidence that the one-shot gate will not fail on the S9-C interaction.

### C findings
- **C1:** comments and log text still say "on a4af8e33": gate:131 message, PINS.env:8 comment, s10b-pg-proof.sh:34 and :126 message, pg-harness.ts:10/:34, bootstrap:6. Builder summary lines 55-56 state the old assumption.
- **C2:** `jest.rls.config.js` is not blob-pinned by the binding. It is covered indirectly: the BASE..HEAD delta is exactly the 16 paths, and the file is the same at a4af8e33 and e6f20300 (sha 99c9f4f1…).
- **C3:** `land-s10a.sh:2-4` has `TIP=a4af8e33…`. This belongs to S10-A, but it must change (see §3).
- **C4:** the worktree d3a9-s10b is at a4af8e33 with the S10-B files uncommitted. It has to move to the new BASE carrying those changes. There is no path overlap with S9-C's 22 paths, so this is expected to be clean. The gate's exact status set and OWNED_PINS checks will confirm it.

## 3. Exact pins/checks to change for S10-A on e6f20300

| Where | Current | Change to |
|---|---|---|
| s10a/land/land-s10a.sh:4 `TIP` | a4af8e33… | e6f20300b495fa9eee9539ae58d30e3b60e5a78c (after PR #547 fast-forwards integration/importer) |
| gate/PINS.env:8 `S10A_PARENT` | a4af8e33… | e6f20300b495fa9eee9539ae58d30e3b60e5a78c |
| gate/s10b-gate-d3a9.sh:79 rule | `HARNESS_BASE_HEAD ∈ {S10A_PARENT, BASE}` | ancestor rule (B2 option a); or option (b) with harness literal edits and re-freeze |
| gate/PINS.env:9 `HARNESS_BASE_HEAD` | a4af8e33 | keep with option (a); e6f20300 only with option (b) |
| gate/PINS.env:62 `CONTRACT_BLOB` | 8ebf936a9f12… | 752f9dbe1a6bdee0c20504a35dce60757880d427 (e6f20300:docs/contracts/importer-openapi.json) |
| gate/PINS.env:61 `SHA_CONTRACT_JSON` | 9eacdd3e… | 2db3f27f482d4b26012924bbcf14437df7ac62cf834eebeccffc2d6a27665098 |
| gate/PINS.env:5-7 `BASE`, `BASE_TREE`, `MIGRATIONS_TREE` | `__FILL__` | fill from the real S10-A commit; MIGRATIONS_TREE must be 654550cb99b5… (same at e6f20300) |
| binding s10b-pg-proof.sh:34 `S10A_PARENT` | a4af8e33… | e6f20300b495fa9eee9539ae58d30e3b60e5a78c |
| binding :35 `HARNESS_BASE_HEAD` | a4af8e33 | keep (ancestor check at :128 already); change only with option (b) |
| binding `BASE_HEAD`, `BASE_TREE`, `EXPECT_*` fills | `__FILL__` | from the S10-A commit and the gate receipt, as designed |
| GATE.sha256 / BINDING.sha256 | — | re-hash after the edits and re-review the diff |

**Unchanged and still valid at e6f20300** (checked with read-only git):
- BASE_SCHEMA blob 2e328bbc and the 0eb41f9a schema
- BASE_MIGRATIONS_TREE 654550cb (172 migrations)
- PKG_LOCK b7fed5ed…, PKG_JSON afecdb37…
- donor client 9042e713 (same schema)
- the S10-A FREEZE file (sha d54aee78) and its 14 paths, which do not overlap S9-C's 22 paths
- the 16-path S10-B `EXPECT_DELTA`
- FORBIDDEN_DELTA_PATHS (applies to BASE..HEAD only)
- all S10-B owned blobs, provided option (a) is taken

The "one commit" shape itself still holds: S10-A is one commit whose parent is e6f20300, and the S10A_PARENT..BASE delta is exactly the 14 FREEZE paths. Only the parent pin moves.

## Delta review (DELTA-review-fix, BASE 92b96715)

Read-only review of `gate/DELTA-review-fix.diff` and `binding/v1/DELTA-review-fix.diff` plus the current bytes. I ran nothing and used no index commands. `GATE.sha256` and `BINDING.sha256` both verify with 0 mismatches, and the fixture sha is 7d9ee89b…, which matches `EXPECT_FIXTURE_SHA`.

### Verdict: GO for the gate and binding source. One B item (B3) stays open, and I recommend closing it before the one-shot gate is relayed

**B1: closed**
- Gate:
  - Every pin/shape precondition now runs before the sentinel and the lock (gate:113-184). This covers HEAD/tree/branch, BASE^, harness-ancestor, hooksPath, index, MERGE_HEAD, status, OWNED_PINS, FREEZE, node_modules, schema, migrations, literals, contract, hooks and syntax.
  - The pre-lock `finish` only logs and exits, and writes neither STARTED nor TERMINAL (gate:117).
  - STARTED is re-checked before the lock (gate:186) and written only after `flock` (gate:193). `finish` is redefined after ACQUIRED.
  - Nothing in gate:1-194 writes to the clone. `mkdir -p $E` and `prelock.log` sit in the evidence dir. `GIT_OPTIONAL_LOCKS=0` is set for the pre-lock git reads.
- Binding:
  - All preconditions run before the lock. The pre-lock `fail` only logs to `prelock.log` and exits, and `$SENT` is written only by the post-lock `finish`.
  - The sentinel check is symlink-aware, both before and after the pre-lock block.

**B2: closed exactly (option a)**
- The pre-lock equality rule is removed (old gate:79).
- It is replaced by `merge-base --is-ancestor HARNESS_BASE_HEAD BASE` and `HARNESS_BASE_HEAD S10A_PARENT`, both pre-lock with rc 78 (gate:128-129).
- `HARNESS_BASE_HEAD` stays a4af8e33 in PINS.env:9 and the binding (:35), and the harness literals are unchanged. The binding's ancestor check (:117) is unchanged.

**Pin table: every value is correct.** I checked each against 92b96715 with read-only git:

| Pin | Value | Result |
|---|---|---|
| `S10A_PARENT` (PINS.env:8, binding:34) | e6f20300b495… | = `92b96715^` |
| `CONTRACT_BLOB` / `SHA_CONTRACT_JSON` | 752f9dbe… / 2db3f27f… | = `92b96715:docs/contracts/importer-openapi.json` |
| `MIGRATIONS_TREE` (expected) | 654550cb | = 92b96715 migrations tree |
| `BASE_SCHEMA_BLOB` | 2e328bbc | = 92b96715 schema blob |
| S10A_PARENT..BASE delta | 14 paths | 14 paths |
| BASE tree (for the fill) | b6fbbfd2a6495183433657814193b080c9582ab7 | recorded for the fill |

- Worktree d3a9-s10b is now at 92b96715 on branch `exec-d3a9/s10b`, with the status set exactly `1 M + 15 ??`.
- All 16 OWNED_PINS sha+mode values match the working bytes. The new devloop-2 bytes cover dto, service, spec, two unit specs, fixtures, harness and worker.
- The binding's devloop-2 blob hints (spec b89fec1c, db 3375f08b, worker e0af8412) match `git hash-object --no-filters` on the working bytes, and the `it(` count is 24.
- `land-s10a.sh` `TIP` is moot, since S10-A is already committed on e6f20300.

**Under-lock re-check set: sufficient**
- Gate (gate:196-199): HEAD, exact status, empty index, no hook paths (including symlinks), no node_modules, and the OWNED_PINS shas. Together with the unchanged post-commit checks (lineage, tree, delta, forbidden paths, contract, identity, trailer), anything that moved in between fails closed.
- Binding (:218-220): fixture sha, HEAD, clean status, candidate client sha and donor client sha, then the full preflight, which stays under the lock.

### Findings

**B3 (from the first review): still open. The devloop-2 evidence does not include S9-C**
- **Evidence:**
  - devloop-2 took the lock at 04:29:29Z. It copied the 14 S10-A FREEZE files into the worktree (`devloop.sh:8`, `run.log:2 S10A_COMPOSED 14`).
  - At that time the worktree HEAD was still a4af8e33. The reflog shows `a4af8e33 … 04:30:25 reset`, then `92b96715 … 04:40:43 Fast-forward`.
  - So devloop-2's `TSC rc=0` and `JEST 7/7, 150/150` ran against the a4af8e33 versions of `lifecycle.service.ts`, `reason-codes.ts` and `reason-domains.ts`, not the S9-C versions that `observation.service.ts:11-12` imports.
- **Harm:** tsc, eslint and the targeted and full jest runs on the real base (S9-C + S10-A + S10-B) happen for the first time inside the one-shot gate, after STARTED is written. Any mismatch uses up the gate. There is no product or data consequence, because the gate fails closed.
- **Blocks:** confidence that the gate is a single successful run.
- **Minimum fix:** one non-binding dev-loop run (devloop-3) of tsc + eslint + the 7 targeted suites on the worktree as it stands now (HEAD 92b96715 plus the 16 owned files), under the lock. The donor node_modules copy is already present.
  - If it passes with the bytes unchanged, relay the gate.
  - If bytes change, re-pin OWNED_PINS and re-hash GATE.sha256.
- **Unblocks:** the gate relay without the risk of using it up.

**New findings: no A. No new B. C only:**
- **C5:** the gate checks STARTED before `flock` but not after it (gate:186 → :192-193). Another gate run could finish between the check and the lock, and this run would then start again. The window is milliseconds, and the same ordering was accepted in S9-C. Adding `[ ! -e $E/STARTED ]` straight after `flock -n 9` would close it. The binding has the same pattern.
- **C6:** the gate's under-lock re-check leaves out OWNED_PINS mode, MERGE_HEAD, `core.hooksPath`, the branch, and the hooks directory not being a symlink. These are all checked before the lock. Only a concurrent actor between those checks and the lock could change them. `core.hooksPath` is the only one that could redirect the hooked commit. Suggest adding it to gate:196 as a one-line check.
- **C7:** the binding's under-lock re-check leaves out `EXPECT_NM_CLIENT_SCHEMA_SHA`. Only the client `index.d.ts` sha is re-checked; the schema sha is checked before the lock.
- **C8:** the gate's pre-lock stage now runs `node --version`, `npm --version` and `node --check`, and the binding's pre-lock stage runs `jest`/`ts-node`/`prisma --version`, all without the lock. These are lightweight and read-only, and prisma runs offline with `CHECKPOINT_DISABLE`.
- **C9:** `worktrees/d3a9-s10b/node_modules` exists now (the devloop donor copy). The gate refuses it before the lock (non-consuming, gate:~149), and the README "set-aside" parent step must move it first. Expected, noted here so the relay is not surprised.
