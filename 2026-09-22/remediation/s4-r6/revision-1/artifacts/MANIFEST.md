# S4 R6 artifacts — checkpoint 91990ae9aec72f47a67591892ac09fa1f59d2f16

| file | sha256 | note |
|---|---|---|
| s4-r6-91990ae9.bundle | af2c8207c9b04ca9089115e39e0a3298c6519b8f58b7238cc1a7c718a9bab0dd | `git bundle verify` okay; prerequisite 0111be661922234d670bbf23e23d270eec1b4a4e; head refs/heads/execute/20260921-s4-r6 = 91990ae9…; 22 commits over 0111be66 (includes frozen 2bcf1563 and 88287cff chain) |
| s4-r6-91990ae9-over-88287cff.patch | 1f57346c7e56fe2b9647134d5bd1b2243dd318124bf8cdd6d2a86a08995c2a06 | `git format-patch 88287cff..91990ae9` (1 commit, 2 files, +166/−6) |
| s4-r6-91990ae9-over-88287cff.diff | aeb7bdcaa1537fca1e11f080cdfad99f8bbc8b4caa8bdbb7e5f799ad7e5b8544 | `git diff 88287cff 91990ae9` |

tree 840fb2855953d5363fbd144e11b3f81763d9cef7; parent 88287cff47240aa58b5f0fea5da08670f1e87df6;
author = committer Bradley Gleave <bradley@bradleytgpcoaching.com> 2026-09-22T04:38:29Z; no trailers.
HOOKS DID NOT EXECUTE at commit (lefthook/toolchain absent, no install granted) — see REPORT.md §2 blocker.
Blob sha256 at 91990ae9: background.js e0e674345fd4e2e2d47267295669ae4114a4c057eccd32e3c28fef1f22ce8eb3 (changed);
shared/session.js b4f459007fc757f184ddb3dd9b61589fd886ba289bc647040b8ed1a16232bbc2 (unchanged from 88287cff);
test/session-ownership-preflight.spec.js b03754b9ccd0a8cbafe37027cce48ae2332a04e86d9015c4c72f217babf3512f.
No extension zip built (no heavy slot). Reproduce: clone any repo containing 0111be66, `git fetch <bundle> execute/20260921-s4-r6`.
