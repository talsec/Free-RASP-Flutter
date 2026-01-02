import 'package:flutter/material.dart';

class GroupedListItem extends StatelessWidget {
  const GroupedListItem({
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(),
      leading: leading != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: leading,
            )
          : null,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
