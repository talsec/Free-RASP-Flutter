import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/android/android_config.dart';

void main() {
  AndroidConfig createConfiguration(
    String? packageName,
    List<String>? signingHashes,
    List<String>? alternativeStores,
  ) {
    return AndroidConfig(
      expectedPackageName: packageName,
      expectedSigningCertificateHashes: signingHashes,
      supportedAlternativeStores: alternativeStores,
    );
  }

  AndroidConfig createDefaultConfiguration(
    String? packageName,
    List<String>? signingHashes,
  ) {
    return AndroidConfig(
      expectedPackageName: packageName,
      expectedSigningCertificateHashes: signingHashes,
    );
  }

  const packageName = 'packageName';
  const signingHashes = <String>[
    'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='
  ];
  const alternativeStores = <String>['someAppStore'];

  test('Object should be created', () {
    expect(
      () => createConfiguration(packageName, signingHashes, alternativeStores),
      returnsNormally,
    );
  });

  group('Null checks', () {
    test('Only expectedPackageName is provided', () {
      expect(
        () => createConfiguration(packageName, null, alternativeStores),
        throwsAssertionError,
      );
      expect(
        () => createConfiguration(packageName, signingHashes, null),
        throwsAssertionError,
      );
      expect(
        () => createConfiguration(packageName, null, null),
        throwsAssertionError,
      );
    });

    test('Only expectedsigningHashes is provided', () {
      expect(
        () => createConfiguration(null, signingHashes, alternativeStores),
        throwsAssertionError,
      );
      expect(
        () => createConfiguration(packageName, signingHashes, null),
        throwsAssertionError,
      );
      expect(
        () => createConfiguration(null, signingHashes, null),
        throwsAssertionError,
      );
    });

    test('Only alternativeStores is provided', () {
      expect(
        () => createConfiguration(null, signingHashes, alternativeStores),
        throwsAssertionError,
      );
      expect(
        () => createConfiguration(packageName, null, alternativeStores),
        throwsAssertionError,
      );
      expect(
        () => createConfiguration(null, null, alternativeStores),
        throwsAssertionError,
      );
    });

    test('Nothing is provided', () {
      expect(() => createConfiguration(null, null, null), throwsAssertionError);
    });

    test('Relying on default parameters', () {
      expect(
        () => createDefaultConfiguration(null, null),
        throwsAssertionError,
      );
      expect(
        () => createDefaultConfiguration(packageName, null),
        throwsAssertionError,
      );
      expect(
        () => createDefaultConfiguration(null, signingHashes),
        throwsAssertionError,
      );
      expect(
        () => createDefaultConfiguration(packageName, signingHashes),
        returnsNormally,
      );
    });
  });

  group('Hash checks', () {
    test('Invalid base64 value', () {
      expect(
        () => createDefaultConfiguration(packageName, ['0:0:0:0']),
        throwsAssertionError,
      );
    });

    test('Valid base64 value but not SHA-256 value', () {
      expect(
        () => createDefaultConfiguration(packageName, ['AAA=']),
        throwsAssertionError,
      );
    });

    test('Valid base64 value', () {
      expect(
        () => createDefaultConfiguration(packageName, signingHashes),
        returnsNormally,
      );
    });
  });
}
