# Docker Swarm Cluster Setup

## Cluster Architecture

### Production Environment
- **Manager Nodes**: 3 (HA for fault tolerance)
- **Worker Nodes**: 5+ (for service distribution)
- **Replicas per Service**: 5 (spread across workers)

### Stage Environment
- **Manager Nodes**: 1-3
- **Worker Nodes**: 3+
- **Replicas per Service**: 3

### Dev Environment
- **Manager Nodes**: 1
- **Worker Nodes**: 2+
- **Replicas per Service**: 2

## Initial Setup

### 1. Initialize Swarm on Manager Node

```bash
# On the first manager node
docker swarm init --advertise-addr <MANAGER-IP>

# Save the join tokens
docker swarm join-token manager    # For additional managers
docker swarm join-token worker     # For workers
```

### 2. Add Manager Nodes (for HA)

```bash
# On additional manager nodes (run the command from step 1 output)
docker swarm join --token <MANAGER-TOKEN> <MANAGER-IP>:2377
```

### 3. Add Worker Nodes

```bash
# On each worker node
docker swarm join --token <WORKER-TOKEN> <MANAGER-IP>:2377
```

### 4. Label Nodes (Optional)

```bash
# Add labels for placement constraints
docker node update --label-add env=prod node1
docker node update --label-add role=backend node2
```

### 5. Verify Cluster

```bash
docker node ls
```

## Firewall Rules

Open these ports between nodes:

- **2377/tcp**: Cluster management
- **7946/tcp/udp**: Node communication
- **4789/udp**: Overlay network traffic

## Zero Downtime Deployment Features

### 1. Rolling Updates
- `parallelism: 1` - Updates one replica at a time
- `order: start-first` - Starts new container before stopping old
- `delay: 20s` - Waits between updates

### 2. Health Checks
- Services must pass health check before old replica stops
- `start_period: 40s` - Grace period for service startup
- `retries: 3` - Retry health checks before marking unhealthy

### 3. Automatic Rollback
- `failure_action: rollback` - Auto rollback on failure
- `max_failure_ratio: 0.2` - Rollback if 20% fail

### 4. Placement Constraints
- `max_replicas_per_node: 1` - Spreads replicas across nodes
- `node.role == worker` - Only on worker nodes

### 5. Resource Limits
- Prevents resource exhaustion
- Ensures predictable performance

## Remote Access Setup

### SSH Key Setup

```bash
# Generate SSH key for Jenkins
ssh-keygen -t rsa -b 4096 -f ~/.ssh/swarm_deploy

# Copy to all manager nodes
ssh-copy-id -i ~/.ssh/swarm_deploy.pub user@dev-manager
ssh-copy-id -i ~/.ssh/swarm_deploy.pub user@stage-manager
ssh-copy-id -i ~/.ssh/swarm_deploy.pub user@prod-manager
```

### Jenkins Credentials

Add these credentials in Jenkins:

1. **docker-registry**: Docker registry URL
2. **dev-swarm-manager**: `user@dev-manager-ip`
3. **stage-swarm-manager**: `user@stage-manager-ip`
4. **prod-swarm-manager**: `user@prod-manager-ip`

## Testing Local Setup

```bash
# Initialize local swarm
docker swarm init

# Build images
./scripts/build-all.sh

# Deploy locally
./scripts/deploy-local.sh

# Check status
docker service ls
docker service ps local_service-a-local
```

## Monitoring

### Check Service Status

```bash
# List all services
docker service ls

# Check service logs
docker service logs -f prod_service-a-prod

# Check service tasks
docker service ps prod_service-a-prod

# Check service health
docker service inspect prod_service-a-prod --format='{{.UpdateStatus.State}}'
```

### Manual Rollback

```bash
# Rollback a service
docker service rollback prod_service-a-prod

# Scale a service
docker service scale prod_service-a-prod=7
```

## Disaster Recovery

### Backup Swarm State

```bash
# On manager node
systemctl stop docker
tar -czvf /backup/swarm-backup.tar.gz /var/lib/docker/swarm
systemctl start docker
```

### Node Failure Handling

- **Manager Node Fails**: Cluster continues with quorum (need majority)
- **Worker Node Fails**: Services auto-rescheduled to healthy nodes
- **Service Fails**: Auto-restart with restart policy

## Best Practices

1. **Always use odd number of managers** (3 or 5)
2. **Never run application containers on managers** (use constraints)
3. **Monitor cluster health regularly**
4. **Test rollback procedures**
5. **Keep manager nodes in different availability zones**
6. **Use overlay networks for service communication**
7. **Implement proper logging and monitoring**
8. **Regular backup of swarm state**

## Production Checklist

- [ ] 3+ manager nodes across different zones
- [ ] 5+ worker nodes
- [ ] Firewall rules configured
- [ ] SSH access configured
- [ ] Docker registry accessible
- [ ] Health checks validated
- [ ] Rollback tested
- [ ] Monitoring in place
- [ ] Backup strategy implemented
- [ ] Load balancer configured (optional)
