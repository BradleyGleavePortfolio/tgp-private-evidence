# S7-3′ G2 B/drain — reviewer B SUCCESSOR, same-review attestation of the actual committed head, environment, gates and filled PG binding

Successor reviewer B (EXEC-cf8ff737); not the author of `B_DRAIN_REVIEW_B_V4.md`; inherits that review question only.
Requested route Claude Fable 5.1 / High — no runtime telemetry observable to me; not claimed. Read-only; no gate,
install, PG or candidate write; sole writes `execution/cf8ff737/b-review-b/**`. Peer-A unread. No source re-audit:
the eleven blobs are byte-identical to the SOURCE_GRANTABLE v4 set (note 01 §1), so the v4 disposition carries.

Every row below was re-derived from the live repository / real artifacts, not copied from the builder's log, unless
marked "(builder receipt)".

## 1. Committed head

| Item | Observed | Expected | Result |
|---|---|---|---|
| HEAD | `75a2863bf79a44f84050406d6878ec9a87f4053e` | new (no predecessor commit existed) | recorded |
| Tree | `f4922ca070e887fb7f613ce955b12621b5c33156` | v4 granted tree | match |
| Parent | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` (single parent) | accepted C1 head | match |
| Author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>` 2026-09-24T15:04:10Z (`git cat-file -p HEAD`) | G05 identity, no co-author trailer | match; no trailers |
| Message | `git log -1 --format=%B` == `remainder/commit-message.txt` (sha256 `fca0b6aa…d9f6`, == handoff §7) modulo trailing newline | exact approved text | match |
| Committed blobs | `git ls-tree -r HEAD` for the 11 paths == `frozen-v4/BLOBS.git-sha1` (modes incl. 100755 bootstrap) | v4 pins | equal |
| base→HEAD | `--name-status` == `frozen-v4/NAME_STATUS.vs-base.txt`; `11 files changed, 2323 insertions(+)` | 11 A, +2323 | equal |
| Worktree after | `git status --porcelain --untracked-files=all` empty | clean | clean |
| Hooks at commit time | `.git/hooks/pre-commit` and `commit-msg` present, executable, lefthook-generated (32 `lefthook` refs each; sha `e5723334…`/`29f83d8e…`); `core.hooksPath` unset | genuine tracked Lefthook 2.1.9 hooks, standalone repo | genuine |
| Hook execution | `05-commit.stderr`: pre-commit summary ✔️ prod-readiness-quick 0.05 s, banned-cast-tokens 0.32 s, prettier 2.06 s, eslint 3.23 s, tsc 47.02 s; commit-msg ✔️ no-ai-tokens; `05-commit.rc` = 0; no `--no-verify`/`LEFTHOOK=0` (remainder L43 refused bypass env) | hooks actually ran | ran |
| Portable | `remainder/bundle/s7-b-drain-75a2863b….bundle` verifies (`git bundle verify` okay; requires `a0ea1bea`), patch + `BUNDLE.sha256` | preserved | preserved |

## 2. Environment applicability (the material inputs G09 binds to)

Environment receipt `env-recovery/logs/04-environment-receipt.txt` and reassertion `remainder/logs/01-env-reassert.txt`
(builder receipts, produced by the fail-closed scripts I read pre-run in note 02):

- `node_modules/.package-lock.json` SHA-256 `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` — equals the accepted C1 record and the runner constant `EXPECT_NM_LOCK_SHA`.
- `.prisma/client/index.d.ts` SHA-256 `bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5` — equals accepted C1 and `EXPECT_NM_CLIENT_SHA`; engines hash `c2990dca…` asserted by script (stage 2 passed).
- 649 entries / 717M — same shape as the RC71-verified copy. Tracked tree stayed `87798e74…` through install and generate (script L40/L53 passed).
- Prettier: target `execution/cf8ff737/b-drain/tooling/prettier-3.9.6/node_modules/prettier/bin/prettier.cjs`, sha `6e922134…906e`, package and CLI version 3.9.6 (closes the launcher-hash ambiguity, note 02 C-1).
- Node v20.20.1 / npm 10.8.2; lefthook 2.1.9.

Decision: the rebuilt environment reproduces every recorded C1 pin, so gate and hook results run in it are evidence for
this head under the same inputs as the accepted C1 acceptance. This is an actual-necessity rehydration, not a re-buy.

## 3. Gates (remainder/logs/04-*.log, rc lines; order and bounds per phase-A grant)

