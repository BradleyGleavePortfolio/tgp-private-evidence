# S6 R2 independent audit A — final revision 1

**FINAL BOUNDED VERDICT: NOT CLEARED at `55db31a0696ebd07d0cb9abb18ffd31dce29457d` / tree `130ef9bfdcdbc038b87466529f5980e759f3451a`.**

The frozen combined validation packet closes the full-suite and authentic JavaScript-export evidence gaps, but does not close two material source findings: **S6-R2-A-01** (real fallback identity/cache composition) and **S6-R2-A-02** (unsupported import-outcome assurances). Both are inherited within the cumulative acceptance path, not newly introduced export regressions. Release/native/hosted unknowns are separate from these bounded-merge blockers. This revision is new; the preliminary root packet remains byte-for-byte unchanged. ([Source findings and probes](preliminary/PRELIMINARY_FINDINGS.md); [combined verification](combined-packet-verification.json).)

## Reviewer identity and independence

- Requested reviewer model/effort: inherited routing from parent; no independently verified model/version or reasoning-setting disclosure is available to this reviewer.
- Actual known identity: the independent API assistant assigned auditor A in this invocation. Do not infer a runtime model from inherited builder/reviewer reports.
- I did not implement the candidate. Read both permitted R1 reports and both published fixer packets; did not read the other current R2 report or communicate with that reviewer.
- Candidate/evidence were read-only. Writes are confined to this assigned audit directory, with final-stage writes only in `final-1/`. No isolated R3 successor was inspected. No install, full Jest, tsc, lint, export, browser, native execution, source change, commit, push, deployment, customer access or hosted change was performed.

## Exact candidate

| Item | Independently observed value |
|---|---|
| Head | `55db31a0696ebd07d0cb9abb18ffd31dce29457d` |
| Tree | `130ef9bfdcdbc038b87466529f5980e759f3451a` |
| Public main base | `a5933fd6de5616493de75f0db907098b149b955c` |
| Pairing ancestor | `eaccaba98bc4400a0341bcd80409ab317bc85856` — ancestor check exit 0 |
| Export ancestor | `d7079265ea1263a1af6cd9cd132fc18dcb1793d9` — ancestor check exit 0 |
| Shared predecessor | `60975b51bd617bbfaa091ce76e57d16945298f82` |
| Local clean state | `git status --porcelain=v1 --untracked-files=all` empty at review |
| Cumulative diff | 35 files, +3813 / −70 |

The [source provenance record](preliminary/source-provenance.txt) includes commit/tree/parent/author/committer and cumulative scope; it verifies local immutable source, not a fresh GitHub branch-protection or PR-state observation. The parent's current state supplies separately time-stamped public-state verification. Original lineage identities remain a parent landing-route decision; no history was rewritten.

## Reviewed scope

Read the dispatch mandate, canonical G01–G22 rules, EXECUTE doctrine, current operator state, and both allowed inherited R1 reports. Reviewed cumulative source, not only the merge diff: pairing hook and actual screen/panel composition, identity hook/cache, mirror, auth sweep, optional storage and runtime consumers, static flag readers and release tests, dependency guard and workflow, lockfile/direct dependencies, request correlation and shared random-id generation, pairing API, review-flag gating, relevant tests, and backend pairing controller/service as a contract reference. Both published fixer reports and qualification notes were challenged rather than treated as clearance.

Independent offline probes:

1. [Actual storage + user cache](preliminary/probe-user-cache.cjs), [output](preliminary/probe-user-cache.log): unchanged candidate TypeScript evaluated in production-Android conditions, with synthetic AsyncStorage and missing optional module. Confirms S6-R2-A-01.
2. [Real React pairing hook](preliminary/probe-pairing-states.cjs), [output](preliminary/probe-pairing-states.log): actual hook under React test renderer; controlled identity, transport, timer, mirror and telemetry boundaries. Confirms failure/cancel state reachability for S6-R2-A-02. Renderer emits its normal deprecation warning; the probe exits naturally.
3. [Release flag/direct-dependency probe](preliminary/probe-flags.cjs), [output](preliminary/probe-flags.log): bounded per-module transforms with actual Expo preset and empty runtime environment; independent import/review truth table and manifest-lock consistency. Not a whole-app export.
4. [Published packet checksum results](preliminary/published-packet-checks.json): pairing manifest 54/54 entries match; export manifest 41/41 entries match. This proves archive integrity, not suitability of each execution claim.

