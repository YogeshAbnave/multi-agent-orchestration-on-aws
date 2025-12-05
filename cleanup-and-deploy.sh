#!/bin/bash

################################################################################
# Cleanup Failed Stack and Redeploy Script
# This script cleans up failed CloudFormation stacks and redeploys
################################################################################

set -e

ACCOUNT="992167236365"
REGION="us-east-1"
PROFILE="mac-prod-prod"
STACK_NAME="prod-mac-prod-backend"
BUCKET_NAME="prod-mac-prod-backend-athena-results-$ACCOUNT"

echo ""
echo "=========================================="
echo "  Cleanup and Redeploy"
echo "  Stack: $STACK_NAME"
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

echo "✓ AWS credentials validated"
echo ""

# Check if stack exists and is in failed state
echo "Checking stack status..."
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DOES_NOT_EXIST")

if [ "$STACK_STATUS" = "DOES_NOT_EXIST" ]; then
    echo "✓ Stack does not exist, proceeding to deployment"
elif [[ "$STACK_STATUS" == *"FAILED"* ]] || [[ "$STACK_STATUS" == "ROLLBACK_COMPLETE" ]]; then
    echo "⚠️  Stack is in failed state: $STACK_STATUS"
    echo "Cleaning up failed stack..."
    
    # Try to empty and delete the problematic S3 bucket
    echo ""
    echo "Step 1: Cleaning up S3 bucket: $BUCKET_NAME"
    
    if aws s3 ls s3://$BUCKET_NAME --profile $PROFILE > /dev/null 2>&1; then
        echo "Bucket exists, emptying contents..."
        
        # Delete all objects
        aws s3 rm s3://$BUCKET_NAME --recursive --profile $PROFILE 2>/dev/null || true
        
        # Delete all versions if versioning is enabled
        echo "Deleting all object versions..."
        aws s3api list-object-versions \
            --bucket $BUCKET_NAME \
            --profile $PROFILE \
            --output json \
            --query 'Versions[].{Key:Key,VersionId:VersionId}' 2>/dev/null | \
        jq -r '.[]? | "--key \"\(.Key)\" --version-id \(.VersionId)"' | \
        while read -r args; do
            eval aws s3api delete-object --bucket $BUCKET_NAME $args --profile $PROFILE 2>/dev/null || true
        done
        
        # Delete all delete markers
        echo "Deleting all delete markers..."
        aws s3api list-object-versions \
            --bucket $BUCKET_NAME \
            --profile $PROFILE \
            --output json \
            --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' 2>/dev/null | \
        jq -r '.[]? | "--key \"\(.Key)\" --version-id \(.VersionId)"' | \
        while read -r args; do
            eval aws s3api delete-object --bucket $BUCKET_NAME $args --profile $PROFILE 2>/dev/null || true
        done
        
        # Delete the bucket
        echo "Deleting bucket..."
        aws s3 rb s3://$BUCKET_NAME --force --profile $PROFILE 2>/dev/null || true
        
        echo "✓ Bucket cleanup complete"
    else
        echo "✓ Bucket does not exist, skipping"
    fi
    
    echo ""
    echo "Step 2: Deleting CloudFormation stack: $STACK_NAME"
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE
    
    echo "Waiting for stack deletion to complete (this may take several minutes)..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --profile $PROFILE 2>/dev/null || {
        echo "⚠️  Stack deletion wait timed out or failed, checking status..."
        FINAL_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DELETED")
        if [ "$FINAL_STATUS" = "DELETED" ]; then
            echo "✓ Stack deleted successfully"
        else
            echo "❌ Stack deletion failed with status: $FINAL_STATUS"
            echo "Please manually delete the stack from AWS Console"
            exit 1
        fi
    }
    
    echo "✓ Stack cleanup complete"
else
    echo "✓ Stack is in good state: $STACK_STATUS"
fi

echo ""
echo "=========================================="
echo "  Starting Deployment"
echo "=========================================="
echo ""

# Navigate to project directory and deploy
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws

echo "Running npm run develop..."
echo "Please select option 3 (Deploy CDK Stack(s)) from the menu"
echo ""

npm run develop
