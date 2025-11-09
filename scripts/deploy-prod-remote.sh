#!/bin/bash
set -euo pipefail

# Remote deployment script for PROD environment
# Usage: SWARM_MANAGER=user@prod-manager-ip ./deploy-prod-remote.sh

if [ -z "$SWARM_MANAGER" ]; then
    echo "Error: SWARM_MANAGER environment variable not set"
    echo "Usage: SWARM_MANAGER=user@hostname ./deploy-prod-remote.sh"
    exit 1
fi

echo "Deploying to REMOTE PROD environment at $SWARM_MANAGER..."

# Copy stack file to remote manager
scp swarm/prod.yml $SWARM_MANAGER:/tmp/prod.yml

# Deploy to remote swarm
ssh $SWARM_MANAGER "VERSION=${VERSION:-latest} docker stack deploy -c /tmp/prod.yml prod"

echo "Remote Production deployment complete!"
echo "Check services: ssh $SWARM_MANAGER 'docker service ls'"
