import 'package:flutter/foundation.dart';

/// Model class for iOS callbacks.
///
/// Callbacks (pointers) are called in talsec_config.
class IOSCallback {
  /// Callback called when app signature does not match expected one
  final VoidCallback? onSignatureDetected;

  /// Callback called when jailbreak on device is detected
  final VoidCallback? onJailbreakDetected;

  /// Callback called when app is manipulated on runtime
  final VoidCallback? onRuntimeManipulationDetected;

  /// Callback called when device is not protected by passcode
  final VoidCallback? onPasscodeDetected;

  /// Callback called when app is running on simulator
  final VoidCallback? onSimulatorDetected;

  /// Callback called when secure enclave layer is missing
  final VoidCallback? onMissingSecureEnclaveDetected;

  /// Callback called when device was changed
  final VoidCallback? onDeviceChangeDetected;

  /// Callback called when device ID detected
  final VoidCallback? onDeviceIdDetected;

  /// Callback called when application is not installed from official store
  final VoidCallback? onUnofficialStoreDetected;

  const IOSCallback({
    final this.onSignatureDetected,
    final this.onJailbreakDetected,
    final this.onRuntimeManipulationDetected,
    final this.onPasscodeDetected,
    final this.onSimulatorDetected,
    final this.onMissingSecureEnclaveDetected,
    final this.onDeviceChangeDetected,
    final this.onDeviceIdDetected,
    final this.onUnofficialStoreDetected,
  });
}
