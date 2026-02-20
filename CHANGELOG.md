# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Flutter

#### Changed

- Updated the internal handling of ExternalIdResult on Android (for `storeExternalId()` method)

## [7.4.0] - 2026-02-10
- Android SDK version: 18.0.2
- iOS SDK version: 6.13.0

### Flutter

#### Added
- Added `onAutomation` callback to `ThreatCallback` for handling `Threat.automation` threat

### Android

#### Added

- Added support for `KernelSU` to the existing root detection capabilities
- Added support for `HMA` to the existing root detection capabilities
- Added new malware detection capabilities
- Added `onAutomationDetected()` callback to `ThreatDetected` interface
  - We are introducing a new capability, detecting whether the device is being automated using tools like Appium
- Added value restrictions to `externalId`
  - Method `storeExternalId()` now returns `ExternalIdResult`, which indicates `Success` or `Error` when `externalId` violates restrictions

#### Fixed

- Fixed exception handling for the KeyStore `getEntry` operation
- Fixed issue in `ScreenProtector` concerning the `onScreenRecordingDetected` invocations
- Merged internal shared libraries into a single one, reducing the final APK size
- Fixed bug related to key storing in keystore type detection (hw-backed keystore check)
- Fixed manifest queries merge

#### Changed

- Removed unused library `tmlib`
- Refactoring of signature verification code
- Updated compile and target API to 36
- Improved root detection capabilities
- Detection of wireless ADB added to ADB detections

## [7.3.0] - 2025-10-20
- Android SDK version: 17.0.0
- iOS SDK version: 6.13.0

### Flutter

