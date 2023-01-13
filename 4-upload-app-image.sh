#!/bin/bash
set -e;

temp=$(mktemp -d)

cd $temp

git clone https://github.com/pietervincken/renovate-talk-java-demo-app.git
cd renovate-talk-java-demo-app
latest_tag=$(git tag | sort -V | tail -1 | sed 's|v||') # remove v from tag name!
echo "Using tag $latest_tag"

docker build --build-arg=APP_VERSION=$latest_tag -t 930970667460.dkr.ecr.eu-west-1.amazonaws.com/renovate-talk-java-demo-app:$latest_tag .
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 930970667460.dkr.ecr.eu-west-1.amazonaws.com

docker push 930970667460.dkr.ecr.eu-west-1.amazonaws.com/renovate-talk-java-demo-app:$latest_tag