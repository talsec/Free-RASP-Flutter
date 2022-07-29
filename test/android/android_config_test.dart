import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/android/android_config.dart';

void main() {
  AndroidConfig createConfiguration(final String? packageName,
      final String? signingHash, final List<String>? alternativeStores) {
    return AndroidConfig(
      expectedPackageName: packageName,
      expectedSigningCertificateHash: signingHash,
      supportedAlternativeStores: alternativeStores,
    );
  }

  AndroidConfig createDefaultConfiguration(
      final String? packageName, final String? signingHash) {
    return AndroidConfig(
      expectedPackageName: packageName,
      expectedSigningCertificateHash: signingHash,
    );
  }

  const String packageName = 'packageName';
  const String signingHash = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';
  const List<String> alternativeStores = ['someAppStore'];

  test('Object should be created', () {
    expect(
        () => createConfiguration(packageName, signingHash, alternativeStores),
        returnsNormally);
  });

  group('Null checks', () {
    test('Only expectedPackageName is provided', () {
      expect(() => createConfiguration(packageName, null, alternativeStores),
          throwsAssertionError);
      expect(() => createConfiguration(packageName, signingHash, null),
          throwsAssertionError);
      expect(() => createConfiguration(packageName, null, null),
          throwsAssertionError);
    });

    test('Only expectedSigningHash is provided', () {
      expect(() => createConfiguration(null, signingHash, alternativeStores),
          throwsAssertionError);
      expect(() => createConfiguration(packageName, signingHash, null),
          throwsAssertionError);
      expect(() => createConfiguration(null, signingHash, null),
          throwsAssertionError);
    });

    test('Only alternativeStores is provided', () {
      expect(() => createConfiguration(null, signingHash, alternativeStores),
          throwsAssertionError);
      expect(() => createConfiguration(packageName, null, alternativeStores),
          throwsAssertionError);
      expect(() => createConfiguration(null, null, alternativeStores),
          throwsAssertionError);
    });

    test('Nothing is provided', () {
      expect(() => createConfiguration(null, null, null), throwsAssertionError);
    });

    test('Relying on default parameters', () {
      expect(
          () => createDefaultConfiguration(null, null), throwsAssertionError);
      expect(() => createDefaultConfiguration(packageName, null),
          throwsAssertionError);
      expect(() => createDefaultConfiguration(null, signingHash),
          throwsAssertionError);
      expect(() => createDefaultConfiguration(packageName, signingHash),
          returnsNormally);
    });
  });

  group('Hash checks', () {
    test('Invalid base64 value', () {
      expect(() => createDefaultConfiguration(packageName, '0:0:0:0'),
          throwsAssertionError);
    });

    test('Valid base64 value but not SHA-256 value', () {
      expect(() => createDefaultConfiguration(packageName, 'AAA='),
          throwsAssertionError);
    });

    test('Valid base64 value', () {
      expect(() => createDefaultConfiguration(packageName, signingHash),
          returnsNormally);
    });
  });
}
