import 'dart:convert';

import 'package:convert/convert.dart';

const hashConverter = HashConverter._();

class HashConverter {
  const HashConverter._();

  String fromSha256toBase64(final String value) {
    final String formattedValue = value.replaceAll(':', '');

    if (!isValidSha256Format(formattedValue)) {
      throw const FormatException('Value is not SHA-256');
    }

    final List<int> bytes = hex.decode(formattedValue);
    final String base64Form = base64.encode(bytes);

    return base64Form;
  }

  String fromBase64toSha256(final String value) {
    final List<int> bytes = base64.decode(value);
    final String hexForm = hex.encode(bytes);

    if (!isValidSha256Format(hexForm)) {
      throw const FormatException('Value is not SHA-256');
    }

    final String sha256Form = _formatSha(hexForm);
    return sha256Form;
  }

  String _formatSha(final String value) {
    final String formattedValue = value.toUpperCase();
    const String delimiter = ':';

    final buffer = StringBuffer();
    for (int i = 0; i < formattedValue.length; i = i + 2) {
      buffer.write(formattedValue.substring(i, i + 2) +
          (i == formattedValue.length - 2 ? '' : delimiter));
    }

    return buffer.toString();
  }

  bool isValidSha256Format(final String value) {
    final validator = RegExp(r'[A-Fa-f0-9]{64}');
    return validator.hasMatch(value);
  }
}
