#!/bin/bash
# Script to upload frontend static files to OVH Object Storage

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Frontend Upload Script${NC}"
echo "======================"

# Check if aws CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    echo "Install it with: pip install awscli"
    exit 1
fi

# Change to terraform directory
cd "$(dirname "$0")"

# Check if terraform has been applied
if [ ! -f terraform.tfstate ]; then
    echo -e "${RED}Error: Terraform state not found. Please run terraform apply first.${NC}"
    exit 1
fi

# Get S3 credentials from Terraform output
echo -e "${GREEN}Getting S3 credentials from Terraform...${NC}"
S3_ENDPOINT=$(terraform output -raw s3_endpoint 2>/dev/null || echo "")
S3_ACCESS_KEY=$(terraform output -raw s3_access_key 2>/dev/null || echo "")
S3_SECRET_KEY=$(terraform output -raw s3_secret_key 2>/dev/null || echo "")
BUCKET_NAME=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "")

if [ -z "$S3_ENDPOINT" ] || [ -z "$S3_ACCESS_KEY" ] || [ -z "$S3_SECRET_KEY" ]; then
    echo -e "${RED}Error: Could not get S3 credentials from Terraform.${NC}"
    exit 1
fi

# Build frontend
echo -e "\n${GREEN}Building frontend...${NC}"
cd ..
npm run build:frontend

# Check if build directory exists
if [ ! -d "dist/apps/frontend" ]; then
    echo -e "${RED}Error: Build directory not found.${NC}"
    exit 1
fi

# Upload to S3
echo -e "\n${GREEN}Uploading to OVH Object Storage...${NC}"
AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY \
AWS_SECRET_ACCESS_KEY=$S3_SECRET_KEY \
aws s3 sync dist/apps/frontend/ s3://$BUCKET_NAME/ \
  --endpoint-url $S3_ENDPOINT \
  --acl public-read \
  --delete

echo -e "\n${GREEN}Upload complete!${NC}"
echo -e "Frontend URL: $(cd terraform && terraform output -raw frontend_bucket_url)"
