#!/usr/bin/env bash

REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

# Check if REPO and TOKEN are set
if [[ -z "$REPO" || -z "$TOKEN" ]]; then
    echo "FATAL: env vars REPO and TOKEN must be set for registering a runner. Exiting..."
    exit 1
fi

echo "REPOSITORY: ${REPOSITORY}"
echo "ACCESS_TOKEN: (partially redacted): ${ACCESS_TOKEN: -6}"

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/"${REPOSITORY}"/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner || exit

./config.sh --url https://github.com/"${REPOSITORY}" --token "${REG_TOKEN}"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!