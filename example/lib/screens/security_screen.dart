import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/models/security_check.dart';
import 'package:freerasp_example/providers/security_provider.dart';
import 'package:freerasp_example/widgets/common/titled_section.dart';
import 'package:freerasp_example/widgets/security/malware_alert_card.dart';
import 'package:freerasp_example/widgets/security/security_check_list.dart';
import 'package:freerasp_example/widgets/security/security_status_card.dart';
import 'package:freerasp_example/widgets/settings/settings_group.dart';
import 'package:freerasp_example/widgets/settings/tiles/external_id_tile.dart';
import 'package:freerasp_example/widgets/settings/tiles/screen_capture_tile.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityControllerProvider);
    final checksByCategory = securityState.checksByCategory;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 12,
            children: [
              const SecurityStatusCard(),
              const MalwareAlertCard(),
              TitledSection(
                title: 'App Integrity',
                child: SecurityCheckList(
                  checks: checksByCategory[ThreatCategory.appIntegrity] ?? [],
                ),
              ),
              TitledSection(
                title: 'Device Security',
                child: SecurityCheckList(
                  checks: checksByCategory[ThreatCategory.deviceSecurity] ?? [],
                ),
              ),
              TitledSection(
                title: 'Runtime Status',
                child: SecurityCheckList(
                  checks: checksByCategory[ThreatCategory.runtimeStatus] ?? [],
                ),
              ),
              const TitledSection(
                title: 'Other Settings',
                child: SettingsGroup(
                  items: [
                    ScreenCaptureTile(),
                    ExternalIdTile(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
