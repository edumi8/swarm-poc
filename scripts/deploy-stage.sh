#!/bin/bash

echo "Deploying to STAGE environment..."

# Deploy stack to swarm
docker stack deploy -c swarm/stage.yml stage

echo "Stage deployment complete!"
echo "Service A: http://localhost:9081"
echo "Service B: http://localhost:9082"
echo "Service C: http://localhost:9083"
