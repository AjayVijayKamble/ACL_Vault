#!/bin/bash
set -e

# ==============================================================================
# ACL Vault — Local & CI iOS Simulator Build Script
# ==============================================================================

echo "--- Step 1: Checking XcodeGen ---"
if ! command -v xcodegen &> /dev/null; then
    echo "Error: xcodegen is not installed. Install via: brew install xcodegen"
    exit 1
fi

echo "--- Step 2: Generating Xcode Project ---"
xcodegen generate --spec project.yml

echo "--- Step 3: Compiling for iOS Simulator ---"
xcodebuild build \
  -project ACLVault.xcodeproj \
  -scheme ACLVault \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath DerivedData \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  COMPILER_INDEX_STORE_ENABLE=NO

echo "--- Step 4: Packaging Simulator Bundle into ZIP ---"
APP_PATH=$(find DerivedData/Build/Products -name "ACLVault.app" -type d | head -n 1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "Error: ACLVault.app could not be found in DerivedData"
    exit 1
fi

PARENT_DIR=$(dirname "$APP_PATH")
APP_NAME=$(basename "$APP_PATH")

rm -f ACLVault-Simulator.zip
(cd "$PARENT_DIR" && zip -r -y "${OLDPWD}/ACLVault-Simulator.zip" "$APP_NAME")

echo "=============================================================================="
echo " SUCCESS: ACLVault-Simulator.zip created successfully!"
echo " Location: $(pwd)/ACLVault-Simulator.zip"
echo " Size: $(du -h ACLVault-Simulator.zip | cut -f1)"
echo " You can upload this ZIP directly to https://appetize.io/upload"
echo "=============================================================================="

