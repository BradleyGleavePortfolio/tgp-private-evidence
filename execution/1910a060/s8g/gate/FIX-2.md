# Gate attempt 2 — STOPPED at jest-targeted (rc 73); FIX-2 prepared, attempt 3 NOT launched (awaiting disposition)

## Attempt 2 result (`attempt-2/`, driver sha256 `b60b11b2…`, launched 22:05:29Z, lock inode 667698 acquired immediately — the S9-A holder had already released — held 22:05:29Z→22:06:33Z, released, no holder now)

| Stage | Result |
|---|---|
| preconditions | OK on the FIX-1 tree (`attempt-2/PREFORMAT.sha256`); attempt-1 `node_modules` and hooks reused after pin verification (hidden lock `05bc530a…`, client `9042e713…`, normalized hooks `9dcf80f4…`/`4ab9b419…`, own-path reference) |
| prettier | check-1 rc 0 (already formatted; no writes) |
| eslint (13 files, `--max-warnings 0`) | rc 0 |
| **tsc --noEmit whole repo** | **rc 0** (FIX-1 closed the only diagnostic) |
| **jest targeted** | rc 1: `settle-hook.spec` PASS, `g2-s8g-db-guard.spec` PASS, `family-plan.spec` PASS (73 tests passed); **`reconstruct-run.spec.ts` failed to RUN** — module-load error `invalid source mapping spec (reconstruct-run.spec:fixture): missing key families.programs.clientSourceId` from the accepted parser (`mapping-spec.ts` `parseRules` → `assertExactKeys`: entity families require exactly `clientSourceId` + `label`). Stopped per policy. |
| jest full / commit | not reached |

Product sources: compiled clean and untouched. The defect is fixture data in one unit spec: its inline source spec declared only `label` for `programs`/`workouts`/`client_history`. The other two fixtures (`family-plan.spec.ts`, `test/utils/g2-s8g-harness.ts` SPEC used by the worker) already declare both rules and parsed fine.

## FIX-2 (applied outside the run; fixture-only; `FIX-2.diff`)
`test/scout/orchestration/reconstruct-run.spec.ts` L178–L192: add `clientSourceId: { paths: [['client_id']], coerce: 'string_or_finite_number' }` to `programs`, `workouts`, `client_history` (the same rule text as the harness SPEC; `string_or_finite_number` is one of the two accepted `FIELD_COERCIONS`). No assertion changed; the spec's stub families never consult the mapper output, so test semantics are unchanged — the fixture now simply satisfies the accepted schema. No banned tokens. New identity: sha256 `e333bc513a638a293b907384199322b8289ef96b24b70a502b0004def7beb355`, blob `497798e1daaa5027c4435dd5b5bc3022b16f6328` (attempt-2 was `a0a6c18e…`/`bed85dec…`). Other 13 files unchanged (`attempt-2/POSTFAIL-tree.txt`).

## Attempt 3 (prepared, NOT launched)
`attempt-3/s8g-gate-1910-a3.sh` sha256 `58868f9c311369d67d1282dfe028fec2ebac81053b4279f2b7114593e1457a8d` — identical to attempt 2 except `S8G_GATE_RELAY=3`, evidence dir `attempt-3/`, receipts prefix `s8g-a3-`; pins the FIX-2 tree via `attempt-3/PREFORMAT.sha256` + `freeze/`; reuses the pinned `node_modules`/hooks; polls the lock (never steals). Launch on disposition:
`S8G_GATE_RELAY=3 S8G_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules S8G_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s8g/gate/attempt-3/s8g-gate-1910-a3.sh`

Residual risk (unverifiable without the slot): `reconstruct-run.spec.ts` has never executed past module load; its ~15 cases exercise the new engine against a FakePrisma and could surface a further assertion mismatch, which would stop attempt 3 at the same stage for disposition.

Attempt-1 and attempt-2 evidence preserved unchanged (`gate/` root and `gate/attempt-2/`).
