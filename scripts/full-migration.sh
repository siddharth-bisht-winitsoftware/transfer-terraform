#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=============================================="
echo "  Multiplex AWS Account Migration"
echo "  Source: 716547169131"
echo "  Target: 742336692415"
echo "=============================================="
echo ""

# Check prerequisites
echo "=== Checking prerequisites ==="
command -v terraform >/dev/null 2>&1 || { echo "ERROR: terraform not found"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "ERROR: aws cli not found"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not found"; exit 1; }
echo "All prerequisites found."
echo ""

# Check AWS profiles
echo "=== Checking AWS credentials ==="
aws sts get-caller-identity --profile default >/dev/null 2>&1 || { echo "ERROR: default profile not configured"; exit 1; }
aws sts get-caller-identity --profile client-account >/dev/null 2>&1 || { echo "ERROR: client-account profile not configured"; exit 1; }
echo "AWS profiles configured correctly."
echo ""

# Confirm before proceeding
echo "This script will:"
echo "  1. Create infrastructure in target account (Terraform)"
echo "  2. Migrate Docker images to new ECR"
echo "  3. Migrate PostgreSQL database"
echo "  4. Deploy Lambda function code"
echo ""
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# Step 1: Terraform
echo ""
echo "=============================================="
echo "  Step 1: Creating Infrastructure (Terraform)"
echo "=============================================="
cd "$PROJECT_DIR"

if [ ! -f "terraform.tfvars" ]; then
    echo "ERROR: terraform.tfvars not found"
    echo "Copy terraform.tfvars.example to terraform.tfvars and fill in values."
    exit 1
fi

terraform init
terraform plan -out=tfplan
terraform apply tfplan

echo ""
echo "Infrastructure created successfully!"
echo ""

# Get outputs
DB_ENDPOINT=$(terraform output -raw db_address)
ECR_WINITAPI=$(terraform output -raw ecr_winitapi_url)
CLOUDFRONT_DOMAIN=$(terraform output -raw cloudfront_domain_name)

echo "Database endpoint: $DB_ENDPOINT"
echo "ECR URL: $ECR_WINITAPI"
echo "CloudFront domain: $CLOUDFRONT_DOMAIN"
echo ""

# Step 2: ECR Images
echo "=============================================="
echo "  Step 2: Migrating Docker Images"
echo "=============================================="
read -p "Migrate Docker images now? (yes/no): " MIGRATE_IMAGES
if [ "$MIGRATE_IMAGES" == "yes" ]; then
    bash "$SCRIPT_DIR/push-images.sh"
fi

# Step 3: Database
echo ""
echo "=============================================="
echo "  Step 3: Migrating Database"
echo "=============================================="
echo "NOTE: This will cause downtime. Perform during maintenance window."
read -p "Migrate database now? (yes/no): " MIGRATE_DB
if [ "$MIGRATE_DB" == "yes" ]; then
    export TARGET_HOST="$DB_ENDPOINT"
    bash "$SCRIPT_DIR/migrate-db.sh"
fi

# Step 4: Lambda
echo ""
echo "=============================================="
echo "  Step 4: Deploying Lambda Code"
echo "=============================================="
read -p "Deploy Lambda code now? (yes/no): " DEPLOY_LAMBDA
if [ "$DEPLOY_LAMBDA" == "yes" ]; then
    bash "$SCRIPT_DIR/deploy-lambda.sh"
fi

# Summary
echo ""
echo "=============================================="
echo "  Migration Summary"
echo "=============================================="
terraform output migration_summary

echo ""
echo "=============================================="
echo "  Next Steps"
echo "=============================================="
echo ""
echo "1. ACM Certificate Validation:"
echo "   Add the following DNS records to validate the certificate:"
terraform output acm_certificate_validation
echo ""
echo "2. Update ECS Service to use new images:"
echo "   aws ecs update-service --cluster multiplex_production --service winitapi-service --force-new-deployment --profile client-account"
echo ""
echo "3. DNS Cutover:"
echo "   Update DNS record for ${DOMAIN_NAME:-your-domain} to point to:"
echo "   $CLOUDFRONT_DOMAIN"
echo ""
echo "4. Verify everything is working in the new account"
echo ""
echo "5. After validation, decommission old infrastructure"
echo ""
echo "Migration script complete!"
