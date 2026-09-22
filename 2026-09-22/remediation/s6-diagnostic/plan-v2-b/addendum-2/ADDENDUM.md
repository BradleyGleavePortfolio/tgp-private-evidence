# S6-V3-NARROW-CLOSURE-B — addendum 2: applicability review of V3 setup `91fe0f1b` and diagnostic runner `1664fd47`

Reviewer B (`s4_r6_independent_audit_b_muc70jfl`); observable identity: API-hosted AI subagent, model/settings not exposed. Read-only; no execution, install, tests, code or peer S4/V2 access. Prior outputs in this directory are unchanged (root and addendum-1 `SHA256SUMS` re-verified OK). This is a source review, not acceptance; setup and diagnostic each still need a separate parent grant.

## Exact inputs (all re-hashed here)
| Input | SHA256 |
|---|---|
| `v3/run-c5-setup-npm-ci.v3.sh` | `91fe0f1b1db951a3d41b34afba528bb2e3815ba89f0154b917aeb01d9b197bd1` |
| `v3/run-c5-resource-inventory.v3.sh` | `1664fd4776d95c83353bba869def899660099d6be811f311c75e0c352c35f69f` |
| `v3/diag/s6diag.main.js` (unchanged positive instrument) | `cf4701010365cb87326c17c901c4f6c941b84ea5d3dceb3f4c5e38c21e51c1d0` |
| `v3/diag/s6diag.selftest.js` | `425ddec601bd5c1d53fa23833ad433afafec648c827ef2ed15659871c8276a28` |
| `v3/MANIFEST.v3.sha256` (expanded execution checkpoint, 11 entries, verifies 11/11) | `50f65b9d7878e2aa52344fa6dc392a3fda94a80c30d84a8d2db5e78e6c05d7e0` |
| `v3/MANIFEST.v3.instrument-only.sha256` (original 2-entry index, verifies 2/2) | `21bb27fed58079ad096c07643ea08b433cb8fd4ff2a3ec4152df06dd91091068` |
| `v3/MANIFEST_CHRONOLOGY.md` | `42e26018f1562410133f024ca4f28f8ccc87b725b7b937fd01d64e1ab2e9c05c` |
| `v3/C5_V3_SUCCESSOR.md`, `EXECUTION_REPAIR_WAVE_2.md` §S6-V3-NARROW-CLOSURE-B | read in full |
Worktree facts re-read: HEAD `d51a1910…dc06`, `.gitignore` has `node_modules/` and `.expo/`; the 20-name module list is present as top-level lockfile entries (checked in my root review); `bash -n` passes for both scripts.

Manifest qualification: the name `MANIFEST.v3.sha256` was overwritten in place (2 entries → 11); the original index is preserved only as the separately named copy `21bb27fe`. The V3 selfcheck receipt (`logs/selftest-v3/prehash.txt`) pins the two instrument files by content, not the manifest, so the positive receipt for `cf470101`/`425ddec6` remains reusable. I do not assert the old manifest file stayed byte-identical.

## 1. Closure verification on actual bytes

| Finding | Setup `91fe0f1b` | Diagnostic `1664fd47` |
|---|---|---|
| **A-1** reap result never gated | **CLOSED.** L96 `CE=$?` → `CLEANUP_FAILURES++`; L114 `finish 0` → `final_accounting` → `FINAL rc=90` and `exit 90` when any cleanup failure; primary `npm-ci rc=0 how=exited` preserved in `FIRST_EXIT` (L97, written L113 before FINAL). Nonzero primary keeps its rc (`die` → `finish "$2"`). | **CLOSED for the final verdict** (per-step `ce` → `CLEANUP_FAILURES++` L145; `finish` L100–104). See M-1 for progression. |
| **A-2** ancestor CHANGED only reported | **CLOSED.** L46–48: equality is evaluated inside `final_accounting`, which `finish` calls *before* deciding FINAL; CHANGED → `CLEANUP_FAILURES++` → FINAL 90/exit 90. L113 no longer asserts "ancestor unchanged". | **CLOSED** (same construct, L87–90). |
| **A-3** KILL path / cleanup visibility | Disclosure closed: FINAL line carries `CLEANUP_FAILURES=`; `final_accounting` idempotent (`ACCOUNTED`), so no duplicate accounting. | Same. |
| **B-01** instrument binding | n/a | **CLOSED.** `V3=$EX/v3`, `DIAG=$V3/diag`, manifest check `MANIFEST.v3.sha256` (L182). Step 0 re-runs the positive selftest (informational). |
| **B-02** `@babel/preset-env` | Setup list unchanged (20). | **CLOSED.** Runner list = setup list, byte-identical 20 names; `require.resolve` in try/catch → `BAD <m> unresolved: <code>` → rc 1 → `die module-paths 5`. |
| **B-03** copies never removed | n/a | **CLOSED, with one gap (M-2).** `COPIES_PLACED=1` is set at L197 *before* the `cp` lines, so `cleanup_copies` also runs on the fingerprint `die` paths; removal is hash-guarded (equal to frozen source → `rm -f`; differ → `RETAINED` + `CLEANUP_FAILURES++`). Porcelain after cleanup is logged. |
| **B-04** lock fd inherited | **CLOSED.** L86 `9>&-` on the npm child. | **CLOSED.** L124 `9>&-` on every owned child. |
| **B-05** lifecycle scripts / `$HOME/.npm` / network | Disclosed unchanged; `--ignore-scripts` is a parent policy choice (one token, new hash). Not a blocker from me. | n/a |
| **B-06** C rc 143 vs 137 | n/a | **CLOSED** in wording (L228–229, L241): both `budget-TERM` and `budget-KILL` are the preserved hang. |
| **B-07** root vs evicted chain label | n/a | Left as documented limitation; instrument hash unchanged by design. Acceptable. |

