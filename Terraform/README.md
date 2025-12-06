# EC2 Infrastructure with Auto-Generated SSH Keys

This Terraform configuration automatically generates a new SSH key pair every time you create infrastructure.

## Features

- Automatically generates RSA 4096-bit SSH key pair
- Saves private key as `ec2-demo-key.pem`
- Saves public key as `ec2-demo-key.pub`
- Sets correct file permissions automatically
- Creates EC2 instance with Ubuntu 22.04 LTS
- Full VPC setup with public subnet and internet gateway

## Usage

### Quick Start (Using PowerShell Script)

The easiest way to deploy:

```powershell
# Deploy everything (init + apply)
.\deploy.ps1

# Or use specific actions
.\deploy.ps1 -Action init      # Initialize Terraform
.\deploy.ps1 -Action plan      # Plan changes
.\deploy.ps1 -Action apply     # Deploy infrastructure
.\deploy.ps1 -Action ssh       # Connect to instance
.\deploy.ps1 -Action output    # Show outputs
.\deploy.ps1 -Action destroy   # Destroy infrastructure
```

### Manual Steps

#### 1. Initialize Terraform

```bash
terraform init
```

#### 2. Plan Infrastructure

```bash
terraform plan
```

#### 3. Apply Configuration

```bash
terraform apply -auto-approve
```

This will:
- Generate a new 4096-bit RSA SSH key pair
- Create VPC, subnet, security group
- Launch EC2 instance with Ubuntu 22.04
- Save the private key to `ec2-demo-key.pem`
- Set correct file permissions automatically

#### 4. Save and Secure the Private Key

After apply, extract and secure the key:

```powershell
# Save the private key
terraform output -raw private_key_pem | Out-File -FilePath "ec2-demo-key.pem" -Encoding ASCII -Force

# Fix Windows permissions
icacls ec2-demo-key.pem /inheritance:r
icacls ec2-demo-key.pem /grant:r "$($env:USERNAME):F"
```

#### 5. Connect to EC2 Instance

Get the SSH command:

```bash
terraform output ssh_connection
```

Or connect directly:

```bash
ssh -i ec2-demo-key.pem ubuntu@<PUBLIC_IP>
```

#### 6. Destroy Infrastructure

```bash
terraform destroy -auto-approve
```

This will delete all AWS resources. The local key files will remain but can be safely deleted.

## Important Notes

- A new key pair is generated with each `terraform apply`
- Old keys are automatically replaced
- Private keys are marked as sensitive in outputs
- Keys are excluded from git via `.gitignore`
- Never commit `.pem` files to version control

## Outputs

- `instance_public_ip` - Public IP of EC2 instance
- `instance_public_dns` - Public DNS name
- `application_url` - HTTP URL to access the instance
- `ssh_connection` - Ready-to-use SSH command
- `private_key_pem` - Private key content (sensitive, use `terraform output -raw private_key_pem`)



cd "D:\CloudAge Projects\AWS use case project\multi-agent-orchestration-on-aws\multi-agent-orchestration-on-aws\multi-agent-orchestration-on-aws\Terraform"

# Remove all permissions
icacls ec2-demo-key.pem /inheritance:r

# Grant only your user read access
icacls ec2-demo-key.pem /grant:r "admin:(R)"

# Verify
icacls ec2-demo-key.pem

# Now connect
ssh -i ec2-demo-key.pem ubuntu@54.146.248.246
