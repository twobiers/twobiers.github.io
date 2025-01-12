#!/bin/bash
set -euo pipefail

script_path=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)
if [ -z "${SUPERNOTES_API_KEY}" ]; then
    echo "Please set the SUPERNOTES_API_KEY environment variable."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Please install jq."
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Please install curl."
    exit 1
fi

response=$(curl --request GET \
    -s \
    --url https://api.supernotes.app/v1/cards/get/deleted \
    --header "Api-Key: $SUPERNOTES_API_KEY" \
    --header 'Content-Type: application/json')

# iterate over response array
for row in $(echo "$response" | jq -r '.[] | @base64'); do
    uuid=$(echo "$row" | base64 --decode)
    find "$script_path/../content/random" -type f -name "*_$uuid.md" -exec rm -f {} +
done
