import 'package:flutter/foundation.dart';

/// A class which holds iOS config.
///
/// Contains crucial data that are passed to native side in order to secure
/// iOS device.
class IOSconfig {
  /// Constructor checks whether [appTeamId] and [appBundleId] are provided.
  /// Both arguments are MANDATORY.
  IOSconfig({
    required this.appBundleId,
    required this.appTeamId,
  }) {
    _checkConfig(appBundleId, appTeamId);
  }

  // Nullable because of older Dart SDK versions
  // see issue https://github.com/talsec/Free-RASP-Flutter/issues/6
  /// Bundle ID of the app.
  final String? appBundleId;

  /// Team ID of the app.
  final String? appTeamId;

  static void _checkConfig(String? bundleId, String? teamId) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    assert(
      bundleId != null && teamId != null,
      'appBundleId and appTeamId cannot be null.',
    );
  }
}
