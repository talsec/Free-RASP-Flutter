import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freerasp/talsec_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({final Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Strings to hold current state (Android)
  final String _rootState = 'Secured';
  final String _emulatorState = 'Secured';
  final String _tamperState = 'Secured';
  final String _hookState = 'Secured';
  final String _untrustedInstallationSourceState = 'Secured';
  final String _deviceBindingState = 'Secured';

  /// Strings to hold current state (iOS)
  final String _signatureState = 'Secured';
  final String _jailbreakState = 'Secured';
  final String _runtimeManipulationState = 'Secured';
  final String _passcodeState = 'Secured';
  final String _simulatorState = 'Secured';
  final String _missingSecureEnclaveState = 'Secured';
  final String _deviceChangeState = 'Secured';
  final String _deviceIdState = 'Secured';
  final String _unofficialStoreState = 'Secured';

  /// String to hold current state (common)
  final String _debuggerState = 'Secured';

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
      Text('Simulator: $_simulatorState\n'),
      Text('Missing secure enclave: $_missingSecureEnclaveState\n'),
      Text('Device change: $_deviceChangeState\n'),
      Text('Device ID: $_deviceIdState\n'),
      Text('Unofficial Store: $_unofficialStoreState\n')
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
    final TalsecConfig config = TalsecConfig(
      /// For Android
      androidConfig: AndroidConfig(
        expectedPackageName: 'com.aheaditec.freeraspExample',
        expectedSigningCertificateHash: 'ek124Mj...',
        supportedAlternativeStores: ["com.sec.android.app.samsungapps"],
      ),

      /// For iOS
      iosConfig: const IOSconfig(
        appBundleId: 'com.aheaditec.freeraspExample',
        appTeamId: 'M8AK35...',
      ),

      watcherMail: 'your_mail@example.com',
    );

    /// Callbacks thrown by library
    final TalsecCallback callback = TalsecCallback(
      /// For Android
      androidCallback: AndroidCallback(
        onRootDetected: () => _updateState(_rootState),
        onEmulatorDetected: () => _updateState(_emulatorState),
        onHookDetected: () => _updateState(_hookState),
        onTamperDetected: () => _updateState(_tamperState),
        onDeviceBindingDetected: () => _updateState(_deviceBindingState),
        onUntrustedInstallationDetected: () =>
            _updateState(_untrustedInstallationSourceState),
      ),

      /// For iOS
      iosCallback: IOSCallback(
        onSignatureDetected: () => _updateState(_signatureState),
        onRuntimeManipulationDetected: () =>
            _updateState(_runtimeManipulationState),
        onJailbreakDetected: () => _updateState(_jailbreakState),
        onPasscodeDetected: () => _updateState(_passcodeState),
        onSimulatorDetected: () => _updateState(_simulatorState),
        onMissingSecureEnclaveDetected: () =>
            _updateState(_missingSecureEnclaveState),
        onDeviceChangeDetected: () => _updateState(_deviceChangeState),
        onDeviceIdDetected: () => _updateState(_deviceIdState),
        onUnofficialStoreDetected: () => _updateState(_unofficialStoreState),
      ),

      /// Debugger is common for both platforms
      onDebuggerDetected: () => _updateState(_debuggerState),
    );

    final TalsecApp app = TalsecApp(
      config: config,
      callback: callback,
    );

    /// Turn on freeRASP
    app.start();

    if (!mounted) return;
  }

  void _updateState(String state) {
    setState(() {
      // ignore: parameter_assignments
      state = 'Detected';
    });
  }

  @override
  Widget build(final BuildContext context) {
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
