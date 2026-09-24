# S7-3′ G2 B/drain — reviewer B SUCCESSOR, continuation note 01 (exact restoration applicability + fresh-runtime obstacles)

Status: **PRELIMINARY**. No committed head, no gate receipts, no filled PG binding exist yet. This note only
(a) decides whether the existing reviewer-B v4 source verdict applies to the restored bytes and (b) names the
concrete environment/binding obstacles the fresh runtime introduces. It will be continued (same review) when the
parent relays the builder proposal and, later, the actual head/gate/binding receipts.

Identity: independent nonbuilder reviewer B **successor** (session EXEC-cf8ff737). I am not the reviewer who wrote
`B_DRAIN_REVIEW_B_V4.md`; I inherit that review question only. Requested route: Claude Fable 5.1, effort High. I have
no observable runtime telemetry confirming model or effort; I do not claim either was used.

Read-only against candidate and evidence. Writes confined to `execution/cf8ff737/b-review-b/**`. Not done: any edit,
gate, install, hook, commit, lock acquisition, PG action, peer-A report read, or re-audit of unchanged v4 bytes.
Inputs read: live `AGENT_RULES.md` (G01–G22), `execution/cf8ff737/SCOPE.md`, `DISPATCHES.md`, owner Safety ROI
doctrine (6c2a68ac), parent `B_DRAIN_V4_PHASE_A_GRANT.md`, prior reviewer-B `B_DRAIN_REVIEW_B_V4.md` +
`B_DRAIN_REVIEW_B_BINDING.md` (both verified intact via `REVIEW_B.v4.sha256` OK), `frozen-v4/*`, C1 environment
receipts (`c1-execution/07-environment-recovery-receipt.txt`, `03-prisma-*`, `05-prettier-tooling-npm-ci.log`),
original phase-A first-run logs (RC71), builder recovery receipts `execution/cf8ff737/b-drain/recovery/00–06`.

## 1. Applicability of the v4 SOURCE_GRANTABLE verdict to the exact restoration — APPLIES

Independently re-derived on the live worktree `worktrees/s7-b-drain` (no builder receipt trusted for these rows):

