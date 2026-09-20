# S6 R2 — independent audit B (T4)

**Status: COMPLETE — bounded verdict issued (see §9).** Read-only review; no source, shared-ref, hosted, native or install action taken. Combined validation packet `execution/s6-final-r2` was checksum-verified by me (27/27) and the parent's completion message (2026-09-20 15:42 PDT) confirmed the same frozen `REPORT.md` sha256 `36dbd19f…3470bc25`, published as `remediation/s6-r2/combined/revision-1`; the packet I audited is the frozen one. Verdict in §9 is final for lens B.

## 1. Identity and independence

| Item | Value |
|---|---|
| Requested reviewer | Claude Fable 5 High (lens B) |
| Actual reviewer identity | **Not independently verifiable from inside the session.** I can only assert I am the model instance that the dispatch tool routed; no in-session mechanism proves the model name/tier. Treat "Fable 5 High" as the *requested* routing only. |
| Independence | Did not read, and did not communicate with, the current S6 R2 reviewer A. Read both permitted R1 reports (`audits/s6-r1/a/revision-2`, `audits/s6-r1/b/revision-1`), both fixer packets (`remediation/s6-r2/{pairing,export}/revision-1`), `COMBINED_STATUS.md`, `EXPORT_REPAIR_DISPATCH.md`, `AGENT_RULES.md` (G01–G20), `EXECUTE.txt`. |
| Writes | Only under `execution/audits/s6-r2/b/` (this report, `probes/`, `SHA256SUMS`). |

## 2. Exact binding (verified by me, not copied)

| Item | Value |
|---|---|
| Frozen worktree | `/home/user/workspace/worktrees/s6-final` (git-dir `repos/mobile/.git/worktrees/s6-final`) |
| Head | `55db31a0696ebd07d0cb9abb18ffd31dce29457d` |
| Tree | `130ef9bfdcdbc038b87466529f5980e759f3451a` |
| Parents | `eaccaba98bc4400a0341bcd80409ab317bc85856` (pairing lane, tree `4e27b472…`) + `d7079265ea1263a1af6cd9cd132fc18dcb1793d9` (export lane, tree `402a7425…`) |
| Lane base | `60975b51bd617bbfaa091ce76e57d16945298f82`; public main `a5933fd6de5616493de75f0db907098b149b955c` is an ancestor |
| Composition check | `git merge-tree --write-tree eaccaba98 d7079265e` independently reproduces tree `130ef9bf…` — the merge commit carries **no** content beyond the two lanes. Lanes touched disjoint files. |
| Clean state | `git status --short --untracked-files=all` → 0 lines (the `node_modules` symlink to `worktrees/s6/node_modules` is excluded via local `.git/info/exclude`, which is an honest exclusion, not a suppression of a tracked change) |
| Identity | Merge commit author = committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers. Lineage `a5933fd6..55db31a`: 7 preserved PR commits by `BradleyGleavePortfolio <264851314+…@users.noreply.github.com>` (S6-A5 — parent landing decision, not re-litigated) + 7 by `Bradley Gleave`. |
| Diff scope | `60975b51..HEAD`: 5 files +540/−38. Cumulative `a5933fd6..HEAD`: 35 files +3813/−70. |
| Dependency determinism | `package.json`/`package-lock.json` byte-identical to the `npm ci` source tree at `worktrees/s6`; lockfile root declares `@babel/core ^7.29.0` (resolved 7.29.0), `zod ^3.25.76`, `@types/node ^25.9.1`; `react-native-mmkv` has 0 lockfile occurrences. |

## 3. Reviewed scope and actions

Cumulative source review at the frozen head: `src/hooks/useExtensionPairing.ts` (508 lines, full), `src/storage/importPairingMirror.ts`, `src/screens/coach/ImportDataScreen.tsx` (peek effect), `src/components/coach/ExtensionPairingPanel.tsx`, `src/hooks/useCurrentUser.ts`, `src/lib/userCache.ts`, `src/storage/mmkv.ts` (HEAD vs `a5933fd6`), `src/navigation/RootNavigator.tsx` `bootstrapAuth`, `src/services/authActions.ts` (sign-out sweep, `resolveSigningOutUserId`), `src/utils/authEvents.ts`, LoginScreen login path, `src/config/__tests__/featureFlagsReleaseInlining.test.ts`, `src/config/__tests__/declaredDependencies.test.ts`, `src/hooks/__tests__/useExtensionPairing.test.tsx`, `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx`, `metro.config.js`, `package.json`, `package-lock.json`, installed `metro@0.84.4` `collectDependencies.js` (`isOptionalDependency`, registry demotion at line 651).

Bounded offline probes (Node only, in-memory AsyncStorage, no installs, seconds of CPU): `probes/probe1-usercache-shim.cjs` (+ `.log`), `probes/probe2-usecurrentuser-shim.cjs` (+ `.log`, includes a CONTROL run).

