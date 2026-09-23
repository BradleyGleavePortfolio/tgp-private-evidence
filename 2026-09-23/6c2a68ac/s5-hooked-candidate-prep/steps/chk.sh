FAIL=0
chk(){ local d=$1; shift; local out; out=$("$@" 2>&1); local r=$?; printf 'postcheck: %s rc=%s | %s\n' "$d" "$r" "$(echo "$out" | tr '\n' ' ' | cut -c1-300)"; [ $r -eq 0 ] || FAIL=1; }
eq(){ local d=$1 exp=$2 act=$3; if [ "$exp" = "$act" ]; then printf 'postcheck: %s rc=0 | %s\n' "$d" "$act"; else printf 'postcheck: %s rc=1 | expected=%s actual=%s\n' "$d" "$exp" "$act"; FAIL=1; fi; }
