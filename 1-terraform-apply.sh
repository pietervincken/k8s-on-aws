#!/bin/bash
set -e

if [ -z $AWS_PROFILE ]; then
    echo "Could not find AWS_PROFILE. Stopping!"
    exit 1
fi

cd terraform
terraform init -backend-config=config.s3.tfbackend -upgrade
terraform apply --auto-approve
terraform output -json > output.json
cd ..

echo "Update NS records!"