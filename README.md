![FreeRasp](https://raw.githubusercontent.com/talsec/Free-RASP-Community/master/visuals/freeRASP.png)

![GitHub Repo stars](https://img.shields.io/github/stars/talsec/Free-RASP-Community?color=green) ![Likes](https://img.shields.io/pub/likes/freerasp?color=green!) ![Likes](https://img.shields.io/pub/points/freerasp) ![GitHub](https://img.shields.io/github/license/talsec/Free-RASP-Community) ![GitHub](https://img.shields.io/github/last-commit/talsec/Free-RASP-Community) [![extra_pedantic on pub.dev](https://img.shields.io/badge/style-extra__pedantic-blue)](https://pub.dev/packages/extra_pedantic)
![Publisher](https://img.shields.io/pub/publisher/freerasp)
# freeRASP for Flutter

freeRASP for Flutter is a mobile in-app protection and security monitoring SDK. It aims to cover the main aspects of RASP (Runtime App Self Protection) and application shielding.

# :notebook_with_decorative_cover: Table of contents

- [Overview](#overview)
- [Usage](#usage)
    * [Prepare Talsec library](#step-1-prepare-talsec-library)
        + [iOS setup](#ios-setup)
        + [Android setup](#android-setup)
        + [Dev vs Release version](#dev-vs-release-version)
    * [Setup the configuration](#step-2-setup-the-configuration-for-your-app)
    * [Handle detected threats](#step-3-handle-detected-threats)
- [Troubleshooting](#troubleshooting)
- [Security Report](#security-report)
- [Enterprise Services](#enterprise-services)
    * [Plans comparison](#plans-comparison)

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

## Step 1: Prepare Talsec library

Add dependency to your `pubspec.yaml` file

```yaml
dependencies:
  freerasp: 3.0.2
```

and run `pub get`

### iOS setup

After depending on plugin, follow with these steps:

1. Open terminal
2. Navigate to your Flutter project
3. Switch to `ios` folder

```shell
$ cd ios
```

4. Run: `pod install`

```shell
$ pod install
```

Note: `.symlinks` folder should now be visible under your `ios` folder.

5. Open `.xcworkspace/.xcodeproject` folder of Flutter project in xcode
6. Go to **Product > Scheme > Edit Scheme... > Build (dropdown arrow) > Pre-actions**
7. Hit **+** and then **New Run Script Action**
8. Set **Provide build setting from** to **Runner**
9. Use the following code to automatically use an appropriate Talsec version for a release or debug (dev) build (see an explanation [here](#dev-vs-release-version)):

```shell
cd "${SRCROOT}/.symlinks/plugins/freerasp/ios"
if [ "${CONFIGURATION}" = "Release" ]; then
    rm -rf ./TalsecRuntime.xcframework
    ln -s ./Release/TalsecRuntime.xcframework/ TalsecRuntime.xcframework
else
    rm -rf ./TalsecRuntime.xcframework
    ln -s ./Debug/TalsecRuntime.xcframework/ TalsecRuntime.xcframework
fi
```
10. Close the terminal window and then resolve warnings in the xcode project:

    1. Go to **Show the Issue navigator**
    2. Click twice on **Update to recommended settings** under **Runner project** issue > **Perform changes**
    3. Click twice on **Update to recommended settings** under **Pods project** issue > **Perform changes**

    Issues should be clear now.

11.  Check if the `ios/.symlinks/plugins/freerasp/ios` contains `TalsecRuntime.xcframework` symlink. If not, create it manually in that folder using the following command.
```shell
ln -s ./Debug/TalsecRuntime.xcframework/ TalsecRuntime.xcframework
```

If there is no .symlinks folder, create the symlink in the `freerasp/ios` folder.

12.  Run **pod install** in the application ios folder.

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

### Dev vs Release version
The Dev version is used to not complicate the development process of the application, e.g. if you would implement killing of the application on the debugger callback. It disables some checks which won't be triggered during the development process:

* Emulator-usage (onEmulatorDetected, onSimulatorDetected)
* Debugging (onDebuggerDetected)
* Signing (onTamperDetected, onSignatureDetected)
* Unofficial store (onUntrustedInstallationDetected, onUnofficialStoreDetected)

Which version of freeRASP is used is tied to the application's development stage - more precisely, how the application is compiled.

* debug (assembleDebug) = dev version
* release (assembleRelease) = release version

## Step 2: Setup the Configuration for your App

Adding imports to the top of file, where you want to use Talsec:
```dart
import 'package:freerasp/talsec_app.dart';
```

Make (convert or create a new one) your root widget (typically one in `runApp(MyWidget())`) and override its `initState` in `State`

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    //TODO: freeRASP implementation
  }
}
```

and then create a Talsec config and insert `AndroidConfig` and/or `IOSConfig` with highlighted identifiers: `expectedPackageName` and `expectedSigningCertificateHash` are needed for Android version.
* `expectedPackageName` - package name of your app you chose when you created it
* `expectedSigningCertificateHash` - hash of the certificate of the key which was used to sign the application. **Hash which is passed here must be encoded in Base64 form**

We provide a handy util tool to help you convert your SHA-256 hash to Base64:


```dart
// Signing hash of your app
String base64Hash = hashConverter.fromSha256toBase64(sha256HashHex);
```

We strongly recommend providing **result value** of this tool as expectedSigningCertificateHash.

**Do not use this tool directly** in `expectedSigningCertificateHash` to get value.

If you are not sure how to get your hash certificate, you can check out the guide on our [Github wiki](https://github.com/talsec/Free-RASP-Community/wiki/Getting-your-signing-certificate-hash-of-app).

Similarly, `appBundleId` and `appTeamId` are needed for iOS version of app. If you publish on the Google Play Store and/or Huawei AppGallery, you **don't have to assign anything** to `supportedAlternativeStores` as those are supported out of the box.

Lastly, pass a mail address to `watcherMail` to be able to get reports. Mail has a strict form `name@domain.com` which is passed as String.

If you are developing only for one of the platforms, you can leave the configuration part for the other one, i.e., delete the other congifuration.

```dart
@override
void initState() {
  super.initState();
  initSecurityState();
}

Future<void> initSecurityState() async {
  TalsecConfig config = TalsecConfig(

    // For Android
    androidConfig: AndroidConfig(
      expectedPackageName: 'YOUR_PACKAGE_NAME',
      expectedSigningCertificateHash: 'HASH_OF_YOUR_APP',
      supportedAlternativeStores: ["com.sec.android.app.samsungapps"],
    ),

    // For iOS
    iosConfig: IOSconfig(
      appBundleId: 'YOUR_APP_BUNDLE_ID',
      appTeamId: 'YOUR_APP_TEAM_ID',
    ),

    // Common email for Alerts and Reports
    watcherMail: 'your_mail@example.com',
  );
}
```

## Step 3: Handle detected threats

Create `AndroidCallback` and/or `IOSCallback` objects and provide `VoidCallback` function pointers to handle detected threats. If you are developing only for one of the platforms, you can leave the callback definition for the other one, i.e., delete the other callback definition.

You can provide a function (or an anonymous function like in this example) to tell Talsec what to do. If you decide to kill the application from the  callback, make sure that you use an appropriate way of killing it (see the [link](https://stackoverflow.com/questions/45109557/flutter-how-to-programmatically-exit-the-app)).

```dart
@override
void initState() {
  // Talsec config
  // ...

  // Talsec callback handler
  TalsecCallback callback = TalsecCallback(
  // For Android
  androidCallback: AndroidCallback(
    onRootDetected: () => print('root'),
    onEmulatorDetected: () => print('emulator'),
    onHookDetected: () => print('hook'),
    onTamperDetected: () => print('tamper'),
    onDeviceBindingDetected: () => print('device binding'),
    onUntrustedInstallationDetected: () => print('untrusted install'),
  ),
  // For iOS
  iosCallback: IOSCallback(
      onSignatureDetected: () => print('signature'),
      onRuntimeManipulationDetected: () => print('runtime manipulation'),
      onJailbreakDetected: () => print('jailbreak'),
      onPasscodeDetected: () => print('passcode'),
      onSimulatorDetected: () => print('simulator'),
      onMissingSecureEnclaveDetected: () => print('secure enclave'),
      onDeviceChangeDetected: () => print('device change'),
      onDeviceIdDetected: () => print('device ID'),
      onUnofficialStoreDetected: () => print('unofficial store')),
  // Common for both platforms
  onDebuggerDetected: () => print('debugger'),
  );
}
```

Visit our [wiki](https://github.com/talsec/Free-RASP-Community/wiki/Threat-detection) to learn more details about the performed checks and their importance for app security.

## Step 4: Start the Talsec

Start Talsec to detect threats just by adding these two lines below the created config and the callback handler:

```dart
void initState() {
  // Talsec config
  // ...
  // Talsec callback handler
  // ...

  TalsecApp app = TalsecApp(
    config: config,
    callback: callback,
  );

  app.start();
}
```

If you are initializing Talsec from the main() function before runApp(), make sure that you place the following before initialization of the Talsec:
```dart
WidgetsFlutterBinding.ensureInitialized();
```

## Step 5: User Data Policies

Google Play [requires](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) all app publishers to declare how they collect and handle user data for the apps they publish on Google Play. They should inform users properly of the data collected by the apps and how the data is shared and processed. Therefore, Google will reject the apps which do not comply with the policy.

Apple has a [similar approach](https://developer.apple.com/app-store/app-privacy-details/) and specifies the types of collected data.

You should also visit our [Android](https://github.com/talsec/Free-RASP-Android/tree/4dd5a41b33244c979de79bb3e16f9ccf167a948d) and [iOS](https://github.com/talsec/Free-RASP-iOS/tree/78dc848ef66c09438e338780ff46dda40efae331) submodules to learn more about their respective data policies.

And you're done 🎉!

# Troubleshooting

### \[Android] `Could not find ... ` dependency issue

**Solution:** Add dependency manually (see [issue](https://github.com/talsec/Free-RASP-Flutter/issues/1)).

In android -> app -> build.gradle add these dependencies

```gradle
dependencies {

 ... some other dependecies ...

   // Talsec Release
   releaseImplementation 'com.aheaditec.talsec.security:TalsecSecurity-Community-Flutter:*-release'

   // Talsec Debug
   implementation 'com.aheaditec.talsec.security:TalsecSecurity-Community-Flutter:*-dev'
}
```

### \[iOS] Unable to build release for simulator in Xcode (errors)

**Solution:** Simulator does **not** support release build of Flutter - more about it [here](https://flutter.dev/docs/testing/build-modes#release). Use a real device in order to build the app in release mode.

### \[iOS] MissingPluginException occurs on hot restart

**Solution:** Technical limitation of Flutter - more about it [here](https://stackoverflow.com/questions/50459272/missingpluginexception-while-using-plugin-for-flutter). Use command `flutter run` to launch app (i.e. run app from scratch).

### \[Android] Code throws `java.lang.UnsatisfiedLinkError: No implementation found for...` exception when building APK

**Solution:** Android version of freeRASP is already obfuscated.

Add this rule to your `proguard-rules.pro` file:

```
-keepclasseswithmembernames,includedescriptorclasses class * {
native *;
}
```

If you encounter any other issues, you can see the list of solved issues [here](https://github.com/talsec/Free-RASP-Flutter/issues?q=is%3Aissue+is%3Aclosed), or open up a [new one](https://github.com/talsec/Free-RASP-Flutter/issues?q=is%3Aopen+is%3Aissue).

# Security Report

The Security Report is a weekly summary describing the application's security state and characteristics of the devices it runs on in a practical and easy-to-understand way.

The report provides a quick overview of the security incidents, their dynamics, app integrity, and reverse engineering attempts. It contains info about the security of devices, such as OS version or the ratio of devices with screen locks and biometrics. Each visualization also comes with a concise explanation.

To receive Security Reports, fill out the _watcherMail_ field in [Talsec config](#step-2-setup-the-configuration-for-your-app).

![enter image description here](https://raw.githubusercontent.com/talsec/Free-RASP-Community/master/visuals/dashboard.png)

# Enterprise Services

We provide extended services (AppiCrypt, Hardening, Secure Storage, and Certificate Pinning) to our commercial customers as well. To get the most advanced protection compliant with PSD2 RT and eIDAS and support from our experts, contact us at [talsec.app](https://talsec.app).

**TIP:** You can try freeRASP and then upgrade easily to an enterprise service.

## Plans Comparison

<table>
    <thead>
        <tr>
            <th></th>
            <th>freeRASP</th>
            <th>Business</th>
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
                    <li>Hooking protections</li>
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
                </ul>
            </td>
            <td>basic</td>
            <td>advanced</td>
        </tr>
        <tr>
            <td>Device OS security status check 
                <ul>
                    <li>HW security module control</li>
                    <li>Device lock control</li>
                    <li>Device lock change control</li>
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
                    <li>Dynamic certificate pinning</li>
                    <li>Obfuscation</li>
                    <li>Secure storage hardening</li>
                    <li>Secure pinpad</li>
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
    </tbody>
</table>
