import 'package:flutter/services.dart';
import 'package:freerasp/freerasp.dart';

/// An exception that is thrown when there is a failure with an external ID.
///
/// This exception extends the [TalsecException] class and includes an error
/// code of 'external-id-failure'. It can include an optional [message] and
/// [stackTrace] parameter.
class ExternalIdFailureException extends TalsecException {
  /// Constructs an instance of [ExternalIdFailureException].
  const ExternalIdFailureException({super.message, super.stackTrace})
      : super(code: 'external-id-failure');

  /// Constructs an instance of [ExternalIdFailureException] from a
  /// [PlatformException].
  ExternalIdFailureException.fromPlatformException(PlatformException exception)
      : this(message: exception.message, stackTrace: exception.stacktrace);
}
