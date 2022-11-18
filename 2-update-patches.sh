#!/bin/bash

external_secrets_operator_iam_role=$(cat terraform/output.json| jq --raw-output '.external_secrets_operator_iam_role.value')

if [ -z $external_secrets_operator_iam_role ]; then
    echo "Could not find external_secrets_operator_iam_role. Stopping!"
    exit 1
fi

yq -i ".[0].value |= \"$external_secrets_operator_iam_role\"" k8s/external-secrets-operator/patches/sa-arn.yaml 

external_dns_operator_iam_role=$(cat terraform/output.json| jq --raw-output '.external_dns_operator_iam_role.value')

if [ -z $external_dns_operator_iam_role ]; then
    echo "Could not find external_dns_operator_iam_role. Stopping!"
    exit 1
fi

yq -i ".[0].value |= \"$external_dns_operator_iam_role\"" k8s/external-dns/patches/sa-arn.yaml 
