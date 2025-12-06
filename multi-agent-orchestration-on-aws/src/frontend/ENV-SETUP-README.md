# Environment Variables Setup Guide

This guide explains how to set up environment variables for local development of the Multi-Agent Orchestration frontend.

## Quick Start

### Option 1: Use Mock Values (UI Development Only)

The `.env` file already contains mock values. Just run:

```powershell
npm run dev
```

⚠️ **Note:** Authentication and API calls will not work with mock values. This is only for UI development.

### Option 2: Fetch Real Values from AWS (Recommended)

If you have already deployed the backend to AWS:

```powershell
# From project root
npm run develop

# Select: "Refresh Local Environment"
```

This will automatically:
- Fetch values from CloudFormation stack outputs
- Create/update the `.env` file
- Configure GraphQL codegen

### Option 3: Use PowerShell Setup Script

```powershell
cd src/frontend
.\setup-env.ps1
```

Follow the interactive prompts to:
1. Fetch from AWS
2. Enter values manually
3. Use mock values

### Option 4: Manual Setup

Copy `.env.local.example` to `.env` and fill in your values:

```powershell
cp .env.local.example .env
```

Then edit `.env` with your AWS values.

## Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_USER_POOL_ID` | Cognito User Pool ID | `us-east-1_XXXXXXXXX` |
| `VITE_USER_POOL_CLIENT_ID` | Cognito User Pool Client ID | `xxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `VITE_IDENTITY_POOL_ID` | Cognito Identity Pool ID | `us-east-1:xxxx-xxxx-xxxx-xxxx` |
| `VITE_GRAPH_API_URL` | AppSync GraphQL API URL | `https://xxxxx.appsync-api.us-east-1.amazonaws.com/graphql` |
| `VITE_GRAPH_API_KEY` | AppSync API Key (optional) | `da2-xxxxxxxxxxxxxxxxxx` |
| `VITE_STORAGE_BUCKET_NAME` | S3 Storage Bucket Name | `your-bucket-name` |
| `VITE_REGION` | AWS Region | `us-east-1` |

## Where to Find These Values

### From AWS Console

1. **Cognito Values:**
   - Go to AWS Cognito Console
   - Select your User Pool
   - Copy User Pool ID, Client ID, and Identity Pool ID

2. **AppSync Values:**
   - Go to AWS AppSync Console
   - Select your API
   - Copy the GraphQL endpoint URL
   - Go to Settings → API Keys to get the API key

3. **S3 Bucket:**
   - Go to AWS S3 Console
   - Find your storage bucket name

### From CloudFormation

1. Go to AWS CloudFormation Console
2. Find your stack (e.g., `prod-mac-prod-frontendDeployment`)
3. Click on "Outputs" tab
4. Look for outputs starting with `vite-`

### Using AWS CLI

```powershell
# Get stack outputs
aws cloudformation describe-stacks `
  --stack-name prod-mac-prod-frontendDeployment `
  --profile mac-prod-prod `
  --query "Stacks[0].Outputs"
```

## Environment File Structure

```env
# .env file structure
VITE_USER_POOL_ID=us-east-1_XXXXXXXXX
VITE_USER_POOL_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_IDENTITY_POOL_ID=us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
VITE_GRAPH_API_URL=https://xxxxxxxxxxxxxxxxxxxxxxxxxx.appsync-api.us-east-1.amazonaws.com/graphql
VITE_GRAPH_API_KEY=da2-xxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_STORAGE_BUCKET_NAME=your-storage-bucket-name
VITE_REGION=us-east-1
```

## Troubleshooting

### Environment Variables Not Loading

**Problem:** Changes to `.env` not reflected in the app

**Solution:**
1. Stop the dev server (Ctrl+C)
2. Restart: `npm run dev`
3. Vite only loads `.env` on startup

### Authentication Errors

**Problem:** "User pool does not exist" or similar errors

**Solution:**
1. Verify `VITE_USER_POOL_ID` is correct
2. Check AWS region matches your User Pool region
3. Ensure User Pool exists in AWS Console

### GraphQL API Errors

**Problem:** "Network error" or "API endpoint not found"

**Solution:**
1. Verify `VITE_GRAPH_API_URL` is correct
2. Check AppSync API exists and is deployed
3. Verify API Key is valid (if using API key auth)
4. Check CORS settings in AppSync

### Mock Values Not Working

**Problem:** App shows errors with mock values

**Solution:**
- This is expected! Mock values are for UI development only
- Authentication and API calls will fail
- Deploy backend to AWS and use real values for full functionality

## Security Notes

⚠️ **Important:**
- Never commit `.env` with real values to version control
- `.env` is already in `.gitignore`
- Use `.env.local.example` as a template
- Rotate API keys regularly
- Use IAM roles in production, not API keys

## Development Workflow

### For UI Development (No Backend)

```powershell
# Use mock values (already in .env)
npm run dev
```

### For Full Stack Development

```powershell
# 1. Deploy backend to AWS
npm run develop
# Select: Deploy CDK Stack(s)

# 2. Refresh local environment
npm run develop
# Select: Refresh Local Environment

# 3. Start frontend dev server
npm run dev
```

### For Testing with Real AWS Services

```powershell
# Ensure .env has real AWS values
npm run dev

# Test authentication
# Test API calls
# Test file uploads to S3
```

## Additional Resources

- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [AWS Amplify Configuration](https://docs.amplify.aws/javascript/tools/libraries/configure-categories/)
- [AWS Cognito User Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
- [AWS AppSync](https://docs.aws.amazon.com/appsync/latest/devguide/welcome.html)

## Support

If you encounter issues:
1. Check this README
2. Review `QUICK-START-LOCAL.md` in project root
3. Check AWS CloudFormation stack outputs
4. Verify AWS credentials are configured
5. Ensure backend is deployed to AWS

---

**Last Updated:** December 2024
