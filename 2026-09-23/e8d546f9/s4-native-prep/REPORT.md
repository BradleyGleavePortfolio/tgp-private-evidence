# S4-NATIVE-PREP — native caller V2 restored and transport prepared; NOT ACTIVATED (revision 1, frozen)

Executor: `restore_upstream_proof_inputs_muddwjad`, T4 executor (non-builder, not audit; requested Claude Fable 5; runtime identity not observable). Executed 2026-09-23T01:44:57Z–01:47:02Z. **Prep only: nothing launched.** No install, census, lock probe, version command, network, product/native/worktree change; Stage 1 NOT rerun. Activation waits for the parent's explicit message referencing the published grant.

## 1. Inputs verified — `logs/N1-verify.txt`

| Input | Result |
|---|---|
| V2 packet `execution/e8d546f9/s4-native-caller-v2/` | 7/7 OK; manifest **`7bff8f2c9fd7c15ac6ebab18524e6cf2b122fa38506e98864f23b15ccea3f8bf`**; `FREEZE.json` `2ae4a8ee…`; caller script **`ba73a99b2602e5640a6339b3e1ec0e79e02272e00914fc5a60faf22f5630a1c1`** (160 lines; A01 discriminator: lines 144–153 all end ` &&`, line 154 does not); invocation **`ef45fd8d8cc6276de070a9cd0a1674e34174360863327db09c564345d52bae84`** = `bash /home/user/workspace/execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh` |
| Review A `audits/s4-native-caller-v2-a` | SHA256SUMS OK, sha256 **`1b2634a0dd91ad78c46f844fc66bbca5725a270103eb6ca30882b06ad512c4fb`**; verdict `S4-NATIVE-V1-A01: SOURCE_CLOSED_UNEXECUTED`, native caller `GRANTABLE_AFTER_INDEPENDENT_V2_B_CLOSURE_AND_RUNTIME_PRECONDITIONS_UNDER_SEPARATE_PARENT_NATIVE_GRANT`, material defects `[]`; binds packet 7bff8f2c |
| Review B `audits/s4-native-caller-v2-b` | SHA256SUMS OK, sha256 **`8bece05bf3aaeecf5a450635895b6f8d75d8cdf9eeed4e99ff9faaa88fef3ca9`**; verdict: delta closes A01 at source, limited to lines 2/17/143–153, no material introduced defect; binds packet 7bff8f2c |
| Staged V6.1 `execution/s4-r6-validation/v6` | 12/12 OK; `SHA256SUMS` **`671d08c3633378ef392a4aee6bbb70b78319994727d74e439b75830a6d63d8ee`**; launcher `85e1bafd…` |
| Stage 1 result (not rerun) | `s4-stage1-result/SHA256SUMS.stage1` `9c84eab2…`, `stage1.exit` 0, `driver exit=0` |
| Transport source | `s4-control-prep/TRANSPORT.md` `2f9c6f69…`; `stage1-caller.cmd` `680a0161…` |
| Ruling / request | `S4_V6_RECOVERY_RULING.md` `f05993ec…` (read in full); `SLOT_REQUEST_V61.md` `15a1d6df…` §5 (item 5.1 native caller prerequisite) / §6 read; `NATIVE_CALLER_REQUEST_V2.md` read in full |
| Native source-restoration evidence | `s4-native-restore` MANIFEST OK `6aca52bd…`; `s4-native-unshallow` MANIFEST OK `718b9757…`; `worktrees/s4-r6` HEAD `91990ae9aec72f47a67591892ac09fa1f59d2f16`, tree `840fb285…`, porcelain 0, unshallow, `node_modules` **absent** (runner L91 requires absent; the fresh `npm ci` is the runner's own step under grant); `execution/s4-r6/predecessor-88287cff` 158 files, `probes` 8 files |
| S2 slot STOP `d749a4b1` | parent statement; 0 file hits in `execution/` and private `execution/` — recorded as unverified here; by file there is no S4 runtime (`runs/`, `caller-receipts/` absent) |

## 2. Restored — `logs/N2-restore-caller.txt`

`execution/s4-r6-validation/native-caller-v2/` created (was absent) with exactly one file `s4-r6-native-caller-v2.sh`, sha256 **`ba73a99b…`**, byte-identical to the packet, mode 0444, dir 0755. The invocation path in the `.cmd` now resolves. Not created: `s4-r6-validation/runs`, `caller-receipts`, `execution/e8d546f9/s4-native-result` (caller/launcher/transport own them at launch). Frozen `v6` untouched (671d08c3 re-verified).

## 3. Transport prepared — `NATIVE_TRANSPORT.md`, `native-caller-v2.cmd`, `logs/N3-transport-checks.txt`

- `native-caller-v2.cmd` (this dir) = byte copy, sha256 **`ef45fd8d…`**.
- `NATIVE_TRANSPORT.md` = Stage 1 `TRANSPORT.md` T1/T2/T3 with only path/name substitutions (`s4-stage1-result`→`s4-native-result`, `stage1.*`→`native.*`, caller file → `native-caller-v2.cmd`) and guard 4 extended to check both accepted caller files (`.cmd` ef45fd8d **and** restored script ba73a99b; refusal-only). After normalising names: T1 residual delta = those guard lines only (4 lines), T2 residual delta = 0; wrapper `setsid -f` line byte-identical modulo names. `bash -n` OK on all three blocks (block sha256 T1 `960bc792…`, T2 `ef550e6e…`, T3 `74a22dff…`). Scans: 0 `kill -KILL/-9`, 0 `timeout`, 0 `--kill-after`, 0 `flock`, 0 `kill -TERM` in T1–T3 (T2 has the same single `kill -0` liveness read as Stage 1). No new semantics.
- Three distinct artefacts defined and collected separately by T3: **[1]** `native.exit` (transport observer exit = caller `OBSERVER_RETURN`), **[2]** `caller-receipts/NATIVE-CALLER-*.txt` (complete all-or-nothing receipt with `ACTUAL_LAUNCHER_EXIT=`), **[3]** `runs/VALIDATION-V6-*/SUPERVISOR_RECORD.json`. Success requires [1]=0 AND [2] complete with actual 0/observer 0 AND [3] consistent; never 97 / would-be 12 / partial `.tmp` / UNKNOWN census.
- Cancellation only on parent order: one `kill -TERM <caller pid>` (from the `caller_pid=` note); never KILL; never the wrapper; recovery per ruling §Recovery (identity triple + EMPTY census, else escalate).

## 4. Defaults and fresh context recorded (file/env facts only)

`S4R6_OUTER_S`, `S4R6_GRACE_S`, `S4R6_CALLER_RECEIPTS`, `S4R6_LEASE_PID` all **unset** (0 `S4R6_*` in env) → caller `OBSERVE_S` 3422 s, cancel wait 127 s, receipts at `execution/s4-r6-validation/caller-receipts`; nominal allowance ≥ 3569 s post-spawn / 3589 s incl. manifest (request §4.1), no KILL deadline. Fresh run context: `runs/`, `caller-receipts/`, `s4-native-result/` absent; canonical lock file exists (not opened). Tool paths present: `setsid pgrep ps timeout python3 sha256sum bash` (versions not queried); user `user`.

## 4a. Grant readback (QUEUED; not activation) — `logs/N4-grant-readback.txt`

`tgp-private-evidence/execution/e8d546f9/S4_NATIVE_V2_GRANT.md` sha256 **`20d42065e10991dc222243cddfd8c2e5be7adc51446c7e68032826fcf24a8e25`**, tracked at private HEAD `7f09413`, read in full. Every hash it names matches the bytes at the launch paths (caller ba73a99b, cmd ef45fd8d, V6.1 671d08c3, V2 packet 7bff8f2c, Stage 1 9c84eab2, reviews 1b2634a0 / 8bece05b). `SLOT_REQUEST_V6.md` (`c0fe3556…`) §5 (original launcher-direct caller line and 3422 s bound; exit map) and §6 (identity-checked recovery) read; the V2 caller replaces only that caller line, launcher `85e1bafd…` unchanged. Grant-specific preconditions by file/env: `worktrees/s4-r6` HEAD 91990ae9, tree 840fb285, parent **88287cff47240aa58b5f0fea5da08670f1e87df6**, base 0111be66 ancestor, non-shallow, porcelain 0, lockfile **`262d4b69…dae8`**, `node_modules`/`dist` absent, hooks 0; **EUID 2000** (`user`), **`TGP_CHROME` unset, 0 `S4R6_*`** in the environment (no inherited overrides to refuse); pinned default Chrome path exists (existence only); tool shell job control off, transport `setsid -f`, caller `set +m`. Fresh native context: `runs/`, `tooling/`, `caller-receipts/`, `s4-native-result/` all absent; canonical lock file exists empty (not opened). S2 slot: `d749a4b1` STOP/closure is now locatable (grant, `S2_V59_CONTROL_DISPOSITION.md`, audits `s2-v59-*`); S2 worktree porcelain 0. The transport in §3 already satisfies the grant's transport clause (accepted Stage 1 `setsid -f bash -c`, adapted only for this invocation and `s4-native-result` paths; no outer timeout/KILL/handler/second allowance).

## 5. Readiness and holds

File-side ready for a grant: exact caller at pinned path, `.cmd` and script hashes pinned, V6.1 bytes frozen, worktree/predecessor/probes restored, `node_modules` absent as the runner requires. Grant published and matched (§4a). **Held**: activation — waits for the explicit parent ACTIVATE message referencing `S4_NATIVE_V2_GRANT.md`; on it, T1 of `NATIVE_TRANSPORT.md` runs exactly once (its guards re-verify both caller hashes and the V6.1 manifest immediately before spawn), then T2 polls, T3 collects the three separate artefacts, and a non-self-including result manifest is frozen under `s4-native-result/`. First unexpected result: stop, preserve, report — no rerun. Not claimed: any runtime outcome; caller semantics remain unexecuted (reviews are source-only).

## 6. Owned outputs

`execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh`; `execution/e8d546f9/s4-native-prep/{REPORT.md, NATIVE_TRANSPORT.md, native-caller-v2.cmd, MANIFEST.sha256, logs/N1, N2, N3, N4}` — `MANIFEST.sha256` covers this directory except itself.
