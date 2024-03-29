#!/bin/bash

if [ -z $AWS_PROFILE ]; then
    echo "Could not find AWS_PROFILE. Stopping!"
    exit 1
fi

kubectl patch app traefik  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge -n argocd
kubectl delete app traefik -n argocd

kubectl patch app monitoring  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge -n argocd
kubectl delete app monitoring -n argocd

kubectl patch app dashboarding  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge -n argocd
kubectl delete app dashboarding -n argocd

apps=$(kubectl get application -n argocd -o name | xargs -I{} basename {})

for app in $apps
do
    kubectl patch app $app  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge -n argocd
    if [[ "$app" == "aws-ebs-csi-driver" ]]
    then
        echo "Skipping aws-ebs-csi-driver"
    else
        kubectl delete app $app -n argocd --wait=false
    fi
done

kubectl delete -k k8s/argocd