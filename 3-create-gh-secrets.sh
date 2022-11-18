#!/bin/bash

set -e pipefail

if [ -z $githubmail ]; then
    echo "Could not find githubmail. Stopping!"
    exit 1
fi

if [ -z $githubpat ]; then
    echo "Could not find githubpat. Stopping!"
    exit 1
fi

if [ -z $githubtrigger ]; then
    echo "Could not find githubtrigger. Stopping!"
    exit 1
fi

echo "Found all properties. Checking secrets now."

tempdir=$(mktemp -d)

ssh-keygen -t ed25519 -C $githubmail -f $tempdir/gh-key -q -N ""
ssh-keyscan -t rsa github.com > $tempdir/known_hosts 2> /dev/null

if ( aws secretsmanager describe-secret --secret-id github-private-key --no-cli-pager > /dev/null 2> /dev/null); then
    aws secretsmanager put-secret-value --secret-id github-private-key --no-cli-pager --secret-binary fileb://$tempdir/gh-key > /dev/null
else
    aws secretsmanager create-secret --name github-private-key --no-cli-pager --secret-binary fileb://$tempdir/gh-key > /dev/null
fi

if ( aws secretsmanager describe-secret --secret-id github-public-key --no-cli-pager > /dev/null 2> /dev/null); then
    aws secretsmanager put-secret-value --secret-id github-public-key --no-cli-pager --secret-binary fileb://$tempdir/gh-key.pub > /dev/null
else
    aws secretsmanager create-secret --name github-public-key --no-cli-pager --secret-binary fileb://$tempdir/gh-key.pub > /dev/null
fi

if ( aws secretsmanager describe-secret --secret-id github-known-hosts --no-cli-pager > /dev/null 2> /dev/null); then
    aws secretsmanager put-secret-value --secret-id github-known-hosts --no-cli-pager --secret-binary fileb://$tempdir/known_hosts > /dev/null
else
    aws secretsmanager create-secret --name github-known-hosts --no-cli-pager --secret-binary fileb://$tempdir/known_hosts > /dev/null
fi

# Since this is a personal token. Wait until needed. 
# if ( aws secretsmanager describe-secret --secret-id github-pat --no-cli-pager > /dev/null 2> /dev/null); then
#     aws secretsmanager put-secret-value --secret-id github-pat --no-cli-pager --secret-string $githubpat > /dev/null
# else
#     aws secretsmanager create-secret --name github-pat --no-cli-pager --secret-string $githubpat > /dev/null
# fi

if ( aws secretsmanager describe-secret --secret-id github-trigger-secret --no-cli-pager > /dev/null 2> /dev/null); then
    aws secretsmanager put-secret-value --secret-id github-trigger-secret --no-cli-pager --secret-string $githubtrigger > /dev/null
else
    aws secretsmanager create-secret --name github-trigger-secret --no-cli-pager --secret-string $githubtrigger > /dev/null
fi

echo "Upload public key to github:"
cat $tempdir/gh-key.pub

rm -rf $tempdir