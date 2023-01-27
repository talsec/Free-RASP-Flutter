import 'package:flutter/foundation.dart';

/// A class for Android callbacks.
///
/// When threat is detected, callback is called according to its type.
///
/// Callbacks (pointers) are called in talsec_config.
class AndroidCallback {
  /// Constructor for Android callbacks.
  ///
  /// If callback is not implemented, implicit null is applied.
  const AndroidCallback({
    this.onRootDetected,
    this.onEmulatorDetected,
    this.onTamperDetected,
    this.onHookDetected,
    this.onDeviceBindingDetected,
    this.onUntrustedInstallationDetected,
  });

  /// Callback called when device is rooted.
  final VoidCallback? onRootDetected;

  /// Callback called when app is running on emulator.
  final VoidCallback? onEmulatorDetected;

  /// Callback called when app code integrity is disturbed.
  final VoidCallback? onTamperDetected;

  /// Callback called when hooking framework is present or used.
  final VoidCallback? onHookDetected;

  /// Callback called when binding of device is disrupted.
  final VoidCallback? onDeviceBindingDetected;

  /// Callback called when application is installed from unrecognised source
  /// such as unofficial store or other not explicitly allow source.
  final VoidCallback? onUntrustedInstallationDetected;
}
