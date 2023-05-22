![FreeRasp](https://raw.githubusercontent.com/talsec/Free-RASP-Community/master/visuals/freeRASP.png)

![GitHub Repo stars](https://img.shields.io/github/stars/talsec/Free-RASP-Community?color=green) ![Likes](https://img.shields.io/pub/likes/freerasp?color=green!) ![Likes](https://img.shields.io/pub/points/freerasp) ![GitHub](https://img.shields.io/github/license/talsec/Free-RASP-Community) ![GitHub](https://img.shields.io/github/last-commit/talsec/Free-RASP-Community) [![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
![Publisher](https://img.shields.io/pub/publisher/freerasp)

# freeRASP for Flutter

freeRASP for Flutter is a mobile in-app protection and security monitoring SDK. It aims to cover the main aspects of RASP (Runtime App Self Protection) and application shielding.

# :notebook_with_decorative_cover: Table of contents

- [Overview](#overview)
- [Usage](#usage)
    * [Step 1: Prepare freeRASP library](#step-1-prepare-freerasp-library)
        + [iOS setup](#ios-setup)
        + [Android setup](#android-setup)
    * [Step 2: Setup the Configuration for your App](#step-2-setup-the-configuration-for-your-app)
        + [Dev vs Release version](#dev-vs-release-version)
    * [Step 3: Handle detected threats](#step-3-handle-detected-threats)
    * [Step 4: Start the freeRASP](#step-4-start-the-freerasp)
    * [Step 5: Additional note about obfuscation](#step-5-additional-note-about-obfuscation)
    * [Step 6: User Data Policies](#step-6-user-data-policies)
- [Troubleshooting](#troubleshooting)
- [Security Report](#security-report)
- [Commercial versions (RASP+ and more)](#bar_chart-commercial-versions-rasp-and-more)
    * [Plans comparison](#plans-comparison)
- [About Us](#about-us)
- [License](#license)

# Overview

The freeRASP is available for Flutter, Android, and iOS developers. We encourage community contributions, investigations of attack cases, joint data research, and other activities aiming to make better app security and app safety for end-users.

freeRASP SDK is designed to combat

* Reverse engineering attempts
* Re-publishing or tampering with the apps
* Running application in a compromised OS environment
* Malware, fraudsters, and cybercriminal activities

Key features are the detection and prevention of

* Root/Jailbreak (e.g., unc0ver, check1rain)
* Hooking framework (e.g., Frida, Shadow)
* Untrusted installation method
* App/Device (un)binding

Additional freeRASP features include low latency, easy integration and a weekly [Security Report](#security-report) containing detailed information about detected incidents and potential threats, summarizing the state of your app security.

The commercial version provides a top-notch protection level, extra features, support and maintenance. One of the most valued commercial features is AppiCrypt® - App Integrity Cryptogram.

It allows easy to implement API protection and App Integrity verification on the backend to prevent API abuse:

* Bruteforce attacks
* Botnets
* Session-hijacking
* DDoS

It is a unified solution that works across all mobile platforms without dependency on external web services (i.e., without extra latency, an additional point of failure, and maintenance costs).

Learn more about commercial features at [https://talsec.app](https://talsec.app).

Learn more about freemium freeRASP features at [GitHub main repository](https://github.com/talsec/Free-RASP-Community).

# Usage

We will guide you step-by-step, but you can always check the expected result in the example.

## Step 1: Prepare freeRASP library

Add dependency to your `pubspec.yaml` file

```yaml
dependencies:
  freerasp: 5.0.3
```

and run `pub get`

### iOS setup

**If you are upgrading from a previous version of freeRASP**, please remove the old `TalsecRuntime.xcframework`
and integration script from your project: 
1. Go to your project's `ios` folder
2. Open `Runner.xcworkspace` in Xcode
3. On top bar select `Runner` -> `Edit Scheme...`
4. On the left side select `Build` -> `Pre-actions`
5. Find integration script and click trash icon on the right side to remove it
6. Open the `.flutter-plugins` (in the root folder of the app), and get the address, where the freerasp is installed.
7. Go to the given folder, and remove the freerasp folder file.
8. Delete .symlinks folder from project.
9. Run `pub get`
10. Run `pod install` to test it


**Otherwise, no further setup is required.**

**Note: You need Xcode 13 to be able to build the application.**

### Android setup

* From root of your project, go to **android > app > build.gradle**
* In `defaultConfig` update `minSdkVersion` to at least **21** (Android 5.0) or higher

```gradle
android {
...
defaultConfig {
    ...
    minSdkVersion 21
    ...
    }
...
}
```

## Step 2: Setup the Configuration for your App

Add imports to the top of the file where you want to use Talsec:

```dart
import 'package:freerasp/freerasp.dart';
```

To properly configure freeRASP for your app, you need to initialize it with a configuration that contains relevant details about your app.  In addition for freeRASP to work correctly, it is necessary that Flutter Bindings are initialized. This can be satisfied by calling `WidgetsFlutterBinding.ensureInitialized()`, as shown in the code snippet below.

```dart
void main() {
  ...

  // This line is important!
  WidgetsFlutterBinding.ensureInitialized();

  // create configuration for freeRASP
  final config = TalsecConfig(
    /// For Android
    androidConfig: AndroidConfig(
      packageName: 'your.package.name',
      signingCertHashes: [
        'AKoRu...'
      ],
      supportedStores: ['some.other.store'],
    ),

    /// For iOS
    iosConfig: IOSConfig(
      bundleIds: ['YOUR_APP_BUNDLE_ID'],
      teamId: 'M8AK35...',
    ),
    watcherMail: 'your_mail@example.com',
    isProd: true,
  );
}
```

Here, a `TalsecConfig` is created with both `AndroidConfig` and `IOSConfig`. Identifiers `packageName` and `signingCertHashes` are required for Android
version.

* `packageName` - package name of your app you chose when you created it
* `signingCertHashes` - list of hashes of the certificates of the keys which were
  used to sign the application. At least one hash value must be provided. **Hashes which are passed
  here must be encoded in Base64 form**

We provide a handy util tool to help you convert your SHA-256 hash to Base64:

```dart
// Signing hash of your app
String base64Hash = hashConverter.fromSha256toBase64(sha256HashHex);
```

We strongly recommend using **result value** of this tool in signingCertHashes. **Do not use this tool directly** in `signingCertHashes` to get value. If you are not sure how to get your hash certificate, you can check out the guide on our [Github wiki](https://github.com/talsec/Free-RASP-Community/wiki/Getting-your-signing-certificate-hash-of-app).
.

Similarly, `bundleIds` and `teamId` are needed for iOS version of app. If you publish on the
Google Play Store and/or Huawei AppGallery, you **don't have to assign anything**
to `supportedStores` as those are supported out of the box.

Next, pass a mail address to `watcherMail` to be able to get reports. Mail has a strict
form `name@domain.com` which is passed as String.

If you are developing only for one of the platforms, you can leave the configuration part for the
other one, i.e., delete the other configuration.

### Dev vs Release version

The Dev version is used during the development of the application. It separates development and
production data and disables some checks which won't be triggered during the development process:

* Emulator-usage (onEmulatorDetected, onSimulatorDetected)
* Debugging (onDebuggerDetected)
* Signing (onTamperDetected, onSignatureDetected)
* Unofficial store (onUntrustedInstallationSource, onUnofficialStoreDetected)

Dev vs Release is currently managed using `isProd` flag in `TalsecConfig` class:

```dart
TalsecConfig(
   isProd: true,
   ...
)
```

`isProd`  defaults to  `true`  when undefined. If you want to use the Dev version to disable checks described above, set the parameter to  `false`. Make sure that you have the Release version in the production (i.e. isProd set to `true`)!

## Step 3: Handle detected threats

freeRASP reacts to threats using _ThreatCallback_. Internally, each threat has its own callback (of `VoidCallback` type), which is called when a threat is detected. 

```dart
void main() {
  ...

  // Setting up callbacks
  final callback = ThreatCallback(
      onAppIntegrity: () => print("App integrity"),
      onDebug: () => print("Debugging"),
      onDeviceBinding: () => print("Device binding"),
      onDeviceID: () => print("Device ID"),
      onHooks: () => print("Hooks"),
      onPasscode: () => print("Passcode not set"),
      onPrivilegedAccess: () => print("Privileged access"),
      onSecureHardwareNotAvailable: () => print("Secure hardware not available"),
      onSimulator: () => print("Simulator"),
      onUnofficialStore: () => print("Unofficial store")
  );

  // Attaching listener
  Talsec.instance.attachListener(callback);
}
```

Visit our [wiki](https://github.com/talsec/Free-RASP-Community/wiki/Threat-detection) to learn more
details about the performed checks and their importance for app security.

## Step 4: Start the freeRASP

Start freeRASP to detect threats just by adding this line below the created config and the
callback handler:

```dart
void main() async {
  ...

  // start freeRASP
  await Talsec.instance.start(config);
}
```

## Step 5: Additional note about obfuscation
The freeRASP contains public API, so the integration process is as simple as possible. Unfortunately, this public API also creates opportunities for the attacker to use publicly available information to interrupt freeRASP operations or modify your custom reaction implementation in threat callbacks. In order for freeRASP to be as effective as possible, it is highly recommended to apply obfuscation to the final package/application, making the public API more difficult to find and also partially randomized for each application so it cannot be automatically abused by generic hooking scripts.

### Android
The majority of Android projects support code shrinking and obfuscation without any additional need for setup. The owner of the project can define the set of rules that are usually automatically used when the application is built in the release mode. For more information, please visit the official documentation
* https://developer.android.com/studio/build/shrink-code 
* https://www.guardsquare.com/manual/configuration/usage

You can make sure, that the obfuscation is enabled by checking the value of **minifyEnabled** property in your **module's build.gradle** file.
```gradle
android {
    ...

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

## Step 6: User Data Policies
See the generic info about freeRASP data collection [here](https://github.com/talsec/Free-RASP-Community/tree/master#data-collection-processing-and-gdpr-compliance).

Google Play [requires](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) all app publishers to declare how they collect and handle user data for the apps they publish on Google Play. They should inform users properly of the data collected by the apps and how the data is shared and processed. Therefore, Google will reject the apps which do not comply with the policy.

Apple has a [similar approach](https://developer.apple.com/app-store/app-privacy-details/) and specifies the types of collected data.

You should also visit our [Android](https://github.com/talsec/Free-RASP-Android/) and [iOS](https://github.com/talsec/Free-RASP-iOS/) submodules to learn more about their respective data policies.

And you're done 🎉!

# Troubleshooting

### \[Android] `Could not find ... ` dependency issue

**Solution:** Add dependency manually (
see [issue](https://github.com/talsec/Free-RASP-Flutter/issues/1)).

In android -> app -> build.gradle add these dependencies

```gradle
dependencies {

 ... some other dependecies ...

   // Talsec dependency
   implementation 'com.aheaditec.talsec.security:TalsecSecurity-Community-Flutter:<version>'
}
```

### \[iOS] Unable to build release for simulator in Xcode (errors)

**Solution:** Simulator does **not** support release build of Flutter - more about
it [here](https://flutter.dev/docs/testing/build-modes#release). Use a real device in order to build
the app in release mode.

### \[iOS] MissingPluginException occurs on hot restart

**Solution:** Technical limitation of Flutter - more about
it [here](https://stackoverflow.com/questions/50459272/missingpluginexception-while-using-plugin-for-flutter)
. Use command `flutter run` to launch app (i.e. run app from scratch).

### \[Android] Code throws `java.lang.UnsatisfiedLinkError: No implementation found for...` exception when building APK

**Solution:** Android version of freeRASP is already obfuscated.

Add this rule to your `proguard-rules.pro` file:

```
-keepclasseswithmembernames,includedescriptorclasses class * {
native ;
}
```

### \[iOS] Building using Codemagic fails: `No such module 'TalsecRuntime'`

**Solution:** You have to adjust Codemagic building pipeline. Instructions how to do it
are [here](https://github.com/talsec/Free-RASP-Flutter/issues/22#issuecomment-1383964470).

If you encounter any other issues, you can see the list of solved
issues [here](https://github.com/talsec/Free-RASP-Flutter/issues?q=is%3Aissue+is%3Aclosed), or open
up a [new one](https://github.com/talsec/Free-RASP-Flutter/issues?q=is%3Aopen+is%3Aissue).

# Security Report

The Security Report is a weekly summary describing the application's security state and characteristics of the devices it runs on in a practical and easy-to-understand way.

The report provides a quick overview of the security incidents, their dynamics, app integrity, and reverse engineering attempts. It contains info about the security of devices, such as OS version or the ratio of devices with screen locks and biometrics. Each visualization also comes with a concise explanation.

To receive Security Reports, fill out the _watcherMail_ field in [Talsec config](#step-2-setup-the-configuration-for-your-app).

![enter image description here](https://raw.githubusercontent.com/talsec/Free-RASP-Community/master/visuals/dashboard.png)

# :bar_chart: Commercial versions (RASP+ and more)
We provide app security hardening SDK: i.e. AppiCrypt®, Customer Data Encryption (local storage), End-to-end encryption, Strings protection (e.g. API keys) and Dynamic Certificate Pinning to our commercial customers as well. To get the most advanced protection compliant with PSD2 RT and eIDAS and support from our experts, contact us at [talsec.app](https://talsec.app).

The commercial version provides a top-notch protection level, extra features, support, and maintenance. One of the most valued commercial features is [AppiCrypt®](https://www.talsec.app/appicrypt) - App Integrity Cryptogram.

It allows easy to implement API protection and App Integrity verification on the backend to prevent API abuse:

-   Bruteforce attacks
-   Botnets
-   Session-hijacking
-   DDoS

It is a unified solution that works across all mobile platforms without dependency on external web services (i.e., without extra latency, an additional point of failure, and maintenance costs).

Learn more about commercial features at  [https://talsec.app](https://talsec.app/).

**TIP:** You can try freeRASP and then upgrade easily to an enterprise service.


## Plans Comparison
<i>
freeRASP is freemium software i.e. there is a Fair Usage Policy (FUP) that impose some limitations on the free usage. See the FUP section in the table below
</i>
<br/>
<br/>
<table>
    <thead>
        <tr>
            <th></th>
            <th>freeRASP</th>
            <th>Business RASP+</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td colspan=5><strong>Runtime App Self Protection (RASP, app shielding)</strong></td>
        </tr>
        <tr>
            <td>Advanced root/jailbreak protections</td>
            <td>basic</td>
            <td>advanced</td>
        </tr>
        <tr>
            <td>Runtime reverse engineering controls 
                <ul>
                    <li>Debug</li>
                    <li>Emulator</li>
                    <li>Hooking protections (e.g. Frida)</li>
                </ul>
            </td>
            <td>basic</td>
            <td>advanced</td>
        </tr>
        <tr>
            <td>Runtime integrity controls 
                <ul>
                    <li>Tamper protection</li>
                    <li>Repackaging / Cloning protection</li>
                    <li>Device binding protection</li>
                    <li>Unofficial store detection</li>
                </ul>
            </td>
            <td>basic</td>
            <td>advanced</td>
        </tr>
        <tr>
            <td>Device OS security status check 
                <ul>
                    <li>HW security module control</li>
                    <li>Screen lock control</li>
                </ul>
            </td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>UI protection 
                <ul>
                    <li>Overlay protection</li>
                    <li>Accessibility services protection</li>
                </ul>
            </td>
            <td>no</td>
            <td>yes</td>
        </tr>
        <tr>
            <td colspan=5><strong>Hardening suite</strong></td>
        </tr>
        <tr>
            <td>Security hardening suite 
                <ul>
                    <li>Customer Data Encryption (local storage)</li>
                    <li>End-to-end encryption</li>
                    <li>Strings protection (e.g. API keys)</li>
                    <li>Dynamic certificate pinning</li>
                </ul>
            </td>
            <td>no</td>
            <td>yes</td>
        </tr>
        <tr>
            <td colspan=5><strong>AppiCrypt® - App Integrity Cryptogram</strong></td>
        </tr>
        <tr>
            <td>API protection by mobile client integrity check, online risk scoring, online fraud prevention, client App integrity check. The cryptographic proof of app & device integrity.</td>
            <td>no</td>
            <td>yes</td>
        </tr>
        <tr>
            <td colspan=5><strong>Monitoring</strong></td>
        </tr>
        <tr>
            <td>AppSec regular email reporting</td>
            <td>yes (up to 100k devices)</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Data insights and auditing portal</td>
            <td>no</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Embed code to integrate with portal</td>
            <td>no</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>API data access</td>
            <td>no</td>
            <td>yes</td>
        </tr>
         <td colspan=5><strong>Fair usage policy</strong></td>
        <tr>
            <td>Mentioning of the App name and logo in the marketing communications of Talsec (e.g. "Trusted by" section of the Talsec web or in the social media).</td>
            <td>over 100k downloads</td>
            <td>no</td>
        </tr>
        <tr>
            <td>Threat signals data collection to Talsec database for processing and product improvement</td>
            <td>yes</td>
            <td>no</td>
        </tr>
    </tbody>
</table>

For further comparison details (and planned features), follow our [discussion](https://github.com/talsec/Free-RASP-Community/discussions/5).

# About Us
Talsec is an academic-based and community-driven mobile security company. We deliver in-App Protection and a User Safety suite for Fintechs. We aim to bridge the gaps between the user's perception of app safety and the strong security requirements of the financial industry. 

Talsec offers a wide range of security solutions, such as App and API protection SDK, Penetration testing, monitoring services, and the User Safety suite. You can check out offered products at [our web](https://www.talsec.app).

# License
This project is provided as freemium software i.e. there is a fair usage policy that impose some limitations on the free usage. The SDK software consists of opensource and binary part which is property of Talsec. The opensource part is  licensed under the MIT License - see the [LICENSE](https://github.com/talsec/Free-RASP-Community/blob/master/LICENSE) file for details.
