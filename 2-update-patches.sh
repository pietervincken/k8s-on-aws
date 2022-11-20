#!/bin/bash

## Set IAM role in external secrets patch
external_secrets_operator_iam_role=$(cat terraform/output.json| jq --raw-output '.external_secrets_operator_iam_role.value')
if [ -z $external_secrets_operator_iam_role ]; then
    echo "Could not find external_secrets_operator_iam_role. Stopping!"
    exit 1
fi
yq -i ".[0].value |= \"$external_secrets_operator_iam_role\"" k8s/external-secrets-operator/patches/sa-arn.yaml 

## Set IAM role in external dns patch
external_dns_operator_iam_role=$(cat terraform/output.json| jq --raw-output '.external_dns_operator_iam_role.value')
if [ -z $external_dns_operator_iam_role ]; then
    echo "Could not find external_dns_operator_iam_role. Stopping!"
    exit 1
fi
yq -i ".[0].value |= \"$external_dns_operator_iam_role\"" k8s/external-dns/patches/sa-arn.yaml 

## Set eks name on autoscaler patch
eks_name=$(cat terraform/output.json| jq --raw-output '.eks_name.value')
if [ -z $eks_name ]; then
    echo "Could not find eks_name. Stopping!"
    exit 1
fi
yq -i ".[0].value |= \"--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/$eks_name\"" k8s/autoscaler/patches/deployment-clusterid.yaml