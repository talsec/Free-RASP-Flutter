# freeRASP for Flutter

freeRASP for Flutter is a part of security SDK for the app shielding and security monitoring. 
Learn more about provided features on the [freeRASP's main repository](https://github.com/talsec/Free-RASP-Community) first.

# Usage
We will guide you step-by-step, but you can always check the expected result in example.

## Step 1: Prepare Talsec library
Add dependency to your `pubspec.yaml` file  
```yaml
dependencies:
  freerasp: 2.0.0
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
and then create a Talsec config and insert `androidConfig` and/or `IOSConfig` with highlighted identifiers: `expectedPackageName` and `expectedSigningCertificateHash` are needed for Android version.  
`expectedPackageName` - package name of your app you chose when you created it  
`expectedSigningCertificateHash` - hash of the certificate of the key which was used to sign the application. **Hash which is passed here must be encoded in Base64 form**
Similarly, `appBundleId` and `appTeamId` are needed for iOS version of app. If you publish on the Google Play Store and/or Huawei AppGallery, you **don't have to assign anything** to `supportedAlternativeStores` as those are supported out of the box.  

Lastly, pass a mail address to `watcherMail` to be able to get reports. Mail has a strict form `name@domain.com` which is passed as String.

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
And you're done 🎉!  

# Enterprise Services
We provide extended services (ie. malware detection, detailed configurable threat reactions, immediate alerts and penetration testing) to our commercial customers with a self-hosted cloud platform as well. To get the most advanced protection compliant with PSD2 RT and eIDAS and support from our experts contact us at https://talsec.app.

**TIP:** You can try freeRASP and then upgrade easily to an enterprise service.

## Plans Comparison
<table>
    <thead>
        <tr>
            <th></th>
            <th>freeRASP</th>
            <th>Premium</th>
            <th>Business</th>
            <th>Enterprise</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Number of active devices </td>
            <td>unlimitted (monitoring up to 100k)</td>
            <td>up to 10&nbsp;000k </td>
            <td>unlimitted</td>
            <td>unlimitted</td>
        </tr>
        <tr>
            <td colspan=5><strong>Runtime App Self Protection (RASP, app shielding)</strong></td>
        </tr>
        <tr>
            <td>Advanced root/jailbreak protections</td>
            <td>basic</td>
            <td>standard</td>
            <td>advanced</td>
            <td>custom</td>
        </tr>
        <tr>
            <td>Runtime reverse engineering controls</br> 
                <ul>
                    <li>Debug</li>
                    <li>Emulator</li>
                    <li>Hooking protections</li>
                </ul>
            </td>
            <td>basic</td>
            <td>standard</td>
            <td>advanced</td>
            <td>custom</td>
        </tr>
        <tr>
            <td>Runtime integrity controls</br> 
                <ul>
                    <li>Tamper protection</li>
                    <li>Repackaging / Cloning protection</li>
                    <li>Device binding protection</li>
                </ul>
            </td>
            <td>basic</td>
            <td>standard</td>
            <td>advanced</td>
            <td>custom</td>
        </tr>
        <tr>
            <td>Device OS security status check</br> 
                <ul>
                    <li>HW security module control</li>
                    <li>Device lock control</li>
                    <li>Device lock change control</li>
                </ul>
            </td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
            <td>custom</td>
        </tr>
        <tr>
            <td>UI protection</br> 
                <ul>
                    <li>Overlay protection</li>
                    <li>Accessibility services protection</li>
                </ul>
            </td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
            <td>custom</td>
        </tr>
        <tr>
            <td colspan=5><strong>Hardening suite</strong></td>
        </tr>
        <tr>
            <td>Security hardening suite</br> 
                <ul>
                    <li>Dynamic certificate pinning</li>
                    <li>Obfuscation</li>
                    <li>Secure storage hardening</li>
                    <li>Secure pinpad</li>
                </ul>
            </td>
            <td>no</td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td colspan=5><strong>Attestation and API protection</strong></td>
        </tr>
        <tr>
            <td>Device attestation and dynamic API protection</td>
            <td>no</td>
            <td>no</td>
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
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Data insights and auditing portal</td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Embed code to integrate with portal</td>
            <td>no</td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>API data access</td>
            <td>no</td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Data retention</td>
            <td>1 month</td>
            <td>1 month</td>
            <td>1 year</td>
            <td>custom</td>
        </tr>
        <tr>
            <td colspan=5><strong>Malware detection</strong></td>
        </tr>
        <tr>
            <td>SDK for Malware detection and backend monitoring</td>
            <td>no</td>
            <td>optional</td>
            <td>optional</td>
            <td>optional</td>
        </tr>
        <tr>
            <td colspan=5><strong>User Safety suite</strong></td>
        </tr>
        <tr>
            <td>SDK API for Safety Dashboard for end-users</td>
            <td>min</td>
            <td>min</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>User Safety Assurance service (Improvement plan report, Top10 tips, hot attacks info)</td>
            <td>no</td>
            <td>no</td>
            <td>basic</td>
            <td>custom</td>
        </tr>
        <tr>
            <td colspan=5><strong>Deployment</strong></td>
        </tr>
        <tr>
            <td>Individual unique SDK build</td>
            <td>no</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Private cloud cluster</td>
            <td>no</td>
            <td>no</td>
            <td>no</td>
            <td>custom</td>
        </tr>
        <tr>
            <td colspan=5><strong>Platforms</strong></td>
        </tr>
        <tr>
            <td>Native (iOS and Android)</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
            <td>yes</td>
        </tr>
        <tr>
            <td>Flutter (multiplatform)</td>
            <td>yes</td>
            <td>yes</td>
            <td>custom</td>
            <td>custom</td>
        </tr>
    </tbody>
</table>

# Troubleshooting
### \[Android] `Cloud not find ... ` dependency issue  
**Solution:** Add dependency manually (see [issue](https://github.com/talsec/Free-RASP-Flutter/issues/1))  
In android -> app -> build.gradle add these dependencies
 ```gradle
dependencies {

  ... some other dependecies ...

    // Talsec Release
    releaseImplementation 'com.aheaditec.talsec.security:TalsecSecurity-Community-Flutter:*-release'

    // Talsec Debug
    debugImplementation 'com.aheaditec.talsec.security:TalsecSecurity-Community-Flutter:*-dev'
}

 ```

### \[iOS] Unable to build release for simulator in Xcode (errors)
**Solution:** Simulator does **not** support release build of Flutter - more about it [here](https://flutter.dev/docs/testing/build-modes#release).
Use real device in order to build app in release mode.
