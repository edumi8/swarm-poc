#!/bin/bash
set -euo pipefail

echo "Building all services in parallel..."

# Build services in parallel for faster execution
(
  echo "Building Service A..."
  cd services/service-a && docker build -t poc/service-a:latest .
) &
pid_a=$!

(
  echo "Building Service B..."
  cd services/service-b && docker build -t poc/service-b:latest .
) &
pid_b=$!

(
  echo "Building Service C..."
  cd services/service-c && docker build -t poc/service-c:latest .
) &
pid_c=$!

# Wait for all builds to complete
echo "Waiting for builds to complete..."
wait $pid_a && echo "✓ Service A built" || { echo "✗ Service A failed"; exit 1; }
wait $pid_b && echo "✓ Service B built" || { echo "✗ Service B failed"; exit 1; }
wait $pid_c && echo "✓ Service C built" || { echo "✗ Service C failed"; exit 1; }

echo "All services built successfully!"
