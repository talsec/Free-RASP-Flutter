import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';

/// Minimal freeRASP setup for pub.dev Example tab.
///
/// The full runnable demo app lives under `example/lib/` in the repository
/// and is not published with the package.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = TalsecConfig(
    androidConfig: AndroidConfig(
      packageName: 'com.aheaditec.freeraspExample',
      signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      supportedStores: ['com.sec.android.app.samsungapps'],
    ),
    iosConfig: IOSConfig(
      bundleIds: ['com.aheaditec.freeraspExample'],
      teamId: 'M8AK35...',
    ),
    watcherMail: 'your_mail@example.com',
    isProd: true,
  );

  await Talsec.instance.start(config);

  Talsec.instance.attachListener(
    ThreatCallback(
      onHooks: () => debugPrint('Hooking framework detected'),
      onDebug: () => debugPrint('Debugger detected'),
      onPrivilegedAccess: () => debugPrint('Root/Jailbreak detected'),
      onSimulator: () => debugPrint('Emulator/Simulator detected'),
    ),
  );

  runApp(
      const MaterialApp(home: Scaffold(body: Center(child: Text('freeRASP')))));
}
