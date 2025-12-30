import 'package:flutter/material.dart';
import 'package:freerasp_example/models/security_check.dart';
import 'package:freerasp_example/widgets/list_item_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    required this.checks,
    super.key,
  });

  final List<SecurityCheck> checks;

  @override
  Widget build(BuildContext context) {
    if (checks.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: checks.length,
      itemBuilder: (context, index) {
        final item = checks[index];
        final isFirst = index == 0;
        final isLast = index == checks.length - 1;

        return ListItemCard(
          title: item.name,
          subtitle: item.description,
          leading: Icon(
            item.isSecure ? Icons.check_circle : Icons.error,
            color: item.isSecure ? Colors.green : Colors.amber,
          ),
          isFirst: isFirst,
          isLast: isLast,
        );
      },
      separatorBuilder: (ctx, i) => const SizedBox(height: 2),
    );
  }
}

