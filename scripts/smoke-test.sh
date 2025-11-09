#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-127.0.0.1}"   # Use explicit IPv4 to avoid IPv6 localhost resolution issues
ENVS="${ENVS:-dev stage prod}"
SERVICES="service-a service-b service-c"
TIMEOUT=${TIMEOUT:-8}
RETRIES=${RETRIES:-10}
WAIT=${WAIT:-3}  # seconds between readiness checks

# Color helpers
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'

header() { echo -e "${BLUE}\n== $1 ==${NC}"; }
ok() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✖${NC} $1"; }

# Derive external port from env + service
port_for() {
  local env="$1" svc="$2"
  case "$svc" in
    service-a) base=1 ;;
    service-b) base=2 ;;
    service-c) base=3 ;;
    *) return 1 ;;
  esac
  case "$env" in
    dev)   echo $((8080 + base)) ;;
    stage) echo $((9080 + base)) ;;
    prod)  echo $((10080 + base)) ;;
    *) return 1 ;;
  esac
}

# Test one endpoint (path) returning HTTP 200 and basic JSON content
hit() {
  local url="$1" label="$2"
  local start end ms code body
  start=$(date +%s%3N || date +%s000)
  if ! body=$(curl -m "$TIMEOUT" -s -w '\n%{http_code}' "$url" || true); then
    fail "$label -> curl error"
    return 1
  fi
  code=$(echo "$body" | tail -n1)
  content=$(echo "$body" | sed '$d')
  end=$(date +%s%3N || date +%s000)
  ms=$((end-start))
  if [[ "$code" == "200" ]]; then
    if [[ "$content" == *"status"* ]]; then
      ok "$label ($code, ${ms}ms)"
    else
      warn "$label ($code, ${ms}ms) missing 'status' field"
    fi
  else
    fail "$label (HTTP $code, ${ms}ms)"
    return 1
  fi
}

summary_pass=0
summary_fail=0

header "Smoke Test (HOST=$HOST, ENVS=$ENVS)"
for env in $ENVS; do
  header "Environment: $env"
  for svc in $SERVICES; do
    port=$(port_for "$env" "$svc" || echo "?")
    if [[ "$port" == "?" ]]; then
      fail "Cannot resolve port for $env/$svc"
      summary_fail=$((summary_fail+1))
      continue
    fi
    base="http://$HOST:$port"
    # Readiness loop using /actuator/health (preferred) then /health fallback
    ready=0
    for i in $(seq 1 $RETRIES); do
      code=$(curl -m "$TIMEOUT" -s -o /dev/null -w '%{http_code}' "$base/actuator/health" || true)
      [[ "$code" == "200" ]] && ready=1 && break
      sleep "$WAIT"
    done
    if [[ $ready -ne 1 ]]; then
      warn "$env/$svc not ready after $RETRIES retries"
    fi
    if hit "$base/" "$env/$svc root" && hit "$base/health" "$env/$svc health"; then
      summary_pass=$((summary_pass+1))
    else
      summary_fail=$((summary_fail+1))
    fi
  done
done

header "Summary"
[[ $summary_fail -eq 0 ]] && ok "All $summary_pass service checks passed" || fail "$summary_fail failures, $summary_pass passed"

exit $([[ $summary_fail -eq 0 ]] && echo 0 || echo 1)
