import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/providers/security_controller_provider.dart';

class SuspiciousAppsScreen extends ConsumerWidget {
  const SuspiciousAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityControllerProvider);
    final suspiciousApps = securityState.detectedMalware;
    final textTheme = Theme.of(context).textTheme;
    const radius = 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suspicious Apps'),
      ),
      body: suspiciousApps.isEmpty
          ? Center(
              child: Text(
                'No suspicious apps detected',
                style: textTheme.bodyLarge,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: suspiciousApps.length,
                itemBuilder: (context, index) {
                  final app = suspiciousApps[index];
                  final isFirst = index == 0;
                  final isLast = index == suspiciousApps.length - 1;

                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: isFirst ? const Radius.circular(radius) : Radius.zero,
                        bottom: isLast ? const Radius.circular(radius) : Radius.zero,
                      ),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FutureBuilder<String?>(
                        future: Talsec.instance.getAppIcon(
                          app.packageInfo.packageName,
                        ),
                        builder: (context, snapshot) {
                          Widget appIcon;
                          if (snapshot.hasData && snapshot.data != null) {
                            try {
                              appIcon = ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64.decode(snapshot.data!),
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.android,
                                      size: 32,
                                    );
                                  },
                                ),
                              );
                            } catch (e) {
                              appIcon = const Icon(
                                Icons.android,
                                size: 32,
                              );
                            }
                          } else {
                            appIcon = const Icon(
                              Icons.android,
                              size: 32,
                            );
                          }

                          return appIcon;
                        },
                      ),
                    ),
                    title: Text(app.packageInfo.packageName),
                    subtitle: Text('Reason: ${app.reason}'),
                  );
                },
                separatorBuilder: (ctx, i) => const SizedBox(height: 2),
              ),
            ),
    );
  }
}
