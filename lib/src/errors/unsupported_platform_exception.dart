import 'package:freerasp/freerasp.dart';

/// An exception that is thrown when a method is not supported on the current
/// platform (e.g. an Android-only method called on iOS).
///
/// This exception extends the [TalsecException] class and includes an error
/// code of 'unsupported-platform'. It can include an optional [message] and
/// [stackTrace] parameter.
class UnsupportedPlatformException extends TalsecException {
  /// Constructs an instance of [UnsupportedPlatformException].
  const UnsupportedPlatformException({super.message, super.stackTrace})
      : super(code: 'unsupported-platform');
}
