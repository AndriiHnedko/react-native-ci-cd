[![CircleCI](https://dl.circleci.com/status-badge/img/gh/AndriiHnedko/react-native-ci-cd/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/AndriiHnedko/react-native-ci-cd/tree/main)
![github actions android beta](https://github.com/AndriiHnedko/react-native-ci-cd/actions/workflows/build-android-beta.yml/badge.svg)
![github actions ios beta](https://github.com/AndriiHnedko/react-native-ci-cd/actions/workflows/build-ios-beta.yml/badge.svg)

[![CircleCI](https://dl.circleci.com/insights-snapshot/gh/AndriiHnedko/react-native-ci-cd/main/android/badge.svg?window=30d)](https://app.circleci.com/insights/github/AndriiHnedko/react-native-ci-cd/workflows/android/overview?branch=main&reporting-window=last-30-days&insights-snapshot=true)

[![CircleCI](https://dl.circleci.com/insights-snapshot/gh/AndriiHnedko/react-native-ci-cd/main/ios/badge.svg?window=30d)](https://app.circleci.com/insights/github/AndriiHnedko/react-native-ci-cd/workflows/ios/overview?branch=main&reporting-window=last-30-days&insights-snapshot=true)

# Fastlane 2023

## Description

This repository contains examples of a pipeline for beta distribution of Android
(Firebase App Distribution) and iOS (Testflight) using Fastlane,
demonstrated with React Native integration, and utilizing CircleCI and GitHub Actions.

This guide is intended for users already familiar with Fastlane.
Below, we will outline the necessary steps to prepare for beta distribution.

### Android

#### Obtain a Firebase App Distribution Token

1. Install the [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
2. Authenticate with Firebase using the following command:

```shell
firebase login:ci
```

3. Insert the obtained refresh token into the variable **FIREBASE_TOKEN** in `fastlane/.env`.
4. Insert your App ID in the settings of your Firebase project into **FIREBASE_APP**.
5. Insert your distribution group into **FIREBASE_DISTRIBUTION_GROUP**.
   You can use multiple groups, separated by commas, like this: `"qa-team, trusted-testers"`.

As a result, your `fastlane/.env` file should contain the following:

```dotenv
FIREBASE_APP=YOUR APP ID
FIREBASE_DISTRIBUTION_GROUP=YOUR DISTRIBUTION GROUPS
FIREBASE_TOKEN=YOUR FIREBASE REFRESH TOKEN
```

You can find complete code examples in these files:

- [.env.example](fastlane/.env.example)
- [Fastfile](fastlane/Fastfile)
- [Prebuild script for CI](pipeline-pre-build.sh)
- [CircleCI](.circleci/config.yml)
- [GitHub Actions](.github/workflows/build-android-beta.yml)

### iOS

#### App Store Connect API Key

Create a new App Store Connect API Key in the [Users page](https://appstoreconnect.apple.com/access/integrations/api)

1. Select the "Keys" tab
2. Give your API Key an appropriate role for the task at hand. You can read more about roles in Permissions
   in [App Store Connect](https://developer.apple.com/support/roles/)
3. Note the Issuer ID and Key ID as you will need it for the configuration steps below
4. Download the newly created API Key file (.p8)

> **NOTE**: This file cannot be downloaded again after the page has been refreshed

5. Open the API Key file (.p8), and you will see a structure similar to this:

```
-----BEGIN PRIVATE KEY-----
y8X74yAUq9keMiRyjk90VKsmmNN9gEe1R9jN8jeRjm6EdzjX53e54i6P7VPuCjyL
X5C4CcVQCAvNzqNNDKVmXbjX2zI0C5aYHmWrkBQql0M0QCzt0ZCS3k6Yjl6n75AH
W3uHjBPR3SxuR1xqEQqqAnu5jbp4QyjaaRkSr3hl4M08ss1umgP38G95bChMFVft
HOqdwHmP
-----END PRIVATE KEY-----
```

6. Convert this to a single line, using `\n` for line breaks, and place it into
   the variable **APP_STORE_CONNECT_API_KEY_KEY** in `fastlane/.env`.
   The resulting entry should look like this:

```dotenv
APP_STORE_CONNECT_API_KEY_KEY='-----BEGIN PRIVATE KEY-----\ny8X74yAUq9keMiRyjk90VKsmmNN9gEe1R9jN8jeRjm6EdzjX53e54i6P7VPuCjyL\nX5C4CcVQCAvNzqNNDKVmXbjX2zI0C5aYHmWrkBQql0M0QCzt0ZCS3k6Yjl6n75AH\nW3uHjBPR3SxuR1xqEQqqAnu5jbp4QyjaaRkSr3hl4M08ss1umgP38G95bChMFVft\nHOqdwHmP\n-----END PRIVATE KEY-----'
```

7. Insert the Issuer ID into the variable **APP_STORE_CONNECT_API_KEY_ISSUER_ID**.
8. Insert the Key ID into the variable **APP_STORE_CONNECT_API_KEY_KEY_ID**.

#### Match

To store certificates, I prefer using an S3 bucket as it provides universality and convenience,
especially in CI systems.

1. Insert the appropriate values from your Apple Developer Account into `fastlane/.env`: **APP_IDENTIFIER, APPLE_ID, ITC_TEAM_ID, TEAM_ID**.
2. Your Appfile should contain the following. You can find the complete code here: [Appfile](fastlane/AppFile)

```
app_identifier(ENV["APP_IDENTIFIER"]) # The bundle identifier of your app
apple_id(ENV["APPLE_ID"]) # Your Apple Developer Portal username
itc_team_id(ENV["ITC_TEAM_ID"]) # App Store Connect Team ID
team_id(ENV["TEAM_ID"]) # Developer Portal Team ID
```

3. Initialize Match in the root of your project with the following command, and choose S3 storage. This will generate a Matchfile for you.

```shell
fastlane match init
```

4. Insert the appropriate values from your S3 bucket into `fastlane/.env`: **S3_ACCESS_KEY, S3_SECRET_ACCESS_KEY, S3_BUCKET, S3_REGION**.
5. Your Matchfile should contain the following. You can find the complete code here: [Matchfile](fastlane/Matchfile)

```
s3_bucket(ENV["S3_BUCKET"])
s3_region(ENV["S3_REGION"])
s3_access_key(ENV["S3_ACCESS_KEY"])
s3_secret_access_key(ENV["S3_SECRET_ACCESS_KEY"])
storage_mode("s3")
```

6. Create a password and place it in the variable **MATCH_PASSWORD**.
   This password will be used to encrypt/decrypt the certificates, so don't lose it.
   Every developer on your team must have it to download the certificates.
7. Execute the following commands to generate the certificates:

```shell
fastlane match appstore
fastlane match development
```

8. Change in Xcode the signing option

I assume you previously used automatic signing by Xcode. So you can now disable this check on every build type and
scheme you have and select the appropriate provisioning profile that match created. It should start with
`match ... com.company.example` depending on the type of build you are selecting.

For example, for development or profile build types, you should select the one that start with
`match Development com.company.example` and for the release you should use `match AppStore com.company.example`.

If an error appears, usually restarting Xcode solves it.

Everyone in your team should do the same.

