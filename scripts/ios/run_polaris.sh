#!/bin/bash

readonly project_dir="example/"

cd "${project_dir}"

# Install the Flutter package dependencies, which contain Dart and native iOS code.

echo "Installing node packages..."

yarn install

# Install the CocoaPods package dependencies.

cd 'ios/'

echo "Installing CocoaPods packages..."

pod install

# Build the iOS workspace.

echo "Building iOS workspace..."

xcodebuild \
    -workspace 'example.xcworkspace' \
    -scheme 'example' \
    -configuration 'Debug' \
    -destination 'generic/platform=iOS Simulator' \
    clean build
