# S6 R2 independent audit A

**SOURCE REVIEW COMPLETE — AWAITING FROZEN COMBINED EXECUTION PACKET. NO FINAL VERDICT ISSUED.**

This is an in-progress report, not a completed/frozen audit revision. The parent must deliver the frozen `execution/s6-final-r2` packet before final disposition. Two preliminary material source findings are available for immediate remediation planning.

## Reviewer identity and independence

- Requested reviewer model/effort: inherited routing from parent; no independently verified model/version or reasoning-setting disclosure is available to this reviewer.
- Actual known identity: the independent API assistant assigned auditor A in this invocation. Do not infer a runtime model from inherited builder/reviewer reports.
- I did not implement the candidate. Read both permitted R1 reports and both published fixer packets; did not read the other current R2 report or communicate with that reviewer.
- Candidate/evidence were read-only. Writes are confined to this assigned audit directory. No install, full Jest, tsc, lint, export, browser, native execution, source change, commit, push, deployment, customer access or hosted change was performed.

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

The [source provenance record](source-provenance.txt) includes commit/tree/parent/author/committer and cumulative scope; it verifies local immutable source, not a fresh GitHub branch-protection or PR-state observation. The parent's current state supplies separately time-stamped public-state verification. Original lineage identities remain a parent landing-route decision; no history was rewritten.

## Reviewed scope

Read the dispatch mandate, canonical G01–G22 rules, EXECUTE doctrine, current operator state, and both allowed inherited R1 reports. Reviewed cumulative source, not only the merge diff: pairing hook and actual screen/panel composition, identity hook/cache, mirror, auth sweep, optional storage and runtime consumers, static flag readers and release tests, dependency guard and workflow, lockfile/direct dependencies, request correlation and shared random-id generation, pairing API, review-flag gating, relevant tests, and backend pairing controller/service as a contract reference. Both published fixer reports and qualification notes were challenged rather than treated as clearance.

Independent offline probes:

1. [Actual storage + user cache](probe-user-cache.cjs), [output](probe-user-cache.log): unchanged candidate TypeScript evaluated in production-Android conditions, with synthetic AsyncStorage and missing optional module. Confirms S6-R2-A-01.
2. [Real React pairing hook](probe-pairing-states.cjs), [output](probe-pairing-states.log): actual hook under React test renderer; controlled identity, transport, timer, mirror and telemetry boundaries. Confirms failure/cancel state reachability for S6-R2-A-02. Renderer emits its normal deprecation warning; the probe exits naturally.
3. [Release flag/direct-dependency probe](probe-flags.cjs), output `probe-flags.log`: bounded per-module transforms with actual Expo preset and empty runtime environment; independent import/review truth table and manifest-lock consistency. Not a whole-app export.
4. [Published packet checksum results](published-packet-checks.json): pairing manifest 54/54 entries match; export manifest 41/41 entries match. This proves archive integrity, not suitability of each execution claim.

## Preliminary material findings

### S6-R2-A-01 — Actual fallback cannot resolve persisted identity; real restoration remains blocked

**Affected boundary:** auth/cache/restore correctness; source-deterministic, not a native-only unknown. **Recommendation:** block closure of the affected S6 acceptance and require repair before bounded merge clearance.

The current build intentionally lacks native MMKV, and the repaired optional loader selects AsyncStorage. Its synchronous `getString()` returns `undefined`; the actual async `readUserCache()` calls that synchronous method and then reads only legacy `user_data`, never the namespaced key written by the real login path. Consequently fresh login writes an unreadable identity. Legacy migration returns a user once, deletes the legacy key, and makes subsequent readers return null. `RootNavigator` requires a user to mount authenticated navigation; `useCurrentUser()` also reads independently. Pairing now waits for non-null identity, so passing tests that supply a mocked identity still do not close actual process-restart restoration. ([storage](../../../../worktrees/s6-final/src/storage/mmkv.ts), 113–127; [cache](../../../../worktrees/s6-final/src/lib/userCache.ts), 33–81; [login](../../../../worktrees/s6-final/src/screens/auth/LoginScreen.tsx), 79–93; [root](../../../../worktrees/s6-final/src/navigation/RootNavigator.tsx), 575–586; [identity hook](../../../../worktrees/s6-final/src/hooks/useCurrentUser.ts), 47–66; [pairing](../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), 288–290, 431.)

The [independent probe](probe-user-cache.log) confirms persisted bytes exist and async storage can retrieve them, while both userCache readers return null; a new module instance with the same disk also returns null. This is inherited source, not an export-fixer regression, but is directly on the acceptance path. Calling it “pre-existing sync shim limitation” does not bound away its consequence.

**Smallest follow-up:** repair user-cache read/write/patch/delete semantics against the existing fallback without native activation; cover fresh login, sequential legacy migration readers, restart, patch and logout with real storage/cache/identity composition. Check existing synchronous identity consumers rather than introducing another inconsistent half-fix. Re-attest the new exact head. See [full preliminary finding](PRELIMINARY_FINDINGS.md).

### S6-R2-A-02 — Pairing UI asserts “nothing imported” / “no import started” without evidence

**Affected boundary:** customer truth and retry/recovery behavior, default-off feature; inherited in the cumulative panel. **Recommendation:** bounded source remediation, not a new progress service.

