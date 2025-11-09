#!/bin/bash
set -euo pipefail

# Remote deployment script for STAGE environment
# Usage: SWARM_MANAGER=user@stage-manager-ip ./deploy-stage-remote.sh

if [ -z "$SWARM_MANAGER" ]; then
    echo "Error: SWARM_MANAGER environment variable not set"
    echo "Usage: SWARM_MANAGER=user@hostname ./deploy-stage-remote.sh"
    exit 1
fi

echo "Deploying to REMOTE STAGE environment at $SWARM_MANAGER..."

# Copy stack file to remote manager
scp swarm/stage.yml $SWARM_MANAGER:/tmp/stage.yml

# Deploy to remote swarm
ssh $SWARM_MANAGER "VERSION=${VERSION:-latest} docker stack deploy -c /tmp/stage.yml stage"

echo "Remote Stage deployment complete!"
echo "Check services: ssh $SWARM_MANAGER 'docker service ls'"
