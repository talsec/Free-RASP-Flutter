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
        certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        supportedAlternativeStores: ['adb'],
      );
    });

    test('Should create AndroidConfig instance', () {
      expect(androidConfig, isA<AndroidConfig>());
      expect(androidConfig.packageName, 'com.example.app');
      expect(
        androidConfig.certificateHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfig.supportedAlternativeStores, ['adb']);
    });

    test('Should create AndroidConfig instance with empty stores', () {
      final androidConfig = AndroidConfig(
        packageName: 'com.example.app',
        certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );

      expect(androidConfig, isA<AndroidConfig>());
      expect(androidConfig.packageName, 'com.example.app');
      expect(
        androidConfig.certificateHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfig.supportedAlternativeStores, <String>[]);
    });

    test('Should convert AndroidConfig to JSON', () {
      final json = androidConfig.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['packageName'], 'com.example.app');
      expect(
        json['certificateHashes'],
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(json['supportedAlternativeStores'], ['adb']);
    });

    test('Should create AndroidConfig instance from JSON', () {
      final json = {
        'packageName': 'com.example.app',
        'certificateHashes': ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        'supportedAlternativeStores': ['adb'],
      };

      final androidConfigFromJson = AndroidConfig.fromJson(json);

      expect(androidConfigFromJson, isA<AndroidConfig>());
      expect(androidConfigFromJson.packageName, 'com.example.app');
      expect(
        androidConfigFromJson.certificateHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfigFromJson.supportedAlternativeStores, ['adb']);
    });

    test('Should create AndroidConfig instance with empty stores from JSON',
        () {
      final json = {
        'packageName': 'com.example.app',
        'certificateHashes': ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      };

      final androidConfigFromJson = AndroidConfig.fromJson(json);

      expect(androidConfigFromJson, isA<AndroidConfig>());
      expect(androidConfigFromJson.packageName, 'com.example.app');
      expect(
        androidConfigFromJson.certificateHashes,
        ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
      );
      expect(androidConfigFromJson.supportedAlternativeStores, <String>[]);
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
          certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw ConfigurationException when signingHash is empty', () {
      expect(
        () => AndroidConfig(
          packageName: 'com.example.app',
          certificateHashes: [],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw ConfigurationException when signingHash is invalid', () {
      expect(
        () => AndroidConfig(
          packageName: 'com.example.app',
          certificateHashes: ['invalid'],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should serialize suspiciousAppDetectionConfig to JSON', () {
      final config = AndroidConfig(
        packageName: 'com.example.app',
        certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        suspiciousAppDetectionConfig: const SuspiciousAppDetectionConfig(
          packageNames: ['com.malware.app'],
          scanScope: ScanScope(scopeType: ScopeType.all),
          reasonMode: ReasonMode.all,
        ),
      );

      final json = config.toJson();
      final detection =
          json['suspiciousAppDetectionConfig'] as Map<String, dynamic>;

      expect(detection['packageNames'], ['com.malware.app']);
      expect(
        (detection['scanScope'] as Map<String, dynamic>)['scopeType'],
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
        'certificateHashes': ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
        'suspiciousAppDetectionConfig': {
          'packageNames': ['com.malware.app'],
          'scanScope': {'scopeType': 'SIDELOADED_AND_OEM'},
          'reasonMode': 'ALL',
        },
      };

      final config = AndroidConfig.fromJson(json);
      final detection = config.suspiciousAppDetectionConfig!;

      expect(detection.packageNames, ['com.malware.app']);
      expect(detection.scanScope.scopeType, ScopeType.sideloadedAndOem);
      expect(detection.reasonMode, ReasonMode.all);
    });
  });
}
