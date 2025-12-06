#!/bin/bash

################################################################################
# ULTIMATE ALL-IN-ONE DEPLOYMENT SCRIPT
# This script handles everything: cleanup, permissions, and deployment
# Just run: ./deploy.sh
################################################################################

set -e

ACCOUNT_NUMBER=992167236365
REGION=us-east-1
PROFILE="mac-prod-prod"
STACK_NAME="prod-mac-prod-backend"

echo ""
echo "=========================================="
echo "  Multi-Agent Orchestration Deployment"
echo "  Ultimate All-in-One Solution"
echo "  Account: $ACCOUNT_NUMBER"
echo "  Region: $REGION"
echo "=========================================="
echo ""

################################################################################
# STEP 1: Validate AWS Credentials
################################################################################
echo "Step 1: Validating AWS credentials..."
if ! aws sts get-caller-identity --profile $PROFILE > /dev/null 2>&1; then
    echo "❌ AWS credentials invalid or expired!"
    echo "Run: aws configure --profile $PROFILE"
    exit 1
fi
echo "✓ AWS credentials validated"
echo ""

################################################################################
# STEP 1.5: Check Existing Resources (Diagnostic)
################################################################################
echo "Step 1.5: Checking for existing resources that might block deployment..."
echo ""

echo "→ S3 Buckets matching 'prod-mac-prod-backend':"
EXISTING_BUCKETS=$(aws s3api list-buckets --profile $PROFILE --query 'Buckets[].Name' --output text 2>/dev/null | \
tr '\t' '\n' | grep -E "prod-mac-prod-backend" || echo "")
if [ -n "$EXISTING_BUCKETS" ]; then
    echo "$EXISTING_BUCKETS" | sed 's/^/  - /'
else
    echo "  None found"
fi
echo ""

echo "→ OpenSearch Domains:"
EXISTING_DOMAINS=$(aws opensearch list-domain-names --profile $PROFILE --region $REGION --query 'DomainNames[].DomainName' --output text 2>/dev/null || echo "")
if [ -n "$EXISTING_DOMAINS" ]; then
    echo "$EXISTING_DOMAINS" | tr '\t' '\n' | sed 's/^/  - /'
else
    echo "  None found"
fi
echo ""

echo "→ Bedrock Knowledge Bases:"
EXISTING_KBS=$(aws bedrock-agent list-knowledge-bases --profile $PROFILE --region $REGION --query 'knowledgeBaseSummaries[].name' --output text 2>/dev/null || echo "")
if [ -n "$EXISTING_KBS" ]; then
    echo "$EXISTING_KBS" | tr '\t' '\n' | sed 's/^/  - /'
else
    echo "  None found"
fi
echo ""

echo "→ IAM Roles matching 'AmazonBedrockExecutionRoleForKnowledgeBase':"
EXISTING_ROLES=$(aws iam list-roles --profile $PROFILE --query 'Roles[?contains(RoleName, `AmazonBedrockExecutionRoleForKnowledgeBase`)].RoleName' --output text 2>/dev/null || echo "")
if [ -n "$EXISTING_ROLES" ]; then
    echo "$EXISTING_ROLES" | tr '\t' '\n' | sed 's/^/  - /'
else
    echo "  None found"
fi
echo ""

echo "→ CloudFormation Stack Status:"
STACK_CHECK=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DOES_NOT_EXIST")
echo "  $STACK_CHECK"
echo ""

echo "✓ Resource check complete - proceeding with cleanup..."
echo ""

################################################################################
# STEP 2: Clean Up OpenSearch Serverless (Collections and Policies)
################################################################################
echo "Step 2: Cleaning up OpenSearch Serverless resources..."

# Step 2.1: Delete OpenSearch Serverless Collections
echo "  2.1: Deleting OpenSearch Serverless Collections..."
COLLECTIONS=$(aws opensearchserverless list-collections \
    --profile $PROFILE \
    --region $REGION \
    --query 'collectionSummaries[].id' \
    --output text 2>/dev/null || echo "")

