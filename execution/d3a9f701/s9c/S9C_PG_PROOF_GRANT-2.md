# S9C-PROOF-2 GRANT — parent d3a9f701, 2026-09-26T03:42:52Z
- PROOF-1 (binding v1) refused rc=70 at preconditions before any PG action: class B runner defect (`git show | grep -q` under pipefail → SIGPIPE 141 false refusal). Preserved at binding/v1/run/. Not a consumed product proof.
- Binding v2 = v1 + captured-bytes greps only (DELTA-from-v1.diff). Script sha256 627583df38f14a286b25b817e4b4e04abbcfa6317f0af2d8abbfe577c9144520; fixture sha256 ca1e563d9056169aacb60c8bf95d6a41d34ff0619eadc7a998972fe9d8dc1085.
- Reviews: A GO (fixture destroy NOT approved; no destroy is part of this grant), B GO (C-B1..C-B3 hygiene recorded).
- Candidate 98133050bb62cc8a506badef67ccfcc317601db1 / tree 7756a39f / parent 5407efae; expects jest rc 0 and "Tests: 10 passed, 10 total".
- ONE run. On failure: preserve, classify; never auto-rerun.
