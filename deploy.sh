#!/bin/bash

echo "Building Cluster"
cd multi-agent-orchestration-on-aws/

ACCOUNT_NUMBER=992167236365
REGION=us-east-1

echo "Updating project config with account number..."
sed -i "s/{ACCOUNT_NUMBER}/$ACCOUNT_NUMBER/g" config/project-config.json

echo "Logging into AWS ECR public registry..."
aws ecr-public get-login-password --region "$REGION" | docker login --username AWS --password-stdin public.ecr.aws

echo "Pulling required Docker image..."
docker pull public.ecr.aws/sam/build-python3.12:latest

echo "Running development deployment..."
npm run develop

echo
