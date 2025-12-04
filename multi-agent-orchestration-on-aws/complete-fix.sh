#!/bin/bash

set -e

echo "=== COMPLETE FIX FOR ALL AGENTS ==="
echo ""

cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws

echo "Step 1: Ensuring all knowledge-base directories have placeholder files..."

# Personalization
mkdir -p src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base
echo "# Personalization Knowledge Base" > src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base/README.md

# Product Recommendation  
mkdir -p src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base
echo "# Product Recommendation Knowledge Base" > src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base/README.md

# Troubleshoot
mkdir -p src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts
echo "# Troubleshoot Knowledge Base" > src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts/README.md

echo "✅ All knowledge-base directories have placeholder files"
echo ""

echo "Step 2: Cleaning old compiled files..."
cd src/backend
find lib -name "*.js" -type f -delete 2>/dev/null || true
find lib -name "*.d.ts" -type f -delete 2>/dev/null || true
find lib -name "*.js.map" -type f -delete 2>/dev/null || true
echo "✅ Old compiled files removed"
echo ""

echo "Step 3: Recompiling TypeScript..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ TypeScript compilation failed!"
    exit 1
fi

echo "✅ TypeScript compiled successfully"
echo ""

echo "Step 4: Verifying fixes in compiled JS files..."
ERRORS=0

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/personalization/index.js; then
    echo "❌ Personalization JS missing fix"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Personalization JS has fix"
fi

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/product_recommendation/index.js; then
    echo "❌ Product Recommendation JS missing fix"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Product Recommendation JS has fix"
fi

if ! grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/troubleshoot/index.js; then
    echo "❌ Troubleshoot JS missing fix"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Troubleshoot JS has fix"
fi

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "❌ $ERRORS agent(s) missing fixes in compiled JS!"
    exit 1
fi

echo ""
echo "Step 5: Testing CDK synth..."
npx aws-cdk@2.1029.2 synth --profile mac-prod-prod -c stage=prod > /tmp/cdk-synth-output.log 2>&1

if [ $? -ne 0 ]; then
    echo "❌ CDK Synth failed!"
    echo ""
    echo "Error output:"
    cat /tmp/cdk-synth-output.log
    exit 1
fi

echo "✅ CDK Synth successful!"
echo ""
echo "=== ALL FIXES APPLIED SUCCESSFULLY ==="
echo ""
echo "You can now deploy with:"
echo "  cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws"
echo "  npm run develop"
