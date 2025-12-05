#!/bin/bash

################################################################################
# Multi-Agent Orchestration - Complete Fix and Deploy Script
# 
# This script:
# 1. Fixes all knowledge base directory issues
# 2. Rebuilds TypeScript with conditional deployment logic
# 3. Bootstraps CDK if needed
# 4. Runs npm run develop for deployment
#
# Usage: ./fix-and-deploy.sh
################################################################################

set -e  # Exit on any error

# Configuration
ACCOUNT="992167236365"
REGION="us-east-1"
PROFILE="mac-prod-prod"
STAGE="prod"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo "=========================================="
echo "  Multi-Agent Orchestration"
echo "  Fix and Deploy Script"
echo "=========================================="
echo ""

# Navigate to project root
PROJECT_ROOT=~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws
cd $PROJECT_ROOT

################################################################################
# Step 1: Validate AWS Credentials
################################################################################
log_info "Step 1: Validating AWS credentials..."

if ! aws sts get-caller-identity --profile $PROFILE > /dev/null 2>&1; then
    log_error "AWS credentials invalid or expired!"
    log_info "Run: aws configure --profile $PROFILE"
    exit 1
fi

CURRENT_ACCOUNT=$(aws sts get-caller-identity --profile $PROFILE --query Account --output text)
if [ "$CURRENT_ACCOUNT" != "$ACCOUNT" ]; then
    log_error "Wrong AWS account! Expected: $ACCOUNT, Got: $CURRENT_ACCOUNT"
    exit 1
fi

log_success "AWS credentials validated (Account: $ACCOUNT)"
echo ""

################################################################################
# Step 2: Fix Knowledge Base Directories
################################################################################
log_info "Step 2: Creating knowledge base directories with placeholder files..."

# Personalization Agent
mkdir -p src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base
cat > src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base/README.md << 'EOF'
# Personalization Knowledge Base
Add personalization-related documents here.
EOF

# Product Recommendation Agent
mkdir -p src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base
cat > src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base/README.md << 'EOF'
# Product Recommendation Knowledge Base
Add product recommendation documents here.
EOF

# Troubleshoot Agent
mkdir -p src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts
cat > src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts/README.md << 'EOF'
# Troubleshoot Knowledge Base
Add troubleshooting documents here.
EOF

log_success "Knowledge base directories created"
echo ""

################################################################################
# Step 3: Rebuild TypeScript
################################################################################
log_info "Step 3: Cleaning and rebuilding TypeScript..."

cd src/backend

# Clean old files
log_info "Removing old compiled files..."
find lib -name "*.js" -type f -delete 2>/dev/null || true
find lib -name "*.d.ts" -type f -delete 2>/dev/null || true
find lib -name "*.js.map" -type f -delete 2>/dev/null || true

# Rebuild
log_info "Compiling TypeScript..."
if ! npm run build > /tmp/tsc-build.log 2>&1; then
    log_error "TypeScript compilation failed!"
    cat /tmp/tsc-build.log
    exit 1
fi

log_success "TypeScript compiled successfully"
echo ""

################################################################################
# Step 4: Verify Fixes
################################################################################
log_info "Step 4: Verifying conditional deployment fixes..."

ERRORS=0

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/personalization/index.js; then
    log_error "Personalization agent missing fix"
    ERRORS=$((ERRORS + 1))
else
    log_success "Personalization agent verified"
fi

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/product_recommendation/index.js; then
    log_error "Product Recommendation agent missing fix"
    ERRORS=$((ERRORS + 1))
else
    log_success "Product Recommendation agent verified"
fi

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/troubleshoot/index.js; then
    log_error "Troubleshoot agent missing fix"
    ERRORS=$((ERRORS + 1))
else
    log_success "Troubleshoot agent verified"
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

if ! npx aws-cdk@2.1029.2 synth --profile $PROFILE -c stage=$STAGE > /tmp/cdk-synth.log 2>&1; then
    log_error "CDK Synth failed!"
    cat /tmp/cdk-synth.log
    exit 1
fi

log_success "CDK synthesis successful"
echo ""

################################################################################
# Step 6: Bootstrap CDK (if needed)
################################################################################
log_info "Step 6: Checking CDK bootstrap status..."

if aws s3 ls s3://cdk-hnb659fds-assets-$ACCOUNT-$REGION --profile $PROFILE > /dev/null 2>&1; then
    log_success "CDK already bootstrapped"
else
    log_warning "CDK not bootstrapped. Bootstrapping now..."
    
    if ! npx aws-cdk@2.1029.2 bootstrap aws://$ACCOUNT/$REGION --profile $PROFILE; then
        log_error "CDK Bootstrap failed!"
        exit 1
    fi
    
    log_success "CDK Bootstrap completed"
fi

echo ""

################################################################################
# Step 7: Run npm run develop
################################################################################
log_info "Step 7: Starting deployment with npm run develop..."
echo ""
log_info "=========================================="
log_info "  All fixes applied successfully!"
log_info "  Launching interactive deployment..."
log_info "=========================================="
echo ""

cd $PROJECT_ROOT

# Run npm run develop
exec npm run develop
