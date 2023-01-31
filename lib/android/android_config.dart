import 'dart:convert';
// ignore_for_file: tighten_type_of_initializing_formals

/// A class which holds Android config.
///
/// These data are used to check if device is trusted.
///
/// On initialization, these data are passed to native code which then
/// initializes Talsec.
class AndroidConfig {
  /// Constructor checks whether [expectedPackageName] and
  /// [expectedSigningCertificateHashes] are provided.
  /// Both arguments are MANDATORY.
  AndroidConfig({
    required this.expectedPackageName,
    required this.expectedSigningCertificateHashes,
    this.supportedAlternativeStores = const <String>[],
  })  : assert(
          expectedPackageName != null,
          'expectedPackageName cannot be null.',
        ),
        assert(
          expectedSigningCertificateHashes != null,
          'expectedSigningCertificateHashes cannot be null.',
        ),
        assert(
          expectedSigningCertificateHashes!.isNotEmpty,
          'expectedSigningCertificateHashes cannot be empty.',
        ),
        assert(
          supportedAlternativeStores != null,
          'supportedAlternativeStores cannot be null.',
        ),
        assert(
          _areSigningHashesBase64(expectedSigningCertificateHashes!),
          'some of expectedSigningCertificateHashes are not in base64 form.',
        ),
        assert(
            _areSigningHashesValid(expectedSigningCertificateHashes!),
            'some of expectedSigningCertificateHashes do NOT contain '
            'SHA-256 value.');

  // Nullable because of older Flutter SDK versions
  // ignore: flutter_style_todos
  // TODO: Rewrite when Flutter version >= 2.0
  // see issue https://github.com/talsec/Free-RASP-Flutter/issues/6
  /// Package name of the application.
  final String? expectedPackageName;

  /// List of expected signing hashes.
  final List<String>? expectedSigningCertificateHashes;

  /// List of supported sources where application can be installed from.
  final List<String>? supportedAlternativeStores;

  static bool _areSigningHashesBase64(List<String> hashesEncoded) {
    for (final item in hashesEncoded) {
      try {
        base64.decode(item);
      } on FormatException {
        return false;
      }
    }
    return true;
  }

  static bool _areSigningHashesValid(List<String> hashesEncoded) {
    for (final item in hashesEncoded) {
      final bytes = base64.decode(item);
      if (bytes.length != 32) {
        return false;
      }
    }
    return true;
  }
}
