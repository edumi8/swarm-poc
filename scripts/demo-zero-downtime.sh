#!/usr/bin/env bash
set -euo pipefail

# Demo: prove zero-downtime on dev service-a by updating it while sending requests
HOST="${HOST:-127.0.0.1}"
PORT=8081
REQUESTS=${REQUESTS:-100}
SLEEP=${SLEEP:-0.2}

ok=0
fail=0

# Fire the rolling update shortly after we start requests
(
  sleep 1
  echo "Triggering rolling update (start-first) for dev_service-a-dev..." >&2
  docker service update --force --update-parallelism 1 --update-delay 5s --update-order start-first dev_service-a-dev >/dev/null
  echo "Update initiated." >&2
) &

for i in $(seq 1 "$REQUESTS"); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://${HOST}:${PORT}/" || true)
  if [[ "$code" == "200" ]]; then
    ok=$((ok+1))
  else
    fail=$((fail+1))
    echo "Request #$i -> HTTP $code" >&2
  fi
  sleep "$SLEEP"
done

echo "OK=${ok} FAIL=${fail} (during rolling update)"
# Exit non-zero only if failures occurred
[[ $fail -eq 0 ]] || exit 1
