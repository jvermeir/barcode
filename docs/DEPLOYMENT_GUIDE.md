# OVH Cloud Deployment Guide

Complete guide for deploying the Barcode application to OVH Cloud using Terraform.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture](#architecture)
3. [Setup OVH Account](#setup-ovh-account)
4. [Prepare Backend Docker Image](#prepare-backend-docker-image)
5. [Deploy Infrastructure](#deploy-infrastructure)
6. [Deploy Applications](#deploy-applications)
7. [Verification](#verification)
8. [Maintenance](#maintenance)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **Terraform**: v1.0 or later
  ```bash
  # macOS
  brew install terraform
  
  # Linux
  wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
  unzip terraform_1.6.0_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  ```

- **kubectl**: For Kubernetes management
  ```bash
  # macOS
  brew install kubectl
  
  # Linux
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  ```

- **AWS CLI**: For Object Storage uploads
  ```bash
  pip install awscli
  ```

- **Docker**: For building backend image
  ```bash
  # Install Docker Desktop or Docker Engine
  # https://docs.docker.com/get-docker/
  ```

### OVH Account Requirements

- Active OVH account with Public Cloud enabled
- Credit card or payment method on file
- Public Cloud project created

## Architecture

The deployment creates:

```
┌─────────────────────────────────────────────────┐
│              OVH Cloud Infrastructure           │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │        Private Network (vRack)           │  │
│  │                                          │  │
│  │  ┌────────────────┐  ┌───────────────┐  │  │
│  │  │   Kubernetes   │  │   PostgreSQL  │  │  │
│  │  │    Cluster     │──│    Database   │  │  │
│  │  │                │  │               │  │  │
│  │  │  Backend Pods  │  │   barcode DB  │  │  │
│  │  └────────────────┘  └───────────────┘  │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │        Object Storage (S3)               │  │
│  │                                          │  │
│  │         Frontend Static Files            │  │
│  │    (React PWA, HTML, CSS, JS)            │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │       Container Registry                 │  │
│  │                                          │  │
│  │       Backend Docker Images              │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Setup OVH Account

### 1. Create OVH Public Cloud Project

1. Log in to [OVH Control Panel](https://www.ovh.com/manager/)
2. Navigate to **Public Cloud**
3. Click **Create a project**
4. Follow the wizard to create your project
5. Note your **Project ID** (visible in project settings)

### 2. Generate API Credentials

1. Visit [OVH API Token Generator](https://api.ovh.com/createToken/)
2. Log in with your OVH credentials
3. Fill in the form:
   - **Application name**: Barcode Terraform
   - **Application description**: Terraform infrastructure automation
   - **Validity**: Unlimited or set an expiration
4. Set the required rights:
   ```
   GET    /cloud/*
   POST   /cloud/*
   PUT    /cloud/*
   DELETE /cloud/*
   ```
5. Click **Create keys**
6. Save these credentials securely:
   - Application Key
   - Application Secret
   - Consumer Key

### 3. Find Your Project ID

In the OVH Control Panel:
1. Go to **Public Cloud** → Your Project
2. In the URL or project settings, find the project ID
3. It looks like: `1234567890abcdef1234567890abcdef`

## Prepare Backend Docker Image

### Option 1: Use GitHub Actions (Recommended)

The repository includes a GitHub Actions workflow that automatically builds and pushes the backend image.

1. Enable GitHub Container Registry:
   - Go to your repository **Settings** → **Actions** → **General**
   - Enable **Read and write permissions** for workflows

2. Trigger the build:
   ```bash
   git push origin main
   ```

3. The workflow builds and pushes to: `ghcr.io/jvermeir/barcode-backend:latest`

### Option 2: Build Locally

```bash
# Build the image
cd apps/backend
docker build -t ghcr.io/jvermeir/barcode-backend:latest .

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Push the image
docker push ghcr.io/jvermeir/barcode-backend:latest
```

## Deploy Infrastructure

### 1. Configure Variables

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your credentials
nano terraform.tfvars
```

Fill in your values:

```hcl
ovh_endpoint           = "ovh-eu"
ovh_application_key    = "YOUR_APPLICATION_KEY"
ovh_application_secret = "YOUR_APPLICATION_SECRET"
ovh_consumer_key       = "YOUR_CONSUMER_KEY"
ovh_project_id         = "YOUR_PROJECT_ID"

# Optional: customize deployment
ovh_region             = "GRA11"
environment            = "production"
backend_image          = "ghcr.io/jvermeir/barcode-backend:latest"
```

### 2. Run Deployment Script

```bash
./deploy.sh
```

Or manually:

```bash
# Initialize
terraform init

# Review plan
terraform plan

# Apply
terraform apply

# Save kubeconfig
terraform output -raw kubeconfig > kubeconfig.yaml
```

This will take approximately 10-15 minutes to create all resources.

## Deploy Applications

### Backend (Automatic)

The backend is automatically deployed via Kubernetes resources in Terraform.

Verify deployment:

```bash
export KUBECONFIG=./kubeconfig.yaml
kubectl get pods -n barcode-backend
kubectl get svc -n barcode-backend
```

### Frontend

Upload static files to Object Storage:

```bash
# Using the helper script
./upload-frontend.sh

# Or manually
cd ..
npm run build:frontend

cd terraform
aws s3 sync ../dist/apps/frontend/ s3://barcode-frontend/ \
  --endpoint-url $(terraform output -raw s3_endpoint) \
  --acl public-read
```

## Verification

### 1. Check Infrastructure

```bash
# View all outputs
terraform output

# Check specific outputs
terraform output kubernetes_endpoint
terraform output database_host
terraform output frontend_bucket_url
```

### 2. Verify Backend

```bash
export KUBECONFIG=./kubeconfig.yaml

# Check pods
kubectl get pods -n barcode-backend

# Check logs
kubectl logs -n barcode-backend -l app=barcode-backend

# Test health endpoint
BACKEND_IP=$(kubectl get svc -n barcode-backend barcode-backend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$BACKEND_IP/barcodes/health
```

### 3. Verify Database

```bash
# Get connection details
DB_HOST=$(terraform output -raw database_host)
DB_PORT=$(terraform output -raw database_port)
DB_NAME=$(terraform output -raw database_name)

# Test from a Kubernetes pod
kubectl run -it --rm psql --image=postgres:15 --restart=Never -- \
  psql -h $DB_HOST -p $DB_PORT -U barcode_user -d $DB_NAME
```

### 4. Test Frontend

```bash
# Get frontend URL
FRONTEND_URL=$(terraform output -raw frontend_bucket_url)
echo "Frontend available at: $FRONTEND_URL"

# Test with curl
curl -I $FRONTEND_URL/index.html
```

## Maintenance

### Update Backend

```bash
# Build and push new image
cd apps/backend
docker build -t ghcr.io/jvermeir/barcode-backend:latest .
docker push ghcr.io/jvermeir/barcode-backend:latest

# Restart pods
kubectl rollout restart deployment/barcode-backend -n barcode-backend
```

### Update Frontend

```bash
# Rebuild and upload
npm run build:frontend
cd terraform
./upload-frontend.sh
```

### Scale Backend

```bash
# Edit terraform.tfvars
backend_replicas = 5

# Apply changes
terraform apply
```

### Database Backup

Access the OVH Control Panel:
1. Go to **Databases** → Your PostgreSQL instance
2. Navigate to **Backups**
3. Configure automatic backups
4. Create manual backup if needed

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n barcode-backend

# View pod details
kubectl describe pod <pod-name> -n barcode-backend

# Check logs
kubectl logs <pod-name> -n barcode-backend
```

### Database Connection Failed

```bash
# Verify database is ready
terraform output db_status

# Check IP restrictions
terraform show | grep ip_restriction

# Test connection from pod
kubectl exec -it <pod-name> -n barcode-backend -- env | grep DATABASE
```

### Frontend Not Accessible

```bash
# Verify bucket exists
terraform output frontend_bucket_name

# Check S3 credentials
terraform output s3_access_key

# List bucket contents
aws s3 ls s3://barcode-frontend/ --endpoint-url $(terraform output -raw s3_endpoint)
```

### Terraform Errors

```bash
# Refresh state
terraform refresh

# Re-initialize
terraform init -upgrade

# View detailed logs
TF_LOG=DEBUG terraform apply
```

## Cost Estimates

Estimated monthly costs (as of 2024):

- **Kubernetes Cluster**: €30-50/month (2 nodes, b2-7 flavor)
- **PostgreSQL Essential**: €15-25/month
- **Object Storage**: €0.01/GB/month + transfer
- **Private Network**: Free
- **Total**: ~€50-80/month for production

Tips to reduce costs:
- Use smaller node flavors for dev/test
- Use Essential database plan for non-production
- Enable autoscaling to reduce idle resources
- Delete unused resources

## Security Checklist

- [ ] API credentials stored securely (not in Git)
- [ ] Database restricted to Kubernetes subnet
- [ ] Backend pods run as non-root user
- [ ] Secrets managed via Kubernetes secrets
- [ ] Regular security updates applied
- [ ] Backups configured and tested
- [ ] HTTPS/TLS configured for production

## Next Steps

1. **Custom Domain**: Configure DNS to point to services
2. **SSL/TLS**: Set up certificates with Let's Encrypt
3. **Monitoring**: Add Prometheus/Grafana for observability
4. **CI/CD**: Automate deployments with GitHub Actions
5. **Multi-region**: Deploy to multiple regions for HA

## Support

- [OVH Documentation](https://docs.ovh.com/gb/en/)
- [Terraform OVH Provider](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

For issues, create a GitHub issue in the repository.
