# L0 GRANT: Learn-and-Remember (cross-repo decision record)
Grade: **T4**. Why: it sets the trust policy for AI output that drives importer writes, and learned knowledge from one coach's account is reused
for other coaches, so the privacy/PII boundary and the tenancy boundary are both in scope. Builder: claude_fable_5. Reviews: gpt_6_sol (A) and claude_opus_5_5 (B), both on the final head.

## Owner requirement (Bradley, 2026-09-27 20:51Z, verbatim)
"We are supposed to be able to say "This is a new site" -> call AI support, decode their data structure, autonymously LEARN AND REMEMBER that
structure and complete the import in one process to NEVER have to do platform specific work again"

## Current truth (verified by parent 20:55Z)
- Extension (tgp-importer-extension main a889f4ad):
  - Built: capture (shared/capture*.js), blueprint contract + normalizer, generic replay engine (shared/replay/*),
    and C2a inference primitives (shared/blueprint/{input,shapes,url-templates,order}.js). C2b-0A merged (#21).
  - Stalled since 2026-09-10: C2b-1 endpoint roles (#20, CI red), and the goal-state doc (#19: authorization + one Start + zero coach actions,
    ≤5:00, path C2a→C2b→C2c→C3a→A1→A2→A3→A4→C3b→V1).
  - Plans: docs/REAL_GOAL_EXECUTION_PLAN.md, docs/AUTO_DISCOVERY.md.
  - Still hand-coded: extractors/truecoach/*.
- Backend (integration/importer 9668af6c):
  - The generic engine is data-driven per platform: src/scout/reconstruct/mapping-spec.ts, source-mapper-registry.ts,
    native/native-rules.ts, and src/scout/induction/* (S10 doc docs/decisions/2026-09-26-s10-induction.md).
  - BUT per-platform specs are JSON committed in src (build time). Real platforms: only truecoach.json (no native rules, no manifest).
  - No AI in src/scout. An existing AI channel is src/diagnostic/ai-roadmap.service.ts (OpenAI SDK → Perplexity sonar-pro, PERPLEXITY_API_KEY).
- S12-B7 (hand-written mapping for the pilot platform) is DELETED. It contradicts the requirement.

## Deliverable (doc only, no code)
`docs/decisions/2026-09-27-learn-and-remember.md` on backend branch `cand/x42/learn-doc`, off integration/importer 9668af6c, as one commit.
Author Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI co-author. Target ≤600 lines, with file:line citations into both repos. Must decide:
1. The one-process flow: authorize → Start once → observe → decode → learn → crawl → map → reconstruct → verify → verdict. It must bind to #19.
   Say which existing extension chain steps survive, which merge, and which are deleted.
2. Where AI runs (backend vs extension) and on what inputs. Redacted structure/samples only; never credentials. Minimise PII sent to the model, and say what is sent.
3. AI output grammar: DATA ONLY (blueprint hints, SourceMappingSpec, InductionManifest, native rules), never executable code. Name the exact
   deterministic validators that must accept it before any source request or any write, and name the conformance checks against the actual staged rows.
4. MEMORY: the learned-platform store (schema, scope, key = canonical platform slug + structure fingerprint, versioning, promotion only after a
   verified import, drift detection and invalidation, no secrets and no PII). How the runtime registry loads learned specs next to the file specs,
   so that a new platform needs zero deploys and CORE DIFF = 0.
5. Truthfulness: AI never decides identity, writes or `complete`. How a learned source earns a coverage basis, and the honest `partial` otherwise.
6. Bounds: model calls per run, tokens, latency, cost, timeouts, and failure/fallback behaviour when AI is unavailable.
7. The slice plan: the ordered slices across both repos, each graded T0–T4, each ≤400 prod LOC, with dependencies. Mark which slices can
   run in parallel now. Define the V1 proof: a real platform that has never been hand-mapped, imported end to end.
8. Owner-reserved questions, listed and never assumed: live source account access, provider or spend changes, production flags.
Say NO to anything not needed for V1.

## Report
Reply with: branch, head SHA, line count, the slice table, and your open questions. Write execution/42d8c5b5/learn/L0_BUILD.md in the
evidence repo (commit it; do not push the evidence repo; the parent commits it).
