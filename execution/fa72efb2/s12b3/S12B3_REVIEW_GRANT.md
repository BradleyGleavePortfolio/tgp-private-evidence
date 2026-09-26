# S12-B3 independent T3 audit grant (EXEC-FA72EFB2)
Auditor: GPT-6 Sol. Read-only on /home/user/workspace/worktrees/fa72-s12b3 (a4d0b85c on mobile main a876268c). Inputs:
S12B3_BUILD_GRANT.md, s12b3_build.md, s12/S12_PILOT_READINESS.md L141; server contract in backend worktrees/fa72-s11d2 (scout import
status + roster DTOs/controllers). Focus: nothing renders success except server-mode `complete`; legacy/claimed values never shown as
server truth; null/absent → "not known yet", never 0 (check every numeric render incl. roster accounting); unknown enum/extra fields
→ explicit unrecognised state, and the decoder TOLERATES added fields (S11-E is about to add an honest roster accounting field for
unclassifiable staged rows — must not break decode); 404 handling matches the server's uniform-404 semantics; polling bounded and
stops on terminal/unmount/background; flag default off; copy plain and passes the banned-words test; contract fixture really derived
from the backend bytes (spot-check the tool); jest open-handle C1 — determine by running the 5 new suites with --detectOpenHandles
whether the new code leaks a timer/listener. Tests may be run under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`
while /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists (scoped suites only; no full jest). No edits, no push.
Write s12b3/s12b3_review.md: verdict GO/NO-GO; A/B five-field form; C list; commands+RC. Rules: execution/fa72efb2/WORKER_RULES.md.