## 2. Parent questions: declared-copy `rm` failure; progression after cleanup failure

**M-2 (nonmaterial gap, smallest closure 1 clause) — `rm -f` failure is silent and uncounted.** `cleanup_copies`: `rm -f "$dst" && echo "… removed"` has no failure branch; if `rm` fails (unwritable directory) nothing is logged and `CLEANUP_FAILURES` is not incremented, so the run can still end `FINAL rc=0`-equivalent with a copy left in the worktree. The porcelain line after cleanup would show it but is not gated. Closure: `rm -f "$dst" && echo removed || { echo "$(ts) copy $f rm FAILED — retained"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }` **and** gate the porcelain count: `[ "$(git status --porcelain | wc -l)" = 0 ] || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1))`. The second clause also catches any unexpected worktree write by Jest. (Likelihood low: `rm -f` on a user-owned file returns 0 unless the directory is unwritable or the path vanished — the latter returns 0.)

**Cannot imply success:** with either gap closed, no path yields FINAL 0 / "positive" while a copy is retained or a group unresolved. Already today, a retained-by-hash-mismatch copy, a survivor, an ancestor change or a nonzero per-step cleanup all force `CLEANUP_FAILURES>0` → FINAL 90 (primary 0) or primary rc with the `CLEANUP_FAILURES=N` text in the FINAL line and the `CLEANUP_FAILURES=` accounting line.

**D-1 (disclosure, not a code blocker) — for the diagnostic the exit code cannot encode cleanup failure.** C's expected primary is 143/137, and `finish` keeps a nonzero primary; a run with survivors therefore exits 143 exactly like a clean expected run. `C5_V3_SUCCESSOR.md`'s positive criteria already require `CLEANUP_FAILURES=0`, `all five copies removed`, `porcelain 0` from the record; the parent's acceptance must key on those record lines, never on rc alone.

**M-1 (material for the diagnostic's trust contract; smallest closure 1 line) — progression continues after a per-step cleanup failure.** `run_owned` L145 counts a nonzero `cleanup_exit` (owned group still has members after TERM → 10 s → KILL → 1 s, i.e. an unexplained survivor) but returns normally; the run proceeds to launch the next owned Jest process (A→B→D→C, up to three more) while a quarantined group is unresolved. This contradicts "stop at first unexplained failure; quarantine: report, do not retry" (the runner's own SURVIVORS text). The lock is no longer inherited (B-04 closed) so the canonical lock is safe, but the causal observation would proceed with a foreign survivor pinned to the same `taskset -c 0,1` CPUs and sharing the Jest cache — an unexplained confounder, and the sequence semantics (A negative control must be *clean* before B/D/C) are violated. Closure, inside `run_owned` after L145:
`[ "$ce" -eq 0 ] || { [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$step rc=$RUN_RC how=$RUN_HOW"; die "$step-cleanup-survivors" 90 "cleanup_exit=$ce; quarantined owned group unresolved — stop, do not start next step"; }`.
This preserves the step's real first exit in `FIRST_EXIT`, reuses the existing rc 90 fail-closed code, and stops before any further child is spawned. Setup has no analogous issue: after its single child, only read-only after-checks run before `finish`.

## 3. Other observations (no action required)
- Missing-FINAL case: an abnormal bash exit (e.g. `set -u` unbound variable) runs `final_accounting` via the EXIT trap but writes no `FINAL` line and cannot change the status. Parent rule should be: no `FINAL rc=` line ⇒ not success. Both scripts.
- `CLEANUP_FAILURES` can double-count one event (per-step `ce` and the later survivor scan); harmless, it is a count not a code.
- Setup L104 clean-tree gate is safe against `node_modules/` (gitignored); `npm ci` never rewrites the lockfile.
- Trap latency ≤ poll sleep; `on_signal` → `reap_group 20` + `finish` fits inside the external `-k 30` window.

## 4. Grantability (distinct)
- **Setup `91fe0f1b`: grantable as frozen** once S2 has released `test-validation.lock` (otherwise rc 75 fail-closed). All A-1/A-2/B-04 closures verified on bytes; B-05 remains a disclosed policy choice. Positive record = `FIRST_EXIT npm-ci rc=0 how=exited`, `cleanup_exit=0`, `UNCHANGED`, `CLEANUP_FAILURES=0`, `FINAL rc=0`, 20× `OK …/worktrees/s6-diagnostic/node_modules/…`, porcelain 0.
- **Diagnostic `1664fd47`: hold for one revision** — M-1 (1 line) and M-2 (1–2 clauses), new hash and manifest entry; then grantable after a positive setup. Nothing else remains from my root report or addendum 1.
- **What a positive run would not prove:** Jest causal closure of P1, product vs harness ownership (that is the run's *question*, answered only by the C inventory), clean baseline, release readiness.
