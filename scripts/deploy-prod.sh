#!/bin/bash
set -euo pipefail

echo "Deploying to PROD environment..."

# Deploy stack to swarm
docker stack deploy -c swarm/prod.yml prod

echo "Production deployment complete!"
echo "Service A: http://localhost:10081"
echo "Service B: http://localhost:10082"
echo "Service C: http://localhost:10083"
