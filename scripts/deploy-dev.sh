#!/bin/bash

echo "Deploying to DEV environment..."

# Deploy stack to swarm
docker stack deploy --detach=false -c swarm/dev.yml dev

echo "Dev deployment complete!"
echo "Service A: http://localhost:8081"
echo "Service B: http://localhost:8082"
echo "Service C: http://localhost:8083"
