import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';

class ExternalIdNotifier extends StateNotifier<String?> {
  ExternalIdNotifier() : super(null);

  Future<void> setExternalId(String id) async {
    try {
      await Talsec.instance.storeExternalId(id);
      state = id;
    } catch (e) {
      // Handle error - you might want to show a snackbar
      rethrow;
    }
  }

  void clearExternalId() {
    state = null;
  }
}

final externalIdProvider = StateNotifierProvider<ExternalIdNotifier, String?>(
  (ref) => ExternalIdNotifier(),
);

