# Variables
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "ec2-demo-key"
}

# app1_url = "http://54.242.21.61/app1/"
# application_url = "http://54.242.21.61"
# instance_public_dns = "ec2-54-242-21-61.compute-1.amazonaws.com"
# instance_public_ip = "54.242.21.61"
# ssh -i ec2-demo-key.pem ubuntu@54.242.21.61
