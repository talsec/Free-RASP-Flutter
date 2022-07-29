import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/utils/utils.dart';

void main() {
  group('Sha256Converter', () {
    group('toBase64', () {
      group('providing valid value', () {
        late String validShaValue;
        late String validBase64Value;

        setUp(() {
          validShaValue =
              '00:AA:11:BB:22:CC:33:DD:44:EE:55:FF:66:AA:77:BB:88:CC:99:DD:00:EE:11:FF:22:AA:33:BB:44:CC:55:DD';
          validBase64Value = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';
        });

        test('standard SHA-256 value', () {
          expect(hashConverter.fromSha256toBase64(validShaValue),
              equals(validBase64Value));

          validShaValue = validShaValue.replaceAll(':', '');
          expect(hashConverter.fromSha256toBase64(validShaValue),
              equals(validBase64Value));
        });

        test('lowerCase SHA-256 value', () {
          validShaValue = validShaValue.toLowerCase();
          expect(hashConverter.fromSha256toBase64(validShaValue),
              equals(validBase64Value));

          validShaValue = validShaValue.replaceAll(':', '');
          expect(hashConverter.fromSha256toBase64(validShaValue),
              equals(validBase64Value));
        });
      });

      group('providing invalid value', () {
        late String validShaValue;

        setUp(() {
          validShaValue =
              '00:AA:11:BB:22:CC:33:DD:44:EE:55:FF:66:AA:77:BB:88:CC:99:DD:00:EE:11:FF:22:AA:33:BB:44:CC:55:DD';
        });

        test('unknown delimiter', () {
          final String invalidShaValue = validShaValue.replaceAll(':', '|');
          expect(() => hashConverter.fromSha256toBase64(invalidShaValue),
              throwsA(isA<FormatException>()));
        });

        test('invalid length', () {
          final String invalidLongerShaValue = validShaValue + 'A';
          expect(() => hashConverter.fromSha256toBase64(invalidLongerShaValue),
              throwsA(isA<FormatException>()));

          final String invalidLongerStrippedShaValue =
              invalidLongerShaValue.replaceAll(':', '');
          expect(
              () => hashConverter
                  .fromSha256toBase64(invalidLongerStrippedShaValue),
              throwsA(isA<FormatException>()));

          final String invalidShorterShaValue =
              validShaValue.replaceFirst('F', '');
          expect(() => hashConverter.fromSha256toBase64(invalidShorterShaValue),
              throwsA(isA<FormatException>()));

          final String invalidShorterStrippedShaValue =
              invalidShorterShaValue.replaceAll(':', '');
          expect(
              () => hashConverter
                  .fromSha256toBase64(invalidShorterStrippedShaValue),
              throwsA(isA<FormatException>()));
        });

        test('contains non hex byte', () {
          final String invalidHexShaValue =
              validShaValue.replaceFirst('F', '@');
          expect(() => hashConverter.fromSha256toBase64(invalidHexShaValue),
              throwsA(isA<FormatException>()));

          final String invalidHexStrippedShaValue =
              invalidHexShaValue.replaceFirst(':', '');
          expect(
              () =>
                  hashConverter.fromSha256toBase64(invalidHexStrippedShaValue),
              throwsA(isA<FormatException>()));
        });

        test('is SHA-1 value', () {
          const String sha1Value =
              '00:AA:11:BB:22:CC:33:DD:44:EE:55:FF:66:AA:77:BB:88:CC:99:DD';
          expect(() => hashConverter.fromSha256toBase64(sha1Value),
              throwsA(isA<FormatException>()));
        });
      });
    });

    group('fromBase64', () {
      group('providing valid value', () {
        late String validShaValue;
        late String validBase64Value;

        setUp(() {
          validShaValue =
              '00:AA:11:BB:22:CC:33:DD:44:EE:55:FF:66:AA:77:BB:88:CC:99:DD:00:EE:11:FF:22:AA:33:BB:44:CC:55:DD';
          validBase64Value = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';
        });

        test('standard base64 value which is sha-256', () {
          expect(hashConverter.fromBase64toSha256(validBase64Value),
              equals(validShaValue));
        });
      });

      group('providing invalid value', () {
        late String validBase64Value;

        setUp(() {
          validBase64Value = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';
        });

        test('invalid base64 value', () {
          validBase64Value = validBase64Value.replaceFirst('/', '');
          expect(() => hashConverter.fromBase64toSha256(validBase64Value),
              throwsA(isA<FormatException>()));
        });

        test('valid base64 value but invalid sha-256 value', () {
          validBase64Value = 'q83vEjRWq83vEjRW';
          expect(base64.decode(validBase64Value), isNotNull);
          expect(() => hashConverter.fromBase64toSha256(validBase64Value),
              throwsA(isA<FormatException>()));
        });
      });
    });
  });
}
