# Terraform Deployment Script with Auto-Generated SSH Keys
# This script automates the deployment process

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'plan', 'apply', 'destroy', 'ssh', 'output')]
    [string]$Action = 'apply'
)

Write-Host "=== Terraform EC2 Deployment ===" -ForegroundColor Cyan
Write-Host ""

switch ($Action) {
    'init' {
        Write-Host "Initializing Terraform..." -ForegroundColor Yellow
        terraform init -upgrade
    }
    'plan' {
        Write-Host "Planning infrastructure changes..." -ForegroundColor Yellow
        terraform plan
    }
    'apply' {
        Write-Host "Applying infrastructure changes..." -ForegroundColor Yellow
        terraform apply -auto-approve
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "=== Deployment Successful! ===" -ForegroundColor Green
            Write-Host ""
            
            # Extract and save private key
            Write-Host "Saving SSH private key..." -ForegroundColor Yellow
            terraform output -raw private_key_pem | Out-File -FilePath "ec2-demo-key.pem" -Encoding ASCII -Force
            
            # Fix permissions
            Write-Host "Setting correct permissions..." -ForegroundColor Yellow
            icacls ec2-demo-key.pem /inheritance:r | Out-Null
            icacls ec2-demo-key.pem /grant:r "$($env:USERNAME):F" | Out-Null
            
            Write-Host ""
            Write-Host "=== Connection Information ===" -ForegroundColor Cyan
            $ip = terraform output -raw instance_public_ip
            $ssh_cmd = "ssh -i ec2-demo-key.pem ubuntu@$ip"
            
            Write-Host "Public IP: $ip" -ForegroundColor White
            Write-Host "SSH Command: $ssh_cmd" -ForegroundColor White
            Write-Host ""
            Write-Host "Application URL: http://$ip" -ForegroundColor White
            Write-Host "App1 URL: http://$ip/app1/" -ForegroundColor White
        }
    }
    'destroy' {
        Write-Host "Destroying infrastructure..." -ForegroundColor Red
        terraform destroy -auto-approve
    }
    'ssh' {
        $ip = terraform output -raw instance_public_ip
        Write-Host "Connecting to EC2 instance..." -ForegroundColor Yellow
        ssh -i ec2-demo-key.pem ubuntu@$ip
    }
    'output' {
        Write-Host "Terraform Outputs:" -ForegroundColor Yellow
        terraform output
    }
}
