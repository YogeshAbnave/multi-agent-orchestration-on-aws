#!/bin/bash

################################################################################
# CDK Bootstrap Script
# Run this ONCE to bootstrap your AWS account for CDK
################################################################################

set -e

ACCOUNT="992167236365"
REGION="us-east-1"
PROFILE="mac-prod-prod"
BUCKET_NAME="cdk-hnb659fds-assets-$ACCOUNT-$REGION"

echo ""
echo "=========================================="
echo "  CDK Bootstrap"
echo "  Account: $ACCOUNT"
echo "  Region: $REGION"
echo "=========================================="
echo ""

# Validate credentials
echo "Validating AWS credentials..."
if ! aws sts get-caller-identity --profile $PROFILE > /dev/null 2>&1; then
    echo "❌ AWS credentials invalid or expired!"
    echo "Run: aws configure --profile $PROFILE"
    exit 1
fi

CURRENT_ACCOUNT=$(aws sts get-caller-identity --profile $PROFILE --query Account --output text)
if [ "$CURRENT_ACCOUNT" != "$ACCOUNT" ]; then
    echo "❌ Wrong AWS account! Expected: $ACCOUNT, Got: $CURRENT_ACCOUNT"
    exit 1
fi

echo "✓ AWS credentials validated"
echo ""

# Check if bucket exists
echo "Checking if CDK bootstrap bucket exists..."
if aws s3 ls s3://$BUCKET_NAME --profile $PROFILE > /dev/null 2>&1; then
    echo "✓ CDK bootstrap bucket already exists!"
else
    echo "Creating CDK bootstrap bucket: $BUCKET_NAME"
    
    # Create the bucket
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --profile $PROFILE
    else
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $REGION \
            --create-bucket-configuration LocationConstraint=$REGION \
            --profile $PROFILE
    fi
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket $BUCKET_NAME \
        --versioning-configuration Status=Enabled \
        --profile $PROFILE
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket $BUCKET_NAME \
        --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
        --profile $PROFILE
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket $BUCKET_NAME \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
        --profile $PROFILE
    
    echo "✓ CDK bootstrap bucket created successfully!"
fi

echo ""

# Run CDK bootstrap to create all necessary resources
echo "Running CDK bootstrap to create IAM roles and other resources..."
echo "This will create:"
echo "  - IAM roles for CDK deployments"
echo "  - ECR repositories for Docker images"
echo "  - SSM parameters for bootstrap version"
echo ""

cd multi-agent-orchestration-on-aws/src/backend

npx aws-cdk@2.1029.2 bootstrap aws://$ACCOUNT/$REGION --profile $PROFILE

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✓ CDK Bootstrap Successful!"
    echo "=========================================="
    echo ""
    echo "You can now deploy with:"
    echo "  cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws"
    echo "  npm run develop"
    echo ""
else
    echo ""
    echo "❌ Bootstrap failed!"
    echo "Check your AWS credentials and permissions"
    exit 1
fi
