#!/usr/bin/env bash
# Private fake runner for the exclusion controls (no npm, no canonical paths). Verifies the inherited lease like v10x, then acts per S5X_SCENARIO.
set -u; [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "${S5X_LOCK:?}" ] || exit 75; [ -n "${S5_LEASE_INHERITED:-}" ] || exit 75
case "${S5X_SCENARIO:?}" in
  normal)     exit 0 ;;
  descendant) ( trap "" TERM; echo ran > "$S5X_EX/DESC_READY"; exec sleep 60 ) 9>&- & until [ -e "$S5X_EX/DESC_READY" ]; do sleep 0.05; done; exit 0 ;;   # leaves a TERM-ignoring same-session descendant
  overrun)    exec sleep 60 ;;                                                                                                        # inner timeout must end it
  *) exit 64 ;;
esac
