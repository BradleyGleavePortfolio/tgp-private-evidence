# CORRECTION-S9A-1 (granted by parent at 2026-09-25 ~22:07Z)

## Trigger
The first S9-A compose run, `run/s9a-compose-20260925T220504Z`, stopped with rc 71 at line 238. That line ran `git -C $DONOR_REPO diff e1ec2fec 62471b11 …`, and the read-only donor clone `1910a060-s8f` does not hold object M. The parent dispositioned this as a script defect, not a problem with the candidate or the frontier. The details are in `COMPOSE_RESULT-S9A.md`.

## Change (exactly as proposed; diff in `analysis/CORRECTION-S9A-1.proposed.diff`)
1. **Line 238:** the donor schema/package comparison now runs as `git -C "$W" diff --quiet "$DONOR_HEAD" "$TIP" -- prisma package.json package-lock.json`. `$W` is the composition clone, which holds both e1ec2fec and M. The donor HEAD check and the node_modules pin checks are unchanged, and the donor stays read-only.
2. **`W`:** now `/home/user/workspace/worktrees/1910a060-land-s9a-2`. The first clone, `1910a060-land-s9a`, is preserved and untouched.

No other byte changed.

## Script identities
| Version | sha256 | Location |
|---|---|---|
| Pre-correction | `bbcdef58c2fc6da971f50143e6bb54ad1ff592ccf8202fab129d7d93c61c4b6e` | Preserved as `analysis/land-s9a-1910.pre-CORRECTION-S9A-1.sh` |
| Post-correction | `21f1ed8cc04b23bd0fa18e0a1f849676aaf1476548a88a2ccccd86187384eb2b` | Installed as `land-s9a-1910.sh`; identical to `analysis/land-s9a-1910.CORRECTION-S9A-1.proposed.sh` |

The corrected script passes `bash -n`.
