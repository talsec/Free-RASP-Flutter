// ignore_for_file: cascade_invocations, discarded_futures

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/talsec.dart' show createTalsecForTesting;

import '../test_utils/test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannel', () {
    final log = <MethodCall>[];
    const channelName = 'talsec.app/freerasp/methods';

    const mockWatcherMail = 'your_mail@example.com';
    final mockAndroidConfig = AndroidConfig(
      packageName: 'com.aheaditec.freeraspExample',
      certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      supportedAlternativeStores: ['com.sec.android.app.samsungapps'],
    );
    final mockIOSConfig = IOSConfig(
      appBundleIds: ['com.aheaditec.freeraspExample'],
      appTeamId: 'M8AK35...',
    );

    tearDown(log.clear);

    group('start', () {
      test('Should start normally on Android', () {
        // Arrange
        final methodChannel = MockMethodChannel(
          channelName: channelName,
          method: 'start',
        );
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final config = TalsecConfig(
          androidConfig: mockAndroidConfig,
          watcherMail: mockWatcherMail,
        );
        // Act
        final talsec = createTalsecForTesting(
          methodChannel.methodChannel,
          FakeEventChannel(),
          FakeEventChannel(),
        );

        // Assert
        expect(
          () => talsec.start(config),
          returnsNormally,
        );
      });

      test('Should start normally on iOS', () {
        // Arrange
        final methodChannel = MockMethodChannel(
          channelName: channelName,
          method: 'start',
        );

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final config = TalsecConfig(
          iosConfig: mockIOSConfig,
          watcherMail: mockWatcherMail,
        );
        // Act
        final talsec = createTalsecForTesting(
          methodChannel.methodChannel,
          FakeEventChannel(),
          FakeEventChannel(),
        );

        // Assert
        expect(
          () => talsec.start(config),
          returnsNormally,
        );
      });

      test('Should throw $ConfigurationException when config is not provided',
          () async {
        // Arrange
        final methodChannel = MockMethodChannel(
          channelName: channelName,
          method: 'start',
        );
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        // Act
        final talsec = createTalsecForTesting(
          methodChannel.methodChannel,
          FakeEventChannel(),
          FakeEventChannel(),
        );

        // Assert
        expect(
          () => talsec.start(TalsecConfig(watcherMail: mockWatcherMail)),
          throwsA(isA<ConfigurationException>()),
        );
      });

      test(
          'Should throw $ConfigurationException when config for given platform '
          'is null', () async {
        // Arrange
        final methodChannel = MockMethodChannel(
          channelName: channelName,
          method: 'start',
        );
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final config = TalsecConfig(
          iosConfig: mockIOSConfig,
          watcherMail: mockWatcherMail,
        );

        // Act
        final talsec = createTalsecForTesting(
          methodChannel.methodChannel,
          FakeEventChannel(),
          FakeEventChannel(),
        );

        // Assert
        expect(
          () => talsec.start(config),
          throwsA(isA<ConfigurationException>()),
        );
      });
    });
  });

  group('EventChannel', () {
    test('Should be able to listen and cancel stream', () async {
      // Act
      final stream = Talsec.instance.onThreatDetected;
      StreamSubscription<Threat>? subscription = stream.listen((_) {});

      // Assert
      subscription.pause();
      expect(subscription.isPaused, isTrue);

      subscription.resume();
      expect(subscription.isPaused, isFalse);

      await subscription.cancel();
      subscription = null;
    });

    test('Should receive stream of Threats', () {
      // Arrange
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/events'),
        data: [
          44506749,
          1115787534,
        ],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        eventChannel.eventChannel,
        FakeEventChannel(),
      );

      // Act
      final stream = talsec.onThreatDetected;

      //Assert
      expectLater(
        stream,
        emitsInOrder([
          Threat.privilegedAccess,
          Threat.appIntegrity,
          emitsDone,
        ]),
      );
    });

    test('Should transform every $PlatformException into $TalsecException', () {
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/events'),
        data: [],
        exceptions: [PlatformException(code: 'dummy-code')],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        eventChannel.eventChannel,
        FakeEventChannel(),
      );

      // Act
      final stream = talsec.onThreatDetected;

      // Assert
      expectLater(
        stream,
        emitsInOrder([
          emitsError(
            isA<TalsecException>().having(
              (e) => e.code,
              'code',
              'talsec-failure',
            ),
          ),
          emitsDone,
        ]),
      );
    });

    test('Should survive thrown exception when listening', () {
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/events'),
        data: [
          44506749,
          1115787534,
        ],
        exceptions: [PlatformException(code: 'dummy-code')],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        eventChannel.eventChannel,
        FakeEventChannel(),
      );

      // Act
      final stream = talsec.onThreatDetected;

      // Assert
      expectLater(
        stream,
        emitsInOrder([
          emitsError(isA<TalsecException>()),
          Threat.privilegedAccess,
          Threat.appIntegrity,
          emitsDone,
        ]),
      );
    });

    test('Should return same stream when called multiple times', () {
      final firstStream = Talsec.instance.onThreatDetected;
      final secondStream = Talsec.instance.onThreatDetected;

      expect(identical(firstStream, secondStream), isTrue);
    });
  });

  group('RaspExecutionState', () {
    test('Should receive stream of RaspExecutionState', () {
      // Arrange
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/execution_state'),
        data: [187429],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        FakeEventChannel(),
        eventChannel.eventChannel,
      );

      // Act
      final stream = talsec.onRaspExecutionState;

      //Assert
      expectLater(
        stream,
        emitsInOrder([
          RaspExecutionState.fastChecksFinished,
          emitsDone,
        ]),
      );
    });

    test('attachExecutionStateListener should invoke callback', () async {
      // Arrange
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/execution_state'),
        data: [187429],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        FakeEventChannel(),
        eventChannel.eventChannel,
      );

      final completer = Completer<void>();
      final callback = RaspExecutionStateCallback(
        onFastChecksFinished: completer.complete,
      );

      // Act
      await talsec.attachExecutionStateListener(callback);

      // Assert
      await expectLater(completer.future, completes);
    });

    test('Should receive Android-only execution states', () {
      // Arrange
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/execution_state'),
        data: [614702, 187429, 952318],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        FakeEventChannel(),
        eventChannel.eventChannel,
      );

      // Act
      final stream = talsec.onRaspExecutionState;

      // Assert
      expectLater(
        stream,
        emitsInOrder([
          RaspExecutionState.criticalChecksFinished,
          RaspExecutionState.fastChecksFinished,
          RaspExecutionState.postponedChecksFinished,
          emitsDone,
        ]),
      );
    });

    test('attachExecutionStateListener should invoke every callback', () async {
      // Arrange
      final eventChannel = MockEventChannel(
        eventChannel: const EventChannel('talsec.app/freerasp/execution_state'),
        data: [614702, 187429, 952318],
      );
      final talsec = createTalsecForTesting(
        FakeMethodChannel(),
        FakeEventChannel(),
        eventChannel.eventChannel,
      );

      final log = <String>[];
      final completer = Completer<void>();
      final callback = RaspExecutionStateCallback(
        onCriticalChecksFinished: () => log.add('critical'),
        onFastChecksFinished: () => log.add('all'),
        onPostponedChecksFinished: () {
          log.add('postponed');
          completer.complete();
        },
      );

      // Act
      await talsec.attachExecutionStateListener(callback);

      // Assert
      await expectLater(completer.future, completes);
      expect(log, ['critical', 'all', 'postponed']);
    });
  });

  group('Android-only APIs', () {
    // Tests run on the host, which is not Android.
    final talsec = createTalsecForTesting(
      FakeMethodChannel(),
      FakeEventChannel(),
      FakeEventChannel(),
    );

    final calls = <String, Future<Object?> Function()>{
      'blockScreenControl': () => talsec.blockScreenControl(enabled: true),
      'isScreenControlBlocked': talsec.isScreenControlBlocked,
      'blockOverlayWindows': () => talsec.blockOverlayWindows(enabled: true),
      'isOverlayWindowsBlocked': talsec.isOverlayWindowsBlocked,
      'startOngoingCallDetection': talsec.startOngoingCallDetection,
      'stopOngoingCallDetection': talsec.stopOngoingCallDetection,
      'addToWhitelist': () => talsec.addToWhitelist('com.example.app'),
      'getAppIcon': () => talsec.getAppIcon('com.example.app'),
    };

    for (final entry in calls.entries) {
      test('${entry.key} should throw outside Android', () {
        expect(entry.value, throwsA(isA<UnsupportedPlatformException>()));
      });
    }
  });
}
