import 'package:freerasp/freerasp.dart';

/// Categories of threats.
enum ThreatCategory {
  /// Threats related to the application's integrity and source.
  appIntegrity,

  /// Threats related to the device's environment and security settings.
  deviceSecurity,

  /// Threats related to user actions or runtime events.
  runtimeStatus,
}

/// Represents a security check with metadata.
class SecurityCheck {
  /// Creates a [SecurityCheck].
  SecurityCheck({
    required this.threat,
    required this.name,
    required this.secureDescription,
    required this.insecureDescription,
    required this.category,
    this.isSecure = true,
  });

  /// The specific threat being checked.
  final Threat threat;

  /// Human-readable name of the threat.
  final String name;

  /// Description shown when the check is secure.
  final String secureDescription;

  /// Description shown when the check is insecure.
  final String insecureDescription;

  /// The category this threat belongs to.
  final ThreatCategory category;

  /// Whether the check is currently passing (secure).
  bool isSecure;

  /// Returns the appropriate description based on security status.
  String get description => isSecure ? secureDescription : insecureDescription;

  SecurityCheck copyWith({
    bool? isSecure,
  }) {
    return SecurityCheck(
      threat: threat,
      name: name,
      secureDescription: secureDescription,
      insecureDescription: insecureDescription,
      category: category,
      isSecure: isSecure ?? this.isSecure,
    );
  }
}
