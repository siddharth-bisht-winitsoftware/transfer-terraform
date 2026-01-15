#!/bin/bash
set -e

# Configuration
SOURCE_FUNCTION="multiplex-sqlite-scheduler"
TARGET_FUNCTION="multiplex-sqlite-scheduler"
SOURCE_PROFILE="default"
TARGET_PROFILE="client-account"
REGION="ap-south-1"
LAMBDA_ZIP="lambda_code.zip"

echo "=== Lambda Function Migration Script ==="
echo ""

# Download Lambda code from source account
echo "=== Step 1: Downloading Lambda code from source account ==="
CODE_URL=$(aws lambda get-function \
    --function-name $SOURCE_FUNCTION \
    --region $REGION \
    --profile $SOURCE_PROFILE \
    --query 'Code.Location' \
    --output text)

if [ -z "$CODE_URL" ]; then
    echo "ERROR: Could not get Lambda code URL"
    exit 1
fi

echo "Downloading from presigned URL..."
curl -o $LAMBDA_ZIP "$CODE_URL"

if [ ! -f "$LAMBDA_ZIP" ]; then
    echo "ERROR: Failed to download Lambda code"
    exit 1
fi

echo "Downloaded: $LAMBDA_ZIP ($(ls -lh $LAMBDA_ZIP | awk '{print $5}'))"
echo ""

# Update Lambda function in target account
echo "=== Step 2: Updating Lambda function in target account ==="
aws lambda update-function-code \
    --function-name $TARGET_FUNCTION \
    --zip-file fileb://$LAMBDA_ZIP \
    --region $REGION \
    --profile $TARGET_PROFILE

echo ""
echo "=== Lambda migration complete! ==="
echo ""

# Test the function
echo "=== Step 3: Testing Lambda function ==="
echo "Invoking Lambda function..."
aws lambda invoke \
    --function-name $TARGET_FUNCTION \
    --region $REGION \
    --profile $TARGET_PROFILE \
    --payload '{}' \
    lambda_response.json

echo "Response:"
cat lambda_response.json
echo ""

# Cleanup
rm -f lambda_response.json

echo ""
echo "Lambda code file retained at: $LAMBDA_ZIP"
echo ""
echo "Next steps:"
echo "1. Verify EventBridge schedule is working"
echo "2. Check CloudWatch logs for any errors"
echo "3. Delete $LAMBDA_ZIP when no longer needed"
