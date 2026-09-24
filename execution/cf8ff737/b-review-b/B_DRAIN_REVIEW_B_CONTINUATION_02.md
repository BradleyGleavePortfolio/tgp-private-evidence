# S7-3′ G2 B/drain — reviewer B SUCCESSOR, continuation note 02 (builder proposal + parent env grant binding; scripts read pre-run)

Status: **PRELIMINARY** — env recovery launched 2026-09-24T14:54:59Z (pid 24175, lock held fd9); no env receipt, gate,
head or filled binding exists yet at write time. Same review as note 01. Successor reviewer B; no telemetry claim.
Read-only; sole writes under `execution/cf8ff737/b-review-b/**`. No peer-A read. No source re-audit.

Inputs: `b-drain/B_DRAIN_RECOVERY_AND_ENV_BLOCKER.md`, parent `B_ENVIRONMENT_RECOVERY_AND_REMAINDER_GRANT.md`,
`b-drain/env-recovery/env-recovery.sh`, `b-drain/remainder/remainder.sh` + `remainder-vs-original-stage2-7.diff`,
worktree `.gitignore`, C1 seal §hooks (`13-C1_ACTUAL_RESULTS_SEAL.md`).

## 1. Proposal vs my note-01 obstacles — coincident; no A/B against the proposal

Builder's B defect and minimum fix are the same closure I recorded as ENV-1 + ENV-2 (documented C1 rehydration route,
hash-bound). Parent grant authorises exactly that and nothing wider (no PG, no accepted-suite rerun, no lock/graph
change). Automatic continuation into the already-granted stage-2 remainder on rc 0 is consistent with owner doctrine
(B → minimum closure → execute) and with the v4 report §4 order / binding BIND-1 order.

## 2. `env-recovery.sh` — material environment applicability checks are present and fail closed

| Grant requirement | Script | Verdict |
|---|---|---|
| Node 20.20.1 / npm 10.8.2, unchanged package/lock | L29–31: HEAD blob == working blob for `package.json` `656d11a2`, `package-lock.json` `354de3da`; version equality | present |
| One `npm ci --no-audit --no-fund --ignore-scripts --loglevel=error` | L39 identical C1 command, 1500 s bound, rc recorded | present |
| Hidden lock SHA `05bc530a…6a44` + recorded resolved versions | L41–43: sha equality; lefthook 2.1.9, prisma/@prisma/client 6.19.3, jest 30.4.2, typescript 5.9.3, eslint 10.5.0, ts-jest 29.4.9 | present |
| No tracked-source change | L40, L53: `git write-tree` == `87798e74…` and `git diff --quiet HEAD` after install and after generate | present |
| Engine pins, one `prisma generate`, client `bf679a16…72d5` | L47–52: engines hash `c2990dca…` in `prisma version` output, libquery `a2924eab…`, schema-engine `5d42b181…`, `index.d.ts` sha | present |
| Prettier 3.9.6 from preserved manifests; version, not hash alone | L34–35 manifest shas `6c39ea3d…`/`3e2189ff…`; L60–62 CLI sha `6e922134…` **and** `package.json` version 3.9.6 **and** `--version` 3.9.6 | present |
| No generic-module fallback / substitution | tooling dir is builder-owned `execution/cf8ff737/b-drain/tooling/prettier-3.9.6`; link only created if `.bin/prettier` absent (L63) | present |
| Mismatch ≠ success | every check `|| stop <stage> <rc>`; sentinel written; lock released on exit | present |

No A/B. Any stop is an honest environment-mismatch stop, not a masked pass.

## 3. `remainder.sh` — reflects the granted stage-2 remainder and the binding order; no A/B

- Preflight (L26–43): base HEAD/tree, clean index, exact untracked set == 11 paths, live `mode blob path` == `frozen-v4/BLOBS.git-sha1`,
  `SOURCE.sha256`, accepted S5 donor/lefthook/package pins unchanged, identity via `git var`, message hash `fca0b6aa…`,
  no `LEFTHOOK`/`LEFTHOOK_EXCLUDE` bypass env, no pre-existing hooks/`hooksPath`.
