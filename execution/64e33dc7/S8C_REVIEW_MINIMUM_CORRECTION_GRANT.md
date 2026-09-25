# S8-C review-minimum correction grant

Parent disposition, 2026-09-25 05:14Z. Sole writer remains `s8_c_replacement_builder_muge72rc`, cumulative T4. This is a narrow ordinary follow-up to frozen head `af9f7f5438fa545394b6d28792411439ded66caf`, tree `62a8071e544e6a307537bd08c55b52e2a9af4e7d`. Preserve that head, its parent `527fe2bc`, every original receipt, checkpoint, failed gate and binding version. No rewrite, amend, push or acceptance.

## Actual B findings and minimum closures

Reviewer B's `s8c/reviews/REVIEW_B.md` identifies two contract deviations. Parent independently read the relevant source and frozen contract sections 3.5, 3.7 and 4.3. These are B findings scoped to S8-C acceptance and its first PG-proof grant, not a reopening of accepted S8-A/B. Do not defer or relabel them C.

- B1: `persistEvidence`, with declared native rules and existing created provenance, falls through after a failed `verifyTarget`. It upserts evidence and overwrites the created provenance reason with `no_native_client_principal`. This misstates coach deletion and identity conflicts. Minimum closure: return the failed verification outcome before any evidence/provenance write. Preserve `native_target_removed` for removed/archived targets and `identity_conflict` for foreign/kind mismatches, rather than flattening both into one reason. Keep successful native replay and the genuinely new client-linked evidence path unchanged. Add focused regression coverage that the failed verification returns its existing exact reason and performs no evidence or provenance mutation.
- B2: a present enum key absent from the explicit enum map emits `invalid_value:<field>` instead of the contract's `enum_unmapped:<field>`. Add only `enum_unmapped` to the existing code vocabulary and qualified-code set, emit it for the map-miss branch, and correct that test expectation. Preserve invalid raw-type / invalid mapped-destination behavior, allowed values, and existing absent/default behavior. No other currently unused contract codes or rule features are in scope.

Closing these defects unlocks final exact-head/binding re-attestation and a separately granted first S8-C PG proof. It does not change principal policy, schema, readers, orchestration or activation.

## Exact writable product surface

Only these five paths may differ from `af9f7f54`:

- `src/scout/reconstruct/native/native-writers.ts`
- `src/scout/reconstruct/native/native-rules.ts`
- `src/scout/reconstruct/native/native-contract.ts`
- `test/scout/reconstruct/native/native-writers.spec.ts`
- `test/scout/reconstruct/native/native-rules.spec.ts`

Use existing test helpers without editing their files. No test skip/deletion, assertion weakening, source sidecar, mapping spec, engine, schema, generated artifact, dependency, workflow, proof source or contract document changes. If the exact minimum cannot fit this surface, report the concrete dependency before expanding it. C findings create no fixes, gates or controls.

## Source now; gates only after explicit relay

Source preparation and an exact versioned checkpoint may proceed now, parallel to S7-L runtime failure disposition. S7-L remains the sole heavy-slot owner through cleanup. Do not acquire the lock, install, generate, format, compile, test or commit until parent explicitly relays the slot.

After relay: hold the existing canonical lock nonblocking in the actual gate process; run scoped formatter/lint on the changed files, then the four existing native unit suites (`native-writers`, `native-rules`, `engine-handoff`, `native-families`) with default Jest configuration. Run genuine ordinary hooks with heap4096 and the pinned isolated formatter. Do not repeat the full mapper/contract/accepted suites, generator, separate R75 when supplied by the genuine hook, or any PG work. Preserve every failure; stop rather than replay a failed gate automatically.

Make one ordinary follow-up commit as Bradley Gleave `<bradley@bradleytgpcoaching.com>` for author and committer, no trailers or hook bypass. Export to a fresh checkpoint version and create a separate `s8c/review-correction/CORRECTION_RECEIPT.md`. Release the slot promptly.

## Versioned binding and changed-question review

