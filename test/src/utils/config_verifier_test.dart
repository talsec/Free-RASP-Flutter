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
        certificateHashes: [validHash],
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
          certificateHashes: [invalidHash],
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
          certificateHashes: [validHash, invalidHash],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should throw $ConfigurationException when cert hashes are empty', () {
      expect(
        () => AndroidConfig(
          packageName: 'packageName',
          certificateHashes: [],
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
          certificateHashes: [validHash],
        ),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('Should encode TalsecConfig to String', () {
      // Arrange
      const expectedString =
          '{"androidConfig":{"packageName":"com.aheaditec.freeraspExample","certificateHashes":["AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0="],"supportedAlternativeStores":["com.sec.android.app.samsungapps"]},"iosConfig":{"appBundleIds":["com.aheaditec.freeraspExample"],"appTeamId":"M8AK35..."},"watcherMail":"test_mail@example.com","isProd":false}';
      final config = TalsecConfig(
        androidConfig: AndroidConfig(
          packageName: 'com.aheaditec.freeraspExample',
          certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
          supportedAlternativeStores: ['com.sec.android.app.samsungapps'],
        ),
        iosConfig: IOSConfig(
          appBundleIds: ['com.aheaditec.freeraspExample'],
          appTeamId: 'M8AK35...',
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
          certificateHashes: ['AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='],
          supportedAlternativeStores: ['com.sec.android.app.samsungapps'],
        ),
        iosConfig: IOSConfig(
          appBundleIds: ['com.aheaditec.freeraspExample'],
          appTeamId: 'M8AK35...',
        ),
        watcherMail: 'test_mail@example.com',
        isProd: false,
      );

      const config =
          '{"androidConfig":{"packageName":"com.aheaditec.freeraspExample","certificateHashes":["AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0="],"supportedAlternativeStores":["com.sec.android.app.samsungapps"]},"iosConfig":{"appBundleIds":["com.aheaditec.freeraspExample"],"appTeamId":"M8AK35..."},"watcherMail":"test_mail@example.com","isProd":false}';

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
        actualConfig.androidConfig?.certificateHashes,
        equals(expectedConfig.androidConfig?.certificateHashes),
      );
      expect(
        actualConfig.iosConfig?.appBundleIds,
        equals(expectedConfig.iosConfig?.appBundleIds),
      );
    });
  });
}
