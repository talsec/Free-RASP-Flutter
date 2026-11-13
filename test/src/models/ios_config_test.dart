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
        appBundleIds: ['com.example.app1', 'com.example.app2'],
        appTeamId: 'team123',
      );
    });

    test('Should create IOSConfig instance', () {
      expect(iosConfig, isA<IOSConfig>());
      expect(iosConfig.appBundleIds, ['com.example.app1', 'com.example.app2']);
      expect(iosConfig.appTeamId, 'team123');
    });

    test('Should convert IOSConfig to JSON', () {
      final json = iosConfig.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['appBundleIds'], ['com.example.app1', 'com.example.app2']);
      expect(json['appTeamId'], 'team123');
    });

    test('Should create IOSConfig instance from JSON', () {
      final json = {
        'appBundleIds': ['com.example.app1', 'com.example.app2'],
        'appTeamId': 'team123',
      };

      final iosConfigFromJson = IOSConfig.fromJson(json);

      expect(iosConfigFromJson, isA<IOSConfig>());
      expect(
        iosConfigFromJson.appBundleIds,
        ['com.example.app1', 'com.example.app2'],
      );
      expect(iosConfigFromJson.appTeamId, 'team123');
    });

    test('Should verify IOSConfig using ConfigVerifier', () {
      expect(() => ConfigVerifier.verifyIOS(iosConfig), returnsNormally);
    });

    test('Should throw ConfigurationException when appBundleIds is empty', () {
      expect(
        () => IOSConfig(appBundleIds: [], appTeamId: 'team123'),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw ConfigurationException when appTeamId is empty', () {
      expect(
        () => IOSConfig(appBundleIds: ['com.example.app1'], appTeamId: ''),
        throwsA(isA<ConfigurationException>()),
      );
    });
  });
}
