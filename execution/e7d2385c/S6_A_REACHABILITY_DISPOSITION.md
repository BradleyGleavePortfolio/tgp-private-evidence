# S6 reviewer A — P2 reachability disagreement disposition

**Disposition: Class C; record/qualify/continue. No actual supported product A→B producer bypassing `signOut()` was found, so S6-B-P2-01's premise is theoretical in the reviewed application. P2 source grantability and my A01/A02 closure remain unchanged; no change, test, rerun or new cycle is required.**

This is an additive source-reachability follow-up after both independent P2 seals, not an adoption of reviewer B's conclusion and not a reopened P1/P2 audit. I inspected only the relevant committed-identity producer/listener and composition bytes.

## Exact product call-chain result

`sessionUserId` can change only when `bootstrapAuth()` reads the token and cached user; its production triggers are initial `RootNavigator` mount and the generic `authEvents.onAuthChange(bootstrapAuth)` listener. ([RootNavigator lines 291–338](P2_inputs/candidate/src/navigation/RootNavigator.tsx))

The supported emitters divide as follows:

1. **Actual identity writers run only under committed logged-out UI.** `LoginScreen`, `CreateAccountScreen` and `RoleSelectionScreen` are owned by `AuthNavigator`, and that navigator renders only for `authState === 'unauthenticated'`; their successful paths write the user cache, purge old persisted query blobs and then emit. ([AuthNavigator](disagreement-inputs/src/navigation/AuthNavigator.tsx), [login](disagreement-inputs/src/screens/auth/LoginScreen.tsx), [signup](disagreement-inputs/src/screens/auth/CreateAccountScreen.tsx), [role selection](disagreement-inputs/src/screens/auth/RoleSelectionScreen.tsx)) Thus the prior committed identity is `null`, not A, before B is committed. ([RootNavigator lines 814–860](P2_inputs/candidate/src/navigation/RootNavigator.tsx))
2. **Authenticated generic emitters do not replace identity.** Coach-wizard completion, onboarding completion/reset and day-one completion alter routing/completion flags and re-bootstrap the same cached user; they do not write another user's id. ([RootNavigator bootstrap identity lines 585–619](P2_inputs/candidate/src/navigation/RootNavigator.tsx))
3. **Supported logout/account-switch routes clear through `signOut()`.** Normal logout and refresh-failure call `signOut()`, whose P2 order retires/drains persistence, purges disk, settles/clears query memory and only then emits logout. ([P2 signOut lines 313–377](P2_inputs/candidate/src/services/authActions.ts), [refresh failure lines 177–197](disagreement-inputs/src/services/api.ts))
4. `BiometricUnlockGate` can unmount and later remount `RootNavigator`, establishing the interruption half of A01, but it does not produce a new identity; it only gates the same application subtree. ([biometric component](disagreement-inputs/src/components/BiometricUnlockGate.tsx), [biometric hook](disagreement-inputs/src/hooks/useBiometricGate.ts)) A remount therefore bootstraps the same persisted user unless a separate supported auth operation changed storage. ([bootstrap](P2_inputs/candidate/src/navigation/RootNavigator.tsx)) No such A→B operation bypassing points 1–3 was found in the inspected production call graph.

There is a token-only logout emitter in `biometric-lock.service.ts`, but repository search found no production importer/caller of its exported `requireAuth()` or `verifyPin()`; declarations and self-calls alone are not an actual supported reachable path. ([service](disagreement-inputs/src/security/biometric-lock.service.ts)) It also does not produce B. ([lockout lines 154–165](disagreement-inputs/src/security/biometric-lock.service.ts)) Treating it as the missing producer would be hypothetical reachability, contrary to the requested decision rule.

## Consequence

The state observation is technically real: if an external/test-only actor mutates persisted credentials from A directly to B while the gate is unmounted, a fresh gate's instance-local `memoryDirtyRef=false` can skip the old-memory clear. ([gate](P2_inputs/candidate/src/services/PersistedQueryCacheGate.tsx)) But without an actual supported producer/call chain, no concrete customer exposure has been established from this scenario in P2 product behavior. This is the previously recorded cold-remount qualification, now sharpened by product-call-graph inspection—not a product blocker. ([original C qualification](FINDINGS.md))

**Class C action:** record the narrower claim; do not generalize P2 to arbitrary out-of-band credential mutation; continue. S6-A-01 remains closed for its concrete orphan continuation/subscription harm, S6-A-02 remains closed, and S6-A-P2-B04 alone still blocks the required identity suite until P3's scoped correction is reviewed. ([P2 findings](P2_FINDINGS.md))

No candidate bytes, tests, runtime, validation criteria or prior seals were changed.
