# OP88-S5-V7 — controls-v7-selective: read-only T3 checker + T0-only driver (PREPARATION ONLY, nothing executed)

Worker: `s5_selective_v7_fixer_mud58q6n` (op88 designated S5 T4 fixer; requested Claude Fable 5 — requested setting, not observed runtime telemetry). Sole writes: `/home/user/workspace/execution/op88/s5-v7`. Prepared 2026-09-22 ~20:47–20:58 UTC. Backend S5 lane, T4. No PR, push, commit, hook, install, Jest, node_modules, DB, network, canonical-lock open/probe, or control/checker execution occurred. Only reads, `sha256sum`, `diff`, `git bundle verify`/`rev-list --missing=print` (read-only, no fetch), `bash -n`, `node --check`, and `sed` line-deletion/append to derive counterexample fixtures inside the owned directory.

## 0. Exact inputs read (all re-hashed now; archive manifests verified: wave6 16/16 OK, controls-v6-gate 3/3 OK)

| Input | SHA256 / identity |
|---|---|
| `execution/OP88_WAVE1.md` §S5 + common contract; live `tgp-agent-context/AGENT_RULES.md`; private `LAST_OPERATOR_STATE.md`, `LAST_OEPRATOR_HANDOFF.MD`; `execution/EXECUTION_REPAIR_WAVE_2.md` §S5-TIER2-V7-SELECTIVE-PREP; `execution/CONTINUATION_20260922.md` §S5; `execution/DISPATCHES.md` row S5 | read in full |
| v6 driver `tier2-control-v6/controls-v6-gate/ctl-teardown-gate.sh` (derivation base) | `b7207f46a69eaa8fe984d7bc61a6c666ea568367a0a45104d47d8eb5abdad7c3` |
| v6 diff / request / manifest | `3efdb856…f466` / `cc6b14be…4357` / `2dc9d9ab…7208` |
| `controls-v3/controls-v3/lib.sh` (sourced by driver, unchanged) | `a08b762b89f50ef0d272da817b08290e07df326a85ea6759afda7baa0394bed2` |
| fake harness `controls-v3/…/teardown-gate/fake-harness.ts` (unchanged) | `2de5fe248126637b28cd0687fea3e4ce43e0c1552ba6a034b21479fac088ab21` |
| control config `…/jest.control.config.js` (unchanged) | `a6eeb1cd1797388a2f81e5b2980bcc9b62e25852e3cd9923aa8168d482ab5e71` |
| preserved T3 record `wave-6-gate-failed/control-results/wave6-gate/gate-20260922T060647Z-T3.jsonl` (16 lines) | `ae38014a86d8f054e7046518c20270d021ba2d9fdac56c9d962dc19679cf7909` |
| preserved T3 Jest log `…/gate-20260922T060647Z-T3.jest.log` (858 lines) | `d6c3c1d7605b2750a90017aa7cabf2265170a19af725ac44eb284f4ff5c7ef10` |
| `WAVE6_FIRST_FAILURE.md`, `control-20260922T060647Z.log`, `outer.exit` (=1), `start` | `be03ca73…`, `069804c1…`, `eaee266f…`, `0b036935…` |
| `tier2-preparation-1/TIER2_SETUP_REQUEST_V1.md`; setup runner `setup-v1/run-s5-setup-npm-ci.v1.sh` | `f28e4779…`; `74736a5878fe4620adfb8dfe8f0a1c88e12b4f08a5313d3a52017e1deb8ebeaa` (listed in `SHA256SUMS.tier2-prep`, not re-read line by line) |
| `tier2-plan-b/REPORT.md`, `SUMMARY.json`, `addendum-1/ADDENDUM.{md,json}` (B: v6 source-grantable, no remaining findings) | read in full |
| `checkpoint-1/{REPORT.md,RECREATE.md,SHA256SUMS}`; dirty patch `s5-r4-dirty-from-143d451e.patch` | patch `c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491` |
| S5 bundle `2026-09-21/…/checkpoint-5-B3/s5-r3-candidate.bundle` | `e42aa021442a8a004bf796e2958461bf79d11c1666fe8fb08ef46dd80bd75b48`; `git bundle verify` OK: head `refs/heads/execute/20260921-s5-r3` = `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`, requires `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Baseline `/home/user/workspace/source/backend` | HEAD `c23b9d9f…`, porcelain clean, **partial clone** (`remote.origin.promisor=true`, `partialclonefilter=blob:none`; 19 993 objects reachable from HEAD are locally missing, 74 of them under `package.json`/`test/utils/g2-pg17-db.ts`/`test/rls-g2-pg17-etq0.spec.ts` history) |

Raw-byte re-verification of the wave-6 first failure (read-only `grep -c` on `ae38014a`): unescaped `DELETE FROM "ScoutImport"` = 0, JSON-escaped `DELETE FROM \"ScoutImport\"` = 1, `DROP CONSTRAINT IF EXISTS g2p_target_refusal` = 1, `"fn":"resetData"` = 1, `"mutating":true` = 5, `PG17_TEARDOWN_SKIPPED` in the T3 log = 0 (T1/T2 logs: 2 each). Matches `WAVE6_FIRST_FAILURE.md` exactly: S5-TIER2-GATE-V6-01 is a control-check pattern defect in v6 L80, not a spec/harness/Jest finding. Wave 6 remains FAIL and immutable; nothing here relabels it.

