import 'package:flutter/material.dart';
import 'package:freerasp_example/models/security_check.dart';
import 'package:freerasp_example/widgets/common/grouped_list_item.dart';

class SecurityCheckList extends StatelessWidget {
  const SecurityCheckList({
    required this.checks,
    super.key,
  });

  final List<SecurityCheck> checks;

  @override
  Widget build(BuildContext context) {
    if (checks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        spacing: 2,
        children: checks.map((item) {
          return GroupedListItem(
            title: item.name,
            subtitle: item.description,
            leading: Icon(
              item.isSecure ? Icons.check_circle : Icons.error,
              color: item.isSecure ? Colors.green : Colors.amber,
            ),
          );
        }).toList(),
      ),
    );
  }
}
