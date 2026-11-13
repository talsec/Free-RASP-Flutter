import 'package:freerasp/src/enums/call_state.dart';
import 'package:freerasp/src/models/suspicious_app_info.dart';

/// Typedef for void methods
typedef VoidCallback = void Function();

/// Typedef for malware callback
typedef MalwareCallback = void Function(
  List<SuspiciousAppInfo> suspiciousApps,
);

/// Typedef for ongoing call callback
typedef OngoingCallCallback = void Function(CallState state);
