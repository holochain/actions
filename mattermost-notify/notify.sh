#!/usr/bin/env bash

set -euo pipefail

base_url="${MATTERMOST_URL%/}"
posts_url="${base_url}/api/v4/posts"

payload="$(jq -cn \
  --arg channel_id "$MATTERMOST_CHANNEL_ID" \
  --arg message "$MATTERMOST_MESSAGE" \
  '{channel_id: $channel_id, message: $message}')"

response_body="$(mktemp)"
trap 'rm -f "$response_body"' EXIT

response_code="$(curl \
  --silent \
  --show-error \
  --connect-timeout 10 \
  --max-time 30 \
  --output "$response_body" \
  --write-out "%{http_code}" \
  --request POST "$posts_url" \
  --header "Authorization: Bearer $MATTERMOST_PERSONAL_ACCESS_TOKEN" \
  --header "Content-Type: application/json" \
  --data "$payload")"

if [ "$response_code" -lt 200 ] || [ "$response_code" -ge 300 ]; then
  printf 'Mattermost API request failed with HTTP %s\n' "$response_code"
  cat "$response_body"
  exit 1
fi

printf 'Message sent to Mattermost channel %s\n' "$MATTERMOST_CHANNEL_ID"
