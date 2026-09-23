# Active TGP execution register

Updated 2026-09-23 for EXEC-6c2a68ac. Current contract: `execution/6c2a68ac/SCOPE.md`. All listed children are individually T4; cumulative S2/S5/S6 integrations are T4. Canonical T4 builder is Claude Fable 5 / High. Parent alone publishes private state and performs evidence disposition.

Owner Safety ROI amendment at 08:56 PDT applies: A/B/C classification, C never blocks or creates cycles, no recursive validation or duplicate evidence. Bottleneck: active S2 fresh setup → real proof → S3 integration. Parallel S5 final reviews must converge to one private execution; no unrelated task is blocked by S5.

| Slice | Worker ID | Requested model | Sole writes | State |
|---|---|---|---|---|
| S2 exact substrate restore | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | restoration paths in SCOPE | COMPLETE; exact receipt accepted, ownership released |
| S2 V61 controls | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | enumerated grant runtime paths and `execution/6c2a68ac/s2-v61-result` | COMPLETE AND ACCEPTED; five raw0, resultd0a1e406/621 entries; dual result review closed |
| S2 V61 result A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s2-v61-result-a` | COMPLETE; bounded acceptance, no A/B blocker; C qualifications retained |
| S2 V61 result B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s2-v61-result-b` | COMPLETE; bounded acceptance, no A/B blocker; controls accepted |
| S2 fresh setup | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | exact setup grant write set and `execution/6c2a68ac/s2-setup-result` | ACTIVE upon parent activation message; sole runtime slot, S10/S20/S30 once |
| S5 V31 independent A | `audit_s5_v31_lens_a_mue9eid4` | Parent inheritance | `execution/6c2a68ac/audits/s5-v31-a` | COMPLETE; material S5-V31-A-01 exact-binding defect, source closure denied |
| S5 V31 independent B | `audit_s5_v31_lens_b_mue9eidl` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v31-b` | COMPLETE; material P1 acknowledgement race V31-B-01 routed to V32 |
| S5 V2 failed-result/recovery A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s5-v2-result-a` | COMPLETE; A/B reconciled, historical failure/closure accepted with qualifications only |
| S5 V2 failed-result/recovery B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v2-result-b` | COMPLETE; A/B reconciled; historical failure and exact-holder closure accepted with qualifications only |
| S6 exact substrate restore | `restore_s6_substrate_mue9osen` | Claude Fable 5 / High | restored paths in SCOPE | COMPLETE; d51a/tree62bf67b8, packet19/19/subset11/11; no runtime |
| S5 V32 narrow binding repair | `repair_s5_binding_mue9vjso` | Claude Fable 5 / High | `execution/6c2a68ac/s5-v32-builder` | COMPLETE; frozen top seal1f23abdc, sourceaddc713d, controlsb99771a7; no runtime |
| S5 V32 final A | `audit_s5_v31_lens_a_mue9eid4` | Parent inheritance | `execution/6c2a68ac/audits/s5-v32-a` | COMPLETE; source CLOSED, one private run grantable, no A/B blocker; seal9bbb8a26 |
| S5 V32 final B | `audit_s5_v31_lens_b_mue9eidl` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v32-b` | ACTIVE; independent final-byte closure and one-shot grantability |
| S5 product substrate restore | `restore_s5_source_mue9wsph` | Claude Fable 5 / High | `worktrees/s5-r4`, `execution/6c2a68ac/s5-source-restore` | COMPLETE and accepted; head143d + patchc36258b3, exact6850b32e fingerprint; no runtime |
| S3 PREP2 substrate restore | `restore_s3_candidate_mue9wspd` | Claude Fable 5 / High | `worktrees/s3-prep2`, `execution/6c2a68ac/s3-restore` | COMPLETE and accepted; a584a1b9 from both parents, receiptbd9e6cd8; no integration/test/commit |

Prior e8d546f9 dispatches, installations, PIDs, slots and grants are preserved historical evidence only. S4 native proof is accepted and closed. S2 V61 control activation is consumed and closed; fresh setup activation is current. V32 A closes the prior S5 B findings; B final review is outstanding before any private control activation. S6 implementation/runtime are held. S1 schema/generator ownership remains reserved and unassigned.

S2 controls are ACCEPTED at stub scope. Fresh setup is activated by `S2_V61_ACCEPTANCE_AND_SETUP_ACTIVATION.md`: only its named install endpoints, canonical lock steps and environment writes. No DB/server, browser, product test, remote product action, production/customer action or new spending is active. All other lanes remain source/review-only.
