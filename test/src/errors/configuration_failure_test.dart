import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

void main() {
  const message = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  const stackTrace = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  test('Should create an instance with default code', () {
    const exception = ConfigurationException();

    expect(exception.code, equals('configuration-exception'));
    expect(exception.message, isNull);
    expect(exception.stackTrace, isNull);
  });

  test('Should create an instance with custom message', () {
    const exception = ConfigurationException(message: message);

    expect(exception.code, equals('configuration-exception'));
    expect(exception.message, equals(message));
    expect(exception.stackTrace, isNull);
  });

  test('Should create an instance with custom message and stackTrace', () {
    const exception = ConfigurationException(
      message: message,
      stackTrace: stackTrace,
    );

    expect(exception.code, equals('configuration-exception'));
    expect(exception.message, equals(message));
    expect(exception.stackTrace, equals(stackTrace));
  });

  test('toString should include code and message', () {
    const exception = ConfigurationException(message: message);

    expect(exception.toString(), equals('configuration-exception: $message'));
  });

  test('toString should include code, message, and stackTrace', () {
    const exception = ConfigurationException(
      message: message,
      stackTrace: stackTrace,
    );

    expect(
      exception.toString(),
      equals('configuration-exception: $message\n\n$stackTrace'),
    );
  });
}
