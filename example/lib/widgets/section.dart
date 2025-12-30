import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  const Section({
    required this.sectionTitle,
    required this.child,
    super.key,
  });

  final String sectionTitle;
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
            sectionTitle,
            style: textTheme.labelLarge?.copyWith(color: colors.primary),
          ),
        ),
        child
      ],
    );
  }
}

