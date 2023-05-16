import 'package:flutter/services.dart';

/// A base exception class for Talsec exceptions.
///
/// This exception class implements the [Exception] interface and provides
/// a basic structure for Talsec-specific exceptions. It includes an error
/// [code], an optional [message], and an optional [stackTrace]. The default
/// value for the [code] parameter is 'talsec-failure'.
class TalsecException implements Exception {
  /// Constructs an instance of [TalsecException].
  const TalsecException({
    this.message,
    this.code = 'talsec-failure',
    this.stackTrace,
  });

  /// Constructs an instance of [TalsecException] from a [PlatformException].
  TalsecException.fromPlatformException(PlatformException exception)
      : this(
          message: exception.message,
          stackTrace: exception.stacktrace,
        );

  /// A [message] that provides human-readable information about the exception.
  final String? message;

  /// A [code] which identifies the type of exception.
  final String code;

  /// A [stackTrace] for this exception.
  final String? stackTrace;

  @override
  String toString() {
    var output = '$code: $message';

    if (stackTrace != null) {
      output += '\n\n$stackTrace';
    }

    return output;
  }
}