Observation (not a finding, no change proposed): all 16 T3 records carry `"phase":"setup"`, including the three teardown records; the fake's `setPhase` is never invoked on this path, so `phase` is not a teardown discriminator. The checker, like v6, discriminates by `fn`/`stmt`/`mutating`.

## 1. Delivered (frozen; hashes in `SHA256SUMS.controls-v7-selective`)

### (a) `controls-v7-selective/check-t3-teardown.cjs` — JSON-aware READ-ONLY checker (node ≥ 20, no dependencies)
`node check-t3-teardown.cjs <T3.jsonl> <T3.jest.log> [--json out]`; reads two files, spawns nothing, writes only stdout and the optional JSON summary. Exit 0 = all predicates PASS, 1 = any FAIL, 2 = usage/read error. Each JSONL line is `JSON.parse`d and shape-checked (`fn`,`phase`,`mutating`,`stmt`,`t`); predicates evaluate decoded field values — no escaping is layered onto grep.

| Predicate | Meaning | Relation to v6 |
|---|---|---|
| `T3.record_parse` | every line one well-shaped JSON record, ≥1 record | new (fail-closed input validity) |
| `T3.setup_partial` | mutating `sql` record with `GRANT USAGE`; record with `ADD CONSTRAINT g2p_target_refusal` | v6 L79 equivalent (decoded) |
| `T3.teardown_ran` | `teardown.drop` (sql, mutating, contains `DROP CONSTRAINT IF EXISTS g2p_target_refusal`) AND `teardown.resetData` (fn `resetData`, mutating) AND `teardown.delete` (sql, mutating, decoded `stmt === 'DELETE FROM "ScoutImport"'`); output names any MISSING part | v6 L80 equivalent, defect closed |
| `T3.teardown_after_failed_alter` | the three teardown records occur after the ADD CONSTRAINT record, in order drop < resetData < delete | **V7 additional discriminator, separately named** (does not alter v6 predicate meaning; reviewer may strike) |
| `T3.log_bound` | log nonempty, contains the fake's `fake: ALTER TABLE failed after authorized GRANT (partial setup)`, `Ran all test suites matching test/candidate.spec.ts`, a `Test Suites:` summary | new (binds the log to the authorized-partial run; prevents an empty/wrong log passing `no_skip`) |
| `T3.no_skip` | `PG17_TEARDOWN_SKIPPED` occurrences = 0 | v6 L81 equivalent |
Observations printed (not predicates): both input sha256/sizes, record count, mutating count, and whether the v6 L80 unescaped vs escaped literal matches the raw bytes.

Expected on the exact preserved inputs (static reading of `ae38014a` lines 11/13/14/15/16 and of `d6c3c1d7`): all six PASS, rc 0. **Not run; this is an expectation, not a result.**

### (b) `counterexamples/` — four fixtures derived deterministically from the preserved bytes (`derive-counterexamples.sh`, `bash -n` OK; derivation executed once with sed; hashes below)
| Fixture | Derivation | Expected checker outcome |
|---|---|---|
| `N1-missing-drop.jsonl` `f167885f…c5c5` | `sed '14d'` (removes DROP CONSTRAINT teardown record) | rc 1, `FAIL T3.teardown_ran … teardown.drop=MISSING` |
| `N2-missing-resetData.jsonl` `a8d56891…a8bb` | `sed '15d'` (removes resetData record) | rc 1, `FAIL T3.teardown_ran … teardown.resetData=MISSING` |
| `N3-missing-delete.jsonl` `093239df…7c9c` | `sed '16d'` (removes `DELETE FROM "ScoutImport"` record) | rc 1, `FAIL T3.teardown_ran … teardown.delete=MISSING` |
| `N4-skipped-marker.jest.log` `2880d6f6…3d5e` | preserved log + one appended `PG17_TEARDOWN_SKIPPED` console.warn block | rc 1, `FAIL T3.no_skip … occurrences=1` |
Verified statically after derivation: N1–N3 have 15 lines, N4 has exactly one marker; line-level diffs vs the originals are exactly the one deleted/added block each. (`T3.teardown_after_failed_alter` will also FAIL on N1–N3 as "not evaluable"; the wrapper asserts the named `teardown_ran` part.)

