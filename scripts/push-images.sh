#!/bin/bash

# Push images to registry
# Usage: REGISTRY=your-registry.com ./push-images.sh

if [ -z "$REGISTRY" ]; then
    echo "Error: REGISTRY environment variable not set"
    echo "Usage: REGISTRY=your-registry.com ./push-images.sh"
    exit 1
fi

VERSION=${VERSION:-latest}

echo "Pushing images to $REGISTRY..."

# Tag and push service-a
docker tag poc/service-a:$VERSION $REGISTRY/service-a:$VERSION
docker push $REGISTRY/service-a:$VERSION

# Tag and push service-b
docker tag poc/service-b:$VERSION $REGISTRY/service-b:$VERSION
docker push $REGISTRY/service-b:$VERSION

# Tag and push service-c
docker tag poc/service-c:$VERSION $REGISTRY/service-c:$VERSION
docker push $REGISTRY/service-c:$VERSION

echo "All images pushed to $REGISTRY"
