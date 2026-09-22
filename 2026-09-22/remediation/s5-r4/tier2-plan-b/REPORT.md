# S5-TIER2-PREP-NARROW-REVIEW B — setup `74736a58` and Tier-2 driver `4d09589c` (source review; nothing executed)

Reviewer B (`s4_r6_independent_audit_b_muc70jfl`; API-hosted AI subagent, model not exposed). Read-only: `sha256sum`, `diff`, `git` reads of the s5-r4 worktree, lockfile JSON read; no execution, probes, syntax checks, install, network, DB or product audit. Sole output: this directory. A source review is not a grant; setup and Tier-2 need separate parent grants, and both are ungranted while the S6 setup holds the canonical lock.

## 0. Exact inputs (all re-hashed)
| Input | SHA256 |
|---|---|
| `s5-r4/setup-v1/run-s5-setup-npm-ci.v1.sh` | `74736a5878fe4620adfb8dfe8f0a1c88e12b4f08a5313d3a52017e1deb8ebeaa` |
| `s5-r4/setup-v1/s6-91fe0f1b-to-s5-setup-v1.diff` | `6f48c9b19282d3eb2e9cadadfd7de5ae056dbb831af4bba9ef664c245576cfe3` |
| `s5-r4/controls-v5-gate/ctl-teardown-gate.sh` | `4d09589c34281975868631c5d2e4f90dd0b3a84ecce3a963226b5be45975c5f6` |
| `s5-r4/controls-v3-to-v5-gate.diff` | `71594e1987ca44d035be3de486fb521bcb8723b944222b8b68f4f252c120c4e2` |
| `s5-r4/TIER2_SETUP_REQUEST_V1.md` | `f28e4779e953fe8ba8e961f9151de2eed57ac6d35fd7e843ecc4275885b8d486` |
| `s5-r4/SHA256SUMS.tier2-prep` (5 entries, verifies 5/5) | `8882e12173888c6589e0d89877356f056d4fbd70e5fe5b25b79b8b90b457fd36` |
| Predecessors/inputs: S6 setup `s6-diagnostic/v3/run-c5-setup-npm-ci.v3.sh` | `91fe0f1b1db951a3d41b34afba528bb2e3815ba89f0154b917aeb01d9b197bd1` |
| `controls-v3/teardown-gate/ctl-teardown-gate.sh` (v3 driver) | `f922100c950c79683443ce79fdffbb5cd96aaa717b4dea0fe718a50117087a4a` |
| `controls-v3/teardown-gate/fake-harness.ts` / `jest.control.config.js` / `controls-v3/lib.sh` | `2de5fe24…ab21` / `a6eeb1cd…3e71` / `a08b762b89f50ef0d272da817b08290e07df326a85ea6759afda7baa0394bed2` |
Both declared diffs reproduce byte-for-byte from the actual files (unified-diff bodies identical; only the `---/+++` timestamp headers excluded).

Worktree facts read now (`/home/user/workspace/worktrees/s5-r4`): HEAD `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`; porcelain exactly ` M test/rls-g2-pg17-etq0.spec.ts` / ` M test/utils/g2-pg17-bootstrap.sh`; `package-lock.json` blob `354de3dae19449970497da6e4d87f0a1225a8f43`; `{ git diff HEAD; printf '%s\n' "$(git status --porcelain --untracked-files=all)"; } | sha256sum` = `6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0` — identical to the runner's `dirty_fingerprint()` definition and pin; `node_modules` absent; `.gitignore` ignores `node_modules/`; `package.json` has `postinstall: prisma generate` and `prepare: lefthook install`; lockfileVersion 3. Platform ancestor `/home/user/node_modules` has **210** top-level entries at review time (contemporaneous count; the runner gates on a names+mtimes hash, not a count).

