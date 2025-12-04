# Multi-Agent Orchestration - Production Deployment Guide

## Quick Start

Run this single command on your Ubuntu server to deploy everything:

```bash
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws
chmod +x deploy-production.sh
./deploy-production.sh
```

## What This Script Does

The `deploy-production.sh` script is a comprehensive deployment solution that handles:

### 1. **AWS Credentials Validation**
- Verifies your AWS credentials are valid
- Confirms you're deploying to the correct account (992167236365)

### 2. **Knowledge Base Setup**
- Creates knowledge-base directories for all agents:
  - Personalization Agent
  - Product Recommendation Agent
  - Troubleshoot Agent
- Adds placeholder README files so directories aren't empty

### 3. **Code Compilation**
- Cleans all old compiled JavaScript files
- Recompiles TypeScript with the latest fixes
- Includes conditional deployment logic to handle empty knowledge bases

### 4. **Verification**
- Verifies all agents have the conditional deployment fix
- Tests CDK synthesis to catch errors before deployment

### 5. **CDK Bootstrap**
- Checks if your AWS account is bootstrapped for CDK
- Automatically bootstraps if needed (creates S3 buckets and resources)

### 6. **Deployment**
- Launches the interactive deployment menu
- Allows you to select which stacks to deploy

## What Was Fixed

### Issue 1: Empty Knowledge Base Directories
**Problem:** CDK BucketDeployment failed when knowledge-base directories were empty.

**Solution:** 
- Added conditional deployment logic to all agents
- Only deploys knowledge base assets if files exist
- Created placeholder README files

### Issue 2: Outdated Compiled Files
**Problem:** JavaScript files on the server didn't have the latest fixes.

**Solution:**
- Script deletes all old `.js` files
- Forces complete TypeScript recompilation

### Issue 3: Account Not Bootstrapped
**Problem:** CDK couldn't deploy because the AWS account wasn't bootstrapped.

**Solution:**
- Script checks bootstrap status
- Automatically bootstraps if needed

## Manual Deployment Steps

If you prefer to run steps manually:

```bash
# 1. Navigate to project
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws

# 2. Validate credentials
aws sts get-caller-identity --profile mac-prod-prod

# 3. Create knowledge base directories (if needed)
mkdir -p src/backend/lib/stacks/backend/multi-agent/personalization/knowledge-base
mkdir -p src/backend/lib/stacks/backend/multi-agent/product_recommendation/knowledge-base
mkdir -p src/backend/lib/stacks/backend/multi-agent/troubleshoot/knowledge-base/ts

# 4. Rebuild TypeScript
cd src/backend
find lib -name "*.js" -delete
npm run build

# 5. Bootstrap CDK (if needed)
npx aws-cdk@2.1029.2 bootstrap aws://992167236365/us-east-1 --profile mac-prod-prod

# 6. Deploy
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws
npm run develop
```

## Configuration

The deployment uses these settings:
- **Account:** 992167236365
- **Region:** us-east-1
- **Profile:** mac-prod-prod
- **Stage:** prod

To change these, edit the variables at the top of `deploy-production.sh`.

## After Deployment

Once deployment is complete:

1. **Add Users:** Run `./add-user.sh` to add users to the application
2. **Access Frontend:** The deployment will output the CloudFront URL
3. **Monitor:** Check CloudWatch logs for agent activity

## Troubleshooting

### If deployment fails:

1. **Check AWS credentials:**
   ```bash
   aws sts get-caller-identity --profile mac-prod-prod
   ```

2. **Check CDK bootstrap:**
   ```bash
   aws s3 ls s3://cdk-hnb659fds-assets-992167236365-us-east-1 --profile mac-prod-prod
   ```

3. **View full error logs:**
   The script saves synth output to `/tmp/cdk-synth-test.log`

4. **Re-run with verbose output:**
   ```bash
   cd src/backend
   npx aws-cdk@2.1029.2 deploy --all --profile mac-prod-prod -c stage=prod --verbose
   ```

## Files Modified

The following files were modified to fix the deployment issues:

1. `src/backend/lib/stacks/backend/multi-agent/personalization/index.ts`
   - Added conditional deployment logic
   - Added filesystem checks

2. `src/backend/lib/stacks/backend/multi-agent/product_recommendation/index.ts`
   - Added conditional deployment logic
   - Added filesystem checks

3. `src/backend/lib/stacks/backend/multi-agent/troubleshoot/index.ts`
   - Added conditional deployment logic
   - Added filesystem checks

All changes ensure that BucketDeployment only occurs when knowledge-base directories contain files.

## Support

For issues or questions, refer to the project documentation or contact the CloudAge team.
