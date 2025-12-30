import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/models/setting_item.dart';
import 'package:freerasp_example/providers/external_id_provider.dart';
import 'package:freerasp_example/providers/screen_capture_provider.dart';
import 'package:freerasp_example/widgets/list_item_card.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({
    required this.settings,
    super.key,
  });

  final List<SettingItem> settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (settings.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: settings.length,
      itemBuilder: (context, index) {
        final item = settings[index];
        final isFirst = index == 0;
        final isLast = index == settings.length - 1;

        Widget? trailing;
        String subtitle = item.description;
        
        if (item.type == SettingType.switch_) {
          if (item.id == 'screen_capture') {
            final screenCaptureState = ref.watch(screenCaptureProvider);
            trailing = screenCaptureState.when<Widget>(
              data: (bool isBlocked) => Switch(
                value: isBlocked,
                onChanged: (bool value) async {
                  await ref.read(screenCaptureProvider.notifier).toggle();
                },
              ),
              loading: () => const SizedBox(
                width: 48,
                height: 24,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const Icon(Icons.error),
            );
          }
        } else if (item.type == SettingType.editable) {
          if (item.id == 'external_id') {
            final externalId = ref.watch(externalIdProvider);
            subtitle = externalId ?? 'Not set';
            trailing = const Icon(Icons.chevron_right);
          }
        }

        return GestureDetector(
          onTap: item.type == SettingType.editable && item.id == 'external_id'
              ? () => _showExternalIdDialog(context, ref, item)
              : null,
          child: ListItemCard(
            title: item.name,
            subtitle: subtitle,
            isFirst: isFirst,
            isLast: isLast,
            trailing: trailing,
          ),
        );
      },
      separatorBuilder: (ctx, i) => const SizedBox(height: 2),
    );
  }

  void _showExternalIdDialog(
    BuildContext context,
    WidgetRef ref,
    SettingItem item,
  ) {
    final currentId = ref.read(externalIdProvider);
    final controller = TextEditingController(text: currentId ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name),
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
                  await ref.read(externalIdProvider.notifier).setExternalId(newId);
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

