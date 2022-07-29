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
  final String? expectedSigningCertificateHash;
  final List<String>? supportedAlternativeStores;

  /// Constructor checks whether [expectedPackageName] and
  /// [expectedSigningCertificateHash] are provided.
  /// Both arguments are MANDATORY.
  AndroidConfig(
      {required final this.expectedPackageName,
      required final this.expectedSigningCertificateHash,
      final this.supportedAlternativeStores = const <String>[]})
      : assert(
            expectedPackageName != null, 'expectedPackageName cannot be null.'),
        assert(expectedSigningCertificateHash != null,
            'expectedSigningCertificateHash cannot be null.'),
        assert(supportedAlternativeStores != null,
            'supportedAlternativeStores cannot be null.'),
        assert(_isSigningHashBase64(expectedSigningCertificateHash!),
            'expectedSigningCertificateHash is not in base64 form.'),
        assert(_isSigningHashValid(expectedSigningCertificateHash!),
            'expectedSigningCertificateHash does NOT contain SHA-256 value.');

  static bool _isSigningHashBase64(final String hashEncoded) {
    try {
      base64.decode(hashEncoded);
      return true;
    } on FormatException {
      return false;
    }
  }

  static bool _isSigningHashValid(final String hashEncoded) {
    final bytes = base64.decode(hashEncoded);
    return bytes.length == 32;
  }
}
