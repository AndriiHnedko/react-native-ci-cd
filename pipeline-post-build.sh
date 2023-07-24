#!/usr/bin/env bash

echo 'Move artifacts'
APK_FILE=$(find "./android/app/build/outputs" -type f -name '*.apk')
mkdir /tmp/artifacts
cp "$APK_FILE" /tmp/artifacts
