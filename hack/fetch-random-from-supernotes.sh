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

current_time=$(date -u --iso-8601=second | sed s/+00:00/Z/ | sed s/,/./)
yesterday_time=$(date -u -d "yesterday" --iso-8601=second | sed s/+00:00/Z/ | sed s/,/./)
# Curl API Call and check if status is 200
response=$(curl --request POST \
    -s \
    --url https://api.supernotes.app/v1/cards/get/select \
    --header "Api-Key: $SUPERNOTES_API_KEY" \
    --header 'Content-Type: application/json' \
    --data "{
    \"created_when\": {
        \"from_when\": \"$yesterday_time\",
        \"to_when\": \"$current_time\"
    },
    \"changed_since\": \"$yesterday_time\",
    \"filter_group\": {
        \"type\": \"group\",
        \"op\": \"and\",
        \"filters\": [
        {
            \"type\": \"visibility\",
            \"op\": \"equals\",
            \"arg\": -1,
            \"name\": \"Invisible\",
            \"inv\": true,
            \"case_sensitive\": null
        },
        {
            \"type\": \"tag\",
            \"op\": \"contains\",
            \"arg\": \"random\",
            \"name\": \"random\",
            \"inv\": null,
            \"case_sensitive\": true
        },
        {
            \"type\": \"tag\",
            \"op\": \"contains\",
            \"arg\": \"blog\",
            \"name\": \"blog\",
            \"inv\": null,
            \"case_sensitive\": true
        }
        ]
    }
    }")
if [ "$(echo "$response" | jq '.')" == "{}" ]; then
    echo "No new blog posts found."
    exit 0
fi

# Iterate over object entries in response
for row in $(echo "$response" | jq -Rnr '[inputs] | join("\\n") | fromjson | to_entries | .[] | @base64'); do
    _jq() {
        echo "${row}" | base64 --decode | jq -r "${1}"
    }

    title=$(_jq '.value.data.name')
    html=$(_jq '.value.data.html')
    id=$(_jq '.value.data.id')
    tags=$(_jq '.value.data.tags')
    created_when=$(_jq '.value.data.created_when')

    file="$script_path/../content/random/$(echo "$created_when" | cut -dT -f1)_${id}.html"
    echo "---" >"${file}"
    echo "title: \"${title}\"" >>"${file}"
    echo "tags: ${tags}" >>"${file}"
    echo "date: \"${created_when}\"" >>"${file}"
    echo "---" >>"${file}"
    echo "${html}" >>"${file}"
done

echo "New blog posts fetched successfully."