# freeRASP for Flutter

freeRASP for Flutter is a part of security SDK for the app shielding and security monitoring. Learn more about provided features on the [freeRASP's main repository](https://github.com/talsec/Free-RASP-Community) first. You can find freeRASP Flutter plugin on [pub.dev](https://pub.dev/packages/freerasp).

# Usage
We will guide you step-by-step, but you can always check the expected result  This is how final implementation should look like:

* [main.dart](https://github.com/talsec/Free-RASP-Flutter/blob/master/lib/main.dart)

## Step 1: Prepare Talsec library
Add dependency to your `pubspec.yaml` file  
```yaml
dependencies:
  freerasp: 1.1.0
```  
and then run: `pub get`

### iOS setup
After depending on plugin follow with these steps:
1. Open terminal 
2. Navigate to your Flutter project 
3. Switch to `ios` folder
```shell script
$ cd ios
```
4. Run: `pod install`  
```shell script
$ pod install
```
Note: `.symlinks` folder should be now visible under your `ios` folder.

5. Open `.xcworkspace/.xcodeproject` folder of Flutter project in xcode
6. Go to **Product > Scheme > Edit Scheme... > Build (dropdown arrow) > Pre-actions**
7. Hit **+** and then **New Run Script Action**
8. Set **Provide build setting from** to **Runner**
9. Use the following code to automatically use an appropriate Talsec version for a release or debug (dev) build (see an explanation [here](#dev-vs-release-version)):
```shell script
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
    3. Click twice on **Update to recommended settings** under **Pods project** issue  > **Perform changes**  
    
    Issues should be clear now.  

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

### Dev vs. Release version
Dev version is used during the development of application. It separates development and production data and disables some checks which won't be triggered during development process:

* Emulator-usage (onEmulatorDetected)
* Debugging (onDebuggerDetected)
* Signing (onTamperDetected)

Which version of freeRASP is used is tied to development stage of application - more precisely, how application is compiled.
* debug (assembleDebug) = dev version
* release (assembleRelease) = release version

## Step 2: Setup the Configuration for your App
Make (convert or create a new one) your root widget (typically one in `runApp(MyWidget())`) and override its `initState` in `State`
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
and then create a Talsec config and insert `androidConfig` and/or `IOSConfig` with highlighted identifiers: `expectedPackageName` and `expectedSigningCertificateHash` are needed for Android version.  
`expectedPackageName` - package name of your app you chose when you created it  
`expectedSigningCertificateHash` - hash of the certificate of the key which was used to sign the application. **Hash which is passed here must be encoded in Base64 form**
Similarly, `appBundleId` and `appTeamId` are needed for iOS version of app. If you publish on the Google Play Store and/or Huawei AppGallery, you **don't have to assign anything** to `supportedAlternativeStores` as those are supported out of the box.  

Lastly, pass a mail address to `watcherMail` to be able to get reports. Mail has a strict form `name@domain.com` which is passed as String.

```dart
@override
 void initState() {
    super.initState();

    TalsecConfig config = TalsecConfig(

      // For Android
      androidConfig: AndroidConfig(
        expectedPackageName: 'YOUR_PACKAGE_NAME',
        expectedSigningCertificateHash: 'HASH_OF_YOUR_APP',
        supportedAlternativeStores: ["com.sec.android.app.samsungapps"],
      ),
   
      // For iOS
      IOSConfig: IOSconfig(
        appBundleId: 'YOUR_APP_BUNDLE_ID',
        appTeamId: 'YOUR_APP_TEAM_ID',
      ),
  
      // Common email for Alerts and Reports
      watcherMail: 'john@example.com',
  );
}
```  

## Step 3: Handle detected threats
Create `AndroidCallback` and/or `IOSCallback` objects and provide `VoidCallback` function pointers to handle detected threats:

```dart
@override
void initState(){
    // Talsec config
    // ...
    
    // Callback setup
    TalsecCallback callback = TalsecCallback(

      // For Android
      androidCallback: AndroidCallback(
          onRootDetected: () => print('Root detected'),
          onEmulatorDetected: () => print('Emulator detected'),
          onHookDetected: () => print('Hook detected'),
          onTamperDetected: () => print('Tamper detected'),
          onDeviceBinding: () => print('Device binding detected'),
          onUntrustedInstallationDetected: () => print('Untrusted installation detected'),
      ),

      // For iOS
      IOSCallback: IOScallback(
        onSignatureDetected: () => print('Signature detected'),
        onRuntimeManipulationDetected: () => print('Runtime manipulation detected'),
        onJailbreakDetected: () => print('Jailbreak detected'),
        onPasscodeChangeDetected: () => print('Passcode change detected'),
        onPasscodeDetected: () => print('Passcode detected'),
        onSimulatorDetected: () => print('Simulator detected'),
        onMissingSecureEnclaveDetected: () => print('Missing secure enclave detected'),
        onDeviceChangeDetected: () => print('Device change detected'),
        onDeviceIdDetected: () => print('Device ID detected'),
      ),

      // Common for both platforms
      onDebuggerDetected: () => print("Debugger detected"),
    );
}
```
## Step 4: Start the Talsec
Start Talsec to detect threats just by adding these two lines below the created config and the callback handler:
```dart
void initState(){
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

## Step 5: User Data policy
Google Play’s User Data policy and App Store's App Privacy Details indicate that applications should inform users properly of the data that they are collecting and processing, and therefore reject the apps which do not comply with the policy. To comply with the policies, follow the manuals for given platforms: [Android](https://github.com/talsec/Free-RASP-Android#step-4-google-plays-user-data-policy), [iOS](https://github.com/talsec/Free-RASP-iOS/tree/master#step-4-app-store-user-data-policy).


And you're done 🎉!  

# Troubleshooting
### \[Android] `Cloud not find ... ` dependency issue  
**Solution:** Add dependency manually (see [issue](https://github.com/talsec/Free-RASP-Flutter/issues/1))  
In android -> app -> build.gradle add these dependencies
 ```gradle
dependencies {

  ... some other dependecies ...

    // Talsec Release
    debugImplementation 'com.aheaditec.talsec.security:TalsecSecurity-Community:3.1.0-dev'

    // Talsec Debug
    releaseImplementation 'com.aheaditec.talsec.security:TalsecSecurity-Community:3.1.0-release'
}

 ```

### \[iOS] Unable to build release for simulator in Xcode (errors)
**Solution:** Simulator does **not** support release build of Flutter - more about it [here](https://flutter.dev/docs/testing/build-modes#release).
Use real device in order to build app in release mode.
