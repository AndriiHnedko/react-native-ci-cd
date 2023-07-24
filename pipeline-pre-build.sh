#!/usr/bin/env bash

echo "Prepare android keystore"
KEYSTORE_FILE=./android/app/release.keystore
echo "$ANDROID_KEYSTORE" | base64 -d >$KEYSTORE_FILE
#for circleci
echo "KEYSTORE_PATH=$(readlink -f $KEYSTORE_FILE)" >>"$BASH_ENV"
#for github actions
echo "KEYSTORE_PATH=$(readlink -f $KEYSTORE_FILE)" >>"$GITHUB_ENV"
echo "Keystore file created: $KEYSTORE_FILE"

echo "Prepare env file $ENV_FILE_NAME"
ENV_WHITELIST=${ENV_WHITELIST:-"^RN_"}
if [ -z "$ENV_FILE_NAME" ]; then
  ENV_FILE_NAME=.env
fi
set | grep -E "$ENV_WHITELIST" | sed 's/^RN_//g' >"$ENV_FILE_NAME"
cp "$ENV_FILE_NAME" .env
echo ".env ($ENV_FILE_NAME) created with contents:"
cat "$ENV_FILE_NAME"

#echo "Generate reactotron config file"
#cp "./ReactotronConfig.js.example" "./ReactotronConfig.js"
#echo "Reactotron config file created: ./ReactotronConfig.js"
