#!/bin/bash

################################################################################
# CDK Bootstrap Script
# Run this ONCE to bootstrap your AWS account for CDK
################################################################################

set -e

ACCOUNT="992167236365"
REGION="us-east-1"
PROFILE="mac-prod-prod"

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

# Check if already bootstrapped
echo "Checking if CDK is already bootstrapped..."
if aws s3 ls s3://cdk-hnb659fds-assets-$ACCOUNT-$REGION --profile $PROFILE > /dev/null 2>&1; then
    echo "✓ CDK is already bootstrapped!"
    echo ""
    echo "You can now run: cd multi-agent-orchestration-on-aws && npm run develop"
    exit 0
fi

echo "CDK is NOT bootstrapped"
echo ""

# Bootstrap
echo "Bootstrapping CDK..."
echo "This will create:"
echo "  - S3 bucket: cdk-hnb659fds-assets-$ACCOUNT-$REGION"
echo "  - IAM roles for CDK deployments"
echo "  - ECR repositories for Docker images"
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
    echo "  cd ../../"
    echo "  npm run develop"
    echo ""
else
    echo ""
    echo "❌ Bootstrap failed!"
    echo "Check your AWS credentials and permissions"
    exit 1
fi
