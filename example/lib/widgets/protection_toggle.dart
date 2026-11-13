import 'package:flutter/material.dart';

/// A row with a button that toggles an Android screen protection.
class ProtectionToggle extends StatefulWidget {
  /// Creates a [ProtectionToggle].
  const ProtectionToggle({
    required this.title,
    required this.isBlocked,
    required this.block,
    super.key,
  });

  /// Name of the protection.
  final String title;

  /// Reads whether the protection is active.
  final Future<bool> Function() isBlocked;

  /// Turns the protection on or off.
  final Future<void> Function({required bool enabled}) block;

  @override
  State<ProtectionToggle> createState() => _ProtectionToggleState();
}

class _ProtectionToggleState extends State<ProtectionToggle> {
  bool _isBlocked = false;

  Future<void> _toggle() async {
    await widget.block(enabled: !_isBlocked);
    final isBlocked = await widget.isBlocked();
    if (mounted) setState(() => _isBlocked = isBlocked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          ElevatedButton(
            onPressed: _toggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBlocked ? Colors.green : Colors.red,
            ),
            child: Text(
              _isBlocked ? 'Protected' : 'Unprotected',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
