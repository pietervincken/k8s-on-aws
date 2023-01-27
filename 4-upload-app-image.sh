#!/bin/bash
set -e;

temp=$(mktemp -d)

ecr_repo_url=$(cat terraform/output.json| jq --raw-output '.ecr_repo_url.value' | sed 's|/.*||')
if [ -z $ecr_repo_url ]; then
    echo "Could not find ecr_repo_url. Stopping!"
    exit 1
fi

cd $temp

git clone https://github.com/pietervincken/renovate-talk-java-demo-app.git
cd renovate-talk-java-demo-app
latest_tag=$(git tag | sort -V | tail -1 | sed 's|v||') # remove v from tag name!
echo "Using tag $latest_tag"

docker build --build-arg=APP_VERSION=$latest_tag -t $ecr_repo_url/renovate-talk-java-demo-app:$latest_tag .
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ecr_repo_url

docker push $ecr_repo_url/renovate-talk-java-demo-app:$latest_tag