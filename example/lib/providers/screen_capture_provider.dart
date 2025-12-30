import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/providers/screen_capture_notifier.dart';

/// Provider for screen capture blocking functionality
final screenCaptureProvider =
    AsyncNotifierProvider.autoDispose<ScreenCaptureNotifier, bool>(() {
  return ScreenCaptureNotifier();
});

