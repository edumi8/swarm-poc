#!/bin/bash

echo "Building all services..."

# Build Service A
echo "Building Service A..."
cd services/service-a
docker build -t poc/service-a:latest .
cd ../..

# Build Service B
echo "Building Service B..."
cd services/service-b
docker build -t poc/service-b:latest .
cd ../..

# Build Service C
echo "Building Service C..."
cd services/service-c
docker build -t poc/service-c:latest .
cd ../..

echo "All services built successfully!"
