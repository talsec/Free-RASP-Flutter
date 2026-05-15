import 'package:json_annotation/json_annotation.dart';

part 'suspicious_app_detection_config.g.dart';

/// The scope of apps to be scanned for malware.
enum ScopeType {
  sideloadedOnly,

  sideloadedAndSystemExcludeOem,

  sideloadedAndOem,

  sideloadedAndSystemAndOem,

  all,
}

/// The mode for reporting malware detection reasons.
enum ReasonMode {
  all,

  highestConfidence,
}

/// Configuration for malware scan scope and trusted install sources.
@JsonSerializable(includeIfNull: false)
class MalwareScanScope {
  const MalwareScanScope({
    required this.scanScope,
    this.trustedInstallSources,
  });

  factory MalwareScanScope.fromJson(Map<String, dynamic> json) =>
      _$MalwareScanScopeFromJson(json);

  Map<String, dynamic> toJson() => _$MalwareScanScopeToJson(this);

  final ScopeType scanScope;

  final List<String>? trustedInstallSources;
}

/// Configuration for suspicious app detection.
@JsonSerializable(includeIfNull: false)
class SuspiciousAppDetectionConfig {
  const SuspiciousAppDetectionConfig({
    this.packageNames,
    this.hashes,
    this.requestedPermissions,
    this.grantedPermissions,
    this.malwareScanScope =
        const MalwareScanScope(scanScope: ScopeType.sideloadedOnly),
    this.reasonMode = ReasonMode.highestConfidence,
  });

  factory SuspiciousAppDetectionConfig.fromJson(Map<String, dynamic> json) =>
      _$SuspiciousAppDetectionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SuspiciousAppDetectionConfigToJson(this);

  final List<String>? packageNames;

  final List<String>? hashes;

  final List<List<String>>? requestedPermissions;

  final List<List<String>>? grantedPermissions;

  final MalwareScanScope malwareScanScope;

  final ReasonMode reasonMode;
}
