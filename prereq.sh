#!/bin/bash

  sudo apt update && sudo apt upgrade -y
  sudo apt install unzip -y
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -o awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
  aws configure
  echo "AWS CLI installed & configured"

  sudo apt install git unzip jq python3.12-venv python3-pip -y
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
  sudo apt-get install -y nodejs
  sudo npm install -g aws-cdk
  sudo apt install -y docker.io
  sudo usermod -aG docker $USER
  sudo systemctl start docker
  sudo systemctl enable docker

  sudo apt install jq

  echo
  echo
  echo "Production environment setup completed"


  newgrp docker
