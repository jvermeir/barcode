#!/bin/bash
# Pre-deployment validation script
# Checks all prerequisites before deploying to OVH Cloud

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Barcode App - OVH Cloud Deployment Validator${NC}"
echo "=============================================="
echo ""

ERRORS=0
WARNINGS=0

# Function to check command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $1 is installed"
        if [ ! -z "$2" ]; then
            VERSION=$("$1" $2 2>&1 | head -n1)
            echo "    Version: $VERSION"
        fi
    else
        echo -e "  ${RED}✗${NC} $1 is NOT installed"
        echo "    Install: $3"
        ((ERRORS++))
    fi
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "  ${GREEN}✓${NC} $1 exists"
    else
        echo -e "  ${YELLOW}!${NC} $1 not found"
        echo "    $2"
        ((WARNINGS++))
    fi
}

# Function to check variable is set
check_var() {
    if grep -q "^$1.*=.*\".*\"" terraform.tfvars 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $1 is configured"
    else
        echo -e "  ${RED}✗${NC} $1 is NOT configured"
        echo "    Set in terraform.tfvars"
        ((ERRORS++))
    fi
}

echo -e "\n${BLUE}1. Checking Required Tools${NC}"
echo "-------------------------"
check_command "terraform" "--version" "https://www.terraform.io/downloads"
check_command "kubectl" "version --client" "https://kubernetes.io/docs/tasks/tools/"
check_command "docker" "--version" "https://docs.docker.com/get-docker/"
check_command "aws" "--version" "pip install awscli (for S3 uploads)"

echo -e "\n${BLUE}2. Checking Terraform Configuration${NC}"
echo "-----------------------------------"
check_file "terraform.tfvars" "Copy from terraform.tfvars.example and configure"
check_file "main.tf" "Should exist in terraform directory"
check_file "variables.tf" "Should exist in terraform directory"
check_file "outputs.tf" "Should exist in terraform directory"

echo -e "\n${BLUE}3. Checking Terraform Variables${NC}"
echo "-------------------------------"
if [ -f "terraform.tfvars" ]; then
    check_var "ovh_application_key"
    check_var "ovh_application_secret"
    check_var "ovh_consumer_key"
    check_var "ovh_project_id"
    
    # Check if using example values
    if grep -q "your-application-key\|your-project-id" terraform.tfvars 2>/dev/null; then
        echo -e "  ${RED}✗${NC} Detected example placeholder values"
        echo "    Replace 'your-*' placeholders with actual OVH credentials"
        ((ERRORS++))
    fi
else
    echo -e "  ${RED}✗${NC} terraform.tfvars not found - skipping variable checks"
    ((ERRORS++))
fi

echo -e "\n${BLUE}4. Checking Backend Docker Image${NC}"
echo "--------------------------------"
if [ -f "../apps/backend/Dockerfile" ]; then
    echo -e "  ${GREEN}✓${NC} Backend Dockerfile exists"
else
    echo -e "  ${YELLOW}!${NC} Backend Dockerfile not found"
    echo "    May affect deployment"
    ((WARNINGS++))
fi

# Check if GitHub Actions workflow exists
if [ -f "../.github/workflows/build-backend.yml" ]; then
    echo -e "  ${GREEN}✓${NC} GitHub Actions workflow configured"
else
    echo -e "  ${YELLOW}!${NC} GitHub Actions workflow not found"
    ((WARNINGS++))
fi

echo -e "\n${BLUE}5. Checking Terraform Initialization${NC}"
echo "------------------------------------"
if [ -d ".terraform" ]; then
    echo -e "  ${GREEN}✓${NC} Terraform is initialized"
else
    echo -e "  ${YELLOW}!${NC} Terraform not initialized"
    echo "    Run: terraform init"
    ((WARNINGS++))
fi

echo -e "\n${BLUE}6. Checking Network Access${NC}"
echo "-------------------------"
if curl -s --connect-timeout 5 https://api.ovh.com/1.0/ping &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Can reach OVH API (api.ovh.com)"
else
    echo -e "  ${YELLOW}!${NC} Cannot reach OVH API"
    echo "    Check internet connection and firewall settings"
    ((WARNINGS++))
fi

echo -e "\n${BLUE}7. Checking Frontend Build${NC}"
echo "-------------------------"
if [ -f "../package.json" ]; then
    echo -e "  ${GREEN}✓${NC} package.json exists"
    if [ -d "../node_modules" ]; then
        echo -e "  ${GREEN}✓${NC} Dependencies installed"
    else
        echo -e "  ${YELLOW}!${NC} Dependencies not installed"
        echo "    Run: npm install"
        ((WARNINGS++))
    fi
else
    echo -e "  ${RED}✗${NC} package.json not found"
    ((ERRORS++))
fi

# Summary
echo ""
echo "=============================================="
echo -e "${BLUE}Validation Summary${NC}"
echo "=============================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You are ready to deploy:"
    echo "  ./deploy.sh"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo ""
    echo "You can proceed with deployment, but review warnings above."
    echo "  ./deploy.sh"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) and $WARNINGS warning(s) found${NC}"
    echo ""
    echo "Please fix the errors above before deploying."
    echo ""
    echo "Common fixes:"
    echo "  1. Install missing tools"
    echo "  2. Create and configure terraform.tfvars"
    echo "  3. Run: terraform init"
    echo "  4. Get OVH credentials: https://api.ovh.com/createToken/"
    exit 1
fi