| Gate | Result |
|---|---|
| `tsc --noEmit -p tsconfig.json` | rc=0 (15:03:09→15:03:56Z) |
| `eslint --no-warn-ignored --max-warnings 0` on the 8 TS paths | rc=0 |
| `prettier --check` on the 8 TS paths | "All matched files use Prettier code style!" rc=0 |
| `node scripts/check-r75.js --mode=staged` | "OK — no positive token change" rc=0 (policy `.github/r75-policy.json`, index measured) |
| `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts --runInBand` | 2 suites passed, **42/42 tests passed, 0 skipped**, 9.7 s, rc=0 |

The v4 hunk (fresh-fake zero-retry case; B-4/B-BD-FRESH-FAKE) is inside the passing unit spec; the one-attempt
semantics I traced in v4 §2 are now confirmed by the real gate. Gates ran against staged tree `f4922ca0…`
(`03-staged-tree.txt`) and the commit re-asserted the same tree immediately before `git commit` (remainder L80).

## 4. Filled PG binding — `execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh`

- Sealed template untouched: `fixture-proposal-v3/PROPOSAL.v3.sha256` all OK; template sha `25eb6837…1c3c`.
- Filled sha `a64d24de…b6b9`. My own `diff` template↔filled = exactly 10 changed lines = the 5 placeholder lines;
  no `__V3_`/`__B_FIXTURE` left; `bash -n` OK; `D` unchanged (`…/fixture-proposal-v3/binding`).
- Pins: `EXPECT_HEAD=75a2863b…053e` (== live HEAD), `EXPECT_TREE=f4922ca0…` (== `HEAD^{tree}`),
  `EXPECT_SPEC_BLOB=9b31fd18…77ab` (== `HEAD:test/rls-g2-b-drain.spec.ts`, the live PG spec — correct, not the unit spec),
  `EXPECT_BOOTSTRAP_BLOB=b4503eef…4de6f` (== `HEAD:test/utils/g2-b-drain-bootstrap.sh`),
  `EXPECT_FIXTURE_SHA=4525f01d…9eb9` (== sha256 of the restored `b-fixture.sh`). Constants `EXPECT_NM_*` equal §2.
- Runner preconditions vs actual state: `W=worktrees/s7-b-drain` HEAD/tree/blob checks (L64–69) will pass; hook
  presence check (L73) will pass; S5 accepted-file pins (L76–79) were re-asserted unchanged by the remainder preflight.
  The template's "v3" comments are historical labels; the pins are v4/actual, as the grant states.

## 5. Findings

No A. No B. C only:

- **C-6 detached HEAD.** `git symbolic-ref HEAD` fails; `75a2863b` is referenced only by HEAD, the reflog and the
  verified bundle — no `refs/heads/*` or `refs/s7/*` ref points at it. Not a proof defect (bundle + patch preserve
  it; runner binds by hash). Cheap hygiene for the builder when next writing: `git update-ref refs/s7/b-drain-75a2863b 75a2863b…`
  (a ref, not a product edit). No cycle.
- C-3 carried: `prod-readiness-quick` ✔️ is a `[ -x ]` no-op (script untracked at this tree), not readiness evidence — same qualification as the C1 seal.
- C-1/C-2/C-4/C-5 from note 02 stand as recorded; none materialised into a stop.

## 6. Verdict (reviewer B, same review)

**ACTUAL-HEAD ATTESTED.** Head `75a2863bf79a44f84050406d6878ec9a87f4053e` = exact v4 tree on accepted C1 base, Bradley
author/committer, genuine tracked hooks executed, all five affected gates rc 0 in an environment reproducing every
recorded pin, filled binding substitution-only and consistent with the head. Local implemented+tested+reviewed for the
DB-free scope; not landed/deployed/product-accepted; the live PG spec `rls-g2-b-drain.spec.ts` remains **unrun**.

**Single PG proof — GRANTABLE from the binding/source side**, conditional only on environment presence: `/home/user/pg17`
(`PG17_HOME`, `DIST`, `PROVENANCE.txt`) and `/usr/bin/psql` do not exist in this runtime, so `b-pg-proof.sh` would
currently fail closed at PRECONDITIONS (postgres/initdb sha pins `23cd1748…873a` / `b7db9bc2…882a`). Minimum: rebuild
PG 17 by the already recorded pinned recipe (`c1-pg/ENVIRONMENT_RECOVERY.md`), require those two hashes, then one
`timeout -k 30 3600 bash execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh` under the canonical slot on a
separate parent grant. No further review step is needed between PG rehydration and the run beyond the runner's own
hash preconditions; I will bind the PG results afterwards (same review, not a new track). BIND-4 (record the live
`PROVENANCE.txt` line in the receipt) and BIND-5 (data dir retained, marker-guarded destroy needs its own grant) from
`B_DRAIN_REVIEW_B_BINDING.md` remain as recorded.

Observation time 2026-09-24 ~15:10Z; private evidence at main `50684d66…` as mounted.
