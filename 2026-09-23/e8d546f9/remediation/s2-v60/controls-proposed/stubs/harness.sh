#!/usr/bin/env bash
# stub harness (STUB — NOT EVIDENCE). Modes: fast (default) | sleep <s> | escape <s>
# r54 additions (A01/B01 counterexamples): leader-exit (same-group unnamed child outlives a rc=0 leader) | grandchild (same-group unnamed
# child for an inner step timeout) | escape-unnamed (setsid child with a plain 'sleep' cmdline: no group, no pattern — documented boundary).
# Every spawned pid is printed as 'spawned pid=<n>' so the control driver can record ownership WITHOUT relying on process names.
# v58 (S2-V57-A04): each such line ALSO carries the child's start identity 'start=<ticks>' (/proc/<pid>/stat field 22, read by THIS producer while it owns
# the child) so the driver promotes a logged number to signal authority only while the live process still has that start identity. Additive: the
# 'spawned pid=<n>' / 'escapee pid=<n>' substrings and all other output are unchanged.
pstart(){ cut -d')' -f2 /proc/"$1"/stat 2>/dev/null | awk '{print $20}'; }   # same expression as the driver's pstart
echo "stub harness db=$1 pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') fd9=$(readlink /proc/$$/fd/9 2>/dev/null || echo closed) mode=${STUB_HARNESS_MODE:-fast} CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset}"
case ${STUB_HARNESS_MODE:-fast} in
  sleep)  sleep "${STUB_HARNESS_SLEEP:-30}";;
  escape) setsid -f bash -c 'exec -a s2r53-stub-escapee sleep '"${STUB_HARNESS_SLEEP:-30}" </dev/null >/dev/null 2>&1; sleep 0.3; ep=$(pgrep -f '^s2r53-stub-escapee' | head -1); echo "escapee pid=$ep start=$(pstart "$ep")"; sleep "${STUB_HARNESS_SLEEP:-30}";;
  leader-exit)    sleep "${STUB_HARNESS_SLEEP:-30}" </dev/null >/dev/null 2>&1 & echo "spawned pid=$! start=$(pstart $!) (same group, cmd 'sleep', leader exits 0 now)";;
  grandchild)     sleep "${STUB_HARNESS_SLEEP:-30}" </dev/null >/dev/null 2>&1 & echo "spawned pid=$! start=$(pstart $!) (same group, cmd 'sleep'); leader now blocks until the step bound kills it"; sleep "${STUB_HARNESS_SLEEP:-30}";;
  escape-unnamed) setsid sleep "${STUB_HARNESS_SLEEP:-30}" </dev/null >/dev/null 2>&1 & echo "spawned pid=$! start=$(pstart $!) (own session via setsid, cmd 'sleep' — outside group and pattern)";;   # this bash is not a group leader, so setsid execs in place: $! is the escapee
esac
echo "== 0 passed, 0 failed (STUB — NOT EVIDENCE)"; exit ${STUB_HARNESS_RC:-0}
