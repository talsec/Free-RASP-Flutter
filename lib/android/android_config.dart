import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  }) {
    _checkConfig(
      expectedPackageName,
      expectedSigningCertificateHashes,
      supportedAlternativeStores,
    );
  }

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

  static void _checkConfig(
    String? packageName,
    List<String>? signingHashes,
    List<String>? alternativeStores,
  ) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    assert(
      packageName != null,
      'expectedPackageName cannot be null.',
    );

    assert(
      signingHashes != null,
      'expectedSigningCertificateHashes cannot be null.',
    );

    assert(
      signingHashes!.isNotEmpty,
      'expectedSigningCertificateHashes cannot be empty.',
    );

    assert(
      alternativeStores != null,
      'supportedAlternativeStores cannot be null.',
    );

    assert(
      _areSigningHashesBase64(signingHashes!),
      'some of expectedSigningCertificateHashes are not in base64 form.',
    );

    assert(
      _areSigningHashesValid(signingHashes!),
      'some of expectedSigningCertificateHashes do NOT contain '
      'SHA-256 value.',
    );
  }
}
