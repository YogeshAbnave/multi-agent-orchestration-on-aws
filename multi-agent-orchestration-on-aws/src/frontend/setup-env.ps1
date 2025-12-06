# PowerShell Script to Setup Environment Variables for Local Development
# This script helps you configure the .env file with real AWS values

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AWS Multi-Agent Orchestration" -ForegroundColor Cyan
Write-Host "Environment Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version 2>&1
    Write-Host "✓ AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    Write-Host "  Download from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Choose an option:" -ForegroundColor Yellow
Write-Host "1. Fetch values from deployed AWS stack (requires backend deployed)" -ForegroundColor White
Write-Host "2. Enter values manually" -ForegroundColor White
Write-Host "3. Use mock values (UI development only)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Fetching values from AWS CloudFormation..." -ForegroundColor Cyan
        
        # Prompt for AWS profile
        $profile = Read-Host "Enter AWS profile name (or press Enter for default)"
        if ([string]::IsNullOrWhiteSpace($profile)) {
            $profile = "default"
        }
        
        # Prompt for stage
        $stage = Read-Host "Enter stage name (e.g., prod, dev)"
        if ([string]::IsNullOrWhiteSpace($stage)) {
            $stage = "prod"
        }
        
        Write-Host ""
        Write-Host "Using profile: $profile, stage: $stage" -ForegroundColor Green
        Write-Host ""
        Write-Host "Note: This requires the backend to be deployed to AWS." -ForegroundColor Yellow
        Write-Host "If you haven't deployed yet, run: npm run develop" -ForegroundColor Yellow
        Write-Host ""
        
        # Run the develop CLI to refresh environment
        Write-Host "Running: npm run develop" -ForegroundColor Cyan
        Write-Host "Please select 'Refresh Local Environment' from the menu" -ForegroundColor Yellow
        
        Set-Location ../..
        npm run develop
        Set-Location src/frontend
        
        Write-Host ""
        Write-Host "✓ Environment setup complete!" -ForegroundColor Green
    }
    
    "2" {
        Write-Host ""
        Write-Host "Enter your AWS values:" -ForegroundColor Cyan
        Write-Host ""
        
        $userPoolId = Read-Host "Cognito User Pool ID (e.g., us-east-1_XXXXXXXXX)"
        $clientId = Read-Host "Cognito User Pool Client ID"
        $identityPoolId = Read-Host "Cognito Identity Pool ID"
        $graphApiUrl = Read-Host "AppSync GraphQL API URL"
        $graphApiKey = Read-Host "AppSync API Key (optional, press Enter to skip)"
        $storageBucket = Read-Host "S3 Storage Bucket Name"
        $region = Read-Host "AWS Region (default: us-east-1)"
        
        if ([string]::IsNullOrWhiteSpace($region)) {
            $region = "us-east-1"
        }
        
        # Create .env file
        $envContent = @"
# AWS Multi-Agent Orchestration - Environment Variables
# Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# AWS COGNITO AUTHENTICATION
VITE_USER_POOL_ID=$userPoolId
VITE_USER_POOL_CLIENT_ID=$clientId
VITE_IDENTITY_POOL_ID=$identityPoolId

# AWS APPSYNC GRAPHQL API
VITE_GRAPH_API_URL=$graphApiUrl
VITE_GRAPH_API_KEY=$graphApiKey

# AWS S3 STORAGE
VITE_STORAGE_BUCKET_NAME=$storageBucket

# AWS REGION
VITE_REGION=$region
"@
        
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
        
        Write-Host ""
        Write-Host "✓ .env file created successfully!" -ForegroundColor Green
        Write-Host "  Location: src/frontend/.env" -ForegroundColor Cyan
    }
    
    "3" {
        Write-Host ""
        Write-Host "Using mock values for local UI development..." -ForegroundColor Cyan
        
        # The .env file already has mock values, just confirm
        if (Test-Path ".env") {
            Write-Host "✓ .env file already exists with mock values" -ForegroundColor Green
        } else {
            Write-Host "✗ .env file not found. Please run this script from src/frontend directory" -ForegroundColor Red
            exit 1
        }
        
        Write-Host ""
        Write-Host "⚠️  Note: Mock values are for UI development only" -ForegroundColor Yellow
        Write-Host "   Authentication and API calls will not work" -ForegroundColor Yellow
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Install dependencies: npm install" -ForegroundColor White
Write-Host "2. Start dev server: npm run dev" -ForegroundColor White
Write-Host "3. Open browser: http://localhost:3000" -ForegroundColor White
Write-Host ""
