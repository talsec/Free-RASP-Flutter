import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freerasp/talsec_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Strings to hold current state (Android)
  String _rootState = 'Secured';
  String _emulatorState = 'Secured';
  String _tamperState = 'Secured';
  String _hookState = 'Secured';
  String _untrustedInstallationSourceState = 'Secured';
  String _deviceBindingState = 'Secured';

  /// Strings to hold current state (iOS)
  String _signatureState = 'Secured';
  String _jailbreakState = 'Secured';
  String _runtimeManipulationState = 'Secured';
  String _passcodeState = 'Secured';
  String _passcodeChangeState = 'Secured';
  String _simulatorState = 'Secured';
  String _missingSecureEnclaveState = 'Secured';
  String _deviceChangeState = 'Secured';
  String _deviceIdDetectedState = 'Secured';

  /// String to hold current state (common)
  String _debuggerState = 'Secured';

  /// Getter to determine which states we care about
  List<Widget> get overview {
    if (Platform.isAndroid) {
      return [
        Text('Root: $_rootState\n'),
        Text('Debugger: $_debuggerState\n'),
        Text('Emulator: $_emulatorState\n'),
        Text('Tamper: $_tamperState\n'),
        Text('Hook: $_hookState\n'),
        Text('Device binding: $_deviceBindingState\n'),
        Text(
            'Untrusted source of installation: $_untrustedInstallationSourceState\n'),
      ];
    }
    return [
      Text('Signature: $_signatureState\n'),
      Text('Jailbreak: $_jailbreakState\n'),
      Text('Debugger: $_debuggerState\n'),
      Text('Runtime Manipulation: $_runtimeManipulationState\n'),
      Text('Passcode: $_passcodeState\n'),
      Text('Passcode change: $_passcodeChangeState\n'),
      Text('Simulator: $_simulatorState\n'),
      Text('Missing secure enclave: $_missingSecureEnclaveState\n'),
      Text('Device change: $_deviceChangeState\n'),
      Text('Device ID: $_deviceIdDetectedState\n')
    ];
  }

  /// Override initState of the "highest" widget in order to start freeRASP
  /// as soon as possible.
  @override
  void initState() {
    super.initState();
    initSecurityState();
  }

  Future<void> initSecurityState() async {
    /// Provide TalsecConfig your expected data and then use them in TalsecApp
    TalsecConfig config = TalsecConfig(
      /// For Android
      androidConfig: AndroidConfig(
        expectedPackageName: 'YOUR_PACKAGE_NAME',
        expectedSigningCertificateHash: 'HASH_OF_YOUR_APP',
        supportedAlternativeStores: ["com.sec.android.app.samsungapps"],
      ),

      /// For iOS
      iosConfig: IOSconfig(
        appBundleId: 'YOUR_APP_BUNDLE_ID',
        appTeamId: 'YOUR_APP_TEAM_ID',
      ),

      watcherMail: 'your_mail@example.com',
    );

    /// Callbacks thrown by library
    TalsecCallback callback = TalsecCallback(
      /// For Android
      androidCallback: AndroidCallback(onRootDetected: () {
        setState(() {
          _rootState = 'Detected';
        });
      }, onEmulatorDetected: () {
        setState(() {
          _emulatorState = 'Detected';
        });
      }, onHookDetected: () {
        setState(() {
          _hookState = 'Detected';
        });
      }, onTamperDetected: () {
        setState(() {
          _tamperState = 'Detected';
        });
      }, onDeviceBindingDetected: () {
        setState(() {
          _deviceBindingState = 'Detected';
        });
      }, onUntrustedInstallationDetected: () {
        setState(
          () {
            _untrustedInstallationSourceState = 'Detected';
          },
        );
      }),

      /// For iOS
      iosCallback: IOScallback(onSignatureDetected: () {
        setState(() {
          _signatureState = 'Detected';
        });
      }, onRuntimeManipulationDetected: () {
        setState(() {
          _runtimeManipulationState = 'Detected';
        });
      }, onJailbreakDetected: () {
        setState(() {
          _jailbreakState = 'Detected';
        });
      }, onPasscodeChangeDetected: () {
        setState(() {
          _passcodeChangeState = 'Detected';
        });
      }, onPasscodeDetected: () {
        setState(() {
          _passcodeState = 'Detected';
        });
      }, onSimulatorDetected: () {
        setState(() {
          _simulatorState = 'Detected';
        });
      }, onMissingSecureEnclaveDetected: () {
        setState(() {
          _missingSecureEnclaveState = 'Detected';
        });
      }, onDeviceChangeDetected: () {
        setState(() {
          _deviceChangeState = 'Detected';
        });
      }, onDeviceIdDetected: () {
        setState(() {
          _deviceIdDetectedState = 'Detected';
        });
      }),

      /// Debugger is common for both platforms
      onDebuggerDetected: () {
        setState(() {
          _debuggerState = 'Detected';
        });
      },
    );

    TalsecApp app = TalsecApp(
      config: config,
      callback: callback,
    );

    /// Turn on freeRASP
    app.start();

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: overview,
          ),
        ),
      ),
    );
  }
}