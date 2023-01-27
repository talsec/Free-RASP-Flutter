import 'package:freerasp/android/android_config.dart';
import 'package:freerasp/ios/ios_config.dart';

export 'android/android_config.dart';
export 'ios/ios_config.dart';

/// Wrapper for configuration objects.
///
/// Holds [androidConfig] and [iosConfig] as parameters and wraps them into
/// general [TalsecConfig].
/// Also contains [watcherMail] for alerts and reports.
class TalsecConfig {
  /// Configuration for [TalsecConfig].
  const TalsecConfig({
    required this.watcherMail,
    this.androidConfig,
    this.iosConfig,
  }) : assert(
          (androidConfig != null || iosConfig != null) && watcherMail != null,
          'Configuration for targeted platform and watcherMail has to be '
          'provided',
        );

  /// Android configuration.
  final AndroidConfig? androidConfig;

  /// iOS configuration.
  final IOSconfig? iosConfig;

  /// Mail for security reports.
  final String? watcherMail;
}
