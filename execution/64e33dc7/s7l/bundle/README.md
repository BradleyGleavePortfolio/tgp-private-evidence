# S7-L candidate source export (no commit yet — see SOURCE_READY.md)
base: 93389265a846095b846fa8f1fb0dad782fb6ee9f (branch exec64/s7l-replacement, worktree /home/user/workspace/worktrees/64e33dc7-s7l)
staged tree: 7086b68220d952ca1fae05949b5b2d1d67189ef5  (git write-tree of the fully staged index; identical to checkpoints/draft-03-gated bytes)
head: NONE — the genuine hooked commit was refused solely by the absent prettier executable (see gates/commit-attempt-2.raw.log)
- s7l-candidate-93389265-to-tree-7086b68220d9.patch : git diff --cached --binary base → tree (apply with git apply on 93389265)
- s7l-candidate-tree-7086b68220d9.tar.gz : git archive of the exact tree (whole repository at the candidate state)
- MANIFEST-name-status.txt : 29 changed/added paths
Verify: git apply the patch on 93389265, git add -A, git write-tree == 7086b68220d952ca1fae05949b5b2d1d67189ef5.