### (c) `controls-v7-selective/run-t3-checker.sh` — bounded wrapper (`bash -n` OK; NOT executed)
Requires `S5_CTL_GRANT=granted-by-parent` (rc 2 otherwise). Pins by sha256 before any node call: T3 JSONL `ae38014a`, T3 log `d6c3c1d7`, checker `ae5842aa21c28b49620acfae53fa52bd26ad29d7ab5dc45739df9f38aca65d88`, all four fixtures (rc 2 on any mismatch). Records a read-only `stat` of the canonical lock path (never opened/probed). Runs P0 (positive) then N1–N4, each `timeout -k 5 20 node …`; per-call bound 20 s, aggregate bound 120 s (refuses to start a call with < 5 s left); first unexpected outcome (rc or missing named `FAIL`/`PASS` line) stops with `STOP_ON_FIRST_UNEXPECTED`, all outputs retained under `$S5_V7_OUT` (default `<packet>/checker-results`). Expected positive record: `PASS P0.rc0`, `PASS P0.T3.{record_parse,setup_partial,teardown_ran,teardown_after_failed_alter,log_bound,no_skip}`, `PASS N1.missing_drop`, `PASS N2.missing_resetData`, `PASS N3.missing_delete`, `PASS N4.skipped_marker`, `SUMMARY pass=11 fail=0`, wrapper rc 0. Archive root overridable via `S5_V7_ARCHIVE` (still hash-gated).

### (d) `controls-v7-selective/ctl-t0-only.sh` — T0-only driver derived from exact v6 (`bash -n` OK; NOT executed)
Exact delta `controls-v6-to-v7-t0-only.diff` (46 lines; 11 added: 10 header comment lines + `AGG_BOUND=380`→`AGG_BOUND=120`; 14 removed: v6 L69–L81 = the T1, T2 and T3 `run_gate` blocks and their checks, plus the old `AGG_BOUND` line). Everything else is the v6 bytes: `control_preconditions` (grant, QUARANTINE), HEAD `143d451e` gate, dirty-fingerprint `6850b32e` gate, `.bin/jest` gate, strict jest 30.4.2 / ts-jest 29.4.9 / typescript 5.9.3 / jest-circus inside-worktree identities, fake-harness/config hash gates (all rc 2 before any child), private `mktemp` control root, I0 candidate-copy check, unchanged `run_gate` (owned `setsid` group, 90 s → TERM → 10 s → KILL, `.owned` census), `mut()`, unchanged T0 block (`run_gate T0 predecessor.spec.ts refused-identity`, `T0.defect` ≥2 mutating incl. DROP + resetData = FAILING predecessor behaviour asserted, `T0.refusal_reason` identity `toMatchObject`/`not_the_disposable_db`/no `Exceeded timeout`), first-failure stop, EXIT-trap reap and root retention, `summary`. The predecessor spec is taken from `git show 143d451e:test/rls-g2-pg17-etq0.spec.ts` as before. No spec/harness/config/lib edit; `controls-v3/` in this packet holds byte-identical copies of `lib.sh`, `fake-harness.ts`, `jest.control.config.js` so the driver's relative `../controls-v3/` source lines resolve inside the owned packet.

Per-control bounds: one Jest run ≤ 90 s + 10 s grace; aggregate 120 s; recommended outer `timeout --foreground -k 20 140`. Expected positive: `I0.inputs`, `T0.owned`, `T0.defect`, `T0.refusal_reason`, `SUMMARY pass=4 fail=0`, driver rc 0, Jest rc nonzero by design. Expected refusals (no child spawned): grant unset rc 2; QUARANTINE rc 4; HEAD/fingerprint/jest/identities/harness/config mismatch rc 2; budget hit or survivor → `T0.owned` FAIL rc 1 with retained root.

## 2. Implemented vs tested vs unrun (truth table)
- Implemented: (a)–(d) above, manifest, this request. Static checks only: `bash -n` on three shell files, `node --check` on the checker, diffs and hashes.
- Tested: **nothing**. The checker has not been run on any input; the counterexample fixtures were derived (sed) but not fed to the checker; the T0 driver has not been run. All "expected" outcomes are static readings.
- Unrun/unproven: checker discrimination, T0 predecessor behaviour under real jest-circus at this head, any DB behaviour, live 51-case run, hooks/generate/commit, a green v6 wave (never claimed).
- Preserved unchanged: wave 6 FAIL (12 PASS / 1 FAIL / T0 NOT RUN, 06:06:47–52Z, outer 1, no survivors); valid T1/T2 observations (named refusals, zero mutation, skipped markers, `.owned`); T3 `setup_partial`/`.owned` observations; all archive bytes (private evidence porcelain clean; manifests verified).