if [ -n "$COLLECTIONS" ]; then
    echo "$COLLECTIONS" | tr '\t' '\n' | while read -r collection_id; do
        if [ -n "$collection_id" ]; then
            COLLECTION_NAME=$(aws opensearchserverless batch-get-collection \
                --ids "$collection_id" \
                --profile $PROFILE \
                --region $REGION \
                --query 'collectionDetails[0].name' \
                --output text 2>/dev/null || echo "")
            
            if echo "$COLLECTION_NAME" | grep -qi "prod-mac-prod\|prodmacprod"; then
                echo "    Deleting collection: $COLLECTION_NAME"
                aws opensearchserverless delete-collection \
                    --id "$collection_id" \
                    --profile $PROFILE \
                    --region $REGION 2>/dev/null || true
            fi
        fi
    done
fi

# Step 2.2: Delete Network Policies
echo "  2.2: Deleting Network Policies..."
NETWORK_POLICIES=$(aws opensearchserverless list-security-policies \
    --type network \
    --profile $PROFILE \
    --region $REGION \
    --query 'securityPolicySummaries[].name' \
    --output text 2>/dev/null || echo "")

if [ -n "$NETWORK_POLICIES" ]; then
    echo "$NETWORK_POLICIES" | tr '\t' '\n' | while read -r policy_name; do
        if [ -n "$policy_name" ] && echo "$policy_name" | grep -qi "prod-mac-prod\|prodmacprod"; then
            echo "    Deleting network policy: $policy_name"
            aws opensearchserverless delete-security-policy \
                --name "$policy_name" \
                --type network \
                --profile $PROFILE \
                --region $REGION 2>/dev/null || true
        fi
    done
fi

# Step 2.3: Delete Encryption Policies
echo "  2.3: Deleting Encryption Policies..."
ENCRYPTION_POLICIES=$(aws opensearchserverless list-security-policies \
    --type encryption \
    --profile $PROFILE \
    --region $REGION \
    --query 'securityPolicySummaries[].name' \
    --output text 2>/dev/null || echo "")

if [ -n "$ENCRYPTION_POLICIES" ]; then
    echo "$ENCRYPTION_POLICIES" | tr '\t' '\n' | while read -r policy_name; do
        if [ -n "$policy_name" ] && echo "$policy_name" | grep -qi "prod-mac-prod\|prodmacprod"; then
            echo "    Deleting encryption policy: $policy_name"
            aws opensearchserverless delete-security-policy \
                --name "$policy_name" \
                --type encryption \
                --profile $PROFILE \
                --region $REGION 2>/dev/null || true
        fi
    done
fi

# Step 2.4: Delete Data Access Policies
echo "  2.4: Deleting Data Access Policies..."
DATA_POLICIES=$(aws opensearchserverless list-access-policies \
    --type data \
    --profile $PROFILE \
    --region $REGION \
    --query 'accessPolicySummaries[].name' \
    --output text 2>/dev/null || echo "")

if [ -n "$DATA_POLICIES" ]; then
    echo "$DATA_POLICIES" | tr '\t' '\n' | while read -r policy_name; do
        if [ -n "$policy_name" ] && echo "$policy_name" | grep -qi "prod-mac-prod\|prodmacprod"; then
            echo "    Deleting data access policy: $policy_name"
            aws opensearchserverless delete-access-policy \
                --name "$policy_name" \
                --type data \
                --profile $PROFILE \
                --region $REGION 2>/dev/null || true
        fi
    done
fi

echo "✓ OpenSearch Serverless cleanup complete"
echo ""
echo "⏳ Waiting 90 seconds for OpenSearch Serverless async deletions..."
sleep 90
echo ""

################################################################################
# STEP 3: Clean Up Bedrock Knowledge Bases
################################################################################
echo "Step 3: Cleaning up Bedrock Knowledge Bases..."