Packet verification: both fixer packets' `SHA256SUMS` and `BUILDER_SHA256SUMS` verify (54/54, 52/52; 41/41, 39/39). Combined packet `execution/s6-final-r2/SHA256SUMS` verifies 27/27; spot-checked `04-jest-full.log` (308/308 suites, 3839/3839 tests, natural exit), `04-jest-full.STAMP` (HEAD/TREE/clean/`MMKV_STUB_PRESENT=no`), bundle sha256s (`43c981f2…`, `0aa77c1f…`), `00-merge.log` (parents/identity).

## 4. NEW MATERIAL FINDING

### S6-B2-1 — Identity cache is unreadable on the shim storage path; the R2 hydration gate therefore never opens in any real build (inherited baseline defect with a direct, new S6 consequence)

**Facts (source-deterministic, probe-confirmed):**

1. `react-native-mmkv` is undeclared (removed in `0dbc0a6`, 2026-05-09; 0 lockfile occurrences) and the export lane's guard now pins it as *optional undeclared*. In every build produced from this tree `prefsStorage`/`cacheStorage`/`secureStorage` are `AsyncStorageShim` instances. The export lane's own runtime probes record this: `isMmkvAvailable(): false`, `prefsStorage.getString sync: undefined` (`export/revision-1/logs/17-…`, `18-…`).
2. `AsyncStorageShim.getString()` **always returns `undefined`** (`src/storage/mmkv.ts:114–117`, unchanged from baseline; documented in `docs/offline-architecture.md`).
3. `src/lib/userCache.ts` reads identity only via the sync `prefsStorage.getString('auth.user_data')` (`readUserCacheSync` L34, `readUserCache` L49), then falls back to the legacy AsyncStorage key `user_data`, and on finding it **writes `prefs:auth.user_data` and deletes the legacy key** (L63–64). `setUserCache` writes only the shim key. Nothing ever reads the shim key back (there is no `getStringAsync` fallback).
4. Probe 1 (`probes/probe1-usercache-shim.log`): after `setUserCache(user)` → `readUserCache()` = `null`, `readUserCacheSync()` = `null`. With a legacy `user_data` present → first read returns the user and deletes the legacy key; second read = `null` (one-shot destructive migration).
5. Probe 2 (`probes/probe2-usecurrentuser-shim.log`): the **real** `useCurrentUser()` + real `userCache` + real `mmkv.ts` (module absent) rendered with `react-test-renderer` after `setUserCache` observes `[null]` on mount and `[null]` after `authEvents.emit('login')`; `IDENTITY RESOLVED = false`. **CONTROL** run with an in-memory `MMKV` class substituted: `[null, "coach-A"]`, resolved = true — the harness is sound and the defect is specifically the shim's sync-read gap.

**S6 consequence (new at R2, introduced by `d1c6198`/`eaccaba`):** `useExtensionPairing` now gates hydration and `start()` on a resolved `userId` (`hydratedRef`, L158/L288–289/L439/L463). With `useCurrentUser()` permanently `null` in a shim build, `start()` is deferred forever, the mirror is never read, and `ExtensionPairingPanel` renders the `idle`/`minting` branch indefinitely ("Preparing your secure pairing code…", `testID pairing-minting`, L107–116) with no cancel, retry, timeout or error state. `ImportDataScreen`'s restore peek (gated on `userId`) never runs either. The R1 head at least minted blind (working code, no restore); the R2 head fails closed into a **dead panel** on the real storage path when `extensionImport` is ON. The pairing fixer's premise — "inside CoachNavigator the cached user is always present… the wait is bounded by one storage read" — is false for the shim path: the read is not repeatable.

**Baseline consequence (outside the S6 lane, must be routed):** `bootstrapAuth` in `RootNavigator` also decides auth state from `readUserCache()`. Source and probe indicate that an email/password login (`setUserCache` → `authEvents.emit`) is followed by a `null` read → `unauthenticated`, and that Google/Apple flows (which write legacy `user_data`) survive exactly one bootstrap. Every `readUserCacheSync` consumer (`queryClient.ts`, `foodLogQueue.ts`, `sync-engine.ts`, `offline/database.ts`, `authActions.ts:220` per-user wipe, `blockedUsersStore.ts`) sees `null` in a shim build. This is **source-derived plus Node module/hook probe evidence, not device-verified**; I am not claiming observed device behaviour. It has been invisible because (a) no release bundle of `main` could be produced from `0dbc0a6` (2026-05-09) until the export lane's fix — the double `require` made every export fail — and (b) every test touching this path mocks `lib/userCache` or `storage/mmkv` with a working sync `getString` (`authActions*.test.ts`, `syncEngine.test.ts`, `foodLogQueue.test.ts`, `queryClient.*.test.ts`) or mocks `useCurrentUser` outright (both S6 test files). No test exercises the real composition.

