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
  );

  static void _log(Threat threat) {
    log[threat] = log[threat]! + 1;
  }

  static void addThreat(Threat threat) {
    switch (threat) {
      case Threat.appIntegrity:
        callback.onAppIntegrity?.call();
        break;
      case Threat.obfuscationIssues:
        callback.onObfuscationIssues?.call();
        break;
      case Threat.debug:
        callback.onDebug?.call();
        break;
      case Threat.deviceBinding:
        callback.onDeviceBinding?.call();
        break;
      case Threat.hooks:
        callback.onHooks?.call();
        break;
      case Threat.privilegedAccess:
        callback.onPrivilegedAccess?.call();
        break;
      case Threat.simulator:
        callback.onSimulator?.call();
        break;
      case Threat.unofficialStore:
        callback.onUnofficialStore?.call();
        break;
      case Threat.passcode:
        callback.onPasscode?.call();
        break;
      case Threat.deviceId:
        callback.onDeviceID?.call();
        break;
      case Threat.secureHardwareNotAvailable:
        callback.onSecureHardwareNotAvailable?.call();
        break;
    }
  }
}
