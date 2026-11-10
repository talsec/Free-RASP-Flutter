// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

import '../test_utils/test_utils.dart';

void main() {
  group('$ThreatCallback', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('Should trigger appropriate function', () async {
      // Arrange
      final controller = StreamController<Threat>();
      controller.add(Threat.simulator);
      controller.add(Threat.simulator);
      controller.add(Threat.appIntegrity);
      controller.add(Threat.privilegedAccess);
      unawaited(controller.close());

      // Act
      await consumeStream(controller.stream);

      // Assert
      expect(SpyThreatListener.log[Threat.simulator], 2);
      expect(SpyThreatListener.log[Threat.appIntegrity], 1);
      expect(SpyThreatListener.log[Threat.privilegedAccess], 1);

      expect(SpyThreatListener.log[Threat.hooks], 0);
      expect(SpyThreatListener.log[Threat.debug], 0);
      expect(SpyThreatListener.log[Threat.deviceBinding], 0);
      expect(SpyThreatListener.log[Threat.unofficialStore], 0);
      expect(SpyThreatListener.log[Threat.obfuscationIssues], 0);
    });

    test('Should forward ongoing call state', () {
      // Arrange
      final states = <CallState>[];
      final callback = ThreatCallback(onOngoingCall: states.add);

      // Act
      callback
        ..onOngoingCallDetected(CallState.started)
        ..onOngoingCallDetected(CallState.stopped);

      // Assert
      expect(states, [CallState.started, CallState.stopped]);
    });
  });
}

Future<void> consumeStream(
  Stream<Threat> stream,
) async {
  await stream.forEach(SpyThreatListener.addThreat);
}
