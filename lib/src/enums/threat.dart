import 'package:freerasp/src/errors/errors.dart';

/// Possible threats which can occur in Flutter app.
enum Threat {
  /// The application is being hooked (e.g. Frida), indicating that the app is
  /// being attacked.
  hooks,

  /// The application is running in unsafe environment (debugger), indicating
  /// that the application is being reverse engineered.
  debug,

  /// The device has not set any passcode as protection, indicating that the
  /// device is unprotected.
  passcode,

  /// The application was reinstalled.
  ///
  /// iOS only.
  deviceId,

  /// The application is running on a simulator, potentially indicating  that
  /// it is being analyzed or reverse engineered.
  simulator,

  /// The integrity of the application's code or data may be compromised,
  /// indicating that it has been tampered with.
  appIntegrity,

  /// The application is not obfuscated, indicating that it is vulnerable to
  /// reverse engineering.
  obfuscationIssues,

  /// The device running the application may be bound to another device,
  /// indicating an attempt to clone the application.
  deviceBinding,

  /// The application is installed from an unofficial app store, indicating
  /// that it has been tampered with.
  unofficialStore,

  /// The application has privileged access to system resources
  /// making it vulnerable to exploitation by attackers.
  privilegedAccess,

  /// The application is running on a device which doesn't support secure
  /// hardware based cryptography.
  secureHardwareNotAvailable
}

/// An extension on the [Threat] enum to provide additional functionality.
extension ThreatX on Threat {
  /// Converts a [String] to an instance of the [Threat] enum.
  ///
  /// Throws an [UnimplementedError] if the given string [name] does not match
  /// any of the predefined values for the [Threat] enum.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// var threat = ThreatX.fromString('debug'); // Threat.debug
  /// ```
  static Threat fromString(String name) {
    switch (name) {
      case 'debug':
        return Threat.debug;
      case 'hooks':
        return Threat.hooks;
      case 'passcode':
        return Threat.passcode;
      case 'deviceId':
        return Threat.deviceId;
      case 'simulator':
        return Threat.simulator;
      case 'appIntegrity':
        return Threat.appIntegrity;
      case 'obfuscationIssues':
        return Threat.obfuscationIssues;
      case 'deviceBinding':
        return Threat.deviceBinding;
      case 'unofficialStore':
        return Threat.unofficialStore;
      case 'privilegedAccess':
        return Threat.privilegedAccess;
      case 'secureHardwareNotAvailable':
        return Threat.secureHardwareNotAvailable;
      default:
        throw TalsecException(
          message: 'Cannot resolve this data as threat: $name',
        );
    }
  }
}
