import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/models/security_check.dart';
import 'package:freerasp_example/models/security_state.dart';

/// Provider for the security controller that manages all security checks.
final securityControllerProvider =
    NotifierProvider.autoDispose<SecurityController, SecurityState>(
  SecurityController.new,
);

class SecurityController extends AutoDisposeNotifier<SecurityState> {
  /// Initializes the security controller and starts monitoring.
  @override
  SecurityState build() {
    final checks = _initChecks();
    Future.microtask(_startListening);

    ref.onDispose(() {
      Talsec.instance.detachListener();
    });

    return SecurityState.initial(checks);
  }

  List<SecurityCheck> _initChecks() {
    return [
      // App Integrity
      SecurityCheck(
        threat: Threat.appIntegrity,
        name: 'App Integrity',
        secureDescription: 'Application signature is verified and intact.',
        insecureDescription: 'Application signature verification failed.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.obfuscationIssues,
        name: 'Obfuscation',
        secureDescription: 'Application code is properly obfuscated.',
        insecureDescription: 'Application code is not obfuscated.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.unofficialStore,
        name: 'Unofficial Store',
        secureDescription: 'Application installed from an official store.',
        insecureDescription: 'Application installed from an unknown source.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.simulator,
        name: 'Simulator',
        secureDescription: 'Running on a real device.',
        insecureDescription: 'Running on a simulator or emulator.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.deviceBinding,
        name: 'Device Binding',
        secureDescription: 'Application properly bound to the device.',
        insecureDescription: 'Device binding compromised.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.multiInstance,
        name: 'Multi Instance',
        secureDescription: 'Single application instance running.',
        insecureDescription: 'Multiple application instances detected.',
        category: ThreatCategory.appIntegrity,
      ),

      // Device Security
      SecurityCheck(
        threat: Threat.privilegedAccess,
        name: 'Root / Jailbreak',
        secureDescription: 'System is running securely (standard environment).',
        insecureDescription: 'Privileged access (Root/Jailbreak) detected.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.hooks,
        name: 'Hooks',
        secureDescription: 'No hooking frameworks detected.',
        insecureDescription: 'Hooking framework detected.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.secureHardwareNotAvailable,
        name: 'Secure Hardware',
        secureDescription: 'Secure hardware available.',
        insecureDescription: 'Secure hardware unavailable.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.devMode,
        name: 'Developer Mode',
        secureDescription: 'Developer options are disabled.',
        insecureDescription: 'Developer options are enabled.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.debug,
        name: 'Debugger',
        secureDescription: 'No debugger attached.',
        insecureDescription: 'Debugger is attached.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.passcode,
        name: 'Passcode',
        secureDescription: 'Device is protected with a passcode.',
        insecureDescription: 'Device is not protected with a passcode.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.adbEnabled,
        name: 'ADB Enabled',
        secureDescription: 'USB debugging (ADB) is disabled.',
        insecureDescription: 'USB debugging (ADB) is enabled.',
        category: ThreatCategory.deviceSecurity,
      ),

      SecurityCheck(
        threat: Threat.systemVPN,
        name: 'System VPN',
        secureDescription: 'No VPN active.',
        insecureDescription: 'Network traffic is routed via VPN.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.screenshot,
        name: 'Screenshot',
        secureDescription: 'No screenshots detected.',
        insecureDescription: 'Screenshot detected.',
        category: ThreatCategory.runtimeStatus,
      ),
      SecurityCheck(
        threat: Threat.screenRecording,
        name: 'Screen Recording',
        secureDescription: 'No screen recording detected.',
        insecureDescription: 'Screen recording detected.',
        category: ThreatCategory.runtimeStatus,
      ),
      SecurityCheck(
        threat: Threat.locationSpoofing,
        name: 'Location Spoofing',
        secureDescription: 'Device location is valid.',
        insecureDescription: 'Device location is being manipulated.',
        category: ThreatCategory.runtimeStatus,
      ),
      SecurityCheck(
        threat: Threat.timeSpoofing,
        name: 'Time Spoofing',
        secureDescription: 'Device time is correct.',
        insecureDescription: 'Device time is out of sync.',
        category: ThreatCategory.runtimeStatus,
      ),
      SecurityCheck(
        threat: Threat.unsecureWiFi,
        name: 'Unsecure Wi-Fi',
        secureDescription: 'Connected to a secure Wi-Fi network.',
        insecureDescription: 'Connected to an unsecure Wi-Fi network.',
        category: ThreatCategory.runtimeStatus,
      ),
    ];
  }

  Future<void> _startListening() async {
    final threatCallback = ThreatCallback(
      onAppIntegrity: () => _handleThreat(Threat.appIntegrity),
      onObfuscationIssues: () => _handleThreat(Threat.obfuscationIssues),
      onUnofficialStore: () => _handleThreat(Threat.unofficialStore),
      onPrivilegedAccess: () => _handleThreat(Threat.privilegedAccess),
      onDeviceBinding: () => _handleThreat(Threat.deviceBinding),
      onSimulator: () => _handleThreat(Threat.simulator),
      onHooks: () => _handleThreat(Threat.hooks),
      onDebug: () => _handleThreat(Threat.debug),
      onScreenRecording: () => _handleThreat(Threat.screenRecording),
      onScreenshot: () => _handleThreat(Threat.screenshot),
      onSecureHardwareNotAvailable: () =>
          _handleThreat(Threat.secureHardwareNotAvailable),
      onSystemVPN: () => _handleThreat(Threat.systemVPN),
      onDeviceID: () => _handleThreat(Threat.deviceId),
      onPasscode: () => _handleThreat(Threat.passcode),
      onADBEnabled: () => _handleThreat(Threat.adbEnabled),
      onDevMode: () => _handleThreat(Threat.devMode),
      onMultiInstance: () => _handleThreat(Threat.multiInstance),
      onUnsecureWiFi: () => _handleThreat(Threat.unsecureWiFi),
      onTimeSpoofing: () => _handleThreat(Threat.timeSpoofing),
      onLocationSpoofing: () => _handleThreat(Threat.locationSpoofing),
      onMalware: _handleMalware,
    );

    await Talsec.instance.attachListener(threatCallback);
  }

  void _handleThreat(Threat type) {
    final currentState = state;
    final checks = List<SecurityCheck>.from(currentState.checks);
    final index = checks.indexWhere((c) => c.threat == type);

    if (index != -1 && checks[index].isSecure) {
      checks[index] = checks[index].copyWith(isSecure: false);
      state = currentState.copyWith(checks: checks);
    }
  }

  void _handleMalware(List<SuspiciousAppInfo?> malware) {
    final currentState = state;
    final malwareList = malware.whereType<SuspiciousAppInfo>().toList();
    state = currentState.copyWith(detectedMalware: malwareList);
  }
}
