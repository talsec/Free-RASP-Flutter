/// Extensions for the `String` class.
extension StringX on String {
  /// Converts the first character of the string to uppercase.
  ///
  /// If the string is empty, returns an empty string.
  ///
  /// If the string has only one character, returns the uppercase version of
  /// the character.
  ///
  /// Otherwise, returns the string with the first character converted to
  String toTitleCase() {
    if (isEmpty) return '';
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}
