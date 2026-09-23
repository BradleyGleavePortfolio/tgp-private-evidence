# S3 composed-lock release proof — EXECUTED ONCE, `runner=0`, all acceptance criteria met as raw actuals (revision 1, frozen)

Executor: `restore_s2_substrate_mue9eidh`, T4 sole runtime assignee, parent EXEC-6c2a68ac. Activation: parent mail 17:41Z "REACTIVATE UNUSED EXACT ONE SHOT NOW" + `S3_COMPOSED_PROOF_REACTIVATION_02.md` (sha256 `7f945d46…`, untracked) + updated `S3_COMPOSED_PROOF_RUNTIME_GRANT.md` working copy `e213ebc5…` (ACTIVE; private HEAD `943dcbb2` copy `4874ffb9…` reads INACTIVE — diff is the status paragraph, result-root rename and "original stopped result is not a collision"; recorded in the console). Both read completely; runner/fixture/request re-read. Window 17:42:02–17:44:38Z. The earlier pre-launch stop `s3-composed-proof-result/` (seal `e04842cc…`) is retained untouched.

## 1. Raw actuals

| Item | Actual (raw) | S2 accepted (bbde4b0b) | Criterion |
|---|---|---|---|
| `runner=` (caller echo of block exit) | **0** | 0 | 0 ✔ |
| `exit-codes.txt` | `final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok cleanup_seconds=0.54 deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none` | identical except `cleanup_seconds=0.56` | ✔ |
| 10 guard spec | exit 0, **72 passed, 0 failed** | 72/72 | ✔ |
| 20 / 21 refusals | **64 / 64** (URL_HOST; CONFIRM) | 64/64 | ✔ |
| 30/31/32 fixture init/start/status | 0 / 0 / running (PID 28244), PG **17.6**, datadir `/home/user/pg17/clusters/s3comp-be0b`, 127.0.0.1:**54354** | 0/0, 54353 | ✔ |
| 40 composition (`test/release/s1s2-composition.sh`, blob 38b70f54) | exit 0, **68 passed, 0 failed** (head be0ba82) | 68/68 | ✔ |
| 45 S1 R4 discriminator | exit 0, **48 passed, 0 failed**, scoped_status=clean | 48/48 | ✔ |
| 50/51 fixture stop / status after stop | 0 / `pg_ctl: no server running` | same | ✔ |
| Reap / survivors / listener | `REAP ok`, `survivors=none`, runner: "nothing listening on 54354" | same | ✔ |
| RECEIPT / PUBLICATION | `receipt_status=ok final_exit=0 first_exit=0 cleanup_exit=0`, inner manifest `c3ccc3fa…` (90 lines, `sha256sum -c` OK), `publication_status=ok process_exit=0` | ok/ok | ✔ |
| Wall time | 17:42:28Z → 17:44:07Z (99 s); outer bound 2100 s | 96 s | — |
| Runner self-stamp | `runner_sha256=e876f48c…` **populated** (absolute invocation) | empty (relative `$0`) | ✔ |

Runner output (runner-owned, untouched): `/home/user/workspace/execution/6c2a68ac/s3-composed-proof/composition-s3/20260923T174228Z/` (94 files). Byte copy: `runner-output/` in this packet (`tar -cf - . | tar -xpf -`; inner `SHA256SUMS` verifies OK on the copy).

## 2. Bindings the runner actually verified before executing anything (`stamp.txt`)

head `be0ba8274e486dee77f15d18fe367a13ff08ecf5` ✔ tree `a584a1b95423f95dae8daabf673ef3776604acbb` ✔ dirty 0 ✔; lock `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55` ✔; closure files identical to be0ba827 ✔; Prisma CLI bytes `c2a77456…` ✔ (checked before first CLI execution); **installed graph `node_modules/.package-lock.json` = `05bc530a…` ✔ (receipt binding to s3-integration-result steps 02/03; not a recursive integrity claim for every installed byte)**; generated client present ✔; `installed_versions: prisma=6.19.3 client=6.19.3 deepmerge_ts=8.0.0`; fixture `9763698b…` ✔ with `PORT=54354;`/`NS=s3comp-be0b` literals ✔; harness `c766a8d9…`, release.sh `8831f8f7…`; `CHECKPOINT_DISABLE=1` exported and stamped (presence only — no claim of network-level checkpoint suppression); no `.s2-composition-install-stamp` (expected; none written).

## 3. Comparison with the accepted S2 run (`comparison/S2_VS_S3_COMPARISON.txt`, raw lines preserved, normalization masks only timestamps/pids/head/tree/lane names/port/out paths/durations)

