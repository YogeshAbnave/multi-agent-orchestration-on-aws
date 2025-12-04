#!/bin/bash

echo "Creating User For Application"

id=$(aws cognito-idp list-user-pools --max-results 10 --query 'UserPools[?starts_with(Name, `authuserPool`)].Id' --output text)  > /dev/null 2>&1

aws cognito-idp admin-create-user --user-pool-id $id --username CloudAge --temporary-password CloudAge@123 --message-action SUPPRESS  > /dev/null 2>&1

aws cognito-idp admin-set-user-password --user-pool-id $id --username CloudAge --password CloudAge@123 --permanent > /dev/null 2>&1

echo

echo "User Created Successfully"
echo "Username: CloudAge"
echo "Password: CloudAge@123"

echo
