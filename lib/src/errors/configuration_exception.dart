import 'package:freerasp/freerasp.dart';

/// An exception that is thrown when there is a failure with a Talsec
/// configuration.
///
/// This exception extends the [TalsecException] class and includes an error
/// code of 'configuration-exception'. It can include an optional [message] and
/// [stackTrace] parameter.
class ConfigurationException extends TalsecException {
  /// Constructs and instance of [ConfigurationException]
  const ConfigurationException({
    super.message,
    super.stackTrace,
  }) : super(
          code: 'configuration-exception',
        );
}
