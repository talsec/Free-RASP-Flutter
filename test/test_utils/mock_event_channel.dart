import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock_event_channel/mock_event_channel.dart';

class MockEventChannel {
  MockEventChannel({
    required this.eventChannel,
    required this.data,
    this.exceptions = const [],
  }) {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, _handler());
  }

  final EventChannel eventChannel;
  final List<String> data;
  final List<PlatformException> exceptions;

  MockStreamHandler _handler() {
    return MockStreamHandler.inline(
      onListen: (args, events) {
        for (final e in exceptions) {
          events.error(
            code: e.code,
            message: e.message,
            details: e.details,
          );
        }
        data.forEach(events.success);
        events.endOfStream();
      },
    );
  }
}
