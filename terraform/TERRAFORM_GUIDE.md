# Terraform Infrastructure Summary

## Overview

This directory contains complete Terraform infrastructure-as-code for deploying the Barcode application to OVH Cloud.

## File Structure

```
terraform/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables file
├── .gitignore                 # Git ignore for sensitive files
├── README.md                  # Terraform documentation
├── deploy.sh                  # Deployment helper script
├── upload-frontend.sh         # Frontend upload script
│
├── modules/
│   ├── networking/            # Private network and subnets
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── kubernetes/            # Kubernetes cluster and backend deployment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── database/              # PostgreSQL managed database
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── storage/               # Object Storage for frontend
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── environments/
    └── production/
        └── production.tfvars  # Production-specific variables
```

## Modules

### 1. Networking Module

**Purpose**: Creates private networking infrastructure

**Resources Created**:
- Private network (vRack)
- Subnet with DHCP
- Network configuration for Kubernetes

**Inputs**:
- `project_id`: OVH project ID
- `region`: OVH region
- `network_name`: Network name
- `subnet_cidr`: CIDR block for subnet

**Outputs**:
- `network_id`: Private network ID
- `subnet_id`: Subnet ID
- `subnet_cidr`: CIDR block

### 2. Kubernetes Module

**Purpose**: Provisions managed Kubernetes cluster and deploys backend

**Resources Created**:
- Managed Kubernetes cluster
- Node pool with autoscaling
- Kubernetes namespace for backend
- Backend deployment (Spring Boot app)
- Backend service (LoadBalancer)
- Kubernetes secrets for database credentials
- Optional ingress controller

**Inputs**:
- `project_id`: OVH project ID
- `region`: OVH region
- `cluster_name`: Cluster name
- `kubernetes_version`: K8s version
- `backend_image`: Docker image for backend
- `backend_replicas`: Number of pod replicas
- `db_host`, `db_port`, `db_name`, `db_username`, `db_password`: Database connection info

**Outputs**:
- `cluster_id`: Kubernetes cluster ID
- `cluster_endpoint`: API server endpoint
- `kubeconfig`: Complete kubeconfig file
- `backend_namespace`: Backend namespace
- `backend_service_url`: Public IP of backend

### 3. Database Module

**Purpose**: Creates managed PostgreSQL database

**Resources Created**:
- Managed PostgreSQL instance
- Database user with password
- Database schema
- IP restrictions for security

**Inputs**:
- `project_id`: OVH project ID
- `region`: OVH region
- `db_name`: Database name
- `db_version`: PostgreSQL version
- `db_plan`: Service plan (essential/business/enterprise)
- `allowed_cidrs`: IP ranges allowed to connect

**Outputs**:
- `db_host`: Database hostname
- `db_port`: Database port
- `db_name`: Database name
- `db_username`: Database user
- `db_password`: Database password (sensitive)

### 4. Storage Module

**Purpose**: Provides Object Storage for frontend static files

**Resources Created**:
- Object Storage bucket (S3-compatible)
- S3 user and credentials
- Container registry
- Optional CDN configuration

**Inputs**:
- `project_id`: OVH project ID
- `region`: OVH region
- `bucket_name`: Bucket name
- `enable_cdn`: Enable CDN (true/false)

**Outputs**:
- `bucket_name`: Bucket name
- `bucket_url`: Public bucket URL
- `s3_endpoint`: S3 endpoint URL
- `s3_access_key`: S3 access key (sensitive)
- `s3_secret_key`: S3 secret key (sensitive)

## Variables

### Required Variables

These must be set in `terraform.tfvars`:

```hcl
ovh_application_key    = "..."  # OVH API application key
ovh_application_secret = "..."  # OVH API application secret
ovh_consumer_key       = "..."  # OVH API consumer key
ovh_project_id         = "..."  # OVH Public Cloud project ID
```

### Optional Variables

Can be customized or use defaults:

```hcl
ovh_endpoint           = "ovh-eu"              # OVH API endpoint
ovh_region             = "GRA11"               # Deployment region
environment            = "production"          # Environment name
network_name           = "barcode-network"     # Network name
subnet_cidr            = "10.0.0.0/16"         # Subnet CIDR
cluster_name           = "barcode-cluster"     # K8s cluster name
kubernetes_version     = "1.28"                # K8s version
backend_image          = "ghcr.io/..."         # Backend image
backend_replicas       = 2                     # Number of pods
db_name                = "barcode"             # Database name
db_version             = "15"                  # PostgreSQL version
db_plan                = "essential"           # Database plan
frontend_bucket_name   = "barcode-frontend"    # Bucket name
enable_cdn             = false                 # Enable CDN
```

## Outputs

After deployment, Terraform provides:

### Network Outputs
- `network_id`: Private network identifier
- `subnet_id`: Subnet identifier

