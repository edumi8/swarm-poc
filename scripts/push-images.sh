#!/bin/bash
set -euo pipefail

# Push images to registry
# Usage: REGISTRY=your-registry.com ./push-images.sh

if [ -z "$REGISTRY" ]; then
    echo "Error: REGISTRY environment variable not set"
    echo "Usage: REGISTRY=your-registry.com ./push-images.sh"
    exit 1
fi

VERSION=${VERSION:-latest}

echo "Pushing images to $REGISTRY in parallel..."

# Tag and push in parallel for faster execution
(
  echo "Tagging and pushing service-a..."
  docker tag poc/service-a:$VERSION $REGISTRY/service-a:$VERSION
  docker push $REGISTRY/service-a:$VERSION
) &
pid_a=$!

(
  echo "Tagging and pushing service-b..."
  docker tag poc/service-b:$VERSION $REGISTRY/service-b:$VERSION
  docker push $REGISTRY/service-b:$VERSION
) &
pid_b=$!

(
  echo "Tagging and pushing service-c..."
  docker tag poc/service-c:$VERSION $REGISTRY/service-c:$VERSION
  docker push $REGISTRY/service-c:$VERSION
) &
pid_c=$!

# Wait for all pushes to complete
echo "Waiting for pushes to complete..."
wait $pid_a && echo "✓ Service A pushed" || { echo "✗ Service A failed"; exit 1; }
wait $pid_b && echo "✓ Service B pushed" || { echo "✗ Service B failed"; exit 1; }
wait $pid_c && echo "✓ Service C pushed" || { echo "✗ Service C failed"; exit 1; }

echo "All images pushed to $REGISTRY"
