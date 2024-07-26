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

## Set IAM role on autoscaler patch
cluster_autoscaler_iam_role=$(cat terraform/output.json| jq --raw-output '.cluster_autoscaler_iam_role.value')
if [ -z $cluster_autoscaler_iam_role ]; then
    echo "Could not find cluster_autoscaler_iam_role. Stopping!"
    exit 1
fi
yq -i ".[0].value |= \"$cluster_autoscaler_iam_role\"" k8s/autoscaler/patches/sa-arn.yaml 

## Set IAM role on certmanager patch
cert_manager_iam_role=$(cat terraform/output.json| jq --raw-output '.cert_manager_iam_role.value')
if [ -z $cert_manager_iam_role ]; then
    echo "Could not find cert_manager_iam_role. Stopping!"
    exit 1
fi
yq -i ".[0].value |= \"$cert_manager_iam_role\"" k8s/certmanager/patches/sa-arn.yaml 

# ## Set thanos bucket name
# thanos_bucket=$(cat terraform/output.json| jq --raw-output '.thanos_bucket.value' | sed 's|/.*||')
# if [ -z $thanos_bucket ]; then
#     echo "Could not find thanos_bucket. Stopping!"
#     exit 1
# fi
# yq -i ".config.bucket |= \"$thanos_bucket\"" "k8s/monitoring/configs/thanos.yaml"

# ## Set thanos iam role arn
# thanos_iam_role_arn=$(cat terraform/output.json| jq --raw-output '.thanos_iam_role_arn.value')
# if [ -z $thanos_iam_role_arn ]; then
#     echo "Could not find thanos_iam_role_arn. Stopping!"
#     exit 1
# fi
# yq -i ".[0].value |= \"$thanos_iam_role_arn\"" "k8s/monitoring/patches/thanos-sa-arn.yaml"