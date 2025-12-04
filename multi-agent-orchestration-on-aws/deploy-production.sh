#!/bin/bash

################################################################################
# Multi-Agent Orchestration - Complete Production Deployment Script
# 
# This script handles:
# 1. Knowledge base directory setup with placeholder files
# 2. TypeScript compilation with fixes
# 3. CDK bootstrap (if needed)
# 4. Full deployment to AWS
#
# Usage: ./deploy-production.sh
################################################################################

set -e  # Exit on any error

# Configuration
ACCOUNT="992167236365"
REGION="us-east-1"
PROFILE="mac-prod-prod"
STAGE="prod"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

################################################################################
# Main Script
################################################################################

echo ""
echo "=========================================="
echo "  Multi-Agent Orchestration Deployment"
echo "  Account: $ACCOUNT"
echo "  Region: $REGION"
echo "  Stage: $STAGE"
echo "=========================================="
echo ""

# Navigate to project root
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws

################################################################################
# Step 1: Validate AWS Credentials
################################################################################
log_info "Step 1: Validating AWS credentials..."

if ! aws sts get-caller-identity --profile $PROFILE > /dev/null 2>&1; then
    log_error "AWS credentials are invalid or expired!"
    log_info "Please run: aws configure --profile $PROFILE"
    exit 1
fi

CALLER_IDENTITY=$(aws sts get-caller-identity --profile $PROFILE)
CURRENT_ACCOUNT=$(echo $CALLER_IDENTITY | grep -o '"Account": "[^"]*' | cut -d'"' -f4)

if [ "$CURRENT_ACCOUNT" != "$ACCOUNT" ]; then
    log_error "Wrong AWS account! Expected: $ACCOUNT, Got: $CURRENT_ACCOUNT"
    exit 1
fi

log_success "AWS credentials validated for account $ACCOUNT"
echo ""

################################################################################
# Step 2: Setup Knowledge Base Directories
################################################################################
log_info "Step 2: Setting up knowledge base directories..."

# Personalization Agent
mkdir -p src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base
cat > src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base/README.md << 'EOF'
# Personalization Knowledge Base

This directory contains knowledge base documents for the personalization agent.

Add your personalization-related documents here, such as:
- User preference guidelines
- Browsing history patterns
- Personalization best practices
- Customer segmentation data

The files in this directory will be automatically synced to the S3 bucket and ingested into the Bedrock knowledge base.
EOF

# Product Recommendation Agent
mkdir -p src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base
cat > src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base/README.md << 'EOF'
# Product Recommendation Knowledge Base

This directory contains knowledge base documents for the product recommendation agent.

Add your product recommendation-related documents here, such as:
- Product catalogs
- Product specifications
- Recommendation algorithms
- Customer purchase patterns
- Product categories and taxonomies

The files in this directory will be automatically synced to the S3 bucket and ingested into the Bedrock knowledge base.
EOF

# Troubleshoot Agent
mkdir -p src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts
cat > src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts/README.md << 'EOF'
# Troubleshoot Knowledge Base

This directory contains knowledge base documents for the troubleshoot agent.

Add your troubleshooting-related documents here, such as:
- FAQ documents
- Troubleshooting guides
- Common issues and solutions
- Product documentation
- Technical support articles

The files in this directory will be automatically synced to the S3 bucket and ingested into the Bedrock knowledge base.
EOF

log_success "Knowledge base directories created with placeholder files"
echo ""

################################################################################
# Step 3: Clean and Rebuild TypeScript
################################################################################
log_info "Step 3: Cleaning old build artifacts and recompiling TypeScript..."

cd src/backend

# Clean old compiled files
log_info "Removing old compiled files..."
find lib -name "*.js" -type f -delete 2>/dev/null || true
find lib -name "*.d.ts" -type f -delete 2>/dev/null || true
find lib -name "*.js.map" -type f -delete 2>/dev/null || true

# Rebuild TypeScript
log_info "Compiling TypeScript..."
npm run build

if [ $? -ne 0 ]; then
    log_error "TypeScript compilation failed!"
    exit 1
fi

log_success "TypeScript compiled successfully"
echo ""

################################################################################
# Step 4: Verify Fixes in Compiled Code
################################################################################
log_info "Step 4: Verifying conditional deployment fixes..."

ERRORS=0

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/personalization/index.js; then
    log_error "Personalization agent missing conditional deployment fix"
    ERRORS=$((ERRORS + 1))
else
    log_success "Personalization agent has conditional deployment fix"
fi

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/product_recommendation/index.js; then
    log_error "Product Recommendation agent missing conditional deployment fix"
    ERRORS=$((ERRORS + 1))
else
    log_success "Product Recommendation agent has conditional deployment fix"
fi

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/troubleshoot/index.js; then
    log_error "Troubleshoot agent missing conditional deployment fix"
    ERRORS=$((ERRORS + 1))
else
    log_success "Troubleshoot agent has conditional deployment fix"
fi

if [ $ERRORS -gt 0 ]; then
    log_error "$ERRORS agent(s) missing fixes!"
    exit 1
fi

echo ""

################################################################################
# Step 5: Test CDK Synth
################################################################################
log_info "Step 5: Testing CDK synthesis..."

npx aws-cdk@2.1029.2 synth --profile $PROFILE -c stage=$STAGE > /tmp/cdk-synth-test.log 2>&1

if [ $? -ne 0 ]; then
    log_error "CDK Synth failed!"
    echo ""
    cat /tmp/cdk-synth-test.log
    exit 1
fi

log_success "CDK synthesis successful"
echo ""

################################################################################
# Step 6: Check CDK Bootstrap Status
################################################################################
log_info "Step 6: Checking CDK bootstrap status..."

# Check if bootstrap bucket exists
if aws s3 ls s3://cdk-hnb659fds-assets-$ACCOUNT-$REGION --profile $PROFILE > /dev/null 2>&1; then
    log_success "CDK is already bootstrapped"
else
    log_warning "CDK is not bootstrapped. Bootstrapping now..."
    
    npx aws-cdk@2.1029.2 bootstrap aws://$ACCOUNT/$REGION --profile $PROFILE
    
    if [ $? -ne 0 ]; then
        log_error "CDK Bootstrap failed!"
        exit 1
    fi
    
    log_success "CDK Bootstrap completed"
fi

echo ""

################################################################################
# Step 7: Deploy to AWS
################################################################################
log_info "Step 7: Starting deployment to AWS..."
echo ""

cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws

log_info "Deployment will be interactive. You can select which stacks to deploy."
log_info "Running: npm run develop"
echo ""

npm run develop

################################################################################
# Completion
################################################################################
echo ""
echo "=========================================="
echo "  Deployment Script Completed"
echo "=========================================="
echo ""
log_info "If deployment was successful, your multi-agent orchestration system is now live!"
log_info "Remember to run add-user.sh to add users to the application."
echo ""
