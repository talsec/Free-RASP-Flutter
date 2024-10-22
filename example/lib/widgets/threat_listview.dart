import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/extensions.dart';
import 'package:freerasp_example/widgets/widgets.dart';

/// ListView displaying all detected threats
class ThreatListView extends StatelessWidget {
  /// Represents a list of detected threats
  const ThreatListView({super.key, required this.threats});

  /// Set of detected threats
  final Set<Threat> threats;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: Threat.values.length,
      itemBuilder: (context, index) {
        final currentThreat = Threat.values[index];
        final isDetected = threats.contains(currentThreat);

        return ListTile(
          title: Text(currentThreat.name.capitalize()),
          subtitle: Text(isDetected ? 'Danger' : 'Safe'),
          trailing: SafetyIcon(isDetected: isDetected),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}
