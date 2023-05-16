import 'package:flutter/material.dart';

/// Class responsible for changing threat icon and style in the example app
class SafetyIcon extends StatelessWidget {
  /// Represents security state icon in the example app
  const SafetyIcon({required this.isDetected, Key? key}) : super(key: key);

  /// Determines whether given threat was detected
  final bool isDetected;

  @override
  Widget build(BuildContext context) {
    return isDetected
        ? const Icon(Icons.gpp_bad_outlined, color: Colors.red, size: 32)
        : const Icon(Icons.gpp_good_outlined, color: Colors.green, size: 32);
  }
}
