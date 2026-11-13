/// State of an ongoing call reported by the ongoing call detection.
///
/// Android only
enum CallState {
  /// A call started while the detection was running.
  started,

  /// A call was already in progress when the detection started.
  ongoing,

  /// A previously reported call has ended.
  stopped,
}
