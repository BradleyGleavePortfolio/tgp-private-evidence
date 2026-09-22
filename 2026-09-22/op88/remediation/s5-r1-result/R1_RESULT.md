# OP88-S5-R1 result — read-only T3 checker executed exactly once (granted by `execution/op88/S5_R1_GRANT.md`)

Executor `s5_selective_v7_fixer_mud58q6n`. Pre-run: V7 manifest `dd7f2eab…9eab` verified 15/15. Caller: the exact granted block, run from a non-job-control tool shell that retained the enclosing exit (tool exit_code 0 = `exit "$rc"`). Start `2026-09-22T21:06:42Z`, end `2026-09-22T21:06:42Z`; wrapper `aggregate_elapsed=0s` (five node invocations, sub-second each); outer allowance 140 s + 10 s kill grace + 15 s receipt reserve was never approached. **RAW_OUTER_EXIT=0** (`op88-r1-outer.exit`).

## Observed (wrapper log `t3-checker-20260922T210642Z.log` = `op88-r1-outer.log`, identical content)
- Gates: wrapper `20e49443…bdaa`, checker `ae5842aa…5d88`, node v20.20.1, JSONL `ae38014a…7909` (2621 bytes), Jest log `d6c3c1d7…ef10` (69561 bytes), fixtures all hash-matched; canonical lock path `absent (not opened, not probed)`.
- **P0 rc 0, `SUMMARY pass=6 fail=0`**: `T3.record_parse` (16 records), `T3.setup_partial` (GRANT line 11; ADD CONSTRAINT line 13 mutating=true), `T3.teardown_ran` (drop line 14, resetData line 15, delete line 16, decoded), `T3.teardown_after_failed_alter` (13 < 14 < 15 < 16), `T3.log_bound` (all four binders true), `T3.no_skip` (0 markers). Observations: `v6_L80.unescaped_literal_in_raw false`, `escaped_literal_in_raw true`.
- **N1 rc 1** `FAIL T3.teardown_ran teardown.drop=MISSING …`; **N2 rc 1** `… teardown.resetData=MISSING …`; **N3 rc 1** `… teardown.delete=MISSING …` (each also `FAIL T3.teardown_after_failed_alter not evaluable`, pass=4 fail=2); **N4 rc 1** `FAIL T3.no_skip PG17_TEARDOWN_SKIPPED occurrences=1` (pass=5 fail=1).
- Wrapper `SUMMARY pass=11 fail=0`, rc 0. No first failure occurred; nothing retried.
- Process census after return: `pgrep -fa 'check-t3-teardown.cjs|run-t3-checker.sh'` → none (observation only, no kill). Pre-run count of 3/3 was the tool shell's own command line containing those strings, not checker processes.
- Post-run identity: V7 manifest still 15/15, `dd7f2eab…`; private evidence porcelain 0; archive inputs unchanged (re-hashed by the wrapper at start).

## Meaning
Closes only the read-only interpretation of the preserved T3 evidence: under real jest-circus in wave 6, the candidate's teardown ran after the partial authorized setup and no skipped marker was emitted — the property v6 L80 failed to read because of JSON escaping. Wave 6 remains FAIL (its 12 PASS total includes I0 and partial T3 as well as T1/T2). Not closed: T0 predecessor behaviour (R2 HELD for A02/A03 correction and fresh isolated setup), DB behaviour, live run, hooks, commit, attestations. No downstream permission implied.
