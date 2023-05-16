// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import './mock_event_channel.dart';

/// Extension on [TestDefaultBinaryMessenger] to provide a mock method call
// TODO(future-dev): Remove when pipeline support for Dart 2.19 is added.
extension TestDefaultBinaryMessengerMockStreamHandlerExtension
    on TestDefaultBinaryMessenger {
  /// Set a handler for intercepting stream events sent to the
  /// platform on the given channel.
  ///
  /// Intercepted method calls are not forwarded to the platform.
  ///
  /// The given handler will replace the currently registered
  /// handler for that channel, if any. To stop intercepting messages
  /// at all, pass null as the handler.
  ///
  /// Events are decoded using the codec of the channel.
  ///
  /// The handler's stream messages are used as a response, after encoding
  /// them using the channel's codec.
  ///
  /// To send an error, pass the error information to the handler's event sink.
  ///
  /// {@macro flutter.flutter_test.TestDefaultBinaryMessenger.
  /// handlePlatformMessage.asyncHandlers}
  ///
  /// Registered handlers are cleared after each test.
  ///
  /// See also:
  ///
  ///  * [setMockMethodCallHandler], which is the similar method for
  ///    [MethodChannel].
  ///
  ///  * [setMockMessageHandler], which is similar but provides raw
  ///    access to the underlying bytes.
  ///
  ///  * [setMockDecodedMessageHandler], which is similar but decodes
  ///    the messages using a [MessageCodec].
  void setMockStreamHandler(EventChannel channel, MockStreamHandler? handler) {
    if (handler == null) {
      setMockMessageHandler(channel.name, null);
      return;
    }

    final controller = StreamController<Object?>();
    addTearDown(controller.close);

    setMockMethodCallHandler(MethodChannel(channel.name, channel.codec),
        (call) async {
      switch (call.method) {
        case 'listen':
          return handler.onListen(
            call.arguments,
            MockStreamHandlerEventSink(controller.sink),
          );
        case 'cancel':
          return handler.onCancel(call.arguments);
        default:
          throw UnimplementedError('Method ${call.method} not implemented');
      }
    });

    final sub = controller.stream.listen(
      (e) => handlePlatformMessage(
        channel.name,
        channel.codec.encodeSuccessEnvelope(e),
        null,
      ),
    );
    addTearDown(sub.cancel);
    sub.onError((dynamic e) {
      if (e is! PlatformException) {
        throw ArgumentError('Stream error must be a PlatformException');
      }
      handlePlatformMessage(
        channel.name,
        channel.codec.encodeErrorEnvelope(
          code: e.code,
          message: e.message,
          details: e.details,
        ),
        null,
      );
    });
    // ignore: cascade_invocations
    sub.onDone(() => handlePlatformMessage(channel.name, null, null));
  }
}
