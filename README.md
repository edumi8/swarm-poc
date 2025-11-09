# Microservices Swarm POC

Monorepo with 3 Spring Boot microservices deployed via Docker Swarm with **ZERO DOWNTIME** and **FAULT TOLERANCE**.

## Key Features

- ✅ **Zero Downtime Deployments** - Rolling updates with health checks
- ✅ **Fault Tolerance** - Multi-replica services with automatic recovery
- ✅ **Auto Rollback** - Automatic rollback on failed deployments
- ✅ **Health Checks** - Container and service health monitoring
- ✅ **Multi-Environment** - Local, Dev, Stage, Prod
- ✅ **CI/CD Ready** - Jenkins pipeline with remote deployment

## Structure
```
.
├── services/
│   ├── service-a/          # Spring Boot service on 8081
│   ├── service-b/          # Spring Boot service on 8082
│   └── service-c/          # Spring Boot service on 8083
├── swarm/
│   ├── local.yml           # Single replica for local testing
│   ├── dev.yml             # 2 replicas per service
│   ├── stage.yml           # 3 replicas per service
│   └── prod.yml            # 5 replicas per service
├── scripts/
│   ├── build-all.sh
│   ├── deploy-local.sh
│   ├── deploy-dev.sh
│   ├── deploy-stage.sh
│   ├── deploy-prod.sh
│   ├── deploy-*-remote.sh  # Remote deployment scripts
│   └── push-images.sh
├── Jenkinsfile             # CI/CD pipeline
└── SWARM_SETUP.md          # Cluster setup guide
```

## Services
- **service-a**: Port 8081
- **service-b**: Port 8082
- **service-c**: Port 8083

## Quick Start (Local)

```bash
# 1. Initialize local swarm
docker swarm init

# 2. Build all services
./scripts/build-all.sh

# 3. Deploy locally
./scripts/deploy-local.sh

# 4. Check services
docker service ls
curl http://localhost:8081
curl http://localhost:8082
curl http://localhost:8083
```

## Deployment

### Local Testing
```bash
./scripts/deploy-local.sh
```

### Dev Environment (Remote)
```bash
SWARM_MANAGER=user@dev-manager ./scripts/deploy-dev-remote.sh
```

### Stage Environment (Remote)
```bash
SWARM_MANAGER=user@stage-manager ./scripts/deploy-stage-remote.sh
```

### Prod Environment (Remote)
```bash
SWARM_MANAGER=user@prod-manager ./scripts/deploy-prod-remote.sh
```

## Zero Downtime Features

### Rolling Updates
- Updates one replica at a time
- New replica starts before old one stops (`start-first`)
- Configurable delay between updates

### Health Checks
- HTTP health endpoint: `/actuator/health`
- Checks every 30s with 3 retries
- 40s startup grace period

### Automatic Rollback
- Triggers on deployment failure
- Max 20% failure ratio in prod
- Automatic reversion to previous version

### Fault Tolerance
- Multiple replicas per service
- Max 1 replica per node (spread across cluster)
- Automatic rescheduling on node failure
- Resource limits prevent resource exhaustion

## Environment Configuration

| Environment | Replicas | Health Check | Rollback | Nodes |
|-------------|----------|--------------|----------|-------|
| Local       | 1        | ✓            | ✗        | 1     |
| Dev         | 2        | ✓            | ✓        | 2+    |
| Stage       | 3        | ✓            | ✓        | 3+    |
| Prod        | 5        | ✓            | ✓        | 5+    |

## CI/CD Pipeline

Jenkins automatically:
1. Builds all services in parallel
2. Pushes to Docker registry
3. Deploys to Dev (automatic)
4. Deploys to Stage (manual approval)
5. Deploys to Prod (manual approval)
6. Verifies deployment health

## Monitoring

```bash
# Check service status
docker service ls

# View service logs
docker service logs -f dev_service-a-dev

# Check running tasks
docker service ps dev_service-a-dev

# Manual rollback
docker service rollback dev_service-a-dev
```

## Setup

See [SWARM_SETUP.md](SWARM_SETUP.md) for:
- Multi-node cluster setup
- Manager/Worker configuration
- Network and firewall rules
- Remote access setup
- Monitoring and disaster recovery