**Toolchain qualification:** these bounded auditor probes ran under Node `v20.20.1`, not the validator's Node `v22.13.1`; the recorded [probe toolchain](preliminary/probe-toolchain.txt) is preserved. They evaluate unchanged source with explicit synthetic boundaries, not a physical Android app or a rerun of the CI suite. The read-only final [verifier](verify-combined-packet.py) uses Python for hashes, text comparisons and Git observations; it executes neither the candidate tests nor either exported bundle. No current-peer report was read, and parent-reported R3 work has no bearing on this exact-candidate verdict.

## Frozen combined execution assessment

Reviewed the delivered [combined report](../../../../s6-final-r2/REPORT.md), [harness](../../../../s6-final-r2/run-final.sh), all eight stamps, full-suite summary/exit, cold-export logs, residue assertions and manifest-covered artifacts. The matching published packet is `repos/evidence/2026-09-20/remediation/s6-r2/combined/revision-1`; the parent supplied evidence-main `5f629f3` and remote verification. **My verification is local**: both report copies hash to `36dbd19ff358d76b2dcfae79f7abde1c20d0393a52e2402ba451c86d3470bc25`; execution manifest 27/27, published manifest 28/28 and its retained builder manifest 27/27 match. The preliminary packet still matches all 11 manifest entries. ([Independent verification](combined-packet-verification.json).)

At the final check, local source HEAD/tree remain exactly as above, with the two prescribed merge parents and empty full-untracked porcelain status. Manifest/lock hashes match the supplied npm-ci input tree; the candidate node_modules symlink resolves to that tree and no MMKV package/stub is present. The packet binds each stage to this HEAD/tree, clean status, Node `v22.13.1` / npm `10.9.2`, unset NODE_OPTIONS, matching dependency hashes and absent MMKV stub. Shared dependency reuse is recorded, not misrepresented as a new combined-head install or a proof that every installed file was independently rehashed. ([Verification inputs and stamps](combined-packet-verification.json); [harness preconditions](../../../../s6-final-r2/run-final.sh).)

| Exact-candidate evidence | Assessment |
|---|---|
| `npm run validate:config` | Exit 0; two warnings remain: null Play Store URL and assetlinks placeholder. Not store-readiness proof. |
| `npm run lint` | Exit 0, 0 errors / 75 warnings. Builder labels warnings pre-existing; I did not independently recreate a baseline lint run. |
| `npx tsc --noEmit` | Exit 0, empty log. |
| `timeout 660 npx jest --ci` | **308/308 suites, 3839/3839 tests, 5/5 snapshots pass; child exit 0; no `--forceExit`.** Reported test duration 119.144 s, stage wall time 412 s. Natural exit within timeout is evidenced despite the delayed-shutdown warning. |
| Cold Android JS export, extension flag ON / review unset | Exit 0, `--no-bytecode --clear`, dedicated TMPDIR and empty-cache marker; 3019 modules. Extension flag `"true"`, review `void 0`. |
| Cold Android JS export, both flags unset | Exit 0, separate TMPDIR and empty-cache marker; extension/review both `void 0`. |
| Residue assertions | Both exit 0. Exactly one bundle per export; no computed `process.env[` or runtime app-flag reads; metadata present. Only public-variable runtime residue is Expo's `EXPO_PUBLIC_USE_RN_FETCH`. |

These results are bound by the [stage stamps and independent checks](combined-packet-verification.json), [full Jest log](../../../../s6-final-r2/logs/04-jest-full.log), [config log](../../../../s6-final-r2/logs/01-validate-config.log), [lint log](../../../../s6-final-r2/logs/02-lint.log) and [run summary](../../../../s6-final-r2/logs/summary.txt). The harness captures child exits before later commands, propagates export failures and asserts residue rather than treating printed matches as success. Serialization is explicit in its flock; no competing heavy audit execution was performed. ([Harness](../../../../s6-final-r2/run-final.sh).)

