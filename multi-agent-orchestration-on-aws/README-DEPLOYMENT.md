# Quick Deployment Guide

## ✨ Auto-Fix Enabled!

Good news! The `npm run develop` command now **automatically fixes** all issues. You can use it directly:

```bash
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws
npm run develop
```

Then select option 2 (Synthesize) or 3 (Deploy) - fixes are applied automatically!

## Alternative: Complete Fix Script

For first-time setup or if you want everything in one command:

```bash
cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws && chmod +x fix-and-deploy.sh && ./fix-and-deploy.sh
```

## What This Script Does

The `fix-and-deploy.sh` script automatically:

1. ✅ **Validates AWS credentials** - Ensures you're deploying to the correct account
2. ✅ **Creates knowledge base directories** - Adds placeholder files for all agents
3. ✅ **Rebuilds TypeScript** - Compiles with conditional deployment fixes
4. ✅ **Verifies fixes** - Confirms all agents have the proper logic
5. ✅ **Tests CDK synth** - Catches errors before deployment
6. ✅ **Bootstraps CDK** - Sets up AWS account if needed (one-time)
7. ✅ **Runs `npm run develop`** - Launches interactive deployment menu

## Issues Fixed

### 1. Empty Knowledge Base Directories
- **Problem:** CDK failed when knowledge-base folders were empty
- **Fix:** Added conditional deployment logic + placeholder files

### 2. Outdated Compiled Files
- **Problem:** Server had old JavaScript files without fixes
- **Fix:** Script deletes old files and recompiles TypeScript

### 3. Account Not Bootstrapped
- **Problem:** CDK couldn't deploy without bootstrap
- **Fix:** Script checks and bootstraps automatically

## After Running the Script

The script will launch the interactive deployment menu where you can:
- Select "Synthesize CDK Stacks" to verify
- Select "Deploy CDK Stack(s)" to deploy to production
- Choose which stacks to deploy

## Configuration

- **Account:** 992167236365
- **Region:** us-east-1
- **Profile:** mac-prod-prod
- **Stage:** prod

## Troubleshooting

If the script fails:

1. **Check AWS credentials:**
   ```bash
   aws sts get-caller-identity --profile mac-prod-prod
   ```

2. **View build logs:**
   ```bash
   cat /tmp/tsc-build.log
   cat /tmp/cdk-synth.log
   ```

3. **Run manually:**
   ```bash
   cd ~/multi-agent-orchestration-on-aws/multi-agent-orchestration-on-aws
   npm run develop
   ```

## Post-Deployment

After successful deployment:
1. Run `./add-user.sh` to add users
2. Access the application via the CloudFront URL
3. Monitor CloudWatch logs

---

**That's it!** One command fixes everything and deploys your multi-agent orchestration system.
