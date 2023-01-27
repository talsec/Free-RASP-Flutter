import 'dart:convert';

import 'package:convert/convert.dart';

/// Static variable for [HashConverter].
const hashConverter = HashConverter._();

/// A class for checking and converting SHA-256 hashes.
///
/// Class is initialized as a static variable [hashConverter].
class HashConverter {
  const HashConverter._();

  /// Converts given SHA-256 hash [String] to Base64 format [String].
  ///
  /// Throws [FormatException] if given [value] is not a valid SHA-256 hash.
  ///
  /// Returns base64 encoded [String].
  String fromSha256toBase64(String value) {
    final formattedValue = value.replaceAll(':', '');

    if (!isValidSha256Format(formattedValue)) {
      throw const FormatException('Value is not SHA-256');
    }

    final bytes = hex.decode(formattedValue);
    final base64Form = base64.encode(bytes);

    return base64Form;
  }

  /// Converts given Base64 [String] to SHA-256 format [String].
  ///
  /// Throws [FormatException] if given [value] cannot be a valid SHA-256 hash.
  ///
  /// Returns base64 encoded [String].
  String fromBase64toSha256(String value) {
    final List<int> bytes = base64.decode(value);
    final hexForm = hex.encode(bytes);

    if (!isValidSha256Format(hexForm)) {
      throw const FormatException('Value is not SHA-256');
    }

    final sha256Form = _formatSha(hexForm);
    return sha256Form;
  }

  String _formatSha(String value) {
    final formattedValue = value.toUpperCase();
    const delimiter = ':';

    final buffer = StringBuffer();
    for (var i = 0; i < formattedValue.length; i = i + 2) {
      buffer.write(
        formattedValue.substring(i, i + 2) +
            (i == formattedValue.length - 2 ? '' : delimiter),
      );
    }

    return buffer.toString();
  }

  /// Checks whether given [String] is valid SHA-256 format.
  ///
  /// Returns true if given [String] is valid SHA-256 format, otherwise false.
  bool isValidSha256Format(String value) {
    final validator = RegExp('[A-Fa-f0-9]{64}');
    return validator.hasMatch(value);
  }
}
