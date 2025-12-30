import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/models/security_check.dart';
import 'package:freerasp_example/models/setting_item.dart';
import 'package:freerasp_example/providers/security_controller_provider.dart';
import 'package:freerasp_example/widgets/category_section.dart';
import 'package:freerasp_example/widgets/malware_alert_card.dart';
import 'package:freerasp_example/widgets/section.dart';
import 'package:freerasp_example/widgets/security_status_card.dart';
import 'package:freerasp_example/widgets/settings_section.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityControllerProvider);
    final checksByCategory = securityState.checksByCategory;

    // Define your settings items
    const otherSettings = [
      SettingItem(
        name: 'Block Screen Capture',
        description: 'Prevent screenshots and screen recording',
        type: SettingType.switch_,
        id: 'screen_capture',
      ),
      SettingItem(
        name: 'External ID',
        description: 'Device identifier for log enrichment',
        type: SettingType.editable,
        id: 'external_id',
      ),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SecurityStatusCard(),
              const MalwareAlertCard(),
              Section(
                sectionTitle: 'App Integrity',
                child: CategorySection(
                  checks: checksByCategory[ThreatCategory.appIntegrity] ?? [],
                ),
              ),
              Section(
                sectionTitle: 'Device Security',
                child: CategorySection(
                  checks: checksByCategory[ThreatCategory.deviceSecurity] ?? [],
                ),
              ),
              Section(
                sectionTitle: 'Runtime Status',
                child: CategorySection(
                  checks: checksByCategory[ThreatCategory.runtimeStatus] ?? [],
                ),
              ),
              Section(
                sectionTitle: 'Other Settings',
                child: SettingsSection(settings: otherSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
