# S8-C mapping-expectation correction receipt (S8C_MAPPING_EXPECTATION_CORRECTION_GRANT, relay 2026-09-25 05:01Z)

## Follow-up commit
- **Head** `af9f7f5438fa545394b6d28792411439ded66caf`, **tree** `62a8071e544e6a307537bd08c55b52e2a9af4e7d`, parent = frozen candidate `527fe2bc24f954b26c0485c90345f237ce39a09d` (tree `d87a9626…`, preserved, not amended). Branch `exec64/s8c-replacement`; porcelain 0.
- Author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; subject "S8-C: assert TrueCoach programs family unresolved"; no trailers, no `--no-verify`, no amend, no push.
- Delta from 527fe2bc: exactly `test/scout/reconstruct/mapping-spec.spec.ts` (blob `80ea0455…` → `9f5503a3…`, +9/−1; patch sha `a79caec2…`). `src/` tree identical to 527fe2bc; `prisma/` identical to base; the six PG-proof blobs identical to 527fe2bc (`checkpoints/v4/HEAD.txt`).
- Content: title now names both unresolved cases; `notes` unresolved assertion retained verbatim; canonical-family loop retained with an explicit `programs` branch asserting `{ ok:false, reason:'unresolved_family:programs' }`; `clients`/`workouts`/`client_history` still assert `{ ok:true, family }`. No skip, deletion, source mapping, parser, `truecoach.json`, artifact or dependency change.

## Gate record (`correction/run/`, one run)
- `s8c-correction-gate.log`: ACQUIRED 05:01:41Z pid 14229 fd9 inode 691716 (lslocks=1, no prior holder — S7-L released 04:57:54Z per grant) → DELTA verified single-file → PRETTIER_CHECK (pinned 3.9.9 prefix, offline) rc 0 → ESLINT rc 0 → JEST changed file only, 1 suite / 40 tests pass → STAGED_TREE `62a8071e…` → genuine hooked commit rc 0 (`commit.raw.log`: prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc 48 s at heap 4096, commit-msg no-ai-tokens all ✔) → HEAD/tree logged → **RELEASED 05:02:44Z** (fd9 closed at exit, lock file preserved). No native/mapper-suite, generator, separate R75 or PG replay. No failures this run.

## Export `checkpoints/v4/` (`MANIFEST.sha256`; v3 and earlier untouched, v3 manifest re-verified)
`s8c-af9f7f54.bundle` `6d58aa9d…` (verified OK; ref `refs/heads/exec64/s8c-replacement`; contains 527fe2bc and af9f7f54; prerequisite accepted base `93389265`), `HEAD.patch` `4e3cd732…`, `HEAD.txt` `9d57d56a…`, `CHANGED_PATHS_from_527fe2bc.txt` `0a9d90a9…` (1 M), `CHANGED_PATHS_from_base.txt` `04c03f40…` (25 paths).

## Binding v2 (`binding/v2/`; original `binding/` byte-identical, `BINDING.sha256` re-verified)
Prepared by `correction/prepare-binding-v2.sh` (source-only, lock-free, executes nothing). Runner delta v1→v2 exactly three lines: `EXPECT_HEAD` → `af9f7f54…`, `EXPECT_TREE` → `62a8071e…`, `D=…/binding` → `…/binding/v2` (receipts path). `PINS.txt` delta: same two pins plus the two mechanical path strings. Six proof-blob pins, BASE_HEAD/BASE_TREE, nine tool pins, fixture (`1a7faa5f…`, byte-identical) and execution behaviour unchanged; zero placeholders.
Hashes (`binding/v2/BINDING.sha256`): `s8c-pg-proof.sh` `038d6af62e09b0f7bce8bbc270e7283bcad06aa27b06daada898e1ac8281ee4f`; `s8c-pg-proof.sh.v1` `66a838ab…` (= original filled runner); `s8c-pg-proof.sh.diff-v1-to-v2` `d56b7db1…`; `s8c-fixture.sh` `1a7faa5f…`; `PINS.txt` `62ad8898…`; `PINS.txt.diff-v1-to-v2` `9438cd93…`; `README.md` `a90b1aea…`.
C item: the first `prepare-binding-v2.sh` invocation exited rc 1 at a `grep -c` zero-count idiom after every substantive check had passed; the idiom was corrected (script sha now `396199ae…`) and the remaining hash/log step completed with the identical commands (`binding/v2/prepare-binding-v2.log`).

## Final pins for review (v2)
EXPECT_HEAD `af9f7f5438fa545394b6d28792411439ded66caf`; EXPECT_TREE `62a8071e544e6a307537bd08c55b52e2a9af4e7d`; blobs `9fc44a2b…` / `8aa86de8…` / `a7d67217…` / `4059883d…` / `d5cbf877…` / `48403063…`; fixture `1a7faa5f…`; tool pins as in `FINAL_PINS_527fe2bc.txt`.

Status: heavy slot released 05:02:44Z; idle. Reviewers may bind the one-test follow-up `af9f7f54` on top of their 527fe2bc source review and the v2 driver. PG only under a separate exact grant.
