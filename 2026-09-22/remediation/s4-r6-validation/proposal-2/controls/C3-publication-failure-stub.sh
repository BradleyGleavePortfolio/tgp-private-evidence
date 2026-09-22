#!/usr/bin/env bash
# CONTROL C3: stub runner exits 0 and writes a SUCCESS exit record but NO sentinel.
# Launch: S4R6_CONTROL=1 S4R6_RUNNER=$PWD/C3-publication-failure-stub.sh S4R6_OUTER_S=30 bash ../launcher/s4-r6-launch-v2.sh
# Expected: OVERALL=FAILED_PUBLICATION, exit 7 (runner exit 0 + result SUCCESS is not enough).
printf '{"result":"SUCCESS","note":"control stub"}\n' > "$S4R6_OUT/EXIT_RECORD.json"
exit 0