## 1. Setup `74736a58` — adaptation from reviewed S6 setup `91fe0f1b`
Every non-comment change (per the reproduced diff) and its assessment:
| Lines (v1) | Change | Assessment |
|---|---|---|
| 16–18, 21–24 | `WT/EX/LOGS` → s5-r4; `PIN_HEAD`, `PIN_LOCK_BLOB`, `PIN_DIRTY_FINGERPRINT`, `PIN_DIRTY_STATUS` constants | All four pins match the worktree now (above). |
| 35 | `dirty_fingerprint()` | Same formula as `RECREATE.md`/`CONTROL_REQUEST.md` (`git diff HEAD` + porcelain incl. untracked); reproduces `6850b32e`. `node_modules` is gitignored, so the install does not perturb it. |
| 68–69, 73, 75, 79 | before-provenance adds fingerprint, hooks-before, npm debug-log count | Record only. |
| 81–84 | gates: HEAD, lock blob, **exact** porcelain, fingerprint (rc 2, before any child) | Correct: the dirty patch is required, anything else refuses. |
| 90, 92 | `npm ci … --ignore-scripts …` | Skips `postinstall: prisma generate` and `prepare: lefthook install`. From the lockfile, `hasInstallScript` packages skipped: `@prisma/client`, `@prisma/engines`, `prisma`, `lefthook`, `@scarf/scarf`, `core-js`, `unrs-resolver`, `fsevents` (mac-only) → no Prisma engine/client generation, no hook install, no scarf telemetry. Tier-2 does not need any of them (the candidate spec imports only `fs`, `path`, the fake harness and `g2-pg17-db.ts`, which has no imports). Registry fetches for the lockfile remain the inherent, declared network. |
| 99 | `npm_logs=[…]` on first_exit line | Raw npm logs in evidence dir; names recorded. |
| 104–112 | after record: fingerprint, `.package-lock.json` sha, bins, generated-client/hook presence | Record only. |
| 113–115 | gates: exact porcelain, fingerprint, `.git/hooks/pre-commit` absent (rc 6) | Correct; replaces the S6 clean-tree gate with the pinned-dirty equivalent. |
| 116–121 | strict identities: 12 modules must resolve inside `$WT/node_modules`; 7 pinned versions | Lockfile check: jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, @prisma/client 6.19.3, prisma 6.19.3, lefthook 2.1.9, eslint 10.5.0 — all exactly as pinned; jest-circus/jest-runtime/@jest/core 30.4.2, babel-jest 30.4.1, @babel/core 7.29.7 present; prettier absent (NOTE path is the expected one). |
| 63 | `runner_sha256=$(sha256sum "$0")` in START line | Good: self-attributing record. |
Unchanged from `91fe0f1b` (verified by diff, not restated): runner-held lock fd 9 with `9>&-` in the child, one owned `setsid` group, 1200 s budget → TERM → 30 s → KILL, `reap_group` result counted, ancestor-inventory GATE, `FIRST_EXIT` (primary) vs `FINAL` (90 on cleanup/ancestor failure, primary rc kept otherwise), signal path → FINAL 143, one-install-only refusal, external `timeout -k 30 1290`.

