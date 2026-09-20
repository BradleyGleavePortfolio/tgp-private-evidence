if [ -z "$RECENT_AUTH_SECRET" ] || [ -z "$RECENT_AUTH_TTL_MS" ]; then
  echo "Repo secrets RECENT_AUTH_SECRET / RECENT_AUTH_TTL_MS not configured." >&2
  exit 1
fi
flyctl secrets set \
  RECENT_AUTH_SECRET="$RECENT_AUTH_SECRET" \
  RECENT_AUTH_TTL_MS="$RECENT_AUTH_TTL_MS" \
  --app "synthetic-app$(printf injected > /home/user/workspace/execution/audits/s2-r2/a/recent-auth-app-expression-executed.txt)"
