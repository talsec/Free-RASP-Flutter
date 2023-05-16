import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

void main() {
  const code = 'test-failure';
  const message = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  const stackTrace = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  test('Should create an instance with default code', () {
    const exception = TalsecException();
    expect(exception.code, equals('talsec-failure'));
    expect(exception.message, isNull);
    expect(exception.stackTrace, isNull);
  });

  test('Should create an instance with custom code and message', () {
    const exception = TalsecException(code: code, message: message);

    expect(exception.code, equals(code));
    expect(exception.message, equals(message));
    expect(exception.stackTrace, isNull);
  });

  test('Should create an instance with custom code, message, and stackTrace',
      () {
    const exception = TalsecException(
      code: code,
      message: message,
      stackTrace: stackTrace,
    );

    expect(exception.code, equals(code));
    expect(exception.message, equals(message));
    expect(exception.stackTrace, equals(stackTrace));
  });

  test('toString should include code and message', () {
    const exception = TalsecException(code: code, message: message);
    expect(exception.toString(), equals('$code: $message'));
  });

  test('toString should include code, message, and stackTrace', () {
    const exception = TalsecException(
      code: code,
      message: message,
      stackTrace: stackTrace,
    );
    expect(exception.toString(), equals('$code: $message\n\n$stackTrace'));
  });
}
