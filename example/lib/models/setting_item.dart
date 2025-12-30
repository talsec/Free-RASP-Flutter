enum SettingType {
  /// A simple informational setting
  info,
  
  /// A setting with a switch toggle
  switch_,
  
  /// A setting that can be edited (opens a dialog)
  editable,
}

class SettingItem {
  const SettingItem({
    required this.name,
    required this.description,
    this.type = SettingType.info,
    this.id,
  });

  final String name;
  final String description;
  final SettingType type;
  final String? id;
}

