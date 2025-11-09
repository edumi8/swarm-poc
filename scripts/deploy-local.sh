#!/bin/bash
set -euo pipefail

echo "Deploying to LOCAL environment..."

# Deploy stack to local swarm
docker stack deploy -c swarm/local.yml local

echo "Local deployment complete!"
echo "Service A: http://localhost:8081"
echo "Service B: http://localhost:8082"
echo "Service C: http://localhost:8083"
