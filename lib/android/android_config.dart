import 'dart:convert';
// ignore_for_file: tighten_type_of_initializing_formals

/// Model class for Android config.
///
/// Contains crucial data that are passed to native side in order to secure Android device.
class AndroidConfig {
  // Nullable because of older Flutter SDK versions
  // TODO: Rewrite when Flutter version >= 2.0
  // see issue https://github.com/talsec/Free-RASP-Flutter/issues/6
  final String? expectedPackageName;
  final List<String>? expectedSigningCertificateHashes;
  final List<String>? supportedAlternativeStores;

  /// Constructor checks whether [expectedPackageName] and
  /// [expectedSigningCertificateHash] are provided.
  /// Both arguments are MANDATORY.
  AndroidConfig(
      {required final this.expectedPackageName,
      required final this.expectedSigningCertificateHashes,
      final this.supportedAlternativeStores = const <String>[]})
      : assert(
            expectedPackageName != null, 'expectedPackageName cannot be null.'),
        assert(expectedSigningCertificateHashes != null,
            'expectedSigningCertificateHash cannot be null.'),
        assert(supportedAlternativeStores != null,
            'supportedAlternativeStores cannot be null.'),
        assert(_areSigningHashesBase64(expectedSigningCertificateHashes!),
            'expectedSigningCertificateHash is not in base64 form.'),
        assert(_areSigningHashesValid(expectedSigningCertificateHashes!),
            'expectedSigningCertificateHash does NOT contain SHA-256 value.');

  static bool _areSigningHashesBase64(final List<String> hashesEncoded) {
    for(var item in hashesEncoded ) {
      try {
        base64.decode(item);
      } on FormatException {
        return false;
      }
    }
    return true;
  }

  static bool _areSigningHashesValid(final List<String> hashesEncoded) {
    for(var item in hashesEncoded ) {
      final bytes = base64.decode(item);
      if (bytes.length != 32) {
        return false;
      }
    }
    return true;
  }
}