**Boundary affected:** storage/identity (T4). Not customer-visible for the *pairing* journey until `extensionImport` is enabled (hard-false default, confirmed in both cold bundles), but the identity-cache defect itself is baseline-wide and is unmasked precisely by the S6 export fix making the app buildable again.

**Smallest follow-up options (for the parent to route; I recommend both):**
- Root fix (storage/identity owner, T4, ~10 lines): make `readUserCache()` fall back to `await prefsStorage.getStringAsync(MMKV_KEY)` when the sync read is empty, before the legacy migration; and make the shim path's `readUserCacheSync` consumers explicit about the limitation (or hydrate the shim's in-memory mirror at boot). Add one test that uses the **real** `userCache` + real shim (no `storage/mmkv` mock) and asserts `setUserCache` → `readUserCache` round-trips.
- S6-scoped hardening (pairing owner): the panel must not spin forever when identity does not resolve — bound the hydration wait or surface an honest failure with retry (G02). Remove/qualify the "always present / one storage read" claim in the hook comments and the packet.

## 5. Dispositions of inherited findings (by stable ID)

| ID | R1 statement | Disposition at `55db31a` | Evidence |
|---|---|---|---|
| S6-A1 / S6-B-1 | Regex flag-guard false positive | **FIXED, sound for its purpose.** AST guard (`@babel/core` `parseSync` + `traverse`) counts only computed `process.env[...]` reads; control tests prove comments cannot trip it and real computed reads are counted. Residual (nonmaterial): `process['env'].X` and aliased `const e = process.env` would evade both the guard and Expo's inliner, but the same suite's release-transform assertions (no `process.env.EXPO_PUBLIC_` residue; empty-env evaluation yields hard-false) catch the *consequence* for the keys the reader accepts. | `featureFlagsReleaseInlining.test.ts:104–128, 163–190`; both cold bundles: computed reads 0, reader residue 0 |
| S6-B-2 | `@babel/core` imported by a test but undeclared | **FIXED.** Declared `^7.29.0` in devDependencies; lockfile root entry present; lock byte-identical to the `npm ci` tree. | `package.json`, `package-lock.json`, §2 |
| S6-A2 / S6-B-3 | Restore unreachable (hydration/`useCurrentUser` timing) | **PARTIALLY FIXED — fixed under an MMKV-present assumption that this same candidate proves false.** Hook logic is correct for a resolving identity (null→id, A→B, A→null, late settles all reviewed; tests at `useExtensionPairing.test.tsx:810–1426` are well-targeted). On the real shim path identity never resolves → **S6-B2-1**. Claim "FIXED" in the pairing packet is an overclaim. | §4; probes 1–2 |
| Parent identity/epoch review (ownerRef, mintEpochRef, `eaccaba`) | Same-mount identity change, stale settles | **SOUND.** `stale()` covers unmount/status/epoch/owner; `finally` releases the guard only for the current epoch; A's late `/pair/init` discarded and compensating `clear` after sign-out is correct; mirror uses raw AsyncStorage (not the shim) so it is unaffected by S6-B2-1; sign-out prefix sweep unchanged. Observation (nonmaterial): `pendingStartRef` is not reset on the restored path (L436–448) — only effect is a redundant auto-mint intent on a later same-mount identity change, which the panel would do anyway. | `useExtensionPairing.ts:405–470`, `authActions.ts:51–78, 195` |
| S6-A3 | Hosted EAS flag inventory UNKNOWN | **UNCHANGED, still UNKNOWN.** No hosted access in any lane or this audit. Not a merge blocker; a release/activation gate. `eas.json` pin deliberately not added (EAS env overrides) — reasonable. | lane reports |
| S6-A4 / S6-B-6 | Cold export never succeeded on main | **FIXED at the combined head.** Authentic cold exports exit 0 with flag ON (`index-90dbc33d…`, sha `43c981f2…`) and flags unset (`index-75c06ea7…`, sha `0aa77c1f…`); `react-native-mmkv` appears once, inside the Metro-optional `try{require}`; flag table shows `"true"` vs `void 0` respectively. Root cause independently confirmed in `metro@0.84.4` `collectDependencies.js:397–424` (try-block rule) and `:651` (registry demotion when any occurrence is non-optional). The new guard mirrors Metro's rule correctly (stricter: promise-chain optionality treated as unguarded — fail-closed) and asserts exactly one guarded site. | `s6-final-r2/logs/05–08`; `export/revision-1/logs/12,14,17,18,22` |
| S6-A5 | Lineage author identities | Parent decision; unchanged; merge commit identity clean. | §2 |
| S6-A6 / S6-B-7 | Nonmaterial | Unchanged. | — |
| S6-R2-NEW-1 | mmkv export failure on main | **FIXED** (same evidence as S6-A4). | — |
| S6-R2-NEW-2 | Full jest delayed exit (~5 min) | **UNCHANGED, pre-existing.** Combined run: tests done in 119 s, process exited naturally at 22:37:07 (timeout not fired). Not a correctness blocker; hygiene item. | `04-jest-full.log/.STAMP` |

