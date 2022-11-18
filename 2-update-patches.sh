#!/bin/bash

external_secrets_operator_iam_role=$(cat terraform/output.json| jq --raw-output '.external_secrets_operator_iam_role.value')

if [ -z $external_secrets_operator_iam_role ]; then
    echo "Could not find external_secrets_operator_iam_role. Stopping!"
    exit 1
fi

yq -i ".[0].value |= \"$external_secrets_operator_iam_role\"" k8s/external-secrets-operator/patches/sa-arn.yaml 
