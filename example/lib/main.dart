// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/screen_capture_notifier.dart';
import 'package:freerasp_example/threat_notifier.dart';
import 'package:freerasp_example/threat_state.dart';
import 'package:freerasp_example/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

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

  await Permission.locationWhenInUse.request();

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
    killOnBypass: true,
  );

  await Talsec.instance.start(config);
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
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TextEditingController _externalIdController;

  @override
  void initState() {
    super.initState();
    _externalIdController = TextEditingController();
  }

  @override
  void dispose() {
    _externalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              ExpansionTile(
                title: const Text('Change External ID'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _externalIdController,
                      decoration: const InputDecoration(
                        labelText: 'External ID',
                        hintText: 'Enter external ID here',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final id = _externalIdController.text;
                          if (id.isNotEmpty) {
                            Talsec.instance.storeExternalId(id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Stored External ID: $id'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an External ID'),
                              ),
                            );
                          }
                        },
                        child: const Text('Store External ID'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Talsec.instance.removeExternalId();
                          _externalIdController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed External ID'),
                            ),
                          );
                        },
                        child: const Text('Remove External ID'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Screen Capture',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(screenCaptureProvider.notifier).toggle(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (ref.watch(screenCaptureProvider).value ?? false)
                                ? Colors.green
                                : Colors.red,
                      ),
                      child: Text(
                        (ref.watch(screenCaptureProvider).value ?? false)
                            ? 'Protected'
                            : 'Unprotected',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Check Rounds Completed'),
                trailing: SafetyIcon(isDetected: !threatState.allChecksPassed),
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
