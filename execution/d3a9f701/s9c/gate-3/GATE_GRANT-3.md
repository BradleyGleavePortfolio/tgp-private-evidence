# S9-C GATE GRANT 3 — parent d3a9f701, 2026-09-26T03:52:51Z
- Gate-2 rc=0 → 98133050 (preserved as refs/heads/exec-d3a9/s9c-r2-gate2; receipt gate/HEAD-98133050bb62.txt). S9C-PROOF-2 on it: 9/10, consumed/preserved; R11 test expectation contradicted D-S9-2 Required families (class B; fix-r11/CLASSIFICATION.md).
- Fix: test/rls-g2-s9c.spec.ts only (+16/-2, fix-r11/r11-fix.diff), sha256 b5558da4…707c; dev check prettier/eslint/tsc/R75-staged all 0. Reviews: A GO, B GO ("R11 fix + binding v3 rule").
- gate-3 PINS.env = gate/PINS.env with only that pin changed; driver = gate driver with only E=…/gate-3 changed.
- r2 reset --mixed to 5407efae (working tree = gate-2 bytes + fix), node_modules removed for the driver's fresh donor copy.
- New one-shot gate on changed test bytes; not a rerun of a consumed proof. Single run; on failure preserve, classify, no auto-rerun.
- 2026-09-26T03:54:49Z attempt-0a refused rc=78 before ACQUIRED (commit-message.txt absent; copied from gate/). attempt-0b ACQUIRED then PRECONDITION_FAIL .git/hooks/pre-commit already present (gate-2's lefthook install) at stage=preflight rc=70: no commit, no tests, no PG. Preserved at run-0-preflight-rc70/ (hooks set aside there). Relaunch 1 under this same grant; zero work had been done.
