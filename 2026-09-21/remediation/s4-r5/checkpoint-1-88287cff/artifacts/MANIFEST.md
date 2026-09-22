# S4 R5 artifacts — checkpoint 88287cff47240aa58b5f0fea5da08670f1e87df6

| file | sha256 | note |
|---|---|---|
| s4-r5-88287cff.bundle | f8de3d639e8765fec1a914ddf4fd220a1e89dbcc6c4492e2108addccdc1fcf97 | `git bundle verify` okay; prerequisite 0111be661922234d670bbf23e23d270eec1b4a4e; head refs/heads/execute/20260921-s4-r5 = 88287cff…; 21 commits over 0111be66 (includes frozen 2bcf1563 chain) |
| s4-r5-88287cff-over-2bcf1563.patch | f9be88be97b4b12c9282cca984f9abf0ad2a746fc16c4e66ec7e25fc1be686fc | `git format-patch 2bcf1563..88287cff` (1 commit, 5 files, +1018/−46) |

tree a2879859882770f45b88f1651438436fd96376f9; parent 2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3;
author = committer Bradley Gleave <bradley@bradleytgpcoaching.com> 2026-09-22T00:45:33Z; no trailers; hooks ran (lefthook 6/6 ✔️).
Blob sha256 at 88287cff: background.js 5a6a4b8b091b302a1acbb60ee23e5d10ddebf439eec1f22942d43e89634ff721;
shared/session.js b4f459007fc757f184ddb3dd9b61589fd886ba289bc647040b8ed1a16232bbc2;
test/session-ownership-preflight.spec.js e72c9dc5d93ab4e2746f0af24e87370bd48918feb9487794ddc07b1989a50ae2.
No extension zip built (no heavy slot). Reproduce: `git clone` any repo containing 0111be66, `git fetch <bundle> execute/20260921-s4-r5`.
