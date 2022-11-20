#!/bin/bash

kubectl delete -k ../renovate-tekton-argo-talk/k8s/argocd

kubectl delete -k ../renovate-tekton-argo-talk/k8s/traefik/

kubectl delete -k ../renovate-tekton-argo-talk/k8s/certmanager/

kubectl delete -k k8s/external-secrets-operator

kubectl delete -k k8s/external-dns

kubectl delete -k k8s/autoscaler
