# S4 native V2 activation receipt

Parent EXEC-e8d546f9, 2026-09-23. This records one activation, not a result or independent audit.

## Authorization and exact startup

Parent sent explicit ACTIVATE after publication of private commit `7f09413935b13f2ae0a3881299fb4e779f107173`. Exact grant `S4_NATIVE_V2_GRANT.md` SHA256 `20d42065e10991dc222243cddfd8c2e5be7adc51446c7e68032826fcf24a8e25` remains unchanged. Executor `restore_upstream_proof_inputs_muddwjad` was instructed to seal prep, verify all stated prerequisites, and run T1 once, with no extra approval wait.

Preparation manifest `f96700eb20f22249171908f1852d8132dae17ec93b9227c165a9345cfb888b17` binds the restored exact caller, invocation and transport. Parent observed these initial lines in the executor's native log:

- Transport launch: 2026-09-23T01:50:31Z, wrapper pid/pgid/sid 16302, caller invocation SHA256 `ef45fd8d8cc6276de070a9cd0a1674e34174360863327db09c564345d52bae84`.
- Caller pid 16315, starttime 423592; launcher pid 16321, starttime 423603; observer 3422 seconds and cancel allowance 127.
- Native run `VALIDATION-V6-20260923T015032Z-16321-76044a34`; canonical lease held by launcher, standby pid 16358/starttime 423606 with matching run token.
- Owned runner session 16382; runner SHA256 `94edb27d6732cfce05523a33201b47e99020a5625181937558001abc0bd50301`.

These are historical startup identities, never reusable signal authorization. Status at this receipt: RUNNING, no outcome yet. Source reviews, grantability and startup do not prove test/package/browser success.

## Environment accounting

S2 result-B records the sandbox `/usr/bin/git` wrapper's short drain sleeper and detached platform telemetry. Parent authorized only read-only final `/proc` fd-link accounting for canonical lease holders, with pid/start/sid/link facts and no telemetry payload or environment capture. No wrapper change, bypass, disabling, extra lock probe or recovery signal was authorized.

All subsequent actual statuses, caller receipt, supervisor record, raw logs, source state and cleanup/retention belong in the executor's frozen final result. S5 fake-only diagnostic remains QUEUED and cannot start automatically when this caller returns.
