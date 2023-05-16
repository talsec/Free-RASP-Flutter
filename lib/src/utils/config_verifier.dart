import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';

/// Class for verifying freeRASP Android config
class ConfigVerifier {
  const ConfigVerifier._();

  /// Verifies if provided [androidConfig] is valid.
  /// Verification is run only if current TargetPlatform is Android.
  /// Verifies [AndroidConfig.packageName] presence and validity of provided
  /// [AndroidConfig.signingCertHashes].
  ///
  /// Throws [ConfigurationException] if config is invalid.
  static void verifyAndroid(AndroidConfig androidConfig) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    if (androidConfig.packageName.isEmpty) {
      throw const ConfigurationException(
        message: 'packageName cannot be empty',
      );
    }

    if (androidConfig.signingCertHashes.isEmpty) {
      throw const ConfigurationException(
        message: 'signingCertHashes cannot be empty',
      );
    }

    _verifyHashesFormat(androidConfig.signingCertHashes);

    _verifyHashesValidity(androidConfig.signingCertHashes);
  }

  static void _verifyHashLength(String hash) {
    final bytes = base64.decode(hash);
    if (bytes.length != 32) {
      throw ConfigurationException(
        message: 'Invalid hash length: "$hash" is not 32 bytes long',
      );
    }
  }

  static void _verifyHashesValidity(List<String> hashesEncoded) {
    hashesEncoded.forEach(_verifyHashLength);
  }

  static void _verifyHashesFormat(List<String> hashesEncoded) {
    hashesEncoded.forEach(_verifyHashFormat);
  }

  static void _verifyHashFormat(String hash) {
    try {
      base64.decode(hash);
    } on FormatException {
      throw const ConfigurationException(
        message: 'SHA256 digest in Base64 is expected. '
            'Refer to the documentation for more detailed info.',
      );
    }
  }

  /// Verifies if provided [iOSConfig] is valid.
  /// Verification is run only if current TargetPlatform is iOS.
  /// Verifies [IOSConfig.bundleIds] and [IOSConfig.teamId] presence.
  ///
  /// Throws [ConfigurationException] if config is invalid.
  static void verifyIOS(IOSConfig iOSConfig) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    if (iOSConfig.bundleIds.isEmpty) {
      throw const ConfigurationException(
        message: 'bundle IDs cannot be empty',
      );
    }

    if (iOSConfig.teamId.isEmpty) {
      throw const ConfigurationException(
        message: 'team ID cannot be empty',
      );
    }
  }
}
