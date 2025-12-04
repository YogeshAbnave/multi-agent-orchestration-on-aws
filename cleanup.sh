#!/bin/bash

for bucket in $(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'prod-mac-prod')].Name" --output text 2>/dev/null); do
    if [ ! -z "$bucket" ]; then
        aws s3api delete-objects --bucket "$bucket" --delete "$(aws s3api list-object-versions --bucket "$bucket" --output json --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" >/dev/null 2>&1
        aws s3api delete-objects --bucket "$bucket" --delete "$(aws s3api list-object-versions --bucket "$bucket" --output json --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')" >/dev/null 2>&1
        aws s3api delete-bucket --bucket "$bucket" >/dev/null 2>&1
    fi
done

cd multi-agent-orchestration-on-aws/

rm -f ~/.cdk.json >/dev/null 2>&1
rm -rf ~/.cdk >/dev/null 2>&1

docker rm -f $(docker ps -aq) >/dev/null 2>&1
docker rmi -f $(docker images -q) >/dev/null 2>&1
docker system prune -a --volumes -f >/dev/null 2>&1

echo
echo "Cleanup Successful!"
