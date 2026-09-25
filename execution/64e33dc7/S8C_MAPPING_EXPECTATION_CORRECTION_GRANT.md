# S8-C canonical-family expectation correction

Parent disposition, 2026-09-25. Sole builder remains `s8_c_replacement_builder_muge72rc`, under the existing cumulative T4 slice. Preserve committed candidate `527fe2bc24f954b26c0485c90345f237ce39a09d`, tree `d87a96267c2ec4f4d79d83d26e6b2928a56c8a85`, its exact exports, failed gates and original filled binding.

## Narrow B finding

`test/scout/reconstruct/mapping-spec.spec.ts:266-268` assumes every `RECONSTRUCT_FAMILY` resolves for TrueCoach. The authorized canonical addition of `programs` changes that dependency, but accepted `truecoach.json` still declares only `clients`, `workouts` and `client_history`. Correct fail-closed behavior is `unresolved_family:programs`.

Class B, proof-only. Concrete harm: the affected test falsely rejects the correct unsupported-family result, preventing a clean source-gate decision for S8-C. Minimum closure: retain the existing `notes` assertion and all three supported-family checks; explicitly assert that the newly canonical `programs` family is unresolved for this unchanged source. Execution unlocked: clean targeted source gate, final exact-head/binding review, then separately granted first PG proof.

## Exact writable delta and sequence

Only `test/scout/reconstruct/mapping-spec.spec.ts`, inside that one repository-spec case, may change from `527fe2bc`. Keep the canonical-family iteration with an explicit `programs` unresolved branch, or enumerate the same three supported constants and add a separate explicit `programs` unresolved assertion. A directly descriptive test-title adjustment is permitted. No skip, assertion deletion, source mapping change, parser change, product file, generated artifact or dependency change.

The source edit may proceed now. S7-L is the sole heavy source-gate grantee; do not acquire the slot or run gates until explicit parent relay. After relay, run only the changed test file and necessary scoped format/lint plus genuine ordinary hooks with heap4096. Do not replay the unaffected native/mapper suites, generator, R75 separately if the genuine hook supplies it, or any PG proof.

Make one ordinary follow-up with Bradley Gleave `<bradley@bradleytgpcoaching.com>` as author and committer, no trailers or bypass; no amend or push. Export the new exact head/tree/delta in a new checkpoint version and release the slot. Preserve the original receipt and create a separate correction receipt.

Prepare a new filled binding under `s8c/binding/v2/`, retaining the original files unchanged. Only the new head/tree pins and mechanical versioned binding/output paths change; six proof blobs, accepted-base ancestry, tool/fixture pins and execution behavior remain unchanged. Record the binding delta and hashes. No execution is granted by binding preparation.

The two independent reviewers already examining `527fe2bc` should continue that new-source review using the committed object, then bind this test-only follow-up and final versioned driver without repeating unchanged analysis. Parent supplies final pins when ready. No final GO or PG grant while this B remains open.

## Source-gate relay, 2026-09-25 05:01Z

S7-L's actual correction driver released the canonical lock at04:57:54Z, rc0, at clean head `54970cd937afc8dea689b33243961abfef8b9dd6`. Parent read its terminal record and at05:00:50Z/05:01:10Z verified no lock holder or heavy test/database process; the two remaining Node processes are the platform code-mode daemon, not candidate work.

S8-C is now the sole source-gate grantee for the exact one-test correction above. Its prepared `s8c/correction/s8c-correction-gate.sh` may run once after taking the existing canonical lock nonblocking in the working process. Perform the scoped format/lint, changed-file Jest and genuine hooked ordinary commit, preserve every output, and release promptly. Then finish the versioned export and v2 binding source-only. No PG action is authorized; S7-L remains frozen for changed-question review.