- **Release path:** all ten release cases C0, C0b, C1, C2, C3, C4, C5, C5r, C7, C8 have identical `[release]` line counts (16/16/26/26/30/26/30/26/21/26) and are **byte-identical after normalization**; `prisma_cli = prisma 6.19.3` in every case; rc/exit lines identical (11). Full `harness.log` normalized diff reduces to exactly two expected lines: `parents=` (S3 is the two-parent merge d5cd9b8b + 5c7b42b3) and `sha256 … package-lock.json` (`62b05b90…` blob a23abae6 → **`b7fed5ed…` blob 354de3da**). All other header lines — release.sh, verifiers list, migration/down/verify SQL, S1 guard, bootstrap SQL, RLS SQL hashes/blobs, psql 18.6, node v20.20.1, CLI sha `c2a77456…`, `prisma_version` (prisma 6.19.3 / @prisma/client 6.19.3 / engines c2990dca…), `npx_resolves_to=prisma : 6.19.3`, server 17.6 — are identical.
- **Discriminator:** 48/48 both; normalized diff is one line, the `S1_R4_LOCK_HOLDER` label (`…-v5.7` → `…-v5.8`), i.e. runner change S3-4.
- **Guard spec / refusals:** identical texts modulo lane DB/port.
- **Dependency graph actually exercised:** S2 = lock `62b05b90…`, deepmerge-ts **7.1.5**; S3 = lock `b7fed5ed…`, deepmerge-ts **8.0.0**, same Prisma 6.19.3 CLI bytes/engines. `@prisma/config@6.19.3` `dist/index.js` lines 893–894 **directly** `import("c12")` and `import("deepmerge-ts")`; c12 3.1.0 does not depend on deepmerge-ts. The S3 product `package.json` `overrides` `"@prisma/config@6.19.3": {"deepmerge-ts": "8.0.0"}` makes the lock hoist deepmerge-ts 8.0.0 with no nested copy, so `@prisma/config` resolves 8.0.0 at run time (package's own declaration still says 7.1.5 — declaration, not resolution). This is a composed-graph comparison; it does not isolate every package or config branch.

## 4. Post-closure state (read-only, `90-postclosure.txt`, 17:44:37Z)

Fixture `s3comp-be0b` **stopped on disk** (`postmaster.pid` absent; left in place, not destroyed), `.log` present; no socket on 54354 in `/proc/net/tcp{,6}`; `/home/user/pg17/run` empty; canonical lock fd holders **0**; no postgres/psql/node/npm/jest/flock/timeout/caller processes for uid 2000; the five `/tmp` scratch paths absent (harness captured/removed its own); `s2comp-r53` untouched (mtimes 16:24:05Z). Source unchanged: s3-prep2 HEAD be0ba827 / tree a584a1b9 / porcelain 0 / lock `b7fed5ed…` / installed graph `05bc530a…` / CLI `c2a77456…` / no stamp; `.git/index` mtime 17:12:12Z and sha `b2f6d4c2…` unchanged from preflight (GIT_OPTIONAL_LOCKS=0 throughout). Prep packet seal `be31c041…` and prior stop seal `e04842cc…` unchanged.

**Runtime slot RELEASED to parent EXEC-6c2a68ac at closure (17:44:38Z).** No survivors known; the runner's own end-of-run scan and my read-only census agree.

## 5. Executor observations / C records

- C-1: the caller (`caller.sh`, `2597502b…`) adds only timestamps, identities and `export GIT_OPTIONAL_LOCKS=0` around the block, as the grant allows; the block lines are `cmp`-identical to the grant (`block.granted.txt` = `block.executed.txt` = `0c81eb0a…`). Transport `setsid -f nohup … > logs/caller.console.log 2>&1 < /dev/null`, rc 0.
- C-2: my post-closure listener observation is a read of `/proc/net/tcp{,6}` for port hex D3EA (file read, no socket probe); the "no listener" claim in §1 is otherwise the runner's own.
- C-3: `node -p` JSON reads and `grep` of installed package files were used for §3 import evidence (static reads, no product execution).
- C-4: the comparison's normalization is a `sed` mask; raw lines are preserved alongside (sections A–C, K) and in `runner-output/`.
- Grant working copy vs HEAD differ (parent's ACTIVE update; publication in parallel); REACTIVATION_02 untracked; hashes recorded in `00-preflight-02.txt`.

## 6. Scope of claim

One request-02 §6 release-path re-observation on the exact integrated S3 head be0ba827 / tree a584a1b9 / lock b7fed5ed with deepmerge-ts 8.0.0, Prisma 6.19.3, PG 17.6, psql 18.6: same raw exits, same 68/48/72 assertions and normalization-identical release logs as the accepted S2 run. Not a full suite/build/image/production/customer/universal-importer claim, not a remote landing grant, not final acceptance; it is the real composed-lock input to the two existing final-head attestations. Bradley decision: not required for this local scope (per grant).

## 7. Files

`00-preflight-02.txt`, `launch.txt`, `caller.sh`, `block.granted.txt`, `block.executed.txt`, `logs/caller.console.log`, `runner-output/**` (94 files), `90-postclosure.txt`, `comparison/{S2_VS_S3_COMPARISON.txt, *.normdiff, s2.rc.norm, s3.rc.norm, s3.harness.pass-lines.txt}`, `RESULT.md`, `MANIFEST.sha256` (non-self-including; seal = sha256 of MANIFEST.sha256).
