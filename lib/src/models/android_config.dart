import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'android_config.g.dart';

/// Class responsible for freeRASP Android configuration
@JsonSerializable(includeIfNull: false)
class AndroidConfig {
  /// Android configuration fields
  AndroidConfig({
    required this.packageName,
    required this.signingCertHashes,
    this.supportedStores = const [],
    this.malwareConfig,
  }) {
    ConfigVerifier.verifyAndroid(this);
  }

  /// Converts config from json
  factory AndroidConfig.fromJson(Map<String, dynamic> json) =>
      _$AndroidConfigFromJson(json);

  /// Converts config to json
  Map<String, dynamic> toJson() => _$AndroidConfigToJson(this);

  /// Package name of the application.
  final String packageName;

  /// List of expected signing hashes.
  final List<String> signingCertHashes;

  /// List of supported sources where application can be installed from.
  final List<String> supportedStores;

  /// Malware configuration for Android.
  final MalwareConfig? malwareConfig;
}
