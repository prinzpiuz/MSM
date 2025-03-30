#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

PUBSPEC_FILE="pubspec.yaml"
NEW_SEMANTIC_VERSION="$1"

# Get the current version
CURRENT_VERSION=$(grep "^version:" "$PUBSPEC_FILE" | awk '{print $2}')

echo "Current version: $CURRENT_VERSION"

# Extract the build number from the current version
CURRENT_BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

# Increment the build number
NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER+=1))
# CURRENT_BUILD_NUMBER++

# Construct the new version string
NEW_VERSION="${NEW_SEMANTIC_VERSION}+${NEW_BUILD_NUMBER}"

# Replace the version in pubspec.yaml
sed -i "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC_FILE"

echo "Updated version in $PUBSPEC_FILE to: $NEW_VERSION"
