# Exact candidate binding freeze receipt — UX-01 account-scoped offer-decision state

Source-only packet for two independent T4 reviews. No npm/install, no runtime, no test run, no typecheck, no build, no commit, no push, no browser, no deploy were performed. Everything below is derived from git plumbing on the staged index of `worktrees/ux01-state`.

## Staging performed

From `worktrees/ux01-state` (branch `ux01-account-state`, HEAD `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9`, no commit made):

```
git add -A src          # exactly the 6 paths listed below (4 A, 2 M); nothing else was dirty
git write-tree          # candidate tree object; no commit object created
git diff --cached HEAD          > UX01_ACCOUNT_STATE.patch
git diff --cached --binary HEAD > UX01_ACCOUNT_STATE.binary.patch
```

`git status --short` after staging showed exactly 6 paths. HEAD remained `bc7b4e96…` throughout. `ls .git/hooks` contains only `*.sample` files (no active hooks).

## Exact resulting tree

| Item | Value |
|---|---|
| Base commit (HEAD, unchanged) | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` |
| Base tree | `acb41c2baab6e856573d86e02135430c3304828b` |
| **Candidate tree (staged index, `git write-tree`, no commit)** | **`a33cb8919495ed24e30623188dbb9f59c67df8bd`** |
| Working branch | `ux01-account-state` |
| `git diff-tree -r --name-only <base-tree> <candidate-tree>` path count | 6 |

## Full changed-blob list (6 paths, base → candidate tree, full 40-char SHA-1)

| Status | Path | Old blob | New blob | Lines (+/−) | Origin |
|---|---|---|---|---|---|
| A | `src/storage/importOfferDecision.ts` | — | `83118fff2c7d611b956483f0a7471e5811d024ac` | +163/−0 | authored this session |
| A | `src/hooks/useImportOfferDecision.ts` | — | `ddede7266e3146ecfb5507b75983f565722966ee` | +168/−0 | authored this session |
| M | `src/services/authActions.ts` | `8bb68bff2bfd110af3d34f8cbb7af2475900ebc3` | `ceb33c45685ce49e98205abf8e268d65aa0a0333` | +9/−0 | narrow edit: 1 import line + 1 entry (with comment) appended to `PER_USER_KEY_PREFIXES` |
| A | `src/storage/__tests__/importOfferDecision.test.ts` | — | `004e520eb24c73fb75ebaadcd1b893d012a2d059` | +206/−0 | authored this session |
| A | `src/hooks/__tests__/useImportOfferDecision.test.tsx` | — | `99cd6e184f7847fa336672544a83e34de7ff558a` | +461/−0 | authored this session |
| M | `src/services/__tests__/authActions.test.ts` | `0aa452aaf53a6c5f31d3418094a1ea4ff6468ee6` | `fb3ac27c1e4f0e1a541b9f682767451364f305c8` | +32/−0 | 1 import block + 1 added `it(...)`; no existing test altered |

Total: 6 files, 1039 insertions, 0 deletions. Both modified files' old blobs equal the base tree's blobs (unaltered accepted-S6 starting point). No package/lock/flag/config/backend/nav/controller/screen path is touched. No donor (PR293/PR294) blob is consumed.

## Patch hashes

Combined patch = `git diff --cached HEAD` from the staged index (all 6 paths, base `acb41c2b` → candidate `a33cb891`):

| File | SHA-256 | Lines |
|---|---|---|
| `UX01_ACCOUNT_STATE.patch` | `d695f8d8216847b2df1aa1b837821c05d3e1e35d474316ed335a459c9b7e0085` | 1099 |
| `UX01_ACCOUNT_STATE.binary.patch` | `d695f8d8216847b2df1aa1b837821c05d3e1e35d474316ed335a459c9b7e0085` | 1099 |

The two files are byte-identical because the delta contains no binary blobs; both are kept so the packet shape matches the sibling presentation packet.

## Exact `authActions.ts` modification (the only edit to an accepted file's logic path)

```diff
@@ -20,6 +20,7 @@
 import { IMPORT_PAIRING_MIRROR_KEY_PREFIX } from '../storage/importPairingMirror';
+import { IMPORT_OFFER_DECISION_KEY_PREFIX } from '../storage/importOfferDecision';
@@ -89,6 +90,14 @@ const ASYNC_SIGN_OUT_PREFIXES = [
 const PER_USER_KEY_PREFIXES = [
   'fasting:scheduled_notification_id:', // FastingScreen — scheduled push id
   'macro_targets:', // useMacroTargets — per-user macro cache
+  // Per-coach Roman import-offer answer (UX-01 J0/J1), keyed
+  // `import_offer_decision:<userId>`. Non-secret and readable only under the
+  // owning coach's key, so — like macro_targets — only the signing-out coach's
+  // EXACT key is removed; a bystander coach's answer on a shared device is not
+  // clobbered. Sign-out clears this local answer only; it makes no claim about
+  // the desktop extension connection. Swept via the exported constant so the
+  // literal lives in one place.
+  IMPORT_OFFER_DECISION_KEY_PREFIX,
 ];
```

The accepted S6 sign-out ordering (retire → drain → clear, cache gate, `ASYNC_SIGN_OUT_PREFIXES` sweep, `PER_USER_KEY_PREFIXES` exact-key removal) is not reordered; only a constant array gains one element. `SIGN_OUT_PREFIXES` (the re-export of `PER_USER_KEY_PREFIXES`) has no other consumers in `src/` outside tests.

## Verification commands for reviewers (read-only)

```
cd worktrees/ux01-state
git rev-parse HEAD HEAD^{tree}            # bc7b4e96…  acb41c2b…
git write-tree                            # a33cb8919495ed24e30623188dbb9f59c67df8bd
git diff --cached --raw HEAD              # 6 rows, blobs as tabled above
git diff --cached HEAD | sha256sum        # d695f8d8…7e0085
```
