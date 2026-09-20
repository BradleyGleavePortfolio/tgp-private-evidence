# Independent verification attempt record

The first read-only verification run exited 1 on the final assertion
`assert result["bundles_equal_after_normalizing_extension_flag"]`.
All preceding source, manifest, stamp, suite-count, cold-cache, hash and residue
assertions had passed. The initial script is preserved as
`verify-combined-packet.attempt-1.py`; its redirected output was empty because
the assertion preceded the final JSON print.

This is an explained failed auditor assertion, not a failed candidate command.
The frozen builder report says the two bundles differ solely by inlined flags.
Independent byte comparison found two additional changed Sentry debug-id
occurrences in the bundle prelude. The bounded comparison is preserved in
`bundle-difference-investigation.json`. The final verifier normalizes the exact
extension-flag field and the two explicitly identified Sentry debug-id
occurrences, then requires complete byte equality. It does not ignore any other
UUIDs, metadata or source.

The evidence wording should be qualified, but this does not invalidate the
authenticated bundle hashes or the successful flag/residue assertions.
