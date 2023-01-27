import 'package:flutter/foundation.dart';

import 'package:freerasp/android/android_callback.dart';
import 'package:freerasp/ios/ios_callback.dart';

export 'android/android_callback.dart';
export 'ios/ios_callback.dart';

/// Wrapper for callbacks
///
/// Takes [androidCallback] and [iosCallback] as parameters and wraps them into
/// general [TalsecCallback].
/// Also takes [onDebuggerDetected] which is common for both platforms.
class TalsecCallback {
  /// Callbacks for Talsec.
  const TalsecCallback({
    this.onDebuggerDetected,
    this.androidCallback,
    this.iosCallback,
  });

  /// Callback called when debugger is detected.
  final VoidCallback? onDebuggerDetected;

  /// Callbacks for Android.
  final AndroidCallback? androidCallback;

  /// Callbacks for iOS.
  final IOSCallback? iosCallback;
}
