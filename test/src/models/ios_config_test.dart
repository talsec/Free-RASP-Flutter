import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/utils/utils.dart';

void main() {
  group('IOSConfig', () {
    late IOSConfig iosConfig;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      iosConfig = IOSConfig(
        bundleIds: ['com.example.app1', 'com.example.app2'],
        teamId: 'team123',
      );
    });

    test('Should create IOSConfig instance', () {
      expect(iosConfig, isA<IOSConfig>());
      expect(iosConfig.bundleIds, ['com.example.app1', 'com.example.app2']);
      expect(iosConfig.teamId, 'team123');
    });

    test('Should convert IOSConfig to JSON', () {
      final json = iosConfig.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['bundleIds'], ['com.example.app1', 'com.example.app2']);
      expect(json['teamId'], 'team123');
    });

    test('Should create IOSConfig instance from JSON', () {
      final json = {
        'bundleIds': ['com.example.app1', 'com.example.app2'],
        'teamId': 'team123',
      };

      final iosConfigFromJson = IOSConfig.fromJson(json);

      expect(iosConfigFromJson, isA<IOSConfig>());
      expect(
        iosConfigFromJson.bundleIds,
        ['com.example.app1', 'com.example.app2'],
      );
      expect(iosConfigFromJson.teamId, 'team123');
    });

    test('Should verify IOSConfig using ConfigVerifier', () {
      expect(() => ConfigVerifier.verifyIOS(iosConfig), returnsNormally);
    });

    test('Should throw ConfigurationException when bundleIds is empty', () {
      expect(
        () => IOSConfig(bundleIds: [], teamId: 'team123'),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw ConfigurationException when teamId is empty', () {
      expect(
        () => IOSConfig(bundleIds: ['com.example.app1'], teamId: ''),
        throwsA(isA<ConfigurationException>()),
      );
    });
  });
}
