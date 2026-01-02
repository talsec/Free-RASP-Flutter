import 'package:flutter/material.dart';

class TitledSection extends StatelessWidget {
  const TitledSection({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: textTheme.labelLarge?.copyWith(color: colors.primary),
          ),
        ),
        child,
      ],
    );
  }
}
