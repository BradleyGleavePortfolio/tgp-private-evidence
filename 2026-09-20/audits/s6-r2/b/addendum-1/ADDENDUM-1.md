# Lens B — Addendum 1 (provenance and G21/G22), 2026-09-20 22:47 UTC

Does not modify the frozen `REPORT.md` (sha256 `09a6395f…471ff`), probes, or `SHA256SUMS`. Checksum for this file in `SHA256SUMS.addendum-1`.

## A. Which `COMBINED_STATUS.md` I read

Recovered from my own preserved tool record (`current_session_context/turns/turn_0001.md`, tool result `toolu_016JwMxMW9DehgVuG1h4PLUX`): the text I read begins "As of 2026-09-20 22:31 UTC, both fixer packets are frozen and archived", describes the two reviews only as "A uses the inherited orchestrator model; B requests Claude Fable 5 / High", and contains **no preliminary findings, no blocker list, no lens-A conclusion, and no words matching `prelim`, `S6-R2-A`, `auditor A`, `lens A` or `reviewer A`**. I did not re-read `COMBINED_STATUS.md` at any later point. → I read the **22:31 version**.

Timing of my finding: the source read of `mmkv.ts` / `userCache.ts` preceded probe 1; `probes/probe1-usercache-shim.log` was written 22:34:29 UTC (file mtime), i.e. S6-B2-1 was formed and probe-confirmed before the ~22:36 UTC edit the parent describes. No lens-A conclusion was visible to me before or while forming the finding, and none was visible up to the freezing of `REPORT.md`.

## B. Incidental post-freeze exposure (disclosed)

At ~22:44 UTC, while answering the parent's provenance question, I ran `rg -n "COMBINED_STATUS|preliminary|…"` over `current_session_context/turns/`. That directory also holds **parent** turns, and the grep output showed me a few lines from `turns/turn_0021.md` quoting the parent's summary of lens A's preliminary findings (a finding ID `S6-R2-A-01` with a one-line title about the storage fallback and persisted identity, and a phrase about pairing messages claiming more than the client can verify). I did not open lens A's report or any further lines, and I stopped that line of inspection. This exposure occurred **after** my final verdict was sent (22:42 UTC) and after `REPORT.md` was frozen; it did not inform any content of the report. It is disclosed here so the provenance record is complete; the parent may weigh it as it sees fit.

## C. G21 / G22

My original read of `repos/context/AGENT_RULES.md` was `head -150`, which ends at G20 (line 147). **G21 (line 155) and G22 (line 161) were not read before the report was written.** I have now read them. Effect on the report: none of the dispositions or the verdict changes.

- G21 (simplest adequate implementation) supports the report's smallest-follow-up ordering: a ~10-line async fallback in `readUserCache` plus a bounded failure state in the panel, rather than a storage-layer rework.
- G22 (governance earns its cost) supports recommending one **un-mocked** round-trip test as the control for S6-B2-1 instead of a new prose rule or auditor step; the two existing AST/Metro-shape guards already fit G22's "short invariant plus tested control" form.

The report's "G01–G20" wording in §1 should be read as "G01–G20 read before writing; G21–G22 read afterward with no change to findings".
