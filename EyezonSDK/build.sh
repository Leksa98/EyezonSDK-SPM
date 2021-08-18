#!/bin/bash
BUILD_DIR=$PWD

xcodebuild archive \
-project EyezonSDK.xcodeproj \
-scheme EyezonSDK \
-configuration Release \
-sdk iphoneos \
-archivePath './build/EyezonSDK.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

## Simulator
xcodebuild archive \
-project EyezonSDK.xcodeproj \
-scheme EyezonSDK \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/EyezonSDK.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework './build/EyezonSDK.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/EyezonSDK.framework' \
-framework './build/EyezonSDK.framework-iphoneos.xcarchive/Products/Library/Frameworks/EyezonSDK.framework' \
-output './build/EyezonSDK.xcframework'

