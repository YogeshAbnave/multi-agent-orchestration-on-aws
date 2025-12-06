# Output: EC2 Instance Public IP
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.myec2vm.public_ip
}

# Output: EC2 Instance Public DNS
output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.myec2vm.public_dns
}

# Output: Application URL
output "application_url" {
  description = "URL to access the web application"
  value       = "http://${aws_instance.myec2vm.public_ip}"
}

# Output: App1 URL
output "app1_url" {
  description = "URL to access the app1 page"
  value       = "http://${aws_instance.myec2vm.public_ip}/app1/"
}

# Output: SSH Connection Command
output "ssh_connection" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.myec2vm.public_ip}"
}

# Output: Private Key (Sensitive)
output "private_key_pem" {
  description = "Private key for SSH access (save this securely)"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}