## 6. Additional observations (nonmaterial unless noted)

- Test suites for the hook and screen mock `useCurrentUser` (switchable id) — appropriate for hook logic, but they do not prove composition with the real identity source (root of the S6-B2-1 blind spot).
- Mirror module: version/shape/user-mismatch discard is fail-closed and logged; `expiresAt` never compared locally; server remains sole expiry authority. Restore shows `waiting` for one poll round-trip before a server `expired` is known — honest per Rule 18 ("waiting", not "live").
- Restore is only reachable when the coach re-enters `ImportDataScreen` (no navigation-state persistence) — acceptable if not overclaimed.
- `go('minting')` fires `void clearImportPairingMirror(uid)` before the awaited write; AsyncStorage's serial queue preserves order — acceptable.
- Export lane residual: deterministic `encryptionKey: tgp-mmkv-enc-${namespace}` contradicts the "random Keychain key" comment — dormant while MMKV is absent; note for the storage owner.
- `metro.config.js` has no `react-native-mmkv` alias (only screenshots stub and web `expo-sqlite` stub) — no hidden resolution path.
- `validate:config` warnings (null Play Store URL, assetlinks placeholder) pre-existing; release gate, not merge gate.

## 7. Evidence gaps and unexplained failures

- **Combined packet binding:** `execution/s6-final-r2/SHA256SUMS` sha256 `ea5ee9d7b9562aaf03e1560360caca38905e64ae7fc1c8e52a674bf5735976a4`; `REPORT.md` sha256 `36dbd19ff358d76b2dcfae79f7abde1c20d0393a52e2402ba451c86d3470bc25`. If the parent's frozen packet differs, this verdict's §9 packet-dependent rows must be re-checked.
- No device/emulator run of any bundle in any lane or this audit; all runtime claims are Node-module or hook-render level.
- Hosted EAS environment inventory: UNKNOWN (no access).
- No unexplained failures encountered. Probe 2's two harness errors (`act` binding, sentry stub path) were harness setup issues, fixed and re-run; both runs are in the log.

## 8. What is and is not established

| Claim | Status |
|---|---|
| Written | yes (`55db31a`) |
| Tested (lint/tsc/full jest/cold exports at exact head) | yes, packet-verified |
| Audited | this report (lens B); lens A unknown to me |
| Merged / deployed / enabled / customer-accepted / production-proven | **no** — none claimed, none observed |
| Pairing restore works in a real build | **NOT established; source + probe indicate it cannot, see S6-B2-1** |

## 9. Bounded verdict

- **Export lane (`d7079265` content):** CLEAR for merge on its own terms. The optional-require repair, the Metro-shape guard, and the cold-export proof are correct and well-evidenced. It does, however, make the app buildable for the first time since 2026-05-09, which is what exposes S6-B2-1.
- **Pairing lane (`eaccaba` content):** hook logic is correct and well-tested for a resolving identity; **NOT CLEAR as "restore fixed"**. The acceptance row "restore reachable on the real screen/panel path with honest states" is not met in the real (shim) build; the flag-ON panel degrades to an unbounded spinner (G02 violation when enabled).
- **Combined head `55db31a` / tree `130ef9bf`:** **NOT CLEARED for an unqualified S6 acceptance.** Under G11 a material correctness finding blocks the affected claim. Merge *eligibility* of the code as a flag-OFF, default-dark change is a parent decision I do not oppose provided (i) the S6 packet's "restore FIXED" claim is downgraded to "fixed contingent on identity resolution; blocked by S6-B2-1", (ii) S6-B2-1 is filed against the storage/identity boundary as a release blocker for *any* build from this tree, and (iii) `extensionImport` is not enabled anywhere before both follow-ups in §4 land with a real-composition test. Release readiness and activation are separately NOT established (S6-A3 unknown, no device evidence, S6-B2-1).
- **Smallest next slice:** T4 storage/identity fix to `readUserCache` (async fallback) + one un-mocked round-trip test; then S6 bounded-wait/failure state in the hook/panel; then re-run the S6 restore test with the real `useCurrentUser`.

## 10. Files

`REPORT.md`, `probes/probe1-usercache-shim.cjs`, `probes/probe1-usercache-shim.log`, `probes/probe2-usecurrentuser-shim.cjs`, `probes/probe2-usecurrentuser-shim.log`, `SHA256SUMS` (this directory). Not published independently; parent publishes.
