import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/utils/utils.dart';

void main() {
  group('AndroidConfig', () {
    late AndroidConfig androidConfig;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      androidConfig = AndroidConfig(
        packageName: 'com.example.app',
        signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        supportedStores: ['adb'],
      );
    });

    test('Should create AndroidConfig instance', () {
      expect(androidConfig, isA<AndroidConfig>());
      expect(androidConfig.packageName, 'com.example.app');
      expect(
        androidConfig.signingCertHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfig.supportedStores, ['adb']);
    });

    test('Should create AndroidConfig instance with empty stores', () {
      final androidConfig = AndroidConfig(
        packageName: 'com.example.app',
        signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );

      expect(androidConfig, isA<AndroidConfig>());
      expect(androidConfig.packageName, 'com.example.app');
      expect(
        androidConfig.signingCertHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfig.supportedStores, <String>[]);
    });

    test('Should convert AndroidConfig to JSON', () {
      final json = androidConfig.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['packageName'], 'com.example.app');
      expect(
        json['signingCertHashes'],
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(json['supportedStores'], ['adb']);
    });

    test('Should create AndroidConfig instance from JSON', () {
      final json = {
        'packageName': 'com.example.app',
        'signingCertHashes': ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        'supportedStores': ['adb'],
      };

      final androidConfigFromJson = AndroidConfig.fromJson(json);

      expect(androidConfigFromJson, isA<AndroidConfig>());
      expect(androidConfigFromJson.packageName, 'com.example.app');
      expect(
        androidConfigFromJson.signingCertHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfigFromJson.supportedStores, ['adb']);
    });

    test('Should create AndroidConfig instance with empty stores from JSON',
        () {
      final json = {
        'packageName': 'com.example.app',
        'signingCertHashes': ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      };

      final androidConfigFromJson = AndroidConfig.fromJson(json);

      expect(androidConfigFromJson, isA<AndroidConfig>());
      expect(androidConfigFromJson.packageName, 'com.example.app');
      expect(
        androidConfigFromJson.signingCertHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfigFromJson.supportedStores, <String>[]);
    });

    test('Should verify AndroidConfig using ConfigVerifier', () {
      expect(
        () => ConfigVerifier.verifyAndroid(androidConfig),
        returnsNormally,
      );
    });

    test('Should throw ConfigurationException when packageName is empty', () {
      expect(
        () => AndroidConfig(
          packageName: '',
          signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw ConfigurationException when signingHash is empty', () {
      expect(
        () => AndroidConfig(
          packageName: 'com.example.app',
          signingCertHashes: [],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw ConfigurationException when signingHash is invalid', () {
      expect(
        () => AndroidConfig(
          packageName: 'com.example.app',
          signingCertHashes: ['invalid'],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should serialize suspiciousAppDetectionConfig to JSON', () {
      final config = AndroidConfig(
        packageName: 'com.example.app',
        signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        suspiciousAppDetectionConfig: const SuspiciousAppDetectionConfig(
          packageNames: ['com.malware.app'],
          malwareScanScope: MalwareScanScope(scanScope: ScopeType.all),
          reasonMode: ReasonMode.all,
        ),
      );

      final json = config.toJson();
      final detection =
          json['suspiciousAppDetectionConfig'] as Map<String, dynamic>;

      expect(detection['packageNames'], ['com.malware.app']);
      expect(
        (detection['malwareScanScope'] as Map<String, dynamic>)['scanScope'],
        'ALL',
      );
      expect(detection['reasonMode'], 'ALL');
    });

    test('Should omit suspiciousAppDetectionConfig from JSON when null', () {
      final json = androidConfig.toJson();

      expect(json.containsKey('suspiciousAppDetectionConfig'), isFalse);
    });

    test('Should deserialize suspiciousAppDetectionConfig from JSON', () {
      final json = {
        'packageName': 'com.example.app',
        'signingCertHashes': ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        'suspiciousAppDetectionConfig': {
          'packageNames': ['com.malware.app'],
          'malwareScanScope': {'scanScope': 'SIDELOADED_AND_OEM'},
          'reasonMode': 'ALL',
        },
      };

      final config = AndroidConfig.fromJson(json);
      final detection = config.suspiciousAppDetectionConfig!;

      expect(detection.packageNames, ['com.malware.app']);
      expect(detection.malwareScanScope.scanScope, ScopeType.sideloadedAndOem);
      expect(detection.reasonMode, ReasonMode.all);
    });
  });
}
