import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

void main() {
  test('Threat enum should contain 10 values', () {
    final threatValuesLength = Threat.values.length;

    expect(threatValuesLength, 10);
  });

  test('Threat enum should match its values index', () {
    const threatValues = Threat.values;

    expect(threatValues[0], Threat.hooks);
    expect(threatValues[1], Threat.debug);
    expect(threatValues[2], Threat.passcode);
    expect(threatValues[3], Threat.deviceId);
    expect(threatValues[4], Threat.simulator);
    expect(threatValues[5], Threat.appIntegrity);
    expect(threatValues[6], Threat.deviceBinding);
    expect(threatValues[7], Threat.unofficialStore);
    expect(threatValues[8], Threat.privilegedAccess);
    expect(threatValues[9], Threat.secureHardwareNotAvailable);
  });

  test(
    'ThreatX.fromString should return correct Threat enum for '
    'valid String value',
    () {
      expect(ThreatX.fromString('debug'), Threat.debug);
      expect(ThreatX.fromString('hooks'), Threat.hooks);
      expect(ThreatX.fromString('passcode'), Threat.passcode);
      expect(ThreatX.fromString('deviceId'), Threat.deviceId);
      expect(ThreatX.fromString('simulator'), Threat.simulator);
      expect(ThreatX.fromString('appIntegrity'), Threat.appIntegrity);
      expect(ThreatX.fromString('deviceBinding'), Threat.deviceBinding);
      expect(ThreatX.fromString('unofficialStore'), Threat.unofficialStore);
      expect(ThreatX.fromString('privilegedAccess'), Threat.privilegedAccess);
      expect(
        ThreatX.fromString('secureHardwareNotAvailable'),
        Threat.secureHardwareNotAvailable,
      );
    },
  );

  test(
    'ThreatX.fromString should throw TalsecException for invalid String value',
    () {
      expect(
        () => ThreatX.fromString('passcodeChange'),
        throwsA(isA<TalsecException>()),
      );
    },
  );
}
