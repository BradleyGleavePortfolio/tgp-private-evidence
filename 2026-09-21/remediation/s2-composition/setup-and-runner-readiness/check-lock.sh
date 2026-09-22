#!/usr/bin/env bash
# Prints whether /home/user/workspace/execution/test-validation.lock is actually held (probe with flock -n, released
# immediately) and which live processes hold it open (via /proc fd scan). Read-only; never takes the lock for work.
L=/home/user/workspace/execution/test-validation.lock
if flock -n "$L" true 2>/dev/null; then echo "lock FREE ($L)"; else echo "lock HELD ($L)"; fi
for p in /proc/[0-9]*; do for f in "$p"/fd/*; do [ "$(readlink "$f" 2>/dev/null)" = "$L" ] && echo "  open by pid=${p#/proc/} $(tr '\0' ' ' <"$p/cmdline" | cut -c1-120)"; done; done 2>/dev/null