Prepare `s8c/binding/v3/` from the preserved v2 binding. The executable driver delta is only EXPECT_HEAD, EXPECT_TREE and the mechanical versioned D/output path. Verify all six proof blobs, fixture, base and tool pins unchanged; record exact v2-to-v3 diff and filled hashes. Never mutate old bindings or change a pin to conceal a mismatch.

Both existing independent reviewers finish their initial review against committed `af9f7f54`. Once final pins are delivered, they review only these closures, new lineage/gates and versioned binding, writing new reports and not reading each other's reports. Any additional concrete finding from the still-running independent review will be separately dispositioned. No final GO while a real A/B remains. No S8-C PG execution is authorized by this grant.

## Amendment: second independent review, 2026-09-25 05:16Z

Reviewer A's initial `s8c/reviews/REVIEW_A.md` is now complete and immutable. Parent read it and the referenced committed code and contract. Two additional narrow closures join this same ordinary follow-up, not a separate build cycle.

- A-review A1 is classified by the parent as B, proof-only, rather than a program-wide A: the legacy `client_history` case in `test/rls-g2-s8c.spec.ts` stages a row on fixture platform `s8c-proof`, but that accepted legacy path uses the repository mapping registry, not the native injection seam. The one-run assertion would deterministically fail. Correct only this `stage()` call to supply `'coach', 'intent', 'truecoach'`, preserving payload, all assertions and all production registry behavior. The existing unit example uses the same valid repository source.
- A-review B1 is a real child-identity contract deviation. Parent chooses the source correction, not the proposed record-only contract amendment. The unique provenance key omits `native_kind`, and top-level source IDs are arbitrary text: a top-level ID can equal a child's length-prefixed encoded ID. Child encoding is injective among children but does not by itself separate parent and child namespaces. Honor frozen section3.3: child `entity_type = 'workouts.exercise'`; top-level stays `workouts`. Change the child provenance key and matching `countUnresolvedChildren` filter together; retain coach/namespace/native-kind/prefix/outcome filters. Update only the corresponding unit/PG assertions and add a focused unit regression showing a top-level identity equal to an encoded child ID remains distinct, with unresolved children still re-reported on replay. No schema, accepted identity key or contract amendment.

The permitted surface is now exactly the original five paths plus:

- `src/scout/reconstruct/native/native-provenance.ts`, only the child-count family discriminator and any directly required import.
- `test/rls-g2-s8c.spec.ts`, only the legacy platform call and child-provenance entity-type expectations required by the correction.

The existing `native-contract.ts` surface may hold a shared fixed child-family constant if needed; no new family registration or DTO enum. Existing test helpers stay unchanged. Total permitted delta is seven paths. Preserve all existing assertions, including native-kind, unresolved child counts, tenancy, legacy target kinds, replay and atomicity.

The v3 executable binding delta is now exactly FOUR lines: EXPECT_HEAD, EXPECT_TREE, EXPECT_SPEC_BLOB and the mechanical D/output path. The other five proof blobs, fixture, base-file and tool pins stay unchanged. Record and review the exact v2-to-v3 delta. This supersedes the earlier three-line/six-unchanged-proof-blob wording only.

## Source-gate relay, 2026-09-25 05:16Z

S7-L's failed proof completed its existing bound cleanup at05:14:22Z after a parent-verified TERM of only the completed Jest stage process group. Terminal rc124, cleanup rc0, postgres0, listener0, survivor none, data retained. Parent subsequently observed no canonical lock holder, no postgres or test/compiler process, and free55641/55642. Lock inode691716 remains intact. The only Node processes observed were the platform code-mode daemons415/454.

S8-C is now the sole source-gate grantee for this complete seven-path correction. Finish and checkpoint source, then execute the scoped formatter/lint, four native unit suites and genuine hooked ordinary commit described above, holding the canonical lock in the actual working process and preserving every output. Include the changed PG spec in scoped formatter/lint and the genuine TypeScript hook, but do not execute any PG-config test. Stop on a failure and report its exact minimum cause; no automatic rerun. Export the new candidate, fill/freeze v3 and release promptly. S7-L may only perform read-only failure disposition meanwhile. No S8-C PG proof is granted.
