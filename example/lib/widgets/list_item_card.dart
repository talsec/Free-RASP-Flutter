import 'package:flutter/material.dart';

class ListItemCard extends StatelessWidget {
  const ListItemCard({
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(radius) : Radius.zero,
          bottom: isLast ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
      leading: leading != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: leading,
            )
          : null,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
