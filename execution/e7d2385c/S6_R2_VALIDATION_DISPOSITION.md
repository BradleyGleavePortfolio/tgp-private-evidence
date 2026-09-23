# S6 R2 validation disposition

Parent EXEC-e7d2385c accepts the observed 00–09 evidence at its qualified boundary on candidate tree `acb41c2baab6e856573d86e02135430c3304828b`, baseline HEAD `d51a191098f483cea9abec6cc7e9f3beffd18c06`. This is not final S6 acceptance or a claim that every strict postcheck returned zero.

The same two independent source reviews continued into actual-result qualification. Neither reviewer requests a product, test, runner, diagnostic or rerun cycle for the recorded observations.

## Observed evidence

| Step | Actual result | Parent disposition |
|---|---|---|
| 00 | Pins pass, raw/status0 | Carry |
| 01 | Typecheck raw0, zero TypeScript errors | Carry |
| 02 | Identity suite19/19, raw0, normal exit | Carry |
| 03 | RootNavigator gate suite4/4, raw0, normal exit without the prior warning | Carry |
| 04 | Persistence suite5/5, raw0 | Carry |
| 05 | Sign-out suite4/4, raw0 | Carry |
| 06 | Five regression suites25/25, raw0; strict postchecks1/status1 | Carry actual regression evidence with qualifications below; strict refusal remains unchanged |
| 07 | Two frozen hazard inputs placed and hash verified, raw0 | Carry |
| 08 | Expected raw1, three intended failures and three passes, exact assertion sites188/208/240, normal exit; strict postchecks1/status1 | Carry the expected hazard outcome with the count qualification below |
| 09 | Only the two temporary hazard copies removed by hash guard, raw/status0 | Carry; porcelain10, candidate tree unchanged, real index unstaged |

S6 released the heavy slot at `2026-09-23T21:17:02Z`. No runner, Jest or TypeScript process remained, and the recorded holder end line confirms the terminal cleanup.

## Qualifications, not new work

- **Regression pattern matches:** The unanchored `todo` alternative matched `legacy-code-todo-rewrite` in two Jest stack-trace filenames, not skipped or todo tests. The exact25/25 summary and five passing suite records remain attributable.
- **Regression exit warning:** The one-second warning is genuine and remains recorded. The process subsequently exited on its own with raw0 about18 seconds after launch, well inside its600-second bound; the warning's owner remains unknown and is not labelled new or pre-existing.
- **Hazard mode count:** One describe header plus three required failure-detail headers produce four matches, not the frozen constant's one. The postfix mode, absence of baseline-singleton mode, expected pass/fail identities and exact failure sites establish the intended proof without another run.

Both independent reviewers classify these as C qualifications with no new A/B blocker. Parent adopts that bounded disposition without rewriting the original criteria, receipt statuses or earlier failed P3 evidence.

## Independent seals

- **Review A, step06:** `RUNTIME06_MANIFEST.sha256` = `d68a580ecc108027dfd19e88d08fa7f1875520d51690ad590a5df54d9c967597`.
- **Review A, step08:** `RUNTIME08_MANIFEST.sha256` = `4af8af42fd22b19ea0fc7740a5a2ca93373e95353e8bf3b6c277fee1bd48b8d9`.
- **Review B, steps00–08:** `MANIFEST.runtime-r2.sha256` = `a6729e532929411c959ac84b43f7e7bafc999f154611a3ae699427629584cbbe`.

## Remaining ordinary commit boundary

The approved message remains byte-identical at SHA-256 `06e7ae2d560b4d535f8226e578e97453a168172117863a6e5e09b81033433a62`. Parent's pre-execution read found that sealed step21 still guarded the superseded message hash; no knowingly mismatched command was run.

Builder froze the minimum successor under `s6-r2-commit-binding/`: manifest `43a995ac300c20a6069ca80f962de19f894478ed5a14085298704001558c00ec`, command SHA-256 `a6e94f17635bdd355f7f3f906dc1486ff4e198aa4f3e40ce45199c3a3437ea64`. Its only change is the expected hash literal, with the original command preserved; the message, candidate, runner, steps20/22/23 and original validation packet are unchanged.

Both same-review binding checks are complete: A seal `d26a45208594f2bb2364f3357968c42e06df4af1f5d9edb3e7f22ac7b744e959`, B binding seal begins `6f7f51de`. S7 released the heavy slot at `2026-09-23T21:20:28Z` after its successful ordinary-hook commit.

Review B identified one remaining mechanical count literal: sealed step20 correctly stages the ten R2 paths but its postcheck still expects nine. Parent chooses the reviewer's receipt-qualification option rather than editing the sealed postcheck or creating another preparation cycle. This disposition applies only if step20 raw exit is0, staged tree is exactly `acb41c2baab6e856573d86e02135430c3304828b`, worktree equals index, exactly the ten frozen paths are staged, no untracked or hazard files remain, and the only strict mismatch is `staged paths expected=9 actual=10`.

Under that exact observed condition, preserve step20's postchecks1/status1 and continue to the approved alternate step21, then unchanged22/23. Any other mismatch stops execution. The count qualification is not a waiver of candidate, path, identity, message, hook, cleanup or final-head verification.

Steps20–23 require the parent's separate explicit activation and transfer; this document records the bounded disposition, not a claim that they ran. Mobile has no configured hooks, so the route is an ordinary no-bypass commit, not a claim of executed hook checks.

Final acceptance still requires the actual committed head, exact parent/tree/message/Bradley author and committer, empty trailers, clean status, bundle identity and both same-review final attestations. No product remote push, merge, deployment or customer action is authorized.
