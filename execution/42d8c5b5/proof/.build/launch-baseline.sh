#!/usr/bin/env bash
# Sequential baseline qualification: S11 lane then S10-B lane on 54be96f1 (each takes the canonical lock itself).
P=/home/user/workspace/repos/tgp-private-evidence/execution/42d8c5b5/proof; B=54be96f18c314cae35d1e5d3000af9f06d693d81
"$P/lane-s11.sh" "$B" "$P/baseline-s11"; echo "S11_RC=$? $(date -u +%FT%TZ)"
"$P/lane-s10b.sh" "$B" "$P/baseline-s10b"; echo "S10B_RC=$? $(date -u +%FT%TZ)"
