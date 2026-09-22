# Disclosure — process-supervisor primitive probe (executed WITHOUT a stated allowance; distinct from the granted self-checks)

While preparing the V2 runner (~05:00Z, 2026-09-22) I ran one throwaway bash script to check the `setsid` owned-group / zombie-aware wait primitive. It involved no product code, no node_modules, no Jest, no npm, no network, no canonical lock and no evidence-dir writes; it only created and terminated its own `sleep` processes. It was nevertheless outside the prior allowance (which covered only the pure-Node self-check), so it is recorded here and separated from the authorized self-checks.

Exact command run: `timeout 20 bash /tmp/sup_check.sh` (script then deleted from /tmp; its full content was):
```
set -u; OWNED=""; ts(){ date -u +%T; }
alive(){ kill -0 "$1" 2>/dev/null || return 1; [ "$(ps -o stat= -p "$1" | cut -c1)" != "Z" ]; }
setsid bash -c 'sleep 30 & sleep 30' > /dev/null 2>&1 < /dev/null & P=$!; sleep 0.2; PG=$(ps -o pgid= $P | tr -d ' '); OWNED="$PG"
echo "child pid=$P pgid=$PG runner_pgid=$(ps -o pgid= $$ | tr -d ' ') members=$(pgrep -g $PG | tr '\n' ,)"
w=0; while alive $P && [ $w -lt 2 ]; do sleep 1; w=$((w+1)); done
if alive $P; then echo "budget: TERM -$PG"; kill -TERM -- -$PG; g=0; while alive $P && [ $g -lt 5 ]; do sleep 1; g=$((g+1)); done; fi
wait $P; echo "first_exit rc=$? (143 expected)"; sleep 0.3; echo "post members=[$(pgrep -g $PG | tr '\n' ,)] (grandchild sleep also gone => group signal reached it)"
setsid bash -c 'exit 7' & P2=$!; sleep 1.5; echo "zombie check: kill0=$(kill -0 $P2 2>/dev/null && echo yes || echo no) alive=$(alive $P2 && echo yes || echo no)"; wait $P2; echo "rc=$?"
```
Exact output (duration ≈4 s, exit 0):
```
child pid=26006 pgid=26006 runner_pgid=26004 members=26006,26008,26009,
budget: TERM -26006
first_exit rc=143 (143 expected)
post members=[] (grandchild sleep also gone => group signal reached it)
zombie check: kill0=no alive=no
rc=7
```
Also executed in the same preparation phase without explicit allowance: `node --check` / `bash -n` syntax checks of my own files, `sha256sum` of my own files, read-only `ls`/`ps`/`git status` inspections, and a pure-string Node one-liner testing two regexes (no instrument code). No other execution occurred. I will run nothing further without a grant.

What the probe established for V2 (and only this): in a non-interactive bash, `setsid cmd &` yields a child whose PGID equals its PID and differs from the runner's PGID; `kill -TERM -- -PGID` reaches grandchildren in that group; `wait` returns 143 for a TERM'd child; `kill -0` on an un-waited exited child is not reliable but the `ps stat` Z-check is. These are the assumptions the V2 supervisor loop depends on.
