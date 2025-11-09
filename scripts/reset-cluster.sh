#!/usr/bin/env bash
set -euo pipefail

# Reset cluster completely: remove stacks, leave swarm, re-init swarm.
# WARNING: This will recreate the swarm and destroy current cluster state.
# Usage:
#   ./scripts/reset-cluster.sh [--force]
#   --force : skip interactive confirmation

FORCE=0
for arg in "$@"; do
  [[ "$arg" == "--force" ]] && FORCE=1
done

if [[ $FORCE -ne 1 ]]; then
  read -r -p "This will REMOVE all stacks and RE-INIT swarm. Continue? (y/N) " ans
  [[ "$ans" == "y" || "$ans" == "Y" ]] || { echo "Aborted."; exit 1; }
fi

./scripts/teardown-all.sh --leave || true

echo "Initializing fresh swarm..."
# Use primary interface IP if desired; fallback to auto
if ip=$(hostname -I | awk '{print $1}'); then
  docker swarm init --advertise-addr "$ip" >/dev/null || {
    echo "Swarm init failed (maybe already in swarm).";
  }
else
  docker swarm init >/dev/null || true
fi

echo "Cluster reset complete."
