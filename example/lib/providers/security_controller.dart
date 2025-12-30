import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/config/talsec_config.dart';
import 'package:freerasp_example/models/security_check.dart';
import 'package:freerasp_example/models/security_state.dart';

class SecurityController extends AutoDisposeNotifier<SecurityState> {
  StreamSubscription<Threat>? _threatSubscription;
  ThreatCallback? _threatCallback;

  @override
  SecurityState build() {
    final checks = _initChecks();
    // Start monitoring asynchronously
    Future.microtask(() => _startMonitoring());
    
    // Handle cleanup when provider is disposed
    ref.onDispose(() {
      _threatSubscription?.cancel();
      // ThreatCallback cleanup is handled automatically by Talsec
    });
    
    return SecurityState.initial(checks);
  }

  List<SecurityCheck> _initChecks() {
    return [
      // App Integrity
      SecurityCheck(
        threat: Threat.appIntegrity,
        name: 'App Integrity',
        secureDescription: 'Application signature verified and intact.',
        insecureDescription: 'Signature verification failed.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.obfuscationIssues,
        name: 'Obfuscation',
        secureDescription: 'Application code is properly obfuscated.',
        insecureDescription: 'Application code obfuscation disabled.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.unofficialStore,
        name: 'Unofficial Store',
        secureDescription: 'Application installed from official store.',
        insecureDescription: 'Application installed from unknown or unofficial source.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.simulator,
        name: 'Simulator',
        secureDescription: 'Running on a real device.',
        insecureDescription: 'Running on simulator or emulator.',
        category: ThreatCategory.appIntegrity,
      ),
      SecurityCheck(
        threat: Threat.deviceBinding,
        name: 'Device Binding',
        secureDescription: 'Application properly bound to device.',
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
        secureDescription: 'System is running securely (sandbox).',
        insecureDescription: 'System security compromised.',
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
        secureDescription: 'Secure hardware available and functioning.',
        insecureDescription: 'Secure hardware unavailable.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.devMode,
        name: 'Developer Mode',
        secureDescription: 'Developer options are disabled.',
        insecureDescription: 'Developer mode is enabled.',
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
        insecureDescription: 'Device is not password protected.',
        category: ThreatCategory.deviceSecurity,
      ),
      SecurityCheck(
        threat: Threat.adbEnabled,
        name: 'ADB Enabled',
        secureDescription: 'USB debugging (ADB) is disabled.',
        insecureDescription: 'USB debugging (ADB) enabled.',
        category: ThreatCategory.deviceSecurity,
      ),

      SecurityCheck(
        threat: Threat.systemVPN,
        name: 'System VPN',
        secureDescription: 'No VPN active.',
        insecureDescription: 'VPN is active.',
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
        insecureDescription: 'Screen recording active.',
        category: ThreatCategory.runtimeStatus,
      ),
    ];
  }

  Future<void> _startMonitoring() async {
    final config = createTalsecConfig();
    await Talsec.instance.start(config);
    _threatSubscription = Talsec.instance.onThreatDetected.listen(_handleThreat);
    
    // Setup ThreatCallback for malware detection
    _threatCallback = ThreatCallback(
      onMalware: _handleMalware,
    );
    Talsec.instance.attachListener(_threatCallback!);
  }

  void _handleThreat(Threat type) {
    final currentState = state;
    final checks = List<SecurityCheck>.from(currentState.checks);
    final index = checks.indexWhere((c) => c.threat == type);
    
    if (index != -1 && checks[index].isSecure) {
      // Create new SecurityCheck with insecure status, preserving all other properties
      checks[index] = SecurityCheck(
        threat: checks[index].threat,
        name: checks[index].name,
        secureDescription: checks[index].secureDescription,
        insecureDescription: checks[index].insecureDescription,
        category: checks[index].category,
        isSecure: false,
      );
      state = currentState.copyWith(checks: checks);
    }
  }

  void _handleMalware(List<SuspiciousAppInfo?> malware) {
    final currentState = state;
    final malwareList = malware.whereType<SuspiciousAppInfo>().toList();
    state = currentState.copyWith(detectedMalware: malwareList);
  }
}
