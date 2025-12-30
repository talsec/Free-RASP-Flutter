import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/models/security_check.dart';

/// State class for security checks managed by Riverpod.
class SecurityState {

  /// Creates an initial state with all checks initialized.
  factory SecurityState.initial(List<SecurityCheck> checks) {
    return SecurityState(checks: checks);
  }
  /// Creates a [SecurityState].
  SecurityState({
    required this.checks,
    this.detectedMalware = const [],
  });

  /// List of all security checks.
  final List<SecurityCheck> checks;

  /// List of detected suspicious apps.
  final List<SuspiciousAppInfo> detectedMalware;

  /// Creates a copy of this state with updated checks.
  SecurityState copyWith({
    List<SecurityCheck>? checks,
    List<SuspiciousAppInfo>? detectedMalware,
  }) {
    return SecurityState(
      checks: checks ?? this.checks,
      detectedMalware: detectedMalware ?? this.detectedMalware,
    );
  }

  /// Groups checks by category.
  Map<ThreatCategory, List<SecurityCheck>> get checksByCategory {
    final map = <ThreatCategory, List<SecurityCheck>>{};
    for (final check in checks) {
      map.putIfAbsent(check.category, () => []).add(check);
    }
    return map;
  }

  /// Returns true if all checks are secure.
  bool get isAllSecure {
    return checks.every((check) => check.isSecure);
  }

  /// Returns true if any malware is detected.
  bool get hasMalware {
    return detectedMalware.isNotEmpty;
  }
}
