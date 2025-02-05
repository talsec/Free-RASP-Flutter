import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';

class ScreenNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<void> toggle() async {
    final isScreenCaptureBlocked =
        await Talsec.instance.isScreenCaptureBlocked();
    await Talsec.instance.blockScreenCapture(enabled: !isScreenCaptureBlocked);
    state = AsyncValue.data(!isScreenCaptureBlocked);
  }
}
