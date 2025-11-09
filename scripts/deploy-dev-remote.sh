#!/bin/bash

# Remote deployment script for DEV environment
# Usage: SWARM_MANAGER=user@dev-manager-ip ./deploy-dev-remote.sh

if [ -z "$SWARM_MANAGER" ]; then
    echo "Error: SWARM_MANAGER environment variable not set"
    echo "Usage: SWARM_MANAGER=user@hostname ./deploy-dev-remote.sh"
    exit 1
fi

echo "Deploying to REMOTE DEV environment at $SWARM_MANAGER..."

# Copy stack file to remote manager
scp swarm/dev.yml $SWARM_MANAGER:/tmp/dev.yml

# Deploy to remote swarm
ssh $SWARM_MANAGER "VERSION=${VERSION:-latest} docker stack deploy -c /tmp/dev.yml dev"

echo "Remote Dev deployment complete!"
echo "Check services: ssh $SWARM_MANAGER 'docker service ls'"
