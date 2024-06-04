import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mock implementation of the [MethodChannel] class from the Flutter
/// framework.
///
/// It allows for testing of code that depends on [MethodChannel] without
/// actually invoking any platform-specific code.
///
/// Original code source: [Geolocator plugin tests](https://github.com/Baseflow/flutter-geolocator/blob/main/geolocator_platform_interface/test/src/implementations/method_channel_mock.dart).
class MockMethodChannel {
  /// Creates a new [MockMethodChannel] instance with the given [channelName],
  /// [method], and [result].
  ///
  /// If a [delay] is provided, a delayed [Future] will be returned by the mock
  /// method call handler.
  ///
  /// Throws a [MissingPluginException] if the method called by the mock method
  /// call handler does not match [method].
  MockMethodChannel({
    required String channelName,
    required this.method,
    this.result,
    this.delay = Duration.zero,
  }) : methodChannel = MethodChannel(channelName) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, _handler);
  }

  final Duration delay;
  final MethodChannel methodChannel;
  final String method;
  final Object? result;
  final log = <MethodCall>[];

  Future<dynamic> _handler(MethodCall methodCall) async {
    log.add(methodCall);

    if (methodCall.method != method) {
      throw MissingPluginException('No implementation found for method '
          '$method on channel ${methodChannel.name}');
    }

    return Future.delayed(delay, () {
      if (result is Exception) {
        // ignore: cast_nullable_to_non_nullable
        throw result as Exception;
      }

      return Future.value(result);
    });
  }
}
