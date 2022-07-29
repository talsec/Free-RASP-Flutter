import 'package:flutter/foundation.dart';

import 'android/android_callback.dart';
import 'ios/ios_callback.dart';

export 'android/android_callback.dart';
export 'ios/ios_callback.dart';

/// Wrapper for callbacks
///
/// Takes [androidCallback] and [iosCallback] as parameters and wraps them into
/// general [TalsecCallback].
/// Also takes [onDebuggerDetected] which is common for both platforms.
class TalsecCallback {
  final VoidCallback? onDebuggerDetected;
  final AndroidCallback? androidCallback;
  final IOSCallback? iosCallback;

  const TalsecCallback({
    final this.onDebuggerDetected,
    final this.androidCallback,
    final this.iosCallback,
  });
}
