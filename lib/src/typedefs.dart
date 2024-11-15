import 'package:freerasp/src/generated/talsec_pigeon_api.g.dart';

/// Typedef for void methods
typedef VoidCallback = void Function();

/// Typedef for malware callback
typedef MalwareCallback = void Function(List<SuspiciousAppInfo?> packageInfo);