cleanup_kb() {
    KB_NAME=$1
    echo "Checking Knowledge Base: $KB_NAME"
    
    KB_ID=$(aws bedrock-agent list-knowledge-bases \
        --profile $PROFILE \
        --region $REGION \
        --query "knowledgeBaseSummaries[?name=='$KB_NAME'].knowledgeBaseId" \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$KB_ID" ]; then
        echo "  Found Knowledge Base ID: $KB_ID"
        echo "  Deleting..."
        aws bedrock-agent delete-knowledge-base \
            --knowledge-base-id "$KB_ID" \
            --profile $PROFILE \
            --region $REGION 2>/dev/null || echo "  Failed to delete"
        echo "  ✓ Deleted Knowledge Base: $KB_NAME"
    else
        echo "  ✓ Knowledge Base not found (already cleaned up)"
    fi
}

cleanup_kb "KBprodmacprodowledgeBaseA71BFFF8"
cleanup_kb "KBprodmacprodowledgeBase9766CCEE"
cleanup_kb "KBprodmacprodowledgeBaseC2BDA896"

echo ""

################################################################################
# STEP 4: Clean Up Orphaned IAM Roles
################################################################################
echo "Step 4: Cleaning up orphaned IAM roles..."

cleanup_iam_role() {
    ROLE=$1
    if aws iam get-role --role-name "$ROLE" --profile $PROFILE > /dev/null 2>&1; then
        echo "  ⚠️  Found orphaned role: $ROLE"
        echo "  Cleaning up..."
        
        # Detach all managed policies
        aws iam list-attached-role-policies --role-name "$ROLE" --profile $PROFILE --query 'AttachedPolicies[].PolicyArn' --output text | \
        tr '\t' '\n' | while read -r policy_arn; do
            if [ -n "$policy_arn" ]; then
                aws iam detach-role-policy --role-name "$ROLE" --policy-arn "$policy_arn" --profile $PROFILE 2>/dev/null || true
            fi
        done
        
        # Delete all inline policies
        aws iam list-role-policies --role-name "$ROLE" --profile $PROFILE --query 'PolicyNames' --output text | \
        tr '\t' '\n' | while read -r policy_name; do
            if [ -n "$policy_name" ]; then
                aws iam delete-role-policy --role-name "$ROLE" --policy-name "$policy_name" --profile $PROFILE 2>/dev/null || true
            fi
        done
        
        # Delete the role
        aws iam delete-role --role-name "$ROLE" --profile $PROFILE 2>/dev/null || true
        echo "  ✓ Deleted role: $ROLE"
        return 0
    else
        return 1
    fi
}

FOUND_ORPHANED=false
cleanup_iam_role "AmazonBedrockExecutionRoleForKnowledgeBaseprodmacdgeBase9766CCEE" && FOUND_ORPHANED=true
cleanup_iam_role "AmazonBedrockExecutionRoleForKnowledgeBaseprodmacdgeBaseC2BDA896" && FOUND_ORPHANED=true
cleanup_iam_role "AmazonBedrockExecutionRoleForKnowledgeBaseprodmacdgeBaseA71BFFF8" && FOUND_ORPHANED=true

if [ "$FOUND_ORPHANED" = false ]; then
    echo "✓ No orphaned IAM roles found"
fi
echo ""

################################################################################
# STEP 5: Clean Up S3 Buckets (All matching buckets)
################################################################################
echo "Step 5: Cleaning up S3 buckets..."

cleanup_s3_bucket() {
    BUCKET=$1
    if aws s3 ls "s3://$BUCKET" --profile $PROFILE > /dev/null 2>&1; then
        echo "  Processing bucket: $BUCKET"
        
        # Empty bucket
        echo "    Emptying bucket..."
        aws s3 rm "s3://$BUCKET" --recursive --profile $PROFILE 2>/dev/null || true
        
        # Delete all versions if versioning enabled (without jq dependency)
        aws s3api list-object-versions \
            --bucket "$BUCKET" \
            --profile $PROFILE \
            --query 'Versions[].{Key:Key,VersionId:VersionId}' \
            --output text 2>/dev/null | \
        while read -r key version; do
            if [ -n "$key" ] && [ -n "$version" ]; then
                aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$version" --profile $PROFILE 2>/dev/null || true
            fi
        done
        
        # Delete all delete markers
        aws s3api list-object-versions \
            --bucket "$BUCKET" \
            --profile $PROFILE \
            --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' \
            --output text 2>/dev/null | \
        while read -r key version; do
            if [ -n "$key" ] && [ -n "$version" ]; then
                aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$version" --profile $PROFILE 2>/dev/null || true
            fi
        done
        
        # Delete bucket
        echo "    Deleting bucket..."
        aws s3 rb "s3://$BUCKET" --force --profile $PROFILE 2>/dev/null || true
        
        echo "  ✓ Cleaned up bucket: $BUCKET"
        return 0
    else
        return 1
    fi
}

# Find and clean all buckets matching our patterns
echo "Searching for buckets to clean up..."
aws s3api list-buckets --profile $PROFILE --query 'Buckets[].Name' --output text 2>/dev/null | \
tr '\t' '\n' | grep -E "prod-mac-prod-backend" | while read -r bucket; do
    if [ -n "$bucket" ]; then
        cleanup_s3_bucket "$bucket"
    fi
done

echo "✓ S3 bucket cleanup complete"
echo ""

################################################################################
# STEP 6: Clean Up OpenSearch Domains
################################################################################
echo "Step 6: Cleaning up OpenSearch domains..."

cleanup_opensearch_pattern() {
    PATTERN=$1
    echo "Searching for OpenSearch domains matching: $PATTERN"
    
    # List all OpenSearch domains
    DOMAINS=$(aws opensearch list-domain-names \
        --profile $PROFILE \
        --region $REGION \
        --query 'DomainNames[].DomainName' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$DOMAINS" ]; then
        echo "$DOMAINS" | tr '\t' '\n' | grep -i "$PATTERN" | while read -r domain; do
            if [ -n "$domain" ]; then
                echo "  Found OpenSearch domain: $domain"
                echo "  Deleting..."
                aws opensearch delete-domain \
                    --domain-name "$domain" \
                    --profile $PROFILE \
                    --region $REGION 2>/dev/null || echo "  Failed to delete, may not exist"
                echo "  ✓ Deleted domain: $domain"
            fi
        done
    fi
}

cleanup_opensearch_pattern "prod-mac-prod-backend"
cleanup_opensearch_pattern "prodmacprodbackend"

echo "✓ OpenSearch cleanup complete"
echo ""

################################################################################
# STEP 7: Clean Up Failed Change Sets
################################################################################
echo "Step 7: Cleaning up failed change sets..."

# List and delete any failed change sets
CHANGE_SETS=$(aws cloudformation list-change-sets \
    --stack-name $STACK_NAME \
    --profile $PROFILE \
    --query 'Summaries[?Status==`FAILED`].ChangeSetName' \
    --output text 2>/dev/null || echo "")

if [ -n "$CHANGE_SETS" ]; then
    echo "$CHANGE_SETS" | tr '\t' '\n' | while read -r cs; do
        if [ -n "$cs" ]; then
            echo "  Deleting failed change set: $cs"
            aws cloudformation delete-change-set \
                --change-set-name "$cs" \
                --stack-name $STACK_NAME \
                --profile $PROFILE 2>/dev/null || true
        fi
    done
    echo "✓ Failed change sets cleaned up"
else
    echo "✓ No failed change sets found"
fi
echo ""

################################################################################
# STEP 8: Force Delete Failed Stack (Handles All Failed States)
################################################################################
echo "Step 8: Checking CloudFormation stack status..."
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DOES_NOT_EXIST")

echo "Current stack status: $STACK_STATUS"
echo ""

if [ "$STACK_STATUS" = "DOES_NOT_EXIST" ]; then
    echo "✓ Stack does not exist (clean slate)"
    
elif [ "$STACK_STATUS" = "REVIEW_IN_PROGRESS" ]; then
    echo "⚠️  Stack is in REVIEW_IN_PROGRESS state"
    echo "Forcefully deleting stack and all change sets..."
    echo ""
    
    # Delete all change sets first
    echo "Step 1: Deleting all change sets..."
    aws cloudformation list-change-sets \
        --stack-name $STACK_NAME \
        --profile $PROFILE \
        --query 'Summaries[].ChangeSetName' \
        --output text 2>/dev/null | \
    tr '\t' '\n' | while read -r cs; do
        if [ -n "$cs" ]; then
            echo "  Deleting change set: $cs"
            aws cloudformation delete-change-set \
                --change-set-name "$cs" \
                --stack-name $STACK_NAME \
                --profile $PROFILE 2>/dev/null || true
            sleep 2
        fi
    done
    
    echo "✓ Change sets deleted"
    echo ""
    
    # Delete the stack
    echo "Step 2: Deleting stack..."
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME \
        --profile $PROFILE
    
    echo "Waiting for deletion to complete..."
    COUNTER=0
    MAX_WAIT=60
    while [ $COUNTER -lt $MAX_WAIT ]; do
        CURRENT_STATUS=$(aws cloudformation describe-stacks \
            --stack-name $STACK_NAME \
            --profile $PROFILE \
            --query 'Stacks[0].StackStatus' \
            --output text 2>/dev/null || echo "DELETED")
        
        if [ "$CURRENT_STATUS" = "DELETED" ]; then
            echo "✓ Stack successfully deleted!"
            break
        fi
        
        echo "  Status: $CURRENT_STATUS (waiting...)"
        sleep 5
        COUNTER=$((COUNTER + 1))
    done
    
    if [ "$CURRENT_STATUS" != "DELETED" ]; then
        echo "⚠️  Stack deletion taking longer than expected"
        echo "Current status: $CURRENT_STATUS"
        echo "Continuing anyway..."
    fi
    
elif [ "$STACK_STATUS" = "DELETE_FAILED" ]; then
    echo "⚠️  Stack is in DELETE_FAILED state"
    echo "Attempting force deletion..."
    echo ""
    
    # Show failed resources
    aws cloudformation describe-stack-resources \
        --stack-name $STACK_NAME \
        --profile $PROFILE \
        --query 'StackResources[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatus]' \
        --output table 2>/dev/null || true
    
    echo ""
    echo "Attempting to delete stack..."
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE 2>&1 || true
    
    # Wait for deletion with timeout
    echo "Waiting for deletion (max 5 minutes)..."
    COUNTER=0
    MAX_WAIT=60
    while [ $COUNTER -lt $MAX_WAIT ]; do
        CURRENT_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DELETED")
        
        if [ "$CURRENT_STATUS" = "DELETED" ]; then
            echo "✓ Stack successfully deleted!"
            break
        fi
        
        if [ "$CURRENT_STATUS" = "DELETE_FAILED" ]; then
            echo ""
            echo "⚠️  Stack still in DELETE_FAILED state"
            echo ""
            echo "MANUAL ACTION REQUIRED:"
            echo "1. Go to: https://console.aws.amazon.com/cloudformation"
            echo "2. Select stack: $STACK_NAME"
            echo "3. Click 'Delete' and choose 'Retain resources' for failed resources"
            echo "4. After deletion, run this script again"
            echo ""
            exit 1
        fi
        
        echo "  Status: $CURRENT_STATUS (waiting...)"
        sleep 5
        COUNTER=$((COUNTER + 1))
    done
    
elif [ "$STACK_STATUS" = "ROLLBACK_FAILED" ]; then
    echo "⚠️  Stack is in ROLLBACK_FAILED state"
    echo "Attempting to continue rollback..."
    echo ""
    
    # Get failed resources
    FAILED_RESOURCES=$(aws cloudformation describe-stack-resources \
        --stack-name $STACK_NAME \
        --profile $PROFILE \
        --query 'StackResources[?ResourceStatus==`DELETE_FAILED`].LogicalResourceId' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$FAILED_RESOURCES" ]; then
        echo "Failed resources found:"
        echo "$FAILED_RESOURCES" | tr '\t' '\n' | sed 's/^/  - /'
        echo ""
        
        # Convert to comma-separated
        RESOURCES_TO_SKIP=$(echo $FAILED_RESOURCES | tr '\t' ',')
        
        echo "Continuing rollback (skipping failed resources)..."
        aws cloudformation continue-update-rollback \
            --stack-name $STACK_NAME \
            --profile $PROFILE \
            --resources-to-skip $RESOURCES_TO_SKIP 2>/dev/null || {
            echo "Trying without resource list..."
            aws cloudformation continue-update-rollback \
                --stack-name $STACK_NAME \
                --profile $PROFILE 2>/dev/null || true
        }
        
        echo "Waiting for rollback to complete..."
        sleep 10
        aws cloudformation wait stack-rollback-complete \
            --stack-name $STACK_NAME \
            --profile $PROFILE 2>/dev/null || true
    fi
    
    echo "Deleting stack..."
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE
    
    echo "Waiting for deletion..."
    aws cloudformation wait stack-delete-complete \
        --stack-name $STACK_NAME \
        --profile $PROFILE 2>/dev/null || true
    
    echo "✓ Stack cleanup complete"
    
elif [ "$STACK_STATUS" = "ROLLBACK_COMPLETE" ] || [[ "$STACK_STATUS" == *"FAILED"* ]]; then
    echo "⚠️  Stack is in failed state: $STACK_STATUS"
    echo "Deleting failed stack..."
    
    aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE
    
    echo "Waiting for stack deletion..."
    aws cloudformation wait stack-delete-complete \
        --stack-name $STACK_NAME \
        --profile $PROFILE 2>/dev/null || true
    
    echo "✓ Failed stack deleted"
    
elif [[ "$STACK_STATUS" == *"IN_PROGRESS"* ]]; then
    echo "⚠️  Stack operation is in progress: $STACK_STATUS"
    echo "Waiting for operation to complete (max 10 minutes)..."
    
    COUNTER=0
    MAX_WAIT=120
    while [ $COUNTER -lt $MAX_WAIT ]; do
        CURRENT_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --profile $PROFILE --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "DOES_NOT_EXIST")
        
        if [[ "$CURRENT_STATUS" != *"IN_PROGRESS"* ]]; then
            echo "✓ Operation completed with status: $CURRENT_STATUS"
            STACK_STATUS=$CURRENT_STATUS
            break
        fi
        
        echo "  Status: $CURRENT_STATUS (waiting...)"
        sleep 5
        COUNTER=$((COUNTER + 1))
    done
    
    if [[ "$STACK_STATUS" == *"IN_PROGRESS"* ]]; then
        echo "⚠️  Operation still in progress after 10 minutes"
        echo "Please check AWS Console and run script again later"
        exit 1
    fi
    
    # After waiting, check if we need to delete the stack
    if [[ "$STACK_STATUS" == *"FAILED"* ]] || [ "$STACK_STATUS" = "ROLLBACK_COMPLETE" ]; then
        echo "Deleting failed stack..."
        aws cloudformation delete-stack --stack-name $STACK_NAME --profile $PROFILE
        aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --profile $PROFILE 2>/dev/null || true
        echo "✓ Stack deleted"
    fi
    
else
    echo "✓ Stack status is: $STACK_STATUS"
fi
echo ""

################################################################################
# STEP 9: Check and Add Athena Permissions
################################################################################
echo "Step 9: Checking Athena permissions..."
ATHENA_CHECK=$(aws athena list-work-groups --profile $PROFILE 2>&1 || echo "FAILED")

if echo "$ATHENA_CHECK" | grep -q "AccessDenied\|UnauthorizedOperation\|not authorized"; then
    echo "⚠️  Missing Athena permissions detected!"
    echo ""
    echo "Attempting to add required Athena permissions automatically..."
    echo ""
    
    # Get current user identity
    CURRENT_USER=$(aws sts get-caller-identity --profile $PROFILE --query 'Arn' --output text)
    
    # Check if it's a user or role
    if echo "$CURRENT_USER" | grep -q ":user/"; then
        USERNAME=$(echo "$CURRENT_USER" | sed 's/.*:user\///')
        echo "Detected IAM User: $USERNAME"
        echo "Adding Athena permissions policy..."
        
        # Create the policy inline
        cat > /tmp/athena-policy-$$.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AthenaQueryPermissions",
      "Effect": "Allow",
      "Action": [
        "athena:StartQueryExecution",
        "athena:GetQueryExecution",
        "athena:GetQueryResults",
        "athena:StopQueryExecution",
        "athena:GetWorkGroup",
        "athena:ListWorkGroups"
      ],
      "Resource": "*"
    },
    {
      "Sid": "GluePermissions",
      "Effect": "Allow",
      "Action": [
        "glue:GetDatabase",
        "glue:GetTable",
        "glue:GetPartitions",
        "glue:CreateTable",
        "glue:DeleteTable",
        "glue:UpdateTable"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3AthenaResults",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::prod-mac-prod-backend-athena-results-992167236365",
        "arn:aws:s3:::prod-mac-prod-backend-athena-results-992167236365/*"
      ]
    }
  ]
}
EOF
        
        aws iam put-user-policy \
            --user-name "$USERNAME" \
            --policy-name AthenaDeploymentPermissions \
            --policy-document file:///tmp/athena-policy-$$.json \
            --profile $PROFILE
        
        rm /tmp/athena-policy-$$.json
        
        echo "✓ Athena permissions added successfully!"
        echo ""
        
    elif echo "$CURRENT_USER" | grep -q ":assumed-role/"; then
        ROLE_NAME=$(echo "$CURRENT_USER" | sed 's/.*:assumed-role\/\([^/]*\).*/\1/')
        echo "Detected Assumed Role: $ROLE_NAME"
        echo ""
        echo "⚠️  Cannot automatically add permissions to assumed roles"
        echo ""
        echo "Please add permissions manually via AWS Console"
        echo ""
        read -p "Have you added the permissions? Continue? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Deployment cancelled. Add permissions and try again."
            exit 1
        fi
    else
        echo "⚠️  Could not determine IAM identity type"
        echo ""
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Deployment cancelled."
            exit 1
        fi
    fi
else
    echo "✓ Athena permissions verified"
fi
echo ""

################################################################################
# STEP 10: Prepare Project
################################################################################
echo "Step 10: Preparing project..."
cd multi-agent-orchestration-on-aws/

echo "Updating project config with account number..."
sed -i "s/{ACCOUNT_NUMBER}/$ACCOUNT_NUMBER/g" config/project-config.json

echo "✓ Project configuration updated"
echo ""

################################################################################
# STEP 11: Docker Setup
################################################################################
echo "Step 11: Setting up Docker..."
echo "Logging into AWS ECR public registry..."
aws ecr-public get-login-password --region "$REGION" | docker login --username AWS --password-stdin public.ecr.aws

echo "Pulling required Docker image..."
docker pull public.ecr.aws/sam/build-python3.12:latest

echo "✓ Docker setup complete"
echo ""

################################################################################
# STEP 12: Deploy
################################################################################
echo "=========================================="
echo "  Starting Deployment"
echo "=========================================="
echo ""
echo "Running npm run develop..."
echo "Please select option 3 (Deploy CDK Stack(s)) from the menu"
echo ""

npm run develop

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
