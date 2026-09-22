# S3-PREP2-FORMAT-ONLY — six-file formatting on top of PREP1 (staged, uncommitted, untested)

Writer: PREP-1/PREP-2 author (not an attestor). Grant: execution/EXECUTION_REPAIR_WAVE_2.md §S3-PREP2-FORMAT-ONLY. Commencement dependency: S5 wave-5 destroy (05:32:07–17, rc 0, 14 PASS) and genctl (05:32:36–44, rc 0, 12 PASS), survivors_rc=0, no S5 processes (00-pre-state.txt) and parent confirmation mail.

## Steps (canonical `execution/test-validation.lock`, `flock -n`, holders lines in 05-post-state.txt)
| step | command | exit | bound | lock held |
|---|---|---|---|---|
| 01 | `node <tool>/prettier.cjs --write` on exactly the six files | 0 | 120+30 s | 05:35:08–09Z |
| 02 | diff review (git only, no formatter) | — | — | none |
| 03 | `node <tool>/prettier.cjs --check` on the same 46 hook-matching staged paths (list sha256 44b8a947…, identical to PRETTIER-ONLY-01) | 0 — "All matched files use Prettier code style!" | 120+30 s | 05:36:05–07Z |

Tool: Prettier 3.9.6, binary sha256 `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e` (verified in PRETTIER-ONLY-01 step 02); `npm_config_offline=true`; no npm/npx/network, no product node_modules, no symlink, no hooks, no commit, no Jest/tsc.

## Diff review (02-diff-review.txt, 02-worktree-vs-prep1-index.full.diff)
- Changed paths: exactly the six; 0 outside. 6 files, +71/−61. `git diff --check` clean; LF; trailing newline.
- With whitespace/blank lines ignored, the residual differences are only `,` (trailing commas: prisma.service +1, health-readiness-bounded +1, logging.interceptor −1) and `-` (markdown table separator dash counts in README 164→810). After also removing `,`/`-`, before/after non-whitespace character streams are identical for all six. Hunks: line-wrapping of 4 long expressions/generics, import collapse, ternary wrap, `toMatchObject` object wrap, 5 markdown table separators.
- No R75 banned tokens introduced. This is a formatting observation; runtime/semantic equivalence is NOT asserted from it — tsc/Jest on the committed head remain required.

## New staged tree
- PREP1 tree `78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69` → **PREP2 tree `a584a1b95423f95dae8daabf673ef3776604acbb`**; `git diff --name-only 78a4f0e8 a584a1b9` = the six paths.
- HEAD `d5cd9b8b…`, MERGE_HEAD `5c7b42b3…`, base `c23b9d9f…` unchanged; product `package-lock.json` blob `354de3da…`, `package.json` `656d11a2…` unchanged; unmerged 0; worktree == index; not committed.
- Three PREP1 resolutions byte-identical: `r100-quality-gate.yml 0ad6eb8b`, `r100-pathspec.spec.ts be6676d6`, `r75-gate.spec.ts 04190bd6`.
- Patches: `patches/prep2-six-files-vs-prep1-78a4f0e8.patch` (minimal), `patches/full-vs-parent1-d5cd9b8b.patch`, `patches/full-vs-parent2-5c7b42b3.patch` — each full patch re-applied on a fresh index of its parent reproduces `a584a1b9…`.
- Before/after copies of the six files in `before/` and `after/`.

## Preservation matrix (PRESERVATION_MATRIX.tsv, 86 rows = every path changed vs base by either parent)
| class | count | meaning |
|---|---|---|
| S3_PRESERVED | 38 | blob == S3 5c7b42b3 (src, lock, policy, checker, dependency-audit, tests, fixtures…) |
| S1S2_PRESERVED | 38 | blob == S2 d5cd9b8b (prisma, release, harness, Dockerfile, fly workflows, delivery/gate specs; fly-logs-dump.yml deletion) |
| FORMATTED_S3_PREP2 | 6 | new blobs; differ from S3, S2, base and PREP1 — the S3 source-review results for these six paths are no longer byte-current |
| RESOLVED_PREP1 | 3 | unchanged since PREP1 |
| AUTO_MERGED | 1 | `.github/workflows/ci.yml` |
| UNEXPECTED | 0 | |

The former "all S3 evidence blobs identical" statement from PREP1 is superseded: it now holds for 38 of 44 S3-only paths plus policy/lock; the six formatted paths need independent revalidation (at minimum tsc + the S3 specs that import them: health-readiness-bounded, observability, scout, throttler/filters, prisma.service).

## Cleanup receipt
Lock released after each step (`lock_held_now=no`); no prettier/npm/node processes owned by this lane remain (`own_processes=0`); only tooling under `execution/s3-composition-prep/tooling/prettier-3.9.6/node_modules` persists (declared). Allocation free for S6 setup.

## Not proven
Hook execution/resolution, dependency closure, commit, tsc/Jest/R75 range on the composed head, runtime equivalence of the six formatted files, acceptance. Prior PREP1 packet and PRETTIER-ONLY-01 evidence untouched.
