# S7-L lifecycle build brief grant (T4 planning, read-only) — parent ~20:58Z

S7-L is now the critical dependency for UX-04/05 binding, S8-G and S9's terminal arbiter (S8_BRIEF §1, UX04_06_BRIEF blockers). Produce a source-bound build brief so the build activates the moment C lands.

Scope: L1–L4, L6 (+ L5/L9 riding the same contract regeneration) per `s8-prep/S8_BRIEF.md` §1: server-accepted Start/cancel/deadline; single terminal arbiter with `cancelled` representable and extension claim demoted to input; execution epoch + commit fencing; scout `intent_id` bound to server-owned `ImportIntent`; per-family run counts; status read for mobile/extension. Excludes L7 (G3-AUTH) and L8 (retention/code retirement) — name the seam only.

Deliver `execution/ce3748cb/s7l-prep/S7L_BRIEF.md` (≤200 lines): exact current source facts (file:line on integration/importer c7a5fe8d and N/Q1 61b93cff), proposed contract (states, transitions, invariants, error codes, compat for legacy intents and old extension builds), migration expand/contract shape and promotion stage, path-disjoint slices with tier/owned paths/acceptance (PG proof needs), overlap map vs C phase-2, S8-A, S8-B and the contract generator, and any decision that is genuinely owner-reserved. No edits, installs or runtime.
