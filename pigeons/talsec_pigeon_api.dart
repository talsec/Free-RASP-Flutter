import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/talsec_pigeon_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/aheaditec/freerasp/generated/TalsecPigeonApi.kt',
    input: 'pigeons/talsec_pigeon_api.dart',
    kotlinOptions: KotlinOptions(package: 'com.aheaditec.freerasp.generated'),
  ),
)
class PackageInfo {
  const PackageInfo({
    required this.packageName,
    this.appIcon,
    this.version,
    this.appName,
    this.installerStore,
  });

  final String packageName;
  final String? appIcon;
  final String? appName;
  final String? version;
  final String? installerStore;
}

class SuspiciousAppInfo {
  const SuspiciousAppInfo({
    required this.packageInfo,
    required this.reasons,
    this.permissions,
  });

  final PackageInfo packageInfo;
  final List<String> reasons;
  final List<String>? permissions;
}

/// State of an ongoing call reported by the ongoing call detection.
enum CallState {
  /// A call started while the detection was running.
  started,

  /// A call was already in progress when the detection started.
  ongoing,

  /// A previously reported call has ended.
  stopped,
}

@FlutterApi()
// Migrate whole Talsec API to pigeon
abstract class TalsecPigeonApi {
  void onMalwareDetected(List<SuspiciousAppInfo> packageInfo);

  void onOngoingCallDetected(CallState state);
}