## 3. Finding closure and remaining blockers
- S5-TIER2-GATE-V6-01 (v6 L80 escaping defect): **source-closed** by (a)+(c); closure is proven only when R1 below runs and shows P0 rc 0 and N1–N4 each rc 1 on the named predicate.
- T3.no_skip and T0 (not evaluated in wave 6): T3.no_skip is evaluated by the checker on the preserved log (expected PASS, 0 markers); T0 requires R2.
- Blocker B1 (T0 execution dependency): `/home/user/workspace/worktrees/s5-r4` (HEAD `143d451e` + dirty patch `c36258b3`, fingerprint `6850b32e`) and its setup-v1 `node_modules` **do not exist in this workspace** (parent confirmed: no application dependencies inherited; `worktrees/` absent). The lib.sh constant `CANDIDATE_WORKTREE=/home/user/workspace/worktrees/s5-r4` and the frozen setup runner `74736a58` (`WT=worktrees/s5-r4`) both name that path. I did not create `worktrees/op88-s5` — not needed for (a)–(d), and creating a differently named worktree would require a changed setup runner/lib.sh (new hashes, new review) or a non-pinned path override; neither is assigned.
- Blocker B2 (restoration input): the baseline is a `blob:none` partial clone; a fresh isolated clone + checkout of `143d451e` may need promisor blob fetches from GitHub for files not already materialized (19 993 missing objects reachable from HEAD; the working-tree blobs at `c23b9d9f` appear present). Restoration per `RECREATE.md` steps 1–4 is therefore not guaranteed offline; this is a concrete missing-dependency report, not silently resolved.
- Blocker B3: setup-v1 `74736a58` performs `npm ci --ignore-scripts` (registry network, ~1117 packages per the historical positive record, which is historical and not present) under the canonical lock; that is a separate grant. The old install is not claimed to exist.

## 4. Narrow executable requests (none granted by this document; independent narrow checker/selector review precedes R1/R2)
- **R0 — independent narrow applicability review** (read-only) of `check-t3-teardown.cjs`, the four fixtures, `run-t3-checker.sh`, and `controls-v6-to-v7-t0-only.diff`: confirm predicates are v6-equivalent on decoded values, counterexamples are discriminating, the V7 additional `teardown_after_failed_alter` and `log_bound` predicates are acceptable (or strike them), and the T0 delta is deletion-plus-bound only.
- **R1 — read-only T3 checker slot** (grantable independently of any setup; node only; ≤ 140 s; no lock, worktree, node_modules, DB, network): `cd /home/user/workspace/execution/op88/s5-v7 && S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 140 bash controls-v7-selective/run-t3-checker.sh; echo "outer_exit=$?"` (capture the raw wrapper status, not echo's). Positive = `SUMMARY pass=11 fail=0`, rc 0, retained `checker-results/`.
- **R2 — T0-only real-Jest slot**, explicitly staged; every stage is a separate grant and none exists yet: (i) restore `worktrees/s5-r4` per `RECREATE.md` steps 1–4 from `source/backend` + bundle `e42aa021` + patch `c36258b3`, verify HEAD/tree/ancestry/fingerprint (`d0e122d3…` tree before patch, `6850b32e` after), resolving B2 if blobs are missing; (ii) fresh isolated dependency setup by the frozen setup-v1 runner `74736a58` (network `npm ci --ignore-scripts`, canonical lock fd 9, positive record `FINAL rc=0` / identities OK / fingerprint unchanged / hooks absent / generated client absent) — **a fresh install, not the historical one**; (iii) then `cd /home/user/workspace/execution/op88/s5-v7 && S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 S5_CTL_OUT=/home/user/workspace/execution/op88/s5-v7/control-results timeout --foreground -k 20 140 bash controls-v7-selective/ctl-t0-only.sh; echo "outer_exit=$?"`. Positive = `SUMMARY pass=4 fail=0`, rc 0, `gate-<ts>-T0.{jsonl,jest.log}` retained, `AGGREGATE_ELAPSED` ≤ 120 s, no survivors. No real PG, generate, hooks or commit.
- Combined S5 Tier-2 acceptance, when R1 and R2 are positive, may cite: wave-6 T1/T2 (12 PASS, immutable) + V7 checker on preserved T3 (`setup_partial`, `teardown_ran`, `no_skip`) + V7 T0 (`defect`, `refusal_reason`, `owned`). It must never be described as a green v6 run; wave 6 stays FAIL.

## 5. Success does not prove
A green V6 wave; real database behaviour; the live 51-case run at any head; hook/formatter installation; the final S5 commit or its two independent exact-head attestations; native completion or product audit.

## 6. Smallest next action
Parent assigns R0 (independent narrow review of the checker/fixtures/wrapper/T0 delta); on closure, grant R1 alone (read-only, node-only) before any R2 setup stage.
