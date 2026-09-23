# Active TGP execution register

Updated 2026-09-23 for EXEC-6c2a68ac. Current contract: `execution/6c2a68ac/SCOPE.md`. All listed children are individually T4; cumulative S2/S5/S6 integrations are T4. Canonical T4 builder is Claude Fable 5 / High. Parent alone publishes private state and performs evidence disposition.

Owner Safety ROI amendment at 08:56 PDT applies: A/B/C classification, C never blocks or creates cycles, no recursive validation or duplicate evidence. Bottleneck: active S3 integration after accepted S1/S2 proof. S6 source work is independently active; S5 canonical runtime queues without blocking either.

| Slice | Worker ID | Requested model | Sole writes | State |
|---|---|---|---|---|
| S2 exact substrate restore | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | restoration paths in SCOPE | COMPLETE; exact receipt accepted, ownership released |
| S2 V61 controls | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | enumerated grant runtime paths and `execution/6c2a68ac/s2-v61-result` | COMPLETE AND ACCEPTED; five raw0, resultd0a1e406/621 entries; dual result review closed |
| S2 V61 result A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s2-v61-result-a` | COMPLETE; bounded acceptance, no A/B blocker; C qualifications retained |
| S2 V61 result B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s2-v61-result-b` | COMPLETE; bounded acceptance, no A/B blocker; controls accepted |
| S2 fresh setup | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | exact setup grant write set and `execution/6c2a68ac/s2-setup-result` | COMPLETE AND ACCEPTED; raw0/0/0, seal7f1a68c0/29 entries, ownership returned |
| S1/S2 real composition proof | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | exact real-proof grant write set and `execution/6c2a68ac/s2-real-composition-result` | COMPLETE AND ACCEPTED; raw0, guard72/72, composition68/68, discriminator48/48; sealbbde4b0b/103 entries; runtime released |
| S1/S2 real-result A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s1s2-real-a` | COMPLETE; scoped acceptance, no A/B, seal448a8b60 |
| S1/S2 real-result B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s1s2-real-b` | COMPLETE; scoped acceptance, no A/B, sealab50754d |
| S5 V31 independent A | `audit_s5_v31_lens_a_mue9eid4` | Parent inheritance | `execution/6c2a68ac/audits/s5-v31-a` | COMPLETE; material S5-V31-A-01 exact-binding defect, source closure denied |
| S5 V31 independent B | `audit_s5_v31_lens_b_mue9eidl` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v31-b` | COMPLETE; material P1 acknowledgement race V31-B-01 routed to V32 |
| S5 V2 failed-result/recovery A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s5-v2-result-a` | COMPLETE; A/B reconciled, historical failure/closure accepted with qualifications only |
| S5 V2 failed-result/recovery B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v2-result-b` | COMPLETE; A/B reconciled; historical failure and exact-holder closure accepted with qualifications only |
| S6 exact substrate restore | `restore_s6_substrate_mue9osen` | Claude Fable 5 / High | restored paths in SCOPE | COMPLETE; d51a/tree62bf67b8, packet19/19/subset11/11; no runtime |
| S5 V32 narrow binding repair | `repair_s5_binding_mue9vjso` | Claude Fable 5 / High | `execution/6c2a68ac/s5-v32-builder` | COMPLETE; frozen top seal1f23abdc, sourceaddc713d, controlsb99771a7; no runtime |
| S5 V32 final A | `audit_s5_v31_lens_a_mue9eid4` | Parent inheritance | `execution/6c2a68ac/audits/s5-v32-a` | COMPLETE; source CLOSED, one private run grantable, no A/B blocker; seal9bbb8a26 |
| S5 V32 final B | `audit_s5_v31_lens_b_mue9eidl` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s5-v32-b` | COMPLETE; source CLOSED/private proof grantable, no A/B blocker; seal5a85d3e1 |
| S5 V32 private controls | `repair_s5_binding_mue9vjso` | Claude Fable 5 / High | exact private-control grant write set | COMPLETE AND ACCEPTED; raw0/11PASS, resulta21622ee/66 entries, slot released16:31:09Z |
| S5 product substrate restore | `restore_s5_source_mue9wsph` | Claude Fable 5 / High | `worktrees/s5-r4`, `execution/6c2a68ac/s5-source-restore` | COMPLETE and accepted; head143d + patchc36258b3, exact6850b32e fingerprint; no runtime |
| S3 PREP2 substrate restore | `restore_s3_candidate_mue9wspd` | Claude Fable 5 / High | `worktrees/s3-prep2`, `execution/6c2a68ac/s3-restore` | COMPLETE and accepted; a584a1b9 from both parents, receiptbd9e6cd8; no integration/test/commit |
| S3 PREP2 integration | `restore_s3_candidate_mue9wspd` | Claude Fable 5 / High | exact S3 integration grant write set; `execution/6c2a68ac/s3-integration-result` | STOPPED step03 postcheck1; install/generate raw0, resultbf7800bd/20 entries; no commit, slot released |
| S3 step03 observation correction review | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s3-step03-bfix/**` | COMPLETE; GRANTABLE, no A/otherB, seal25f049dd; no retry/install/regenerate |
| S3 PREP2 continuation | `restore_s3_candidate_mue9wspd` | Claude Fable 5 / High | exact continuation write set; `execution/6c2a68ac/s3-integration-continuation` | CONSUMED;03R/04–07raw0, exact hooked commitbe0ba827; extra08raw127 preserved, existing08D accepted; sealca604a0d/23 |
| S3 remaining validation | `restore_s3_candidate_mue9wspd` | Claude Fable 5 / High | exact original09–14 write set; `execution/6c2a68ac/s3-integration-validation` | COMPLETE; allraw0,31 suites/825 tests PASS, seal1513911d/27, bundled204a582; runtime returned |
| S3 composed proof preparation | `restore_s2_substrate_mue9eidh` | Claude Fable 5 / High | `execution/6c2a68ac/s3-composed-proof-prep/**` | ACTIVE SOURCE ONLY; minimal binding successor to accepted runner/fixture, no product/WT/runtime writes |
| S3 final exact-head A | `audit_s5_failure_lens_a_mue9osec` | Parent inheritance | `execution/6c2a68ac/audits/s3-final-head-a/**` | ACTIVE source/applicability portion; final runtime verdict pending sealed targeted and composed results |
| S3 final exact-head B | `audit_s5_failure_lens_b_mue9oser` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s3-final-head-b/**` | ACTIVE independent source/applicability portion; same final result dependency, no peer conclusion |
| S6 setup/C6 source successor | `restore_s6_substrate_mue9osen` | Claude Fable 5 / High | `execution/6c2a68ac/s6-exclusion-v1/**` | COMPLETE FROZEN; seal001b840f/28 entries; source-only, ownership released |
| S6 exact compositions A | `audit_s5_v31_lens_a_mue9eid4` | Parent inheritance | `execution/6c2a68ac/audits/s6-exclusion-v1-a/**` | COMPLETE; both SOURCE-CLOSED, no A/B, seald9a9d4c5 |
| S6 exact compositions B | `audit_s5_v31_lens_b_mue9eidl` | Claude Fable 5 / High | `execution/6c2a68ac/audits/s6-exclusion-v1-b/**` | COMPLETE; both SOURCE-CLOSED, no A/B, sealb64eb282 |
| S6 actual setup then C6-only | `restore_s6_substrate_mue9osen` | Claude Fable 5 / High | exact separate stage-grant write sets | SETUP ACTIVE sole runtime; C6 NOT ACTIVE pending setup acceptance and separate activation |

Prior e8d546f9 dispatches, installations, PIDs, slots and grants are preserved historical evidence only. S4 native proof is accepted and closed. S2 controls/setup/real proof and S5 private proof are consumed and closed. S3 prior stopped waves remain frozen; exact hooked be0ba827 is preserved. S6 dual source review is complete. S1 schema/generator ownership remains reserved and unassigned.

S3 original09–14 is COMPLETE and its frozen1513911d packet supplied to the same final-head reviewers. Composed-proof source preparation remains active. S6 SETUP exclusively owns runtime under `S3_TARGETED_RESULT_AND_S6_SETUP_ACTIVATION.md`; C6 and S5 setup/T0 remain NOT ACTIVE. No browser, remote product action, production/customer action or new spending is active. Bradley decision required: NO.
