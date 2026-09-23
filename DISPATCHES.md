# Active TGP execution register

Updated 2026-09-23 for EXEC-6c2a68ac. Current contract: `execution/6c2a68ac/SCOPE.md`. All listed children are individually T4; cumulative S2/S5/S6 integrations are T4. Canonical T4 builder is Claude Fable 5 / High. Parent alone publishes private state and performs evidence disposition.

| Slice | Worker ID | Requested model | Sole writes | State |
|---|---|---|---|---|
| S2 exact substrate restore | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | restoration paths in SCOPE | COMPLETE; exact receipt accepted, ownership released |
| S2 V61 controls | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | enumerated grant runtime paths and `execution/6c2a68ac/s2-v61-result` | ACTIVE upon parent message; one five-set block, stop first failure; exclusive runtime slot |
| S5 V31 independent A | `audit_s5_v31_lens_a_mue9eid4` | Parent inheritance | `execution/6c2a68ac/audits/s5-v31-a` | COMPLETE; material S5-V31-A-01 exact-binding defect, source closure denied |
| S5 V31 independent B | `audit_s5_v31_lens_b_mue9eidl` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v31-b` | ACTIVE; read/hash/diff only, no peer |
| S5 V2 failed-result/recovery A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s5-v2-result-a` | ACTIVE; read/hash/diff only, no peer |
| S5 V2 failed-result/recovery B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v2-result-b` | ACTIVE; read/hash/diff only, no peer |
| S6 exact substrate restore | `restore_s6_substrate_mue9osen` | Claude Fable 5 / High | fresh `source/mobile`, `worktrees/s6-diagnostic`, `execution/op88/s6-c6-prep`, `execution/6c2a68ac/s6-restore` | ACTIVE; source-only, no implementation/runtime/install |

Prior e8d546f9 dispatches, installations, PIDs, slots and grants are preserved historical evidence only. S4 native proof is accepted and closed. S2 V61 is activated by `execution/6c2a68ac/S2_RESTORATION_ACCEPTANCE_AND_ACTIVATION.md`. S5 runtime is blocked by material exact-binding finding S5-V31-A-01; the second independent review continues. S6 implementation/runtime are held. S1 schema/generator ownership remains reserved and unassigned.

No remote product action, canonical lock operation, install, DB, browser, product test, production/customer action or new spending is active. Source review may overlap the sole S2 stub-only runtime grant.
