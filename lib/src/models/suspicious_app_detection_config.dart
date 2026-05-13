import 'package:json_annotation/json_annotation.dart';

part 'suspicious_app_detection_config.g.dart';

/// The scope of apps to be scanned for malware.
enum ScopeType {
  /// Only sideloaded apps.
  sideloadedOnly,

  /// Sideloaded and system apps, excluding OEM apps.
  sideloadedAndSystemExcludeOem,

  /// Sideloaded and OEM apps.
  sideloadedAndOem,

  /// Sideloaded, system, and OEM apps.
  sideloadedAndSystemAndOem,

  /// All apps.
  all,
}

/// The mode for reporting malware detection reasons.
enum ReasonMode {
  /// Report all reasons.
  all,

  /// Report only the highest confidence reason.
  highestConfidence,
}

/// Configuration for malware scan scope and trusted install sources.
@JsonSerializable(includeIfNull: false)
class MalwareScanScope {
  /// Creates a new instance of [MalwareScanScope].
  const MalwareScanScope({
    required this.scanScope,
    this.trustedInstallSources,
  });

  /// Converts from json
  factory MalwareScanScope.fromJson(Map<String, dynamic> json) =>
      _$MalwareScanScopeFromJson(json);

  /// Converts to json
  Map<String, dynamic> toJson() => _$MalwareScanScopeToJson(this);

  /// The scope of apps to be scanned.
  final ScopeType scanScope;

  /// List of trusted install sources.
  final List<String>? trustedInstallSources;
}

/// Configuration for suspicious app detection.
@JsonSerializable(includeIfNull: false)
class SuspiciousAppDetectionConfig {
  /// Creates a new instance of [SuspiciousAppDetectionConfig].
  const SuspiciousAppDetectionConfig({
    this.packageNames,
    this.hashes,
    this.requestedPermissions,
    this.grantedPermissions,
    this.malwareScanScope =
        const MalwareScanScope(scanScope: ScopeType.sideloadedOnly),
    this.reasonMode = ReasonMode.highestConfidence,
  });

  /// Converts from json
  factory SuspiciousAppDetectionConfig.fromJson(Map<String, dynamic> json) =>
      _$SuspiciousAppDetectionConfigFromJson(json);

  /// Converts to json
  Map<String, dynamic> toJson() => _$SuspiciousAppDetectionConfigToJson(this);

  /// List of suspicious package names to detect.
  final List<String>? packageNames;

  /// List of suspicious app hashes to detect.
  final List<String>? hashes;

  /// Sets of requested permissions that indicate a suspicious app.
  final List<List<String>>? requestedPermissions;

  /// Sets of granted permissions that indicate a suspicious app.
  final List<List<String>>? grantedPermissions;

  /// Configuration for the malware scan scope.
  final MalwareScanScope malwareScanScope;

  /// The mode for reporting detection reasons.
  final ReasonMode reasonMode;
}
