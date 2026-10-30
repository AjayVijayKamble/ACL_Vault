#!/bin/bash
set -o pipefail

echo "=========================================================="
echo "=== Step 1: Generating Xcode Project with XcodeGen ==="
echo "=========================================================="
xcodegen generate --spec project.yml

echo "=== Step 2: Patching objectVersion for compatibility ==="
sed -i '' 's/objectVersion = [0-9]*/objectVersion = 56/g' ACLVault.xcodeproj/project.pbxproj
grep "objectVersion" ACLVault.xcodeproj/project.pbxproj || true

echo "=========================================================="
echo "=== Step 3: Compiling ACLVault for iOS Simulator ==="
echo "=========================================================="
set +e
xcodebuild build \
  -project ACLVault.xcodeproj \
  -scheme ACLVault \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  -derivedDataPath ./DerivedData \
  COMPILER_INDEX_STORE_ENABLE=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" 2>&1 | tee xcodebuild_raw.log

BUILD_CODE=${PIPESTATUS[0]}
set -e

if [ $BUILD_CODE -ne 0 ]; then
  echo "=========================================================="
  echo "=== COMPILATION FAILED (Exit Code: $BUILD_CODE) ==="
  echo "=========================================================="
  grep -E "error:|fatal error:" xcodebuild_raw.log | head -n 50 || true
  echo "=========================================================="
  
  # Push build log to build-log branch for immediate local inspection
  git config user.name "github-actions[bot]"
  git config user.email "github-actions[bot]@users.noreply.github.com"
  git checkout -B build-log
  git add -f xcodebuild_raw.log
  git commit -m "ci: compiler log" || true
  git push origin build-log --force || true
  
  if [ -n "$GITHUB_STEP_SUMMARY" ]; then
    echo "## ❌ Xcode Compilation Errors (Exit Code $BUILD_CODE)" >> "$GITHUB_STEP_SUMMARY"
    echo '```text' >> "$GITHUB_STEP_SUMMARY"
    grep -E "error:|fatal error:" xcodebuild_raw.log | head -n 50 >> "$GITHUB_STEP_SUMMARY"
    echo '```' >> "$GITHUB_STEP_SUMMARY"
  fi
  exit $BUILD_CODE
fi

echo "=========================================================="
echo "=== BUILD SUCCEEDED ==="
echo "=========================================================="
