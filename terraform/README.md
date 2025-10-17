# Deploying Barcode App on OVH Cloud with Terraform

This directory contains Terraform configuration for deploying the Barcode application to OVH Cloud.

## Architecture Overview

The deployment creates the following infrastructure:

1. **Private Network (vRack)**: Secure private networking for resources
2. **Managed Kubernetes Cluster**: Hosts the backend application
3. **Managed PostgreSQL Database**: Persistent data storage
4. **Object Storage**: Hosts frontend static files
5. **Container Registry**: Stores Docker images

## Prerequisites

Before deploying, ensure you have:

- **OVH Account**: Active OVH Public Cloud account
- **Terraform**: Version 1.0 or later ([Download](https://www.terraform.io/downloads))
- **OVH API Credentials**: Application key, secret, and consumer key
- **Backend Docker Image**: Backend application containerized and pushed to a registry

### Getting OVH API Credentials

1. Visit [OVH API Token Creation](https://api.ovh.com/createToken/)
2. Log in with your OVH account
3. Set the required rights:
   - `GET /cloud/*`
   - `POST /cloud/*`
   - `PUT /cloud/*`
   - `DELETE /cloud/*`
4. Note down:
   - Application Key
   - Application Secret
   - Consumer Key
5. Find your Project ID in the OVH Public Cloud console

## Quick Start

### 1. Clone and Navigate

```bash
cd terraform
```

### 2. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Fill in your OVH credentials and project ID:

```hcl
ovh_endpoint           = "ovh-eu"
ovh_application_key    = "YOUR_APP_KEY"
ovh_application_secret = "YOUR_APP_SECRET"
ovh_consumer_key       = "YOUR_CONSUMER_KEY"
ovh_project_id         = "YOUR_PROJECT_ID"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Deploy

```bash
terraform apply
```

Type `yes` when prompted to confirm deployment.

## Modules

### Networking Module (`modules/networking`)

Creates:
- Private network (vRack)
- Subnet with DHCP
- Network configuration for Kubernetes

### Kubernetes Module (`modules/kubernetes`)

Creates:
- Managed Kubernetes cluster
- Node pool with autoscaling
- Backend namespace
- Backend deployment and service
- Database credentials as Kubernetes secrets

### Database Module (`modules/database`)

Creates:
- Managed PostgreSQL instance
- Database user with credentials
- Database with proper permissions
- IP restrictions for security

### Storage Module (`modules/storage`)

Creates:
- Object Storage container for frontend
- S3 credentials for access
- Container registry for Docker images
- Optional CDN configuration

## Outputs

After successful deployment, Terraform will output:

- **Kubernetes Endpoint**: API server URL
- **Kubeconfig**: For kubectl access
- **Database Connection**: Host, port, credentials
- **Frontend Bucket URL**: For uploading static files
- **Backend Service URL**: Public IP of the backend service

View outputs:

```bash
terraform output
```

View sensitive outputs:

```bash
terraform output -json | jq
```

## Accessing Resources

### Kubernetes Cluster

```bash
# Save kubeconfig
terraform output -raw kubeconfig > kubeconfig.yaml

# Use kubectl
export KUBECONFIG=./kubeconfig.yaml
kubectl get pods -n barcode-backend
```

### Database Connection

```bash
# Get connection details
terraform output database_host
terraform output database_port
terraform output database_connection_string
```

### Frontend Deployment

```bash
# Get S3 credentials
terraform output -json | jq -r '.s3_access_key.value'
terraform output -json | jq -r '.s3_secret_key.value'

# Upload frontend files (example with AWS CLI)
aws s3 sync ../apps/frontend/dist s3://barcode-frontend \
  --endpoint-url $(terraform output -raw s3_endpoint) \
  --region $(terraform output -raw ovh_region)
```

## Environment-Specific Deployments

### Production

```bash
terraform apply -var-file="environments/production/production.tfvars"
```

### Development

Create a `environments/dev/dev.tfvars` with lower resource specs:

```hcl
environment      = "dev"
backend_replicas = 1
db_plan         = "essential"
enable_cdn      = false
```

Then apply:

```bash
terraform apply -var-file="environments/dev/dev.tfvars"
```

## Security Best Practices

### Secrets Management

**Never commit sensitive values to Git!**

1. Use `terraform.tfvars` (gitignored) for secrets
2. Or use environment variables:

```bash
export TF_VAR_ovh_application_key="your-key"
export TF_VAR_ovh_application_secret="your-secret"
export TF_VAR_ovh_consumer_key="your-consumer-key"
```

3. Or use a secrets manager like HashiCorp Vault

### Network Security

- Database is restricted to Kubernetes subnet only
- Private network isolates resources
- Security groups limit traffic to necessary ports

## Maintenance

### Updating Resources

```bash
# Update variables in terraform.tfvars
# Then apply changes
terraform apply
```

### Scaling

```bash
# Edit backend_replicas in terraform.tfvars
backend_replicas = 5

# Apply
terraform apply
```

### Destroying Resources

**Warning: This will delete all resources!**

```bash
terraform destroy
```

## Troubleshooting

### Cluster Not Ready

```bash
# Check cluster status
terraform output cluster_status

# View Kubernetes events
kubectl get events -n barcode-backend
```

### Database Connection Issues

```bash
# Verify IP restrictions
terraform show | grep ip_restriction

# Test connection from a pod
kubectl run -it --rm debug --image=postgres:15 -- \
  psql -h $(terraform output -raw database_host) \
       -U $(terraform output -raw database_username) \
       -d $(terraform output -raw database_name)
```

### Backend Pods Not Starting

```bash
# Check pod logs
kubectl logs -n barcode-backend -l app=barcode-backend

# Describe pods
kubectl describe pods -n barcode-backend
```

## Cost Optimization

- Use `essential` plan for database in dev/test
- Set appropriate min/max nodes for autoscaling
- Use smaller node flavors for non-production
- Disable CDN if not needed
- Review OVH pricing for your region

## Regions

Available OVH regions:
- **GRA** (Gravelines, France): GRA11, GRA9, GRA7
- **SBG** (Strasbourg, France): SBG5
- **BHS** (Beauharnois, Canada): BHS5
- **DE** (Frankfurt, Germany): DE1
- **UK** (London, UK): UK1
- **WAW** (Warsaw, Poland): WAW1

Choose the region closest to your users for best performance.

## Support

For issues:
1. Check [OVH Documentation](https://docs.ovh.com/gb/en/)
2. Review [Terraform OVH Provider](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
3. Check application logs in Kubernetes

## Next Steps

After deployment:

1. **Configure DNS**: Point your domain to the backend service IP
2. **Set up CI/CD**: Automate deployments with GitHub Actions
3. **Enable Monitoring**: Set up logging and metrics
4. **Configure Backups**: Enable database backups in OVH console
5. **SSL/TLS**: Configure certificates for HTTPS
