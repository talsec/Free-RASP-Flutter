import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/providers/screen_capture_provider.dart';
import 'package:freerasp_example/widgets/common/grouped_list_item.dart';

class ScreenCaptureTile extends ConsumerWidget {
  const ScreenCaptureTile({
    this.title = 'Block Screen Capture',
    this.subtitle = 'Prevent screenshots and screen recording',
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenCaptureState = ref.watch(screenCaptureProvider);

    final trailing = screenCaptureState.when(
      data: (isBlocked) => Switch(
        value: isBlocked,
        onChanged: (_) => ref.read(screenCaptureProvider.notifier).toggle(),
      ),
      loading: () => const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error),
    );

    return GroupedListItem(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }
}
