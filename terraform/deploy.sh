#!/bin/bash
# Helper script to initialize and deploy Barcode app to OVH Cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Barcode App - OVH Cloud Deployment Script${NC}"
echo "=========================================="

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed.${NC}"
    echo "Please install Terraform from https://www.terraform.io/downloads"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo -e "${YELLOW}Warning: terraform.tfvars not found.${NC}"
    echo "Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}Please edit terraform.tfvars with your OVH credentials before proceeding.${NC}"
    exit 1
fi

# Initialize Terraform
echo -e "\n${GREEN}Step 1: Initializing Terraform...${NC}"
terraform init

# Validate configuration
echo -e "\n${GREEN}Step 2: Validating configuration...${NC}"
terraform validate

# Format code
echo -e "\n${GREEN}Step 3: Formatting Terraform code...${NC}"
terraform fmt -recursive

# Create plan
echo -e "\n${GREEN}Step 4: Creating deployment plan...${NC}"
terraform plan -out=tfplan

# Prompt for confirmation
echo -e "\n${YELLOW}Review the plan above. Do you want to apply it? (yes/no)${NC}"
read -r response

if [ "$response" = "yes" ]; then
    echo -e "\n${GREEN}Step 5: Applying configuration...${NC}"
    terraform apply tfplan
    
    echo -e "\n${GREEN}Deployment complete!${NC}"
    echo -e "\n${GREEN}Getting outputs...${NC}"
    terraform output
    
    # Save kubeconfig
    echo -e "\n${GREEN}Saving kubeconfig...${NC}"
    terraform output -raw kubeconfig > kubeconfig.yaml
    echo -e "Kubeconfig saved to: ${GREEN}kubeconfig.yaml${NC}"
    
    echo -e "\n${GREEN}Next steps:${NC}"
    echo "1. Configure kubectl: export KUBECONFIG=\$(pwd)/kubeconfig.yaml"
    echo "2. Check backend pods: kubectl get pods -n barcode-backend"
    echo "3. Upload frontend files to Object Storage"
    
else
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    rm -f tfplan
fi