Independently read and hashed both actual 7,092,246-byte JavaScript artifacts:

- ON: `43c981f2b9f611113359806775b8f278b57833f700ca45eb9837c9067ddb59d8`.
- Unset: `0aa77c1f245b11bd52143e1e4a13b9ca53c6254df7f4746e0caf0a24e48f2dbe`.

The independent [bundle checks](combined-packet-verification.json) confirm flag-table literals, residue absence and one MMKV mention inside the caught optional require; the same bundle context retains the no-value synchronous shim getter implicated by A-01. These are authentic bundle-time results, **not** native startup/Hermes or consumer-correctness results.

### S6-R2-A-03 — Nonblocking evidence wording qualification

The combined report's “solely by the inlined flag values” statement is not byte-exact: two Sentry debug-id occurrences also differ. The initial auditor comparison therefore exited 1 on that assertion; its [original verifier](verify-combined-packet.attempt-1.py) and [attempt record](verification-attempts.md) are retained. A bounded [difference inspection](bundle-difference-investigation.json) identified only those debug-id differences after flag normalization. Exact equality holds after normalizing the specific flag field and those two identified debug-id occurrences—no other fields are ignored. This is a report qualification, not another merge blocker or invalidation of the export/residue gates. ([Final verifier result](combined-packet-verification.json).)

### Negative controls, prior failures and unexplained results

The pairing predecessor negative control intentionally fails three current ownership/epoch tests against the old hook; the export negative control intentionally fails two guard assertions against the old double-require file. They demonstrate test sensitivity, not failing current-candidate gates. Earlier undeclared Babel/raw-regex failures and optional-module export failure have source changes and exact combined passing evidence; historical stubbed exports and sibling/precommit exports are not substituted for it. ([Pairing packet](../../../../../repos/evidence/2026-09-20/remediation/s6-r2/pairing/revision-1/REPORT.md); [export packet](../../../../../repos/evidence/2026-09-20/remediation/s6-r2/export/revision-1/REPORT.md); [combined result](combined-packet-verification.json).)

There is **no unexplained failing combined-candidate command** in the frozen packet. Jest's delayed process shutdown remains unexplained at root-cause level; the warning must not be silently erased, but the eventual exit 0 before the timeout closes the prior missing-natural-exit evidence gap. My own failed bundle-equality assertion is explained separately in A-03 and preserved rather than suppressed. ([Jest log](../../../../s6-final-r2/logs/04-jest-full.log); [Jest stamp](../../../../s6-final-r2/logs/04-jest-full.STAMP); [attempt record](verification-attempts.md).)

## Material source findings — open, merge-blocking

### S6-R2-A-01 — Actual fallback cannot resolve persisted identity; real restoration remains blocked

**Affected boundary:** auth/cache/restore correctness; source-deterministic, not a native-only unknown. **Materiality:** high; an authenticated identity persisted by the actual login path cannot be recovered through its consumers. **Disposition:** OPEN; blocks affected S6 acceptance and bounded merge clearance.

The current build intentionally lacks native MMKV, and the repaired optional loader selects AsyncStorage. Its synchronous `getString()` returns `undefined`; the actual async `readUserCache()` calls that synchronous method and then reads only legacy `user_data`, never the namespaced key written by the real login path. Consequently fresh login writes an unreadable identity. Legacy migration returns a user once, deletes the legacy key, and makes subsequent readers return null. `RootNavigator` requires a user to mount authenticated navigation; `useCurrentUser()` also reads independently. Pairing now waits for non-null identity, so passing tests that supply a mocked identity still do not close actual process-restart restoration. ([storage](../../../../../worktrees/s6-final/src/storage/mmkv.ts), 113–127; [cache](../../../../../worktrees/s6-final/src/lib/userCache.ts), 33–81; [login](../../../../../worktrees/s6-final/src/screens/auth/LoginScreen.tsx), 79–93; [root](../../../../../worktrees/s6-final/src/navigation/RootNavigator.tsx), 575–586; [identity hook](../../../../../worktrees/s6-final/src/hooks/useCurrentUser.ts), 47–66; [pairing](../../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), 288–290, 431.)

