import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

void main() {
  test('Threat enum should contain 14 values', () {
    final threatValuesLength = Threat.values.length;

    expect(threatValuesLength, 16);
  });

  test('Threat enum should match its values index', () {
    const threatValues = Threat.values;

    expect(threatValues[0], Threat.hooks);
    expect(threatValues[1], Threat.debug);
    expect(threatValues[2], Threat.passcode);
    expect(threatValues[3], Threat.deviceId);
    expect(threatValues[4], Threat.simulator);
    expect(threatValues[5], Threat.appIntegrity);
    expect(threatValues[6], Threat.obfuscationIssues);
    expect(threatValues[7], Threat.deviceBinding);
    expect(threatValues[8], Threat.unofficialStore);
    expect(threatValues[9], Threat.privilegedAccess);
    expect(threatValues[10], Threat.secureHardwareNotAvailable);
    expect(threatValues[11], Threat.systemVPN);
    expect(threatValues[12], Threat.devMode);
    expect(threatValues[13], Threat.adbEnabled);
    expect(threatValues[14], Threat.screenshot);
    expect(threatValues[15], Threat.screenRecording);
  });

  test(
    'ThreatX.fromString should return correct Threat enum for '
    'valid String value',
    () {
      expect(ThreatX.fromInt(1268968002), Threat.debug);
      expect(ThreatX.fromInt(209533833), Threat.hooks);
      expect(ThreatX.fromInt(1293399086), Threat.passcode);
      expect(ThreatX.fromInt(1514211414), Threat.deviceId);
      expect(ThreatX.fromInt(477190884), Threat.simulator);
      expect(ThreatX.fromInt(1115787534), Threat.appIntegrity);
      expect(ThreatX.fromInt(1001443554), Threat.obfuscationIssues);
      expect(ThreatX.fromInt(1806586319), Threat.deviceBinding);
      expect(ThreatX.fromInt(629780916), Threat.unofficialStore);
      expect(ThreatX.fromInt(44506749), Threat.privilegedAccess);
      expect(ThreatX.fromInt(1564314755), Threat.secureHardwareNotAvailable);
      expect(ThreatX.fromInt(659382561), Threat.systemVPN);
      expect(ThreatX.fromInt(45291047), Threat.devMode);
      expect(ThreatX.fromInt(379769839), Threat.adbEnabled);
      expect(ThreatX.fromInt(705651459), Threat.screenshot);
      expect(ThreatX.fromInt(64690214), Threat.screenRecording);
    },
  );
}
