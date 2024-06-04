import 'dart:io';

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
  secureHardwareNotAvailable,

  /// The application is running on a device that has active system VPN
  systemVPN,

  /// The device has Developer mode enabled
  ///
  /// Android only
  devMode,
}

/// An extension on the [Threat] enum to provide additional functionality.
extension ThreatX on Threat {
  /// Converts a [int] code to an instance of the [Threat] enum.
  ///
  /// Kills an app if the given int [code] does not match any of the predefined
  /// values for the [Threat] enum.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final threat = ThreatX.fromInt(1268968002); // Threat.debug
  /// ```
  ///
  /// Shared error codes:
  /// * 1268968002 - debug
  /// * 209533833 - hooks
  /// * 55943254 - overlay
  /// * 1293399086 - passcode
  /// * 1514211414 - deviceId
  /// * 477190884 - simulator
  /// * 1115787534 - appIntegrity
  /// * 1001443554 - obfuscationIssues
  /// * 1806586319 - deviceBinding
  /// * 629780916 - unofficialStore
  /// * 44506749 - privilegedAccess
  /// * 1564314755 - secureHardwareNotAvailable
  /// * 659382561 - systemVPN
  /// * 45291047 - devMode
  static Threat fromInt(int code) {
    switch (code) {
      case 1268968002:
        return Threat.debug;
      case 209533833:
        return Threat.hooks;
      case 1293399086:
        return Threat.passcode;
      case 1514211414:
        return Threat.deviceId;
      case 477190884:
        return Threat.simulator;
      case 1115787534:
        return Threat.appIntegrity;
      case 1001443554:
        return Threat.obfuscationIssues;
      case 1806586319:
        return Threat.deviceBinding;
      case 629780916:
        return Threat.unofficialStore;
      case 44506749:
        return Threat.privilegedAccess;
      case 1564314755:
        return Threat.secureHardwareNotAvailable;
      case 659382561:
        return Threat.systemVPN;
      case 45291047:
        return Threat.devMode;
      default:
        // Unknown data came from native code. This shouldn't normally happen.
        exit(127);
    }
  }
}
