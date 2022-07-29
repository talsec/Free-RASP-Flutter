import 'package:flutter/foundation.dart';

/// Model class for Android callbacks.
///
/// Callbacks (pointers) are called in talsec_config.
class AndroidCallback {
  /// Callback called when device is rooted
  final VoidCallback? onRootDetected;

  /// Callback called when app is running on emulator
  final VoidCallback? onEmulatorDetected;

  /// Callback called when app code integrity is disturbed
  final VoidCallback? onTamperDetected;

  /// Callback called when hooking framework is present or used
  final VoidCallback? onHookDetected;

  /// Callback called when binding of device is disrupted
  final VoidCallback? onDeviceBindingDetected;

  /// Callback called when application is installed from unrecognised source
  /// such as unofficial store or other not explicitly allow source
  final VoidCallback? onUntrustedInstallationDetected;

  const AndroidCallback({
    final this.onRootDetected,
    final this.onEmulatorDetected,
    final this.onTamperDetected,
    final this.onHookDetected,
    final this.onDeviceBindingDetected,
    final this.onUntrustedInstallationDetected,
  });
}
