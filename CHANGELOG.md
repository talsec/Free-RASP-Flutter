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
