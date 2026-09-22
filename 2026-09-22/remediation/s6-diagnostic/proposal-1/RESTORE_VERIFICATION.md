# S6 candidate restore verification (worktree /home/user/workspace/worktrees/s6-diagnostic)
- bundle: tgp-private-evidence/2026-09-21/remediation/s6-r3/checkpoint-1/s6-r3.bundle
- sha256: c0ad2994f899775bd821029b62c1c492991bf1ddf1ab184ec0a88a9d7e439662 (OK, equals brief)
- `git bundle verify`: okay; prerequisite a5933fd6de5616493de75f0db907098b149b955c satisfied from source/mobile clone
- advertised head: refs/heads/execute/20260921-s6-r3 = d51a191098f483cea9abec6cc7e9f3beffd18c06 (checked out on branch of same name)
- tree: 62bf67b88e0f123f1a23ee34a1a75cb43029d9fb; a5933fd6 is ancestor; 15 commits; 55 files changed vs public
- head commit author/committer: Bradley Gleave <bradley@bradleytgpcoaching.com>; no AI trailer
- status: clean; node_modules ABSENT (no install performed); no /home/user/{node_modules,package.json}
- archive and source/mobile untouched; no commits made; no product bytes edited
