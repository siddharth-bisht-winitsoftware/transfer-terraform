#!/bin/bash
set -e

# Configuration
SOURCE_ACCOUNT="716547169131"
TARGET_ACCOUNT="742336692415"
REGION="ap-south-1"
SOURCE_PROFILE="default"      # Profile for source account
TARGET_PROFILE="client-account"  # Profile for target account

REPOSITORIES=("multiplex/winitapi" "multiplex/syncconsumer")

echo "=== ECR Image Migration Script ==="
echo "Source Account: $SOURCE_ACCOUNT"
echo "Target Account: $TARGET_ACCOUNT"
echo ""

# Login to source ECR
echo "Logging into source ECR..."
aws ecr get-login-password --region $REGION --profile $SOURCE_PROFILE | \
    docker login --username AWS --password-stdin ${SOURCE_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

# Login to target ECR
echo "Logging into target ECR..."
aws ecr get-login-password --region $REGION --profile $TARGET_PROFILE | \
    docker login --username AWS --password-stdin ${TARGET_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

# Migrate each repository
for REPO in "${REPOSITORIES[@]}"; do
    echo ""
    echo "=== Processing: $REPO ==="

    SOURCE_URI="${SOURCE_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}"
    TARGET_URI="${TARGET_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}"

    # List images in source repo
    echo "Fetching image tags from source..."
    TAGS=$(aws ecr list-images --repository-name $REPO --region $REGION --profile $SOURCE_PROFILE \
        --query 'imageIds[*].imageTag' --output text | tr '\t' '\n' | grep -v "^None$" | head -5)

    if [ -z "$TAGS" ]; then
        echo "No tags found for $REPO, trying 'latest'..."
        TAGS="latest"
    fi

    for TAG in $TAGS; do
        echo "  Pulling: ${SOURCE_URI}:${TAG}"
        docker pull ${SOURCE_URI}:${TAG} || { echo "Failed to pull $TAG, skipping..."; continue; }

        echo "  Tagging: ${TARGET_URI}:${TAG}"
        docker tag ${SOURCE_URI}:${TAG} ${TARGET_URI}:${TAG}

        echo "  Pushing: ${TARGET_URI}:${TAG}"
        docker push ${TARGET_URI}:${TAG}

        echo "  Done: $TAG"
    done
done

echo ""
echo "=== Image migration complete! ==="
echo ""
echo "Next steps:"
echo "1. Update ECS task definition to use new image URIs"
echo "2. Deploy ECS service with: aws ecs update-service --cluster <cluster> --service <service> --force-new-deployment"
