# S6 R2 auditor A — preliminary source findings

This is **not a final verdict**. Combined execution packet has not yet been delivered frozen. Independent source review at `55db31a0696ebd07d0cb9abb18ffd31dce29457d`, tree `130ef9bfdcdbc038b87466529f5980e759f3451a`. No current peer report read; no source implementation, install, heavy execution, push, hosted action or native run.

## S6-R2-A-01 — MATERIAL: actual production storage consumer cannot resolve identity, so pairing restore is still unreachable

The optional-MMKV export repair correctly selects the AsyncStorage shim, but that shim's synchronous `getString()` always returns `undefined`. The actual identity consumer `readUserCache()` calls that synchronous method and then reads only the old unnamespaced `user_data`, not the `prefs:auth.user_data` written by `setUserCache()`. This is not a native-device uncertainty: it is deterministic JavaScript composition. See [storage fallback](../../../../worktrees/s6-final/src/storage/mmkv.ts), lines 113–127, and [user cache](../../../../worktrees/s6-final/src/lib/userCache.ts), lines 33–81.

The unchanged real login screen calls `setUserCache(user)`, and `RootNavigator.bootstrapAuth()` requires `readUserCache()` to return a user. With current dependencies (MMKV absent), a fresh successful login's persisted user cannot be read; bootstrap selects unauthenticated. A legacy user can be returned once while migration deletes the old key, after which the screen/hook's separate reads return null. The pairing hook now deliberately waits for a non-null identity, so its new restore guards are locally correct but their actual prerequisite never arrives. See [login](../../../../worktrees/s6-final/src/screens/auth/LoginScreen.tsx), lines 79–93; [root bootstrap](../../../../worktrees/s6-final/src/navigation/RootNavigator.tsx), lines 575–586; [identity hook](../../../../worktrees/s6-final/src/hooks/useCurrentUser.ts), lines 47–66; [pairing hook](../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), lines 288–290 and 431.

Independent bounded offline execution of unchanged candidate modules confirms:

- Production Android path tries the missing optional module exactly once and selects the fallback.
- `setUserCache(synthetic user)` stores `prefs:auth.user_data`; both sync and async cache readers return null.
- Legacy `user_data` → first read returns synthetic user, second read returns null; module reload with the same disk still returns null.
- Direct `prefsStorage.getStringAsync('auth.user_data')` sees the stored user, ruling out a failed write.

Probe: [executable](probe-user-cache.cjs), [output](probe-user-cache.log). Mock boundary: deterministic in-memory AsyncStorage implementation and Android platform; TypeScript transpile of the **actual** `mmkv.ts` and `userCache.ts`; not a copied implementation, not a native test.

**Inheritance / consequence:** `userCache.ts` and the shim read behavior are unchanged from public main; the export repair did not create the defect. Nevertheless it makes the normal release graph buildable with that fallback, and the S6 restoration acceptance relies on this exact consumer. The export packet lists the incompatibility merely as a pre-existing residual; that understates its functional consequence. Source-level portions of S6-A2 / S6-B-3 are repaired, but integrated closure cannot be given while this prerequisite remains broken. A passing suite with mocked `useCurrentUser` cannot close it.

**Smallest follow-up:** make identity persistence/read/patch/delete semantics coherent with the already-selected AsyncStorage fallback, without declaring or activating native MMKV. Add a real storage + userCache + useCurrentUser composition test, including fresh login, sequential readers after legacy migration, restart, patch, and logout. Audit synchronous consumers separately so an async-only patch does not leave user scoping broken. Re-attest the changed head.

## S6-R2-A-02 — MATERIAL customer truth: terminal copy asserts an import outcome that pairing cannot know

The panel's inherited `failed` copy says “Nothing was imported”, and its local-only `cancelled` copy says “No import was started”. Five status-transport failures after extension redemption, or local Cancel before the next status poll, do not prove either claim. Backend redemption issues tokens independently; no cancel endpoint exists. This is a concrete customer-truth defect in the cumulative reviewed panel, not missing native proof. See [panel](../../../../worktrees/s6-final/src/components/coach/ExtensionPairingPanel.tsx), lines 219–236, and [hook](../../../../worktrees/s6-final/src/hooks/useExtensionPairing.ts), lines 264–267 and 474–478.

The independent [real React hook probe](probe-pairing-states.cjs) reaches `failed` after five transport failures and reaches `cancelled` without any revoke/outcome request; [output](probe-pairing-states.log) records the actual panel messages. Resolved identity is deliberately mocked here to isolate this defect from S6-R2-A-01; timers, transport, telemetry and mirror are also controlled. This proves the state transitions, not actual external import execution. The latter need not be fabricated: the checked backend contract allows extension redemption/import to proceed independently of a mobile poll result.

The paired zero-delta message also says “Your import is still running in the browser extension” though `/pair/status = paired` only establishes redemption, not a current running import. The smallest remedy is truthful bounded copy: status unavailable rather than “nothing imported”; local checking abandoned rather than “no import started”; paired rather than a current progress assertion. If distinct mint/poll failures need different wording, preserve their origin in state. No new backend endpoint is necessary merely to stop asserting unknown outcomes. A false negative can induce a duplicate retry or wrongly reassure a coach that a live import stopped, so this is not cosmetic wording.

## Additional source observations pending final classification

- The logout compensating clear covers a write settling after the hook has observed owner change, not every write after sign-out begins. Prefix keys are snapshotted before async wipes and the logout event is emitted last. A previously absent mirror written after enumeration but before identity change may survive; payload ownership and server TTL still bound cross-user use. Do not upgrade the new test to a universal “nothing can remain after logout” claim.
- `asMmkvModule` recognizes a function-valued constructor, not constructibility/native initialization. The absent-package fallback is the current supported path; no MMKV native capability or encryption assurance is established.

Final inherited-ID disposition, execution attribution, checksum verification and bounded verdict remain pending the parent's completed combined-head packet.
