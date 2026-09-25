# EXEC-DACEDDC8 takeover checkpoint (2026-09-25 ~16:25Z)

**HANDOFF: ACCEPTED.** Contradictions were identified and resolved by source precedence:
- (a) The attached Agent Rules say "PROPOSED", but the live `AGENT_RULES` are "EFFECTIVE 2026-09-18" with identical G01–G22. Live wins.
- (b) The boot hint cursor (cf8ff737, N/Q1) is stale. Live is session 64e33dc7.
- (c) The 05:56Z owner freeze conflicts with Bradley's current EXECUTE takeover prompt. The later owner instruction wins, and grants are re-issued in `SCOPE.md`.
- (d) Op81 says "never server-side merge" and requires R3 manual squash. The owner autonomous-landing amendment supersedes this. The established method is PR + CI green + FF push preserving Bradley identity (`cf8ff737/LANDING_LEDGER.md`).
- The previous sandbox disk is gone. Half-done work is reconstructed from durable and live evidence in `HALF_DONE_WORK.md`.

**LIVE CURSOR (16:10Z):** all heads match durable state, and live is not ahead.
- backend `integration/importer` `93389265`, `main` `c23b9d9f`
- mobile `main` `affc2818`
- extension `main` `0111be66`, `land/s4-r6` `8901d5f5`
- agent-context `1ebbed76`
- private evidence `3f627e88`

No open PR targets `integration/importer`. Integration CI is green except the known Danger title check (class C).

**LANDED:** accepted backend through R (`93389265`), mobile through UX-03c and the CI correction, extension `main`. S7-L and S8-C replacements are not landed.

**ACTIVE:**
- RT-2 runtime re-provision (parent, heavy slot).
- S7-L worker correction phase 1 (source only, `s7_l_worker_correction_muh68jv6`, T4 requested `claude_fable_5_1`).
- S8-C gate commit is queued next on the slot.

**BLOCKED:**
- S8-F on accepted S8-C.
- S8-G on accepted S7-L and S8-C.
- The composition/landing of both on acceptance.

**OWNERSHIP:**
- Parent daceddc8: executive; S8-C mechanical completion; runtime; publication and landing.
- S7-L worktree: sole writer `s7_l_worker_correction_muh68jv6`.
- No predecessor worker holds authority.

**HEAVY SLOT:** the lock file was created fresh by RT-2's in-process `flock -n` at 16:22:50Z. It was absent in this sandbox; historical inode 691716 is not present. The queue is in `SCOPE.md`.

**OPEN A/B:**
- S7-L B (proof-tool): OLD-client runtime identity. Closure is being built.
- S8-C B (proof-tool): raw schema `cmp`. Closure WIP is ready.
- No product-defect A/B is open.

**OWNER-RESERVED:**
- PR #530 production promotion.
- Extension PR #27 non-author approval.
- S8-D/E principal policy (D-S8-2).
- G3-AUTH.
- Chrome Web Store, flags/readers, real accounts, spending, protection/security.

**NEXT:**
1. RT-2 steps 2–3 (formatter, lane provisioning).
2. S8-C gate commit, v6 export, v4 binding.
3. Relay the slot to the S7-L gates and v4 binding.
4. Dual T4 changed-question reviews for each candidate.
5. Serialized single v4 PG proofs, then acceptance and landing to `integration/importer`, then S8-F/S8-G.

BRADLEY DECISION REQUIRED: NO
