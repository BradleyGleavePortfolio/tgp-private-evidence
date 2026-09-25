# Binding v2 -> v3 exact delta (source-only; nothing run)

v2: `../v2/s7l-pg-proof.sh` 0287a941655b0ff9ec19a306af943fd93c357c00b6187f6ad31dfc90c1de2705, `../v2/s7l-fixture.sh` dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2, frozen 04:59:28Z against 54970cd9; RUN ONCE 05:06:22Z–05:14:22Z, FAILED (`../v2/run/`: 21 failed / 3 passed / 24, rc 124 stage jest after the parent's narrow TERM; receipts, sentinel, `PROOF_RUN_RECEIPT.md` unchanged).
v3: `s7l-pg-proof.sh`, `s7l-fixture.sh` (see BINDING.sha256), frozen against a68cdac7 (parent 54970cd9).

Fixture changes (full diff `fixture-v2-to-v3.diff`, 3 changed lines): `LANE=$RUNTIME_ROOT/clusters/s7l` -> `$RUNTIME_ROOT/proof-v3/clusters/s7l`; `SOCK=$RUNTIME_ROOT/run/s7l` -> `$RUNTIME_ROOT/proof-v3/run/s7l` (same line as DATA/LOG, which derive from LANE); the one comment line that names those directories. Guard regex, port, identities, marker, init/start/stop/destroy logic, runner-PID gate: unchanged.

Driver changes (full diff `driver-v2-to-v3.diff`):
1. Header comment: v3 purpose, lineage, fresh lane.
2. `D=…/binding/v2` -> `D=…/binding/v3` (run receipts under `binding/v3/run`); usage line path.
3. Pins: `EXPECT_PARENT` 839b54c5 -> 54970cd9; `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_SPEC_BLOB` re-filled by freeze-v3.sh (a68cdac7 / 6c00e248 / 94e7fac4); `EXPECT_FIXTURE_SHA` re-filled for the v3 fixture. All other proof-object, schema/migration and tool pins unchanged.
4. Fresh runtime paths: `LANE=$RUNTIME_ROOT/proof-v3/clusters/s7l`, `SOCK=$RUNTIME_ROOT/proof-v3/run/s7l`, `OLDROOT=$RUNTIME_ROOT/proof-v3/s7l/old-root` (`OLDCLIENT` derived); `CLUSTERS=$RUNTIME_ROOT/clusters` kept for other-lane checks.
5. Lineage checks: `HEAD^ == EXPECT_PARENT` (54970cd9) with tree 513c71d7; `EXPECT_PARENT^ == 839b54c5` with tree f02205c6; `EXPECT_PARENT^^ == BASE_HEAD`; base-ancestor check retained; delta `EXPECT_PARENT..HEAD` must be exactly `test/rls-g2-s7l.spec.ts`. Placeholder/not-frozen refusal messages say v3.
6. Both other-lane loops (preflight and post): exclusion `basename == s7l` -> `"${d%/}" != "$LANE"` (own lane by actual path), so the retained failed v2 `clusters/s7l` is included as another stopped lane whose postmaster.pid must be absent and whose postgresql.conf / pg_control hashes must be unchanged.
No change to lock handling (canonical `flock -n` fd 9, inode check), fixture calls, bootstrap, identity checks, the single jest invocation, stop/post logic, bounds, sentinel semantics or exit codes. Known and unchanged: `finish()` hashes the log before appending the END line (record-only C finding).

freeze-v3.sh vs ../v2/freeze-v2.sh (`freeze-v2-to-v3.diff`): PARENT 54970cd9 with v2-tree, v1 and base lineage refusals; one-path delta; fixture delta must equal the recorded `fixture-v2-to-v3.diff` and be exactly 3 lines; v1 AND v2 `BINDING.sha256 -c`; v2 run `jest.log` hash d6253d28… unchanged; hashes the two diffs and this file into BINDING.sha256.
