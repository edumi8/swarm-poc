#!/usr/bin/env bash
set -euo pipefail

# Tear down all known stacks safely. Does not leave swarm by default.
# Usage:
#   ./scripts/teardown-all.sh [--leave] [--prune]
#
# Flags:
#   --leave  : also leave swarm (force) after removing stacks
#   --prune  : prune unused images, networks, and volumes afterwards

LEAVE=0
PRUNE=0
for arg in "$@"; do
  case "$arg" in
    --leave) LEAVE=1 ;;
    --prune) PRUNE=1 ;;
  esac
done

STACKS=(dev stage prod local ingress)

exists_stack() {
  docker stack ls --format '{{.Name}}' | grep -qx "$1"
}

remove_stack() {
  local s="$1"
  if exists_stack "$s"; then
    echo "Removing stack: $s"
    docker stack rm "$s" || true
  else
    echo "Stack not found (skip): $s"
  fi
}

wait_until_gone() {
  local s="$1"
  for i in {1..60}; do
    if ! exists_stack "$s"; then
      echo "Stack $s removed."
      return 0
    fi
    sleep 2
  done
  echo "Timed out waiting for stack $s to be removed (some tasks may still be shutting down)."
}

for s in "${STACKS[@]}"; do
  remove_stack "$s"
  wait_until_gone "$s"
done

echo "Stacks removed."

if [[ $PRUNE -eq 1 ]]; then
  echo "Pruning unused Docker resources..."
  docker system prune -a -f --volumes
fi

if [[ $LEAVE -eq 1 ]]; then
  echo "Leaving swarm (force)..."
  docker swarm leave --force || true
fi

echo "Teardown complete."
