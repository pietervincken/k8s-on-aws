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

aws eks update-kubeconfig --region $AWS_REGION --name $eks_name

kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
kubectl wait deployment -n external-secrets external-secrets-webhook --for condition=Available=True --timeout=120s
kubectl apply -k k8s/external-secrets-operator

kubectl apply -k k8s/external-dns

kubectl apply -k ../renovate-tekton-argo-talk/k8s/traefik/
kubectl apply -k ../renovate-tekton-argo-talk/k8s/traefik/

kubectl apply -k ../renovate-tekton-argo-talk/k8s/certmanager/
kubectl apply -k ../renovate-tekton-argo-talk/k8s/certmanager/

kubectl apply -k https://github.com/pietervincken/renovate-talk-java-demo-app-deploy.git//kustomize