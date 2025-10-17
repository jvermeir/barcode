# Terraform Files Index

Quick reference guide to all files in the Terraform directory.

## Core Configuration Files

### `main.tf`
Main Terraform configuration file that:
- Configures OVH provider
- Declares all modules (networking, kubernetes, database, storage)
- Sets up provider relationships
- Connects modules together

### `variables.tf`
Input variables for the deployment:
- OVH credentials (application key, secret, consumer key)
- Region and project settings
- Resource sizing (nodes, replicas, database plan)
- Network configuration

### `outputs.tf`
Output values after deployment:
- Kubernetes endpoint and kubeconfig
- Database connection details
- Frontend bucket URLs
- Service endpoints
- Deployment summary

### `terraform.tfvars.example`
Example configuration file to copy and customize:
- Template with all required variables
- Example values and comments
- Copy to `terraform.tfvars` and fill in real values

## Modules

### `modules/networking/`
Private network configuration:
- **main.tf**: Creates vRack private network and subnet
- **variables.tf**: Network name, CIDR, region
- **outputs.tf**: Network and subnet IDs

### `modules/kubernetes/`
Kubernetes cluster and backend deployment:
- **main.tf**: K8s cluster, node pool, namespace, backend deployment, service
- **variables.tf**: Cluster config, node sizing, backend image
- **outputs.tf**: Cluster endpoint, kubeconfig, service URL

### `modules/database/`
PostgreSQL managed database:
- **main.tf**: Database instance, user, schema, IP restrictions
- **variables.tf**: Database version, plan, sizing
- **outputs.tf**: Connection details, credentials

### `modules/storage/`
Object Storage for frontend:
- **main.tf**: S3 bucket, credentials, registry
- **variables.tf**: Bucket name, CDN settings
- **outputs.tf**: Bucket URL, S3 credentials

## Helper Scripts

### `deploy.sh` ⭐
**Main deployment script** - Automated deployment workflow:
```bash
./deploy.sh
```
- Initializes Terraform
- Validates configuration
- Creates deployment plan
- Applies infrastructure
- Saves kubeconfig
- Shows next steps

### `validate.sh`
**Pre-deployment checker** - Validates prerequisites:
```bash
./validate.sh
```
- Checks required tools (terraform, kubectl, docker)
- Validates configuration files
- Verifies credentials
- Tests network access
- Reports errors and warnings

### `upload-frontend.sh`
**Frontend deployment** - Uploads static files:
```bash
./upload-frontend.sh
```
- Builds frontend application
- Gets S3 credentials from Terraform
- Uploads files to Object Storage
- Sets public permissions

### `destroy.sh` ⚠️
**Resource cleanup** - Destroys all infrastructure:
```bash
./destroy.sh
```
- Double confirmation required
- Shows resources to be deleted
- Destroys all OVH resources
- Cleans up local files
- **WARNING**: Permanent deletion!

## Environment Configurations

### `environments/production/production.tfvars`
Production environment overrides:
- Higher replica counts
- Business-tier database
- CDN enabled
- Production-grade settings

Can use with:
```bash
terraform apply -var-file="environments/production/production.tfvars"
```

## Documentation

### `README.md` 📖
Main Terraform documentation:
- Quick start guide
- Module descriptions
- Deployment instructions
- Maintenance procedures
- Troubleshooting

### `QUICKSTART.md` 🚀
30-minute deployment guide:
- Step-by-step instructions
- Prerequisites checklist
- Common issues
- Fast deployment path

### `TERRAFORM_GUIDE.md` 📚
Comprehensive technical reference:
- Detailed module documentation
- All variables and outputs
- Advanced configuration
- Security features
- Cost optimization

### `ARCHITECTURE.md` 🏗️
Architecture diagrams and design:
- Infrastructure diagrams
- Data flow
- Security architecture
- Scalability design
- High availability

### `IMPLEMENTATION_SUMMARY.md` ✅
Implementation checklist:
- What was implemented
- File structure
- Verification steps
- Testing procedures
- Success criteria

## Configuration Files

### `.gitignore`
Git ignore rules:
- Excludes `.terraform/` directory
- Ignores state files
- Protects credentials (`*.tfvars`)
- Allows example files
- Ignores kubeconfig files

## Generated Files (Not in Git)

These files are created during deployment and should NOT be committed:

### `.terraform/`
Terraform working directory:
- Provider plugins
- Module cache
- Lock files

### `terraform.tfstate`
Current infrastructure state:
- Contains actual resource IDs
- Sensitive credentials
- Auto-managed by Terraform
- **NEVER commit to Git**

### `terraform.tfstate.backup`
Previous state backup:
- Created on each apply
- Allows state recovery
- **NEVER commit to Git**

### `kubeconfig.yaml`
Kubernetes cluster access:
- Generated from Terraform output
- Contains cluster credentials
- Use with `kubectl`
- **NEVER commit to Git**

### `tfplan`
Terraform execution plan:
- Binary plan file
- Created by `terraform plan`
- Used by `terraform apply`
- Temporary file

### `terraform.tfvars`
Your actual configuration:
- Contains OVH credentials
- Real passwords and keys
- **NEVER commit to Git**
- Copy from `.example` file

## Usage Patterns

### Initial Setup
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with real values
./validate.sh
```

### Deploy Infrastructure
```bash
./deploy.sh
# or manually:
terraform init
terraform plan
terraform apply
```

### Deploy Frontend
```bash
./upload-frontend.sh
```

### Update Resources
```bash
# Edit terraform.tfvars
terraform plan
terraform apply
```

### View Outputs
```bash
terraform output
terraform output -json | jq
terraform output -raw kubeconfig > kubeconfig.yaml
```

### Access Cluster
```bash
export KUBECONFIG=./kubeconfig.yaml
kubectl get pods -n barcode-backend
```

### Cleanup
```bash
./destroy.sh
```

## File Dependencies

```
terraform.tfvars (your config)
    ↓
variables.tf (input definitions)
    ↓
main.tf (resource creation)
    ├─→ modules/networking/
    ├─→ modules/database/
    ├─→ modules/kubernetes/
    └─→ modules/storage/
    ↓
outputs.tf (export values)
    ↓
kubeconfig.yaml (cluster access)
```

## Quick Reference

| Need to... | Use this file/script |
|------------|---------------------|
| Deploy everything | `./deploy.sh` |
| Check prerequisites | `./validate.sh` |
| Upload frontend | `./upload-frontend.sh` |
| Delete everything | `./destroy.sh` |
| Get started quickly | `QUICKSTART.md` |
| Understand architecture | `ARCHITECTURE.md` |
| Learn Terraform details | `TERRAFORM_GUIDE.md` |
| Troubleshoot issues | `README.md` |
| Configure deployment | `terraform.tfvars` |
| See what's deployed | `terraform output` |
| Access cluster | `kubeconfig.yaml` |

## Security Reminders

❌ **NEVER commit these files:**
- `terraform.tfvars` (credentials)
- `terraform.tfstate` (state with secrets)
- `terraform.tfstate.backup`
- `kubeconfig.yaml` (cluster access)
- `.terraform/` directory

✅ **Safe to commit:**
- `*.example` files
- Documentation (`.md` files)
- Module definitions (`modules/*/`)
- Helper scripts (`*.sh`)
- `.gitignore`
- Environment templates (`environments/*/`)

## Support

- **Questions**: See documentation files above
- **Issues**: https://github.com/jvermeir/barcode/issues
- **OVH Docs**: https://docs.ovh.com/
- **Terraform**: https://registry.terraform.io/providers/ovh/ovh/
