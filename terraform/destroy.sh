#!/bin/bash
# Helper script to safely destroy all OVH Cloud resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}Barcode App - OVH Cloud Cleanup Script${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}WARNING: This will permanently delete ALL resources!${NC}"
echo ""
echo "This includes:"
echo "  - Kubernetes cluster and all pods"
echo "  - PostgreSQL database and ALL DATA"
echo "  - Object Storage bucket and frontend files"
echo "  - Private network"
echo ""
echo -e "${YELLOW}This action CANNOT be undone!${NC}"
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed.${NC}"
    exit 1
fi

# Check if terraform.tfstate exists
if [ ! -f terraform.tfstate ]; then
    echo -e "${YELLOW}Warning: No terraform state file found.${NC}"
    echo "Nothing to destroy."
    exit 0
fi

# Show current resources
echo -e "\n${GREEN}Current deployed resources:${NC}"
terraform show -json | jq -r '.values.root_module.child_modules[].resources[].address' 2>/dev/null || terraform show

# Confirm destruction
echo ""
echo -e "${RED}Are you absolutely sure you want to destroy everything?${NC}"
echo "Type 'yes' to confirm:"
read -r response

if [ "$response" != "yes" ]; then
    echo -e "${GREEN}Destruction cancelled. No changes made.${NC}"
    exit 0
fi

# Final confirmation
echo ""
echo -e "${RED}Last chance! Type 'DELETE' to proceed:${NC}"
read -r final_confirm

if [ "$final_confirm" != "DELETE" ]; then
    echo -e "${GREEN}Destruction cancelled. No changes made.${NC}"
    exit 0
fi

# Destroy resources
echo -e "\n${YELLOW}Starting destruction...${NC}"
terraform destroy -auto-approve

# Cleanup local files
echo -e "\n${GREEN}Cleaning up local files...${NC}"
rm -f kubeconfig.yaml
rm -f tfplan
rm -f .terraform.lock.hcl

echo -e "\n${GREEN}Destruction complete!${NC}"
echo "All OVH Cloud resources have been deleted."
