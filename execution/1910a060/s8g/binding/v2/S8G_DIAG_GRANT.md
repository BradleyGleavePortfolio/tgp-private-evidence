# S8G-DIAG-1 — fresh diagnostic run of exact candidate 820ce85b (parent grant, session d3a9f701, 2026-09-26T00:43:30Z)
Why: the predecessor 5/19 proof receipt (binding/v1/run/*) is absent from all durable evidence (one bounded recovery attempt,
owner s8_g_fresh_diagnosis_owner_muhnbqcc). Per owner correction 17:29 PT this is a NEW diagnostic, not a reconstruction and not
an automatic rerun of the consumed v1 grant. Result is preserved as-is whatever it is.
Candidate: 820ce85be2ebf994112afbb90739eb9469ad628e tree 7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a (bundle s8g-820ce85be2eb.bundle), standalone clone worktrees/1910a060-s8g, clean.
Binding v2 = v1 runner with exactly two value deltas (DELTA-v1-v2.diff): D path v1->v2, EXPECT_LOCK_INODE 667698->692282
(this sandbox's canonical lock, d3a9f701/runtime/LOCK_ESTABLISHED.txt). Fixture/PINS copied byte-identical.
Runtime: d3a9f701/runtime receipts (pg17 dist 1005-file manifest identical to 1910a060; psql d1108fdb; donor hidden lock/client pins equal).
Executor: parent. Exactly one run: timeout -k 30 3600 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s8g/binding/v2/s8g-pg-proof.sh. Port 55644. Datadir retained. Synthetic local data only.
Acceptance use: if 19/19 the result is acceptance-capable evidence subject to dual review of this binding delta; otherwise it is the diagnosis input.

## Attempt 0 (00:43:30Z) — precondition refusal, not a consumed proof
rc 70 at stage=preconditions: W/.git/hooks lacked the lefthook pre-commit/commit-msg (fresh standalone clone; the donor gets them from
npm prepare). No server, no initdb, no jest. Preserved at run-attempt0-precondition-refusal/. Class B (environment precondition).
Minimum fix: copy the donor's lefthook hooks (pre-commit e21bece6…, commit-msg 277018c4…, byte-equal to RUNTIME_SETUP_RECEIPT §4) into W/.git/hooks.
Runner/fixture bytes unchanged. Attempt 1 is the single diagnostic run of this grant.
