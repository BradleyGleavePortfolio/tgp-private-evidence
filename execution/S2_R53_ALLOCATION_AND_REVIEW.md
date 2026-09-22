# S2 R53 setup allocation and independent review

TIER:T4 for both setup and plan-review children: trusted release/security validation, synthetic destructive recovery and evidence attribution consequences. Canonical builder Claude Fable5. Parent grants setup only, not independent safety acceptance or real DB authority.

## Identity and shared scope

- REPOSITORY/PR:backend cumulative delivery/S1 composition, preserved #524/#525/#526/#528/#529; source is private successor, no new public PR.
- BASE:c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7. EXACT CURRENT HEAD:d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c/treec0ab87d4dc584b2a7ccad53db16fa551b93fe359.
- PURPOSE:restore exact prerequisite environment and independently evaluate frozen runner/fixture for real proof.
- NON-GOALS:no source change/commit/push, product/hosted access, live customer data, release or acceptance claim.
- DEPENDENCIES:execution/s2-setup-prep37-file SHA256SUMS.outer; runnerfb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925; fixture9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881; original v5.3/evidence immutable.
- REQUIRED REVIEW:two independent nonwriter frozen-packet dispositions before real proof, then observed proof interpretation and final exact-head attestations.
- RECOVERY:one-strike stop, preserve partial installs/logs, no cleanup of platform dependencies, no automatic retries, no releasing another stage while owned descendants remain.
- WHAT SUCCESS DOES NOT PROVE:PG composition/discriminator, S1 inherited membership, final acceptance, hosted/release/customer/native safety.

## SETUP-05 grant

WRITER OWNER:s2_t4_runner_cleanup_muc6cvij. Sole heavy owner after S5 Tier1 terminates; canonical nonblocking lock acquired by each setup step. Verify exact frozen packet/head/clean state and sufficient disk before launch. Only SLOT_REQUEST_05_SETUP_ONLY.md setup stages S10/S20/S30; no fixture/init/start/DB/controls/destroy.

Use frozen infra/launch-detached.sh, with these additional external deadline wrappers. Each wrapper creates its own controlled process group under the detached session; record actual launcher/child PID/PGID and confirm no survivors before next stage. Do not use foreground timeout for the added outer bound.

```
bash infra/launch-detached.sh start setup-10-grant05 timeout --kill-after=60 1560 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-10-clients.sh
bash infra/launch-detached.sh start setup-20-grant05 timeout --kill-after=60 480 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-20-pg17.sh
bash infra/launch-detached.sh start setup-30-grant05 timeout --kill-after=60 2160 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-30-npm-ci.sh
```

Execute sequentially, not all at once. One install attempt per stage; no repeated failed stage. Parent grants apt client packages, pinned Maven17.6 bytes and exact-lock npm closure/explicit guarded Prisma generate as described in request05. Use no production credentials. Preserve raw npm logs and before/after outside-root inventory; /home/user/node_modules is pre-existing platform-owned state and must remain untouched. A successful stamp is not permission for a server/proof run.

ACCEPTANCE/REQUIRED EVIDENCE:each actual raw exit0/sentinel, setup identities and pinned hashes, d5cd clean after, root inventory unchanged, no PG server/listener, no surviving owned setup child, canonical lock free between/after stages. On any failure stop, report first exit/cleanup separately and preserve partial state for disposition.

## S2-R53-INDEPENDENT-PLAN A/B

WRITER OWNERS:independent A s1_r4_independent_audit_a_muc6muvy writes only execution/audits/s2-r53/a; independent B s1_r4_independent_audit_b_muc6muwk writes only execution/audits/s2-r53/b. Neither implemented S2 candidate/runner/fixture. Their frozen S1 reports remain immutable. Requested A model inherited parent; B Claude Fable5, actual runtime settings unexposed.

ACCEPTANCE/REQUIRED EVIDENCE:independently inspect frozen37-file packet, actual d5cd source consumers and existing frozen runner controls only as needed. Challenge lock/proc identity, no adoption of unrelated server, fresh namespace/port/DB guards, process-group/escape handling, timeout budget, failclosed cleanup/quarantine, exact script compatibility and evidence semantics, setup applicability, real-mode branches versus stubs, intendednegative coverage. Check inherited S1 discriminator prerequisites and164+1 replay. Find minimum material closure, not a new architecture/framework.

No install/test/probe/server/network/DB execution, no source/runner/fixture writes. Do not read current peer conclusions before freezing concise Markdown/JSON/nonselfmanifest. Distinguish source-fixed, controls-observed, real-proof pending and release/customer holds. These are independent execution-plan reviews, not repeated full source archaeology.