The [independent probe](preliminary/probe-user-cache.log) confirms persisted bytes exist and async storage can retrieve them, while both userCache readers return null; a new module instance with the same disk also returns null. This is inherited source, not an export-fixer regression, but is directly on the acceptance path. Calling it “pre-existing sync shim limitation” does not bound away its consequence.

**Smallest follow-up:** repair user-cache read/write/patch/delete semantics against the existing fallback without native activation; cover fresh login, sequential legacy migration readers, restart, patch and logout with real storage/cache/identity composition. Check existing synchronous identity consumers rather than introducing another inconsistent half-fix. Re-attest the new exact head. See [full preliminary finding](preliminary/PRELIMINARY_FINDINGS.md).

### S6-R2-A-02 — Pairing UI asserts “nothing imported” / “no import started” without evidence

**Affected boundary:** customer truth and retry/recovery behavior, default-off feature; inherited in the cumulative panel. **Materiality:** material recovery misinformation, not cosmetic wording. **Disposition:** OPEN; bounded source remediation before clearance, not a new progress service.

Five status-transport failures yield `failed`; the panel then says “Nothing was imported”. Local cancel drops the code/poll/mirror with no revoke request; the panel says “No import was started”. The extension may already have redeemed the code and continued while the phone has not received a successful status poll. A mobile transport failure/local abandon cannot establish either negative claim. Similarly `/pair/status = paired` establishes code redemption, not the current running import claimed by zero-roster-delta copy. ([hook](../../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), 264–267, 474–478; [panel](../../../../../worktrees/s6-final/src/components/coach/ExtensionPairingPanel.tsx), 183–196, 219–236; [backend service](../../../../../repos/backend/src/extension-pair/extension-pair.service.ts), `redeem` and `deriveStatus`; [probe output](preliminary/probe-pairing-states.log).)

False assurance can prompt redundant retry or mislead a coach about a still-running import, so this is not typography or cosmetic wording. The smallest remedy is status-bounded copy: “could not check pairing status”, “stopped checking on this device; check the extension”, and “paired; check the extension for progress”. Distinguish init from polling failure if stronger wording is desired. Do not add an unapproved progress/revoke contract merely to correct the messages.

## Final inherited finding dispositions

| Stable ID | Source disposition / remaining boundary |
|---|---|
| S6-A1 / S6-B-1 | **Closed in bounded scope:** Babel AST guard excludes comments, includes a real computed-read negative control; exact combined full suite passes. |
| S6-B-2 | **Closed:** direct `@babel/core` devDependency and matching lock root/resolution; no weakening of dependency scanner; exact combined suite/lint/types pass. |
| S6-A2 / S6-B-3 | Hook and screen timing defects repaired locally, including null-first identity and screen peek. **Integrated finding not closed:** S6-R2-A-01 blocks actual identity hydration; tests still replace `useCurrentUser`. |
| S6-A3 | Remains release/build-input gate: hosted production/preview public flags not inventoried. No hosted change authorized or attempted. Correct static inlining can activate formerly ignored hosted values. Not automatically a bounded merge blocker if merge is genuinely separated from release. |
| S6-A4 / S6-B-6 | **JavaScript-export gap closed:** exact combined cold ON/unset exports, hashes and residues independently verified. Native startup/device, hosted inventory and integrated customer proof remain unproven. |
| S6-A5 | Parent landing-route decision for inherited author/committer identities. New candidate lineage identity recorded, no rewrite. |
| S6-A6 | Prior nonmaterial accessibility/plaintext/local-server-cancel observations retained with boundaries. Server create-then-expire is nontransactional; do not present single-active invariant as an unconditional atomic guarantee. New customer-copy finding A-02 is separately material. |
| S6-B-4 | User-key/payload guard and server ownership checks remain sound. Mint epoch protects late success/rejection/finally for current attempt. This is not universal logout/persistence-race proof; see residuals. |
| S6-B-5 | Import and review switches remain independent, hard-default-off, with both required for reconstruction reads. No new native/hosted activation found in source. |
| S6-B-7 | Contract/error-reference/a11y mechanics mostly retained. Its “honest errors” conclusion does not transfer to the unsupported import-outcome copy in A-02. |
| S6-R2-NEW-1 (fixer) | **Bundle-resolution blocker closed:** one guarded require, no second unguarded require; authentic exact-head combined exports pass without stub. Fallback initialization alone does not prove real consumers (A-01). |
| S6-R2-NEW-2 (fixer) | **Non-exit gap closed for this candidate:** exact combined full run exits 0 naturally under timeout 660 without forceExit. Shutdown-delay warning remains; root cause not established, but no current failing exit. |

