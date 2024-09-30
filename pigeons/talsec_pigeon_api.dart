import 'package:pigeon/pigeon.dart';

// ignore: flutter_style_todos
// TODO: Migrate whole Talsec API to pigeon
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/talsec_pigeon_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/aheaditec/freerasp/generated/TalsecPigeonApi.kt',
    input: 'pigeons/talsec_pigeon_api.dart',
    kotlinOptions: KotlinOptions(package: 'com.aheaditec.talsec.generated'),
  ),
)
class PackageInfo {
  const PackageInfo({
    required this.packageName,
    this.appIcon,
    this.version,
    this.appName,
    this.installationSource,
  });

  final String packageName;
  final String? appIcon;
  final String? appName;
  final String? version;
  final String? installationSource;
}

class SuspiciousAppInfo {
  const SuspiciousAppInfo({
    required this.packageInfo,
    required this.reason,
  });

  final PackageInfo packageInfo;
  final String reason;
}

@FlutterApi()
// ignore: one_member_abstracts
abstract class TalsecPigeonApi {
  void onMalwareDetected(List<SuspiciousAppInfo> packageInfo);
}
