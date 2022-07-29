import 'android/android_config.dart';
import 'ios/ios_config.dart';

export 'android/android_config.dart';
export 'ios/ios_config.dart';

/// Wrapper for configuration objects.
///
/// Holds [androidConfig] and [iosConfig] as parameters and wraps them into
/// general [TalsecConfig].
/// Also contains [watcherMail] for alerts and reports.
class TalsecConfig {
  final AndroidConfig? androidConfig;
  final IOSconfig? iosConfig;
  final String? watcherMail;

  const TalsecConfig({
    required final this.watcherMail,
    final this.androidConfig,
    final this.iosConfig,
  }) : assert(
          (androidConfig != null || iosConfig != null) && watcherMail != null,
          'Configuration for targeted platform and watcherMail has to be provided',
        );
}