These dispositions compare both permitted inherited reports ([R1 A](../../../../../repos/evidence/2026-09-20/audits/s6-r1/a/revision-2/REPORT.md); [R1 B](../../../../../repos/evidence/2026-09-20/audits/s6-r1/b/revision-1/REPORT.md)) against cumulative source/probes and the [exact combined packet verification](combined-packet-verification.json), not against another current reviewer.

## Residuals and evidence boundaries

- **Epoch/identity:** mint success, catch and finally now use attempt identity; owner change clears in-memory ownership. A→B→A stale writes are not storage-transactionally ordered; they can overwrite the newer A mirror. Server revalidation prevents treating that mirror as authoritative. If old code was already redeemed, status may be `paired`, not necessarily `expired`; “always expired” is too strong. No cross-owner mirror read was found.
- **Logout write window:** the compensation checks owner after awaited write. `signOut()` snapshots prefix keys before asynchronous wipes and emits logout last. A previously absent mirror written after enumeration but before identity change can survive without entering that compensation branch. Same-user key/payload checks and server code TTL bound it; no universal wipe guarantee is attested. ([logout](../../../../../worktrees/s6-final/src/services/authActions.ts), 295–314, 338; [mint write](../../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), 339–359.)
- **Mirror truth:** local persisted expiry is not compared against client time; server decides. Restore may show a pending code before validation, but does not claim completed import. Storage-read failure falls back to no mirror; write failure degrades durability. Native retention and physical-device clipboard behavior were not tested.
- **Optional module:** the one guarded require and absent-package lock invariant match the intended Metro behavior. Shape validation rejects missing/empty/non-function exports, but a function-valued `MMKV` is not proof of constructibility or successful native initialization. Do not activate that path based on this review.
- **Crypto:** inherited deterministic native-MMKV encryption key conflicts with random-Keychain prose. That path is currently unlinked/absent, so not a newly activated crypto defect here; enabling MMKV requires a separate security repair. AsyncStorage fallback is plaintext, not an encryption proof.
- **Flags:** module transforms and JS exports do not establish hosted EAS values, native startup/Hermes, deployment, enablement, customer import or acceptance. Warm transform cache can retain prior flag values; final proof must be cold/cleared for each intended input.
- **Evidence attribution:** stubbed pairing-lane exports are diagnostic only. Predecessor full-suite evidence does not transfer to either sibling or the combined head. The published manifest checks do not fix that applicability limitation.

## Final verdict and smallest follow-up

**NOT CLEARED for the bounded cumulative S6 candidate.** The checked-in suite and authentic exports are valid evidence for their commands, not proof of the real storage → user cache → identity → pairing composition or an import-outcome observation. A-01 and A-02 remain open; neither needs a hosted/native experiment to establish the defect. ([Identity probe](preliminary/probe-user-cache.log); [pairing probe](preliminary/probe-pairing-states.log); [combined verification](combined-packet-verification.json).)

1. Repair actual fallback user-cache consistency, including sync consumers, migration, restart, updates and logout; add integrated regression proof without replacing the identity/cache modules under test.
2. Replace unsupported failure/cancel/running assertions with status-bounded wording; regress failure after possible redemption and local abandon without claiming a server-side cancel or import outcome.
3. Freeze the successor's exact head/tree, rerun affected and cumulative gates under parent scheduling, and independently re-audit the affected acceptance boundaries. No clearance transfers automatically from this source or to the parent's isolated R3 work.
4. Keep hosted public-flag inventory, authentic native startup/device import, store-configuration remediation, deployment/enablement and customer acceptance as distinct future release gates. Current native MMKV must not be activated on the strength of this audit.

No implementation, source push, product merge, deployment, flag activation, native/customer execution or final-product acceptance is claimed. This completed revision must be archived unchanged; any correction must be a new notified revision.
