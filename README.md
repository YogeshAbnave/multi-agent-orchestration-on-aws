# Multi-Agent Orchestration Deployment

## 🚀 One Command Deployment

```bash
chmod +x deploy.sh
./deploy.sh
```

That's it! Everything is automated in one script.

## ⏱️ What to Expect

- **Cleanup Phase**: 2-3 minutes (includes 90-second wait for async deletions)
- **Deployment Phase**: 10-15 minutes
- **Total Time**: ~15-20 minutes

## ✅ What deploy.sh Does

The script automatically handles everything:

1. **Validates AWS credentials**
2. **Cleans up OpenSearch Serverless** (collections, network policies, encryption policies, data access policies)
3. **Waits 90 seconds** for async OpenSearch Serverless deletions
4. **Cleans up Bedrock Knowledge Bases**
5. **Removes orphaned IAM roles**
6. **Cleans up S3 buckets**
7. **Deletes OpenSearch domains**
8. **Removes failed CloudFormation change sets**
9. **Force deletes stuck CloudFormation stacks** (DELETE_FAILED, ROLLBACK_FAILED, etc.)
10. **Adds Athena permissions** automatically (for IAM users)
11. **Prepares project configuration**
12. **Sets up Docker** (ECR login and image pull)
13. **Deploys the stack**

## 🔍 Current Issue Being Fixed

**AWS::EarlyValidation::ResourceExistenceCheck** - CloudFormation detected existing resources from previous failed deployments:

- OpenSearch Serverless Collections
- Security Policies (Network, Encryption, Data Access)
- Bedrock Knowledge Bases
- IAM Roles
- S3 Buckets

The script now cleans up ALL of these automatically.

## 📋 Requirements

- AWS CLI configured with profile `mac-prod-prod`
- Docker installed and running
- Node.js and npm installed
- AWS Account: `992167236365`
- Region: `us-east-1`

## 🛠️ Manual Cleanup (If Script Fails)

If automated cleanup doesn't work, use AWS Console:

1. **OpenSearch Serverless**:
   - Go to: https://console.aws.amazon.com/aos/home?region=us-east-1#opensearch/collections
   - Delete collections with "prod-mac-prod" in the name
   - Delete all associated security policies

2. **Bedrock Knowledge Bases**:
   - Go to Bedrock Console → Knowledge Bases
   - Delete any with "prodmacprod" in the name

3. **S3 Buckets**:
   - Delete buckets containing "prod-mac-prod-backend"

4. **Wait 2-3 minutes** for async deletions

5. **Run**: `./deploy.sh`

## 🎯 Verify Deployment Success

```bash
aws cloudformation describe-stacks \
  --stack-name prod-mac-prod-backend \
  --profile mac-prod-prod \
  --query 'Stacks[0].StackStatus'
```

Should return: `CREATE_COMPLETE`

## 💡 Why 90-Second Wait?

OpenSearch Serverless deletions are **asynchronous**. AWS needs time to:
- Remove collections from the control plane
- Delete associated indexes
- Clean up security policies
- Update resource registries

The 90-second wait ensures these deletions complete before CloudFormation tries to create new resources.

## 📁 Files

- `deploy.sh` - **All-in-one deployment script** (use this!)
- `README.md` - This file
- Other `.sh` files - Existing utility scripts (not related to this deployment)

## 🚨 Troubleshooting

### Still Getting ResourceExistenceCheck Error?

Wait an additional 2-3 minutes and run `./deploy.sh` again. Some resources may take longer to fully delete.

### Permission Issues?

The script automatically adds Athena permissions for IAM users. For assumed roles, you'll need to add them manually via AWS Console.

### Docker Issues?

Ensure Docker is running:
```bash
docker ps
```

Check AWS credentials:
```bash
aws sts get-caller-identity --profile mac-prod-prod
```
aws cloudformation describe-stacks --stack-name CDKToolkit --profile mac-prod-prod --region us-east-1


cd multi-agent-orchestration-on-aws/src/backend
npx cdk bootstrap aws://992167236365/us-east-1 --profile mac-prod-prod -c stage=prod


aws cloudformation describe-stack-events --stack-name prod-mac-prod-backend --profile mac-prod-prod --region us-east-1 --max-items 20


aws cloudformation delete-stack --stack-name prod-mac-prod-backend --profile mac-prod-prod --region us-east-1
# Wait for deletion, then redeploy
