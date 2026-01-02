import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/providers/security_provider.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityControllerProvider);
    final isSecure = securityState.isAllSecure;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: AvatarGlow(
          glowColor: isSecure ? Colors.green : Colors.orange,
          glowRadiusFactor: 0.4,
          duration: const Duration(seconds: 1),
          glowCount: 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.security,
              color: isSecure ? Colors.green : Colors.orange,
              size: 32,
            ),
          ),
        ),
        title: Text(
          isSecure ? 'Device is Secure' : 'Device may be compromised',
        ),
        subtitle: Text(
          isSecure
              ? 'Checking security status...'
              : 'See alerts for more details',
        ),
      ),
    );
  }
}
