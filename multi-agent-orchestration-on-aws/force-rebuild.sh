#!/bin/bash

echo "=== FORCE REBUILD - Fixing Outdated JS Files ==="
echo ""

cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws/src/backend

echo "Step 1: Deleting ALL compiled JS and declaration files..."
find lib -name "*.js" -type f -exec rm -f {} \;
find lib -name "*.d.ts" -type f -exec rm -f {} \;
find lib -name "*.js.map" -type f -exec rm -f {} \;

echo "✅ All compiled files deleted"
echo ""

echo "Step 2: Verifying TypeScript source files have the fix..."
if grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/personalization/index.ts; then
    echo "✅ Personalization agent has the fix"
else
    echo "❌ Personalization agent missing the fix!"
    exit 1
fi

if grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/product_recommendation/index.ts; then
    echo "✅ Product recommendation agent has the fix"
else
    echo "❌ Product recommendation agent missing the fix!"
    exit 1
fi

echo ""
echo "Step 3: Recompiling TypeScript..."
npx tsc

if [ $? -ne 0 ]; then
    echo "❌ TypeScript compilation failed!"
    exit 1
fi

echo "✅ TypeScript compiled successfully"
echo ""

echo "Step 4: Verifying compiled JS files have the fix..."
if grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/personalization/index.js; then
    echo "✅ Personalization JS has the fix"
else
    echo "❌ Personalization JS still missing the fix!"
    exit 1
fi

if grep -q "hasKnowledgeBaseFiles" lib/stacks/backend/multi-agent/product_recommendation/index.js; then
    echo "✅ Product recommendation JS has the fix"
else
    echo "❌ Product recommendation JS still missing the fix!"
    exit 1
fi

echo ""
echo "Step 5: Testing CDK synth..."
npx aws-cdk@2.1029.2 synth --profile mac-prod-prod -c stage=prod > /tmp/cdk-synth-test.log 2>&1

if [ $? -ne 0 ]; then
    echo "❌ CDK Synth still failing!"
    echo "Error output:"
    cat /tmp/cdk-synth-test.log
    exit 1
fi

echo "✅ CDK Synth successful!"
echo ""
echo "=== SUCCESS! All fixes applied and verified ==="
echo "You can now run: cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws && npm run develop"
