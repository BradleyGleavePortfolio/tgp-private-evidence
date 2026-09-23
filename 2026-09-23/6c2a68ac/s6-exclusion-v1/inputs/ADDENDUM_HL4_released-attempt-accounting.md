# ADDENDUM to S6_EXCLUSION_SCOPE_MAP.md — H-L4 completeness: exact released-attempt → bound-IDENTITY → retained-SID accounting (map note only; NOT implemented)

Additive note (parent mail 18:59 PDT). The frozen scope packet (`MANIFEST.s6-exclusion-scope` = `57bcbf08…725fa`, 2 entries) is unchanged; this file sits beside it and is not in that manifest. Nothing executed; no bytes of any candidate exist. Accepted directions restated as binding: O-A direct launcher (observer unused; no `timeout` last owner), Choice A (two EX roots + four-marker refusal), H-S1/H-R1 inherited fd 9, H-R2 pid-first IDENTITY, C6 bounds 240/30/300 (nominal, not a completion attestation), unused private `S5X` branch kept verbatim, no handoff. Implementation path (later, on explicit activation after S5 V3 review B closes): `execution/e8d546f9/s6-exclusion-v1/`.

## 1. The boundary, stated precisely
Two released attempts exist in a C6 run (selftest, then C). The runner names each released attempt in its bound EXIT_RECORD (`step=<s> IDENTITY attempt=attempt-XXXXXX identity_rc=0 adoption=published state=released`, C6 runner L299; setup L231 `npm-ci IDENTITY attempt=… state=released`). v3's `released=1` boolean (L180) plus rule L187 (`released-but-no-IDENTITY` only when the retained id set is EMPTY) would certify a run as accounted when the selftest IDENTITY/SID is known but the C attempt's IDENTITY was lost before its first read: `ids` is non-empty (selftest), `released=1` is satisfied, and the C session — the actual Jest workload — would be censused by nobody. A non-empty set of OLD ids must never certify ALL released attempts.

## 2. Smallest hunk (replaces v3 L180 `rel` and L187; adds two retained set variables in the style of `INNER_KNOWN`; no new registry, no new file, no signal)
State line (v3 L161) gains: `REL_KNOWN=""; REL_BOUND=""` — released attempt names once seen (union, never shrinks) and established `attempt:pid` bindings (union).

`runner_truth` (v3 L180), after the token-binding check L179 has passed (facts are taken only from THIS attempt's record):
```
for a in $(sed -n 's/.* IDENTITY attempt=\([^ ]*\) .* state=released.*/\1/p' "$r" 2>/dev/null); do case " $REL_KNOWN " in *" $a "*) ;; *) REL_KNOWN="$REL_KNOWN $a";; esac; done
rel=$(set -- $REL_KNOWN; echo $#)
```
(`released=<n>` in `RUNNER_NOTE` becomes a count of distinct released attempt names ever observed; the `sed` matches both consumers' line shapes — `step=<s> IDENTITY attempt=…` and `npm-ci IDENTITY attempt=…`; a read failure of `$r` here is already `unknown` by rules L178/L188 once `RSTATE != never-released`.)

`session_state`, replacing L187:
```
local a f p; for a in $REL_KNOWN; do case " $REL_BOUND " in *" $a:"*) continue;; esac   # already bound once: its pid is in INNER_KNOWN and stays censused
  f="$INNER_LOGS/attempts/$a/IDENTITY"; p=""
  if [ -r "$f" ] && grep -q " self_sid=$SESSION " "$f" 2>/dev/null; then p=$(sed -n 's/^pid=\([0-9][0-9]*\) .*/\1/p' "$f" 2>/dev/null | head -1); fi
  if [ -n "$p" ]; then REL_BOUND="$REL_BOUND $a:$p"; case " $INNER_KNOWN " in *" $p "*) ;; *) INNER_KNOWN="$INNER_KNOWN $p";; esac
  else unknown=1; d="$d inner:released-attempt-unbound:$a"; fi; done
ids=${INNER_KNOWN# }; INNER=${ids// /,}
```
Ordering inside `session_state`: run this loop AFTER L186 (the `inner_sids` union) and BEFORE the census loop L190, so a pid bound here is censused in the same cycle.

Semantics:
- Every released attempt named by the runner must map, at least once, to a readable IDENTITY that (a) is bound to our outer `SESSION` by ` self_sid=` and (b) yields a pid ⇒ that pid joins `INNER_KNOWN` and is censused until positively `empty`. Until each released attempt is bound, `CENSUS=unknown` ⇒ SELF-HOLD (`inner:released-attempt-unbound:attempt-XXXXXX`), regardless of how many other ids are known or empty.
- A binding once established is retained (`REL_BOUND`), so later loss of the IDENTITY read does not un-account the attempt; the sid itself remains retained and censused by v3's A-01 rule (a later unreadable read still adds `unknown` via `inner_sids` rc 2 — unchanged, safe direction).
- Bound IDENTITYs for attempts NOT named as released (identity confirmed, adoption failed ⇒ gate child exits 75/76) are still discovered by `inner_sids` and censused — stricter, unchanged.
- Loss of the EXIT_RECORD itself after adoption is already `unknown` (v3 L188); `REL_KNOWN` additionally keeps the released names already seen so a partial later read cannot shrink the accounting.
- Setup consumer: same hunk, one attempt; behaves as v3 L187 did for the one-attempt case but with the explicit attempt-name binding instead of set-emptiness.

## 3. Interaction with H-R2 and with the runner records (both consumers)
- H-R2 (pid-first IDENTITY in the C6 runner) is REQUIRED for the `^pid=` sed above as well; the setup IDENTITY is already pid-first (L230).
- The C6 runner's IDENTITY line L299 and the record `attempt=` token are `${att##*/}` = the directory name under `$INNER_LOGS/attempts/` — path join `"$INNER_LOGS/attempts/$a/IDENTITY"` is exact; no globbing.
- The C6 refused-adoption path writes `state=never-released` (not matched) and then `die … 2`; a `released-then-cancelled` latch (EXIT_RECORD append failed) means the line itself was NOT written — the attempt is then only discoverable via `inner_sids` (bound IDENTITY exists because it is written before adoption) and the run is `unknown` by L188 (`exit_record=…`) if the record later reads incomplete — safe direction; noted as the one case where a released attempt has no `attempt=` line.

## 4. Grant/implementation notes (additive to §8 of the map)
- H-L4 = this hunk (both launcher copies, identical text); `RUNNER_NOTE` field becomes `released=<n>`; `CENSUS_DETAIL` gains `inner:released-attempt-unbound:<attempt>`; `LEASE_RELEASE`/`SELF_HOLD` print `inner=[…]` from the retained union as before. Any accepted S5 V3 successor that changes L180/L187 must be re-based before this hunk is applied.
- Two independent reviews of the composition should include one question specific to this boundary: "with selftest bound and C's IDENTITY unreadable before first read, does the C6 launcher hold (`released-attempt-unbound:attempt-…`) and never release on the selftest sid alone?" — answered from source, not runtime.
- Truth: map note only; nothing implemented, nothing executed; S5 V3 A cleared (d9104403), B pending; implementation waits for B closure and explicit activation.
