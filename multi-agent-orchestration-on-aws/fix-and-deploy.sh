#!/bin/bash

set -e  # Exit on any error

echo "=== Complete Fix and Deploy Script ==="
echo ""

# Navigate to project root
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws

echo "Step 1: Pulling latest changes from git..."
git pull || echo "No git changes to pull"
echo ""

echo "Step 2: Creating knowledge-base directories with placeholder files..."
mkdir -p src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base
mkdir -p src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base

# Create placeholder files
echo "# Personalization Knowledge Base" > src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base/README.md
echo "# Product Recommendation Knowledge Base" > src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base/README.md

echo "✅ Knowledge base directories created"
echo ""

echo "Step 3: Cleaning old build artifacts..."
cd src/backend
find lib -name "*.js" -type f -delete
find lib -name "*.d.ts" -type f -delete
echo "✅ Old build artifacts removed"
echo ""

echo "Step 4: Rebuilding TypeScript..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ TypeScript build failed!"
    exit 1
fi

echo "✅ TypeScript built successfully"
echo ""

echo "Step 5: Testing CDK synth..."
npx aws-cdk@2.1029.2 synth --profile mac-prod-prod -c stage=prod > /dev/null

if [ $? -ne 0 ]; then
    echo "❌ CDK Synth failed!"
    echo "Running with full error output:"
    npx aws-cdk@2.1029.2 synth --profile mac-prod-prod -c stage=prod
    exit 1
fi

echo "✅ CDK Synth successful!"
echo ""

echo "=== All fixes applied successfully! ==="
echo "You can now run: npm run develop"
