# S5-TIER2-GATE-V6-01 — single run, first-failure stop at T3.teardown_ran (no retry, no weakening)

Invocation (exact, once, synchronous guarded wait with `set +e`, outer rc captured): `cd /home/user/workspace/execution/s5-r4 && mkdir -p control-results && S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20 400 bash controls-v6-gate/ctl-teardown-gate.sh` — start 06:06:47Z, end 06:06:52Z, outer_exit=1 (driver STOP_ON_FIRST_FAILURE), aggregate 5 s. v6 manifest re-verified from `controls-v6-gate/` before start (0 mismatches, driver b7207f46…). Gates: HEAD 143d451e, dirty fingerprint 6850b32e… (T2-2), `.bin/jest`, DEPENDENCY_IDENTITIES rc=0 (jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, jest-circus inside worktree), fake harness 2de5fe24…, config a6eeb1cd…, candidate spec copy sha 01f3cfc0… == worktree file (I0 PASS). Control root retained `/tmp/s5-r4-gate-UuL96M` (test/ and jest.config.js copied here). Canonical lock never opened (flock -n probe free afterwards). Source fingerprint unchanged after the run.

## Results: 12 PASS, 1 FAIL, T0 NOT RUN
- T1 refused-identity (pid 8573, 3 s, jest rc 1, `.owned` PASS): 2 recorded calls, 0 mutating; `PG17_TEARDOWN_SKIPPED {"reason":"setup refused before first mutation; no DDL/DML issued"}` emitted; named reason PASS — Jest log shows `expect(received).toMatchObject(expected)` at spec line 46 with `+ "database": "not_the_disposable_db"`, no `Exceeded timeout`.
- T2 refused-prestate (pid 8634, 1 s, jest rc 1, `.owned` PASS): 6 recorded calls, 0 mutating, `_prisma_migrations` reached; skipped marker emitted; named reason PASS — `Expected: "164"` / `Received: "165"`, no identity failure, no timeout.
- T3 authorized-partial (pid 8688, 1 s, jest rc 1, `.owned` PASS): `T3.setup_partial` PASS (GRANT recorded mutating, then `ALTER TABLE "Person" ADD CONSTRAINT g2p_target_refusal …` with the fake throwing "fake: ALTER TABLE failed after authorized GRANT (partial setup)"). **`T3.teardown_ran` FAIL.**

## First failure — raw evidence (gate-20260922T060647Z-T3.jsonl, 16 lines)
Lines 14–16, all after the failed ALTER: `{"fn":"sql","mutating":true,"stmt":"ALTER TABLE \"Person\" DROP CONSTRAINT IF EXISTS g2p_target_refusal; ALTER TABLE \"ScoutReconstructedEntity\" DROP CONSTRAIN…"}`, `{"fn":"resetData","mutating":true,…}`, `{"fn":"sql","mutating":true,"stmt":"DELETE FROM \"ScoutImport\""}`. No `PG17_TEARDOWN_SKIPPED` in the T3 Jest log. The teardown DID run after the partial authorized setup — the property the check asserts holds in the record.

Classification: CONTROL-CHECK pattern defect (JSON escaping), not a spec/harness/Jest finding. The check greps the literal `DELETE FROM "ScoutImport"` but the JSONL record stores the statement JSON-escaped as `DELETE FROM \"ScoutImport\"`; pattern tests on the raw file: DROP CONSTRAINT 1 hit, `"fn":"resetData"` 1 hit, unescaped DELETE pattern 0 hits, escaped pattern 1 hit. The same escaping affects no other check (T1/T2/T0 patterns contain no double quotes inside statements). Minimal v7 repair (NOT written, NOT run): match `DELETE FROM \\"ScoutImport\\"` (or `"fn":"sql","phase":"setup","mutating":true,"stmt":"DELETE FROM \\"ScoutImport\\""`). No harness/spec change.

## Owned-process census
Jest pids 8573/8634/8688 gone; every `.owned` check passed with empty groups; no jest/driver processes after; `survivors=0`. Real PG, hooks, commit, network, install, npx, Prisma untouched.

## Not proven
T3.no_skip and T0 (predecessor defect under real hooks) not evaluated in this run. Positive T1/T2 prove real jest-circus hook behaviour under the FAKE harness only — not DB behaviour, live 51, native hooks or the final commit.
