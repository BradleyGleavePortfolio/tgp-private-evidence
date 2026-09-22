# CORRECTION 1 to S6_C5_REVIEW_B.md — commit identities in §0 (additive; original bytes untouched)

Auditor: independent non-builder S6 T4 auditor B (actual runtime model/settings not observable, not asserted). Read-only (`git log` on the scratch read-only clone `/tmp/s6c5b-ro`, ref `refs/ro/s6-r3` = `d51a191098f483cea9abec6cc7e9f3beffd18c06`, fetched from bundle `c0ad2994f899775bd821029b62c1c492991bf1ddf1ab184ec0a88a9d7e439662`). Nothing executed beyond `git log`/`rev-list`/`rev-parse`. Triggered by parent mail 14:17 PDT: "builder reports 7 prior noreply commits".

## 1. What the frozen review says (original preserved, NOT rewritten)
`S6_C5_REVIEW_B.md` (sha256 `2398cc9d242faee77a5835869559415418444cc19f1eacf504f6b1a1a5d1694b`) §0 line 5 states: "(re-derived from bundle `c0ad2994…9662`: head/tree match, base is ancestor, 15 commits, author+committer Bradley Gleave)".

## 2. Factual correction
The clause "15 commits, author+committer Bradley Gleave" is **incorrect as stated**. It was derived from `git log -1` on the head only and overgeneralised to all 15 commits. The builder's statement (7 prior noreply commits) is **correct**. Exact identity table of `a5933fd6..d51a1910` (15 commits, `git rev-list --count` = 15; author | committer identical within each commit):

| # | Commit | Author = Committer | Subject |
|---|---|---|---|
| 1 | d51a191 (head) | Bradley Gleave <bradley@bradleytgpcoaching.com> | S6 R3 (reimplementation): truthful async identity cache, generation fences, owner-fenced food queue, bounded pairing identity wait |
| 2 | 55db31a | Bradley Gleave <bradley@bradleytgpcoaching.com> | Merge execute/20260920-s6-export-r2 (bundle-safe optional react-native-mmkv) into S6 final candidate |
| 3 | d707926 | Bradley Gleave <bradley@bradleytgpcoaching.com> | storage: make react-native-mmkv a bundle-safe optional dependency |
| 4 | eaccaba | Bradley Gleave <bradley@bradleytgpcoaching.com> | fix(import): scope every mint settle path to its own attempt |
| 5 | 60975b5 | Bradley Gleave <bradley@bradleytgpcoaching.com> | test(config): AST-based process.env guard; declare @babel/core devDependency |
| 6 | d1c6198 | Bradley Gleave <bradley@bradleytgpcoaching.com> | fix(import): make pairing-session restore reachable after a process death |
| 7 | 27b48f6 | Bradley Gleave <bradley@bradleytgpcoaching.com> | fix(config): make EXPO_PUBLIC_* flag reads static so release builds inline them |
| 8 | 3e9249f | Bradley Gleave <bradley@bradleytgpcoaching.com> | Compose final #289 dependency-guard hardening into the M5 mobile foundation candidate |
| 9 | 2235498 | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | fix(deps): resolve npm's aliases, read bundled .js, and derive the entrypoint set |
| 10 | ba3fd40 | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | fix(deps): guard the root entrypoints and every workflow, not just src/ and ci.yml |
| 11 | 8f0b584 | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | fix(deps): parse imports with tsc so the dependency guard has no blind spots |
| 12 | 3408867 | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | fix(a11y): make the pairing code readable, copyable, and honest about it |
| 13 | d2f0d31 | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | feat(import): durable user-scoped pairing state and support correlation |
| 14 | ed0342e | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | feat(flags): declare import flags and add an independent review kill switch |
| 15 | 4be69b9 | BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com> | fix(deps): declare zod and make CI installs deterministic |

Summary: 8 commits author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` (the head and the 7 newest), 7 older commits author+committer `BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com>`. A case-insensitive search of all 15 commit bodies for `co-authored` / `generated` found 0 matches (no AI co-author trailers observed).

## 3. What does and does not change
- Corrected §0 reading: "15 commits over base; head d51a1910 author+committer Bradley Gleave <bradley@bradleytgpcoaching.com>; 8/15 with that identity; 7/15 with the noreply identity above."
- No other finding, hash, line binding or conclusion of `S6_C5_REVIEW_B.md` depended on this clause; findings S6-C5-B-01..03 and §8 stand as frozen.
- The G05 identity requirement (author+committer Bradley Gleave, no AI co-author) is **not** attested here for the bundle history; the actual final-head G05 proof remains a later, separate attestation. This file only corrects a factual overclaim in my own §0.
- Head/tree/base facts in §0 remain correct: head `d51a191098f483cea9abec6cc7e9f3beffd18c06`, tree `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb`, base `a5933fd6de5616493de75f0db907098b149b955c` is an ancestor.

## 4. Manifest handling
Original `MANIFEST.sha256` (sha256 `58f1ae81796862e38c95f85e6f3577f6b85bc0dea08078fec93aac968fa4d315`, two entries) is left byte-identical. An additive `MANIFEST.rev2.sha256` lists the original review, original INPUTS.sha256 and this correction file (non-self-including).