#### Added
- Added `killOnBypass` to `TalsecConfig` that configures if the app should be terminated when the threat callbacks are suppressed/hooked by an attacker (Android only) ([Issue 65](https://github.com/talsec/Free-RASP-Android/issues/65))
- Added `onTimeSpoofing` callback to `ThreatCallback` for handling `Threat.timeSpoofing` threat (Android only)
  - We are introducing a new capability, detecting whether the device time has been tampered with
- Added `onLocationSpoofing` callback to `ThreatCallback` for handling `Threat.locationSpoofing` threat (Android only)
  - We are introducing a new capability, detecting whether the location is being spoofed on the device.
- Added `onUnsecureWifi` callback to `ThreatCallback` for handling `Threat.unsecureWifi` threat (Android only)
  - We are introducing a new capability, detecting whether the device is connected to an unsecured Wi-Fi network.
- Added `onAllChecksDone` callback to new `RaspExecutionStateCallback`
  - We are introducing a new callback that notifies when all security checks have been completed.

### Android

#### Removed
- Removed deprecated functionality `Pbkdf2Native` and both related native libraries (`libpbkdf2_native.so` and `libpolarssl.so`)

#### Changed
- Updated internal dependencies

### iOS

#### Changed
- Updated internal dependencies

## [7.2.2] - 2025-10-09
- iOS SDK version: 6.12.1
- Android SDK version: 16.0.1

### Android

#### Fixed
- Fixed an issue with crashing screen protector 

## [7.2.1] - 2025-07-18
- iOS SDK version: 6.12.1
- Android SDK version: 16.0.1

### iOS

#### Fixed
- Fixed an issue with native framework

## [7.2.0] - 2025-07-16

- iOS SDK version: 6.12.1
- Android SDK version: 16.0.1

### Android

#### Added

- Added support for 16 KB memory page sizes
- Added `onMultiInstance` callback
  - Detecting whether the application is installed/running in various multi-instancing environments (e.g. Parallel Space)

#### Changed

- The ADB service running as a root is a signal for root detection
- Improved emulator detection
- Internal security improvements

#### Fixed

- Removed malware report duplicates

### iOS

#### Added

- Added palera1n jailbreak detection

#### Changed

- Improved Dopamine jailbreak detection

#### Fixed

- Resolved memory-related stability issues.

## [7.1.0] - 2025-05-19

- iOS SDK version:  6.11.0
- Android SDK version: 15.1.0

### Flutter

#### Added

- Added interface for screenshot / screen recording blocking on iOS
- Added interface for external ID storage

### Android

#### Added

- Added externalId to put an integrator-specified custom identifier into the logs.
- Added eventId to the logs, which is unique per each log. It allows traceability of the same log across various systems.

#### Changed

- New root detection checks added

### iOS

#### Added

- Added externalId to put an integrator-specified custom identifier into the logs.
- Added eventId to the logs, which is unique per each log. It allows traceability of the same log across various systems.
- Screen capture protection obscuring app content in screenshots and screen recordings preventing unauthorized content capture. Refer to the freeRASP integration documentation.

#### Fixed

- Issue with the screen recording detection.
- Issue that prevented Xcode tests from running correctly.
- Issue that caused compilation errors due to unknown references.

## [7.0.0] - 2024-03-26

- iOS SDK version:  6.9.0
- Android SDK version: 15.0.0

### Flutter

#### Added
- `fvm` support for Flutter version management

#### Changed
- Updated versions for example app

### Android

#### Changed
- Breaking: Raised kotlin version to 2.1.0
- Compile API increased to 35, dependencies updated
- Internal library obfuscation reworked
- Root detection divided into 2 parts (quick initial checks, and time-demanding asynchronous post checks)

#### Fixed

- ANR issues bug-fixing

### iOS

#### Added

- Improvement of the obfuscation of the SDK.

#### Changed

- Deep signing of the OpenSSL binaries.

## [6.12.0] - 2025-02-18

- iOS SDK version:  6.8.0
- Android SDK version: 14.0.1

### Flutter

#### Added

- `blockScreenCapture` method to block/unblock screen capture
- `isScreenCaptureBlocked` method to get the current screen capture blocking status
- New callbacks:
    - `screenshot`: Detects when a screenshot is taken
    - `screenRecording`: Detects when screen recording is active

#### Changed

- Raised Android CompileSDK level to 35
- Monitoring is now disabled by default

### Android

#### Added

- Passive and active screenshot/screen recording protection

#### Changed

- Improved root detection

#### Fixed

- Proguard rules to address warnings from okhttp dependency

### iOS

#### Added

- Passive Screenshot/Screen Recording detection

## [6.11.0] - 2024-12-30

- iOS SDK version:  6.6.3
- Android SDK version: 13.2.0

### Android

#### Added

- Added request integrity information to data collection headers.
- Enhanced and accelerated the data collection logic.

## [6.10.0] - 2024-12-17

- iOS SDK version:  6.6.3
- Android SDK version: 13.0.0

### Flutter

#### Changed

- App icons for detected malware are not fetched automatically anymore, which reduces computation
  required to retrieve malware data. From now on, app icons have to be retrieved using
  the `getAppIcon` method

### Android

#### Changed

- Malware data is now parsed on background thread to improve responsiveness

## [6.9.0] - 2024-11-19

- Android SDK version: 13.0.0
- iOS SDK version: 6.6.3

### Flutter

#### Added

- New feature: onADBEnabled callback allowing you to detect USB debugging option enabled in the
  developer settings on the device

### Android

#### Added

- ADB detection feature

## [6.8.0] - 2024-11-15

- Android SDK version: 12.0.0
- iOS SDK version: 6.6.3

### Flutter

#### Added

- New feature: Malware detection as a new callback for enhanced app security

### Android

#### Changed

- Internal refactoring of Malware detection feature

#### Fixed

- Refactoring Magisk checks in the root detection
- Resolving IllegalArgumentException caused by unregistering not registered receiver in
  TalsecMonitoringReceiver

### iOS

#### Added

- Enhanced security with **[Serotonin Jailbreak](https://github.com/SerotoninApp/Serotonin)
  Detection** to identify compromised devices.

#### Changed

- Updated SDK code signing; it will now be signed with:
    - Team ID: PBDDS45LQS
    - Team Name: Lynx SFT s.r.o.

## [6.7.3] - 2024-10-28

- Android SDK version: 11.1.3
- iOS SDK version: 6.6.1

### iOS

#### Changed

- Renewed the signing certificate

## [6.7.2] - 2024-10-18

- Android SDK version: 11.1.3
- iOS SDK version: 6.6.0

### Android

#### Fixed

- Reported ANR issues present on some devices were
  resolved ([GH Flutter issue #138](https://github.com/talsec/Free-RASP-Flutter/issues/138))
- Reported crashes caused by ConcurrentModificationException and NullPointerException were
  resolved ([GH Flutter issue #140](https://github.com/talsec/Free-RASP-Flutter/issues/140))
- Reported crashes caused by the UnsupportedOperationException were resolved

## [6.7.1] - 2024-09-30

- Android SDK version: 11.1.1
- iOS SDK version: 6.6.0

### Android

#### Fixed

- False positives for hook detection

## [6.7.0] - 2024-09-26

- Android SDK version: 11.1.0
- iOS SDK version: 6.6.0

### Flutter

#### Added

- Auditing mechanism for runtime checks

#### Changed

- Migration
  to [declarative Gradle plugin](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply)
- [CHANGELOG.md](CHANGELOG.md) now follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- Updated [README.md](README.md) with new documentation links

### Android

#### Added

- Auditing mechanism for runtime checks

#### Changed

- Breaking: TalsecConfig creation was migrated to a Builder pattern
- Refactored fetching the list of installed applications for root and hook detection
- Updated OpenSSL to version 3.0.14
- Updated CURL to version 8.8.0

#### Fixed

- Native crashes (SEGFAULT) in `ifpip` method
- Collision for command line tools (e.g. `ping`) which couldn't be invoked without the full path

### iOS

#### Added

- [Dopamine](https://github.com/opa334/Dopamine) jailbreak detection.

#### Changed

- Enhanced and accelerated the data collection logic
- Updated OpenSSL to version 3.0.14
- Updated CURL to version 8.8.0

# freeRASP 6.6.0

## What's new in 6.6.0?

- 🔎 Added new threat `Threat.systemVPN` for VPN detection
- 🔎 Added new callback `onSystemVPN` in `ThreatCallback` for handling `Threat.systemVPN` threat
- ❗ Increased minimal Dart SDK version to **2.18.0** and minimal Flutter version to **3.3.0**
- ⚡ Resolved issue in logging caused by the device's default system locale.
- ✔️ Updated CA bundle
- 📄 Documentation updates

## Android

- 🔎 Added new threat `Threat.devMode` for detecting Developer mode on Android
- 🔎 Added new callback `onDevMode` in `ThreatCallback` for handling `Threat.devMode` threat
- ✔️ Increased the version of the GMS dependency

## iOS

- ⚡ Passcode check is now periodical

# freeRASP 6.5.1

## What's new in 6.5.1?

- 📄 Fixed typo in README

## Android

- ⚡ New Talsec SDK artifact hosting - better stability and availibility

# freeRASP 6.5.0

## What's new in 6.5.0?

- ⚡ Updated `CURL` to `8.5.0` and `OpenSSL` to `1.1.1w` (
  resolves [issue #93](https://github.com/talsec/Free-RASP-Flutter/issues/93))
- 📄 Added information about APK size increase and ways to decrease it (
  resolves [issue #100](https://github.com/talsec/Free-RASP-Flutter/issues/100))

## Android

- ⚡ Fixed issue with disappearing threats when the app is quickly put into the background and then
  back to the foreground (
  resolves [issue #91](https://github.com/talsec/Free-RASP-Flutter/issues/91))
- ⚡ Fixed a native crash bug during one of the native root checks (detected after NDK upgrade)
- ⚡ Improved _appIntegrity_ check and its logging

## iOS

- ❗ Added Privacy Manifest
- ❗ Added codesigning for the SDK, it is signed by:
    - _Team ID_: `ASQC376HCN`
    - _Team Name_: `AHEAD iTec, s.r.o.`
- ⚡ Improved obfuscation of Swift and C strings

# freeRASP 6.4.0

Minor fixes and improvements

## What's new in 6.4.0?

- ⚡ Improved reaction obfuscation
- ⚡ Improved obfuscation of the iOS SDK
- ⚡ Fixed ProviderException on Android
- ⚡ Fixed typo in namespace which caused incompatibility with AGP 8.0
- 📄 Fixed information about Xcode version
- ❗ Raised supported Xcode version to 14.3.1

# freeRASP 6.3.0

Improved logging of the Android SDK and minor bug fixes

## What's new in 6.3.0?

- 📄 Documentation updates and improvements
- ✔️ Updated CA bundle for logging pinning
- ✔️ Added error logging of network issues within the logging process
- ✔️ Added retry politics for logging
- ⚡ Fixed issue with DeadObjectException on Android 5 and 6 caused by excessive
  PackageManager.queryIntentActivities() usage
- ⚡ Improved root detection capabilities

# freeRASP 6.2.0

Minor fixes and added support for AGP 8.0

## What's new in 6.2.0?

- ⚡ Added support for AGP 8.0
- ❗ Removed PolarSSL dependency on Android
- ❗ Removed forgotten `onOverlay` callback
- ✔️ Fixed issue
  with [denied USE_BIOMETRICS permission](https://github.com/talsec/Free-RASP-Android/issues/20)

# freeRASP 6.1.0

## What's new in 6.1.0?

- ⚡ Fixed issue with incorrect Keystore type detection on Android 11 and
  above (https://github.com/talsec/Free-RASP-Flutter/issues/77)
- ⚡ Reduced timeout period for logging from 20 sec to 5 sec on iOS
- ⚡ Logging is now async in all calls on iOS

# freeRASP 6.0.0

We are constantly working on improving your freeRASP experience. This update contains a new check -
obfuscation detection. Minimal supported Android SDK level was raised to 23.

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

- ✔️ Fixed issue when freeRASP
  throws [IllegalStateException: Talsec is not running](https://github.com/talsec/Free-RASP-Flutter/issues/70)

# freeRASP 5.0.2

Fixed issue causing app to freeze on iOS

## What's new in 5.0.2?

- ✔️ Fixed issue
  with [app freezing after `start` called on iOS](https://github.com/talsec/Free-RASP-Flutter/issues/67)
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
- ✔️ Fixed issue
  with [Codemagic CI/CD on iOS](https://github.com/talsec/Free-RASP-Flutter/issues/22)
- ✔️ Fixed issue
  with [app crashing on hot restart](https://github.com/talsec/Free-RASP-Flutter/issues/57)

### Other improvements

- 📄 Documentation updates and improvements
- ⚡ Updated demo app for new implementation
- ⬆️ Increased constraint with maximal Dart SDK version to support the latest release

# freeRASP 5.0.0-dev.1

New changes incoming! This major update, contains new API to for handling dev and release
deployments
of freeRASP. Now, you can integrate freeRASP more easily without pesky iOS installation steps. We
also no longer rely on HMS.

## What's new in 5.0.0-dev.1?

- ❗ Only one version of the SDK is used from now on, instead of two separate for dev and release

  ### Android

- ❗ Removed the HMS dependencies

- ⚡ Improved root detection accuracy by moving the 'ro.debuggable' property state to an ignored
  group

- ⚡ Enhanced root detection capabilities by moving the selinux properties check to device state

- ⚡ Fine-tuning root evaluation strategy

### iOS

- ❗ Removed the dependency on the symlinks choosing the proper version (release/dev)
- ❗️ Removed pre-built script for changing the Debug and Release versions

### Other improvements

- 📄 Documentation updates and improvements
- ⚡ Updated demo app for new implementation

# freeRASP 4.0.0

A new round of fixes and improvements! Here's the list of all the new things we included in the
latest release.

## What's new in 4.0.0?

- ❗ BREAKING API CHANGE: Added multi-signature support for certificate hashes of Android apps
- ✔️ Fixed `NullPointerException` in RootDetector when there are no running
  processes ([issue](https://github.com/talsec/Free-RASP-Flutter/issues/40)) on Android
- ✔️ Removed deprecated SafetyNet
  dependency ([issue](https://github.com/talsec/Free-RASP-Flutter/issues/28)) on Android
- ✔️ Fixed the ANR issue ([issue](https://github.com/talsec/Free-RASP-Flutter/issues/32)) on Android
- ✔️ Updated HMS and GMS dependencies on Android
- 🔎 Improved detection of BlueStacks and Nox
  emulators ([issue](https://github.com/talsec/Free-RASP-Android/issues/6)) on Android
- ❗ Improved device binding detection to not trigger for moving the app to a new device on iOS
- ⚡ Improved hook detection and logging on iOS
- 🔎 Improved logging of non-existing hardware for biometrics on iOS

# freeRASP 3.0.2

We are constantly listening to our community to make freeRASP better. This update contain fixes
to [reported issues](https://github.com/talsec/Free-RASP-Flutter/issues).

## What's new in 3.0.2?

- 📄 Updated [troubleshoot](README.md#Troubleshoot) section related to
  ProGuard [issue](https://github.com/talsec/Free-RASP-Flutter/issues/21)
- ✔️ Fixed `Duplicate class` [issue](https://github.com/talsec/Free-RASP-Flutter/issues/23)

# freeRASP 3.0.1

This update contains small fix of documentation.

## What's new in 3.0.1?

- 🛠️ Fixed Plans Comparison table in README.md

# freeRASP 3.0.0

We are constantly working on improving your freeRASP experience, and today we're happy to announce a
major update packed with new features and improvements! Here's the list of all the new things we
included in the latest release.

## What's new in 3.0.0?

Among the first changes, you will notice our prettier and easy-to-navigate README. We also created a
much-desired tool for a hash conversion (including a guide on how to use it) and added a check, so
you know you've done it right.

- 👀 Updated README.md
- 🛠️ Added tool for converting sha-256 hash to base64 form
- 🛠️ Added checks for hash correctness in the `AndroidConfig` constructor

And as usual, the new release also contains some bug squashing.

- ✔️ Fixed [issue](https://github.com/talsec/Free-RASP-Flutter/issues/9) with profile mode on
  Android
- ✔️ Fixed `onCancel` nullable [issue](https://github.com/talsec/Free-RASP-Flutter/issues/11)

## Android additions

For Android builds, we focused on extending the critical tampering detection and improving the
informational value provided by logs. You may also notice improved performance and API changes for
device binding checks.

- 🔎 Added native checks in C
- 📄 Added information about security patches to logs
- 📄 Added information about Google Play Services, Huawei Mobile Services, SafetyNet Verify Apps
- ⚡ Improved performance
- ❗ BREAKING API CHANGE: Renamed `onDeviceBinding` callback to `onDeviceBindingDetected`

## iOS improvements

For iOS devices, we prepared upgraded and polished incident detections and even added some new ones.
Other changes include several API modifications, based
on [discussion](https://github.com/talsec/Free-RASP-Flutter/issues/15) with the community.

- 🔎 Improved detection of jailbreak hiders (Shadow)
- ⚡ Improved jailbreak detection
- ⚡ Improved hook detection
- ❗ BREAKING API CHANGE: Added `unofficialStoreDetected` callback
- ❗ BREAKING API CHANGE: Removed `onPasscodeChangeDetected`
- ❗ BREAKING API CHANGE: Renamed `IOScallback` to `IOSCallback`
- ❗ BREAKING API CHANGE: Renamed parameter `IOSCallback` to `iosCallback`

## 2.0.0

### General/Flutter

* Fixed bug causing Talsec to not run properly (initialization checks for non null-safe version of
  Flutter)

* Added configuration tests

  ### Android

* Improved performance during library initialization

* Improved method handling

* Improved incident handling

* Sensitive content logging modification, package names of well-known dangerous applications (
  rooting apps, hooking frameworks, etc...) are no longer sent to Elastic, only a flag that device
  contains one of those applications is sent

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
