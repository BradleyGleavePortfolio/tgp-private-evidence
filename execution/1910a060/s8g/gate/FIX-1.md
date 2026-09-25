# FIX-1 — minimum closure of gate attempt 1 rc 73 (parent disposition 2026-09-25 15:04 PT)

Scope: exactly one line of one test file, `test/scout/orchestration/reconstruct-run.spec.ts` (FakePrisma `select` helper, L77). Product sources untouched (attempt 1 already showed them compiling clean; the only tsc diagnostic was this line).

Exact diff (attempt-1 post-format copy → current working tree): `FIX-1.diff`
```
-      Object.entries(where).every(([k, v]) => (s as Record<string, unknown>)[k] === v),
+      Object.entries(where).every(([k, v]) => s[k as keyof Staged] === v),
```
`Staged` is the spec's own six-field interface (coach_id, intent_id, entity_type, source_platform, source_id, payload). The typed key narrowing `k as keyof Staged` indexes the row directly; no cast of the object to an unrelated type, no `as any` / `as unknown as` / `as never` / `@ts-*` (all `.github/r75-policy.json` tokens re-scanned across the 14 files: none). Behaviour identical: a `where` key absent from the row still compares `undefined === v` exactly as before.

New file identity: sha256 `a0a6c18e3860b4eae5266aa232a71a7c3e9baf14991a5110cbbfa5d0cd83956c`, blob `bed85decec993d6a4e4908237e96e816df23aba3` (attempt-1 post-format was sha256 `4638ce61…`, blob `e3317947…`). Other 13 files unchanged from `POSTFAIL-tree.txt`. Frozen for attempt 2 in `attempt-2/PREFORMAT.sha256` + `attempt-2/freeze/`.

Attempt-1 evidence is preserved unchanged in this directory (`gate.log`, `tsc.raw.log`, `TERMINAL RC=73 STAGE=tsc`, `SHA256SUMS`, `freeze/`, `postformat/`, `POSTFAIL-tree.txt`, `ATTEMPT-1-REPORT.md`). Attempt 2 driver: `attempt-2/s8g-gate-1910-a2.sh` sha256 `b60b11b2e80c276f5c5a3fd24c9eb8bccbc3ac0e36da03db46eb050457810e2d` (requires `S8G_GATE_RELAY=2`; polls `flock -n` on inode 667698 every 5 s, logging each minute, up to 5400 s; never steals).
