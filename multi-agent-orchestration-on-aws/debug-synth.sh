#!/bin/bash

echo "=== Debugging CDK Synth Error ==="
echo ""

cd src/backend

echo "Step 1: Checking if TypeScript compiles..."
npx tsc --noEmit 2>&1 | tee /tmp/tsc-errors.log

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ TypeScript compilation errors found!"
    echo "Showing first 50 lines of errors:"
    head -50 /tmp/tsc-errors.log
    exit 1
fi

echo "✅ TypeScript compiles successfully"
echo ""

echo "Step 2: Running CDK synth with full error output..."
npx ts-node --prefer-ts-exts bin/prod.ts 2>&1 | tee /tmp/cdk-synth-errors.log

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ CDK Synth failed!"
    echo "Showing full error:"
    cat /tmp/cdk-synth-errors.log
    exit 1
fi

echo "✅ CDK Synth successful!"
