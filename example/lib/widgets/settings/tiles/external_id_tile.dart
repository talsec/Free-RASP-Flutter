import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/providers/external_id_provider.dart';
import 'package:freerasp_example/widgets/common/grouped_list_item.dart';

class ExternalIdTile extends ConsumerWidget {
  const ExternalIdTile({
    this.title = 'External ID',
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final externalId = ref.watch(externalIdProvider);
    final subtitle = externalId ?? 'Not set';

    return GroupedListItem(
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showExternalIdDialog(context, ref),
    );
  }

  void _showExternalIdDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentId = ref.read(externalIdProvider);
    final controller = TextEditingController(text: currentId ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'External ID',
            hintText: 'Enter device identifier',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newId = controller.text.trim();
              if (newId.isNotEmpty) {
                try {
                  await ref
                      .read(externalIdProvider.notifier)
                      .setExternalId(newId);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('External ID saved successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Error saving external ID: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                // Clear the external ID if empty
                ref.read(externalIdProvider.notifier).clearExternalId();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
