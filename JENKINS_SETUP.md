# Jenkins Setup for Docker Swarm Deployment

## Prerequisites
- Jenkins server with Docker installed
- SSH access to Swarm manager nodes
- Docker registry access

## Required Plugins
1. Docker Pipeline
2. SSH Agent
3. Credentials Binding

## Configure Credentials

### 1. Docker Registry
- Go to: Manage Jenkins → Credentials
- Add: Secret text
  - ID: `docker-registry`
  - Secret: `your-registry.com` or `docker.io/yourusername`

### 2. Swarm Manager Nodes
Add SSH credentials for each environment:

**Dev Manager**
- Kind: SSH Username with private key
- ID: `dev-swarm-manager`
- Username: `deploy-user`
- Private Key: Upload or paste SSH private key
- Value in pipeline: `user@dev-manager-ip`

**Stage Manager**
- Kind: SSH Username with private key
- ID: `stage-swarm-manager`
- Username: `deploy-user`
- Private Key: Upload or paste SSH private key
- Value in pipeline: `user@stage-manager-ip`

**Prod Manager**
- Kind: SSH Username with private key
- ID: `prod-swarm-manager`
- Username: `deploy-user`
- Private Key: Upload or paste SSH private key
- Value in pipeline: `user@prod-manager-ip`

## SSH Key Setup

```bash
# On Jenkins server, generate deployment key
ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/swarm_deploy -N ""

# Copy public key to each swarm manager
ssh-copy-id -i /var/lib/jenkins/.ssh/swarm_deploy.pub deploy-user@dev-manager-ip
ssh-copy-id -i /var/lib/jenkins/.ssh/swarm_deploy.pub deploy-user@stage-manager-ip
ssh-copy-id -i /var/lib/jenkins/.ssh/swarm_deploy.pub deploy-user@prod-manager-ip

# Test connections
ssh -i /var/lib/jenkins/.ssh/swarm_deploy deploy-user@dev-manager-ip 'docker node ls'
```

## Create Jenkins Pipeline Job

1. New Item → Pipeline
2. Name: `microservices-swarm-deploy`
3. Pipeline definition: Pipeline script from SCM
4. SCM: Git
5. Repository URL: Your Git repo
6. Script Path: `Jenkinsfile`
7. Branches: `*/main`

## Test Pipeline

1. Build with Parameters
2. Check console output
3. Verify services on remote cluster:
```bash
ssh deploy-user@dev-manager-ip 'docker service ls'
```

## Troubleshooting

### SSH Connection Issues
```bash
# On Jenkins server
sudo -u jenkins ssh -v deploy-user@manager-ip
```

### Docker Permission Issues
```bash
# On Swarm manager nodes
sudo usermod -aG docker deploy-user
```

### Image Pull Issues
```bash
# Login to registry on manager nodes
docker login your-registry.com
```

## Security Best Practices

1. Use dedicated deploy user (not root)
2. Limit SSH key permissions (chmod 600)
3. Use private Docker registry
4. Implement image scanning
5. Use Jenkins credentials, never hardcode
6. Enable Jenkins security and RBAC
7. Use separate SSH keys per environment
