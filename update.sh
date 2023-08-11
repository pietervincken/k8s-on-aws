#!/bin/bash

set -e pipefail

tempdir=$(mktemp -d)

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases" |                 # Get latest release from GitHub api
  jq --raw-output 'map(select(.tag_name |  test("^v.*"))) | map(select(.prerelease | not)) | map(select(.tag_name | test(".*beta.*")|not)) | map(select(.tag_name | test(".*alpha.*")|not)) | map(select(.tag_name | test(".*rc.*")|not)) | first | .tag_name'  # get the tag from tag_name
}

# helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
# helm repo add traefik https://traefik.github.io/charts
# helm repo add external-secrets https://charts.external-secrets.io
# helm repo add grafana https://grafana.github.io/helm-charts
# helm repo add autoscaler https://kubernetes.github.io/autoscaler
# helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

cd k8s/external-secrets-operator
rm -rf resources/render/
mkdir -p resources/render
helm template external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --set installCRDs=true | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded external-secrets-operator"

cd k8s/external-dns/
externalDNSOperatorVersion=$(get_latest_release "kubernetes-sigs/external-dns")
git clone -q --depth=1 https://github.com/kubernetes-sigs/external-dns.git --branch $externalDNSOperatorVersion $tempdir/externaldns 2> /dev/null
rm -rf resources/render
mkdir -p resources/render
cp -R $tempdir/externaldns/kustomize/* resources/render
# Stupid workaround for properly doing this :facepalm:
kustomize edit set image k8s.gcr.io/external-dns/external-dns:$externalDNSOperatorVersion 
cd ../../
echo "Upgraded external-dns to $externalDNSOperatorVersion"

if [ -z $AWS_REGION ]; then
    echo "Could not find AWS_REGION. Stopping!"
    exit 1
fi

cd k8s/autoscaler/
rm -rf resources/render
mkdir -p resources/render
# curl -sL https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
helm template autoscaler autoscaler/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=test \
  --set awsRegion=$AWS_REGION | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded autoscaler"

cd k8s/aws-ebs-csi-driver/
rm -rf resources/render
mkdir -p resources/render
helm template aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver\
    --namespace kube-system \
    | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded aws-ebs-csi-driver"

# Cleanup
rm -rf $tempdir