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
      onDeviceID: () => _updateThreat(Threat.deviceID),
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
      onAdbEnabled: () => _updateThreat(Threat.adbEnabled),
      onScreenshot: () => _updateThreat(Threat.screenshot),
      onScreenRecording: () => _updateThreat(Threat.screenRecording),
      onMultiInstance: () => _updateThreat(Threat.multiInstance),
      onUnsecureWifi: () => _updateThreat(Threat.unsecureWifi),
      onTimeSpoofing: () => _updateThreat(Threat.timeSpoofing),
      onLocationSpoofing: () => _updateThreat(Threat.locationSpoofing),
      onAutomation: () => _updateThreat(Threat.automation),
      onBootloader: () => _updateThreat(Threat.bootloader),
      onOngoingCall: _updateCallState,
    );

    final raspExecutionStateCallback = RaspExecutionStateCallback(
      onFastChecksFinished: _updateChecksStatus,
      onPostponedChecksFinished: _updatePostponedChecksStatus,
    );

    Talsec.instance.attachListener(threatCallback);
    Talsec.instance.attachExecutionStateListener(raspExecutionStateCallback);
  }

  void _updateThreat(Threat threat) {
    state = state.copyWith(detectedThreats: {...state.detectedThreats, threat});
  }

  void _updateMalware(List<SuspiciousAppInfo> malware) {
    state = state.copyWith(detectedMalware: malware);
  }

  void _updateChecksStatus() {
    state = state.copyWith(allChecksPassed: true);
  }

  void _updatePostponedChecksStatus() {
    state = state.copyWith(postponedChecksPassed: true);
  }

  void _updateCallState(CallState callState) {
    state = state.copyWith(callState: callState);
  }
}
