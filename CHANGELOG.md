# freeRASP 6.3.0
Improved logging of the Android SDK and minor bug fixes

## What's new in 6.2.0?
- 📄 Documentation updates and improvements
- ✔️ updated CA bundle for logging pinning
- ✔️ added error logging of network issues within the logging process
- ✔️ added retry politics for logging
- ⚡ fixed issue with DeadObjectException on Android 5 and 6 caused by excessive PackageManager.queryIntentActivities() usage
- ⚡ improved root detection capabilities

# freeRASP 6.2.0
Minor fixes and added support for AGP 8.0

## What's new in 6.2.0?
- ⚡ Added support for AGP 8.0
- ❗ Removed PolarSSL dependency on Android
- ❗ Removed forgotten `onOverlay` callback
- ✔️ Fixed issue with [denied USE_BIOMETRICS permission](https://github.com/talsec/Free-RASP-Android/issues/20)

# freeRASP 6.1.0

## What's new in 6.1.0?
- ⚡ Fixed issue with incorrect Keystore type detection on Android 11 and above (https://github.com/talsec/Free-RASP-Flutter/issues/77)
- ⚡ Reduced timeout period for logging from 20 sec to 5 sec on iOS
- ⚡ Logging is now async in all calls on iOS

# freeRASP 6.0.0
We are constantly working on improving your freeRASP experience. This update contains a new check - obfuscation detection. Minimal supported Android SDK level was raised to 23.

## What's new in 6.0.0?
- ❗ BREAKING: Raised minSdkVersion on Android to 23
- ❗ Removed BouncyCastle dependency on Android
- 🔎 New threat type `obfuscationIssues`
- 🔎 New threat callback `onObfuscationIssues`
- ✔️ Fixed `NullPointerException` which could occur during specific subcheck execution on Android

# freeRASP 5.0.4
- ✔️ Fixed issue with metadata in iOS framework

# freeRASP 5.0.3
Fixed issue that caused freeRASP to be killed prematurely

## What's new in 5.0.3?
- ✔️ Fixed issue when freeRASP throws [IllegalStateException: Talsec is not running](https://github.com/talsec/Free-RASP-Flutter/issues/70)

# freeRASP 5.0.2
Fixed issue causing app to freeze on iOS

## What's new in 5.0.2?
- ✔️ Fixed issue with [app freezing after `start` called on iOS](https://github.com/talsec/Free-RASP-Flutter/issues/67)
- 📄 Updated example application

# freeRASP 5.0.1
Minor changes in documentation

## What's new in 5.0.1?
- 📄 Updated documentation for migration from freeRASP 4.x to 5.x

# freeRASP 5.0.0
Get ready for some exciting updates! In this latest release, we have revamped the freeRASP's 
codebase, which has helped to resolve several known issues. As a result, the integration of 
freeRASP into your workflow is even easier than before.

## What's new in 5.0.0?
- ⚡ New enum values for threat types
- ⚡ New threat handler for handling threat types
- ✔️ Fixed issue with [platform detection](https://github.com/talsec/Free-RASP-Flutter/issues/61)
- ✔️ Fixed issue with [Codemagic CI/CD on iOS](https://github.com/talsec/Free-RASP-Flutter/issues/22)
- ✔️ Fixed issue with [app crashing on hot restart](https://github.com/talsec/Free-RASP-Flutter/issues/57)

### Other improvements
- 📄 Documentation updates and improvements
- ⚡ Updated demo app for new implementation
- ⬆️ Increased constraint with maximal Dart SDK version to support the latest release

# freeRASP 5.0.0-dev.1
New changes incoming! This major update, contains new API to for handling dev and release deployments
of freeRASP. Now, you can integrate freeRASP more easily without pesky iOS installation steps. We
also no longer rely on HMS.

## What's new in 5.0.0-dev.1?
- ❗ Only one version of the SDK is used from now on, instead of two separate for dev and release
### Android
- ❗ Removed the HMS dependencies
- ⚡ Improved root detection accuracy by moving the 'ro.debuggable' property state to an ignored group
- ⚡ Enhanced root detection capabilities by moving the selinux properties check to device state
- ⚡ Fine-tuning root evaluation strategy

### iOS
- ❗ Removed the dependency on the symlinks choosing the proper version (release/dev)
- ❗️ Removed pre-built script for changing the Debug and Release versions

### Other improvements
- 📄 Documentation updates and improvements
- ⚡ Updated demo app for new implementation

# freeRASP 4.0.0
A new round of fixes and improvements! Here's the list of all the new things we included in the latest release.

## What's new in 4.0.0?
- ❗ BREAKING API CHANGE: Added multi-signature support for certificate hashes of Android apps
- ✔️ Fixed `NullPointerException` in RootDetector when there are no running processes ([issue](https://github.com/talsec/Free-RASP-Flutter/issues/40)) on Android
- ✔️ Removed deprecated SafetyNet dependency ([issue](https://github.com/talsec/Free-RASP-Flutter/issues/28)) on Android
- ✔️ Fixed the ANR issue ([issue](https://github.com/talsec/Free-RASP-Flutter/issues/32)) on Android
- ✔️ Updated HMS and GMS dependencies on Android
- 🔎 Improved detection of BlueStacks and Nox emulators ([issue](https://github.com/talsec/Free-RASP-Android/issues/6)) on Android
- ❗ Improved device binding detection to not trigger for moving the app to a new device on iOS
- ⚡ Improved hook detection and logging on iOS
- 🔎 Improved logging of non-existing hardware for biometrics on iOS

# freeRASP 3.0.2
We are constantly listening to our community to make freeRASP better. This update contain fixes to [reported issues](https://github.com/talsec/Free-RASP-Flutter/issues).

## What's new in 3.0.2?
- 📄 Updated [troubleshoot](README.md#Troubleshoot) section related to ProGuard [issue](https://github.com/talsec/Free-RASP-Flutter/issues/21) 
- ✔️ Fixed `Duplicate class` [issue](https://github.com/talsec/Free-RASP-Flutter/issues/23)

# freeRASP 3.0.1
This update contains small fix of documentation.

## What's new in 3.0.1?
- 🛠️ Fixed Plans Comparison table in README.md

# freeRASP 3.0.0
We are constantly working on improving your freeRASP experience, and today we're happy to announce a major update packed with new features and improvements! Here's the list of all the new things we included in the latest release.

## What's new in 3.0.0?

Among the first changes, you will notice our prettier and easy-to-navigate README. We also created a much-desired tool for a hash conversion (including a guide on how to use it) and added a check, so you know you've done it right.

- 👀 Updated README.md
- 🛠️ Added tool for converting sha-256 hash to base64 form
- 🛠️ Added checks for hash correctness in the `AndroidConfig` constructor

And as usual, the new release also contains some bug squashing.

- ✔️ Fixed [issue](https://github.com/talsec/Free-RASP-Flutter/issues/9) with profile mode on Android
- ✔️ Fixed `onCancel` nullable [issue](https://github.com/talsec/Free-RASP-Flutter/issues/11)

## Android additions

For Android builds, we focused on extending the critical tampering detection and improving the informational value provided by logs. You may also notice improved performance and API changes for device binding checks.

- 🔎 Added native checks in C
- 📄 Added information about security patches to logs
- 📄 Added information about Google Play Services, Huawei Mobile Services, SafetyNet Verify Apps
- ⚡ Improved performance
- ❗ BREAKING API CHANGE: Renamed `onDeviceBinding` callback to `onDeviceBindingDetected`

## iOS improvements

For iOS devices, we prepared upgraded and polished incident detections and even added some new ones. Other changes include several API modifications, based on [discussion](https://github.com/talsec/Free-RASP-Flutter/issues/15) with the community.

- 🔎 Improved detection of jailbreak hiders (Shadow)
- ⚡ Improved jailbreak detection
- ⚡ Improved hook detection
- ❗ BREAKING API CHANGE: Added `unofficialStoreDetected` callback
- ❗ BREAKING API CHANGE: Removed `onPasscodeChangeDetected`
- ❗ BREAKING API CHANGE: Renamed `IOScallback` to `IOSCallback`
- ❗ BREAKING API CHANGE: Renamed parameter `IOSCallback` to `iosCallback`

## 2.0.0
### General/Flutter
* Fixed bug causing Talsec to not run properly (initialization checks for non null-safe version of Flutter)
* Added configuration tests
### Android
* Improved performance during library initialization
* Improved method handling
* Improved incident handling
* Sensitive content logging modification,  package names of well-known dangerous applications (rooting apps, hooking frameworks, etc...) are no longer sent to Elastic, only a flag that device contains one of those applications is sent
* Fixed usage of deprecated API calls (DexFile) for Android 8.0 and above
* Fixed issue with root prompt ("app asking for root permission") on rooted devices
### iOS
* Updated jailbreak checks to detect jailbreak hiders
* Updated hook checks
* Better debugger handling
* Better incident handling
* Fixed issue with false positive during device binding check

## 1.1.0
#### Android  
* Changed minSDK to 21
* Added DeviceBinding callback
* Added UntrustedInstallation callback

#### iOS  
* Added onDeviceChange callback
* Added onDeviceIdDetected callback

## 1.0.0
* Initial full release of freeRASP.

## 0.0.4
* Update: documentation

## 0.0.3
### General/Flutter
* Fix: documentation

## 0.0.2
### General/Flutter
* Updated README.md
### iOS
* Fixed build failure on Xcode

## 0.0.1
* Initial testing release of freeRASP.
