import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';

/// Provider for screen capture blocking functionality
final screenCaptureProvider =
    AsyncNotifierProvider.autoDispose<ScreenCaptureNotifier, bool>(() {
  return ScreenCaptureNotifier();
});

/// Class responsible for triggering screen capture blocking
class ScreenCaptureNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  bool build() => false;

  /// Toggles screen capture blocking
  ///
  /// If screen capture is blocked, it will be unblocked and vice versa
  Future<void> toggle() async {
    final isScreenCaptureBlocked =
        await Talsec.instance.isScreenCaptureBlocked();
    await Talsec.instance.blockScreenCapture(enabled: !isScreenCaptureBlocked);
    state = AsyncValue.data(!isScreenCaptureBlocked);
  }
}
