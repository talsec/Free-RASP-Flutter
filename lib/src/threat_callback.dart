import 'package:freerasp/src/typedefs.dart';

/// A class which represents a set of callbacks that are used to notify the
/// application when certain security threat are detected.
///
/// ```dart
/// // Example of single callback
/// final callback = ThreatCallback(
///   onDebug: () => print('Debug detected'),
/// );
/// ```
///
/// [ThreatCallback] is then attached to Talsec instance which handles correct
/// function invocations.
///
/// ```dart
/// // Attaching callback to Talsec
/// Talsec.instance.attachListener(callback);
/// ```
class ThreatCallback {
  /// Constructs a [ThreatCallback] instance.
  ThreatCallback({
    this.onHooks,
    this.onDebug,
    this.onPasscode,
    this.onDeviceID,
    this.onSimulator,
    this.onAppIntegrity,
    this.onObfuscationIssues,
    this.onDeviceBinding,
    this.onUnofficialStore,
    this.onPrivilegedAccess,
    this.onSecureHardwareNotAvailable,
  });

  /// This method is called when a threat related dynamic hooking (e.g. Frida)
  /// is detected.
  final VoidCallback? onHooks;

  /// This method is called when an unsafe environment (debugger) is detected.
  final VoidCallback? onDebug;

  /// This method is called when the device has not set any passcode.
  final VoidCallback? onPasscode;

  /// This method is called when the application was reinstalled.
  ///
  /// iOS only.
  final VoidCallback? onDeviceID;

  /// This method is called when running on simulator/emulator is detected.
  final VoidCallback? onSimulator;

  /// This method is called when application's integrity is compromised (e.g.
  /// invalid signature, package name, signing hash,...).
  final VoidCallback? onAppIntegrity;

  /// This method is called when application is not obfuscated.
  final VoidCallback? onObfuscationIssues;

  /// This method is called when device binding is compromised.
  final VoidCallback? onDeviceBinding;

  /// This method is called when application was installed from other source
  /// then set one in the Talsec SDK.
  final VoidCallback? onUnofficialStore;

  /// This method is called when elevated rights are detected on device (e.g.
  /// root, jailbreak,...).
  final VoidCallback? onPrivilegedAccess;

  /// This method is called when secure hardware is not available on device.
  final VoidCallback? onSecureHardwareNotAvailable;
}
