#!/bin/bash

################################################################################
# Delete Stack in REVIEW_IN_PROGRESS State
# This script forcefully deletes a stack stuck in review
################################################################################

PROFILE="mac-prod-prod"
STACK_NAME="prod-mac-prod-backend"

echo ""
echo "=========================================="
echo "  Force Delete REVIEW_IN_PROGRESS Stack"
echo "=========================================="
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
sleep 5

# Check status
COUNTER=0
MAX_WAIT=60
while [ $COUNTER -lt $MAX_WAIT ]; do
    STATUS=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --profile $PROFILE \
        --query 'Stacks[0].StackStatus' \
        --output text 2>/dev/null || echo "DELETED")
    
    if [ "$STATUS" = "DELETED" ]; then
        echo "✓ Stack successfully deleted!"
        break
    fi
    
    echo "  Status: $STATUS (waiting...)"
    sleep 5
    COUNTER=$((COUNTER + 1))
done

echo ""
echo "=========================================="
echo "  Done!"
echo "=========================================="
echo ""
echo "Now run: ./deploy.sh"
echo ""