| Check | Result |
|---|---|
| HEAD / tree | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` / `87798e742c7b48f56b05e9b5c30efa877180a9b3` = frozen-v4 `BASE.txt`; HEAD author+committer Bradley (builder receipt 02); `.git/shallow` = `c23b9d9f…` (same graft as the C1 bundle origin) |
| 11 paths | `git hash-object` of each working file == `frozen-v4/BLOBS.git-sha1` sha; modes match (10× 100644, bootstrap `.sh` 100755). 11/11 OK |
| SOURCE.sha256 | `sha256sum -c` → 11/11 OK against the working tree |
| Tree id | tree object `f4922ca070e887fb7f613ce955b12621b5c33156` exists in the repo (builder temp-index `write-tree`, receipt 04); `git status`: 0 tracked modified, exactly the 11 untracked candidate paths |
| Material tracked inputs | `package.json`, `package-lock.json`, `prisma/schema.prisma` unchanged vs HEAD (`git diff --quiet`) — the candidate adds no schema/lock change |
| Frozen packets | `frozen-v4/PACKET.v4.sha256` all OK; `fixture-proposal-v3/PROPOSAL.v3.sha256` all OK at the restored original runner path; `b-fixture.sh` = `4525f01d…9eb9` |
| Prior reports | `REVIEW_B.v4.sha256` OK (the verdict I inherit is byte-intact) |

Decision: the v4 disposition (**SOURCE_GRANTABLE** for tree `f4922ca0…`, no open source A/B) was bound to exactly
these blobs on exactly this base with these tracked inputs; all are byte-identical. Per G09 the verdict is reusable
without any new source audit. Nothing in the restoration changes candidate behaviour. The ten v3-inherited grants and
the single v4 hunk trace stand as written. **No source re-audit is warranted and none was performed.**

## 2. Fresh-runtime obstacles (only concrete ones; classified)

### ENV-1 — accepted dependency donor absent (class **B**, execution-proof obstacle)

- Fact: `worktrees/s7-c1` does not exist; `worktrees/s7-b-drain/node_modules` is absent; the RC71-verified 649-entry
  copy (717M) lived only in the old runtime. No durable artifact holds `node_modules` (private evidence has only
  source bundles/tarballs). Node `v20.20.1` / npm `10.8.2` are present and match the grant.
- Consequence: no `tsc`, `eslint`, `jest`, `ts-jest`, `lefthook` binaries → grant steps "lefthook install", gates 1–5
  and the hooked commit cannot execute. Product bytes are unaffected. Blocked decision: phase-A gate/commit execution.
- Minimum closure (proposal for parent disposition; needs an explicit amendment because the grant literally says
  "no installation, generation"): repeat the **already-accepted documented C1 rehydration route** inside
  `worktrees/s7-b-drain` itself, hash-bound to the same preserved outputs:
  1. `npm ci --no-audit --no-fund --ignore-scripts --loglevel=error` from the unchanged committed lockfile (C1 = this
     HEAD) → require `node_modules/.package-lock.json` SHA-256 `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`;
  2. pinned `prisma 6.19.3` engine fetch (`prisma version`) → require engines hash `c2990dca591cba766e3b7ef5d9e8a84796e47ab7`
     (libquery `a2924eab…`, schema-engine `5d42b181…` as in `03-prisma-engines.txt`);
  3. `prisma generate` against the **base** `prisma/schema.prisma` (unchanged vs HEAD; the candidate has no schema path,
     so this is the accepted C1 generate, not a "candidate generate") → require `.prisma/client/index.d.ts` SHA-256
     `bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5` (grant already excuses whitespace-normalised
     generated schema as non-semantic; the `index.d.ts` hash is the binding one);
  4. assert tracked tree still `87798e74…` and the 11 blobs unchanged after install (install must not touch source).
  Equal hashes ⇒ the copied-environment evidence the runner pins (`EXPECT_NM_LOCK_SHA`, `EXPECT_NM_CLIENT_SHA`) remains
  applicable. Any hash miss = stop, report, no auto-fix (grant's first-failure rule).
- Why this is the minimum: it is one standard tool (`npm ci`) plus the pinned Prisma step, exactly what produced the
  accepted environment; no new framework, census, or control. Network reads are the same registry reads C1 made; no
  spending. The RC71 "recopy forbidden / full inode census forbidden" clauses were written for the copy route; with no
  donor they are moot — do not re-run an inode census against a donor that does not exist.
- Execution unlocked: `lefthook install` → gates 1–5 → hooked Bradley commit → filled binding copy (the whole existing
  stage-2 remainder), under the canonical slot.

### ENV-2 — external Prettier 3.9.6 tooling absent (class **B**, same proof; closes with ENV-1)

- Fact: `execution/e7d2385c/s5-continuation/tooling/prettier-3.9.6` does not exist in this runtime. Preserved manifests
  + provenance exist at `/tmp/tgp-private-evidence/2026-09-22/remediation/s3-composition-prep/request-02/tooling/prettier-3.9.6/`
  (`package.json`, `package-lock.json`, `PROVENANCE.md`: prettier 3.9.6, integrity `sha512-OpN0…`).
- Consequence: gate 3 (`prettier --check`) and the tracked `lefthook.yml` pre-commit `npx prettier --check {staged_files}`
  cannot resolve a formatter; product lockfile has no prettier (deliberately). Blocks the hooked commit.
- Minimum closure: recreate the tooling directory from the preserved manifests (`npm ci --ignore-scripts`, one
  integrity-verified registry read as documented), require CLI `node_modules/prettier/bin/prettier.cjs` SHA-256
  `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`, `--version` 3.9.6, then the gitignored link
  `worktrees/s7-b-drain/node_modules/.bin/prettier → <that CLI>`. This is the same link the RC71 detector rejected and
  the parent already dispositioned as an approved shared immutable tool; the remainder driver must keep treating that
  one absolute link as the approved exception, not widen the rule.
- Location is a parent call: reuse the original path (`execution/e7d2385c/s5-continuation/tooling/prettier-3.9.6`) so
  existing receipts stay path-consistent, or an explicitly named recovery-tool directory per SCOPE.

### ENV-3 — hooks not installed (class **C**, expected state)

`core.hooksPath` empty, `.git/hooks` samples only, `git rev-parse --git-common-dir` = `.git` (standalone repo). This is
the pre-`lefthook install` state the grant expects; `lefthook install` will affect only this repo. Record, continue.

### ENV-4 — canonical lock file absent (class **C**)

`execution/test-validation.lock` does not exist. `flock -n` creates it on first use; no one holds it. No action.

### ENV-5 — PostgreSQL lane absent (class **C** now; hard prerequisite for the later PG grant only)

`/home/user/pg17` does not exist. Not needed for phase A/remainder. Before any single-run PG grant, a separate PG
rehydration must reproduce binaries hashing to the runner's constant pins `EXPECT_POSTGRES_SHA=23cd1748…873a` and
`EXPECT_INITDB_SHA=b7db9bc2…882a`; otherwise `b-pg-proof.sh` fails closed at preflight (correct behaviour). Record
only; do not start PG work now (SCOPE: PG separately gated).

### Identity / provenance — no obstacle

`git var GIT_AUTHOR_IDENT` / `GIT_COMMITTER_IDENT` = `Bradley Gleave <bradley@bradleytgpcoaching.com>` in the
worktree; `git config user.*` set. Disk 9.4G free (C1 env ≈ 717M).

## 3. Binding pins — what changes, what does not

- Unchanged and re-confirmed for the filled copy `runtime/binding/b-pg-proof.sh`: `EXPECT_TREE=f4922ca070e887fb7f613ce955b12621b5c33156`,
  `EXPECT_SPEC_BLOB=9b31fd1813d25a1624ab04666e0b1be4743277ab` (live PG spec), `EXPECT_BOOTSTRAP_BLOB=b4503eef525baa531eedb148f47828db3a4ade6f`,
  `EXPECT_FIXTURE_SHA=4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9`; runner `D` path restored at the
  original absolute location and intact. `EXPECT_NM_LOCK_SHA`/`EXPECT_NM_CLIENT_SHA` constants are exactly the two
  hashes ENV-1 must reproduce.
- Necessarily new: `EXPECT_HEAD` — a fresh runtime cannot reproduce a predecessor commit hash (none ever existed; the
  RC71 run stopped before commit). The committed tree must still equal `f4922ca0…` and the parent `a0ea1bea…`; any
  other tree returns to same-review binding as the v4 report already states.
- Commit message: `remainder/commit-message.txt` SHA-256 `fca0b6aa…d9f6` == handoff §7 (builder receipt 06); I did not
  re-derive the handoff text and will check the actual commit object's message/identity at binding time.

## 4. Preliminary disposition

- Source: v4 SOURCE_GRANTABLE **applies unchanged** to the restored worktree. No source finding.
- Execution: **one B-class environment obstacle (ENV-1 + ENV-2, one closure)** blocks the existing stage-2 remainder.
  Minimum closure = documented hash-bound rehydration (`npm ci --ignore-scripts` + pinned Prisma engines/generate on
  the unchanged base schema + Prettier 3.9.6 tooling from preserved manifests), then the granted remainder runs
  unchanged. No new gates, controls, censuses or audits. Parent must record the amendment to the grant's "copy, no
  install/generate" wording as the minimum scoped disposition SCOPE already anticipates.
- Nothing else is blocked. J3 source-only work is not affected by this lane.
- Reviewer B (successor) remains on this same review for: builder proposal check (relayed by parent), actual head +
  gate receipts + filled `runtime/binding/b-pg-proof.sh` binding. Not a new audit track.

Observation time: 2026-09-24 ~14:55Z. Provenance: live worktree and `/tmp/tgp-private-evidence` at private main
`50684d66…` as mounted in this runtime.
