import 'package:freerasp/freerasp.dart';

class SpyThreatListener {
  SpyThreatListener._();

  static final Map<Threat, int> log = Threat.values.asMap().map(
        (key, value) => MapEntry(value, 0),
      );

  static final callback = ThreatCallback(
    onAppIntegrity: () => _log(Threat.appIntegrity),
    onDebug: () => _log(Threat.debug),
    onDeviceBinding: () => _log(Threat.deviceBinding),
    onDeviceID: () => _log(Threat.deviceId),
    onHooks: () => _log(Threat.hooks),
    onPasscode: () => _log(Threat.passcode),
    onPrivilegedAccess: () => _log(Threat.privilegedAccess),
    onSecureHardwareNotAvailable: () => _log(Threat.secureHardwareNotAvailable),
    onSimulator: () => _log(Threat.simulator),
    onUnofficialStore: () => _log(Threat.unofficialStore),
    onSystemVPN: () => _log(Threat.systemVPN),
    onDevMode: () => _log(Threat.devMode),
    onADBEnabled: () => _log(Threat.adbEnabled),
    onScreenshot: () => _log(Threat.screenshot),
    onScreenRecording: () => _log(Threat.screenRecording),
    onObfuscationIssues: () => _log(Threat.obfuscationIssues),
    onMultiInstance: () => _log(Threat.multiInstance),
    onAutomation: () => _log(Threat.automation),
  );

  static void _log(Threat threat) {
    log[threat] = log[threat]! + 1;
  }

  static void addThreat(Threat threat) {
    switch (threat) {
      case Threat.appIntegrity:
        callback.onAppIntegrity?.call();
      case Threat.obfuscationIssues:
        callback.onObfuscationIssues?.call();
      case Threat.debug:
        callback.onDebug?.call();
      case Threat.deviceBinding:
        callback.onDeviceBinding?.call();
      case Threat.hooks:
        callback.onHooks?.call();
      case Threat.privilegedAccess:
        callback.onPrivilegedAccess?.call();
      case Threat.simulator:
        callback.onSimulator?.call();
      case Threat.unofficialStore:
        callback.onUnofficialStore?.call();
      case Threat.passcode:
        callback.onPasscode?.call();
      case Threat.deviceId:
        callback.onDeviceID?.call();
      case Threat.secureHardwareNotAvailable:
        callback.onSecureHardwareNotAvailable?.call();
      case Threat.systemVPN:
        callback.onSystemVPN?.call();
      case Threat.devMode:
        callback.onDevMode?.call();
      case Threat.adbEnabled:
        callback.onADBEnabled?.call();
      case Threat.screenshot:
        callback.onScreenshot?.call();
      case Threat.screenRecording:
        callback.onScreenRecording?.call();
      case Threat.multiInstance:
        callback.onMultiInstance?.call();
      case Threat.unsecureWiFi:
        callback.onUnsecureWiFi?.call();
      case Threat.timeSpoofing:
        callback.onTimeSpoofing?.call();
      case Threat.locationSpoofing:
        callback.onLocationSpoofing?.call();
      case Threat.automation:
        callback.onAutomation?.call();
    }
  }
}
