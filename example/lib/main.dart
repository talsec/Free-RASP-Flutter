import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/safety_icon.dart';
import 'package:freerasp_example/threat_notifier.dart';

/// Represents current state of the threats detectable by freeRASP
final threatProvider = StateNotifierProvider<ThreatNotifier, Map<Threat, bool>>(
  (ref) => ThreatNotifier(),
);

void main() async {
  /// Make sure that bindings are initialized before using Talsec.
  WidgetsFlutterBinding.ensureInitialized();

  final config = TalsecConfig(
    /// For Android
    androidConfig: AndroidConfig(
      packageName: 'com.aheaditec.freeraspExample',
      signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      supportedStores: ['com.sec.android.app.samsungapps'],
      blocklistedPackageNames: ['com.aheaditec.freeraspExample'],
    ),

    /// For iOS
    iosConfig: IOSConfig(
      bundleIds: ['com.aheaditec.freeraspExample'],
      teamId: 'M8AK35...',
    ),
    watcherMail: 'your_mail@example.com',
    // ignore: avoid_redundant_argument_values
    isProd: true, // use kReleaseMode for automatic switch
  );

  /// freeRASP should be always initialized in the top-level widget
  await Talsec.instance.start(config);

  /// Another way to handle [Threat] is to use Stream.
  /// ```dart
  /// final subscription = Talsec.instance.onThreatDetected.listen((threat) {
  ///   log('Threat detected: $threat');
  /// });
  /// ```
  runApp(const ProviderScope(child: App()));
}

/// The example app demonstrating usage of freeRASP
class App extends StatelessWidget {
  /// The root widget of the application.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('freeRASP Demo'),
        ),
        body: const SafeArea(
          child: Center(
            child: HomePage(),
          ),
        ),
      ),
    );
  }
}

/// Displays the main content of the application.
class HomePage extends ConsumerWidget {
  /// The constructor for the [HomePage] widget.
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threatMap = ref.watch(threatProvider);
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Test results',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: threatMap.length,
            itemBuilder: (context, index) {
              /// Using Provider to get app state.
              final currentThreat = threatMap.keys.elementAt(index);
              final isDetected = threatMap[currentThreat]!;
              return ListTile(
                // ignore: sdk_version_since
                title: Text(currentThreat.name),
                subtitle: Text(isDetected ? 'Danger' : 'Safe'),
                trailing: SafetyIcon(isDetected: isDetected),
              );
            },
            separatorBuilder: (_, __) {
              return const Divider(
                height: 0,
              );
            },
          ),
        ),
      ],
    );
  }
}
