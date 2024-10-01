// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/extensions.dart';
import 'package:freerasp_example/safety_icon.dart';
import 'package:freerasp_example/threat_notifier.dart';
import 'package:freerasp_example/threat_state.dart';

/// Represents current state of the threats detectable by freeRASP
final threatProvider =
    NotifierProvider.autoDispose<ThreatNotifier, ThreatState>(() {
  return ThreatNotifier();
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
      blocklistedPackageNames: ['com.aheaditec.freeraspExample'],
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
              Expanded(
                child: _ThreatListView(threatState: threatState),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ListView displaying all detected threats
class _ThreatListView extends StatelessWidget {
  const _ThreatListView({required this.threatState});

  final ThreatState threatState;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: Threat.values.length,
      itemBuilder: (context, index) {
        final currentThreat = Threat.values[index];
        final isDetected = threatState.detectedThreats.contains(currentThreat);

        return ListTile(
          title: Text(currentThreat.name.toTitleCase()),
          subtitle: Text(isDetected ? 'Danger' : 'Safe'),
          trailing: SafetyIcon(isDetected: isDetected),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}

/// Bottom sheet widget that displays malware information
class MalwareBottomSheet extends StatelessWidget {
  const MalwareBottomSheet({super.key, required this.suspiciousApps});

  final List<SuspiciousAppInfo> suspiciousApps;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Suspicious Apps', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          ...suspiciousApps.map((malware) {
            return ListTile(
              title: Text(malware.packageInfo.packageName),
              subtitle: Text('Reason: ${malware.reason}'),
              leading: const Icon(Icons.warning, color: Colors.red),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ),
        ],
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
      builder: (BuildContext context) =>
          MalwareBottomSheet(suspiciousApps: suspiciousApps),
    );
  });
}
