# Quick Start: Deploy to OVH Cloud

This guide helps you deploy the Barcode app to OVH Cloud in under 30 minutes.

## Prerequisites Checklist

- [ ] OVH Public Cloud account
- [ ] Terraform installed (v1.0+)
- [ ] kubectl installed
- [ ] Docker installed
- [ ] Git repository cloned

## Step-by-Step Guide

### 1. Get OVH Credentials (5 minutes)

1. Go to [OVH API Token Generator](https://api.ovh.com/createToken/)
2. Login and create token with these rights:
   ```
   GET    /cloud/*
   POST   /cloud/*
   PUT    /cloud/*
   DELETE /cloud/*
   ```
3. Save these values:
   - Application Key
   - Application Secret
   - Consumer Key
4. Get your Project ID from OVH Control Panel → Public Cloud

### 2. Build Backend Image (5 minutes)

**Option A: GitHub Actions (Recommended)**
```bash
# Push to trigger automatic build
git push origin main
# Wait for workflow to complete
# Check: https://github.com/jvermeir/barcode/actions
```

**Option B: Local Build**
```bash
cd apps/backend
docker build -t ghcr.io/jvermeir/barcode-backend:latest .
docker push ghcr.io/jvermeir/barcode-backend:latest
```

### 3. Configure Terraform (2 minutes)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
ovh_endpoint           = "ovh-eu"
ovh_application_key    = "YOUR_APP_KEY"
ovh_application_secret = "YOUR_APP_SECRET"
ovh_consumer_key       = "YOUR_CONSUMER_KEY"
ovh_project_id         = "YOUR_PROJECT_ID"
```

### 4. Deploy Infrastructure (10-15 minutes)

```bash
# Automated deployment
./deploy.sh

# Answer 'yes' when prompted
```

This creates:
- ✓ Private network
- ✓ Kubernetes cluster
- ✓ PostgreSQL database
- ✓ Object Storage bucket

### 5. Verify Deployment (2 minutes)

```bash
# Set kubeconfig
export KUBECONFIG=./kubeconfig.yaml

# Check backend pods
kubectl get pods -n barcode-backend

# Get backend URL
kubectl get svc -n barcode-backend

# Test health endpoint
BACKEND_IP=$(kubectl get svc -n barcode-backend barcode-backend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$BACKEND_IP/barcodes/health
```

Expected output: `{"status":"healthy"}`

### 6. Deploy Frontend (5 minutes)

```bash
# Upload frontend files
./upload-frontend.sh

# Or manually
cd ..
npm run build:frontend
cd terraform
terraform output frontend_bucket_url
# Upload files to this URL
```

### 7. Test Application (2 minutes)

```bash
# Get URLs
echo "Backend: http://$(kubectl get svc -n barcode-backend barcode-backend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "Frontend: $(terraform output -raw frontend_bucket_url)"

# Test backend
curl -X GET http://BACKEND_IP/barcodes

# Test frontend
curl -I FRONTEND_URL/index.html
```

## What's Deployed?

| Component | Type | Cost/Month |
|-----------|------|------------|
| Kubernetes (2 nodes) | Managed | ~€40 |
| PostgreSQL | Managed | ~€20 |
| Object Storage | Pay-as-you-go | ~€1 |
| **Total** | | **~€60** |

## Common Issues

### "Error: timeout waiting for cluster"
- **Fix**: Cluster creation takes 10-15 minutes, wait and retry

### "Backend pods not ready"
```bash
kubectl describe pods -n barcode-backend
kubectl logs -n barcode-backend -l app=barcode-backend
```
- **Fix**: Check database connection in logs

### "Frontend not accessible"
```bash
terraform output frontend_bucket_url
aws s3 ls s3://barcode-frontend/ --endpoint-url $(terraform output -raw s3_endpoint)
```
- **Fix**: Ensure files uploaded with public-read ACL

## Next Steps

- [ ] Configure custom domain
- [ ] Set up SSL/TLS certificates
- [ ] Enable monitoring
- [ ] Configure backups
- [ ] Set up CI/CD

## Cleanup

To delete everything:
```bash
terraform destroy
```

⚠️ **Warning**: This deletes all data permanently!

## Get Help

- 📖 [Full Deployment Guide](../docs/DEPLOYMENT_GUIDE.md)
- 📖 [Terraform Guide](TERRAFORM_GUIDE.md)
- 🌐 [OVH Documentation](https://docs.ovh.com/)
- 🐛 [Report Issues](https://github.com/jvermeir/barcode/issues)
