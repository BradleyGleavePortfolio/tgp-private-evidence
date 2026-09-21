# S5 R3 checkpoint 2 — recreate the candidate from the frozen bundle

```bash
git clone /home/user/workspace/repos/growth-project-backend s5-r3-restore   # or any clone containing public main c23b9d9f
cd s5-r3-restore
git bundle verify /home/user/workspace/execution/s5-r3/checkpoint-2/s5-r3-candidate.bundle   # "is okay"
git fetch /home/user/workspace/execution/s5-r3/checkpoint-2/s5-r3-candidate.bundle execute/20260921-s5-r3:execute/20260921-s5-r3
git checkout execute/20260921-s5-r3
git rev-parse HEAD HEAD^{tree}     # cf3e72f90ad63d40c1831d8b86141f2d16b7ba05 / 85d57e9d41dd9cce5699b32b669f90ea459fc01b
git log -1 --format='%an <%ae> | %cn <%ce>'   # Bradley Gleave <bradley@bradleytgpcoaching.com> | same
sha256sum -c /home/user/workspace/execution/s5-r3/checkpoint-2/SHA256SUMS   # run from checkpoint-2/
```

Alternative: `git -C <clone-with-9f38ab03> apply --index checkpoint-2/delta-9f38ab03..cf3e72f9.patch` (test-only, 4 files).

Runner, install script, lane fixture script and the offline psql stand-in are copied verbatim into `checkpoint-2/`
(hashes in `SHA256SUMS`); the live copies used by the plan are `execution/s5-r3/{run-proof.sh,npm-ci.sh,s5-fixture.sh,stubs/psql-stub.sh}`.

Old-root fixture: `bash execution/s5-r3/run-proof.sh oldroot` (offline; creates or verifies
`execution/s5-r3/old-root-925780e0`, a self-contained clone detached at O `925780e0…`, 164 migrations).