Five status-transport failures yield `failed`; the panel then says “Nothing was imported”. Local cancel drops the code/poll/mirror with no revoke request; the panel says “No import was started”. The extension may already have redeemed the code and continued while the phone has not received a successful status poll. A mobile transport failure/local abandon cannot establish either negative claim. Similarly `/pair/status = paired` establishes code redemption, not the current running import claimed by zero-roster-delta copy. ([hook](../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), 264–267, 474–478; [panel](../../../../worktrees/s6-final/src/components/coach/ExtensionPairingPanel.tsx), 183–196, 219–236; [backend service](../../../../repos/backend/src/extension-pair/extension-pair.service.ts), `redeem` and `deriveStatus`; [probe output](probe-pairing-states.log).)

False assurance can prompt redundant retry or mislead a coach about a still-running import, so this is not typography or cosmetic wording. The smallest remedy is status-bounded copy: “could not check pairing status”, “stopped checking on this device; check the extension”, and “paired; check the extension for progress”. Distinguish init from polling failure if stronger wording is desired. Do not add an unapproved progress/revoke contract merely to correct the messages.

## Inherited finding dispositions — provisional pending final packet

| Stable ID | Source disposition / remaining boundary |
|---|---|
| S6-A1 / S6-B-1 | Source fix valid: Babel AST guard excludes comments, includes a real computed-read negative control. Exact combined full-suite/guard execution pending packet. |
| S6-B-2 | Source fixed: direct `@babel/core` devDependency and matching lock root/resolution; no weakening of dependency scanner. Combined validation pending. |
| S6-A2 / S6-B-3 | Hook and screen timing defects repaired locally, including null-first identity and screen peek. **Integrated finding not closed:** S6-R2-A-01 blocks actual identity hydration; tests still replace `useCurrentUser`. |
| S6-A3 | Remains release/build-input gate: hosted production/preview public flags not inventoried. No hosted change authorized or attempted. Correct static inlining can activate formerly ignored hosted values. Not automatically a bounded merge blocker if merge is genuinely separated from release. |
| S6-A4 / S6-B-6 | Transform proof is useful, not native proof. Export fixer's authentic flag-on export binds to its committed head; unset export was precommit. Combined cold exports still require frozen packet. |
| S6-A5 | Parent landing-route decision for inherited author/committer identities. New candidate lineage identity recorded, no rewrite. |
| S6-A6 | Prior nonmaterial accessibility/plaintext/local-server-cancel observations retained with boundaries. Server create-then-expire is nontransactional; do not present single-active invariant as an unconditional atomic guarantee. New customer-copy finding A-02 is separately material. |
| S6-B-4 | User-key/payload guard and server ownership checks remain sound. Mint epoch protects late success/rejection/finally for current attempt. This is not universal logout/persistence-race proof; see residuals. |
| S6-B-5 | Import and review switches remain independent, hard-default-off, with both required for reconstruction reads. No new native/hosted activation found in source. |
| S6-B-7 | Contract/error-reference/a11y mechanics mostly retained. Its “honest errors” conclusion does not transfer to the unsupported import-outcome copy in A-02. |
| S6-R2-NEW-1 (fixer) | Optional-MMKV bundle-resolution root cause source-fixed (one guarded require, no second unguarded require). Authentic combined export evidence pending. Fallback initialization alone does not prove real consumers (A-01). |
| S6-R2-NEW-2 (fixer) | Earlier slow/non-exit shorthand superseded for predecessor by its natural-exit proof. No automatic transfer to combined head; await full combined log and exit. |

## Residuals and evidence boundaries

- **Epoch/identity:** mint success, catch and finally now use attempt identity; owner change clears in-memory ownership. A→B→A stale writes are not storage-transactionally ordered; they can overwrite the newer A mirror. Server revalidation prevents treating that mirror as authoritative. If old code was already redeemed, status may be `paired`, not necessarily `expired`; “always expired” is too strong. No cross-owner mirror read was found.
- **Logout write window:** the compensation checks owner after awaited write. `signOut()` snapshots prefix keys before asynchronous wipes and emits logout last. A previously absent mirror written after enumeration but before identity change can survive without entering that compensation branch. Same-user key/payload checks and server code TTL bound it; no universal wipe guarantee is attested. ([logout](../../../../worktrees/s6-final/src/services/authActions.ts), 295–314, 338; [mint write](../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), 339–359.)
- **Mirror truth:** local persisted expiry is not compared against client time; server decides. Restore may show a pending code before validation, but does not claim completed import. Storage-read failure falls back to no mirror; write failure degrades durability. Native retention and physical-device clipboard behavior were not tested.
- **Optional module:** the one guarded require and absent-package lock invariant match the intended Metro behavior. Shape validation rejects missing/empty/non-function exports, but a function-valued `MMKV` is not proof of constructibility or successful native initialization. Do not activate that path based on this review.
- **Crypto:** inherited deterministic native-MMKV encryption key conflicts with random-Keychain prose. That path is currently unlinked/absent, so not a newly activated crypto defect here; enabling MMKV requires a separate security repair. AsyncStorage fallback is plaintext, not an encryption proof.
- **Flags:** module transforms and JS exports do not establish hosted EAS values, native startup/Hermes, deployment, enablement, customer import or acceptance. Warm transform cache can retain prior flag values; final proof must be cold/cleared for each intended input.
- **Evidence attribution:** stubbed pairing-lane exports are diagnostic only. Predecessor full-suite evidence does not transfer to either sibling or the combined head. The published manifest checks do not fix that applicability limitation.

## Pending final execution assessment

Await parent's explicitly frozen combined-head packet. Review exact head/tree/clean state, relevant toolchain/dependency inputs, untruncated command and exit binding, focused/full natural-exit results, cold flag-on and flag-unset exports, bundle hashes/residue, and negative-control attribution. List unexplained failures rather than hiding them. No final bounded verdict has been issued.
