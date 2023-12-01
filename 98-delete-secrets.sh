#!/bin/bash

if [ -z $AWS_PROFILE ]; then
    echo "Could not find AWS_PROFILE. Stopping!"
    exit 1
fi

aws secretsmanager delete-secret --secret-id github-private-key     --no-cli-pager --recovery-window-in-days 7
aws secretsmanager delete-secret --secret-id github-public-key      --no-cli-pager --recovery-window-in-days 7
aws secretsmanager delete-secret --secret-id github-known-hosts     --no-cli-pager --recovery-window-in-days 7
aws secretsmanager delete-secret --secret-id github-trigger-secret  --no-cli-pager --recovery-window-in-days 7