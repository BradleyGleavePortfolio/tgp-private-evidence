#!/usr/bin/env bash
for i in $(seq 1 60); do [ -e /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE ] && { echo "FREE $(date -u +%T)" > /tmp/s11c/slot.txt; exit 0; }; sleep 60; done; echo TIMEOUT > /tmp/s11c/slot.txt
