#!/bin/bash

eks_name=$(cat terraform/output.json| jq --raw-output '.eks_name.value')

if [ -z $eks_name ]; then
    echo "Could not find eks_name. Stopping!"
    exit 1
fi

if [ -z $AWS_REGION ]; then
    echo "Could not find AWS_REGION. Stopping!"
    exit 1
fi

if [ -z $AWS_PROFILE ]; then
    echo "Could not find AWS_PROFILE. Stopping!"
    exit 1
fi

aws eks update-kubeconfig --region $AWS_REGION --name $eks_name

kubectl apply -k k8s/autoscaler

kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
kubectl wait deployment -n external-secrets external-secrets-webhook --for condition=Available=True --timeout=120s
kubectl apply -k k8s/external-secrets-operator

kubectl apply -k ../renovate-tekton-argo-talk/k8s/argocd # first attempt will fail due to missing crds
kubectl apply -k ../renovate-tekton-argo-talk/k8s/argocd

kubectl apply -k k8s/argoapps
