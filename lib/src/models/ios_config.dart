import 'package:freerasp/src/utils/config_verifier.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ios_config.g.dart';

/// Class responsible for freeRASP iOS configuration
@JsonSerializable()
class IOSConfig {
  /// iOS configuration fields
  IOSConfig({
    required this.bundleIds,
    required this.teamId,
  }) {
    ConfigVerifier.verifyIOS(this);
  }

  /// Converts config from json
  factory IOSConfig.fromJson(Map<String, dynamic> json) =>
      _$IOSConfigFromJson(json);

  /// Converts config to json
  Map<String, dynamic> toJson() => _$IOSConfigToJson(this);

  /// Bundle ID of the app.
  final List<String> bundleIds;

  /// Team ID of the app.
  final String teamId;
}
