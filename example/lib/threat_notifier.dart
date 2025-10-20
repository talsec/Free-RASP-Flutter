import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/threat_state.dart';

/// Class responsible for setting up listeners to detected threats
class ThreatNotifier extends AutoDisposeNotifier<ThreatState> {
  @override
  ThreatState build() {
    _init();
    return ThreatState.initial();
  }

  void _init() {
    final threatCallback = ThreatCallback(
      onMalware: _updateMalware,
      onHooks: () => _updateThreat(Threat.hooks),
      onDebug: () => _updateThreat(Threat.debug),
      onPasscode: () => _updateThreat(Threat.passcode),
      onDeviceID: () => _updateThreat(Threat.deviceId),
      onSimulator: () => _updateThreat(Threat.simulator),
      onAppIntegrity: () => _updateThreat(Threat.appIntegrity),
      onObfuscationIssues: () => _updateThreat(Threat.obfuscationIssues),
      onDeviceBinding: () => _updateThreat(Threat.deviceBinding),
      onUnofficialStore: () => _updateThreat(Threat.unofficialStore),
      onPrivilegedAccess: () => _updateThreat(Threat.privilegedAccess),
      onSecureHardwareNotAvailable: () =>
          _updateThreat(Threat.secureHardwareNotAvailable),
      onSystemVPN: () => _updateThreat(Threat.systemVPN),
      onDevMode: () => _updateThreat(Threat.devMode),
      onADBEnabled: () => _updateThreat(Threat.adbEnabled),
      onScreenshot: () => _updateThreat(Threat.screenshot),
      onScreenRecording: () => _updateThreat(Threat.screenRecording),
      onMultiInstance: () => _updateThreat(Threat.multiInstance),
      onUnsecureWiFi: () => _updateThreat(Threat.unsecureWiFi),
      onTimeSpoofing: () => _updateThreat(Threat.timeSpoofing),
      onLocationSpoofing: () => _updateThreat(Threat.locationSpoofing),
      onAllChecksFinished: _updateChecksStatus,
    );

    Talsec.instance.attachListener(threatCallback);
  }

  void _updateThreat(Threat threat) {
    state = state.copyWith(detectedThreats: {...state.detectedThreats, threat});
  }

  void _updateMalware(List<SuspiciousAppInfo?> malware) {
    state = state.copyWith(detectedMalware: malware.nonNulls.toList());
  }

  void _updateChecksStatus() {
    state = state.copyWith(allChecksPassed: true);
  }
}
