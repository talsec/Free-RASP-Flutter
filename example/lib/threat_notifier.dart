import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';

/// Class responsible for setting up listeners to detected threats
class ThreatNotifier extends StateNotifier<Map<Threat, bool>> {
  /// Sets up reactions to detected threats and starts the threat listener
  ThreatNotifier() : super(_emptyState()) {
    final callback = ThreatCallback(
      onAppIntegrity: () => _updateThreat(Threat.appIntegrity),
      onDebug: () => _updateThreat(Threat.debug),
      onDeviceBinding: () => _updateThreat(Threat.deviceBinding),
      onDeviceID: () => _updateThreat(Threat.deviceId),
      onHooks: () => _updateThreat(Threat.hooks),
      onPasscode: () => _updateThreat(Threat.passcode),
      onPrivilegedAccess: () => _updateThreat(Threat.privilegedAccess),
      onSecureHardwareNotAvailable: () =>
          _updateThreat(Threat.secureHardwareNotAvailable),
      onSimulator: () => _updateThreat(Threat.simulator),
      onUnofficialStore: () => _updateThreat(Threat.unofficialStore),
    );

    Talsec.instance.attachListener(callback);
  }

  static Map<Threat, bool> _emptyState() {
    final threatMap =
        Threat.values.asMap().map((key, value) => MapEntry(value, false));

    if (Platform.isAndroid) {
      threatMap.remove(Threat.deviceId);
    }

    return threatMap;
  }

  void _updateThreat(Threat threat) {
    final threatMap = {threat: true};
    state = {...state, ...threatMap};
  }
}
