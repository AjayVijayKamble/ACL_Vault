#!/bin/bash
set -e

# ==============================================================================
# ACL Vault — Appetize.io Cloud Upload & Link Generator Script
# ==============================================================================

ZIP_FILE="${1:-ACLVault-Simulator.zip}"
API_TOKEN="${APPETIZE_API_TOKEN:-$2}"
DEVICE="${3:-iphone15pro}"
OS_VERSION="${4:-17.5}"
SCALE="${5:-75}"

if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: Build artifact '$ZIP_FILE' not found."
    echo "Run scripts/build_simulator.sh first to produce the simulator bundle."
    exit 1
fi

if [ -z "$API_TOKEN" ]; then
    echo "=============================================================================="
    echo " Notice: APPETIZE_API_TOKEN not provided."
    echo " You can upload '$ZIP_FILE' directly to:"
    echo "   👉 https://appetize.io/upload"
    echo ""
    echo " Or run this script with your token:"
    echo "   APPETIZE_API_TOKEN='your_token' ./scripts/deploy_appetize.sh"
    echo "=============================================================================="
    exit 0
fi

echo "Uploading $ZIP_FILE to Appetize.io..."

RESPONSE=$(curl --silent --show-error --location \
  --request POST "https://api.appetize.io/v2/apps" \
  --header "Authorization: Bearer $API_TOKEN" \
  --form "file=@$ZIP_FILE" \
  --form "platform=ios")

echo "Response: $RESPONSE"

PUBLIC_KEY=$(echo "$RESPONSE" | grep -o '"publicKey":"[^"]*' | cut -d'"' -f4)

if [ -n "$PUBLIC_KEY" ]; then
    STREAM_URL="https://appetize.io/app/${PUBLIC_KEY}?device=${DEVICE}&osVersion=${OS_VERSION}&scale=${SCALE}"
    echo "=============================================================================="
    echo " 🚀 LIVE APPETIZE STREAM READY:"
    echo " $STREAM_URL"
    echo "=============================================================================="
else
    echo "Upload failed or public key not found in response."
    exit 1
fi

