import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/talsec.dart' show createTalsecForTesting;

import '../test_utils/test_utils.dart';

const _events = EventChannel('talsec.app/freerasp/events');

const _malwareApp = <Object?, Object?>{
  'packageInfo': <Object?, Object?>{
    'packageName': 'com.example.malware',
    'appName': 'Malware',
    'version': '42',
    'installerStore': null,
  },
  'reasons': <Object?>['blacklist'],
  'permissions': null,
};

Talsec _talsecWith(List<Object?> data) {
  final channel = MockEventChannel(eventChannel: _events, data: data);
  return createTalsecForTesting(
    FakeMethodChannel(),
    channel.eventChannel,
    FakeEventChannel(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('attachListener delivers threats and payloads in order', () async {
    // Arrange
    final log = <Object>[];
    final talsec = _talsecWith([
      44506749,
      <Object?, Object?>{
        'type': 'malware',
        'suspiciousApps': [_malwareApp],
      },
      <Object?, Object?>{'type': 'ongoingCall', 'state': 'started'},
      <Object?, Object?>{'type': 'ongoingCall', 'state': 'stopped'},
    ]);
    final callback = ThreatCallback(
      onPrivilegedAccess: () => log.add(Threat.privilegedAccess),
      onMalware: log.add,
      onOngoingCall: log.add,
    );

    // Act
    await talsec.attachListener(callback);
    await pumpEventQueue();

    // Assert
    expect(log, [
      Threat.privilegedAccess,
      [
        const SuspiciousAppInfo(
          packageInfo: PackageInfo(
            packageName: 'com.example.malware',
            appName: 'Malware',
            version: '42',
          ),
          reasons: ['blacklist'],
        ),
      ],
      CallState.started,
      CallState.stopped,
    ]);
    await talsec.detachListener();
  });

  test('onThreatDetected skips payload events', () {
    final talsec = _talsecWith([
      <Object?, Object?>{'type': 'ongoingCall', 'state': 'ongoing'},
      1115787534,
    ]);

    expectLater(
      talsec.onThreatDetected,
      emitsInOrder([Threat.appIntegrity, emitsDone]),
    );
  });

  test('SuspiciousAppInfo.fromMap reads permissions', () {
    final app = SuspiciousAppInfo.fromMap(const {
      'packageInfo': <Object?, Object?>{'packageName': 'com.example.malware'},
      'reasons': <Object?>['permission'],
      'permissions': <Object?>['android.permission.READ_SMS'],
    });

    expect(app.permissions, ['android.permission.READ_SMS']);
    expect(app.packageInfo.packageName, 'com.example.malware');
  });

  test('SuspiciousAppInfo.fromMap throws on a malformed map', () {
    expect(
      () => SuspiciousAppInfo.fromMap(const {'reasons': <Object?>[]}),
      throwsA(anything),
    );
  });
}