- Env reassertion (L45–50): the two dependency hashes + formatter target sha **and** 3.9.6 version — exactly the grant's
  "reassert, no recopy/census" clause. RC71 detector not re-run (correct; no donor exists).
- Hooks (L55–60): `lefthook install` from the local binary; requires executable `pre-commit`/`commit-msg` referencing
  lefthook (content check, not the C1 literal-path mistake); copies actual hook files to receipts.
- Staging (L64–66): `git add` the 11 paths only; `write-tree` must equal `f4922ca0…`; 11 cached names.
- Gates (L72–76): grant order/bounds exactly — tsc 300 / eslint 8 TS paths 180 / prettier --check 8 paths 120 /
  `check-r75 --mode=staged` 60 / jest two DB-free specs `--runInBand` 300; first nonzero stops.
- Commit (L80–88): tree re-asserted before commit; `git commit -F` with hooks (no `--no-verify`, no amend/rebase);
  `npm_config_offline=true` so hook `npx` cannot fetch; post-checks tree == v4, parent == base, clean, message equal
  modulo trailing blank lines, committed blobs listed.
- Filled binding (L92–101): template sha `25eb6837…` asserted; 5 substitutions only; diff shape exactly 10 ±lines;
  no placeholder left; `EXPECT_SPEC_BLOB=9b31fd18…` (live PG spec, correct — not the unit spec), `EXPECT_BOOTSTRAP_BLOB=b4503eef…`,
  `EXPECT_FIXTURE_SHA=4525f01d…` re-derived from committed HEAD / restored fixture; `bash -n`; written to canonical
  `execution/95633079/s7-b-drain/runtime/binding/` (SCOPE-granted additive path; `D` unchanged). Not executed.
- Bundle/patch (L106–109). Diff vs original stage 2–7: path relocation + added template-sha guard only.

## 4. C items (record, continue — none blocks)

- **C-1 launcher hash is version-independent.** Builder found `/usr/local/lib/node_modules/convex/node_modules/prettier` 3.9.9 has the same `prettier.cjs` sha `6e922134…`. The phase-A grant's "approved shared immutable tool" identity by hash alone was therefore under-specified. Already closed in both scripts (package version + `--version`). Applies retroactively to the RC71 disposition as hygiene only: that link pointed into the C1 tooling dir installed from the 3.9.6 lock, so no wrong version was ever used.
- **C-2** `env-recovery.sh` L69 receipt label `porcelain_tracked=` prints full porcelain (will include the 11 untracked); label only.
- **C-3** `prod-readiness-quick` hook is a `[ -x ]` no-op (script untracked at this tree); its ✔️ is not readiness evidence — qualification carried forward verbatim from the C1 seal.
- **C-4** Remainder L60 requires exactly 11 porcelain lines after `lefthook install`; if lefthook writes any untracked file at the worktree root this stops (fail-closed false stop, not a false pass). `node_modules/` is gitignored (`.gitignore` L1/L11); tooling dir is outside the worktree.
- **C-5** `EXPECT_HEAD` will necessarily be a new hash (no predecessor commit ever existed); binding is filled post-commit, as designed.

## 5. What I will bind on receipt (no new controls)

`env-recovery/logs/04-environment-receipt.txt` + sentinel (rc, three hashes, versions, tree unchanged); `remainder/logs`
`02-hook-identity.txt`, `03-staged-tree.txt`, `04-*.log` rc lines, `05-commit.rc`, `06-commit-object.txt` (author,
committer, tree, parent, message), `07-binding-PINS.txt` and `runtime/binding/*.substitution-only.diff`. Any nonzero is
reported as the builder's honest stop; I will classify only if the failure is a candidate defect (A/B) rather than
environment.

Observation time 2026-09-24 ~14:58Z.