**Setup findings:** none blocking. Disclosures: (S-1) `--ignore-scripts` leaves `node_modules/.bin/lefthook` and Prisma non-functional by design — irrelevant to Tier-2, but any later hook/Prisma slot must not treat this install as complete for those tools (the request's §C already says so). (S-2) The request text "210 entries" is a contemporaneous description; the gate is the hash, which is correct. **Verdict: setup `74736a58` is source-grantable as frozen**, after the S6 setup releases the canonical lock (rc 75 otherwise). Positive record = `FIRST_EXIT npm-ci rc=0 how=exited`, `cleanup_exit=0`, ancestor `UNCHANGED`, `CLEANUP_FAILURES=0`, `FINAL rc=0`, `dirty_fingerprint_after=6850b32e…`, `hooks_pre_commit=absent`, `generated_client=absent`, 12× `OK` in `setup.module-paths.txt`.

## 2. Tier-2 driver `4d09589c` — bounds, owned cleanup, first failure, negative class
Verified on bytes (line numbers of `ctl-teardown-gate.sh`):
- **Gates before any child (L20–26, rc 2):** HEAD pin; `.bin/jest` present; strict jest/ts-jest/typescript identities inside the worktree (same pins as setup); fake-harness and control-config hashes pinned to the byte-identical v3 inputs (`2de5fe24`, `a6eeb1cd`). `control_preconditions` (lib L33–35) additionally requires `S5_CTL_GRANT=granted-by-parent` and no `QUARANTINE`. No lock, no network, no DB, no install (`env -i`, fixed PATH, `HOME=$CR`).
- **Ownership/bounds (L44–58):** each Jest run is `setsid` in its own group; poll ≤ `budget` (90 s, reduced to remaining aggregate); TERM → 10 s → KILL; `wait`; post-wait straggler TERM/2 s/KILL/1 s; census. `check <id>.owned` requires `how=exited` and empty group — a budget hit or survivor is the *first failed check* and stops the driver (lib `check` → `exit 1`, `S5_CTL_KEEP=1`). Aggregate bound 380 s (L46: refuses to start a run with < 5 s left → `GATE_RC=124`, no record → next `zero_mutation` check fails → stop). EXIT trap (L30–31) reaps all owned groups, retains the control root on survivors or keep, records aggregate elapsed; TERM/INT/HUP → exit 143 via the trap. Outer `timeout --foreground -k 20 400`: worst-case trap work (10 s grace + 1 s + census) fits in the 20 s kill margin.
- **Real assertion/copy applicability (L33–43):** candidate spec copied from the dirty worktree file and gated byte-identical (I0); predecessor from `git show 143d451e:…`; the real `g2-pg17-db.ts` (pure constants, no imports) copied; fake harness substituted for `g2-pg17-harness.ts` only inside `$CR`; `node_modules` symlinked from the worktree. Marker constants in the fake (`s5-disposable-pg17`, `s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop`) equal `G2_PG17_CLUSTER_MARKER`/`G2_PG17_DATABASE_MARKER` in the real module, so the copied spec can reach the pre-state gate in T2 and the mutation phase in T3. No spec/assertion change vs v3 (diff confirms).
- **Negative meaning — is a non-refusal failure excluded?** The T1/T2 predicates are `zero_mutation` (0 `"mutating":true` **and** ≥ 1 record line), `skipped_marker` (`PG17_TEARDOWN_SKIPPED` in the Jest log, emitted only by `afterAll` with `teardownAuthorized=false`) and, for T1, `jest_failed` (rc ≠ 0). Classification of the failure classes the parent named:
  - *Compile/transform failure* → no record lines → `zero_mutation` fails → stop. Excluded.
  - *Crash/abort before `afterAll`* → no marker → `skipped_marker` fails → stop. Excluded.
  - *Budget TERM/KILL* → `.owned` fails → stop. Excluded.
  - *Jest hook timeout or any other pre-authorization exception in `beforeAll`* (e.g. "Exceeded timeout of 30000 ms for a hook", a harness TypeError after the first recorded call) → Jest still runs `afterAll`, marker is emitted, mutations are 0, rc ≠ 0 → **all T1 (and T2) predicates pass**. Not excluded. With the synchronous fake harness a timeout is implausible, but the predicates do not name the intended refusal, so rc ≠ 0 + marker is doing the classifying.

**T2-1 (material for the control's intended-negative claim; smallest closure 3 lines, no new framework).** Add named-reason predicates from the Jest log, which already contains the failing assertion: after L64 `check T1.refusal_reason "$( grep -q 'not_the_disposable_db' "$OUT/gate-$CTL_TS-T1.jest.log" && ! grep -q 'Exceeded timeout' "$OUT/gate-$CTL_TS-T1.jest.log"; echo $? )" "beforeAll failed at the identity toMatchObject (received database not_the_disposable_db), not a timeout"`; after L67 the T2 analogue with `Received: "165"` (the `appliedMigrations` `toBe('164')` diff) and no `Exceeded timeout`; after L73 the T0 analogue with `not_the_disposable_db`. Consequence without it: a candidate that throws for an unrelated reason before authorization would be recorded as "refused-identity: zero mutation" — the frozen A-01 control claim would rest on rc ≠ 0 plus the marker rather than on the intended refusal. This is the only closure I require before Tier-2 execution.

**T2-2 (disclosure, not blocking).** The driver pins HEAD but not the dirty fingerprint; the candidate spec sha is logged (L42) and gated only against the live worktree file (I0). Attribution to `6850b32e` is therefore by the positive setup record (which gates the fingerprint after install) plus the logged sha, not by the driver itself. A one-line `dirty_fingerprint` gate would make the driver self-attributing; optional.

**T2-3 (disclosure).** T3 reaching `GRANT` depends on every read-only gate passing in the fake (schema/`gitShow` file expectations under `$CR/fakeroot`); if one does not, `T3.setup_partial` fails and the driver stops with raw logs — fail-closed, not repaired. `T1.jest_failed` is an additional requirement, not the discriminator, which is correct.

## 3. Verdicts (distinct)
- **Setup `74736a58`: source-grantable as frozen** (after the S6 setup releases the lock). No changes requested.
- **Tier-2 driver `4d09589c`: hold for one 3-line revision (T2-1)**, new hash and manifest entry; then grantable only after a positive setup record. T2-2 optional.
- **What positive runs would not prove:** Tier-2 shows real jest-circus hook semantics on the real spec text with a *fake* harness — not DB behaviour, not the live 51-case run, not hook/formatter installation, not the final S5 commit (still needs hooks and dual exact-head attestations).
