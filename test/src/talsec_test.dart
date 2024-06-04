// ignore_for_file: cascade_invocations, sdk_version_since

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

import '../test_utils/test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannel', () {
    final log = <MethodCall>[];
    const channelName = 'talsec.app/freerasp/methods';

    const mockWatcherMail = 'your_mail@example.com';
    final mockAndroidConfig = AndroidConfig(
      packageName: 'com.aheaditec.freeraspExample',
      signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      supportedStores: ['com.sec.android.app.samsungapps'],
    );
    final mockIOSConfig = IOSConfig(
      bundleIds: ['com.aheaditec.freeraspExample'],
      teamId: 'M8AK35...',
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
        final talsec =
            Talsec.private(methodChannel.methodChannel, FakeEventChannel());

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
        final talsec =
            Talsec.private(methodChannel.methodChannel, FakeEventChannel());

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
        final talsec =
            Talsec.private(methodChannel.methodChannel, FakeEventChannel());

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
        final talsec =
            Talsec.private(methodChannel.methodChannel, FakeEventChannel());

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
        eventChannel: Talsec.instance.eventChannel,
        data: [
          44506749,
          1115787534,
        ],
      );
      final talsec =
          Talsec.private(FakeMethodChannel(), eventChannel.eventChannel);

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
        eventChannel: Talsec.instance.eventChannel,
        data: [],
        exceptions: [PlatformException(code: 'dummy-code')],
      );
      final talsec =
          Talsec.private(FakeMethodChannel(), eventChannel.eventChannel);

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
        eventChannel: Talsec.instance.eventChannel,
        data: [
          44506749,
          1115787534,
        ],
        exceptions: [PlatformException(code: 'dummy-code')],
      );
      final talsec =
          Talsec.private(FakeMethodChannel(), eventChannel.eventChannel);

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
}
