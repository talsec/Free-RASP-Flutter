import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/extensions.dart';
import 'package:freerasp_example/widgets/widgets.dart';

/// ListView displaying all detected threats
class ThreatListView extends StatelessWidget {
  /// Represents a list of detected threats
  const ThreatListView({
    required this.threats,
    this.showOngoingCall = false,
    this.callState,
    super.key,
  });

  /// Set of detected threats
  final Set<Threat> threats;

  /// Whether to show the ongoing call row (Android only)
  final bool showOngoingCall;

  /// Last reported state of an ongoing call
  final CallState? callState;

  @override
  Widget build(BuildContext context) {
    // Ongoing call carries a state instead of being a Threat value, so it is
    // appended to the list as an extra row.
    final itemCount = Threat.values.length + (showOngoingCall ? 1 : 0);

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == Threat.values.length) {
          final isDetected =
              callState == CallState.started || callState == CallState.ongoing;
          return _ThreatTile(
            name: 'OngoingCall',
            isDetected: isDetected,
            subtitle: switch (callState) {
              null => 'Not detected',
              CallState.started => 'Started',
              CallState.ongoing => 'Ongoing',
              CallState.stopped => 'Stopped',
            },
          );
        }

        final currentThreat = Threat.values[index];
        return _ThreatTile(
          name: currentThreat.name.capitalize(),
          isDetected: threats.contains(currentThreat),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}

class _ThreatTile extends StatelessWidget {
  const _ThreatTile({
    required this.name,
    required this.isDetected,
    this.subtitle,
  });

  final String name;
  final bool isDetected;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(subtitle ?? (isDetected ? 'Danger' : 'Safe')),
      trailing: SafetyIcon(isDetected: isDetected),
    );
  }
}
