import 'package:freerasp/src/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'talsec_config.g.dart';

/// Class responsible for freeRASP configuration
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TalsecConfig {
  /// Configuration for [TalsecConfig].
  TalsecConfig({
    required this.watcherMail,
    this.isProd = true,
    this.killOnBypass = false,
    this.androidConfig,
    this.iosConfig,
  });

  /// Converts config from json
  factory TalsecConfig.fromJson(Map<String, dynamic> json) =>
      _$TalsecConfigFromJson(json);

  /// Converts config to json
  Map<String, dynamic> toJson() => _$TalsecConfigToJson(this);

  /// Android configuration.
  final AndroidConfig? androidConfig;

  /// iOS configuration.
  final IOSConfig? iosConfig;

  /// Mail for security reports.
  final String watcherMail;

  /// Whether the SDK should be running in release mode.
  final bool isProd;

  /// Whether the application should be killed when SDK is bypassed.
  ///
  /// When bypassed, application is killed without triggering callbacks.
  final bool killOnBypass;
}
