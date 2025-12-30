import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/models/security_state.dart';
import 'package:freerasp_example/providers/security_controller.dart';

/// Provider for the security controller that manages all security checks.
final securityControllerProvider =
    NotifierProvider.autoDispose<SecurityController, SecurityState>(
  () => SecurityController(),
);

