// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/screen_capture_notifier.dart';
import 'package:freerasp_example/threat_notifier.dart';
import 'package:freerasp_example/threat_state.dart';
import 'package:freerasp_example/widgets/widgets.dart';

/// Represents current state of the threats detectable by freeRASP
final threatProvider =
    NotifierProvider.autoDispose<ThreatNotifier, ThreatState>(() {
  return ThreatNotifier();
});

final screenCaptureProvider =
    AsyncNotifierProvider.autoDispose<ScreenCaptureNotifier, bool>(() {
  return ScreenCaptureNotifier();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Talsec config
  await _initializeTalsec();

  runApp(const ProviderScope(child: App()));
}

/// Initialize Talsec configuration for Android and iOS
Future<void> _initializeTalsec() async {
  final config = TalsecConfig(
    androidConfig: AndroidConfig(
      packageName: 'com.aheaditec.freeraspExample',
      signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      supportedStores: ['com.sec.android.app.samsungapps'],
      malwareConfig: MalwareConfig(
        blacklistedPackageNames: ['com.aheaditec.freeraspExample'],
        suspiciousPermissions: [
          ['android.permission.CAMERA'],
          ['android.permission.READ_SMS', 'android.permission.READ_CONTACTS'],
        ],
      ),
    ),
    iosConfig: IOSConfig(
      bundleIds: ['com.aheaditec.freeraspExample'],
      teamId: 'M8AK35...',
    ),
    watcherMail: 'your_mail@example.com',
    isProd: true,
  );

  await Talsec.instance.start(config);
}

/// Example of how to use [Talsec.storeExternalId].
Future<void> testStoreExternalId(String data) async {
  await Talsec.instance.storeExternalId(data);
}

/// The root widget of the application
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

/// The home page that displays the threats and results
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatState = ref.watch(threatProvider);

    // Listen for changes in the threatProvider and show the malware modal
    ref.listen(threatProvider, (prev, next) {
      if (prev?.detectedMalware != next.detectedMalware) {
        _showMalwareBottomSheet(context, next.detectedMalware);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('freeRASP Demo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                'Threat Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Store External ID'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    testStoreExternalId('testData');
                  },
                ),
              ),
              ListTile(
                title: const Text('Change Screen Capture'),
                leading: SafetyIcon(
                  isDetected: !(ref.watch(screenCaptureProvider).value ?? true),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(screenCaptureProvider.notifier).toggle();
                  },
                ),
              ),
              Expanded(
                child: ThreatListView(threats: threatState.detectedThreats),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension method to show the malware bottom sheet
void _showMalwareBottomSheet(
  BuildContext context,
  List<SuspiciousAppInfo> suspiciousApps,
) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) => MalwareBottomSheet(
        suspiciousApps: suspiciousApps,
      ),
    );
  });
}
