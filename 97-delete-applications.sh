#!/bin/bash

kubectl delete pipelineruns --all -A
kubectl delete pipelines --all -A
kubectl delete tasks --all -A

kubectl patch app traefik  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge -n argocd
kubectl delete app traefik -n argocd

apps=$(kubectl get application -n argocd -o name | xargs -I{} basename {})


for app in $apps
do
    kubectl patch app $app  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge -n argocd
    kubectl delete app $app -n argocd --wait=false
done

kubectl delete -k ../renovate-tekton-argo-talk/k8s/argocd