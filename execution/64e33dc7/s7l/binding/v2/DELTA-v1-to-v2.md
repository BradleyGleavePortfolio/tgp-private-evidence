# Binding v1 -> v2 exact delta (source-only; nothing run)

v1: `../s7l-pg-proof.sh` 3e97da2e51fdb7eab32cb828620e639d92c4ed9f6e527eadd2c4a8ae62cef307, `../s7l-fixture.sh` dc77a7c9…3dd2, frozen 04:39:00Z against 839b54c5 (`../BINDING.sha256`, unchanged).
v2: `s7l-pg-proof.sh` (see BINDING.sha256), `s7l-fixture.sh` byte-identical to v1 (cmp; same sha dc77a7c9…3dd2), frozen against 54970cd9.

Driver changes (full unified diff: `driver-v1-to-v2.diff`, 44 lines):
1. Header comment: v2 purpose and lineage.
2. `D=…/s7l/binding` -> `D=…/s7l/binding/v2` (run receipts therefore under `binding/v2/run`); usage line path.
3. Pins: `EXPECT_PARENT=839b54c5…` added; `EXPECT_HEAD` 839b54c5→54970cd9; `EXPECT_TREE` f02205c6→513c71d7; `EXPECT_SPEC_BLOB` 840b3fdc→052fa35d (changed L06 spec). Fixture pin re-filled with the identical value. All other proof-object and tool pins unchanged.
4. Placeholder refusal now covers head/tree/spec-blob as well as fixture; `EXPECT_HEAD` must differ from both base and v1 parent.
5. Exact-parent check: `HEAD^ == EXPECT_PARENT` (replaces v1's `HEAD^ == BASE_HEAD`), plus `EXPECT_PARENT^ == BASE_HEAD`, `EXPECT_PARENT^{tree} == f02205c6`, base-ancestor check retained, and `git diff --name-only EXPECT_PARENT HEAD` must be exactly the three granted correction paths.
No change to lock handling, fixture calls, bootstrap, identity checks, jest invocation, stop/post logic, bounds or exit codes.

freeze-v2.sh vs ../freeze.sh: adds PARENT lineage refusals, fixture byte-identity check, v1 `BINDING.sha256 -c` check, fills the three `__FILL_AFTER_FOLLOWUP_COMMIT__` pins from the committed head, compares EXPECT_PARENT, hashes `freeze-v2.sh`/`DELTA-v1-to-v2.md`.
Freeze history: first pass 04:58:26Z (pins filled, all HEAD_PIN_OK/TOOL_PIN_OK, docs not yet v2 — retained as `BINDING.sha256.first-pass-04-58-26Z`); final pass after PINS/README/DELTA finalised (see `BINDING.sha256`).
