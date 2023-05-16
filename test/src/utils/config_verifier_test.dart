import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/utils/config_verifier.dart';

void main() {
  group('Verify Android config', () {
    test('Should return normally when valid parameters provided', () {
      // Arrange
      const validHash = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';
      final config = AndroidConfig(
        packageName: 'packageName',
        signingCertHashes: [validHash],
      );

      // Act & Assert
      expect(() => ConfigVerifier.verifyAndroid(config), returnsNormally);
    });

    test('Should throw $ConfigurationException when invalid hash format', () {
      // Arrange
      const invalidHash = 'invalidHash';

      // Act & Assert
      expect(
        () => AndroidConfig(
          packageName: 'packageName',
          signingCertHashes: [invalidHash],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test(
        'Should throw $ConfigurationException when one of hashes has invalid '
        'format', () {
      // Arrange
      const validHash = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';
      const invalidHash = 'invalidHash';

      // Act & Assert
      expect(
        () => AndroidConfig(
          packageName: 'packageName',
          signingCertHashes: [validHash, invalidHash],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw $ConfigurationException when cert hashes are empty', () {
      expect(
        () => AndroidConfig(
          packageName: 'packageName',
          signingCertHashes: [],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw $ConfigurationException when package name is empty', () {
      // Arrange
      const validHash = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';

      // Act & Assert
      expect(
        () => AndroidConfig(
          packageName: '',
          signingCertHashes: [validHash],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should encode TalsecConfig to String', () {
      // Arrange
      const expectedString =
          '{"androidConfig":{"packageName":"com.aheaditec.freeraspExample","signingCertHashes":["AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0="],"supportedStores":["com.sec.android.app.samsungapps"]},"iosConfig":{"bundleIds":["com.aheaditec.freeraspExample"],"teamId":"M8AK35..."},"watcherMail":"test_mail@example.com","isProd":false}';
      final config = TalsecConfig(
        androidConfig: AndroidConfig(
          packageName: 'com.aheaditec.freeraspExample',
          signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
          supportedStores: ['com.sec.android.app.samsungapps'],
        ),
        iosConfig: IOSConfig(
          bundleIds: ['com.aheaditec.freeraspExample'],
          teamId: 'M8AK35...',
        ),
        watcherMail: 'test_mail@example.com',
        isProd: false,
      );

      // Act & Assert
      expect(
        jsonEncode(config.toJson()),
        equals(expectedString),
      );
    });

    test('Should decode String to TalsecConfig', () {
      // Arrange
      final expectedConfig = TalsecConfig(
        androidConfig: AndroidConfig(
          packageName: 'com.aheaditec.freeraspExample',
          signingCertHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
          supportedStores: ['com.sec.android.app.samsungapps'],
        ),
        iosConfig: IOSConfig(
          bundleIds: ['com.aheaditec.freeraspExample'],
          teamId: 'M8AK35...',
        ),
        watcherMail: 'test_mail@example.com',
        isProd: false,
      );

      const config =
          '{"androidConfig":{"packageName":"com.aheaditec.freeraspExample","signingCertHashes":["AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0="],"supportedStores":["com.sec.android.app.samsungapps"]},"iosConfig":{"bundleIds":["com.aheaditec.freeraspExample"],"teamId":"M8AK35..."},"watcherMail":"test_mail@example.com","isProd":false}';

      // Act
      final actualConfig =
          TalsecConfig.fromJson(jsonDecode(config) as Map<String, dynamic>);

      // Assert
      expect(
        actualConfig.watcherMail,
        equals(expectedConfig.watcherMail),
      );
      expect(
        actualConfig.isProd,
        equals(expectedConfig.isProd),
      );
      expect(
        actualConfig.androidConfig?.signingCertHashes,
        equals(expectedConfig.androidConfig?.signingCertHashes),
      );
      expect(
        actualConfig.iosConfig?.bundleIds,
        equals(expectedConfig.iosConfig?.bundleIds),
      );
    });
  });
}
