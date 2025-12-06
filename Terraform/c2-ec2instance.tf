# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "EC2 Demo VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "EC2 Demo IGW"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "EC2 Demo Public Subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "EC2 Demo Public RT"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "myec2_sg" {
  name        = "ec2-demo-sg"
  description = "Security group for EC2 demo instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom App Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 Demo SG"
  }
}

# Generate SSH Key Pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private Key to Local File using null_resource
resource "null_resource" "save_private_key" {
  triggers = {
    key_id = tls_private_key.ec2_key.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      $key = @"
${tls_private_key.ec2_key.private_key_pem}
"@
      $key | Out-File -FilePath "${var.key_name}.pem" -Encoding ASCII -Force -NoNewline
      icacls "${var.key_name}.pem" /inheritance:r
      icacls "${var.key_name}.pem" /grant:r "$($env:USERNAME):F"
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

# Save Public Key to Local File using null_resource
resource "null_resource" "save_public_key" {
  triggers = {
    key_id = tls_private_key.ec2_key.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      $key = @"
${tls_private_key.ec2_key.public_key_openssh}
"@
      $key | Out-File -FilePath "${var.key_name}.pub" -Encoding ASCII -Force -NoNewline
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

# Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Data source to get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Resource: EC2 Instance
resource "aws_instance" "myec2vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.myec2_sg.id]
  key_name                    = aws_key_pair.ec2_key.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/app1-install.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    "Name" = "EC2 Demo"
    "KeyFingerprint" = tls_private_key.ec2_key.id  # Force recreation when key changes
  }

  lifecycle {
    create_before_destroy = false
  }
}