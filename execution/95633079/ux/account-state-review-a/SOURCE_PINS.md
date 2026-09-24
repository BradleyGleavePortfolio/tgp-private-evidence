# UX-01 account-state review A — source pins (independently re-derived)

Reviewer: independent T4 reviewer A (nonbuilder). Requested route Claude Fable 5 / High (requested setting, not observed runtime identity). Observation time 2026-09-24T06:38Z (2026-09-23 23:38 PDT).

Method: read-only `git` plumbing in `worktrees/ux01-state` and `worktrees/ux07-mobile`; `sha256sum` on packet files; reading of sibling read-only `node_modules` (ux07-mobile) for library typings only. Nothing installed, typechecked, tested, hooked, browsed, probed, committed or written outside `execution/95633079/ux/account-state-review-a/**`. Peer reviewer B's area (`account-state-review-b/`) was not opened.

## Worktree and tree pins (all match the packet)

| Item | Packet claim | Observed |
|---|---|---|
| HEAD (accepted S6 successor) | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` ✔ |
| HEAD tree | `acb41c2baab6e856573d86e02135430c3304828b` | ✔ |
| HEAD parent | `d51a191098f483cea9abec6cc7e9f3beffd18c06` | ✔ |
| HEAD author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com> | both fields ✔; subject `fix(query-cache): identity-bound persisted query cache gate with retire/drain/clear ordering` |
| `git write-tree` (staged index) | `a33cb8919495ed24e30623188dbb9f59c67df8bd` | ✔ |
| `git diff --cached HEAD \| sha256sum` | `d695f8d8216847b2df1aa1b837821c05d3e1e35d474316ed335a459c9b7e0085` | ✔ |
| `UX01_ACCOUNT_STATE.patch` sha256 | same | ✔ (binary.patch byte-identical ✔) |
| Branch | `ux01-account-state` | ✔; no remotes configured |
| Working tree vs index | clean | `git diff --stat` empty; no untracked files ✔ |
| Active hooks | none | `.git/hooks` non-sample count = 0 ✔ |
| `git diff-tree -r acb41c2b a33cb891` | 6 paths | 6 rows, blobs below ✔ |

## Blob pins (base → candidate)

| Status | Path | Old blob | New blob | Lines | sha256 of new blob content |
|---|---|---|---|---|---|
| A | `src/storage/importOfferDecision.ts` | — | `83118fff2c7d611b956483f0a7471e5811d024ac` | 163 | `755b46d2754f44c8841f1c4ce263b5ddf18fed431c1191a411a5a22d1c8521f9` |
| A | `src/hooks/useImportOfferDecision.ts` | — | `ddede7266e3146ecfb5507b75983f565722966ee` | 168 | `cb91e9a7ced90285fe19e6cb957e7aed0059b2b1da6a860f411511060f4576b6` |
| M | `src/services/authActions.ts` | `8bb68bff2bfd110af3d34f8cbb7af2475900ebc3` (= base tree blob ✔) | `ceb33c45685ce49e98205abf8e268d65aa0a0333` | 421 (+9/−0) | `ceb4fd8fa3347aa77f06084dd431d9238b37d8123a0a2c00b664e73a9abad792` |
| A | `src/storage/__tests__/importOfferDecision.test.ts` | — | `004e520eb24c73fb75ebaadcd1b893d012a2d059` | 206 | `5b9699560d4edf399271715b837336b0fa8083f558381ca309695fb1a663c424` |
| A | `src/hooks/__tests__/useImportOfferDecision.test.tsx` | — | `99cd6e184f7847fa336672544a83e34de7ff558a` | 461 | `d5af62e671ce741d620bfb0fe201a47391b939ea8e84843a0038c2ed409c2e43` |
| M | `src/services/__tests__/authActions.test.ts` | `0aa452aaf53a6c5f31d3418094a1ea4ff6468ee6` (= base tree blob ✔) | `fb3ac27c1e4f0e1a541b9f682767451364f305c8` | 364 (+32/−0) | `b3ced270e63cdb8384e6e79db5cecf8050fa468f862226c09adc02a692bdcce0` |

Totals: 6 files, +1039/−0 (`git diff --cached HEAD --stat`). Source +340 (163+168+9), tests +699 (206+461+32).

## Sibling disjointness

`worktrees/ux07-mobile` HEAD `df0ad112529afcd9bfdf084e9930c90ee0bfffb3`, HEAD tree `377e4b7a497a69c2f1e68236a3f1527913c7429b`. `git diff-tree -r --name-only acb41c2b 377e4b7a` = 12 paths, all `src/screens/coach/**`. Intersection with this delta's 6 paths: 0 ✔.

## Governing and canonical inputs read (sha256)

| File | sha256 |
|---|---|
| `agent-context/AGENT_RULES.md` | `edd63115537049e41ada062d35c74b4a1224f1bf784272ca45cf6c61398e173c` |
| `checkpoint-private/execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md` | `e4bb28667ac2c57d62009317299e61dbd7e151575e6a8693129313f71f083218` |
| `resume-evidence/ux-planning/OFFICIAL_UX_JOB_AND_PR_MAP.md` (revision 3) | `1e9bd28b137504212cac49bb26ec9bba91958fa1774c5156ede80aeba59b1dec` |
| `resume-evidence/ux-planning/journey/CANONICAL_MOBILE_JOURNEY_SPEC.md` | `3bc4a929ec7b5f69a190de32640c6616dda5753e86230244455b9990b2071471` (matches `journey/MANIFEST.sha256`) |
| `resume-evidence/ux-planning/journey/STATE_AND_EDGE_CASE_MATRIX.md` | `b386ba4a38318c4299f6f0b774f0541bf4c40a64abd844ce826853931aeff78a` (matches manifest) |
| `resume-evidence/ux-planning/journey/CONTRACT_QUESTIONS.md` | `d7ae51c2cc505159549a77fb877fb61981842bdf024607a03e46a3cd48eaf714` (matches manifest) |
| `execution/95633079/ux/account-state/UX01_ACCOUNT_STATE_HANDOFF.md` | `8ef857453776a613c2c60dd73a26c010e20d5cac18ded0206329ee79ed0263c9` |
| `execution/95633079/ux/account-state/EXACT_PINS.md` | `49d35cef398b27af2a0d367aa8a19540b99b3140a34e25db7fc98b1d756062c4` |
| `execution/95633079/ux/account-state/FREEZE_RECEIPT.md` | `7a4a219216083ccded37c077fde2db930c70ddec173d6cfb7206f3e39831ad4f` |
| `execution/95633079/ux/account-state/UX01_ACCOUNT_STATE.patch` | `d695f8d8216847b2df1aa1b837821c05d3e1e35d474316ed335a459c9b7e0085` |

## Base-tree context files read (unchanged by the delta, at `acb41c2b`)

`src/storage/importPairingMirror.ts`, `src/hooks/useCurrentUser.ts`, `src/hooks/useExtensionPairing.ts` (identity/flag handling lines), `src/utils/logger.ts`, `src/config/featureFlags.ts` (L68–75, L419), `src/navigation/RootNavigator.tsx` (auth-change bootstrap L334–338), `src/utils/authEvents.ts`, `jest.setup.js`, `package.json` (jest block, dependency versions), `.eslintrc.js`, `.github/workflows/ci.yml`, `.env.example` L142, existing tests `useExtensionPairing.identityWait.test.tsx`, `useExtensionPairing.test.tsx`, `importPairingMirror.test.ts` (technique parity only).

## Library facts read from sibling read-only install (`worktrees/ux07-mobile/node_modules`)

- `@react-native-async-storage/async-storage` 3.1.1: `./jest` export → `src/jest/AsyncStorageMock.ts`; methods are instance arrow-function properties on a class (`getItem = async (...) => ...`), so `jest.spyOn(AsyncStorage, 'getItem')` replaces an own property and `mockRestore()` restores it.
- `@testing-library/react-native` 14.0.0: `renderHook(...) → Promise<RenderHookResult>`, `rerender(props) → Promise<void>`, `unmount() → Promise<void>`, `cleanup() → Promise<void>`, `waitFor` awaits a promise-returning expectation (`wait-for.js` L112–116).
- `react` 19.2.3; `eslint-plugin-react-hooks` 4.6.2 (no render-time ref rule).
