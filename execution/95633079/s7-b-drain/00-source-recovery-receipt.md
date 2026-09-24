# S7-3′ B/drain — source recovery receipt

Recovered `2026-09-24` (UTC) by the separate G2 B/drain builder under parent EXEC-95633079.

| Item | Value |
|---|---|
| Method | `git clone --no-hardlinks --no-local` of the local accepted standalone repo `worktrees/s7-c1` (read-only against it), then `git checkout --detach a0ea1bea`, `git remote remove origin` |
| Isolated repo | `/home/user/workspace/worktrees/s7-b-drain` (standalone `.git`, no remote, no hooks, no `node_modules`) |
| HEAD | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` = C1 accepted commit (`C1_FINAL_ACCEPTANCE.md`) |
| Tree | `87798e742c7b48f56b05e9b5c30efa877180a9b3` = accepted tree |
| Parents | `5c760b774598532e90d5d217e15adc9285c3c3f4` `881c4c791727adef8d423931e1cca83a0ffbb9c9` |
| Author / committer at head | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both |
| Repo identity config (no commit made) | `user.name=Bradley Gleave`, `user.email=bradley@bradleytgpcoaching.com` |
| `git status --short` after recovery | empty |
| `.git/hooks` non-sample entries | none (Lefthook not installed; no `npm ci`, no `prepare`) |
| Public main | not touched, not reset, not recomposed; no fetch/push |
| s7-c1 after clone | HEAD `a0ea1bea`, `git status --short` empty (unchanged) |

Historical recovery docs pulled with `git show` from the local `agent-context` object store at
`3300d31539df4428c9b8f5f85215a4842c30728c` (object present; no remote retrieval needed):
see `evidence/HISTORICAL_DOCS.sha256`.
