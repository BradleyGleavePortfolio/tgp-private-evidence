# TGP R1 candidate recovery checkpoint

Six immutable audit-source snapshots, captured 20 September 2026. These are incremental Git bundles verified against the preserved source repositories, not standalone clones and not audit clearance.

Restore the appropriate repository history from **TGP EXECUTE: preserved Git recovery checkpoint** first, then import its lane bundle. Each `.verify.txt` lists prerequisites and bundled refs; each `.identity.txt` records the exact commit, tree and parent identities. SHA256SUMS covers the bundle files.

S1, S2, S3 and S5 use the backend repository; S4 uses the importer; S6 uses mobile. S5 is a parent-created audit-only snapshot of current proof/harness files, not a claim that the builder's branch was complete. All other lane snapshots are the recorded builder commits.

All six lanes are T4 and entered dual independent round-one audit. Validation was incomplete at capture. Written, tested, audited, merged, deployed, enabled and customer-proven remain separate states.

Private audit reports are preserved as they return in `BradleyGleavePortfolio/tgp-private-evidence`; the public `tgp-agent-context/LAST_OPERATOR_STATE.md` is the current takeover entry point. Bundles preserve source, not an external deployment, environment, database backup or customer outcome.
