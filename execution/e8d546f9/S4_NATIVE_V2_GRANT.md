# S4 R6 native validation grant with caller V2

Parent EXEC-e8d546f9, 2026-09-23. Individually T4: consequential validation, process ownership, canonical exclusion and trusted evidence. Sole executor `restore_upstream_proof_inputs_muddwjad`, requested Claude Fable 5 / High as policy, not observed runtime telemetry. Executor is not the caller builder or independent reviewer.

## Activation

QUEUED until private publication, exact preparation and an explicit parent ACTIVATE message. S2 V59 stopped and closed its slot with frozen result `d749a4b1…`; no competing control/install/browser/database execution is permitted.

Authorize one native VALIDATION invocation only. No Stage 1 rerun, retry, source repair or replacement harness is authorized.

## Exact reviewed inputs

- V6.1 packet manifest `671d08c3633378ef392a4aee6bbb70b78319994727d74e439b75830a6d63d8ee`, 12/12, staged at `execution/s4-r6-validation/v6/`. Runner/library/product bytes unchanged.
- Stage 1 result manifest `9c84eab2f4a4fe2567d952e9a6bded8ea301d9f2110d8427363f181c9ff940d7`: raw 0, all 363 predicates and clean private ownership. Preserve, do not rerun.
- Native caller V2 packet manifest `7bff8f2c9fd7c15ac6ebab18524e6cf2b122fa38506e98864f23b15ccea3f8bf`, 7/7.
- Exact caller `ba73a99b2602e5640a6339b3e1ec0e79e02272e00914fc5a60faf22f5630a1c1`, mechanically restored outside V6 at `execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh`.
- Invocation file `ef45fd8d8cc6276de070a9cd0a1674e34174360863327db09c564345d52bae84`.
- Independent exact V2 reviews: A manifest `1b2634a0dd91ad78c46f844fc66bbca5725a270103eb6ca30882b06ad512c4fb`; B manifest `8bece05bf3aaeecf5a450635895b6f8d75d8cdf9eeed4e99ff9faaa88fef3ca9`. Both close the required receipt-write propagation defect with no material introduced defect. V1 B's earlier narrower reading never overrode A's valid finding.

Verify all named manifest and caller hashes immediately before launch. A mismatch or pre-existing native run/result log is refusal, not permission to overwrite or retry.

## Native source and environment

Worktree `worktrees/s4-r6` must remain clean at HEAD `91990ae9aec72f47a67591892ac09fa1f59d2f16`, tree `840fb2855953d5363fbd144e11b3f81763d9cef7`, parent `88287cff47240aa58b5f0fea5da08670f1e87df6`. Base `0111be661922234d670bbf23e23d270eec1b4a4e` is an ancestor; the restored worktree is non-shallow after the separately recorded parent fetch. Lockfile SHA256 `262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8`.

Use restored byte-exact predecessor and probes at the runner's pinned paths. Restoration/unshallow result `718b9757…` records file/Git readiness; runtime still checks node v20.20.1, npm 10.8.2 and all pins. `node_modules` and worktree `dist` must be absent before this fresh run. No preinstallation is requested.

Use the same unprivileged user (EUID 2000), non-job-control transport. Verify all `S4R6_*` overrides and `TGP_CHROME` are unset before launch so VALIDATION, canonical lease, default receipts, outer 3300, grace 45 and the pinned default Chrome path apply. Refuse unexplained inherited overrides rather than silently changing semantics.

## Invocation and transport

The exact inner invocation is:

```sh
bash /home/user/workspace/execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh
```

Use the already accepted Stage 1 `setsid -f bash -c` transport, adapted only for this invocation and fresh `execution/e8d546f9/s4-native-result/` log/exit paths. Preserve the actual observer status immediately in the transport receipt. No added outer timeout, KILL, signal handler, second allowance or alternate caller. The tool's 900-second group supervisor must not terminate this detached native chain.

Caller observer 3422 seconds plus one 127-second cancellation allowance and at least 20 seconds of bounded read tail gives nominal 3569 seconds post-spawn, 3589 including manifest allowance. Polling, publication and some reads remain unenclosed; these figures are not a universal completion guarantee or permission to KILL. The existing launcher/runner retain their reviewed owned-session deadlines and cleanup.

## Authorized effects

Only the unchanged native runner/launcher/caller perform execution. Permit their canonical nonblocking fd-9 acquisition at `execution/test-validation.lock`; refusal 75 stops the run without displacing another holder.

Permit the runner's one fresh locked `npm ci`, toolchain provenance, gitleaks 8.30.0 install/version check, gates, exact-range/full-history scans, focused/full Vitest, pinned positive/negative discriminators, package/hash joins, two Chrome pipe trials and browser positive/negative proofs. External downloads are limited to dependencies/tools fetched by these exact scripts; no extra package, global upgrade, credential transmission, hosted application action or live customer import.

Writes are limited to the declared native run paths under `execution/s4-r6-validation/runs/`, `tooling/`, `caller-receipts/`; dependency/build/test outputs in `worktrees/s4-r6` generated by the unchanged runner; normal npm cache/log files generated by npm; runner/browser-owned temporary profiles; canonical lease; exact caller restore/prep paths; and `execution/e8d546f9/s4-native-result/` evidence. Source, lockfile, predecessor, probes, frozen V6/V2 packets, other worktrees and prior results must not be edited. Any unexpected source mutation is evidence of failure, not permission to repair.

No Git hook/commit/push, product landing, deployment, settings, flags, database, S5/S6 runtime, schema/generator action or customer/production proof is authorized.

## Outcome and recovery

Preserve three separate facts: transport observer exit, complete caller receipt with actual launcher exit/identity, and the launcher's `SUPERVISOR_RECORD.json` plus runner records/sentinel. Native success requires actual launcher 0 AND observer 0 AND complete, mutually consistent evidence, no validation blocks, source unchanged and EMPTY owned work without a live quarantine owner.

Expected 19 focused and 1742 full tests are runner assertions, not assumed facts. Report observed counts, every actual step status, expected-negative classification, artifact/hash joins, browser results and NOTRUN reasons. A timeout, runtime-unavailable browser, missing receipt, nonzero, UNKNOWN, contradiction or retained owner is not success. Preserve all logs including installation/debug logs with credential review before private publication.

Observer 97 is an unresolved/retained boundary, never actual launcher 12 or completion. Actual 12 can be a forwarded runner status; determine cause from supervisor/runner fields, not the caller's diagnostic wording alone.

No executor recovery signal or ad hoc lock probe is authorized beyond exact reviewed scripts. Any live last owner must be reported with pid/starttime/token/fd9 and current owned-work census. Parent recovery needs separate exact identity verification and positively EMPTY work; UNKNOWN never authorizes release. Do not pattern-kill, signal a bare PID, kill the wrapper or delete the lock.

On first unexpected result, preserve the full result tree and source state, stop, and report. Freeze a non-self-including result manifest and attributable cleanup/retention accounting. No automatic rerun or installation reuse is granted. Final evidence review remains separate from execution and from all release/customer acceptance.