### Kubernetes Outputs
- `kubernetes_cluster_id`: Cluster ID
- `kubernetes_endpoint`: API server URL
- `kubeconfig`: Complete kubeconfig (sensitive)
- `backend_namespace`: Backend namespace
- `backend_service_url`: Backend public IP

### Database Outputs
- `database_host`: PostgreSQL hostname
- `database_port`: PostgreSQL port
- `database_name`: Database name
- `database_connection_string`: JDBC connection string

### Storage Outputs
- `frontend_bucket_name`: Bucket name
- `frontend_bucket_url`: Public URL
- `frontend_cdn_url`: CDN URL (if enabled)

### Summary Output
- `deployment_summary`: JSON object with all key information

## Quick Start

### 1. Initial Setup

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your OVH credentials
vim terraform.tfvars
```

### 2. Deploy

```bash
# Automated deployment
./deploy.sh

# Or manual steps
terraform init
terraform plan
terraform apply
```

### 3. Get Outputs

```bash
# All outputs
terraform output

# Specific output
terraform output kubernetes_endpoint

# Sensitive output (JSON)
terraform output -json | jq '.kubeconfig.value'

# Save kubeconfig
terraform output -raw kubeconfig > kubeconfig.yaml
```

### 4. Access Cluster

```bash
export KUBECONFIG=./kubeconfig.yaml
kubectl get pods -n barcode-backend
```

## Deployment Flow

The Terraform configuration deploys resources in this order:

1. **Networking** (Module: networking)
   - Private network created
   - Subnet configured

2. **Database** (Module: database)
   - PostgreSQL instance provisioned
   - Database and user created
   - IP restrictions applied

3. **Kubernetes** (Module: kubernetes)
   - Cluster created
   - Node pool configured
   - Backend namespace created
   - Database secrets created
   - Backend deployment applied
   - Service exposed

4. **Storage** (Module: storage)
   - Object Storage bucket created
   - S3 credentials generated
   - Container registry provisioned

## Security Features

### Secrets Management
- Database credentials stored as Kubernetes secrets
- Sensitive outputs marked as sensitive
- `.gitignore` prevents committing credentials

### Network Security
- Database restricted to Kubernetes subnet
- Private network isolates resources
- Security groups limit traffic

### Application Security
- Backend pods run as non-root user
- Resource limits prevent resource exhaustion
- Health checks ensure availability

## Cost Management

### Estimated Costs (Monthly)

| Resource | Plan | Estimated Cost |
|----------|------|----------------|
| Kubernetes (2 nodes) | b2-7 | €35-45 |
| PostgreSQL | Essential | €15-20 |
| Object Storage | Pay-as-you-go | €0.01/GB |
| Network | Free | €0 |
| **Total** | | **€50-65** |

### Cost Optimization Tips

1. **Development**: Use smaller flavors and essential plan
2. **Autoscaling**: Enable to reduce idle resources
3. **Monitoring**: Track usage and optimize
4. **Cleanup**: Delete unused resources

## Maintenance

### Update Backend

```bash
# New image available
terraform apply -var="backend_image=ghcr.io/.../barcode-backend:v2.0"
```

### Scale Application

```bash
# Edit terraform.tfvars
backend_replicas = 5

# Apply
terraform apply
```

### Upgrade Kubernetes

```bash
# Check available versions in OVH console
# Update terraform.tfvars
kubernetes_version = "1.29"

# Apply (may cause downtime)
terraform apply
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This permanently deletes:
- All data in the database
- Frontend files in Object Storage
- Kubernetes cluster and all deployments

## Troubleshooting

### Common Issues

**Issue**: `Error: ovh_cloud_project_kube: timeout waiting for state`
- **Solution**: OVH API may be slow, increase timeout or retry

**Issue**: Database connection refused
- **Solution**: Check IP restrictions, ensure Kubernetes subnet is allowed

**Issue**: Backend pods CrashLoopBackOff
- **Solution**: Check logs with `kubectl logs`, verify database credentials

**Issue**: Frontend not accessible
- **Solution**: Verify bucket exists and files uploaded with correct permissions

### Debug Mode

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
terraform apply
```

## Advanced Configuration

### Custom Domain

Add ingress configuration in `modules/kubernetes/main.tf`:

```hcl
variable "backend_domain" {
  default = "api.yourdomain.com"
}

variable "enable_ingress" {
  default = true
}
```

### Multiple Environments

Create environment-specific tfvars:

```bash
terraform apply -var-file="environments/staging/staging.tfvars"
```

### Remote State

Configure S3 backend for state:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "barcode/production.tfstate"
  }
}
```

## References

- [OVH Terraform Provider](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [OVH Cloud Documentation](https://docs.ovh.com/gb/en/)
- [Terraform Documentation](https://www.terraform.io/docs)
